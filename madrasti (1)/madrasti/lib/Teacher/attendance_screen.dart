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

  // =====================================
  // DATA
  // =====================================

  List atRiskStudents = [];

  Map<String, dynamic> schoolData = {};

  List currentStudents = [];

  bool isLoading = true;

  bool isSaving = false;

  String errorMessage = "";

  String selectedGrade = "";

  String selectedSection = "";

  // =====================================
  // DATE
  // =====================================

  DateTime selectedDate =
  DateTime.now();

  // =====================================
  // INIT
  // =====================================

  @override
  void initState() {

    super.initState();

    loadAttendanceData();

  }

  // =====================================
  // FORMAT DATE
  // =====================================

  String formatDate(
      DateTime date,
      ) {

    return
      "${date.year}-"
          "${date.month.toString().padLeft(2, '0')}-"
          "${date.day.toString().padLeft(2, '0')}";

  }

  // =====================================
  // FORMAT STATUS
  // =====================================

  String formatStatus(
      String status,
      ) {

    switch (status.toLowerCase()) {

      case "present":
        return "Present";

      case "absent":
        return "Absent";

      default:
        return "Absent";

    }

  }

  // =====================================
  // LOAD ATTENDANCE
  // =====================================

  Future<void> loadAttendanceData() async {

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
        // FORMAT STATUSES
        // =================================

        schoolData.forEach((grade, sections) {

          sections.forEach((section, students) {

            for (var student in students) {

              student["status"] =
                  formatStatus(
                    student["status"],
                  );

            }

          });

        });

        // =================================
        // DEFAULT CLASS
        // =================================

        if (schoolData.isNotEmpty) {

          selectedGrade =
              schoolData.keys.first;

          selectedSection =
              schoolData[selectedGrade]
                  .keys
                  .first;

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

  // =====================================
  // UPDATE CURRENT LIST
  // =====================================

  void updateStudentsList() {

    currentStudents =
    schoolData[selectedGrade]
    [selectedSection];

    setState(() {});

  }

  // =====================================
  // SEND WARNING
  // =====================================

  Future<void> sendWarningNotification(

      String studentId,
      String studentName,

      ) async {

    try {

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
          studentId,

          "admin_id":
          "60000000-0000-0000-0000-000000000001",

          "warning_type":
          "Attendance",

          "reason":
          "High absence rate",

          "action_taken":
          "Parent notified",

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

          SnackBar(

            backgroundColor:
            Colors.orange.shade700,

            content: Text(

              "Warning sent to $studentName",

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
                  "Failed to send warning",

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
            "Error sending warning",
          ),

        ),

      );

    }

  }

  // =====================================
  // SAVE ATTENDANCE
  // =====================================

  Future<void> saveChanges() async {

    if (isSaving) {
      return;
    }

    try {

      setState(() {

        isSaving = true;

      });

      final studentsPayload =
      currentStudents.map((student) {

        return {

          ...student,

          "status":

          student["status"]
              .toString()
              .toLowerCase(),

        };

      }).toList();

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
          studentsPayload,

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

        // =================================
        // LOCK STUDENTS
        // =================================

        setState(() {

          for (var student in currentStudents) {

            student["locked"] = true;

          }

        });

        ScaffoldMessenger.of(context)
            .showSnackBar(

          const SnackBar(

            backgroundColor:
            Colors.green,

            content: Text(

              "Attendance synced successfully",

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

          backgroundColor:
          Colors.red,

          content: Text(
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

  // =====================================
  // STATUS COLOR
  // =====================================

  Color getStatusColor(
      String status,
      ) {

    switch (status) {

      case "Present":

        return Colors.green;

      case "Absent":

        return Colors.red;

      default:

        return Colors.black;

    }

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
        const EdgeInsets.all(
          16,
        ),

        child: Column(

          crossAxisAlignment:
          CrossAxisAlignment.start,

          children: [

            // =================================
            // DATE
            // =================================

            Card(

              shape:
              RoundedRectangleBorder(

                borderRadius:
                BorderRadius.circular(
                  14,
                ),

              ),

              child: ListTile(

                leading:
                const Icon(
                  Icons.calendar_month,
                ),

                title: Text(

                  formatDate(
                    selectedDate,
                  ),

                ),

                trailing:
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

                      await loadAttendanceData();

                    }

                  },

                  child:
                  const Text(
                    "Change",
                  ),

                ),

              ),

            ),

            const SizedBox(
              height: 16,
            ),

            // =================================
            // RISK STUDENTS
            // =================================

            if (atRiskStudents
                .isNotEmpty) ...[

              const Text(

                "Students At Risk",

                style: TextStyle(

                  fontWeight:
                  FontWeight.bold,

                  fontSize: 16,

                  color:
                  Colors.red,

                ),

              ),

              const SizedBox(
                height: 10,
              ),

              Container(

                decoration:
                BoxDecoration(

                  color:
                  Colors.white,

                  borderRadius:
                  BorderRadius.circular(
                    16,
                  ),

                ),

                child:
                ExpansionTile(

                  leading:
                  const Icon(

                    Icons.warning,

                    color:
                    Colors.red,

                  ),

                  title: Text(

                    "${atRiskStudents.length} students need attention",

                    style:
                    const TextStyle(

                      color:
                      Colors.red,

                      fontWeight:
                      FontWeight.bold,

                    ),

                  ),

                  children:
                  atRiskStudents.map(

                        (student) {

                      return ListTile(

                        title: Text(
                          student["name"],
                        ),

                        subtitle: Text(

                          "Absences: ${student["absences"]} | ${student["class"]}",

                        ),

                        trailing:
                        ElevatedButton.icon(

                          onPressed: () {

                            sendWarningNotification(

                              student["id"]
                                  .toString(),

                              student["name"],

                            );

                          },

                          style:
                          ElevatedButton.styleFrom(

                            backgroundColor:
                            Colors.orange,

                          ),

                          icon:
                          const Icon(

                            Icons.notifications,

                            color:
                            Colors.white,

                            size: 18,

                          ),

                          label:
                          const Text(

                            "Warn",

                            style: TextStyle(
                              color:
                              Colors.white,
                            ),

                          ),

                        ),

                      );

                    },

                  ).toList(),

                ),

              ),

              const SizedBox(
                height: 20,
              ),

            ],

            // =================================
            // FILTERS
            // =================================

            const Text(

              "Review Attendance",

              style: TextStyle(

                fontWeight:
                FontWeight.bold,

                fontSize: 16,

              ),

            ),

            const SizedBox(
              height: 10,
            ),

            Card(

              shape:
              RoundedRectangleBorder(

                borderRadius:
                BorderRadius.circular(
                  14,
                ),

              ),

              child: Padding(

                padding:
                const EdgeInsets.symmetric(

                  horizontal: 16,

                  vertical: 8,

                ),

                child: Row(

                  children: [

                    Expanded(

                      child:
                      DropdownButton<String>(

                        value:
                        selectedGrade,

                        isExpanded:
                        true,

                        underline:
                        const SizedBox(),

                        items:
                        schoolData.keys.map(

                              (grade) {

                            return DropdownMenuItem<String>(

                              value:
                              grade,

                              child:
                              Text(
                                grade,
                              ),

                            );

                          },

                        ).toList(),

                        onChanged:
                            (value) {

                          selectedGrade =
                          value!;

                          selectedSection =
                              schoolData[value]
                                  .keys
                                  .first;

                          updateStudentsList();

                        },

                      ),

                    ),

                    const Padding(

                      padding:
                      EdgeInsets.symmetric(
                        horizontal: 8,
                      ),

                      child: Text(
                        "|",
                      ),

                    ),

                    Expanded(

                      child:
                      DropdownButton<String>(

                        value:
                        selectedSection,

                        isExpanded:
                        true,

                        underline:
                        const SizedBox(),

                        items:
                        schoolData[selectedGrade]
                            .keys
                            .map<DropdownMenuItem<String>>(

                              (section) {

                            return DropdownMenuItem<String>(

                              value:
                              section,

                              child:
                              Text(
                                section,
                              ),

                            );

                          },

                        ).toList(),

                        onChanged:
                            (value) {

                          selectedSection =
                          value!;

                          updateStudentsList();

                        },

                      ),

                    ),

                  ],

                ),

              ),

            ),

            const SizedBox(
              height: 16,
            ),

            // =================================
            // STUDENTS
            // =================================

            Expanded(

              child:
              currentStudents
                  .isEmpty

                  ? const Center(
                child: Text(
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

                  return Card(

                    margin:
                    const EdgeInsets.only(
                      bottom: 10,
                    ),

                    shape:
                    RoundedRectangleBorder(

                      borderRadius:
                      BorderRadius.circular(
                        14,
                      ),

                    ),

                    child: ListTile(

                      leading:
                      CircleAvatar(

                        backgroundColor:
                        AppColors.primary
                            .withOpacity(
                          0.1,
                        ),

                        child: Text(

                          student["name"][0],

                          style:
                          const TextStyle(

                            color:
                            AppColors.primary,

                            fontWeight:
                            FontWeight.bold,

                          ),

                        ),

                      ),

                      title: Text(

                        student["name"],

                        style:
                        const TextStyle(

                          fontWeight:
                          FontWeight.bold,

                        ),

                      ),

                      subtitle: Text(

                        "Current: ${student["status"]}",

                        style: TextStyle(

                          color:
                          getStatusColor(
                            student["status"],
                          ),

                          fontWeight:
                          FontWeight.w600,

                        ),

                      ),

                      trailing:
                      DropdownButton<String>(

                        value:
                        student["status"],

                        underline:
                        const SizedBox(),

                        onChanged:

                        student["locked"] == true

                            ? null

                            : (newStatus) {

                          setState(() {

                            student["status"] =
                            newStatus!;

                          });

                        },

                        items: [

                          "Present",

                          "Absent",

                        ].map(

                              (status) {

                            return DropdownMenuItem<String>(

                              value:
                              status,

                              child:
                              Text(

                                status,

                                style: TextStyle(

                                  color:
                                  getStatusColor(
                                    status,
                                  ),

                                  fontWeight:
                                  FontWeight.bold,

                                ),

                              ),

                            );

                          },

                        ).toList(),

                      ),

                    ),

                  );

                },

              ),

            ),

            // =================================
            // SAVE BUTTON
            // =================================

            SizedBox(

              width: double.infinity,

              height: 55,

              child: ElevatedButton(

                onPressed:
                isSaving
                    ? null
                    : saveChanges,

                style:
                ElevatedButton.styleFrom(

                  backgroundColor:
                  AppColors.primary,

                  shape:
                  RoundedRectangleBorder(

                    borderRadius:
                    BorderRadius.circular(
                      15,
                    ),

                  ),

                ),

                child:
                isSaving

                    ? const CircularProgressIndicator(
                  color:
                  Colors.white,
                )

                    : const Text(

                  "Confirm & Sync",

                  style: TextStyle(

                    color:
                    Colors.white,

                    fontSize: 16,

                    fontWeight:
                    FontWeight.bold,

                  ),

                ),

              ),

            ),

          ],

        ),

      ),

    );

  }

  // =====================================
  // ERROR
  // =====================================

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
            loadAttendanceData,

            child: const Text(
              "Retry",
            ),

          ),

        ],

      ),

    );

  }

}