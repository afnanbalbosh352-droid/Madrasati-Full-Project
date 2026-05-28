import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../General/app_colors.dart';
import '../api.dart';

class TeacherAssessmentScreen extends StatefulWidget {

  const TeacherAssessmentScreen({super.key});

  @override
  State<TeacherAssessmentScreen> createState() =>
      _TeacherAssessmentScreenState();

}

class _TeacherAssessmentScreenState
    extends State<TeacherAssessmentScreen> {

  // =====================================
  // CONTROLLERS
  // =====================================

  final noteController =
  TextEditingController();

  final titleController =
  TextEditingController();

  // =====================================
  // DATA
  // =====================================

  List students = [];

  List subjects = [];

  List assessments = [];

  bool isLoading = true;

  bool isSubmitting = false;

  String errorMessage = "";

  // =====================================
  // SELECTED VALUES
  // =====================================

  String? selectedStudentId;

  String? selectedSubjectId;

  String selectedRating =
      "Good";

  // =====================================
  // RATINGS
  // =====================================

  final List<String> ratings = [

    "Excellent",

    "Very Good",

    "Good",

    "Poor",

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
      prefs.getString(
        "profile_id",
      );

      if (teacherId == null) {

        errorMessage =
        "Teacher not found";

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
      prefs.getString(
        "profile_id",
      );

      if (teacherId == null) {

        errorMessage =
        "Teacher not found";

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
        "Failed to load subjects";

      }

    }

    catch (e) {

      errorMessage =
      "Error loading subjects";

    }

  }

  // =====================================
  // SHOW MESSAGE
  // =====================================

  void showMessage(String message) {

    ScaffoldMessenger.of(context)
        .showSnackBar(

      SnackBar(
        content: Text(message),
      ),

    );

  }

  // =====================================
  // ADD ASSESSMENT
  // =====================================

  void addAssessment() {

    if (selectedStudentId == null) {

      showMessage(
        "Please select student",
      );

      return;

    }

    if (selectedSubjectId == null) {

      showMessage(
        "Please select subject",
      );

      return;

    }

    if (titleController.text
        .trim()
        .isEmpty) {

      showMessage(
        "Please enter evaluation title",
      );

      return;

    }

    if (noteController.text
        .trim()
        .isEmpty) {

      showMessage(
        "Please enter note",
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

      assessments.add({

        "student_id":
        selectedStudentId,

        "student_name":
        student["full_name"],

        "subject_id":
        selectedSubjectId,

        "subject_name":
        subject["name"],

        "evaluation_title":
        titleController.text.trim(),

        "rating":
        selectedRating,

        "note":
        noteController.text.trim(),

      });

      titleController.clear();

      noteController.clear();

      selectedStudentId = null;

      selectedSubjectId = null;

      selectedRating = "Good";

    });

    showMessage(
      "Assessment added successfully",
    );

  }

  // =====================================
  // EDIT ASSESSMENT
  // =====================================

  void editAssessment(int index) {

    final item =
    assessments[index];

    setState(() {

      selectedStudentId =
      item["student_id"];

      selectedSubjectId =
      item["subject_id"];

      selectedRating =
      item["rating"];

      titleController.text =
      item["evaluation_title"];

      noteController.text =
      item["note"];

      assessments.removeAt(index);

    });

  }

  // =====================================
  // SUBMIT ASSESSMENTS
  // =====================================

  Future<void> submitAssessments() async {

    if (assessments.isEmpty) {

      showMessage(
        "No assessments to send",
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
      prefs.getString(
        "profile_id",
      );

      if (teacherId == null) {

        showMessage(
          "Teacher not found",
        );

        return;

      }

      for (var assessment
      in assessments) {

        final response =
        await http.post(

          Uri.parse(
            Api.teacherAddAssessment,
          ),

          headers: {

            "Content-Type":
            "application/json",

          },

          body: jsonEncode({

            "student_id":
            assessment["student_id"],

            "teacher_id":
            teacherId,

            "subject_id":
            assessment["subject_id"],

            "evaluation_title":
            assessment["evaluation_title"],

            "rating":
            assessment["rating"],

            "note":
            assessment["note"],

          }),

        );

        final data =
        jsonDecode(response.body);

        if (response.statusCode != 200 ||
            data["success"] != true) {

          showMessage(

            data["message"] ??
                "Failed to submit assessments",

          );

          return;

        }

      }

      showMessage(
        "Assessments submitted successfully",
      );

      setState(() {

        assessments.clear();

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
  // GET RATING COLOR
  // =====================================

  Color getRatingColor(
      String rating,
      ) {

    switch (rating) {

      case "Excellent":
        return Colors.green;

      case "Very Good":
        return Colors.blue;

      case "Good":
        return Colors.orange;

      default:
        return Colors.red;

    }

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
      AppColors.background,

      appBar: AppBar(

        title: const Text(
          "Monthly Assessment",
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

              size: 70,

              color: Colors.red,

            ),

            const SizedBox(height: 16),

            Text(
              errorMessage,
            ),

            const SizedBox(height: 20),

            ElevatedButton(

              onPressed:
              loadData,

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
              "No students found",
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
              "No subjects found",
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

                    // =====================
                    // STUDENT
                    // =====================

                    DropdownButtonFormField<
                        String>(

                      initialValue:
                      selectedStudentId,

                      hint: const Text(
                        "Select Student",
                      ),

                      decoration:
                      const InputDecoration(

                        prefixIcon:
                        Icon(Icons.person),

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

                    // =====================
                    // SUBJECT
                    // =====================

                    DropdownButtonFormField<
                        String>(

                      initialValue:
                      selectedSubjectId,

                      hint: const Text(
                        "Select Subject",
                      ),

                      decoration:
                      const InputDecoration(

                        prefixIcon:
                        Icon(Icons.book),

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

                    // =====================
                    // TITLE
                    // =====================

                    TextField(

                      controller:
                      titleController,

                      decoration:
                      const InputDecoration(

                        labelText:
                        "Evaluation Title",

                        hintText:
                        "Monthly Evaluation",

                        prefixIcon:
                        Icon(Icons.title),

                        border:
                        OutlineInputBorder(),

                      ),

                    ),

                    const SizedBox(
                      height: 12,
                    ),

                    // =====================
                    // RATING
                    // =====================

                    DropdownButtonFormField<
                        String>(

                      initialValue:
                      selectedRating,

                      decoration:
                      const InputDecoration(

                        labelText:
                        "Rating",

                        prefixIcon:
                        Icon(
                          Icons.star_rate,
                          color:
                          Colors.amber,
                        ),

                      ),

                      items:
                      ratings.map((r) {

                        return DropdownMenuItem<
                            String>(

                          value: r,

                          child: Text(r),

                        );

                      }).toList(),

                      onChanged: (val) {

                        setState(() {

                          selectedRating =
                          val!;

                        });

                      },

                    ),

                    const SizedBox(
                      height: 12,
                    ),

                    // =====================
                    // NOTE
                    // =====================

                    TextField(

                      controller:
                      noteController,

                      maxLines: 3,

                      decoration:
                      const InputDecoration(

                        labelText:
                        "Teacher Note",

                        hintText:
                        "Enter comments here",

                        prefixIcon:
                        Icon(
                          Icons.note_alt,
                        ),

                        border:
                        OutlineInputBorder(),

                      ),

                    ),

                    const SizedBox(
                      height: 20,
                    ),

                    // =====================
                    // BUTTON
                    // =====================

                    SizedBox(

                      width:
                      double.infinity,

                      height: 50,

                      child:
                      ElevatedButton.icon(

                        onPressed:
                        addAssessment,

                        icon: const Icon(
                          Icons.add,
                        ),

                        label: const Text(
                          "Add Assessment",
                        ),

                      ),

                    ),

                  ],

                ),

              ),

            ),

            const SizedBox(height: 20),

            // =========================
            // TITLE
            // =========================

            const Align(

              alignment:
              Alignment.centerLeft,

              child: Text(

                "Pending Assessments",

                style: TextStyle(

                  fontSize: 18,

                  fontWeight:
                  FontWeight.bold,

                ),

              ),

            ),

            const SizedBox(height: 10),

            // =========================
            // LIST
            // =========================

            Expanded(

              child:
              assessments.isEmpty

                  ? const Center(
                child: Text(
                  "No assessments added",
                ),
              )

                  : ListView.builder(

                itemCount:
                assessments.length,

                itemBuilder:
                    (_, i) {

                  final a =
                  assessments[i];

                  return Card(

                    margin:
                    const EdgeInsets.only(
                      bottom: 10,
                    ),

                    child: ListTile(

                      leading:
                      CircleAvatar(

                        backgroundColor:
                        getRatingColor(
                          a["rating"],
                        ),

                        child: const Icon(

                          Icons.person,

                          color:
                          Colors.white,

                        ),

                      ),

                      title: Text(

                        "${a["student_name"]} (${a["rating"]})",

                      ),

                      subtitle: Text(

                        "${a["subject_name"]}\n"
                            "${a["evaluation_title"]}\n"
                            "Note: ${a["note"]}",

                      ),

                      isThreeLine: true,

                      trailing:
                      IconButton(

                        icon: const Icon(

                          Icons.edit,

                          color:
                          Colors.blue,

                        ),

                        onPressed:
                            () {

                          editAssessment(i);

                        },

                      ),

                    ),

                  );

                },

              ),

            ),

            // =========================
            // SUBMIT BUTTON
            // =========================

            if (assessments.isNotEmpty)

              SizedBox(

                width:
                double.infinity,

                height: 55,

                child:
                ElevatedButton.icon(

                  onPressed:
                  isSubmitting

                      ? null

                      : submitAssessments,

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

                    Icons.send,

                    color:
                    Colors.white,

                  ),

                  label: Text(

                    isSubmitting

                        ? "Sending..."

                        : "Send Assessments",

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