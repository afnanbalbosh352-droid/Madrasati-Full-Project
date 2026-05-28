const express = require("express");

module.exports = (pool) => {

    const router = express.Router();

    // =====================================
    // TEACHER DASHBOARD
    // =====================================
    router.get("/dashboard/:teacherId", async (req, res) => {
        try {
            const { teacherId } = req.params;

            // TEACHER INFO
            const teacher = await pool.query(
                `
                SELECT
                    teachers.id,
                    users.full_name,
                    users.email,
                    users.phone,
                    teachers.specialization
                FROM teachers
                JOIN users ON teachers.user_id = users.id
                WHERE teachers.id = $1
                `,
                [teacherId]
            );

            // COUNTS
            const assignmentsCount = await pool.query(
                `
                SELECT COUNT(*) AS total
                FROM assignments
                WHERE teacher_id = $1
                `,
                [teacherId]
            );

            const activitiesCount = await pool.query(
                `
                SELECT COUNT(*) AS total
                FROM activities
                WHERE teacher_id = $1
                `,
                [teacherId]
            );

            const sectionsCount = await pool.query(
                `
                SELECT COUNT(DISTINCT section_id) AS total
                FROM teacher_subjects
                WHERE teacher_id = $1
                `,
                [teacherId]
            );

            res.json({
                success: true,
                teacher: teacher.rows[0],
                statistics: {
                    assignments: assignmentsCount.rows[0].total,
                    activities: activitiesCount.rows[0].total,
                    sections: sectionsCount.rows[0].total
                }
            });

        } catch (error) {
            console.log(error);
            res.status(500).json({
                success: false,
                error: error.message
            });
        }
    });

    // =====================================
    // GET TEACHER SECTIONS
    // =====================================
    router.get("/sections/:teacherId", async (req, res) => {
        try {
            const { teacherId } = req.params;

            const sections = await pool.query(
                `
                SELECT DISTINCT
                    sections.id,
                    sections.name AS section_name,
                    grades_levels.name AS grade_name
                FROM teacher_subjects
                JOIN sections ON teacher_subjects.section_id = sections.id
                JOIN grades_levels ON sections.grade_level_id = grades_levels.id
                WHERE teacher_subjects.teacher_id = $1
                ORDER BY grade_name ASC
                `,
                [teacherId]
            );

            res.json({
                success: true,
                sections: sections.rows
            });

        } catch (error) {
            console.log(error);
            res.status(500).json({
                success: false,
                error: error.message
            });
        }
    });

    // =====================================
    // GET SECTION STUDENTS
    // =====================================
    router.get("/section-students/:sectionId", async (req, res) => {
        try {
            const { sectionId } = req.params;

            const students = await pool.query(
                `
                SELECT
                    students.id,
                    students.student_number,
                    users.full_name
                FROM students
                JOIN users ON students.user_id = users.id
                WHERE students.section_id = $1
                ORDER BY users.full_name ASC
                `,
                [sectionId]
            );

            res.json({
                success: true,
                students: students.rows
            });

        } catch (error) {
            console.log(error);
            res.status(500).json({
                success: false,
                error: error.message
            });
        }
    });

    // =====================================
    // ADD ACTIVITY
    // =====================================
    router.post("/add-activity", async (req, res) => {
        try {
            const { teacher_id, section_id, title, description } = req.body;

            await pool.query(
                `
                INSERT INTO activities
                (id, teacher_id, section_id, title, description, status)
                VALUES
                (uuid_generate_v4(), $1, $2, $3, $4, 'pending')
                `,
                [teacher_id, section_id, title, description]
            );

            res.json({
                success: true,
                message: "Activity added and waiting admin approval"
            });

        } catch (error) {
            console.log(error);
            res.status(500).json({
                success: false,
                error: error.message
            });
        }
    });

    // =====================================
    // ADD ASSIGNMENT (واجب عام للصف)
    // =====================================
    router.post("/add-assignment", async (req, res) => {
        try {
            const {
                teacher_id,
                section_id,
                subject_id,
                title,
                description,
                due_date
            } = req.body;

            await pool.query(
                `
                INSERT INTO assignments
                (id, teacher_id, section_id, subject_id, title, description, due_date)
                VALUES
                (uuid_generate_v4(), $1, $2, $3, $4, $5, $6)
                `,
                [teacher_id, section_id, subject_id, title, description, due_date]
            );

            res.json({
                success: true,
                message: "Assignment added successfully"
            });

        } catch (error) {
            console.log(error);
            res.status(500).json({
                success: false,
                error: error.message
            });
        }
    });

    // =====================================
    // ADD ATTENDANCE
    // =====================================
    router.post("/add-attendance", async (req, res) => {
        try {
            const { student_id, teacher_id, attendance_date, status } = req.body;

            const existingAttendance = await pool.query(
                `
                SELECT * FROM attendance
                WHERE student_id = $1 AND attendance_date = $2
                `,
                [student_id, attendance_date]
            );

            if (existingAttendance.rows.length > 0) {
                return res.status(400).json({
                    success: false,
                    message: "Attendance already submitted"
                });
            }

            await pool.query(
                `
                INSERT INTO attendance
                (id, student_id, teacher_id, attendance_date, status)
                VALUES
                (uuid_generate_v4(), $1, $2, $3, $4)
                `,
                [student_id, teacher_id, attendance_date, status]
            );

            res.json({
                success: true,
                message: "Attendance added successfully"
            });

        } catch (error) {
            console.log(error);
            res.status(500).json({
                success: false,
                error: error.message
            });
        }
    });

    // =====================================
    // ADD GRADES
    // =====================================
    router.post("/add-grade", async (req, res) => {
        try {
            const { student_id, subject_id, teacher_id, exam_type, grade_value } = req.body;

            await pool.query(
                `
                INSERT INTO grades
                (id, student_id, subject_id, teacher_id, exam_type, grade_value, is_approved)
                VALUES
                (uuid_generate_v4(), $1, $2, $3, $4, $5, false)
                `,
                [student_id, subject_id, teacher_id, exam_type, grade_value]
            );

            res.json({
                success: true,
                message: "Grade submitted for admin review"
            });

        } catch (error) {
            console.log(error);
            res.status(500).json({
                success: false,
                error: error.message
            });
        }
    });

    // =====================================
    // ADD STUDENT EVALUATION
    // =====================================
    router.post("/add-evaluation", async (req, res) => {
        try {
            const {
                student_id,
                teacher_id,
                subject_id,
                evaluation_title,
                rating,
                note
            } = req.body;

            await pool.query(
                `
                INSERT INTO assessments
                (id, student_id, teacher_id, subject_id, evaluation_title, rating, note)
                VALUES
                (uuid_generate_v4(), $1, $2, $3, $4, $5, $6)
                `,
                [student_id, teacher_id, subject_id, evaluation_title, rating, note]
            );

            res.json({
                success: true,
                message: "Evaluation added successfully"
            });

        } catch (error) {
            console.log(error);
            res.status(500).json({
                success: false,
                error: error.message
            });
        }
    });

    // =====================================
    // GET CLASS SCHEDULE
    // =====================================
    router.get("/class-schedule/:teacherId", async (req, res) => {
        try {
            const { teacherId } = req.params;

            const schedule = await pool.query(
                `
                SELECT
                    class_schedule.day_of_week,
                    class_schedule.period_number,
                    class_schedule.start_time,
                    class_schedule.end_time,
                    subjects.name AS subject_name,
                    sections.name AS section_name,
                    grades_levels.name AS grade_name
                FROM class_schedule
                JOIN subjects ON class_schedule.subject_id = subjects.id
                JOIN sections ON class_schedule.section_id = sections.id
                JOIN grades_levels ON sections.grade_level_id = grades_levels.id
                WHERE class_schedule.teacher_id = $1
                ORDER BY day_of_week, period_number ASC
                `,
                [teacherId]
            );

            res.json({
                success: true,
                schedule: schedule.rows
            });

        } catch (error) {
            console.log(error);
            res.status(500).json({
                success: false,
                error: error.message
            });
        }
    });

    // =====================================
    // GET NOTIFICATIONS
    // =====================================
    router.get("/notifications", async (req, res) => {
        try {
            const notifications = await pool.query(
                `
                SELECT * FROM notifications
                ORDER BY created_at DESC
                `
            );

            res.json({
                success: true,
                notifications: notifications.rows
            });

        } catch (error) {
            console.log(error);
            res.status(500).json({
                success: false,
                error: error.message
            });
        }
    });

    // =====================================
    // GET TEACHER ASSIGNMENTS
    // =====================================
    router.get("/assignments/:teacherId", async (req, res) => {
        try {
            const { teacherId } = req.params;

            const assignments = await pool.query(
                `
                SELECT
                    assignments.id,
                    assignments.title,
                    assignments.description,
                    assignments.due_date,
                    subjects.name AS subject_name
                FROM assignments
                JOIN subjects ON assignments.subject_id = subjects.id
                WHERE assignments.teacher_id = $1
                ORDER BY assignments.created_at DESC
                `,
                [teacherId]
            );

            res.json({
                success: true,
                assignments: assignments.rows
            });

        } catch (error) {
            console.log(error);
            res.status(500).json({
                success: false,
                error: error.message
            });
        }
    });

    // =====================================
    // GET TEACHER ACTIVITIES
    // =====================================
    router.get("/activities/:teacherId", async (req, res) => {
        try {
            const { teacherId } = req.params;

            const activities = await pool.query(
                `
                SELECT * FROM activities
                WHERE teacher_id = $1
                ORDER BY created_at DESC
                `,
                [teacherId]
            );

            res.json({
                success: true,
                activities: activities.rows
            });

        } catch (error) {
            console.log(error);
            res.status(500).json({
                success: false,
                error: error.message
            });
        }
    });

    // =====================================
    // TEACHER SUBJECTS
    // =====================================
    router.get("/subjects/:teacherId", async (req, res) => {
        try {
            const { teacherId } = req.params;

            const subjects = await pool.query(
                `
                SELECT DISTINCT
                    subjects.id,
                    subjects.name
                FROM teacher_subjects   
                JOIN subjects ON teacher_subjects.subject_id = subjects.id
                WHERE teacher_subjects.teacher_id = $1
                ORDER BY subjects.name ASC
                `,
                [teacherId]
            );

            res.json({
                success: true,
                subjects: subjects.rows
            });

        } catch (error) {
            console.log(error);
            res.status(500).json({
                success: false,
                error: error.message
            });
        }
    });

    // =====================================
    // GET TEACHER STUDENTS
    // =====================================
    router.get("/teacher-students/:teacherId", async (req, res) => {
        try {
            const { teacherId } = req.params;

            const students = await pool.query(
                `
                SELECT DISTINCT
                    students.id,
                    users.full_name
                FROM teacher_subjects
                JOIN students ON teacher_subjects.section_id = students.section_id
                JOIN users ON students.user_id = users.id
                WHERE teacher_subjects.teacher_id = $1
                ORDER BY users.full_name ASC
                `,
                [teacherId]
            );

            res.json({
                success: true,
                students: students.rows
            });

        } catch (error) {
            console.log(error);
            res.status(500).json({
                success: false,
                error: error.message
            });
        }
    });

    // =====================================
    // GET TEACHER CHATS
    // =====================================
    router.get("/teacher-chats/:teacherId", async (req, res) => {
        try {
            const { teacherId } = req.params;

            const chats = await pool.query(
                `
                SELECT
                    chats.id AS chat_id,
                    students.id AS student_id,
                    users.full_name AS student_name,
                    (
                        SELECT message FROM messages
                        WHERE messages.chat_id = chats.id
                        ORDER BY created_at DESC LIMIT 1
                    ) AS last_message,
                    (
                        SELECT created_at FROM messages
                        WHERE messages.chat_id = chats.id
                        ORDER BY created_at DESC LIMIT 1
                    ) AS last_message_time
                FROM chats
                JOIN students ON chats.student_id = students.id
                JOIN users ON students.user_id = users.id
                WHERE chats.teacher_id = $1
                ORDER BY last_message_time DESC NULLS LAST
                `,
                [teacherId]
            );

            res.json({
                success: true,
                chats: chats.rows
            });

        } catch (error) {
            console.log(error);
            res.status(500).json({
                success: false,
                error: error.message
            });
        }
    });

    // =====================================
    // GET CHAT MESSAGES
    // =====================================
    router.get("/messages/:chatId", async (req, res) => {
        try {
            const { chatId } = req.params;

            const messages = await pool.query(
                `
                SELECT id, chat_id, sender_user_id, message, created_at
                FROM messages
                WHERE chat_id = $1
                ORDER BY created_at ASC
                `,
                [chatId]
            );

            res.json({
                success: true,
                messages: messages.rows
            });

        } catch (error) {
            console.log(error);
            res.status(500).json({
                success: false,
                error: error.message
            });
        }
    });

    // =====================================
    // SEND MESSAGE
    // =====================================
    router.post("/send-message", async (req, res) => {
        try {
            const { chat_id, sender_user_id, message } = req.body;

            if (!chat_id || !sender_user_id || !message) {
                return res.status(400).json({
                    success: false,
                    message: "Missing required fields"
                });
            }

            await pool.query(
                `
                INSERT INTO messages (id, chat_id, sender_user_id, message)
                VALUES (uuid_generate_v4(), $1, $2, $3)
                `,
                [chat_id, sender_user_id, message]
            );

            res.json({
                success: true,
                message: "Message sent successfully"
            });

        } catch (error) {
            console.log(error);
            res.status(500).json({
                success: false,
                error: error.message
            });
        }
    });

    // =====================================
    // SEND NOTIFICATION
    // =====================================
    router.post("/send-notification", async (req, res) => {
        try {
            const { teacher_id, section_id, title, message, type } = req.body;

            if (!teacher_id || !section_id || !title || !message || !type) {
                return res.status(400).json({
                    success: false,
                    message: "Missing required fields"
                });
            }

            await pool.query(
                `
                INSERT INTO notifications (id, teacher_id, section_id, title, description, type, target_type)
                VALUES (uuid_generate_v4(), $1, $2, $3, $4, $5, 'section')
                `,
                [teacher_id, section_id, title, message, type]
            );

            res.json({
                success: true,
                message: "Notification sent successfully"
            });

        } catch (error) {
            console.log(error);
            res.status(500).json({
                success: false,
                error: error.message
            });
        }
    });

    // =====================================
    // GET NOTIFICATIONS
    // =====================================
    router.get("/teacher-notifications/:teacherId", async (req, res) => {
        try {
            const { teacherId } = req.params;

            const notifications = await pool.query(
                `
                SELECT * FROM notifications
                WHERE admin_id = $1
                ORDER BY created_at DESC
                `,
                [teacherId]
            );

            res.json({
                success: true,
                notifications: notifications.rows
            });

        } catch (error) {
            console.log(error);
            res.status(500).json({
                success: false,
                error: error.message
            });
        }
    });

    // =====================================
    // DELETE NOTIFICATION
    // =====================================
    router.delete("/teacher-notifications/:id", async (req, res) => {
        try {
            const { id } = req.params;

            await pool.query(
                `
                DELETE FROM teacher_notifications
                WHERE id = $1
                `,
                [id]
            );

            res.json({
                success: true,
                message: "Notification deleted successfully"
            });

        } catch (error) {
            console.log(error);
            res.status(500).json({
                success: false,
                error: error.message
            });
        }
    });

    // ===================================================================
    // GET STUDENT ASSESSMENTS (الـ Route الجديد والناقص اللي بحل المشكلة)
    // ===================================================================
    router.get("/student-assessments/:studentId", async (req, res) => {
        try {
            const { studentId } = req.params;

            const assessments = await pool.query(
                `
                SELECT 
                    assessments.id,
                    assessments.evaluation_title,
                    assessments.rating,
                    assessments.note,
                    subjects.name AS subject_name
                FROM assessments
                LEFT JOIN subjects ON assessments.subject_id = subjects.id
                WHERE assessments.student_id = $1
                ORDER BY assessments.id DESC
                `,
                [studentId]
            );

            res.json({
                success: true,
                assessments: assessments.rows
            });

        } catch (error) {
            console.log(error);
            res.status(500).json({
                success: false,
                error: error.message
            });
        }
    });

    return router;
};