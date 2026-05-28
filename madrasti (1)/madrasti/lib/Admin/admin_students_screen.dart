import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../General/app_colors.dart';
import '../api.dart';

class AdminStudentsScreen extends StatefulWidget {

  const AdminStudentsScreen({
    super.key,
  });

  @override
  State<AdminStudentsScreen> createState() =>
      _AdminStudentsScreenState();

}

class _AdminStudentsScreenState
    extends State<AdminStudentsScreen> {

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

  List students = [];

  List sections = [];

  bool isLoading = true;

  bool isSaving = false;

  String errorMessage = "";

  // =====================================
  // FILTERS
  // =====================================

  String? selectedGrade;

  String? selectedSectionId;

  String? formSectionId;

  // =====================================
  // INIT
  // =====================================

  @override
  void initState() {

    super.initState();

    loadData();

  }

  // =====================================
  // SAFE STRING
  // =====================================

  String safe(dynamic value) {

    if (value == null) {

      return "";

    }

    return value.toString();

  }

  // =====================================
  // GET SECTION NAME
  // =====================================

  String getSectionName(Map section) {

    if (section["section_name"] != null) {

      return safe(
        section["section_name"],
      );

    }

    return safe(
      section["name"],
    );

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

      final sectionsResponse =
      await http.get(

        Uri.parse(
          Api.adminSections,
        ),

      );

      final studentsResponse =
      await http.get(

        Uri.parse(
          Api.adminStudents,
        ),

      );

      debugPrint(
        sectionsResponse.body,
      );

      debugPrint(
        studentsResponse.body,
      );

      final sectionsData =
      jsonDecode(
        sectionsResponse.body,
      );

      final studentsData =
      jsonDecode(
        studentsResponse.body,
      );

      if (

      sectionsResponse.statusCode == 200 &&

          studentsResponse.statusCode == 200 &&

          sectionsData["success"] == true &&

          studentsData["success"] == true

      ) {

        sections =
            sectionsData["sections"] ?? [];

        students =
            studentsData["students"] ?? [];

        if (sections.isNotEmpty) {

          selectedGrade =

              safe(
                sections.first["grade_name"],
              );

          selectedSectionId =

              safe(
                sections.first["id"],
              );

        }

      }

      else {

        errorMessage =
        "Failed loading data";

      }

    }

    catch (e) {

      debugPrint(
        "LOAD ERROR => $e",
      );

      errorMessage =
      "Error loading students";

    }

    finally {

      setState(() {

        isLoading = false;

      });

    }

  }

  // =====================================
  // FILTERED STUDENTS
  // =====================================

  List get filteredStudents {

    if (
    selectedGrade == null &&
        selectedSectionId == null
    ) {

      return students;

    }

    return students.where((student) {

      bool gradeMatch = true;

      if (selectedGrade != null) {

        gradeMatch =

            safe(
              student["grade_name"],
            ) ==
                selectedGrade;

      }

      Map? selectedSection;

      try {

        selectedSection =
            sections.firstWhere(

                  (section) {

                return safe(
                  section["id"],
                ) ==
                    selectedSectionId;

              },

            );

      }

      catch (e) {

        selectedSection = null;

      }

      final selectedSectionName =

      selectedSection != null

          ? getSectionName(
        selectedSection,
      )

          : "";

      bool sectionMatch = true;

      if (selectedSectionId != null) {

        sectionMatch =

            safe(
              student["section_id"],
            ) ==
                selectedSectionId ||

                safe(
                  student["section_name"],
                ) ==
                    selectedSectionName ||

                safe(
                  student["section"],
                ) ==
                    selectedSectionName;

      }

      return gradeMatch &&
          sectionMatch;

    }).toList();

  }

  // =====================================
  // CREATE STUDENT
  // =====================================

  Future<void> createStudent() async {

    if (

    nameController.text
        .trim()
        .isEmpty ||

        nationalIdController.text
            .trim()
            .isEmpty ||

        formSectionId == null ||

        formSectionId!.isEmpty

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
          Api.adminCreateStudent,
        ),

        headers: {

          "Content-Type":
          "application/json",

        },

        body: jsonEncode({

          "full_name":
          nameController.text.trim(),

          "national_id":
          nationalIdController.text.trim(),

          "section_id":
          formSectionId,

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

        if (mounted) {

          Navigator.pop(context);

        }

        showMessage(
          "Student added successfully",
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
        "CREATE ERROR => $e",
      );

      showMessage(
        "Error adding student",
      );

    }

    finally {

      setState(() {

        isSaving = false;

      });

    }

  }

  // =====================================
  // UPDATE STUDENT
  // =====================================

  Future<void> updateStudent(
      String studentId,
      ) async {

    if (

    nameController.text
        .trim()
        .isEmpty ||

        nationalIdController.text
            .trim()
            .isEmpty ||

        formSectionId == null ||

        formSectionId!.isEmpty

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

      debugPrint(
        "UPDATE ID => $studentId",
      );

      final response =
      await http.put(

        Uri.parse(

          "${Api.adminUpdateStudent}/$studentId",

        ),

        headers: {

          "Content-Type":
          "application/json",

        },

        body: jsonEncode({

          "full_name":
          nameController.text.trim(),

          "national_id":
          nationalIdController.text.trim(),

          "section_id":
          formSectionId,

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

        if (mounted) {

          Navigator.pop(context);

        }

        showMessage(
          "Student updated successfully",
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
        "UPDATE ERROR => $e",
      );

      showMessage(
        "Error updating student",
      );

    }

    finally {

      setState(() {

        isSaving = false;

      });

    }

  }

  // =====================================
  // DELETE STUDENT
  // =====================================

  Future<void> deleteStudent(
      String studentId,
      ) async {

    try {

      final response =
      await http.delete(

        Uri.parse(

          "${Api.adminDeleteStudent}/$studentId",

        ),

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

        showMessage(
          "Student deleted successfully",
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
        "DELETE ERROR => $e",
      );

      showMessage(
        "Error deleting student",
      );

    }

  }

  // =====================================
  // DIALOG
  // =====================================

  void showStudentDialog({
    Map? student,
  }) {

    final isEdit =
        student != null;

    if (isEdit) {

      nameController.text =

          safe(
            student["full_name"],
          );

      nationalIdController.text =

          safe(
            student["national_id"],
          );

      formSectionId =

          safe(
            student["section_id"],
          );

      if (formSectionId!.isEmpty) {

        formSectionId =
            selectedSectionId;

      }

    }

    else {

      nameController.clear();

      nationalIdController.clear();

      formSectionId =
          selectedSectionId;

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
                    ? "Edit Student"
                    : "Add Student",

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
                        "Student Name",

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

                      ),

                    ),

                    const SizedBox(
                      height: 12,
                    ),

                    DropdownButtonFormField<String>(

                      initialValue:

                      sections.any(

                            (section) {

                          return safe(
                            section["id"],
                          ) ==
                              formSectionId;

                        },

                      )

                          ? formSectionId

                          : null,

                      decoration:
                      const InputDecoration(

                        labelText:
                        "Section",

                      ),

                      items:
                      sections.map(

                            (section) {

                          return DropdownMenuItem<String>(

                            value:
                            safe(
                              section["id"],
                            ),

                            child:
                            Text(

                              "${safe(section["grade_name"])} - ${getSectionName(section)}",

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

                  child:
                  const Text(
                    "Cancel",
                  ),

                ),

                ElevatedButton(

                  onPressed:
                  isSaving

                      ? null

                      : () {

                    if (isEdit) {

                      updateStudent(

                        safe(
                          student["id"],
                        ),

                      );

                    }

                    else {

                      createStudent();

                    }

                  },

                  child:
                  isSaving

                      ? const SizedBox(

                    width: 18,

                    height: 18,

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
  // MESSAGE
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

        title:
        const Text(
          "Students Management",
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

          showStudentDialog();

        },

        child:
        const Icon(
          Icons.add,
        ),

      ),

      body:

      isLoading

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

            const SizedBox(
              height: 16,
            ),

            Text(
              errorMessage,
            ),

            const SizedBox(
              height: 20,
            ),

            ElevatedButton(

              onPressed:
              loadData,

              child:
              const Text(
                "Retry",
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

            // =====================================
            // FILTERS
            // =====================================

            Row(

              children: [

                Expanded(

                  child:
                  DropdownButtonFormField<String>(

                    initialValue:
                    selectedGrade,

                    decoration:
                    const InputDecoration(

                      labelText:
                      "Grade",

                    ),

                    items:
                    sections

                        .where(

                          (section) {

                        return section[
                        "grade_name"] !=
                            null;

                      },

                    )

                        .map<String>(

                          (section) {

                        return safe(
                          section["grade_name"],
                        );

                      },

                    )

                        .toSet()

                        .map(

                          (grade) {

                        return DropdownMenuItem<String>(

                          value:
                          grade,

                          child:
                          Text(grade),

                        );

                      },

                    ).toList(),

                    onChanged:
                        (value) {

                      setState(() {

                        selectedGrade =
                            value;

                        final filteredSections =

                        sections.where(

                              (section) {

                            return safe(

                              section[
                              "grade_name"],

                            ) == value;

                          },

                        ).toList();

                        if (
                        filteredSections
                            .isNotEmpty
                        ) {

                          selectedSectionId =

                              safe(

                                filteredSections
                                    .first["id"],

                              );

                        }

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
                    sections.any(

                          (section) {

                        return safe(
                          section["id"],
                        ) ==
                            selectedSectionId;

                      },

                    )

                        ? selectedSectionId

                        : null,

                    decoration:
                    const InputDecoration(

                      labelText:
                      "Section",

                    ),

                    items:
                    sections.where(

                          (section) {

                        return safe(

                          section[
                          "grade_name"],

                        ) ==
                            selectedGrade;

                      },

                    ).map(

                          (section) {

                        return DropdownMenuItem<String>(

                          value:
                          safe(
                            section["id"],
                          ),

                          child:
                          Text(

                            getSectionName(
                              section,
                            ),

                          ),

                        );

                      },

                    ).toList(),

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
            // STUDENTS
            // =====================================

            Expanded(

              child:
              filteredStudents.isEmpty

                  ? const Center(

                child: Text(
                  "No students found",
                ),

              )

                  : ListView.builder(

                itemCount:
                filteredStudents.length,

                itemBuilder:
                    (_, index) {

                  final student =
                  filteredStudents[index];

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

                    child:
                    ListTile(

                      leading:
                      CircleAvatar(

                        backgroundColor:
                        AppColors.primary
                            .withOpacity(
                          0.1,
                        ),

                        child:
                        Text(

                          safe(
                            student[
                            "full_name"],
                          ).isNotEmpty

                              ? safe(
                            student[
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

                          ),

                        ),

                      ),

                      title:
                      Text(

                        safe(
                          student[
                          "full_name"],
                        ),

                      ),

                      subtitle:
                      Text(

                        "ID: ${safe(student["national_id"])}",

                      ),

                      trailing:
                      Row(

                        mainAxisSize:
                        MainAxisSize.min,

                        children: [

                          IconButton(

                            onPressed: () {

                              showStudentDialog(
                                student:
                                student,
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

                              deleteStudent(

                                safe(
                                  student[
                                  "id"],
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