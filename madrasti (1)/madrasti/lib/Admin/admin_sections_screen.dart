import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../General/app_colors.dart';
import '../api.dart';

class AdminSectionsScreen extends StatefulWidget {

  const AdminSectionsScreen({super.key});

  @override
  State<AdminSectionsScreen> createState() =>
      _AdminSectionsScreenState();

}

class _AdminSectionsScreenState
    extends State<AdminSectionsScreen> {

  // =====================================
  // CONTROLLERS
  // =====================================

  final TextEditingController
  sectionController =
  TextEditingController();

  // =====================================
  // DATA
  // =====================================

  List grades = [];

  List teachers = [];

  List subjects = [];

  List sections = [];

  bool isLoading = true;

  bool isSaving = false;

  String errorMessage = "";

  // =====================================
  // SELECTED VALUES
  // =====================================

  String? selectedGradeId;

  String? selectedTeacherId;

  String? selectedSubjectId;

  // =====================================
  // INIT
  // =====================================

  @override
  void initState() {

    super.initState();

    initialize();

  }

  // =====================================
  // INITIALIZE
  // =====================================

  Future<void> initialize() async {

    try {

      setState(() {

        isLoading = true;

      });

      await Future.wait([

        getGrades(),

        getTeachers(),

        getSubjects(),

        getSections(),

      ]);

      setState(() {

        isLoading = false;

      });

    }

    catch (e) {

      setState(() {

        errorMessage =
        "Failed to load data";

        isLoading = false;

      });

    }

  }

  // =====================================
  // GET SECTIONS
  // =====================================

  Future<void> getSections() async {

    final response =
    await http.get(

      Uri.parse(
        Api.adminSections,
      ),

    );

    final data =
    jsonDecode(response.body);

    if (response.statusCode == 200 &&
        data["success"] == true) {

      sections =
          data["sections"] ?? [];

    }

  }

  // =====================================
  // GET GRADES
  // =====================================

  Future<void> getGrades() async {

    final response =
    await http.get(

      Uri.parse(
        Api.adminGrades,
      ),

    );

    final data =
    jsonDecode(response.body);

    if (response.statusCode == 200 &&
        data["success"] == true) {

      grades =
          data["grades"] ?? [];

    }

  }

  // =====================================
  // GET TEACHERS
  // =====================================

  Future<void> getTeachers() async {

    final response =
    await http.get(

      Uri.parse(
        Api.adminSectionTeachers,
      ),

    );

    final data =
    jsonDecode(response.body);

    if (response.statusCode == 200 &&
        data["success"] == true) {

      teachers =
          data["teachers"] ?? [];

    }

  }

  // =====================================
  // GET SUBJECTS
  // =====================================

  Future<void> getSubjects() async {

    final response =
    await http.get(

      Uri.parse(
        Api.adminSubjects,
      ),

    );

    final data =
    jsonDecode(response.body);

    if (response.statusCode == 200 &&
        data["success"] == true) {

      subjects =
          data["subjects"] ?? [];

    }

  }

  // =====================================
  // CREATE SECTION
  // =====================================

  Future<void> createSection() async {

    if (sectionController.text
        .trim()
        .isEmpty) {

      return;

    }

    try {

      setState(() {

        isSaving = true;

      });

      final response =
      await http.post(

        Uri.parse(
          Api.adminCreateSection,
        ),

        headers: {

          "Content-Type":
          "application/json",

        },

        body: jsonEncode({

          "grade_id":
          selectedGradeId,

          "section_name":
          sectionController.text.trim(),

          "teacher_id":
          selectedTeacherId,

          "subject_id":
          selectedSubjectId,

        }),

      );

      final data =
      jsonDecode(response.body);

      if (response.statusCode == 200 &&
          data["success"] == true) {

        Navigator.pop(context);

        sectionController.clear();

        await getSections();

        setState(() {});

      }

    }

    catch (e) {

      debugPrint(e.toString());

    }

    finally {

      setState(() {

        isSaving = false;

      });

    }

  }

  // =====================================
  // DELETE SECTION
  // =====================================

  Future<void> deleteSection(
      String sectionId,
      ) async {

    try {

      final response =
      await http.delete(

        Uri.parse(
          "${Api.adminDeleteSection}/$sectionId",
        ),

      );

      final data =
      jsonDecode(response.body);

      if (response.statusCode == 200 &&
          data["success"] == true) {

        await getSections();

        setState(() {});

      }

    }

    catch (e) {

      debugPrint(e.toString());

    }

  }

  // =====================================
  // DIALOG
  // =====================================

  void showAddDialog() {

    showDialog(

      context: context,

      builder: (_) {

        return AlertDialog(

          title:
          const Text(
            "Add Section",
          ),

          content:
          SingleChildScrollView(

            child: Column(

              mainAxisSize:
              MainAxisSize.min,

              children: [

                DropdownButtonFormField<String>(

                  decoration:
                  const InputDecoration(

                    labelText:
                    "Grade",

                  ),

                  items:
                  grades.map((g) {

                    return DropdownMenuItem(

                      value:
                      g["id"].toString(),

                      child:
                      Text(g["name"]),

                    );

                  }).toList(),

                  onChanged: (v) {

                    selectedGradeId = v;

                  },

                ),

                const SizedBox(height: 14),

                TextField(

                  controller:
                  sectionController,

                  decoration:
                  const InputDecoration(

                    labelText:
                    "Section Name",

                  ),

                ),

                const SizedBox(height: 14),

                DropdownButtonFormField<String>(

                  decoration:
                  const InputDecoration(

                    labelText:
                    "Teacher",

                  ),

                  items:
                  teachers.map((t) {

                    return DropdownMenuItem(

                      value:
                      t["id"].toString(),

                      child:
                      Text(t["name"]),

                    );

                  }).toList(),

                  onChanged: (v) {

                    selectedTeacherId = v;

                  },

                ),

                const SizedBox(height: 14),

                DropdownButtonFormField<String>(

                  decoration:
                  const InputDecoration(

                    labelText:
                    "Subject",

                  ),

                  items:
                  subjects.map((s) {

                    return DropdownMenuItem(

                      value:
                      s["id"].toString(),

                      child:
                      Text(s["name"]),

                    );

                  }).toList(),

                  onChanged: (v) {

                    selectedSubjectId = v;

                  },

                ),

              ],

            ),

          ),

          actions: [

            TextButton(

              onPressed: () {

                Navigator.pop(context);

              },

              child:
              const Text("Cancel"),

            ),

            ElevatedButton(

              onPressed:
              isSaving
                  ? null
                  : createSection,

              child:
              isSaving

                  ? const CircularProgressIndicator()

                  : const Text("Create"),

            ),

          ],

        );

      },

    );

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
      AppColors.background,

      appBar: AppBar(

        title:
        const Text(
          "Sections Management",
        ),

        backgroundColor:
        AppColors.primary,

        foregroundColor:
        Colors.white,

      ),

      floatingActionButton:
      FloatingActionButton(

        backgroundColor:
        AppColors.primary,

        onPressed:
        showAddDialog,

        child:
        const Icon(Icons.add),

      ),

      body:
      isLoading

          ? const Center(
        child:
        CircularProgressIndicator(),
      )

          : errorMessage
          .isNotEmpty

          ? Center(
        child:
        Text(errorMessage),
      )

          : ListView.builder(

        padding:
        const EdgeInsets.all(16),

        itemCount:
        sections.length,

        itemBuilder:
            (_, index) {

          final section =
          sections[index];

          return Card(

            margin:
            const EdgeInsets.only(
              bottom: 14,
            ),

            child: ListTile(

              leading:
              CircleAvatar(

                backgroundColor:
                AppColors.primary
                    .withOpacity(0.1),

                child: const Icon(

                  Icons.group,

                  color:
                  AppColors.primary,

                ),

              ),

              title: Text(

                "Section ${section["section_name"]}",

              ),

              subtitle: Column(

                crossAxisAlignment:
                CrossAxisAlignment.start,

                children: [

                  Text(

                    "Grade: ${section["grade_name"]}",

                  ),

                  Text(

                    "Teacher: ${section["teacher_name"]}",

                  ),

                  Text(

                    "Subject: ${section["subject_name"]}",

                  ),

                ],

              ),

              trailing:
              IconButton(

                onPressed: () {

                  deleteSection(

                    section["id"]
                        .toString(),

                  );

                },

                icon: const Icon(

                  Icons.delete,

                  color: Colors.red,

                ),

              ),

            ),

          );

        },

      ),

    );

  }

}