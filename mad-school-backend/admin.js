const express = require("express");

module.exports = (pool) => {

    const router = express.Router();

    // =====================================
    // ADMIN DASHBOARD
    // =====================================

    router.get("/dashboard/:adminId", async (req, res) => {

        try {

            const totalStudents = await pool.query(`
                SELECT COUNT(*) AS total
                FROM students
            `);

            const totalTeachers = await pool.query(`
                SELECT COUNT(*) AS total
                FROM teachers
            `);

            const totalSections = await pool.query(`
                SELECT COUNT(*) AS total
                FROM sections
            `);

            const totalWarnings = await pool.query(`
                SELECT COUNT(*) AS total
                FROM warnings
            `);

            const pendingActivities = await pool.query(`
                SELECT COUNT(*) AS total
                FROM activities
                WHERE status = 'pending'
            `);

            const pendingGrades = await pool.query(`
                SELECT COUNT(*) AS total
                FROM grades
                WHERE is_approved = false
            `);

            res.json({
                success: true,
                statistics: {
                    students: totalStudents.rows[0].total,
                    teachers: totalTeachers.rows[0].total,
                    sections: totalSections.rows[0].total,
                    warnings: totalWarnings.rows[0].total,
                    pending_activities: pendingActivities.rows[0].total,
                    pending_grades: pendingGrades.rows[0].total
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
    // GET ALL STUDENTS
    // =====================================

    router.get("/students", async (req, res) => {

        try {

            const students = await pool.query(`
                SELECT
                    students.id,
                    students.student_number,
                    users.full_name,
                    users.national_id,
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

                ORDER BY users.full_name ASC
            `);

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
// GET ALL TEACHERS
// =====================================

router.get("/teachers", async (req, res) => {

    try {

        const teachers = await pool.query(

            `
            SELECT

                teachers.id,

                users.full_name,

                users.national_id,

                users.phone,

                teachers.specialization,

                sections.id AS section_id,

                sections.name AS section_name,

                grades_levels.name AS grade_name,

                subjects.id AS subject_id,

                subjects.name AS subject_name

            FROM teachers

            JOIN users
            ON teachers.user_id = users.id

            LEFT JOIN teacher_subjects
            ON teacher_subjects.teacher_id =
            teachers.id

            LEFT JOIN sections
            ON teacher_subjects.section_id =
            sections.id

            LEFT JOIN grades_levels
            ON sections.grade_level_id =
            grades_levels.id

            LEFT JOIN subjects
            ON teacher_subjects.subject_id =
            subjects.id

            ORDER BY users.full_name ASC
            `

        );

        res.json({

            success: true,

            teachers:
            teachers.rows,

        });

    }

    catch (error) {

        console.log(error);

        res.status(500).json({

            success: false,

            message:
            error.message,

        });

    }

});


    


    // =====================================
    // GET ALL TEACHERS
    // =====================================

    router.get("/teachers", async (req, res) => {

        try {

            const teachers = await pool.query(`
                SELECT
                    teachers.id,
                    users.full_name,
                    users.national_id,
                    users.phone,
                    teachers.specialization
                FROM teachers

                JOIN users
                ON teachers.user_id = users.id

                ORDER BY users.full_name ASC
            `);

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


    // =====================================
    // GET SECTIONS
    // =====================================

// =====================================
// GET SECTIONS
// =====================================

router.get("/sections", async (req, res) => {

    try {

        const sections = await pool.query(

            `
            SELECT

                sections.id,
                sections.name,
                sections.grade_level_id,
                grades_levels.name AS grade_name

            FROM sections

            JOIN grades_levels
            ON sections.grade_level_id = grades_levels.id

            ORDER BY grades_levels.name ASC
            `

        );

        res.json({

            success: true,
            sections: sections.rows

        });

    }

    catch (error) {

        console.log(error);

        res.status(500).json({

            success: false,
            error: error.message

        });

    }

});


    // =====================================
    // ASSIGN CLASS TEACHER
    // =====================================

    router.post("/assign-class-teacher", async (req, res) => {

        try {

            const {
                section_id,
                teacher_id
            } = req.body;

            await pool.query(
                `
                UPDATE sections
                SET class_teacher_id = $1
                WHERE id = $2
                `,
                [
                    teacher_id,
                    section_id
                ]
            );

            res.json({
                success: true,
                message: "Class teacher assigned successfully"
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
    // GET PENDING ACTIVITIES
    // =====================================

    router.get("/pending-activities", async (req, res) => {

        try {

            const activities = await pool.query(`
                SELECT
                    activities.id,
                    activities.title,
                    activities.description,
                    activities.status,
                    users.full_name AS teacher_name
                FROM activities

                JOIN teachers
                ON activities.teacher_id = teachers.id

                JOIN users
                ON teachers.user_id = users.id

                WHERE activities.status = 'pending'

                ORDER BY activities.created_at DESC
            `);

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
    // APPROVE ACTIVITY
    // =====================================

    router.post("/approve-activity", async (req, res) => {

        try {

            const { activity_id } = req.body;

            await pool.query(
                `
                UPDATE activities
                SET status = 'approved'
                WHERE id = $1
                `,
                [activity_id]
            );

            res.json({
                success: true,
                message: "Activity approved successfully"
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
    // REJECT ACTIVITY
    // =====================================

    router.post("/reject-activity", async (req, res) => {

        try {

            const { activity_id } = req.body;

            await pool.query(
                `
                UPDATE activities
                SET status = 'rejected'
                WHERE id = $1
                `,
                [activity_id]
            );

            res.json({
                success: true,
                message: "Activity rejected successfully"
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

            const {
                admin_id,
                title,
                description,
                target_type
            } = req.body;

            await pool.query(
                `
                INSERT INTO notifications
                (
                    id,
                    admin_id,
                    title,
                    description,
                    target_type
                )
                VALUES
                (
                    uuid_generate_v4(),
                    $1,
                    $2,
                    $3,
                    $4
                )
                `,
                [
                    admin_id,
                    title,
                    description,
                    target_type
                ]
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
    // GET PENDING GRADES
    // =====================================

    router.get("/pending-grades", async (req, res) => {

        try {

            const grades = await pool.query(`
                SELECT
                    grades.id,
                    grades.exam_type,
                    grades.grade_value,
                    users.full_name AS student_name,
                    subjects.name AS subject_name
                FROM grades

                JOIN students
                ON grades.student_id = students.id

                JOIN users
                ON students.user_id = users.id

                JOIN subjects
                ON grades.subject_id = subjects.id

                WHERE grades.is_approved = false

                ORDER BY grades.created_at DESC
            `);

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
    // APPROVE GRADE
    // =====================================

    router.post("/approve-grade", async (req, res) => {

        try {

            const { grade_id } = req.body;

            await pool.query(
                `
                UPDATE grades
                SET is_approved = true
                WHERE id = $1
                `,
                [grade_id]
            );

            res.json({
                success: true,
                message: "Grade approved successfully"
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
// GET ATTENDANCE
// =====================================

router.get("/attendance", async (req, res) => {

    try {

        const { attendance_date } = req.query;

        if (!attendance_date) {

            return res.status(400).json({

                success: false,

                message:
                "attendance_date is required",

            });

        }

        // =====================================
        // CHECK WEEKEND
        // =====================================

        const selectedDate =
        new Date(attendance_date);

        const day =
        selectedDate.getDay();

        // Friday = 5
        // Saturday = 6

        if (day === 5 || day === 6) {

            return res.status(400).json({

                success: false,

                is_holiday: true,

                message:
                "Cannot take attendance on Friday or Saturday",

            });

        }

        // =====================================
        // GET STUDENTS + TODAY ATTENDANCE
        // =====================================

        const result = await pool.query(

            `
            SELECT

                students.id,

                users.full_name,

                grades_levels.name AS grade,

                sections.name AS section,

                COALESCE(
                    attendance.status,
                    'Absent'
                ) AS status,

                (
                    SELECT COUNT(*)
                    FROM attendance a2
                    WHERE
                    a2.student_id = students.id
                    AND LOWER(a2.status) = 'absent'
                ) AS absences_count

            FROM students

            JOIN users
            ON students.user_id = users.id

            JOIN sections
            ON students.section_id = sections.id

            JOIN grades_levels
            ON sections.grade_level_id =
            grades_levels.id

            LEFT JOIN attendance
            ON attendance.student_id =
            students.id

            AND attendance.attendance_date = $1

            ORDER BY users.full_name ASC
            `,
            [attendance_date]

        );

        // =====================================
        // BUILD SCHOOL DATA
        // =====================================

        let schoolData = {};

        result.rows.forEach((student) => {

            const grade =
            student.grade;

            const section =
            student.section;

            if (!schoolData[grade]) {

                schoolData[grade] = {};

            }

            if (!schoolData[grade][section]) {

                schoolData[grade][section] = [];

            }

            schoolData[grade][section].push({

                id:
                student.id,

                name:
                student.full_name,

                status:
                student.status.toLowerCase(),

            });

        });

        // =====================================
        // AT RISK STUDENTS
        // =====================================

        const atRiskStudents =
        result.rows

            .filter(
                (s) =>
                parseInt(
                    s.absences_count
                ) >= 7
            )

            .map((s) => ({

                id:
                s.id,

                name:
                s.full_name,

                absences:
                s.absences_count,

                class:
                `${s.grade}-${s.section}`,

            }));

        // =====================================
        // RESPONSE
        // =====================================

        res.json({

            success: true,

            school_data:
            schoolData,

            at_risk_students:
            atRiskStudents,

        });

    }

    catch (error) {

        console.log(error);

        res.status(500).json({

            success: false,

            message:
            error.message,

        });

    }

});



// =====================================
// SAVE ATTENDANCE
// =====================================

router.post("/attendance", async (req, res) => {

    try {

        const {
            students,
            attendance_date
        } = req.body;

        if (!attendance_date) {

            return res.status(400).json({

                success: false,

                message:
                "attendance_date is required",

            });

        }

        // =====================================
        // CHECK HOLIDAY
        // =====================================

        const selectedDate =
        new Date(attendance_date);

        const day =
        selectedDate.getDay();

        if (day === 5 || day === 6) {

            return res.status(400).json({

                success: false,

                is_holiday: true,

                message:
                "Cannot save attendance on Friday or Saturday",

            });

        }

        // =====================================
        // SAVE STUDENTS
        // =====================================

        for (const student of students) {

            // =============================
            // CHECK EXISTING
            // =============================

            const existing =
            await pool.query(

                `
                SELECT *
                FROM attendance
                WHERE student_id = $1
                AND attendance_date = $2
                `,
                [
                    student.id,
                    attendance_date
                ]

            );

            // =============================
            // UPDATE
            // =============================

            if (existing.rows.length > 0) {

                await pool.query(

                    `
                    UPDATE attendance
                    SET status = $1
                    WHERE student_id = $2
                    AND attendance_date = $3
                    `,
                    [
                        student.status.toLowerCase(),
                        student.id,
                        attendance_date
                    ]

                );

            }

            // =============================
            // INSERT
            // =============================

            else {

                await pool.query(

                    `
                    INSERT INTO attendance
                    (
                        id,
                        student_id,
                        attendance_date,
                        status
                    )
                    VALUES
                    (
                        uuid_generate_v4(),
                        $1,
                        $2,
                        $3
                    )
                    `,
                    [
                        student.id,
                        attendance_date,
                        student.status.toLowerCase()
                    ]

                );

            }

        }

        res.json({

            success: true,

            message:
            "Attendance saved successfully",

        });

    }

    catch (error) {

        console.log(error);

        res.status(500).json({

            success: false,

            message:
            error.message,

        });

    }

});



// =====================================
// GET GRADES
// =====================================

router.get("/grades", async (req, res) => {

    try {

        const grades = await pool.query(`

            SELECT
                id,
                name
            FROM grades_levels

            ORDER BY name ASC

        `);

        res.json({

            success: true,

            grades:
            grades.rows,

        });

    }

    catch (error) {

        console.log(error);

        res.status(500).json({

            success: false,

            message:
            error.message,

        });

    }

});




// =====================================
// GET SUBJECTS
// =====================================

router.get("/subjects", async (req, res) => {

    try {

        const subjects = await pool.query(`

            SELECT
                id,
                name
            FROM subjects

            ORDER BY name ASC

        `);

        res.json({

            success: true,

            subjects:
            subjects.rows,

        });

    }

    catch (error) {

        console.log(error);

        res.status(500).json({

            success: false,

            message:
            error.message,

        });

    }

});




// =====================================
// GET SECTION TEACHERS
// =====================================

router.get("/section-teachers", async (req, res) => {

    try {

        const teachers = await pool.query(`

            SELECT
                teachers.id,
                users.full_name AS name

            FROM teachers

            JOIN users
            ON teachers.user_id = users.id

            ORDER BY users.full_name ASC

        `);

        res.json({

            success: true,

            teachers:
            teachers.rows,

        });

    }

    catch (error) {

        console.log(error);

        res.status(500).json({

            success: false,

            message:
            error.message,

        });

    }

});


// =====================================
// CREATE SECTION
// =====================================

router.post("/create-section", async (req, res) => {

    try {

        const {
            grade_id,
            section_name,
            teacher_id,
            subject_id
        } = req.body;

        await pool.query(

            `
            INSERT INTO sections
            (
                id,
                name,
                grade_level_id,
                class_teacher_id,
                subject_id
            )
            VALUES
            (
                uuid_generate_v4(),
                $1,
                $2,
                $3,
                $4
            )
            `,
            [
                section_name,
                grade_id,
                teacher_id,
                subject_id
            ]

        );

        res.json({

            success: true,

            message:
            "Section created successfully",

        });

    }

    catch (error) {

        console.log(error);

        res.status(500).json({

            success: false,

            message:
            error.message,

        });

    }

}); 








router.get("/grades", async (req, res) => {

    try {

        const grades = await pool.query(`

            SELECT
                id,
                name
            FROM grades_levels

            ORDER BY name ASC

        `);

        res.json({

            success: true,

            grades:
            grades.rows,

        });

    }

    catch (error) {

        res.status(500).json({

            success: false,

            message:
            error.message,

        });

    }

});




router.post("/create-student", async (req, res) => {

    try {

        const {
            full_name,
            national_id,
            section_id
        } = req.body;

        // =================================
        // CREATE USER
        // =================================

        const userResult =
        await pool.query(

            `
            INSERT INTO users
            (
                id,
                full_name,
                national_id,
                role
            )
            VALUES
            (
                uuid_generate_v4(),
                $1,
                $2,
                'student'
            )
            RETURNING id
            `,
            [
                full_name,
                national_id
            ]

        );

        const userId =
        userResult.rows[0].id;

        // =================================
        // CREATE STUDENT
        // =================================

        await pool.query(

            `
            INSERT INTO students
            (
                id,
                user_id,
                section_id
            )
            VALUES
            (
                uuid_generate_v4(),
                $1,
                $2
            )
            `,
            [
                userId,
                section_id
            ]

        );

        res.json({

            success: true,

            message:
            "Student created successfully",

        });

    }

    catch (error) {

        res.status(500).json({

            success: false,

            message:
            error.message,

        });

    }

});




router.put("/update-student/:id", async (req, res) => {

    try {

        const { id } =
        req.params;

        const {
            full_name,
            national_id,
            section_id
        } = req.body;

        // =================================
        // GET USER ID
        // =================================

        const student =
        await pool.query(

            `
            SELECT user_id
            FROM students
            WHERE id = $1
            `,
            [id]

        );

        if (
        student.rows.length == 0
        ) {

            return res.status(404).json({

                success: false,

                message:
                "Student not found",

            });

        }

        const userId =
        student.rows[0].user_id;

        // =================================
        // UPDATE USER
        // =================================

        await pool.query(

            `
            UPDATE users
            SET
                full_name = $1,
                national_id = $2
            WHERE id = $3
            `,
            [
                full_name,
                national_id,
                userId
            ]

        );

        // =================================
        // UPDATE STUDENT
        // =================================

        await pool.query(

            `
            UPDATE students
            SET section_id = $1
            WHERE id = $2
            `,
            [
                section_id,
                id
            ]

        );

        res.json({

            success: true,

            message:
            "Student updated successfully",

        });

    }

    catch (error) {

        res.status(500).json({

            success: false,

            message:
            error.message,

        });

    }

});









router.delete("/delete-student/:id", async (req, res) => {

    try {

        const { id } =
        req.params;

        // =================================
        // GET USER ID
        // =================================

        const student =
        await pool.query(

            `
            SELECT user_id
            FROM students
            WHERE id = $1
            `,
            [id]

        );

        if (
        student.rows.length == 0
        ) {

            return res.status(404).json({

                success: false,

                message:
                "Student not found",

            });

        }

        const userId =
        student.rows[0].user_id;

        // =================================
        // DELETE STUDENT
        // =================================

        await pool.query(

            `
            DELETE FROM students
            WHERE id = $1
            `,
            [id]

        );

        // =================================
        // DELETE USER
        // =================================

        await pool.query(

            `
            DELETE FROM users
            WHERE id = $1
            `,
            [userId]

        );

        res.json({

            success: true,

            message:
            "Student deleted successfully",

        });

    }

    catch (error) {

        res.status(500).json({

            success: false,

            message:
            error.message,

        });

    }

});






// =====================================
// CREATE TEACHER
// =====================================

router.post("/create-teacher", async (req, res) => {

    try {

        const {

            full_name,
            national_id,
            section_id,
            subject_id

        } = req.body;

        // ===============================
        // CREATE USER
        // ===============================

        const userResult =
        await pool.query(

            `
            INSERT INTO users
            (
                id,
                full_name,
                national_id,
                password,
                role,
                is_active
            )
            VALUES
            (
                uuid_generate_v4(),
                $1,
                $2,
                $3,
                'teacher',
                true
            )
            RETURNING id
            `,
            [

                full_name,
                national_id,
                "123456"

            ]

        );

        const userId =
        userResult.rows[0].id;

        // ===============================
        // CREATE TEACHER
        // ===============================

        const teacherResult =
        await pool.query(

            `
            INSERT INTO teachers
            (
                id,
                user_id,
                specialization,
                hire_date
            )
            VALUES
            (
                uuid_generate_v4(),
                $1,
                $2,
                NOW()
            )
            RETURNING id
            `,
            [

                userId,
                "Teacher"

            ]

        );

        const teacherId =
        teacherResult.rows[0].id;

        // ===============================
        // ASSIGN SUBJECT + SECTION
        // ===============================

        await pool.query(

            `
            INSERT INTO teacher_subjects
            (
                id,
                teacher_id,
                subject_id,
                section_id
            )
            VALUES
            (
                uuid_generate_v4(),
                $1,
                $2,
                $3
            )
            `,
            [

                teacherId,
                subject_id,
                section_id

            ]

        );

        res.json({

            success: true,

            message:
            "Teacher created successfully",

        });

    }

    catch (error) {

        console.log(error);

        res.status(500).json({

            success: false,

            message:
            error.message,

        });

    }

});




// =====================================
// UPDATE TEACHER
// =====================================// =====================================
// UPDATE TEACHER
// =====================================

router.put("/update-teacher/:id", async (req, res) => {

    try {

        const { id } =
        req.params;

        const {

            full_name,
            national_id,
            section_id,
            subject_id

        } = req.body;

        // ===============================
        // GET USER ID
        // ===============================

        const teacher =
        await pool.query(

            `
            SELECT user_id
            FROM teachers
            WHERE id = $1
            `,
            [id]

        );

        if (
            teacher.rows.length == 0
        ) {

            return res.status(404).json({

                success: false,

                message:
                "Teacher not found",

            });

        }

        const userId =
        teacher.rows[0].user_id;

        // ===============================
        // UPDATE USER
        // ===============================

        await pool.query(

            `
            UPDATE users
            SET

                full_name = $1,
                national_id = $2

            WHERE id = $3
            `,
            [

                full_name,
                national_id,
                userId

            ]

        );

        // ===============================
        // DELETE OLD ASSIGNMENTS
        // ===============================

        await pool.query(

            `
            DELETE FROM teacher_subjects
            WHERE teacher_id = $1
            `,
            [id]

        );

        // ===============================
        // INSERT NEW ASSIGNMENT
        // ===============================

        await pool.query(

            `
            INSERT INTO teacher_subjects
            (
                id,
                teacher_id,
                subject_id,
                section_id
            )
            VALUES
            (
                uuid_generate_v4(),
                $1,
                $2,
                $3
            )
            `,
            [

                id,
                subject_id,
                section_id

            ]

        );

        res.json({

            success: true,

            message:
            "Teacher updated successfully",

        });

    }

    catch (error) {

        console.log(error);

        res.status(500).json({

            success: false,

            message:
            error.message,

        });

    }

});


// =====================================
// DELETE TEACHER
// =====================================

router.delete("/delete-teacher/:id", async (req, res) => {

    try {

        const { id } =
        req.params;

        // ===============================
        // GET USER ID
        // ===============================

        const teacher =
        await pool.query(

            `
            SELECT user_id
            FROM teachers
            WHERE id = $1
            `,
            [id]

        );

        if (
            teacher.rows.length == 0
        ) {

            return res.status(404).json({

                success: false,

                message:
                "Teacher not found",

            });

        }

        const userId =
        teacher.rows[0].user_id;

        // ===============================
        // DELETE ASSIGNMENTS
        // ===============================

        await pool.query(

            `
            DELETE FROM teacher_subjects
            WHERE teacher_id = $1
            `,
            [id]

        );

        // ===============================
        // DELETE TEACHER
        // ===============================

        await pool.query(

            `
            DELETE FROM teachers
            WHERE id = $1
            `,
            [id]

        );

        // ===============================
        // DELETE USER
        // ===============================

        await pool.query(

            `
            DELETE FROM users
            WHERE id = $1
            `,
            [userId]

        );

        res.json({

            success: true,

            message:
            "Teacher deleted successfully",

        });

    }

    catch (error) {

        console.log(error);

        res.status(500).json({

            success: false,

            message:
            error.message,

        });

    }

});



    // =====================================
    // ADD WARNING
    // =====================================

    router.post("/add-warning", async (req, res) => {

        try {

            const {
                student_id,
                admin_id,
                warning_type,
                reason,
                action_taken
            } = req.body;

            await pool.query(
                `
                INSERT INTO warnings
                (
                    id,
                    student_id,
                    admin_id,
                    warning_type,
                    reason,
                    action_taken
                )
                VALUES
                (
                    uuid_generate_v4(),
                    $1,
                    $2,
                    $3,
                    $4,
                    $5
                )
                `,
                [
                    student_id,
                    admin_id,
                    warning_type,
                    reason,
                    action_taken
                ]
            );

            res.json({
                success: true,
                message: "Warning added successfully"
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
    // GET WARNINGS
    // =====================================

    router.get("/warnings", async (req, res) => {

        try {

            const warnings = await pool.query(`
                SELECT
                    warnings.id,
                    warnings.warning_type,
                    warnings.reason,
                    warnings.action_taken,
                    warnings.warning_date,
                    users.full_name AS student_name
                FROM warnings

                JOIN students
                ON warnings.student_id = students.id

                JOIN users
                ON students.user_id = users.id

                ORDER BY warnings.warning_date DESC
            `);

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
// UPDATE SECTION
// =====================================

router.put("/update-section/:id", async (req, res) => {

    try {

        const { id } = req.params;

        const {
            grade_id,
            section_name,
            teacher_id,
            subject_id
        } = req.body;

        await pool.query(

            `
            UPDATE sections
            SET
                name = $1,
                grade_level_id = $2,
                class_teacher_id = $3,
                subject_id = $4
            WHERE id = $5
            `,
            [
                section_name,
                grade_id,
                teacher_id,
                subject_id,
                id
            ]

        );

        res.json({

            success: true,

            message:
            "Section updated successfully",

        });

    }

    catch (error) {

        console.log(error);

        res.status(500).json({

            success: false,

            message:
            error.message,

        });

    }

});




// =====================================
// DELETE SECTION
// =====================================

router.delete("/delete-section/:id", async (req, res) => {

    try {

        const { id } =
        req.params;

        // =====================================
        // CHECK STUDENTS
        // =====================================

        const students =
        await pool.query(

            `
            SELECT id
            FROM students
            WHERE section_id = $1
            `,
            [id]

        );

        // =====================================
        // IF STUDENTS EXIST
        // =====================================

        if (students.rows.length > 0) {

            return res.status(400).json({

                success: false,

                message:
                "Cannot delete section because students are assigned to it",

            });

        }

        // =====================================
        // DELETE SECTION
        // =====================================

        await pool.query(

            `
            DELETE FROM sections
            WHERE id = $1
            `,
            [id]

        );

        res.json({

            success: true,

            message:
            "Section deleted successfully",

        });

    }

    catch (error) {

        console.log(error);

        res.status(500).json({

            success: false,

            message:
            error.message,

        });

    }

});




router.post(
"/add-class-schedule",

async (req, res) => {

    try {

        const {

            section_id,
            schedule

        } = req.body;

        await pool.query(

            `
            DELETE FROM class_schedule
            WHERE section_id = $1
            `,
            [section_id]

        );

        for (const item of schedule) {

           

            await pool.query(

    `
    INSERT INTO class_schedule
    (

        id,
        section_id,
        subject_id,
        teacher_id,
        day_of_week,
        period_number,
        start_time,
        end_time

    )
    VALUES
    (
        uuid_generate_v4(),
        $1,
        $2,
        $3,
        $4,
        $5,
        $6,
        $7
    )
    `,
    [

        section_id,

        item.subject_id,

        item.teacher_id,

        item.day_of_week,

        item.period_number,

        item.start_time,

        item.end_time,

    ]

);

        }

        res.json({

            success: true,

            message:
            "Schedule saved successfully",

        });

    }

    catch (error) {

        console.log(error);

        res.status(500).json({

            success: false,

            error:
            error.message,

        });

    }

});






router.get(
"/admin/class-schedule/:sectionId",

async (req, res) => {

    try {

        const { sectionId } =
        req.params;

        const result =
        await pool.query(

            `
            SELECT *
            FROM class_schedule
            WHERE section_id = $1
            `,
            [sectionId]

        );

        res.json({

            success: true,

            schedule:
            result.rows.map((row) => ({

                day:
                row.day_of_week,

                period:
                row.period_number,

                subject_id:
                row.subject_id,

            })),

        });

    }

    catch (error) {

        console.log(error);

        res.status(500).json({

            success: false,

            error:
            error.message,

        });

    }

});





// =====================================
// GET ALL NOTIFICATIONS
// =====================================

router.get("/notifications", async (req, res) => {

    try {

        const notifications =
        await pool.query(`

            SELECT
                id,
                title,
                description,
                target_type,
                created_at
            FROM notifications

            ORDER BY created_at DESC

        `);

        res.json({

            success: true,

            notifications:
            notifications.rows,

        });

    }

    catch (error) {

        console.log(error);

        res.status(500).json({

            success: false,

            message:
            error.message,

        });

    }

});




// =====================================
// DELETE NOTIFICATION
// =====================================

router.delete("/delete-notification/:id", async (req, res) => {

    try {

        const { id } =
        req.params;

        await pool.query(

            `
            DELETE FROM notifications
            WHERE id = $1
            `,
            [id]

        );

        res.json({

            success: true,

            message:
            "Notification deleted successfully",

        });

    }

    catch (error) {

        console.log(error);

        res.status(500).json({

            success: false,

            message:
            error.message,

        });

    }

});











// =====================================
// SEND TEACHER NOTIFICATION
// =====================================

router.post(
"/teacher-send-notification",

async (req, res) => {

    try {

        const {

            teacher_id,
            section_id,
            title,
            message,
            type

        } = req.body;

        // =====================================
        // INSERT NOTIFICATION
        // =====================================

        const notificationResult =
        await pool.query(

            `
            INSERT INTO notifications
            (

                id,
                admin_id,
                title,
                description,
                target_type

            )
            VALUES
            (

                uuid_generate_v4(),
                $1,
                $2,
                $3,
                $4

            )
            RETURNING id
            `,
            [

                teacher_id,
                title,
                message,
                type

            ]

        );

        const notificationId =
        notificationResult.rows[0].id;

        // =====================================
        // GET STUDENTS
        // =====================================

        const students =
        await pool.query(

            `
            SELECT

                users.id

            FROM students

            JOIN users
            ON students.user_id = users.id

            WHERE students.section_id = $1
            `,
            [section_id]

        );

        // =====================================
        // INSERT RECEIVERS
        // =====================================

        for (const student of students.rows) {

            await pool.query(

                `
                INSERT INTO notifications_receivers
                (

                    id,
                    notification_id,
                    user_id,
                    is_read

                )
                VALUES
                (

                    uuid_generate_v4(),
                    $1,
                    $2,
                    false

                )
                `,
                [

                    notificationId,
                    student.id

                ]

            );

        }

        res.json({

            success: true,

            message:
            "Notification sent successfully"

        });

    }

    catch (error) {

        console.log(error);

        res.status(500).json({

            success: false,

            message:
            error.message

        });

    }

});


// =====================================
// GET TEACHER NOTIFICATIONS
// =====================================

router.get(
"/teacher-notifications/:teacherId",

async (req, res) => {

    try {

        const { teacherId } =
        req.params;

        const notifications =
        await pool.query(

            `
            SELECT

                notifications.id,

                notifications.title,

                notifications.description AS message,

                notifications.target_type AS type,

                notifications.created_at,

                sections.name AS section_name,

                grades_levels.name AS grade_name

            FROM notifications

            LEFT JOIN notifications_receivers
            ON notifications.id =
            notifications_receivers.notification_id

            LEFT JOIN users
            ON notifications_receivers.user_id =
            users.id

            LEFT JOIN students
            ON users.id =
            students.user_id

            LEFT JOIN sections
            ON students.section_id =
            sections.id

            LEFT JOIN grades_levels
            ON sections.grade_level_id =
            grades_levels.id

            WHERE notifications.admin_id = $1

            GROUP BY

                notifications.id,
                sections.name,
                grades_levels.name

            ORDER BY notifications.created_at DESC
            `,
            [teacherId]

        );

        res.json({

            success: true,

            notifications:
            notifications.rows

        });

    }

    catch (error) {

        console.log(error);

        res.status(500).json({

            success: false,

            message:
            error.message

        });

    }

});


// =====================================
// DELETE TEACHER NOTIFICATION
// =====================================

router.delete(
"/teacher-notifications/:id",

async (req, res) => {

    try {

        const { id } =
        req.params;

        // =====================================
        // DELETE RECEIVERS
        // =====================================

        await pool.query(

            `
            DELETE FROM notifications_receivers
            WHERE notification_id = $1
            `,
            [id]

        );

        // =====================================
        // DELETE NOTIFICATION
        // =====================================

        await pool.query(

            `
            DELETE FROM notifications
            WHERE id = $1
            `,
            [id]

        );

        res.json({

            success: true,

            message:
            "Notification deleted successfully"

        });

    }

    catch (error) {

        console.log(error);

        res.status(500).json({

            success: false,

            message:
            error.message

        });

    }

});


// =====================================
// GET TEACHER SECTIONS
// =====================================

router.get(
"/admin-sections/:teacherId",

async (req, res) => {

    try {

        const { teacherId } =
        req.params;

        const sections =
        await pool.query(

            `
            SELECT DISTINCT

                sections.id,

                sections.name AS section_name,

                grades_levels.name AS grade_name

            FROM teacher_subjects

            JOIN sections
            ON teacher_subjects.section_id =
            sections.id

            JOIN grades_levels
            ON sections.grade_level_id =
            grades_levels.id

            WHERE teacher_subjects.teacher_id = $1

            ORDER BY grades_levels.name ASC
            `,
            [teacherId]

        );

        res.json({

            success: true,

            sections:
            sections.rows

        });

    }

    catch (error) {

        console.log(error);

        res.status(500).json({

            success: false,

            message:
            error.message

        });

    }

});

    return router;

};