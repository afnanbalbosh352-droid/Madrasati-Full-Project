import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../General/app_colors.dart';
import '../api.dart';

class TeacherGradesScreen extends StatefulWidget {

  const TeacherGradesScreen({super.key});

  @override
  State<TeacherGradesScreen> createState() =>
      _TeacherGradesScreenState();

}

class _TeacherGradesScreenState
    extends State<TeacherGradesScreen> {

  final TextEditingController gradeController =
  TextEditingController();

  // =====================================
  // DROPDOWNS
  // =====================================

  String? selectedStudentId;

  String? selectedSubjectId;

  String selectedExam = "First Exam";

  // =====================================
  // DATA
  // =====================================

  List students = [];

  List subjects = [];

  List grades = [];

  bool isLoading = true;

  bool isSubmitting = false;

  String errorMessage = "";

  // =====================================
  // EXAMS
  // =====================================

  final List<String> exams = [

    "First Exam",

    "Second Exam",

    "Final Exam",

  ];

  // =====================================
  // INIT
  // =====================================

  @override
  void initState() {

    super.initState();

    loadData();

  }

  // =====================================
  // LOAD DATA
  // =====================================

  Future<void> loadData() async {

    setState(() {

      isLoading = true;

      errorMessage = "";

    });

    await Future.wait([

      getStudents(),

      getSubjects(),

    ]);

    setState(() {

      isLoading = false;

    });

  }

  // =====================================
  // GET STUDENTS
  // =====================================

  Future<void> getStudents() async {

    try {

      final prefs =
      await SharedPreferences.getInstance();

      final teacherId =
      prefs.getString("profile_id");

      if (teacherId == null) {

        errorMessage =
        "Teacher ID not found";

        return;

      }

      final response = await http.get(

        Uri.parse(
          "${Api.teacherStudents}/$teacherId",
        ),

      );

      final data =
      jsonDecode(response.body);

      if (response.statusCode == 200 &&
          data["success"] == true) {

        students =
            data["students"] ?? [];

      }

      else {

        errorMessage =
            data["message"] ??
                "Failed to load students";

      }

    }

    catch (e) {

      errorMessage =
      "Error loading students";

    }

  }

  // =====================================
  // GET SUBJECTS
  // =====================================

  Future<void> getSubjects() async {

    try {

      final prefs =
      await SharedPreferences.getInstance();

      final teacherId =
      prefs.getString("profile_id");

      if (teacherId == null) {

        errorMessage =
        "Teacher ID not found";

        return;

      }

      final response = await http.get(

        Uri.parse(
          "${Api.teacherSubjects}/$teacherId",
        ),

      );

      final data =
      jsonDecode(response.body);

      if (response.statusCode == 200 &&
          data["success"] == true) {

        subjects =
            data["subjects"] ?? [];

      }

      else {

        errorMessage =
            data["message"] ??
                "Failed to load subjects";

      }

    }

    catch (e) {

      errorMessage =
      "Error loading subjects";

    }

  }

  // =====================================
  // ADD GRADE
  // =====================================

  void addGrade() {

    final gradeValue =
    double.tryParse(
      gradeController.text,
    );

    if (selectedStudentId == null) {

      showMessage(
        "Please select a student",
      );

      return;

    }

    if (selectedSubjectId == null) {

      showMessage(
        "Please select a subject",
      );

      return;

    }

    if (gradeController.text.isEmpty) {

      showMessage(
        "Please enter grade",
      );

      return;

    }

    if (gradeValue == null ||
        gradeValue < 0 ||
        gradeValue > 100) {

      showMessage(
        "Grade must be between 0 and 100",
      );

      return;

    }

    final student =
    students.firstWhere(
          (s) =>
      s["id"].toString() ==
          selectedStudentId,
    );

    final subject =
    subjects.firstWhere(
          (s) =>
      s["id"].toString() ==
          selectedSubjectId,
    );

    setState(() {

      grades.add({

        "student_id":
        selectedStudentId,

        "student_name":
        student["full_name"],

        "subject_id":
        selectedSubjectId,

        "subject_name":
        subject["name"],

        "exam_type":
        selectedExam,

        "grade":
        gradeController.text,

      });

      gradeController.clear();

      selectedStudentId = null;

      selectedSubjectId = null;

      selectedExam = "First Exam";

    });

    showMessage(
      "Grade added successfully",
    );

  }

  // =====================================
  // SUBMIT
  // =====================================

  Future<void> submitGrades() async {

    if (grades.isEmpty) {

      showMessage(
        "No grades to submit",
      );

      return;

    }

    setState(() {

      isSubmitting = true;

    });

    try {

      final prefs =
      await SharedPreferences.getInstance();

      final teacherId =
      prefs.getString("profile_id");

      if (teacherId == null) {

        showMessage(
          "Teacher ID not found",
        );

        return;

      }

      for (var grade in grades) {

        final response =
        await http.post(

          Uri.parse(
            Api.teacherAddGrade,
          ),

          headers: {

            "Content-Type":
            "application/json",

          },

          body: jsonEncode({

            "student_id":
            grade["student_id"],

            "subject_id":
            grade["subject_id"],

            "teacher_id":
            teacherId,

            "exam_type":
            grade["exam_type"],

            "grade_value":
            grade["grade"],

          }),

        );

        final data =
        jsonDecode(response.body);

        if (response.statusCode != 200 ||
            data["success"] != true) {

          showMessage(
            data["message"] ??
                "Failed to send grades",
          );

          return;

        }

      }

      showMessage(
        "Grades sent successfully",
      );

      setState(() {

        grades.clear();

      });

    }

    catch (e) {

      showMessage(
        "Something went wrong",
      );

    }

    finally {

      setState(() {

        isSubmitting = false;

      });

    }

  }

  // =====================================
  // EDIT
  // =====================================

  void editGrade(int index) {

    final item = grades[index];

    setState(() {

      selectedStudentId =
      item["student_id"];

      selectedSubjectId =
      item["subject_id"];

      selectedExam =
      item["exam_type"];

      gradeController.text =
      item["grade"];

      grades.removeAt(index);

    });

  }

  // =====================================
  // MESSAGE
  // =====================================

  void showMessage(String message) {

    ScaffoldMessenger.of(context)
        .showSnackBar(

      SnackBar(
        content: Text(message),
      ),

    );

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
      AppColors.background,

      appBar: AppBar(

        title: const Text(
          "Student Grades",
        ),

        backgroundColor:
        AppColors.primary,

        foregroundColor:
        Colors.white,

      ),

      body: isLoading

          ? const Center(
        child:
        CircularProgressIndicator(),
      )

          : errorMessage.isNotEmpty

          ? Center(

        child: Column(

          mainAxisAlignment:
          MainAxisAlignment.center,

          children: [

            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 70,
            ),

            const SizedBox(height: 16),

            Text(
              errorMessage,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(

              onPressed: loadData,

              child: const Text(
                "Retry",
              ),

            ),

          ],

        ),

      )

          : students.isEmpty

          ? const Center(

        child: Column(

          mainAxisAlignment:
          MainAxisAlignment.center,

          children: [

            Icon(
              Icons.people_outline,
              size: 70,
              color: Colors.grey,
            ),

            SizedBox(height: 16),

            Text(
              "No students assigned to this teacher",
              style: TextStyle(
                fontSize: 16,
              ),
            ),

          ],

        ),

      )

          : subjects.isEmpty

          ? const Center(

        child: Column(

          mainAxisAlignment:
          MainAxisAlignment.center,

          children: [

            Icon(
              Icons.menu_book_outlined,
              size: 70,
              color: Colors.grey,
            ),

            SizedBox(height: 16),

            Text(
              "No subjects assigned to this teacher",
              style: TextStyle(
                fontSize: 16,
              ),
            ),

          ],

        ),

      )

          : Padding(

        padding:
        const EdgeInsets.all(16),

        child: Column(

          children: [

            // =========================
            // FORM
            // =========================

            Card(

              elevation: 4,

              shape:
              RoundedRectangleBorder(

                borderRadius:
                BorderRadius.circular(
                  16,
                ),

              ),

              child: Padding(

                padding:
                const EdgeInsets.all(16),

                child: Column(

                  children: [

                    DropdownButtonFormField<
                        String>(

                      initialValue:
                      selectedStudentId,

                      hint: const Text(
                        "Select Student",
                      ),

                      items:
                      students.map((s) {

                        return DropdownMenuItem<
                            String>(

                          value:
                          s["id"]
                              .toString(),

                          child: Text(
                            s["full_name"],
                          ),

                        );

                      }).toList(),

                      onChanged: (val) {

                        setState(() {

                          selectedStudentId =
                              val;

                        });

                      },

                    ),

                    const SizedBox(
                      height: 12,
                    ),

                    DropdownButtonFormField<
                        String>(

                      initialValue:
                      selectedSubjectId,

                      hint: const Text(
                        "Select Subject",
                      ),

                      items:
                      subjects.map((s) {

                        return DropdownMenuItem<
                            String>(

                          value:
                          s["id"]
                              .toString(),

                          child: Text(
                            s["name"],
                          ),

                        );

                      }).toList(),

                      onChanged: (val) {

                        setState(() {

                          selectedSubjectId =
                              val;

                        });

                      },

                    ),

                    const SizedBox(
                      height: 12,
                    ),

                    DropdownButtonFormField<
                        String>(

                      initialValue:
                      selectedExam,

                      items:
                      exams.map((e) {

                        return DropdownMenuItem<
                            String>(

                          value: e,

                          child: Text(e),

                        );

                      }).toList(),

                      onChanged: (val) {

                        setState(() {

                          selectedExam =
                          val!;

                        });

                      },

                    ),

                    const SizedBox(
                      height: 12,
                    ),

                    TextField(

                      controller:
                      gradeController,

                      keyboardType:
                      TextInputType.number,

                      decoration:
                      const InputDecoration(

                        labelText:
                        "Grade",

                        hintText:
                        "0 - 100",

                        border:
                        OutlineInputBorder(),

                      ),

                    ),

                    const SizedBox(
                      height: 16,
                    ),

                    SizedBox(

                      width:
                      double.infinity,

                      height: 50,

                      child:
                      ElevatedButton(

                        onPressed:
                        addGrade,

                        child:
                        const Text(
                          "Add Grade",
                        ),

                      ),

                    ),

                  ],

                ),

              ),

            ),

            const SizedBox(height: 20),

            // =========================
            // LIST
            // =========================

            Expanded(

              child: grades.isEmpty

                  ? const Center(
                child: Text(
                  "No grades added yet",
                ),
              )

                  : ListView.builder(

                itemCount:
                grades.length,

                itemBuilder:
                    (_, i) {

                  final grade =
                  grades[i];

                  return Card(

                    child: ListTile(

                      leading:
                      CircleAvatar(

                        backgroundColor:
                        AppColors.primary,

                        child: Text(
                          grade["grade"],
                          style:
                          const TextStyle(
                            color:
                            Colors.white,
                          ),
                        ),

                      ),

                      title: Text(
                        grade["student_name"],
                      ),

                      subtitle: Text(
                        "${grade["subject_name"]} • ${grade["exam_type"]}",
                      ),

                      trailing:
                      IconButton(

                        icon: const Icon(
                          Icons.edit,
                          color:
                          Colors.blue,
                        ),

                        onPressed:
                            () {

                          editGrade(i);

                        },

                      ),

                    ),

                  );

                },

              ),

            ),

            // =========================
            // SUBMIT
            // =========================

            if (grades.isNotEmpty)

              SizedBox(

                width:
                double.infinity,

                height: 55,

                child:
                ElevatedButton.icon(

                  onPressed:
                  isSubmitting
                      ? null
                      : submitGrades,

                  style:
                  ElevatedButton.styleFrom(

                    backgroundColor:
                    Colors.green,

                  ),

                  icon:
                  isSubmitting

                      ? const SizedBox(

                    width: 20,
                    height: 20,

                    child:
                    CircularProgressIndicator(
                      color:
                      Colors.white,
                      strokeWidth: 2,
                    ),

                  )

                      : const Icon(
                    Icons.check_circle,
                    color:
                    Colors.white,
                  ),

                  label: Text(

                    isSubmitting

                        ? "Sending..."

                        : "Send Grades",

                    style:
                    const TextStyle(
                      color:
                      Colors.white,
                    ),

                  ),

                ),

              ),

          ],

        ),

      ),

    );

  }

}