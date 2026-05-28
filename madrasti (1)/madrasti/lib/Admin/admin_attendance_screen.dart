import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../General/app_colors.dart';
import '../api.dart';

class AdminAttendanceScreen extends StatefulWidget {

  const AdminAttendanceScreen({
    super.key,
  });

  @override
  State<AdminAttendanceScreen> createState() =>
      _AdminAttendanceScreenState();

}

class _AdminAttendanceScreenState
    extends State<AdminAttendanceScreen> {

  // =====================================================
  // DATA
  // =====================================================

  List atRiskStudents = [];

  Map<String, dynamic> schoolData = {};

  List currentStudents = [];

  bool isLoading = true;

  bool isSaving = false;

  String errorMessage = "";

  String selectedGrade = "";

  String selectedSection = "";

  DateTime selectedDate =
  DateTime.now();

  final List<String> attendanceStatuses = [

    "Present",

    "Absent",

  ];

  // =====================================================
  // INIT
  // =====================================================

  @override
  void initState() {

    super.initState();

    loadAttendanceData();

  }

  // =====================================================
  // FORMAT DATE
  // =====================================================

  String formatDate(
      DateTime date,
      ) {

    return
      "${date.year}-"
          "${date.month.toString().padLeft(2, '0')}-"
          "${date.day.toString().padLeft(2, '0')}";

  }

  // =====================================================
  // NORMALIZE STATUS
  // =====================================================
  String normalizeStatus(
      dynamic status,
      ) {

    final value =
    status.toString().toLowerCase();

    switch (value) {

      case "present":
        return "Present";

      case "absent":
        return "Absent";

      default:
        return "Absent";

    }

  }
  // =====================================================
  // LOAD ATTENDANCE
  // =====================================================

  Future<void>
  loadAttendanceData() async {

    try {

      setState(() {

        isLoading = true;

        errorMessage = "";

      });

      final response =
      await http.get(

        Uri.parse(

          "${Api.adminAttendance}"
              "?attendance_date="
              "${formatDate(selectedDate)}",

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

        schoolData =
            data["school_data"] ?? {};

        atRiskStudents =
            data["at_risk_students"] ?? [];

        // =================================
        // NORMALIZE STATUS
        // =================================

        schoolData.forEach((grade, sections) {

          sections.forEach((section, students) {

            for (var student in students) {

              student["status"] =
                  normalizeStatus(
                    student["status"],
                  );

            }

          });

        });

        // =================================
        // DEFAULT VALUES
        // =================================

        if (schoolData.isNotEmpty) {

          selectedGrade =
              schoolData.keys.first
                  .toString();

          selectedSection =
              schoolData[selectedGrade]
                  .keys
                  .first
                  .toString();

          currentStudents =
          schoolData[selectedGrade]
          [selectedSection];

        }

      }

      else {

        errorMessage =
            data["message"] ??
                "Failed to load attendance";

      }

    }

    catch (e) {

      errorMessage =
      "Error loading attendance";

    }

    finally {

      setState(() {

        isLoading = false;

      });

    }

  }

  // =====================================================
  // SAVE ATTENDANCE
  // =====================================================

  Future<void>
  saveChanges() async {

    try {

      setState(() {

        isSaving = true;

      });

      final response =
      await http.post(

        Uri.parse(
          Api.adminAttendance,
        ),

        headers: {

          "Content-Type":
          "application/json",

        },

        body: jsonEncode({

          "attendance_date":
          formatDate(selectedDate),

          "grade":
          selectedGrade,

          "section":
          selectedSection,

          "students":
          currentStudents,

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

        ScaffoldMessenger.of(context)
            .showSnackBar(

          const SnackBar(

            backgroundColor:
            Colors.green,

            content: Text(

              "Attendance updated successfully",

            ),

          ),

        );

      }

      else {

        ScaffoldMessenger.of(context)
            .showSnackBar(

          SnackBar(

            backgroundColor:
            Colors.red,

            content: Text(

              data["message"] ??
                  "Failed to save attendance",

            ),

          ),

        );

      }

    }

    catch (e) {

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(

          content:
          Text(
            "Error saving attendance",
          ),

        ),

      );

    }

    finally {

      setState(() {

        isSaving = false;

      });

    }

  }

  // =====================================================
  // STATUS COLOR
  // =====================================================

  Color getStatusColor(
      String status,
      ) {

    switch (status) {

      case "Present":
        return Colors.green;

      case "Absent":
        return Colors.red;

      case "Late":
        return Colors.orange;

      case "Excused":
        return Colors.blue;

      default:
        return Colors.black;

    }

  }

  // =====================================================
  // BUILD
  // =====================================================

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
      AppColors.background,

      appBar: AppBar(

        title:
        const Text(
          "Attendance Management",
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

          ? buildErrorState()

          : Padding(

        padding:
        const EdgeInsets.all(16),

        child: Column(

          crossAxisAlignment:
          CrossAxisAlignment.start,

          children: [

            // =================================
            // DATE CARD
            // =================================

            Container(

              padding:
              const EdgeInsets.all(16),

              decoration:
              BoxDecoration(

                color:
                Colors.white,

                borderRadius:
                BorderRadius.circular(16),

              ),

              child: Row(

                children: [

                  const Icon(
                    Icons.calendar_month,
                  ),

                  const SizedBox(width: 12),

                  Expanded(

                    child: Text(

                      formatDate(
                        selectedDate,
                      ),

                      style:
                      const TextStyle(

                        fontSize: 16,

                        fontWeight:
                        FontWeight.bold,

                      ),

                    ),

                  ),

                  ElevatedButton(

                    onPressed: () async {

                      final picked =
                      await showDatePicker(

                        context: context,

                        initialDate:
                        selectedDate,

                        firstDate:
                        DateTime(2024),

                        lastDate:
                        DateTime(2035),

                      );

                      if (picked != null) {

                        selectedDate =
                            picked;

                        loadAttendanceData();

                      }

                    },

                    child:
                    const Text(
                      "Select Date",
                    ),

                  ),

                ],

              ),

            ),

            const SizedBox(height: 20),

            // =================================
            // FILTERS
            // =================================

            Row(

              children: [

                // =====================================
                // GRADES
                // =====================================

                Expanded(

                  child:
                  DropdownButtonFormField<String>(

                    initialValue:
                    selectedGrade.isEmpty
                        ? null
                        : selectedGrade,

                    decoration:
                    InputDecoration(

                      hintText:
                      "Select Grade",

                      filled: true,

                      fillColor:
                      Colors.white,

                      contentPadding:
                      const EdgeInsets.symmetric(

                        horizontal: 14,
                        vertical: 14,

                      ),

                      border:
                      OutlineInputBorder(

                        borderRadius:
                        BorderRadius.circular(14),

                        borderSide:
                        BorderSide.none,

                      ),

                    ),

                    isExpanded: true,

                    items:

                    schoolData.keys
                        .map<DropdownMenuItem<String>>(

                          (grade) {

                        return DropdownMenuItem<String>(

                          value:
                          grade.toString(),

                          child:
                          Text(

                            grade.toString(),

                          ),

                        );

                      },

                    ).toList(),

                    onChanged:
                        (value) {

                      if (value == null) {
                        return;
                      }

                      setState(() {

                        selectedGrade =
                            value;

                        selectedSection =
                            schoolData[selectedGrade]
                                .keys
                                .first
                                .toString();

                        currentStudents =
                        schoolData[selectedGrade]
                        [selectedSection];

                      });

                    },

                  ),

                ),

                const SizedBox(width: 14),

                // =====================================
                // SECTION
                // =====================================

                Expanded(

                  child:
                  DropdownButtonFormField<String>(

                    initialValue:
                    selectedSection.isEmpty
                        ? null
                        : selectedSection,

                    decoration:
                    InputDecoration(

                      hintText:
                      "Select Section",

                      filled: true,

                      fillColor:
                      Colors.white,

                      contentPadding:
                      const EdgeInsets.symmetric(

                        horizontal: 14,
                        vertical: 14,

                      ),

                      border:
                      OutlineInputBorder(

                        borderRadius:
                        BorderRadius.circular(14),

                        borderSide:
                        BorderSide.none,

                      ),

                    ),

                    isExpanded: true,

                    items:

                    selectedGrade.isEmpty

                        ? []

                        : schoolData[selectedGrade]
                        .keys
                        .map<DropdownMenuItem<String>>(

                          (section) {

                        return DropdownMenuItem<String>(

                          value:
                          section.toString(),

                          child:
                          Text(

                            section.toString(),

                          ),

                        );

                      },

                    ).toList(),

                    onChanged:
                        (value) {

                      if (value == null) {
                        return;
                      }

                      setState(() {

                        selectedSection =
                            value;

                        currentStudents =
                        schoolData[selectedGrade]
                        [selectedSection];

                      });

                    },

                  ),

                ),

              ],

            ),

            const SizedBox(height: 20),

            // =================================
            // STUDENTS LIST
            // =================================

            Expanded(

              child:

              currentStudents.isEmpty

                  ? const Center(

                child:
                Text(
                  "No students found",
                ),

              )

                  : ListView.builder(

                itemCount:
                currentStudents.length,

                itemBuilder:
                    (_, index) {

                  final student =
                  currentStudents[index];

                  final currentStatus =
                  normalizeStatus(

                    student["status"],

                  );

                  return Card(

                    margin:
                    const EdgeInsets.only(
                      bottom: 10,
                    ),

                    shape:
                    RoundedRectangleBorder(

                      borderRadius:
                      BorderRadius.circular(16),

                    ),

                    child: ListTile(

                      leading:
                      CircleAvatar(

                        backgroundColor:
                        AppColors.primary
                            .withOpacity(0.1),

                        child:
                        Text(

                          (student["name"] ??
                              "U")[0],

                          style:
                          const TextStyle(

                            color:
                            AppColors.primary,

                          ),

                        ),

                      ),

                      title:
                      Text(
                        student["name"],
                      ),

                      subtitle:
                      Text(

                        currentStatus,

                        style:
                        TextStyle(

                          color:
                          getStatusColor(
                            currentStatus,
                          ),

                          fontWeight:
                          FontWeight.bold,

                        ),

                      ),

                      trailing:
                      DropdownButton<String>(

                        value:
                        currentStatus,

                        underline:
                        const SizedBox(),

                        items:
                        attendanceStatuses
                            .map<DropdownMenuItem<String>>(

                              (status) {

                            return DropdownMenuItem<String>(

                              value:
                              status,

                              child:
                              Text(status),

                            );

                          },

                        ).toList(),

                        onChanged:
                            (value) {

                          if (value == null) {
                            return;
                          }

                          setState(() {

                            student["status"] =
                                value;

                          });

                        },

                      ),

                    ),

                  );

                },

              ),

            ),

            const SizedBox(height: 20),

            // =================================
            // SAVE BUTTON
            // =================================

            SizedBox(

              width:
              double.infinity,

              height: 55,

              child:
              ElevatedButton(

                onPressed:

                isSaving
                    ? null
                    : saveChanges,

                style:
                ElevatedButton.styleFrom(

                  backgroundColor:
                  AppColors.primary,

                ),

                child:

                isSaving

                    ? const CircularProgressIndicator(
                  color:
                  Colors.white,
                )

                    : const Text(

                  "Save Attendance",

                  style:
                  TextStyle(

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

    );

  }

  // =====================================================
  // ERROR STATE
  // =====================================================

  Widget buildErrorState() {

    return Center(

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

          Text(errorMessage),

          const SizedBox(height: 20),

          ElevatedButton(

            onPressed:
            loadAttendanceData,

            child:
            const Text(
              "Retry",
            ),

          ),

        ],

      ),

    );

  }

}