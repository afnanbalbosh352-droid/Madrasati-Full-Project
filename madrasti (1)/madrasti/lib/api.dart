class Api {

  // =========================================================
  // BASE URL
  // =========================================================

  // ANDROID EMULATOR
  static const String baseUrl =
      "http://localhost:3000";



  // =========================================================
  // AUTH
  // =========================================================

  static const String login =
      "$baseUrl/loginn";

  static const String resetPassword =
      "$baseUrl/reset-password";

  static const String verifySchool =
      "$baseUrl/verify-school";


  // =========================================================
  // STUDENT APIs
  // =========================================================

  static const String studentDashboard =
      "$baseUrl/student/dashboard";

  static const String studentActivities =
      "$baseUrl/student/activities";

  static const String studentExamSchedule =
      "$baseUrl/student/exam-schedule";

  static const String studentAssignments =
      "$baseUrl/student/assignments";

  static const String studentClassSchedule =
      "$baseUrl/student/class-schedule";

  static const String studentGrades =
      "$baseUrl/student/grades";

  static const String studentAssessments =
      "$baseUrl/student/assessments";

  static const String studentAttendance =
      "$baseUrl/student/attendance";

  static const String studentWarnings =
      "$baseUrl/student/warnings";

  static const String studentNotifications =
      "$baseUrl/student/notifications";

  static const String studentTeachers =
      "$baseUrl/student/teachers";


  // =========================================================
  // TEACHER APIs
  // =========================================================

  static const String teacherDashboard =
      "$baseUrl/feature/dashboard";

  static const String teacherSections =
      "$baseUrl/feature/sections";



  static const String teacherAddActivity =
      "$baseUrl/feature/add-activity";

  static const String teacherAddAssignment =
      "$baseUrl/feature/add-assignment";

  static const String teacherAddAttendance =
      "$baseUrl/feature/add-attendance";

  static const String teacherAddGrade =
      "$baseUrl/feature/add-grade";

  static const String teacherAddAssessment =
      "$baseUrl/feature/add-assessment";

  static const String teacherSchedule =
      "$baseUrl/feature/class-schedule";

  static const String teacherNotifications =
      "$baseUrl/feature/notifications";

  static const String teacherAssignments =
      "$baseUrl/feature/assignments";

  static const String teacherActivities =
      "$baseUrl/feature/activities";


  // =========================================================
  // ADMIN APIs
  // =========================================================

  static const String adminDashboard =
      "$baseUrl/admin/dashboard";

  static const String adminStudents =
      "$baseUrl/admin/students";

  static const String adminStudentsBySection =
      "$baseUrl/admin/students-by-section";

  static const String adminTeachers =
      "$baseUrl/admin/teachers";



  static const String adminAssignClassTeacher =
      "$baseUrl/admin/assign-class-teacher";



  static const String adminPendingActivities =
      "$baseUrl/admin/pending-activities";

  static const String adminApproveActivity =
      "$baseUrl/admin/approve-activity";

  static const String adminRejectActivity =
      "$baseUrl/admin/reject-activity";

  static const String adminSendNotification =
      "$baseUrl/admin/send-notification";

  static const String adminPendingGrades =
      "$baseUrl/admin/pending-grades";

  static const String adminApproveGrade =
      "$baseUrl/admin/approve-grade";

  static const String adminAttendance =
      "$baseUrl/admin/attendance";

  static const String adminAddWarning =
      "$baseUrl/admin/add-warning";

  static const String adminWarnings =
      "$baseUrl/admin/warnings";





  static const String createOrGetChat =
      "$baseUrl/student/chat/create-or-get";



  static const String getMessages =
      "$baseUrl/student/chat/messages";











  static const String teacherSubjects =
      "$baseUrl/feature/subjects";

  static const String teacherStudents =
      "$baseUrl/feature/teacher-students";









  static const String teacherChats =
      "$baseUrl/feature/teacher-chats";

  static const String chatMessages =
      "$baseUrl/feature/messages";

  static const String sendMessage =
      "$baseUrl/feature/send-message";









  static const String teacherSendNotification =
      "$baseUrl/feature/send-notification";

  static const String teacherSentNotifications =
      "$baseUrl/feature/teacher-notifications";





  static const String adminSectionTeachers =
      "$baseUrl/admin/section-teachers";

  static const String adminCreateSection =
      "$baseUrl/admin/create-section";

  static const String adminUpdateSection =
      "$baseUrl/admin/update-section";

  static const String adminDeleteSection =
      "$baseUrl/admin/delete-section";

  static const String adminDeleteNotification =
      "$baseUrl/admin/delete-notification";




  // =========================================================
// ADMIN STUDENTS
// =========================================================

  static const String adminCreateStudent =
      "$baseUrl/admin/create-student";

  static const String adminUpdateStudent =
      "$baseUrl/admin/update-student";

  static const String adminDeleteStudent =
      "$baseUrl/admin/delete-student";




  static const String adminCreateTeacher =
      "$baseUrl/admin/create-teacher";

  static const String adminUpdateTeacher =
      "$baseUrl/admin/update-teacher";

  static const String adminDeleteTeacher =
      "$baseUrl/admin/delete-teacher";



  // =====================================
// ADMIN GRADES
// =====================================


  static const String adminApproveStudentGrade =
      "$baseUrl/admin/approve-grade";

  static const String adminGenerateReportCard =
      "$baseUrl/admin/report-card";

  static const String adminPrintCertificates =
      "$baseUrl/admin/print-certificates";






  static const String adminNotifications =
      "$baseUrl/admin/notifications";







  static const String adminGrades =
      "$baseUrl/admin/grades";

  static const String adminSections =
      "$baseUrl/admin/sections";

  static const String adminSubjects =
      "$baseUrl/admin/subjects";

  static const String adminClassSchedule =
      "$baseUrl/admin/admin/class-schedule";

  static const String adminAddClassSchedule =
      "$baseUrl/admin/add-class-schedule";




}