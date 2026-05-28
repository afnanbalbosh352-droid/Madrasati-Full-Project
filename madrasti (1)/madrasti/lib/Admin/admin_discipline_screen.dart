import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../General/app_colors.dart';
import '../api.dart';

class AdminPenaltiesScreen extends StatefulWidget {

  const AdminPenaltiesScreen({
    super.key,
  });

  @override
  State<AdminPenaltiesScreen> createState() =>
      _AdminPenaltiesScreenState();

}

class _AdminPenaltiesScreenState
    extends State<AdminPenaltiesScreen> {

  // =====================================
  // CONTROLLERS
  // =====================================

  final TextEditingController
  reasonController =
  TextEditingController();

  // =====================================
  // DATA
  // =====================================

  List grades = [];

  List sections = [];

  List students = [];

  List penaltyHistory = [];

  bool isLoading = true;

  bool isSubmitting = false;

  String errorMessage = "";

  // =====================================
  // SELECTED VALUES
  // =====================================

  String? selectedGradeId;

  String? selectedSectionId;

  String? selectedStudentId;

  String selectedType =
      "Warning";

  // =====================================
  // PENALTY TYPES
  // =====================================

  final List<Map<String, String>>
  penaltyTypes = [

    {
      "value": "Warning",
      "label": "Warning (تنبيه)",
    },

    {
      "value": "Final Warning",
      "label": "Final Warning (إنذار نهائي)",
    },

    {
      "value": "Suspension",
      "label": "Suspension (فصل مؤقت)",
    },

    {
      "value": "Transfer",
      "label": "Transfer (نقل من الصف)",
    },

  ];

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

    await getGrades();

    await getPenaltyHistory();

  }

  // =====================================
  // GET GRADES
  // =====================================

  Future<void> getGrades() async {

    try {

      setState(() {

        isLoading = true;

      });

      final response =
      await http.get(

        Uri.parse(
          Api.adminGrades,
        ),

      );

      final data =
      jsonDecode(
        response.body,
      );

      if (

      response.statusCode == 200 &&

          data["success"] == true

      ) {

        grades =
            data["grades"] ?? [];

        if (grades.isNotEmpty) {

          selectedGradeId =
              grades[0]["id"]
                  .toString();

          await getSections();

        }

      }

      else {

        setState(() {

          errorMessage =
              data["message"] ??
                  "Failed to load grades";

          isLoading = false;

        });

      }

    }

    catch (e) {

      setState(() {

        errorMessage =
        "Error loading grades";

        isLoading = false;

      });

    }

  }

  // =====================================
  // GET SECTIONS
  // =====================================

  Future<void> getSections() async {

    try {

      final response =
      await http.get(

        Uri.parse(
          Api.adminSections,
        ),

      );

      final data =
      jsonDecode(
        response.body,
      );

      if (

      response.statusCode == 200 &&

          data["success"] == true

      ) {

        final allSections =
            data["sections"] ?? [];

        sections =
            allSections.where((section) {

              return section["grade_level_id"]
                  .toString() ==
                  selectedGradeId;

            }).toList();

        if (sections.isNotEmpty) {

          selectedSectionId =
              sections[0]["id"]
                  .toString();

          await getStudents();

        }

      }

    }

    catch (e) {

      setState(() {

        errorMessage =
        "Error loading sections";

        isLoading = false;

      });

    }

  }

  // =====================================
  // GET STUDENTS
  // =====================================

  Future<void> getStudents() async {

    try {

      final response =
      await http.get(

        Uri.parse(
          Api.adminStudents,
        ),

      );

      final data =
      jsonDecode(
        response.body,
      );

      if (

      response.statusCode == 200 &&

          data["success"] == true

      ) {

        final allStudents =
            data["students"] ?? [];

        // =================================
        // GET SELECTED SECTION
        // =================================

        final selectedSection =
        sections.firstWhere(

              (section) {

            return section["id"]
                .toString() ==
                selectedSectionId;

          },

        );

        // =================================
        // FILTER STUDENTS
        // =================================

        students =
            allStudents.where((student) {

              return student["section_name"]
                  .toString() ==

                  selectedSection["name"]
                      .toString();

            }).toList();

        setState(() {

          isLoading = false;

        });

      }

    }

    catch (e) {

      setState(() {

        errorMessage =
        "Error loading students";

        isLoading = false;

      });

    }

  }

  // =====================================
  // GET HISTORY
  // =====================================

  Future<void>
  getPenaltyHistory() async {

    try {

      final response =
      await http.get(

        Uri.parse(
          Api.adminWarnings,
        ),

      );

      final data =
      jsonDecode(
        response.body,
      );

      if (

      response.statusCode == 200 &&

          data["success"] == true

      ) {

        setState(() {

          penaltyHistory =
              data["warnings"] ?? [];

        });

      }

    }

    catch (e) {

      debugPrint(
        e.toString(),
      );

    }

  }

  // =====================================
  // SUBMIT PENALTY
  // =====================================

  Future<void>
  submitPenalty() async {

    if (selectedStudentId == null) {

      showMessage(
        "Please select student",
      );

      return;

    }

    if (

    reasonController.text
        .trim()
        .isEmpty

    ) {

      showMessage(
        "Please enter reason",
      );

      return;

    }

    try {

      setState(() {

        isSubmitting = true;

      });

      final response =
      await http.post(

        Uri.parse(
          Api.adminAddWarning,
        ),

        headers: {

          "Content-Type":
          "application/json",

        },

        body: jsonEncode({

          "student_id":
          selectedStudentId,

          "admin_id":
          "60000000-0000-0000-0000-000000000001",

          "warning_type":
          selectedType,

          "reason":
          reasonController.text
              .trim(),

          "action_taken":
          "Pending",

        }),

      );

      final data =
      jsonDecode(
        response.body,
      );

      if (

      response.statusCode == 200 &&

          data["success"] == true

      ) {

        showMessage(
          "Penalty submitted successfully",
        );

        reasonController.clear();

        setState(() {

          selectedStudentId =
          null;

          selectedType =
          "Warning";

        });

        await getPenaltyHistory();

      }

      else {

        showMessage(

          data["message"] ??
              "Failed to submit penalty",

        );

      }

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

        title: const Text(
          "Penalties",
        ),

        centerTitle: true,

        backgroundColor:
        AppColors.primary,

        foregroundColor:
        Colors.white,

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

          : SingleChildScrollView(

        padding:
        const EdgeInsets.all(16),

        child: Column(

          crossAxisAlignment:
          CrossAxisAlignment.start,

          children: [

            const Text(

              "Issue New Penalty",

              style: TextStyle(

                fontSize: 18,

                fontWeight:
                FontWeight.bold,

              ),

            ),

            const SizedBox(height: 16),

            // =====================================
            // FORM CARD
            // =====================================

            Card(

              elevation: 4,

              shape:
              RoundedRectangleBorder(

                borderRadius:
                BorderRadius.circular(16),

              ),

              child: Padding(

                padding:
                const EdgeInsets.all(20),

                child: Column(

                  children: [

                    // =====================
                    // GRADE
                    // =====================

                    DropdownButtonFormField<String>(

                      initialValue:
                      selectedGradeId,

                      decoration:
                      const InputDecoration(

                        labelText:
                        "Grade",

                        border:
                        OutlineInputBorder(),

                      ),

                      items:
                      grades.map((g) {

                        return DropdownMenuItem(

                          value:
                          g["id"]
                              .toString(),

                          child:
                          Text(
                            g["name"],
                          ),

                        );

                      }).toList(),

                      onChanged:
                          (val) async {

                        setState(() {

                          selectedGradeId =
                              val;

                          selectedSectionId =
                          null;

                          selectedStudentId =
                          null;

                        });

                        await getSections();

                      },

                    ),

                    const SizedBox(height: 16),

                    // =====================
                    // SECTION
                    // =====================

                    DropdownButtonFormField<String>(

                      initialValue:
                      selectedSectionId,

                      decoration:
                      const InputDecoration(

                        labelText:
                        "Section",

                        border:
                        OutlineInputBorder(),

                      ),

                      items:
                      sections.map((s) {

                        return DropdownMenuItem(

                          value:
                          s["id"]
                              .toString(),

                          child:
                          Text(
                            s["name"],
                          ),

                        );

                      }).toList(),

                      onChanged:
                          (val) async {

                        setState(() {

                          selectedSectionId =
                              val;

                          selectedStudentId =
                          null;

                        });

                        await getStudents();

                      },

                    ),

                    const SizedBox(height: 16),

                    // =====================
                    // STUDENT
                    // =====================

                    DropdownButtonFormField<String>(

                      initialValue:
                      selectedStudentId,

                      decoration:
                      const InputDecoration(

                        labelText:
                        "Student",

                        prefixIcon:
                        Icon(Icons.person),

                        border:
                        OutlineInputBorder(),

                      ),

                      items:
                      students.map((s) {

                        return DropdownMenuItem(

                          value:
                          s["id"]
                              .toString(),

                          child:
                          Text(
                            s["full_name"],
                          ),

                        );

                      }).toList(),

                      onChanged:
                          (val) {

                        setState(() {

                          selectedStudentId =
                              val;

                        });

                      },

                    ),

                    const SizedBox(height: 16),

                    // =====================
                    // TYPE
                    // =====================

                    DropdownButtonFormField<String>(

                      initialValue:
                      selectedType,

                      decoration:
                      const InputDecoration(

                        labelText:
                        "Penalty Type",

                        prefixIcon:
                        Icon(Icons.gavel),

                        border:
                        OutlineInputBorder(),

                      ),

                      items:
                      penaltyTypes.map((t) {

                        return DropdownMenuItem(

                          value:
                          t["value"],

                          child:
                          Text(
                            t["label"]!,
                          ),

                        );

                      }).toList(),

                      onChanged:
                          (val) {

                        setState(() {

                          selectedType =
                          val!;

                        });

                      },

                    ),

                    const SizedBox(height: 16),

                    // =====================
                    // REASON
                    // =====================

                    TextField(

                      controller:
                      reasonController,

                      maxLines: 4,

                      decoration:
                      const InputDecoration(

                        labelText:
                        "Reason",

                        hintText:
                        "Enter penalty reason",

                        border:
                        OutlineInputBorder(),

                        alignLabelWithHint:
                        true,

                      ),

                    ),

                    const SizedBox(height: 24),

                    // =====================
                    // BUTTON
                    // =====================

                    SizedBox(

                      width:
                      double.infinity,

                      height: 55,

                      child:
                      ElevatedButton(

                        onPressed:

                        isSubmitting

                            ? null

                            : submitPenalty,

                        style:
                        ElevatedButton.styleFrom(

                          backgroundColor:
                          Colors.redAccent,

                          shape:
                          RoundedRectangleBorder(

                            borderRadius:
                            BorderRadius.circular(12),

                          ),

                        ),

                        child:

                        isSubmitting

                            ? const CircularProgressIndicator(
                          color:
                          Colors.white,
                        )

                            : const Text(

                          "Submit Penalty",

                          style: TextStyle(

                            color:
                            Colors.white,

                            fontWeight:
                            FontWeight.bold,

                            fontSize: 16,

                          ),

                        ),

                      ),

                    ),

                  ],

                ),

              ),

            ),

            const SizedBox(height: 30),

            // =====================================
            // HISTORY
            // =====================================

            const Text(

              "Recent Penalties History",

              style: TextStyle(

                fontSize: 18,

                fontWeight:
                FontWeight.bold,

              ),

            ),

            const SizedBox(height: 12),

            penaltyHistory.isEmpty

                ? const Center(

              child: Padding(

                padding:
                EdgeInsets.all(20),

                child:
                Text(
                  "No penalties found",
                ),

              ),

            )

                : ListView.builder(

              shrinkWrap: true,

              physics:
              const NeverScrollableScrollPhysics(),

              itemCount:
              penaltyHistory.length,

              itemBuilder:
                  (_, index) {

                final item =
                penaltyHistory[index];

                return Card(

                  margin:
                  const EdgeInsets.only(
                    bottom: 10,
                  ),

                  child: ListTile(

                    leading:
                    const CircleAvatar(

                      backgroundColor:
                      Colors.orangeAccent,

                      child: Icon(

                        Icons.warning_amber_rounded,

                        color:
                        Colors.white,

                      ),

                    ),

                    title: Text(

                      item["student_name"],

                      style:
                      const TextStyle(

                        fontWeight:
                        FontWeight.bold,

                      ),

                    ),

                    subtitle: Text(

                      "${item["warning_type"]} • ${item["warning_date"]}",

                    ),

                  ),

                );

              },

            ),

          ],

        ),

      ),

    );

  }

}