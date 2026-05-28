const express = require("express");

module.exports = (pool) => {

    const router = express.Router();

    // =====================================
    // STUDENT DASHBOARD
    // =====================================

    router.get("/dashboard/:studentId", async (req, res) => {

        try {

            const { studentId } = req.params;

            // =========================
            // STUDENT INFO
            // =========================

            const studentInfo = await pool.query(
                `
                SELECT
                    students.id,
                    students.student_number,
                    users.full_name,
                    users.email,
                    users.phone,
                    sections.name AS section_name,
                    grades_levels.name AS grade_name
                FROM students

                JOIN users
                ON students.user_id = users.id

                JOIN sections
                ON students.section_id = sections.id

                JOIN grades_levels
                ON sections.grade_level_id = grades_levels.id

                WHERE students.id = $1
                `,
                [studentId]
            );

            // =========================
            // COUNTS
            // =========================

            const activitiesCount = await pool.query(
                `
                SELECT COUNT(*) AS total
                FROM activities
                WHERE section_id =
                (
                    SELECT section_id
                    FROM students
                    WHERE id = $1
                )
                `,
                [studentId]
            );

            const assignmentsCount = await pool.query(
                `
                SELECT COUNT(*) AS total
                FROM assignments
                WHERE section_id =
                (
                    SELECT section_id
                    FROM students
                    WHERE id = $1
                )
                `,
                [studentId]
            );

            const warningsCount = await pool.query(
                `
                SELECT COUNT(*) AS total
                FROM warnings
                WHERE student_id = $1
                `,
                [studentId]
            );

            res.json({
                success: true,
                student: studentInfo.rows[0],
                statistics: {
                    activities: activitiesCount.rows[0].total,
                    assignments: assignmentsCount.rows[0].total,
                    warnings: warningsCount.rows[0].total
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
    // STUDENT ACTIVITIES
    // =====================================

    router.get("/activities/:studentId", async (req, res) => {

        try {

            const { studentId } = req.params;

            const student = await pool.query(
                `
                SELECT section_id
                FROM students
                WHERE id = $1
                `,
                [studentId]
            );

            if (student.rows.length === 0) {

                return res.status(404).json({
                    success: false,
                    message: "Student not found"
                });

            }

            const sectionId = student.rows[0].section_id;

            const activities = await pool.query(
                `
                SELECT
                    id,
                    title,
                    description,
                    created_at
                FROM activities
                WHERE section_id = $1
                AND status = 'approved'
                ORDER BY created_at DESC
                `,
                [sectionId]
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
    // EXAM SCHEDULE
    // =====================================

    router.get("/exam-schedule/:studentId", async (req, res) => {

        try {

            const { studentId } = req.params;

            const student = await pool.query(
                `
                SELECT section_id
                FROM students
                WHERE id = $1
                `,
                [studentId]
            );

            const sectionId = student.rows[0].section_id;

            const exams = await pool.query(
                `
                SELECT
                    exam_schedules.id,
                    exam_schedules.exam_title,
                    exam_schedules.exam_date,
                    exam_schedules.exam_time,
                    subjects.name AS subject_name
                FROM exam_schedules

                JOIN subjects
                ON exam_schedules.subject_id = subjects.id

                WHERE exam_schedules.section_id = $1

                ORDER BY exam_date ASC
                `,
                [sectionId]
            );

            res.json({
                success: true,
                exams: exams.rows
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
    // STUDENT ASSIGNMENTS
    // =====================================

    router.get("/assignments/:studentId", async (req, res) => {

        try {

            const { studentId } = req.params;

            const student = await pool.query(
                `
                SELECT section_id
                FROM students
                WHERE id = $1
                `,
                [studentId]
            );

            const sectionId = student.rows[0].section_id;

            const assignments = await pool.query(
                `
                SELECT
                    assignments.id,
                    assignments.title,
                    assignments.description,
                    assignments.due_date,
                    subjects.name AS subject_name
                FROM assignments

                JOIN subjects
                ON assignments.subject_id = subjects.id

                WHERE assignments.section_id = $1

                ORDER BY due_date ASC
                `,
                [sectionId]
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
    // CLASS SCHEDULE
    // =====================================

    router.get("/class-schedule/:studentId", async (req, res) => {

        try {

            const { studentId } = req.params;

            const student = await pool.query(
                `
                SELECT section_id
                FROM students
                WHERE id = $1
                `,
                [studentId]
            );

            const sectionId = student.rows[0].section_id;

            const schedule = await pool.query(
                `
                SELECT
                    class_schedule.day_of_week,
                    class_schedule.period_number,
                    class_schedule.start_time,
                    class_schedule.end_time,
                    subjects.name AS subject_name,
                    users.full_name AS teacher_name
                FROM class_schedule

                JOIN subjects
                ON class_schedule.subject_id = subjects.id

                JOIN teachers
                ON class_schedule.teacher_id = teachers.id

                JOIN users
                ON teachers.user_id = users.id

                WHERE class_schedule.section_id = $1

                ORDER BY
                    day_of_week,
                    period_number ASC
                `,
                [sectionId]
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
    // STUDENT GRADES
    // =====================================

    router.get("/grades/:studentId", async (req, res) => {

        try {

            const { studentId } = req.params;

            const grades = await pool.query(
                `
                SELECT
                    grades.id,
                    grades.exam_type,
                    grades.grade_value,
                    grades.is_approved,
                    subjects.name AS subject_name
                FROM grades

                JOIN subjects
                ON grades.subject_id = subjects.id

                WHERE grades.student_id = $1

                ORDER BY grades.created_at DESC
                `,
                [studentId]
            );

            res.json({
                success: true,
                grades: grades.rows
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
    // STUDENT ASSESSMENTS
    // =====================================

    router.get("/assessments/:studentId", async (req, res) => {

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

                JOIN subjects
                ON assessments.subject_id = subjects.id

                WHERE assessments.student_id = $1

                ORDER BY assessments.created_at DESC
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


    // =====================================
    // STUDENT ATTENDANCE
    // =====================================

    router.get("/attendance/:studentId", async (req, res) => {

        try {

            const { studentId } = req.params;

            const attendance = await pool.query(
                `
                SELECT *
                FROM attendance
                WHERE student_id = $1
                ORDER BY attendance_date DESC
                `,
                [studentId]
            );

            const absentDays = await pool.query(
                `
                SELECT COUNT(*) AS total_absent
                FROM attendance
                WHERE student_id = $1
                AND status = 'absent'
                `,
                [studentId]
            );

            const absent = parseInt(absentDays.rows[0].total_absent);

            const limit = 20;

            const remaining = limit - absent;

            res.json({
                success: true,
                statistics: {
                    absent_days: absent,
                    limit: limit,
                    remaining: remaining
                },
                attendance: attendance.rows
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
    // STUDENT WARNINGS
    // =====================================

    router.get("/warnings/:studentId", async (req, res) => {

        try {

            const { studentId } = req.params;

            const warnings = await pool.query(
                `
                SELECT
                    warning_type,
                    reason,
                    action_taken,
                    warning_date
                FROM warnings
                WHERE student_id = $1
                ORDER BY warning_date DESC
                `,
                [studentId]
            );

            res.json({
                success: true,
                warnings: warnings.rows
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
    // STUDENT NOTIFICATIONS
    // =====================================

    router.get("/notifications", async (req, res) => {

        try {

            const notifications = await pool.query(
                `
                SELECT *
                FROM notifications
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
    // TEACHERS LIST
    // =====================================

    router.get("/teachers", async (req, res) => {

        try {

            const teachers = await pool.query(
                `
                SELECT
                    teachers.id,
                    users.full_name,
                    teachers.specialization
                FROM teachers

                JOIN users
                ON teachers.user_id = users.id

                ORDER BY users.full_name ASC
                `
            );

            res.json({
                success: true,
                teachers: teachers.rows
            });

        } catch (error) {

            console.log(error);

            res.status(500).json({
                success: false,
                error: error.message
            });

        }

    });




       router.post("/create-or-get22", async (req, res) => {

        try {

            const {
                student_id,
                teacher_id
            } = req.body;

            let chat = await pool.query(
                `
                SELECT *
                FROM chats
                WHERE student_id = $1
                AND teacher_id = $2
                `,
                [student_id, teacher_id]
            );

            // =============================
            // CREATE CHAT
            // =============================

            if (chat.rows.length === 0) {

                const newChat =
                    await pool.query(
                        `
                        INSERT INTO chats
                        (
                            id,
                            student_id,
                            teacher_id,
                            created_at
                        )
                        VALUES
                        (
                            uuid_generate_v4(),
                            $1,
                            $2,
                            NOW()
                        )
                        RETURNING *
                        `,
                        [student_id, teacher_id]
                    );

                chat = newChat;

            }

            res.json({

                success: true,

                chat: chat.rows[0],

            });

        }

        catch (error) {

            console.log(error);

            res.status(500).json({

                success: false,

                error: error.message,

            });

        }

    });

    // =====================================
    // GET MESSAGES
    // =====================================

    router.get("/messages/:chatId", async (req, res) => {

        try {

            const { chatId } =
                req.params;

            const messages =
                await pool.query(
                    `
                    SELECT *
                    FROM messages
                    WHERE chat_id = $1
                    ORDER BY created_at ASC
                    `,
                    [chatId]
                );

            res.json({

                success: true,

                messages: messages.rows,

            });

        }

        catch (error) {

            console.log(error);

            res.status(500).json({

                success: false,

                error: error.message,

            });

        }

    });

    // =====================================
    // SEND MESSAGE
    // =====================================

    router.post("/chat/send-message", async (req, res) => {

        try {

            const {
                chat_id,
                sender_user_id,
                message
            } = req.body;

            const newMessage =
                await pool.query(
                    `
                    INSERT INTO messages
                    (
                        id,
                        chat_id,
                        sender_user_id,
                        message,
                        created_at
                    )
                    VALUES
                    (
                        uuid_generate_v4(),
                        $1,
                        $2,
                        $3,
                        NOW()
                    )
                    RETURNING *
                    `,
                    [
                        chat_id,
                        sender_user_id,
                        message
                    ]
                );

            res.json({

                success: true,

                message:
                newMessage.rows[0],

            });

        }

        catch (error) {

            console.log(error);

            res.status(500).json({

                success: false,

                error: error.message,

            });

        }

    });



// =====================================
// CREATE OR GET CHAT
// =====================================

router.post("/chat/create-or-get", async (req, res) => {

    try {

        const {
            student_id,
            teacher_id
        } = req.body;

        const existingChat = await pool.query(
            `
            SELECT *
            FROM chats
            WHERE student_id = $1
            AND teacher_id = $2
            `,
            [student_id, teacher_id]
        );

        // =============================
        // CHAT EXISTS
        // =============================

        if (existingChat.rows.length > 0) {

            return res.json({

                success: true,

                chat:
                existingChat.rows[0],

            });

        }

        // =============================
        // CREATE CHAT
        // =============================

        const newChat = await pool.query(
            `
            INSERT INTO chats
            (
                id,
                student_id,
                teacher_id,
                created_at
            )
            VALUES
            (
                uuid_generate_v4(),
                $1,
                $2,
                NOW()
            )
            RETURNING *
            `,
            [student_id, teacher_id]
        );

        res.json({

            success: true,

            chat:
            newChat.rows[0],

        });

    }

    catch (error) {

        console.log(error);

        res.status(500).json({

            success: false,

            error: error.message,

        });

    }

});






// =====================================
// GET MESSAGES
// =====================================

router.get("/chat/messages/:chatId", async (req, res) => {
        try {
            const { chatId } = req.params;
            const messages = await pool.query(
                `
                SELECT *
                FROM messages
                WHERE chat_id = $1
                ORDER BY created_at ASC
                `,
                [chatId]
            );

            res.json({
                success: true,
                messages: messages.rows,
            });
        } catch (error) {
            console.log(error);
            res.status(500).json({
                success: false,
                error: error.message,
            });
        }
    }); // <--- تأكدي من إغلاق دالة الـ get هنا

    return router; // <--- إرجاع الـ router للـ app.js
};