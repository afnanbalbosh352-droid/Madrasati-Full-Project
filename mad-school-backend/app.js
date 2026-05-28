const express = require("express");
const cors = require("cors");
const jwt = require("jsonwebtoken");
const { Pool } = require("pg");

const app = express();
app.use((req, res, next) => {
    console.log(`=== 🚨 طلب جديد وصل! ===`);
    console.log(`الرابط (Method & URL): ${req.method} ${req.url}`);
    next();
});
app.use(cors());
app.use(express.json());


// =====================================
// DATABASE CONNECTION
// =====================================

const pool = new Pool({
    user: "postgres",
    host: "localhost",
    database: "GP2",
    password: "afnan",
    port: 5432,
});


// =====================================
// SECRET KEY
// =====================================

const SECRET_KEY = "MAD_SECRET_KEY";


// =====================================
// TEST API
// =====================================

app.get("/", (req, res) => {

    res.json({
        success: true,
        message: "MAD School Backend Running"
    });

});


// =====================================
// LOGIN
// =====================================




// =====================================
// LOGIN
// =====================================

app.post("/loginn", async (req, res) => {

    try {

        const { national_id, password } = req.body;

        if (!national_id || !password) {

            return res.status(400).json({
                success: false,
                message: "national_id and password required"
            });

        }

        // =====================================
        // GET USER
        // =====================================

        const user = await pool.query(
            `
            SELECT *
            FROM users
            WHERE national_id = $1
            `,
            [national_id]
        );

        if (user.rows.length === 0) {

            return res.status(404).json({
                success: false,
                message: "User not found"
            });

        }

        const foundUser = user.rows[0];

        // =====================================
        // CHECK PASSWORD
        // =====================================

        if (password !== foundUser.password) {

            return res.status(401).json({
                success: false,
                message: "Wrong password"
            });

        }

        // =====================================
        // TOKEN
        // =====================================

        const token = jwt.sign(

            {
                id: foundUser.id,
                role: foundUser.role
            },

            SECRET_KEY,

            {
                expiresIn: "7d"
            }

        );

        // =====================================
        // EXTRA PROFILE IDS
        // =====================================

        let profile_id = null;

        // STUDENT
        if (foundUser.role === "student") {

            const student = await pool.query(
                `
                SELECT id
                FROM students
                WHERE user_id = $1
                `,
                [foundUser.id]
            );

            if (student.rows.length > 0) {

                profile_id = student.rows[0].id;

            }

        }

        // TEACHER
        else if (foundUser.role === "teacher") {

            const teacher = await pool.query(
                `
                SELECT id
                FROM teachers
                WHERE user_id = $1
                `,
                [foundUser.id]
            );

            if (teacher.rows.length > 0) {

                profile_id = teacher.rows[0].id;

            }

        }

        // ADMIN
        else if (foundUser.role === "admin") {

            const admin = await pool.query(
                `
                SELECT id
                FROM admins
                WHERE user_id = $1
                `,
                [foundUser.id]
            );

            if (admin.rows.length > 0) {

                profile_id = admin.rows[0].id;

            }

        }

        // =====================================
        // RESPONSE
        // =====================================

        res.json({

            success: true,
            message: "Login success",

            token: token,

            user: foundUser,

            profile_id: profile_id

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
// VERIFY SCHOOL
// =====================================

app.post("/verify-school", async (req, res) => {

    try {

        console.log(req.body);

        const { school_code } = req.body;

        if (!school_code) {

            return res.status(400).json({
                success: false,
                message: "School code is required"
            });

        }

        const school = await pool.query(
            `
            SELECT *
            FROM schools
            WHERE school_code = $1
            `,
            [school_code]
        );

        if (school.rows.length === 0) {

            return res.status(404).json({
                success: false,
                message: "School not found"
            });

        }

        res.json({
            success: true,
            school: school.rows[0]
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
// IMPORT ROUTES
// =====================================

const studentRoutes = require("./student");
const adminRoutes = require("./admin");
const featureRoutes = require("./feature");

app.use("/student", studentRoutes(pool));
app.use("/admin", adminRoutes(pool));
app.use("/feature", featureRoutes(pool));


// =====================================
// SERVER
// =====================================

const PORT = 3000;

app.listen(PORT, () => {

    console.log(`Server running on port ${PORT}`);

});