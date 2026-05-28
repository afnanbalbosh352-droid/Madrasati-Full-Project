import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../General/app_colors.dart';
import '../api.dart';

class AdminTeachersScreen extends StatefulWidget {

  const AdminTeachersScreen({
    super.key,
  });

  @override
  State<AdminTeachersScreen> createState() =>
      _AdminTeachersScreenState();

}

class _AdminTeachersScreenState
    extends State<AdminTeachersScreen> {

  // =====================================
  // CONSTANTS
  // =====================================

  static const String allValue =
      "__ALL__";

  // =====================================
  // CONTROLLERS
  // =====================================

  final TextEditingController
  nameController =
  TextEditingController();

  final TextEditingController
  nationalIdController =
  TextEditingController();

  // =====================================
  // DATA
  // =====================================

  List teachers = [];

  List sections = [];

  List subjects = [];

  bool isLoading = true;

  bool isSaving = false;

  String errorMessage = "";

  // =====================================
  // FILTERS
  // =====================================

  String? selectedGrade =
      allValue;

  String? selectedSectionId =
      allValue;

  // =====================================
  // FORM
  // =====================================

  String? formSectionId;

  String? formSubjectId;

  // =====================================
  // INIT
  // =====================================

  @override
  void initState() {

    super.initState();

    loadData();

  }

  // =====================================
  // DISPOSE
  // =====================================

  @override
  void dispose() {

    nameController.dispose();

    nationalIdController.dispose();

    super.dispose();

  }

  // =====================================
  // SAFE
  // =====================================

  String safe(dynamic value) {

    if (value == null) {

      return "";

    }

    return value.toString();

  }

  // =====================================
  // LOAD DATA
  // =====================================

  Future<void> loadData() async {

    try {

      setState(() {

        isLoading = true;

        errorMessage = "";

      });

      final teachersResponse =
      await http.get(

        Uri.parse(
          Api.adminTeachers,
        ),

      );

      final sectionsResponse =
      await http.get(

        Uri.parse(
          Api.adminSections,
        ),

      );

      final subjectsResponse =
      await http.get(

        Uri.parse(
          Api.adminSubjects,
        ),

      );

      debugPrint(
        teachersResponse.body,
      );

      debugPrint(
        sectionsResponse.body,
      );

      debugPrint(
        subjectsResponse.body,
      );

      final teachersData =
      jsonDecode(
        teachersResponse.body,
      );

      final sectionsData =
      jsonDecode(
        sectionsResponse.body,
      );

      final subjectsData =
      jsonDecode(
        subjectsResponse.body,
      );

      if (

      teachersResponse.statusCode == 200 &&

          sectionsResponse.statusCode == 200 &&

          subjectsResponse.statusCode == 200 &&

          teachersData["success"] == true &&

          sectionsData["success"] == true &&

          subjectsData["success"] == true

      ) {

        teachers =
            teachersData["teachers"] ?? [];

        sections =
            sectionsData["sections"] ?? [];

        subjects =
            subjectsData["subjects"] ?? [];

        setState(() {

          isLoading = false;

        });

      }

      else {

        setState(() {

          errorMessage =
          "Failed to load data";

          isLoading = false;

        });

      }

    }

    catch (e) {

      debugPrint(
        e.toString(),
      );

      setState(() {

        errorMessage =
        "Error loading teachers";

        isLoading = false;

      });

    }

  }

  // =====================================
  // FILTERED TEACHERS
  // =====================================

  List get filteredTeachers {

    return teachers.where((teacher) {

      final gradeMatch =

          selectedGrade ==
              allValue ||

              safe(
                teacher["grade_name"],
              ) ==
                  selectedGrade;

      final sectionMatch =

          selectedSectionId ==
              allValue ||

              safe(
                teacher["section_id"],
              ) ==
                  selectedSectionId;

      return gradeMatch &&
          sectionMatch;

    }).toList();

  }

  // =====================================
  // CREATE TEACHER
  // =====================================

  Future<void> createTeacher() async {

    if (

    nameController.text
        .trim()
        .isEmpty ||

        nationalIdController.text
            .trim()
            .isEmpty ||

        formSectionId == null ||

        formSubjectId == null

    ) {

      showMessage(
        "Please fill all fields",
      );

      return;

    }

    try {

      setState(() {

        isSaving = true;

      });

      final response =
      await http.post(

        Uri.parse(
          Api.adminCreateTeacher,
        ),

        headers: {

          "Content-Type":
          "application/json",

        },

        body: jsonEncode({

          "full_name":
          nameController.text.trim(),

          "national_id":
          nationalIdController.text
              .trim(),

          "section_id":
          formSectionId,

          "subject_id":
          formSubjectId,

        }),

      );

      debugPrint(
        response.body,
      );

      final data =
      jsonDecode(response.body);

      if (

      response.statusCode == 200 &&

          data["success"] == true

      ) {

        Navigator.pop(context);

        showMessage(
          "Teacher added successfully",
        );

        await loadData();

      }

      else {

        showMessage(

          safe(
            data["message"],
          ),

        );

      }

    }

    catch (e) {

      debugPrint(
        e.toString(),
      );

      showMessage(
        "Error adding teacher",
      );

    }

    finally {

      setState(() {

        isSaving = false;

      });

    }

  }

  // =====================================
  // UPDATE TEACHER
  // =====================================

  Future<void> updateTeacher(
      String teacherId,
      ) async {

    try {

      setState(() {

        isSaving = true;

      });

      final response =
      await http.put(

        Uri.parse(

          "${Api.adminUpdateTeacher}/$teacherId",

        ),

        headers: {

          "Content-Type":
          "application/json",

        },

        body: jsonEncode({

          "full_name":
          nameController.text.trim(),

          "national_id":
          nationalIdController.text
              .trim(),

          "section_id":
          formSectionId,

          "subject_id":
          formSubjectId,

        }),

      );

      debugPrint(
        response.body,
      );

      final data =
      jsonDecode(response.body);

      if (

      response.statusCode == 200 &&

          data["success"] == true

      ) {

        Navigator.pop(context);

        showMessage(
          "Teacher updated successfully",
        );

        await loadData();

      }

      else {

        showMessage(

          safe(
            data["message"],
          ),

        );

      }

    }

    catch (e) {

      debugPrint(
        e.toString(),
      );

      showMessage(
        "Error updating teacher",
      );

    }

    finally {

      setState(() {

        isSaving = false;

      });

    }

  }

  // =====================================
  // DELETE TEACHER
  // =====================================

  Future<void> deleteTeacher(
      String teacherId,
      ) async {

    try {

      final response =
      await http.delete(

        Uri.parse(

          "${Api.adminDeleteTeacher}/$teacherId",

        ),

      );

      final data =
      jsonDecode(response.body);

      if (

      response.statusCode == 200 &&

          data["success"] == true

      ) {

        showMessage(
          "Teacher deleted successfully",
        );

        await loadData();

      }

      else {

        showMessage(

          safe(
            data["message"],
          ),

        );

      }

    }

    catch (e) {

      showMessage(
        "Error deleting teacher",
      );

    }

  }

  // =====================================
  // DIALOG
  // =====================================

  void showTeacherDialog({
    Map? teacher,
  }) {

    final isEdit =
        teacher != null;

    if (isEdit) {

      nameController.text =

          safe(
            teacher["full_name"],
          );

      nationalIdController.text =

          safe(
            teacher["national_id"],
          );

      formSectionId =

          safe(
            teacher["section_id"],
          );

      formSubjectId =

          safe(
            teacher["subject_id"],
          );

    }

    else {

      nameController.clear();

      nationalIdController.clear();

      formSectionId = null;

      formSubjectId = null;

    }

    showDialog(

      context: context,

      builder: (_) {

        return StatefulBuilder(

          builder:
              (_, setDialogState) {

            return AlertDialog(

              title: Text(

                isEdit
                    ? "Edit Teacher"
                    : "Add Teacher",

              ),

              content:
              SingleChildScrollView(

                child: Column(

                  mainAxisSize:
                  MainAxisSize.min,

                  children: [

                    TextField(

                      controller:
                      nameController,

                      decoration:
                      const InputDecoration(

                        labelText:
                        "Teacher Name",

                        border:
                        OutlineInputBorder(),

                      ),

                    ),

                    const SizedBox(
                      height: 12,
                    ),

                    TextField(

                      controller:
                      nationalIdController,

                      decoration:
                      const InputDecoration(

                        labelText:
                        "National ID",

                        border:
                        OutlineInputBorder(),

                      ),

                    ),

                    const SizedBox(
                      height: 12,
                    ),

                    DropdownButtonFormField<
                        String>(

                      initialValue:
                      formSectionId,

                      decoration:
                      const InputDecoration(

                        labelText:
                        "Section",

                        border:
                        OutlineInputBorder(),

                      ),

                      items:

                      sections.map(

                            (section) {

                          return DropdownMenuItem<

                              String>(

                            value:
                            safe(
                              section["id"],
                            ),

                            child:
                            Text(

                              "${safe(section["grade_name"])} - ${safe(section["name"])}",

                            ),

                          );

                        },

                      ).toList(),

                      onChanged:
                          (value) {

                        setDialogState(() {

                          formSectionId =
                              value;

                        });

                      },

                    ),

                    const SizedBox(
                      height: 12,
                    ),

                    DropdownButtonFormField<
                        String>(

                      initialValue:
                      formSubjectId,

                      decoration:
                      const InputDecoration(

                        labelText:
                        "Subject",

                        border:
                        OutlineInputBorder(),

                      ),

                      items:

                      subjects.map(

                            (subject) {

                          return DropdownMenuItem<

                              String>(

                            value:
                            safe(
                              subject["id"],
                            ),

                            child:
                            Text(

                              safe(
                                subject["name"],
                              ),

                            ),

                          );

                        },

                      ).toList(),

                      onChanged:
                          (value) {

                        setDialogState(() {

                          formSubjectId =
                              value;

                        });

                      },

                    ),

                  ],

                ),

              ),

              actions: [

                TextButton(

                  onPressed: () {

                    Navigator.pop(
                      context,
                    );

                  },

                  child: const Text(
                    "Cancel",
                  ),

                ),

                ElevatedButton(

                  onPressed:
                  isSaving

                      ? null

                      : () {

                    if (isEdit) {

                      updateTeacher(

                        safe(
                          teacher["id"],
                        ),

                      );

                    }

                    else {

                      createTeacher();

                    }

                  },

                  child:
                  isSaving

                      ? const SizedBox(

                    width: 20,

                    height: 20,

                    child:
                    CircularProgressIndicator(

                      strokeWidth: 2,

                      color:
                      Colors.white,

                    ),

                  )

                      : Text(

                    isEdit
                        ? "Save"
                        : "Add",

                  ),

                ),

              ],

            );

          },

        );

      },

    );

  }

  // =====================================
  // SNACKBAR
  // =====================================

  void showMessage(
      String message,
      ) {

    ScaffoldMessenger.of(context)
        .showSnackBar(

      SnackBar(

        content:
        Text(message),

      ),

    );

  }

  // =====================================
  // BUILD
  // =====================================

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
      AppColors.background,

      appBar: AppBar(

        title: const Text(
          "Teachers Management",
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

        onPressed: () {

          showTeacherDialog();

        },

        child: const Icon(
          Icons.add,
        ),

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

        child: Text(
          errorMessage,
        ),

      )

          : Padding(

        padding:
        const EdgeInsets.all(
          16,
        ),

        child: Column(

          children: [

            // =====================================
            // FILTERS
            // =====================================

            Row(

              children: [

                Expanded(

                  child:
                  DropdownButtonFormField<String>(

                    initialValue:

                    (
                        {

                          allValue,

                          ...sections
                              .map(
                                (e) => safe(
                              e["grade_name"],
                            ),
                          )

                        }.contains(
                          selectedGrade,
                        )

                    )

                        ? selectedGrade
                        : allValue,

                    decoration:
                    const InputDecoration(

                      labelText:
                      "Grade",

                      border:
                      OutlineInputBorder(),

                    ),

                    items: [

                      const DropdownMenuItem(

                        value:
                        allValue,

                        child:
                        Text(
                          "All Grades",
                        ),

                      ),

                      ...sections

                          .map(

                            (e) => safe(
                          e["grade_name"],
                        ),

                      )

                          .where(
                            (e) => e.isNotEmpty,
                      )

                          .toSet()

                          .map(

                            (grade) {

                          return DropdownMenuItem(

                            value:
                            grade,

                            child:
                            Text(grade),

                          );

                        },

                      ),

                    ],

                    onChanged:
                        (value) {

                      setState(() {

                        selectedGrade =
                            value;

                        selectedSectionId =
                            allValue;

                      });

                    },

                  ),

                ),

                const SizedBox(
                  width: 12,
                ),

                Expanded(

                  child:
                  DropdownButtonFormField<String>(

                    initialValue:

                    (
                        {

                          allValue,

                          ...sections

                              .where(

                                (section) {

                              if (
                              selectedGrade ==
                                  allValue
                              ) {

                                return true;

                              }

                              return safe(

                                section[
                                "grade_name"],

                              ) ==
                                  selectedGrade;

                            },

                          )

                              .map(
                                (e) => safe(
                              e["id"],
                            ),
                          )

                        }.contains(
                          selectedSectionId,
                        )

                    )

                        ? selectedSectionId
                        : allValue,

                    decoration:
                    const InputDecoration(

                      labelText:
                      "Section",

                      border:
                      OutlineInputBorder(),

                    ),

                    items: [

                      const DropdownMenuItem(

                        value:
                        allValue,

                        child:
                        Text(
                          "All Sections",
                        ),

                      ),

                      ...sections

                          .where(

                            (section) {

                          if (
                          selectedGrade ==
                              allValue
                          ) {

                            return true;

                          }

                          return safe(

                            section[
                            "grade_name"],

                          ) ==
                              selectedGrade;

                        },

                      )

                          .map(

                            (section) {

                          return DropdownMenuItem(

                            value:
                            safe(
                              section["id"],
                            ),

                            child:
                            Text(

                              "${safe(section["grade_name"])} - ${safe(section["name"])}",

                            ),

                          );

                        },

                      ),

                    ],

                    onChanged:
                        (value) {

                      setState(() {

                        selectedSectionId =
                            value;

                      });

                    },

                  ),

                ),

              ],

            ),

            const SizedBox(
              height: 20,
            ),

            // =====================================
            // LIST
            // =====================================

            Expanded(

              child:

              filteredTeachers.isEmpty

                  ? const Center(

                child: Text(
                  "No teachers found",
                ),

              )

                  : ListView.builder(

                itemCount:
                filteredTeachers.length,

                itemBuilder:
                    (_, index) {

                  final teacher =
                  filteredTeachers[index];

                  return Card(

                    margin:
                    const EdgeInsets.only(
                      bottom: 12,
                    ),

                    shape:
                    RoundedRectangleBorder(

                      borderRadius:
                      BorderRadius.circular(
                        14,
                      ),

                    ),

                    child: ListTile(

                      contentPadding:
                      const EdgeInsets.all(
                        12,
                      ),

                      leading:
                      CircleAvatar(

                        radius: 28,

                        backgroundColor:
                        AppColors.primary
                            .withOpacity(
                          0.1,
                        ),

                        child: Text(

                          safe(
                            teacher[
                            "full_name"],
                          ).isNotEmpty

                              ? safe(
                            teacher[
                            "full_name"],
                          ).substring(
                            0,
                            1,
                          )

                              : "?",

                          style:
                          const TextStyle(

                            color:
                            AppColors.primary,

                            fontWeight:
                            FontWeight.bold,

                            fontSize: 20,

                          ),

                        ),

                      ),

                      title: Text(

                        safe(
                          teacher[
                          "full_name"],
                        ),

                        style:
                        const TextStyle(

                          fontWeight:
                          FontWeight.bold,

                        ),

                      ),

                      subtitle:
                      Padding(

                        padding:
                        const EdgeInsets.only(
                          top: 8,
                        ),

                        child: Column(

                          crossAxisAlignment:
                          CrossAxisAlignment.start,

                          children: [

                            Text(

                              "Subject: ${safe(teacher["subject_name"])}",

                            ),

                            const SizedBox(
                              height: 4,
                            ),

                            Text(

                              "Grade: ${safe(teacher["grade_name"])}",

                            ),

                            const SizedBox(
                              height: 4,
                            ),

                            Text(

                              "Section: ${safe(teacher["section_name"])}",

                            ),

                            const SizedBox(
                              height: 4,
                            ),

                            Text(

                              "National ID: ${safe(teacher["national_id"])}",

                            ),

                          ],

                        ),

                      ),

                      trailing:
                      Column(

                        mainAxisAlignment:
                        MainAxisAlignment.center,

                        children: [

                          IconButton(

                            onPressed: () {

                              showTeacherDialog(
                                teacher: teacher,
                              );

                            },

                            icon:
                            const Icon(

                              Icons.edit,

                              color:
                              Colors.blue,

                            ),

                          ),

                          IconButton(

                            onPressed: () {

                              deleteTeacher(

                                safe(
                                  teacher["id"],
                                ),

                              );

                            },

                            icon:
                            const Icon(

                              Icons.delete,

                              color:
                              Colors.red,

                            ),

                          ),

                        ],

                      ),

                    ),

                  );

                },

              ),

            ),

          ],

        ),

      ),

    );

  }

}