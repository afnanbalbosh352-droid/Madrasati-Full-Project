--
-- PostgreSQL database dump
--

\restrict K9xDhARTBTgEDKuOCWTTzJrkaN7jfE6XGcU6k3XdzOzOsHtHqgBhSjl0ecbnlUZ

-- Dumped from database version 17.9
-- Dumped by pg_dump version 17.9

-- Started on 2026-05-25 02:19:46

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 2 (class 3079 OID 16389)
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- TOC entry 5154 (class 0 OID 0)
-- Dependencies: 2
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 218 (class 1259 OID 16400)
-- Name: activities; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.activities (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    teacher_id uuid,
    section_id uuid,
    title character varying(255) NOT NULL,
    description text,
    status character varying(20) DEFAULT 'pending'::character varying,
    approved_by uuid,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT activities_status_check CHECK (((status)::text = ANY (ARRAY[('pending'::character varying)::text, ('approved'::character varying)::text, ('rejected'::character varying)::text])))
);


ALTER TABLE public.activities OWNER TO postgres;

--
-- TOC entry 219 (class 1259 OID 16409)
-- Name: admins; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.admins (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    user_id uuid
);


ALTER TABLE public.admins OWNER TO postgres;

--
-- TOC entry 220 (class 1259 OID 16413)
-- Name: assessments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.assessments (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    student_id uuid,
    teacher_id uuid,
    subject_id uuid,
    evaluation_title character varying(255),
    rating character varying(50),
    note text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT assessments_rating_check CHECK (((rating)::text = ANY (ARRAY[('Excellent'::character varying)::text, ('Very Good'::character varying)::text, ('Good'::character varying)::text, ('Poor'::character varying)::text])))
);


ALTER TABLE public.assessments OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 16421)
-- Name: assignments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.assignments (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    teacher_id uuid,
    section_id uuid,
    subject_id uuid,
    title character varying(255) NOT NULL,
    description text,
    due_date date NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.assignments OWNER TO postgres;

--
-- TOC entry 222 (class 1259 OID 16428)
-- Name: attendance; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.attendance (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    student_id uuid,
    teacher_id uuid,
    attendance_date date NOT NULL,
    status character varying(20),
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT attendance_status_check CHECK (((status)::text = ANY (ARRAY[('present'::character varying)::text, ('absent'::character varying)::text])))
);


ALTER TABLE public.attendance OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 16434)
-- Name: chats; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.chats (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    student_id uuid,
    teacher_id uuid,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.chats OWNER TO postgres;

--
-- TOC entry 224 (class 1259 OID 16439)
-- Name: class_schedule; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.class_schedule (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    section_id uuid NOT NULL,
    subject_id uuid NOT NULL,
    teacher_id uuid,
    day_of_week character varying(20) NOT NULL,
    period_number character varying(10) NOT NULL,
    start_time time without time zone NOT NULL,
    end_time time without time zone NOT NULL
);


ALTER TABLE public.class_schedule OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 16443)
-- Name: exam_schedules; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.exam_schedules (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    section_id uuid,
    subject_id uuid,
    exam_title character varying(255),
    exam_date date NOT NULL,
    exam_time time without time zone NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.exam_schedules OWNER TO postgres;

--
-- TOC entry 226 (class 1259 OID 16448)
-- Name: grades; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.grades (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    student_id uuid,
    subject_id uuid,
    teacher_id uuid,
    exam_type character varying(100),
    grade_value numeric(5,2),
    is_approved boolean DEFAULT false,
    approved_by uuid,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.grades OWNER TO postgres;

--
-- TOC entry 227 (class 1259 OID 16454)
-- Name: grades_levels; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.grades_levels (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    school_id uuid,
    name character varying(100) NOT NULL
);


ALTER TABLE public.grades_levels OWNER TO postgres;

--
-- TOC entry 228 (class 1259 OID 16458)
-- Name: messages; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.messages (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    chat_id uuid,
    sender_user_id uuid,
    message text NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.messages OWNER TO postgres;

--
-- TOC entry 229 (class 1259 OID 16465)
-- Name: notifications; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.notifications (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    admin_id uuid,
    title character varying(255) NOT NULL,
    description text,
    target_type character varying(50),
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    teacher_id uuid,
    section_id uuid,
    type character varying(100),
    CONSTRAINT notifications_target_type_check CHECK (((target_type)::text = ANY (ARRAY[('all_students'::character varying)::text, ('all_teachers'::character varying)::text, ('grade'::character varying)::text, ('section'::character varying)::text, ('specific_student'::character varying)::text, ('specific_teacher'::character varying)::text])))
);


ALTER TABLE public.notifications OWNER TO postgres;

--
-- TOC entry 230 (class 1259 OID 16473)
-- Name: notifications_receivers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.notifications_receivers (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    notification_id uuid,
    user_id uuid,
    is_read boolean DEFAULT false
);


ALTER TABLE public.notifications_receivers OWNER TO postgres;

--
-- TOC entry 231 (class 1259 OID 16478)
-- Name: schools; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.schools (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    school_code character varying(20) NOT NULL,
    school_name character varying(255) NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.schools OWNER TO postgres;

--
-- TOC entry 232 (class 1259 OID 16483)
-- Name: sections; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sections (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    grade_level_id uuid,
    name character varying(50) NOT NULL,
    homeroom_teacher_id uuid,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    subject_id uuid,
    class_teacher_id uuid
);


ALTER TABLE public.sections OWNER TO postgres;

--
-- TOC entry 233 (class 1259 OID 16488)
-- Name: students; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.students (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    user_id uuid,
    student_number character varying(50),
    section_id uuid,
    parent_name character varying(255),
    parent_phone character varying(50),
    address text,
    enrollment_date date DEFAULT CURRENT_DATE
);


ALTER TABLE public.students OWNER TO postgres;

--
-- TOC entry 234 (class 1259 OID 16495)
-- Name: subjects; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.subjects (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    school_id uuid,
    name character varying(255) NOT NULL
);


ALTER TABLE public.subjects OWNER TO postgres;

--
-- TOC entry 235 (class 1259 OID 16499)
-- Name: teacher_subjects; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.teacher_subjects (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    teacher_id uuid,
    subject_id uuid,
    section_id uuid
);


ALTER TABLE public.teacher_subjects OWNER TO postgres;

--
-- TOC entry 236 (class 1259 OID 16503)
-- Name: teachers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.teachers (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    user_id uuid,
    specialization character varying(255),
    hire_date date DEFAULT CURRENT_DATE
);


ALTER TABLE public.teachers OWNER TO postgres;

--
-- TOC entry 237 (class 1259 OID 16508)
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    school_id uuid,
    role character varying(20) NOT NULL,
    full_name character varying(255) NOT NULL,
    national_id character varying(50) NOT NULL,
    password character varying(255),
    phone character varying(30),
    email character varying(255),
    is_active boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT users_role_check CHECK (((role)::text = ANY (ARRAY[('student'::character varying)::text, ('teacher'::character varying)::text, ('admin'::character varying)::text])))
);


ALTER TABLE public.users OWNER TO postgres;

--
-- TOC entry 238 (class 1259 OID 16517)
-- Name: warnings; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.warnings (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    student_id uuid,
    admin_id uuid,
    warning_type character varying(100),
    reason text,
    action_taken text,
    warning_date date DEFAULT CURRENT_DATE,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.warnings OWNER TO postgres;

--
-- TOC entry 5128 (class 0 OID 16400)
-- Dependencies: 218
-- Data for Name: activities; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.activities (id, teacher_id, section_id, title, description, status, approved_by, created_at) FROM stdin;
535dccdd-0b7e-4855-81b1-54f4838bb7eb	70000000-0000-0000-0000-000000000001	30000000-0000-0000-0000-000000000001	Math Competition	Participated in the mathematics competition.	approved	60000000-0000-0000-0000-000000000001	2026-05-06 22:41:45.731379
3febf8f4-42b1-40b8-8d79-86a0a2a40093	70000000-0000-0000-0000-000000000001	30000000-0000-0000-0000-000000000001	Science Exhibition	Presented a science project in school.	approved	60000000-0000-0000-0000-000000000001	2026-05-06 22:41:45.731379
42fade51-3949-4e63-9678-8581649b2510	70000000-0000-0000-0000-000000000001	30000000-0000-0000-0000-000000000001	School Trip	Educational trip to Jerash.	approved	60000000-0000-0000-0000-000000000001	2026-05-06 22:41:45.731379
bab52a86-8a70-40f7-8adb-c4f30cee6695	70000000-0000-0000-0000-000000000001	30000000-0000-0000-0000-000000000001	Test2	Test2	rejected	\N	2026-05-08 18:22:24.337266
c6d4215c-83d8-40b2-9202-30554283fca6	70000000-0000-0000-0000-000000000001	30000000-0000-0000-0000-000000000001	test1	133	approved	\N	2026-05-08 09:16:30.854493
5e43694c-6ef8-4f6c-8c69-e4eee83af6f3	70000000-0000-0000-0000-000000000001	30000000-0000-0000-0000-000000000001	3	3	approved	\N	2026-05-08 09:15:43.431423
a57bfd56-917a-4013-b8cd-ed158775338d	70000000-0000-0000-0000-000000000001	30000000-0000-0000-0000-000000000001	نشاط كيمياء	.....	approved	\N	2026-05-23 19:58:17.655814
21e0db10-c833-499f-82ec-cc05dc1ddffa	70000000-0000-0000-0000-000000000001	30000000-0000-0000-0000-000000000001	مباراة	حصة الرياضة	pending	\N	2026-05-24 14:58:48.357062
\.


--
-- TOC entry 5129 (class 0 OID 16409)
-- Dependencies: 219
-- Data for Name: admins; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.admins (id, user_id) FROM stdin;
60000000-0000-0000-0000-000000000001	50000000-0000-0000-0000-000000000001
\.


--
-- TOC entry 5130 (class 0 OID 16413)
-- Dependencies: 220
-- Data for Name: assessments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.assessments (id, student_id, teacher_id, subject_id, evaluation_title, rating, note, created_at) FROM stdin;
\.


--
-- TOC entry 5131 (class 0 OID 16421)
-- Dependencies: 221
-- Data for Name: assignments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.assignments (id, teacher_id, section_id, subject_id, title, description, due_date, created_at) FROM stdin;
baf93f1e-4dfe-47f2-ab8b-20e628a9ce46	70000000-0000-0000-0000-000000000001	30000000-0000-0000-0000-000000000001	40000000-0000-0000-0000-000000000001	Math Homework	Solve exercises on page 25	2026-05-10	2026-05-06 22:46:46.427141
399eeb96-8fef-4ce7-bab1-d75c8a9d05f3	70000000-0000-0000-0000-000000000001	30000000-0000-0000-0000-000000000001	40000000-0000-0000-0000-000000000001	Science Project	Prepare a project about renewable energy	2026-05-15	2026-05-06 22:46:46.427141
1b9bfa68-16cb-4856-ae03-f0d4a4b21122	70000000-0000-0000-0000-000000000001	30000000-0000-0000-0000-000000000001	40000000-0000-0000-0000-000000000001	English Essay	Write an essay about technology in education	2026-05-20	2026-05-06 22:46:46.427141
3013f1fc-0445-4c67-8157-04398c7e24d2	70000000-0000-0000-0000-000000000001	30000000-0000-0000-0000-000000000001	40000000-0000-0000-0000-000000000001	ddd	ddd	2026-05-26	2026-05-24 19:49:49.776254
\.


--
-- TOC entry 5132 (class 0 OID 16428)
-- Dependencies: 222
-- Data for Name: attendance; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.attendance (id, student_id, teacher_id, attendance_date, status, created_at) FROM stdin;
8067026d-978f-4d73-8135-3eb5f7ea0f51	f5398b96-c200-47bb-83b9-9952e31e3692	70000000-0000-0000-0000-000000000001	2026-05-08	absent	2026-05-08 09:16:45.543351
a9111dc9-ca4f-4ebd-b9e9-0b8505aeefd0	22b0d31e-580e-4f7a-9b5f-4cc14818d50c	70000000-0000-0000-0000-000000000001	2026-05-08	present	2026-05-08 09:16:45.615854
f1a87b52-a7e9-4253-b2e6-d5f252c3dabd	f5398b96-c200-47bb-83b9-9952e31e3692	\N	2026-05-17	absent	2026-05-10 19:30:16.828512
e713d626-055e-456d-8d68-09e48ac4bab1	22b0d31e-580e-4f7a-9b5f-4cc14818d50c	\N	2026-05-17	present	2026-05-10 19:30:16.855827
169ac9ad-b7cf-4266-b866-0ace3217c493	f5398b96-c200-47bb-83b9-9952e31e3692	\N	2026-05-12	present	2026-05-11 23:04:29.5616
a9c07964-afa2-498e-a39d-08b5961eb890	22b0d31e-580e-4f7a-9b5f-4cc14818d50c	\N	2026-05-12	present	2026-05-11 23:04:29.565457
ab5270a5-c5b3-43e6-a887-c611935a0015	f5398b96-c200-47bb-83b9-9952e31e3692	\N	2026-05-11	present	2026-05-11 23:04:14.798973
fe935517-96b9-420c-9112-f9bd246c5f70	22b0d31e-580e-4f7a-9b5f-4cc14818d50c	\N	2026-05-11	present	2026-05-11 23:04:14.832326
635d84d1-c3a2-4654-b8ea-0a550bf2ac6d	f5398b96-c200-47bb-83b9-9952e31e3692	\N	2026-05-25	absent	2026-05-24 11:27:18.919932
2094ffb1-1de4-4395-b25f-e51750146420	22b0d31e-580e-4f7a-9b5f-4cc14818d50c	\N	2026-05-25	absent	2026-05-24 11:27:18.933541
f544d676-1cd3-4882-aae1-75594232c062	f5398b96-c200-47bb-83b9-9952e31e3692	\N	2026-05-24	absent	2026-05-24 11:25:35.574692
014fd74d-b3eb-4cb4-b767-004c425f5c83	22b0d31e-580e-4f7a-9b5f-4cc14818d50c	\N	2026-05-24	absent	2026-05-24 11:25:35.597814
c1c25730-5948-4d20-90be-7cf30ace8380	f5398b96-c200-47bb-83b9-9952e31e3692	\N	2026-05-27	present	2026-05-24 11:30:15.04376
7fe43975-c54f-4042-8186-1f18bff155c5	22b0d31e-580e-4f7a-9b5f-4cc14818d50c	\N	2026-05-27	absent	2026-05-24 11:30:15.059428
\.


--
-- TOC entry 5133 (class 0 OID 16434)
-- Dependencies: 223
-- Data for Name: chats; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.chats (id, student_id, teacher_id, created_at) FROM stdin;
bcd28795-9303-4325-8851-fa4bd23c5767	f5398b96-c200-47bb-83b9-9952e31e3692	70000000-0000-0000-0000-000000000001	2026-05-06 23:02:46.440939
0dd1ff7c-abe3-44b5-a07e-149796d11a5b	a3599b4a-9d7d-4af4-ad35-8f0eab3e245d	c4a9da72-10ff-40b6-bb17-b44d1f5ac18b	2026-05-15 15:00:25.084374
64032b1c-8d49-4a07-8c43-55d2824f19f7	a3599b4a-9d7d-4af4-ad35-8f0eab3e245d	70000000-0000-0000-0000-000000000001	2026-05-15 15:00:28.833857
4985595f-dc72-46b3-a716-368f4f7e8b61	22b0d31e-580e-4f7a-9b5f-4cc14818d50c	c4a9da72-10ff-40b6-bb17-b44d1f5ac18b	2026-05-23 20:35:28.41691
fbe754d4-5d3d-4bce-8ad7-d72519e776b2	22b0d31e-580e-4f7a-9b5f-4cc14818d50c	70000000-0000-0000-0000-000000000001	2026-05-24 11:38:47.179101
\.


--
-- TOC entry 5134 (class 0 OID 16439)
-- Dependencies: 224
-- Data for Name: class_schedule; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.class_schedule (id, section_id, subject_id, teacher_id, day_of_week, period_number, start_time, end_time) FROM stdin;
ce5dfa9c-9978-464e-8f77-1e17eb8fc163	30000000-0000-0000-0000-000000000001	40000000-0000-0000-0000-000000000001	\N	Sun	C1	08:00:00	09:00:00
b0135284-8b70-465d-9897-35170b40169a	30000000-0000-0000-0000-000000000001	40000000-0000-0000-0000-000000000001	\N	Mon	C1	08:00:00	09:00:00
\.


--
-- TOC entry 5135 (class 0 OID 16443)
-- Dependencies: 225
-- Data for Name: exam_schedules; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.exam_schedules (id, section_id, subject_id, exam_title, exam_date, exam_time, created_at) FROM stdin;
\.


--
-- TOC entry 5136 (class 0 OID 16448)
-- Dependencies: 226
-- Data for Name: grades; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.grades (id, student_id, subject_id, teacher_id, exam_type, grade_value, is_approved, approved_by, created_at) FROM stdin;
c900b7f4-14c3-4d5b-a99c-5100d910a2e9	22b0d31e-580e-4f7a-9b5f-4cc14818d50c	40000000-0000-0000-0000-000000000001	70000000-0000-0000-0000-000000000001	Mid Exam	95.00	t	\N	2026-05-06 23:10:04.282454
7d58668e-8fa4-4259-ac32-08849f438c03	22b0d31e-580e-4f7a-9b5f-4cc14818d50c	40000000-0000-0000-0000-000000000001	70000000-0000-0000-0000-000000000001	Final Exam	88.00	t	\N	2026-05-06 23:10:04.282454
1ec0daac-e156-48a2-aed8-6855fa91ebf8	22b0d31e-580e-4f7a-9b5f-4cc14818d50c	40000000-0000-0000-0000-000000000001	70000000-0000-0000-0000-000000000001	Quiz	91.00	t	\N	2026-05-06 23:10:04.282454
4cd82fab-d9e5-44f4-bea6-9e67cc2f7062	22b0d31e-580e-4f7a-9b5f-4cc14818d50c	40000000-0000-0000-0000-000000000001	70000000-0000-0000-0000-000000000001	Second Exam	30.00	f	\N	2026-05-24 19:46:37.007512
\.


--
-- TOC entry 5137 (class 0 OID 16454)
-- Dependencies: 227
-- Data for Name: grades_levels; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.grades_levels (id, school_id, name) FROM stdin;
20000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111111	Grade 1
20000000-0000-0000-0000-000000000002	11111111-1111-1111-1111-111111111111	Grade 2
20000000-0000-0000-0000-000000000003	11111111-1111-1111-1111-111111111111	Grade 3
\.


--
-- TOC entry 5138 (class 0 OID 16458)
-- Dependencies: 228
-- Data for Name: messages; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.messages (id, chat_id, sender_user_id, message, created_at) FROM stdin;
609e4d93-6f1a-463c-82ba-3aed94a266bc	bcd28795-9303-4325-8851-fa4bd23c5767	50000000-0000-0000-0000-000000000003	مرحبا	2026-05-06 23:06:02.354125
99982408-9e93-4ba2-932c-6e57a0dbf7c2	bcd28795-9303-4325-8851-fa4bd23c5767	50000000-0000-0000-0000-000000000002	السلام عليكم احمد	2026-05-08 08:39:48.239483
2c73a753-e583-4287-8037-887fad76a3f0	bcd28795-9303-4325-8851-fa4bd23c5767	50000000-0000-0000-0000-000000000002	السلام عليكم	2026-05-08 08:41:45.422267
3f49361e-d5b4-44dc-8603-3ae7504cf0d6	bcd28795-9303-4325-8851-fa4bd23c5767	50000000-0000-0000-0000-000000000002	غدا امتحان الشهر الثاني	2026-05-08 08:48:52.339797
609e4d93-6f1a-463c-82ba-3aed94a266bf	bcd28795-9303-4325-8851-fa4bd23c5767	50000000-0000-0000-0000-000000000003	وعليكم السلام	2026-05-08 09:39:48.239483
e3641537-22e7-421e-88cb-da1997d5a580	bcd28795-9303-4325-8851-fa4bd23c5767	50000000-0000-0000-0000-000000000002	test	2026-05-08 18:26:44.582919
066d3236-690b-478d-9975-4afee8a7db4a	0dd1ff7c-abe3-44b5-a07e-149796d11a5b	50000000-0000-0000-0000-000000000006	hi	2026-05-15 15:00:47.459011
f0271cb6-bbbf-4727-a953-19eff6f982d9	0dd1ff7c-abe3-44b5-a07e-149796d11a5b	50000000-0000-0000-0000-000000000006	hi	2026-05-23 19:01:50.188383
3f7bc178-8d2b-496a-9ac0-d42f1d837759	64032b1c-8d49-4a07-8c43-55d2824f19f7	50000000-0000-0000-0000-000000000006	hello	2026-05-23 19:02:02.657371
67525234-2c41-4286-8dac-46fa56c0a7d1	fbe754d4-5d3d-4bce-8ad7-d72519e776b2	50000000-0000-0000-0000-000000000004	السلام عليكم استاذ	2026-05-24 11:39:01.257873
\.


--
-- TOC entry 5139 (class 0 OID 16465)
-- Dependencies: 229
-- Data for Name: notifications; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.notifications (id, admin_id, title, description, target_type, created_at, teacher_id, section_id, type) FROM stdin;
309d4e27-185f-474e-acd4-ba5053ecdae4	60000000-0000-0000-0000-000000000001	aaaaa	hhhhh	all_teachers	2026-05-24 19:55:22.553503	\N	\N	\N
08db65cc-21bf-4db6-8420-6a5cf9fb8122	60000000-0000-0000-0000-000000000001	AAAA	HHHH	all_teachers	2026-05-24 19:55:56.314909	\N	\N	\N
dd66bb3f-83c4-4c7f-8ee5-c86fcd1126fe	60000000-0000-0000-0000-000000000001	اشعار مدرسين	...	all_teachers	2026-05-24 20:04:07.260388	\N	\N	\N
\.


--
-- TOC entry 5140 (class 0 OID 16473)
-- Dependencies: 230
-- Data for Name: notifications_receivers; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.notifications_receivers (id, notification_id, user_id, is_read) FROM stdin;
\.


--
-- TOC entry 5141 (class 0 OID 16478)
-- Dependencies: 231
-- Data for Name: schools; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.schools (id, school_code, school_name, created_at) FROM stdin;
11111111-1111-1111-1111-111111111111	MAD001	MAD School	2026-05-06 20:53:28.657888
\.


--
-- TOC entry 5142 (class 0 OID 16483)
-- Dependencies: 232
-- Data for Name: sections; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sections (id, grade_level_id, name, homeroom_teacher_id, created_at, subject_id, class_teacher_id) FROM stdin;
30000000-0000-0000-0000-000000000002	20000000-0000-0000-0000-000000000002	Section A	70000000-0000-0000-0000-000000000001	2026-05-06 22:23:28.658533	\N	\N
30000000-0000-0000-0000-000000000003	20000000-0000-0000-0000-000000000003	Section A	70000000-0000-0000-0000-000000000001	2026-05-06 22:23:28.658533	\N	\N
30000000-0000-0000-0000-000000000001	20000000-0000-0000-0000-000000000001	Section A	70000000-0000-0000-0000-000000000001	2026-05-06 22:23:28.658533	\N	70000000-0000-0000-0000-000000000001
4b12f83d-3612-42f3-a6f9-bcf44e1185cb	20000000-0000-0000-0000-000000000001	C	\N	2026-05-24 11:57:14.504874	40000000-0000-0000-0000-000000000001	dc00af87-6d89-4781-b1e9-516aac6f8387
\.


--
-- TOC entry 5143 (class 0 OID 16488)
-- Dependencies: 233
-- Data for Name: students; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.students (id, user_id, student_number, section_id, parent_name, parent_phone, address, enrollment_date) FROM stdin;
22b0d31e-580e-4f7a-9b5f-4cc14818d50c	50000000-0000-0000-0000-000000000004	STD002	30000000-0000-0000-0000-000000000001	Khaled Mohammad	0795552222	Zarqa	2025-09-01
c243e849-c8d7-4be2-a2b4-199db69fc717	50000000-0000-0000-0000-000000000005	STD003	30000000-0000-0000-0000-000000000002	Yusuf Sami	0795553333	Irbid	2025-09-01
a3599b4a-9d7d-4af4-ad35-8f0eab3e245d	50000000-0000-0000-0000-000000000006	STD004	30000000-0000-0000-0000-000000000002	Omar Khaled	0795554444	Salt	2025-09-01
f5398b96-c200-47bb-83b9-9952e31e3692	50000000-0000-0000-0000-000000000003	STD001	30000000-0000-0000-0000-000000000001	Ahmad Ali	0795551111	Amman	2025-09-01
a6906c3e-58ba-4049-ace2-9849fa8a8d25	0b2992e6-63e4-43d6-a3dc-c47f028fd746	\N	30000000-0000-0000-0000-000000000001	\N	\N	\N	2026-05-24
\.


--
-- TOC entry 5144 (class 0 OID 16495)
-- Dependencies: 234
-- Data for Name: subjects; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.subjects (id, school_id, name) FROM stdin;
40000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111111	Mathematics
\.


--
-- TOC entry 5145 (class 0 OID 16499)
-- Dependencies: 235
-- Data for Name: teacher_subjects; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.teacher_subjects (id, teacher_id, subject_id, section_id) FROM stdin;
fa486915-f658-47ad-8159-1feff0aa0b64	70000000-0000-0000-0000-000000000001	40000000-0000-0000-0000-000000000001	30000000-0000-0000-0000-000000000001
275fdb5c-5a0f-464a-a2d9-9565d57197f1	c4a9da72-10ff-40b6-bb17-b44d1f5ac18b	40000000-0000-0000-0000-000000000001	30000000-0000-0000-0000-000000000001
26c39577-55ba-49fb-b8cb-fe529d12cdc9	dc00af87-6d89-4781-b1e9-516aac6f8387	40000000-0000-0000-0000-000000000001	30000000-0000-0000-0000-000000000001
\.


--
-- TOC entry 5146 (class 0 OID 16503)
-- Dependencies: 236
-- Data for Name: teachers; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.teachers (id, user_id, specialization, hire_date) FROM stdin;
70000000-0000-0000-0000-000000000001	50000000-0000-0000-0000-000000000002	Mathematics	2026-05-06
c4a9da72-10ff-40b6-bb17-b44d1f5ac18b	cd8059bf-3770-45ca-9e37-d64521b3202e	Teacher	2026-05-11
dc00af87-6d89-4781-b1e9-516aac6f8387	ce2fd9cf-4b26-4614-8b88-77380b146016	Teacher	2026-05-24
\.


--
-- TOC entry 5147 (class 0 OID 16508)
-- Dependencies: 237
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, school_id, role, full_name, national_id, password, phone, email, is_active, created_at) FROM stdin;
50000000-0000-0000-0000-000000000004	11111111-1111-1111-1111-111111111111	student	Mohammad Khaled	700000002	123456	0792222222	mohammad@mad.com	t	2026-05-06 22:23:35.800179
50000000-0000-0000-0000-000000000005	11111111-1111-1111-1111-111111111111	student	Sami Yusuf	700000003	123456	0792222223	sami@mad.com	t	2026-05-06 22:23:35.800179
50000000-0000-0000-0000-000000000006	11111111-1111-1111-1111-111111111111	student	Khaled Omar	700000004	123456	0792222224	khaled@mad.com	t	2026-05-06 22:23:35.800179
50000000-0000-0000-0000-000000000002	11111111-1111-1111-1111-111111111111	teacher	Mohammad Hasan	123	123	0791111111	teacher@mad.com	t	2026-05-06 21:05:07.599923
50000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111111	admin	Ahmad Khaled	12345	12345	0790000001	admin@mad.com	t	2026-05-06 21:05:07.599923
50000000-0000-0000-0000-000000000003	11111111-1111-1111-1111-111111111111	student	Ali Ahmad	700000022	123456	0792222222	student@mad.com	t	2026-05-06 21:05:07.599923
cd8059bf-3770-45ca-9e37-d64521b3202e	\N	teacher	Batool	1234567890	123456	\N	\N	t	2026-05-11 06:21:40.426695
ce2fd9cf-4b26-4614-8b88-77380b146016	\N	teacher	Adham	12347699	123456	\N	\N	t	2026-05-24 11:56:13.268206
0b2992e6-63e4-43d6-a3dc-c47f028fd746	\N	student	Adam H	700000001	\N	\N	\N	t	2026-05-24 12:14:13.96186
\.


--
-- TOC entry 5148 (class 0 OID 16517)
-- Dependencies: 238
-- Data for Name: warnings; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.warnings (id, student_id, admin_id, warning_type, reason, action_taken, warning_date, created_at) FROM stdin;
5dc08f7d-5a48-4982-81a1-2107816f397e	a3599b4a-9d7d-4af4-ad35-8f0eab3e245d	60000000-0000-0000-0000-000000000001	Final Warning	ص	Pending	2026-05-11	2026-05-11 23:11:58.549526
e574da9c-81ff-4177-97a7-0f84a45833a2	a3599b4a-9d7d-4af4-ad35-8f0eab3e245d	60000000-0000-0000-0000-000000000001	Warning	غياب	Pending	2026-05-23	2026-05-23 19:08:26.624424
827b81a0-58f5-4ef0-924b-919d70772922	22b0d31e-580e-4f7a-9b5f-4cc14818d50c	60000000-0000-0000-0000-000000000001	Warning	مشكلة صفية	Pending	2026-05-24	2026-05-24 11:47:34.761904
aa9c2d3a-b1fe-4c16-8a80-7fb98a439c38	22b0d31e-580e-4f7a-9b5f-4cc14818d50c	60000000-0000-0000-0000-000000000001	Transfer	مشاكل صفية	Pending	2026-05-24	2026-05-24 11:50:28.283755
\.


--
-- TOC entry 4879 (class 2606 OID 16526)
-- Name: activities activities_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.activities
    ADD CONSTRAINT activities_pkey PRIMARY KEY (id);


--
-- TOC entry 4882 (class 2606 OID 16528)
-- Name: admins admins_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.admins
    ADD CONSTRAINT admins_pkey PRIMARY KEY (id);


--
-- TOC entry 4884 (class 2606 OID 16530)
-- Name: admins admins_user_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.admins
    ADD CONSTRAINT admins_user_id_key UNIQUE (user_id);


--
-- TOC entry 4886 (class 2606 OID 16532)
-- Name: assessments assessments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.assessments
    ADD CONSTRAINT assessments_pkey PRIMARY KEY (id);


--
-- TOC entry 4888 (class 2606 OID 16534)
-- Name: assignments assignments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.assignments
    ADD CONSTRAINT assignments_pkey PRIMARY KEY (id);


--
-- TOC entry 4891 (class 2606 OID 16536)
-- Name: attendance attendance_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attendance
    ADD CONSTRAINT attendance_pkey PRIMARY KEY (id);


--
-- TOC entry 4893 (class 2606 OID 16538)
-- Name: attendance attendance_student_id_attendance_date_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attendance
    ADD CONSTRAINT attendance_student_id_attendance_date_key UNIQUE (student_id, attendance_date);


--
-- TOC entry 4896 (class 2606 OID 16540)
-- Name: chats chats_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chats
    ADD CONSTRAINT chats_pkey PRIMARY KEY (id);


--
-- TOC entry 4898 (class 2606 OID 16542)
-- Name: class_schedule class_schedule_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.class_schedule
    ADD CONSTRAINT class_schedule_pkey PRIMARY KEY (id);


--
-- TOC entry 4900 (class 2606 OID 16544)
-- Name: exam_schedules exam_schedules_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.exam_schedules
    ADD CONSTRAINT exam_schedules_pkey PRIMARY KEY (id);


--
-- TOC entry 4905 (class 2606 OID 16546)
-- Name: grades_levels grades_levels_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.grades_levels
    ADD CONSTRAINT grades_levels_pkey PRIMARY KEY (id);


--
-- TOC entry 4902 (class 2606 OID 16548)
-- Name: grades grades_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.grades
    ADD CONSTRAINT grades_pkey PRIMARY KEY (id);


--
-- TOC entry 4908 (class 2606 OID 16550)
-- Name: messages messages_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT messages_pkey PRIMARY KEY (id);


--
-- TOC entry 4910 (class 2606 OID 16552)
-- Name: notifications notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (id);


--
-- TOC entry 4912 (class 2606 OID 16554)
-- Name: notifications_receivers notifications_receivers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notifications_receivers
    ADD CONSTRAINT notifications_receivers_pkey PRIMARY KEY (id);


--
-- TOC entry 4914 (class 2606 OID 16556)
-- Name: schools schools_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.schools
    ADD CONSTRAINT schools_pkey PRIMARY KEY (id);


--
-- TOC entry 4916 (class 2606 OID 16558)
-- Name: schools schools_school_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.schools
    ADD CONSTRAINT schools_school_code_key UNIQUE (school_code);


--
-- TOC entry 4918 (class 2606 OID 16560)
-- Name: sections sections_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sections
    ADD CONSTRAINT sections_pkey PRIMARY KEY (id);


--
-- TOC entry 4921 (class 2606 OID 16562)
-- Name: students students_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.students
    ADD CONSTRAINT students_pkey PRIMARY KEY (id);


--
-- TOC entry 4923 (class 2606 OID 16564)
-- Name: students students_student_number_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.students
    ADD CONSTRAINT students_student_number_key UNIQUE (student_number);


--
-- TOC entry 4925 (class 2606 OID 16566)
-- Name: students students_user_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.students
    ADD CONSTRAINT students_user_id_key UNIQUE (user_id);


--
-- TOC entry 4927 (class 2606 OID 16568)
-- Name: subjects subjects_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.subjects
    ADD CONSTRAINT subjects_pkey PRIMARY KEY (id);


--
-- TOC entry 4929 (class 2606 OID 16570)
-- Name: teacher_subjects teacher_subjects_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.teacher_subjects
    ADD CONSTRAINT teacher_subjects_pkey PRIMARY KEY (id);


--
-- TOC entry 4931 (class 2606 OID 16572)
-- Name: teachers teachers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.teachers
    ADD CONSTRAINT teachers_pkey PRIMARY KEY (id);


--
-- TOC entry 4933 (class 2606 OID 16574)
-- Name: teachers teachers_user_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.teachers
    ADD CONSTRAINT teachers_user_id_key UNIQUE (user_id);


--
-- TOC entry 4935 (class 2606 OID 16576)
-- Name: users users_national_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_national_id_key UNIQUE (national_id);


--
-- TOC entry 4937 (class 2606 OID 16578)
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- TOC entry 4939 (class 2606 OID 16580)
-- Name: warnings warnings_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.warnings
    ADD CONSTRAINT warnings_pkey PRIMARY KEY (id);


--
-- TOC entry 4880 (class 1259 OID 16581)
-- Name: idx_activities_section; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_activities_section ON public.activities USING btree (section_id);


--
-- TOC entry 4889 (class 1259 OID 16582)
-- Name: idx_assignments_section; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_assignments_section ON public.assignments USING btree (section_id);


--
-- TOC entry 4894 (class 1259 OID 16583)
-- Name: idx_attendance_student; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_attendance_student ON public.attendance USING btree (student_id);


--
-- TOC entry 4903 (class 1259 OID 16584)
-- Name: idx_grades_student; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_grades_student ON public.grades USING btree (student_id);


--
-- TOC entry 4906 (class 1259 OID 16585)
-- Name: idx_messages_chat; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_messages_chat ON public.messages USING btree (chat_id);


--
-- TOC entry 4919 (class 1259 OID 16586)
-- Name: idx_students_section; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_students_section ON public.students USING btree (section_id);


--
-- TOC entry 4940 (class 2606 OID 16587)
-- Name: activities activities_approved_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.activities
    ADD CONSTRAINT activities_approved_by_fkey FOREIGN KEY (approved_by) REFERENCES public.admins(id);


--
-- TOC entry 4941 (class 2606 OID 16592)
-- Name: activities activities_section_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.activities
    ADD CONSTRAINT activities_section_id_fkey FOREIGN KEY (section_id) REFERENCES public.sections(id);


--
-- TOC entry 4942 (class 2606 OID 16597)
-- Name: activities activities_teacher_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.activities
    ADD CONSTRAINT activities_teacher_id_fkey FOREIGN KEY (teacher_id) REFERENCES public.teachers(id);


--
-- TOC entry 4943 (class 2606 OID 16602)
-- Name: admins admins_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.admins
    ADD CONSTRAINT admins_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- TOC entry 4944 (class 2606 OID 16607)
-- Name: assessments assessments_student_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.assessments
    ADD CONSTRAINT assessments_student_id_fkey FOREIGN KEY (student_id) REFERENCES public.students(id);


--
-- TOC entry 4945 (class 2606 OID 16612)
-- Name: assessments assessments_subject_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.assessments
    ADD CONSTRAINT assessments_subject_id_fkey FOREIGN KEY (subject_id) REFERENCES public.subjects(id);


--
-- TOC entry 4946 (class 2606 OID 16617)
-- Name: assessments assessments_teacher_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.assessments
    ADD CONSTRAINT assessments_teacher_id_fkey FOREIGN KEY (teacher_id) REFERENCES public.teachers(id);


--
-- TOC entry 4947 (class 2606 OID 16622)
-- Name: assignments assignments_section_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.assignments
    ADD CONSTRAINT assignments_section_id_fkey FOREIGN KEY (section_id) REFERENCES public.sections(id);


--
-- TOC entry 4948 (class 2606 OID 16627)
-- Name: assignments assignments_subject_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.assignments
    ADD CONSTRAINT assignments_subject_id_fkey FOREIGN KEY (subject_id) REFERENCES public.subjects(id);


--
-- TOC entry 4949 (class 2606 OID 16632)
-- Name: assignments assignments_teacher_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.assignments
    ADD CONSTRAINT assignments_teacher_id_fkey FOREIGN KEY (teacher_id) REFERENCES public.teachers(id);


--
-- TOC entry 4950 (class 2606 OID 16637)
-- Name: attendance attendance_student_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attendance
    ADD CONSTRAINT attendance_student_id_fkey FOREIGN KEY (student_id) REFERENCES public.students(id);


--
-- TOC entry 4951 (class 2606 OID 16642)
-- Name: attendance attendance_teacher_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attendance
    ADD CONSTRAINT attendance_teacher_id_fkey FOREIGN KEY (teacher_id) REFERENCES public.teachers(id);


--
-- TOC entry 4952 (class 2606 OID 16647)
-- Name: chats chats_student_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chats
    ADD CONSTRAINT chats_student_id_fkey FOREIGN KEY (student_id) REFERENCES public.students(id);


--
-- TOC entry 4953 (class 2606 OID 16652)
-- Name: chats chats_teacher_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chats
    ADD CONSTRAINT chats_teacher_id_fkey FOREIGN KEY (teacher_id) REFERENCES public.teachers(id);


--
-- TOC entry 4954 (class 2606 OID 16657)
-- Name: class_schedule class_schedule_section_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.class_schedule
    ADD CONSTRAINT class_schedule_section_id_fkey FOREIGN KEY (section_id) REFERENCES public.sections(id) ON DELETE CASCADE;


--
-- TOC entry 4955 (class 2606 OID 16662)
-- Name: class_schedule class_schedule_subject_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.class_schedule
    ADD CONSTRAINT class_schedule_subject_id_fkey FOREIGN KEY (subject_id) REFERENCES public.subjects(id) ON DELETE CASCADE;


--
-- TOC entry 4956 (class 2606 OID 16667)
-- Name: class_schedule class_schedule_teacher_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.class_schedule
    ADD CONSTRAINT class_schedule_teacher_id_fkey FOREIGN KEY (teacher_id) REFERENCES public.teachers(id) ON DELETE SET NULL;


--
-- TOC entry 4957 (class 2606 OID 16672)
-- Name: exam_schedules exam_schedules_section_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.exam_schedules
    ADD CONSTRAINT exam_schedules_section_id_fkey FOREIGN KEY (section_id) REFERENCES public.sections(id);


--
-- TOC entry 4958 (class 2606 OID 16677)
-- Name: exam_schedules exam_schedules_subject_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.exam_schedules
    ADD CONSTRAINT exam_schedules_subject_id_fkey FOREIGN KEY (subject_id) REFERENCES public.subjects(id);


--
-- TOC entry 4971 (class 2606 OID 16682)
-- Name: sections fk_homeroom_teacher; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sections
    ADD CONSTRAINT fk_homeroom_teacher FOREIGN KEY (homeroom_teacher_id) REFERENCES public.teachers(id);


--
-- TOC entry 4966 (class 2606 OID 16687)
-- Name: notifications fk_notifications_section; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT fk_notifications_section FOREIGN KEY (section_id) REFERENCES public.sections(id) ON DELETE CASCADE;


--
-- TOC entry 4967 (class 2606 OID 16692)
-- Name: notifications fk_notifications_teacher; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT fk_notifications_teacher FOREIGN KEY (teacher_id) REFERENCES public.teachers(id) ON DELETE CASCADE;


--
-- TOC entry 4959 (class 2606 OID 16697)
-- Name: grades grades_approved_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.grades
    ADD CONSTRAINT grades_approved_by_fkey FOREIGN KEY (approved_by) REFERENCES public.admins(id);


--
-- TOC entry 4963 (class 2606 OID 16702)
-- Name: grades_levels grades_levels_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.grades_levels
    ADD CONSTRAINT grades_levels_school_id_fkey FOREIGN KEY (school_id) REFERENCES public.schools(id) ON DELETE CASCADE;


--
-- TOC entry 4960 (class 2606 OID 16707)
-- Name: grades grades_student_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.grades
    ADD CONSTRAINT grades_student_id_fkey FOREIGN KEY (student_id) REFERENCES public.students(id);


--
-- TOC entry 4961 (class 2606 OID 16712)
-- Name: grades grades_subject_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.grades
    ADD CONSTRAINT grades_subject_id_fkey FOREIGN KEY (subject_id) REFERENCES public.subjects(id);


--
-- TOC entry 4962 (class 2606 OID 16717)
-- Name: grades grades_teacher_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.grades
    ADD CONSTRAINT grades_teacher_id_fkey FOREIGN KEY (teacher_id) REFERENCES public.teachers(id);


--
-- TOC entry 4964 (class 2606 OID 16722)
-- Name: messages messages_chat_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT messages_chat_id_fkey FOREIGN KEY (chat_id) REFERENCES public.chats(id) ON DELETE CASCADE;


--
-- TOC entry 4965 (class 2606 OID 16727)
-- Name: messages messages_sender_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT messages_sender_user_id_fkey FOREIGN KEY (sender_user_id) REFERENCES public.users(id);


--
-- TOC entry 4968 (class 2606 OID 16732)
-- Name: notifications notifications_admin_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_admin_id_fkey FOREIGN KEY (admin_id) REFERENCES public.admins(id);


--
-- TOC entry 4969 (class 2606 OID 16737)
-- Name: notifications_receivers notifications_receivers_notification_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notifications_receivers
    ADD CONSTRAINT notifications_receivers_notification_id_fkey FOREIGN KEY (notification_id) REFERENCES public.notifications(id) ON DELETE CASCADE;


--
-- TOC entry 4970 (class 2606 OID 16742)
-- Name: notifications_receivers notifications_receivers_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notifications_receivers
    ADD CONSTRAINT notifications_receivers_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- TOC entry 4972 (class 2606 OID 16747)
-- Name: sections sections_grade_level_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sections
    ADD CONSTRAINT sections_grade_level_id_fkey FOREIGN KEY (grade_level_id) REFERENCES public.grades_levels(id) ON DELETE CASCADE;


--
-- TOC entry 4973 (class 2606 OID 16752)
-- Name: students students_section_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.students
    ADD CONSTRAINT students_section_id_fkey FOREIGN KEY (section_id) REFERENCES public.sections(id);


--
-- TOC entry 4974 (class 2606 OID 16757)
-- Name: students students_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.students
    ADD CONSTRAINT students_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- TOC entry 4975 (class 2606 OID 16762)
-- Name: subjects subjects_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.subjects
    ADD CONSTRAINT subjects_school_id_fkey FOREIGN KEY (school_id) REFERENCES public.schools(id) ON DELETE CASCADE;


--
-- TOC entry 4976 (class 2606 OID 16767)
-- Name: teacher_subjects teacher_subjects_section_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.teacher_subjects
    ADD CONSTRAINT teacher_subjects_section_id_fkey FOREIGN KEY (section_id) REFERENCES public.sections(id) ON DELETE CASCADE;


--
-- TOC entry 4977 (class 2606 OID 16772)
-- Name: teacher_subjects teacher_subjects_subject_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.teacher_subjects
    ADD CONSTRAINT teacher_subjects_subject_id_fkey FOREIGN KEY (subject_id) REFERENCES public.subjects(id) ON DELETE CASCADE;


--
-- TOC entry 4978 (class 2606 OID 16777)
-- Name: teacher_subjects teacher_subjects_teacher_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.teacher_subjects
    ADD CONSTRAINT teacher_subjects_teacher_id_fkey FOREIGN KEY (teacher_id) REFERENCES public.teachers(id) ON DELETE CASCADE;


--
-- TOC entry 4979 (class 2606 OID 16782)
-- Name: teachers teachers_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.teachers
    ADD CONSTRAINT teachers_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- TOC entry 4980 (class 2606 OID 16787)
-- Name: users users_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_school_id_fkey FOREIGN KEY (school_id) REFERENCES public.schools(id) ON DELETE CASCADE;


--
-- TOC entry 4981 (class 2606 OID 16792)
-- Name: warnings warnings_admin_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.warnings
    ADD CONSTRAINT warnings_admin_id_fkey FOREIGN KEY (admin_id) REFERENCES public.admins(id);


--
-- TOC entry 4982 (class 2606 OID 16797)
-- Name: warnings warnings_student_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.warnings
    ADD CONSTRAINT warnings_student_id_fkey FOREIGN KEY (student_id) REFERENCES public.students(id);


-- Completed on 2026-05-25 02:19:47

--
-- PostgreSQL database dump complete
--

\unrestrict K9xDhARTBTgEDKuOCWTTzJrkaN7jfE6XGcU6k3XdzOzOsHtHqgBhSjl0ecbnlUZ

