import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../General/app_colors.dart';
import '../api.dart';

class AdminGradesScreen extends StatefulWidget {

  const AdminGradesScreen({super.key});

  @override
  State<AdminGradesScreen> createState() =>
      _AdminGradesScreenState();

}

class _AdminGradesScreenState
    extends State<AdminGradesScreen> {

  // =====================================
  // DATA
  // =====================================

  List studentsGrades = [];

  bool isLoading = true;

  bool isPrinting = false;

  String errorMessage = "";

  // =====================================
  // FILTERS
  // =====================================

  String selectedGrade = "Tenth";

  String selectedSection = "A";

  String selectedSemester =
      "current";

  final List<String> grades = [

    "Tenth",

    "Ninth",

  ];

  final List<String> sections = [

    "A",

    "B",

    "C",

  ];

  final List<Map<String, String>>
  semesters = [

    {
      "name": "Current Semester",
      "value": "current",
    },

    {
      "name": "Previous Semester",
      "value": "previous",
    },

  ];

  // =====================================
  // INIT
  // =====================================

  @override
  void initState() {

    super.initState();

    getGrades();

  }

  // =====================================
  // GET GRADES
  // =====================================

  Future<void> getGrades() async {

    try {

      setState(() {

        isLoading = true;

        errorMessage = "";

      });

      final response =
      await http.get(

        Uri.parse(

          "${Api.adminGrades}"
              "?grade=$selectedGrade"
              "&section=$selectedSection"
              "&semester=$selectedSemester",

        ),

      );

      final data =
      jsonDecode(response.body);

      if (response.statusCode == 200 &&
          data["success"] == true) {

        setState(() {

          studentsGrades =
              data["students"] ?? [];

          isLoading = false;

        });

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
  // APPROVE GRADE
  // =====================================

  Future<void> approveGrade(
      String studentId,
      ) async {

    try {

      final response =
      await http.post(

        Uri.parse(
          Api.adminApproveStudentGrade,
        ),

        headers: {

          "Content-Type":
          "application/json",

        },

        body: jsonEncode({

          "student_id":
          studentId,

        }),

      );

      final data =
      jsonDecode(response.body);

      if (response.statusCode == 200 &&
          data["success"] == true) {

        ScaffoldMessenger.of(context)
            .showSnackBar(

          const SnackBar(

            backgroundColor:
            Colors.green,

            content: Text(
              "Grade approved successfully",
            ),

          ),

        );

        getGrades();

      }

      else {

        ScaffoldMessenger.of(context)
            .showSnackBar(

          SnackBar(

            content: Text(

              data["message"] ??
                  "Failed to approve grade",

            ),

          ),

        );

      }

    }

    catch (e) {

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(

          content: Text(
            "Error approving grade",
          ),

        ),

      );

    }

  }

  // =====================================
  // REPORT CARD
  // =====================================

  Future<void> generateReportCard(
      String studentId,
      ) async {

    try {

      final response =
      await http.get(

        Uri.parse(

          "${Api.adminGenerateReportCard}/$studentId",

        ),

      );

      final data =
      jsonDecode(response.body);

      if (response.statusCode == 200 &&
          data["success"] == true) {

        ScaffoldMessenger.of(context)
            .showSnackBar(

          const SnackBar(

            backgroundColor:
            Colors.green,

            content: Text(
              "Report card generated",
            ),

          ),

        );

      }

      else {

        ScaffoldMessenger.of(context)
            .showSnackBar(

          SnackBar(

            content: Text(

              data["message"] ??
                  "Failed to generate report",

            ),

          ),

        );

      }

    }

    catch (e) {

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(

          content: Text(
            "Error generating report card",
          ),

        ),

      );

    }

  }

  // =====================================
  // PRINT CERTIFICATES
  // =====================================

  Future<void> printCertificates() async {

    try {

      setState(() {

        isPrinting = true;

      });

      final response =
      await http.post(

        Uri.parse(
          Api.adminPrintCertificates,
        ),

        headers: {

          "Content-Type":
          "application/json",

        },

        body: jsonEncode({

          "grade":
          selectedGrade,

          "section":
          selectedSection,

          "semester":
          selectedSemester,

        }),

      );

      final data =
      jsonDecode(response.body);

      if (response.statusCode == 200 &&
          data["success"] == true) {

        ScaffoldMessenger.of(context)
            .showSnackBar(

          const SnackBar(

            backgroundColor:
            Colors.green,

            content: Text(
              "Certificates generated successfully",
            ),

          ),

        );

      }

      else {

        ScaffoldMessenger.of(context)
            .showSnackBar(

          SnackBar(

            content: Text(

              data["message"] ??
                  "Failed to print certificates",

            ),

          ),

        );

      }

    }

    catch (e) {

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(

          content: Text(
            "Error printing certificates",
          ),

        ),

      );

    }

    finally {

      setState(() {

        isPrinting = false;

      });

    }

  }

  // =====================================
  // GRADE BOX
  // =====================================

  Widget buildGradeBox(

      String label,
      dynamic value, {

        bool isFinal = false,

      }) {

    return Column(

      children: [

        Text(

          label,

          style: const TextStyle(

            fontSize: 10,

            color: Colors.grey,

          ),

        ),

        const SizedBox(
          height: 4,
        ),

        Container(

          padding:
          const EdgeInsets.all(8),

          decoration: BoxDecoration(

            color:
            isFinal

                ? AppColors.primary
                .withOpacity(0.1)

                : Colors.grey[100],

            borderRadius:
            BorderRadius.circular(8),

          ),

          child: Text(

            value.toString(),

            style: TextStyle(

              fontWeight:
              isFinal

                  ? FontWeight.bold

                  : FontWeight.normal,

              color:
              isFinal

                  ? AppColors.primary

                  : Colors.black,

            ),

          ),

        ),

      ],

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
          "Final Grades Approval",
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
              getGrades,

              child: const Text(
                "Retry",
              ),

            ),

          ],

        ),

      )

          : Padding(

        padding:
        const EdgeInsets.all(
          16,
        ),

        child: Column(

          children: [

            // =========================
            // FILTERS
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
                const EdgeInsets.all(
                  14,
                ),

                child: Column(

                  children: [

                    DropdownButtonFormField<
                        String>(

                      initialValue:
                      selectedSemester,

                      decoration:
                      const InputDecoration(

                        labelText:
                        "Academic Period",

                        prefixIcon:
                        Icon(
                          Icons.history,
                        ),

                      ),

                      items:
                      semesters.map((s) {

                        return DropdownMenuItem(

                          value:
                          s["value"],

                          child: Text(
                            s["name"]!,
                          ),

                        );

                      }).toList(),

                      onChanged: (val) {

                        setState(() {

                          selectedSemester =
                          val!;

                        });

                        getGrades();

                      },

                    ),

                    const SizedBox(
                      height: 14,
                    ),

                    Row(

                      children: [

                        Expanded(

                          child:
                          DropdownButtonFormField<
                              String>(

                            initialValue:
                            selectedGrade,

                            decoration:
                            const InputDecoration(

                              labelText:
                              "Grade",

                            ),

                            items:
                            grades.map((g) {

                              return DropdownMenuItem(

                                value: g,

                                child: Text(g),

                              );

                            }).toList(),

                            onChanged: (val) {

                              setState(() {

                                selectedGrade =
                                val!;

                              });

                              getGrades();

                            },

                          ),

                        ),

                        const SizedBox(
                          width: 10,
                        ),

                        Expanded(

                          child:
                          DropdownButtonFormField<
                              String>(

                            initialValue:
                            selectedSection,

                            decoration:
                            const InputDecoration(

                              labelText:
                              "Section",

                            ),

                            items:
                            sections.map((s) {

                              return DropdownMenuItem(

                                value: s,

                                child: Text(s),

                              );

                            }).toList(),

                            onChanged: (val) {

                              setState(() {

                                selectedSection =
                                val!;

                              });

                              getGrades();

                            },

                          ),

                        ),

                      ],

                    ),

                  ],

                ),

              ),

            ),

            const SizedBox(
              height: 16,
            ),

            // =========================
            // LIST
            // =========================

            Expanded(

              child:
              studentsGrades.isEmpty

                  ? const Center(
                child: Text(
                  "No grades found",
                ),
              )

                  : ListView.builder(

                itemCount:
                studentsGrades.length,

                itemBuilder:
                    (_, index) {

                  final student =
                  studentsGrades[index];

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

                    child: Padding(

                      padding:
                      const EdgeInsets.all(
                        14,
                      ),

                      child: Column(

                        crossAxisAlignment:
                        CrossAxisAlignment.start,

                        children: [

                          Row(

                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,

                            children: [

                              Expanded(

                                child: Text(

                                  student["name"],

                                  style:
                                  const TextStyle(

                                    fontWeight:
                                    FontWeight.bold,

                                    fontSize:
                                    16,

                                  ),

                                ),

                              ),

                              Icon(

                                student["is_approved"] == true

                                    ? Icons.check_circle

                                    : Icons.pending,

                                color:

                                student["is_approved"] == true

                                    ? Colors.green

                                    : Colors.orange,

                              ),

                            ],

                          ),

                          const SizedBox(
                            height: 4,
                          ),

                          Text(

                            student["subject"],

                            style: TextStyle(

                              color:
                              Colors.grey[600],

                            ),

                          ),

                          const Divider(),

                          Row(

                            mainAxisAlignment:
                            MainAxisAlignment.spaceAround,

                            children: [

                              buildGradeBox(

                                "1st",

                                student["first"],

                              ),

                              buildGradeBox(

                                "2nd",

                                student["second"],

                              ),

                              buildGradeBox(

                                "Mid",

                                student["mid"],

                              ),

                              buildGradeBox(

                                "Part.",

                                student["participation"],

                              ),

                              buildGradeBox(

                                "Total",

                                student["total"],

                                isFinal: true,

                              ),

                            ],

                          ),

                          const SizedBox(
                            height: 14,
                          ),

                          Row(

                            mainAxisAlignment:
                            MainAxisAlignment.end,

                            children: [

                              if (student["is_approved"] != true)

                                ElevatedButton.icon(

                                  onPressed: () {

                                    approveGrade(

                                      student["student_id"]
                                          .toString(),

                                    );

                                  },

                                  style:
                                  ElevatedButton.styleFrom(

                                    backgroundColor:
                                    Colors.green,

                                  ),

                                  icon:
                                  const Icon(

                                    Icons.done_all,

                                    color:
                                    Colors.white,

                                    size: 18,

                                  ),

                                  label:
                                  const Text(

                                    "Approve",

                                    style: TextStyle(
                                      color:
                                      Colors.white,
                                    ),

                                  ),

                                )

                              else

                                OutlinedButton.icon(

                                  onPressed: () {

                                    generateReportCard(

                                      student["student_id"]
                                          .toString(),

                                    );

                                  },

                                  icon:
                                  const Icon(

                                    Icons.picture_as_pdf,

                                    size: 18,

                                  ),

                                  label:
                                  const Text(

                                    "View Report",

                                  ),

                                ),

                            ],

                          ),

                        ],

                      ),

                    ),

                  );

                },

              ),

            ),

            // =========================
            // PRINT BUTTON
            // =========================

            SizedBox(

              width: double.infinity,

              height: 55,

              child: ElevatedButton.icon(

                onPressed:
                isPrinting
                    ? null
                    : printCertificates,

                style:
                ElevatedButton.styleFrom(

                  backgroundColor:
                  AppColors.primary,

                  shape:
                  RoundedRectangleBorder(

                    borderRadius:
                    BorderRadius.circular(
                      14,
                    ),

                  ),

                ),

                icon:
                isPrinting

                    ? const SizedBox(

                  width: 18,
                  height: 18,

                  child:
                  CircularProgressIndicator(

                    color:
                    Colors.white,

                    strokeWidth: 2,

                  ),

                )

                    : const Icon(

                  Icons.print_rounded,

                  color:
                  Colors.white,

                ),

                label: Text(

                  isPrinting

                      ? "Printing..."

                      : "Print All Approved Certificates",

                  style:
                  const TextStyle(

                    color:
                    Colors.white,

                    fontWeight:
                    FontWeight.bold,

                    fontSize: 15,

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