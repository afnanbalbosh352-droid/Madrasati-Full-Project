import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../General/app_colors.dart';
import '../api.dart';

class TeacherAssignmentsScreen extends StatefulWidget {

  const TeacherAssignmentsScreen({super.key});

  @override
  State<TeacherAssignmentsScreen> createState() =>
      _TeacherAssignmentsScreenState();

}

class _TeacherAssignmentsScreenState
    extends State<TeacherAssignmentsScreen> {

  // =====================================
  // CONTROLLERS
  // =====================================

  final titleController =
  TextEditingController();

  final descController =
  TextEditingController();

  // =====================================
  // DATA
  // =====================================

  List sections = [];

  List subjects = [];

  List assignments = [];

  bool isLoading = true;

  bool isSubmitting = false;

  String errorMessage = "";

  // =====================================
  // SELECTED VALUES
  // =====================================

  String? selectedSectionId;

  String? selectedSubjectId;

  DateTime? selectedDate;

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

      getSections(),

      getSubjects(),

    ]);

    setState(() {

      isLoading = false;

    });

  }

  // =====================================
  // GET SECTIONS
  // =====================================

  Future<void> getSections() async {

    try {

      final prefs =
      await SharedPreferences.getInstance();

      final teacherId =
      prefs.getString("profile_id");

      if (teacherId == null) {

        errorMessage =
        "Teacher not found";

        return;

      }

      final response = await http.get(

        Uri.parse(
          "${Api.teacherSections}/$teacherId",
        ),

      );

      final data =
      jsonDecode(response.body);

      if (response.statusCode == 200 &&
          data["success"] == true) {

        sections =
            data["sections"] ?? [];

      }

      else {

        errorMessage =
        "Failed to load sections";

      }

    }

    catch (e) {

      errorMessage =
      "Error loading sections";

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
  // PICK DATE
  // =====================================

  Future<void> pickDate() async {

    final date =
    await showDatePicker(

      context: context,

      initialDate:
      DateTime.now(),

      firstDate:
      DateTime.now(),

      lastDate:
      DateTime(2030),

    );

    if (date != null) {

      setState(() {

        selectedDate = date;

      });

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
  // ADD ASSIGNMENT LOCAL
  // =====================================

  void addAssignment() {

    if (selectedSectionId == null) {

      showMessage(
        "Please select section",
      );

      return;

    }

    if (selectedSubjectId == null) {

      showMessage(
        "Please select subject",
      );

      return;

    }

    if (titleController.text.trim().isEmpty) {

      showMessage(
        "Please enter assignment title",
      );

      return;

    }

    if (descController.text.trim().isEmpty) {

      showMessage(
        "Please enter assignment description",
      );

      return;

    }

    if (selectedDate == null) {

      showMessage(
        "Please choose due date",
      );

      return;

    }

    final section =
    sections.firstWhere(
          (s) =>
      s["id"].toString() ==
          selectedSectionId,
    );

    final subject =
    subjects.firstWhere(
          (s) =>
      s["id"].toString() ==
          selectedSubjectId,
    );

    setState(() {

      assignments.add({

        "section_id":
        selectedSectionId,

        "section_name":
        "${section["grade_name"]} - ${section["section_name"]}",

        "subject_id":
        selectedSubjectId,

        "subject_name":
        subject["name"],

        "title":
        titleController.text.trim(),

        "description":
        descController.text.trim(),

        "due_date":
        selectedDate,

      });

      titleController.clear();

      descController.clear();

      selectedDate = null;

      selectedSectionId = null;

      selectedSubjectId = null;

    });

    showMessage(
      "Assignment added successfully",
    );

  }

  // =====================================
  // EDIT ASSIGNMENT
  // =====================================

  void editAssignment(int index) {

    final item =
    assignments[index];

    setState(() {

      selectedSectionId =
      item["section_id"];

      selectedSubjectId =
      item["subject_id"];

      titleController.text =
      item["title"];

      descController.text =
      item["description"];

      selectedDate =
      item["due_date"];

      assignments.removeAt(index);

    });

  }

  // =====================================
  // SEND ASSIGNMENTS
  // =====================================

  Future<void> submitAssignments() async {

    if (assignments.isEmpty) {

      showMessage(
        "No assignments to send",
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
          "Teacher not found",
        );

        return;

      }

      for (var assignment
      in assignments) {

        final response =
        await http.post(

          Uri.parse(
            Api.teacherAddAssignment,
          ),

          headers: {

            "Content-Type":
            "application/json",

          },

          body: jsonEncode({

            "teacher_id":
            teacherId,

            "section_id":
            assignment["section_id"],

            "subject_id":
            assignment["subject_id"],

            "title":
            assignment["title"],

            "description":
            assignment["description"],

            "due_date":
            DateFormat(
              "yyyy-MM-dd",
            ).format(
              assignment["due_date"],
            ),

          }),

        );

        final data =
        jsonDecode(response.body);

        if (response.statusCode != 200 ||
            data["success"] != true) {

          showMessage(
            data["message"] ??
                "Failed to send assignments",
          );

          return;

        }

      }

      showMessage(
        "Assignments sent successfully",
      );

      setState(() {

        assignments.clear();

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

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
      AppColors.background,

      appBar: AppBar(

        title: const Text(
          "Assignments Management",
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

          : sections.isEmpty

          ? const Center(

        child: Column(

          mainAxisAlignment:
          MainAxisAlignment.center,

          children: [

            Icon(

              Icons.groups_2_outlined,

              size: 70,

              color: Colors.grey,

            ),

            SizedBox(height: 16),

            Text(
              "No sections assigned to this teacher",
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
                    // SECTION
                    // =====================

                    DropdownButtonFormField<
                        String>(

                      initialValue:
                      selectedSectionId,

                      hint: const Text(
                        "Select Section",
                      ),

                      items:
                      sections.map((s) {

                        return DropdownMenuItem<
                            String>(

                          value:
                          s["id"]
                              .toString(),

                          child: Text(

                            "${s["grade_name"]} - ${s["section_name"]}",

                          ),

                        );

                      }).toList(),

                      onChanged: (val) {

                        setState(() {

                          selectedSectionId =
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
                        "Assignment Title",

                        border:
                        OutlineInputBorder(),

                      ),

                    ),

                    const SizedBox(
                      height: 12,
                    ),

                    // =====================
                    // DESCRIPTION
                    // =====================

                    TextField(

                      controller:
                      descController,

                      maxLines: 3,

                      decoration:
                      const InputDecoration(

                        labelText:
                        "Assignment Description",

                        border:
                        OutlineInputBorder(),

                      ),

                    ),

                    const SizedBox(
                      height: 12,
                    ),

                    // =====================
                    // DATE
                    // =====================

                    Row(

                      children: [

                        Expanded(

                          child: Text(

                            selectedDate == null

                                ? "Choose due date"

                                : DateFormat(
                              "yyyy-MM-dd",
                            ).format(
                              selectedDate!,
                            ),

                          ),

                        ),

                        TextButton(

                          onPressed:
                          pickDate,

                          child: const Text(
                            "Choose",
                          ),

                        ),

                      ],

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
                        addAssignment,

                        child: const Text(
                          "Add Assignment",
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

              child:
              assignments.isEmpty

                  ? const Center(
                child: Text(
                  "No assignments added yet",
                ),
              )

                  : ListView.builder(

                itemCount:
                assignments.length,

                itemBuilder:
                    (_, i) {

                  final a =
                  assignments[i];

                  return Card(

                    margin:
                    const EdgeInsets.only(
                      bottom: 10,
                    ),

                    child: ListTile(

                      leading: CircleAvatar(

                        backgroundColor:
                        AppColors.primary,

                        child: const Icon(

                          Icons.assignment,

                          color:
                          Colors.white,

                        ),

                      ),

                      title: Text(
                        a["title"],
                      ),

                      subtitle: Text(

                        "${a["section_name"]}\n"
                            "${a["subject_name"]}\n"
                            "Due: ${DateFormat("yyyy-MM-dd").format(a["due_date"])}",

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

                          editAssignment(i);

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

            if (assignments.isNotEmpty)

              SizedBox(

                width:
                double.infinity,

                height: 55,

                child:
                ElevatedButton.icon(

                  onPressed:
                  isSubmitting

                      ? null

                      : submitAssignments,

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

                        : "Send Assignments",

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