import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../General/app_colors.dart';
import '../api.dart';

class AttendanceScreen extends StatefulWidget {

  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() =>
      _AttendanceScreenState();

}

class _AttendanceScreenState
    extends State<AttendanceScreen> {

  bool isLoading = true;

  List attendanceList = [];

  int absentDays = 0;

  int presentDays = 0;

  int totalSemesterDays = 100;

  // =========================================
  // GET ATTENDANCE
  // =========================================

  Future<void> getAttendance() async {

    try {

      final prefs =
      await SharedPreferences.getInstance();

      final studentId =
      prefs.getString("profile_id");

      final response = await http.get(

        Uri.parse(
          "${Api.studentAttendance}/$studentId",
        ),

        headers: {
          "Content-Type": "application/json",
        },

      );

      final data =
      jsonDecode(response.body);

      if (response.statusCode == 200 &&
          data["success"] == true) {

        attendanceList =
        data["attendance"];

        // ===============================
        // CALCULATE
        // ===============================

        absentDays = attendanceList
            .where(
              (item) =>
          item["status"]
              .toString()
              .toLowerCase() ==
              "absent",
        )
            .length;

        presentDays = attendanceList
            .where(
              (item) =>
          item["status"]
              .toString()
              .toLowerCase() ==
              "present",
        )
            .length;

      }

      setState(() {
        isLoading = false;
      });

    }

    catch (error) {

      print(error);

      setState(() {
        isLoading = false;
      });

    }

  }

  @override
  void initState() {

    super.initState();

    getAttendance();

  }

  @override
  Widget build(BuildContext context) {

    // =====================================
    // LOGIC
    // =====================================

    const double allowedPercentage = 0.10;

    int maxAllowedDays =
    (totalSemesterDays *
        allowedPercentage)
        .toInt();

    int remainingDays =
        maxAllowedDays - absentDays;

    double progress =
        absentDays / maxAllowedDays;

    bool isAtRisk =
        absentDays >=
            (maxAllowedDays - 1);

    return Scaffold(

      backgroundColor:
      AppColors.background,

      appBar: AppBar(

        title: const Text(
          "Attendance Tracker",
        ),

        backgroundColor:
        AppColors.primary,

        foregroundColor:
        Colors.white,

        elevation: 0,

      ),

      body: isLoading

          ? const Center(
        child:
        CircularProgressIndicator(),
      )

          : SingleChildScrollView(

        child: Column(

          children: [

            // =================================
            // HEADER
            // =================================

            Container(

              width: double.infinity,

              padding:
              const EdgeInsets.all(20),

              decoration: const BoxDecoration(

                color:
                AppColors.primary,

                borderRadius:
                BorderRadius.only(

                  bottomLeft:
                  Radius.circular(30),

                  bottomRight:
                  Radius.circular(30),

                ),

              ),

              child: Column(

                children: [

                  Text(

                    "Total Semester Days: $totalSemesterDays",

                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),

                  ),

                  const SizedBox(height: 10),

                  Text(

                    isAtRisk
                        ? "Warning: High Absence!"
                        : "Your Attendance is Good",

                    style: const TextStyle(

                      color: Colors.white,

                      fontSize: 22,

                      fontWeight:
                      FontWeight.bold,

                    ),

                  ),

                ],

              ),

            ),

            const SizedBox(height: 30),

            // =================================
            // MAIN CARD
            // =================================

            Padding(

              padding:
              const EdgeInsets.symmetric(
                horizontal: 20,
              ),

              child: Card(

                shape:
                RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(20),
                ),

                elevation: 5,

                child: Padding(

                  padding:
                  const EdgeInsets.all(25),

                  child: Column(

                    children: [

                      Stack(

                        alignment:
                        Alignment.center,

                        children: [

                          SizedBox(

                            width: 150,
                            height: 150,

                            child:
                            CircularProgressIndicator(

                              value:
                              progress > 1.0
                                  ? 1.0
                                  : progress,

                              strokeWidth: 12,

                              backgroundColor:
                              Colors.grey.shade200,

                              color:
                              isAtRisk
                                  ? Colors.redAccent
                                  : Colors.green,

                            ),

                          ),

                          Column(

                            children: [

                              Text(

                                "$absentDays / $maxAllowedDays",

                                style: TextStyle(

                                  fontSize: 26,

                                  fontWeight:
                                  FontWeight.bold,

                                  color:
                                  isAtRisk
                                      ? Colors.red
                                      : Colors.black87,

                                ),

                              ),

                              const Text(

                                "Days Absent",

                                style: TextStyle(
                                  color: Colors.grey,
                                ),

                              ),

                            ],

                          ),

                        ],

                      ),

                      const SizedBox(height: 30),

                      const Divider(),

                      const SizedBox(height: 10),

                      Row(

                        mainAxisAlignment:
                        MainAxisAlignment
                            .spaceAround,

                        children: [

                          buildStatDetail(
                            "Remaining",
                            "$remainingDays",
                            Colors.blue,
                          ),

                          buildStatDetail(
                            "Limit",
                            "$maxAllowedDays Days",
                            Colors.orange,
                          ),

                          buildStatDetail(
                            "Present",
                            "$presentDays",
                            Colors.green,
                          ),

                        ],

                      ),

                    ],

                  ),

                ),

              ),

            ),

            // =================================
            // WARNING
            // =================================

            if (isAtRisk)

              Padding(

                padding:
                const EdgeInsets.all(20),

                child: Row(

                  crossAxisAlignment:
                  CrossAxisAlignment.start,

                  children: [

                    const Icon(

                      Icons.warning_amber_rounded,

                      color: Colors.red,

                    ),

                    const SizedBox(width: 10),

                    const Expanded(

                      child: Text(

                        "Warning: You have reached the allowed absence limit. Please be careful.",

                        style: TextStyle(

                          color: Colors.red,

                          fontWeight:
                          FontWeight.bold,

                          fontSize: 14,

                        ),

                      ),

                    ),

                  ],

                ),

              ),

            // =================================
            // ATTENDANCE LIST
            // =================================

            ListView.builder(

              itemCount:
              attendanceList.length,

              shrinkWrap: true,

              physics:
              const NeverScrollableScrollPhysics(),

              padding:
              const EdgeInsets.all(16),

              itemBuilder:
                  (context, index) {

                final item =
                attendanceList[index];

                final isPresent =
                    item["status"]
                        .toString()
                        .toLowerCase() ==
                        "present";

                return Card(

                  margin:
                  const EdgeInsets.only(
                    bottom: 10,
                  ),

                  child: ListTile(

                    leading: CircleAvatar(

                      backgroundColor:
                      isPresent
                          ? Colors.green
                          : Colors.red,

                      child: Icon(

                        isPresent
                            ? Icons.check
                            : Icons.close,

                        color: Colors.white,

                      ),

                    ),

                    title: Text(

                      item["status"],

                      style: const TextStyle(
                        fontWeight:
                        FontWeight.bold,
                      ),

                    ),

                    subtitle: Text(
                      item["attendance_date"]
                          .toString()
                          .substring(0, 10),
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

  // =========================================
  // STAT DETAIL
  // =========================================

  Widget buildStatDetail(

      String label,
      String value,
      Color color,

      ) {

    return Column(

      children: [

        Text(

          value,

          style: TextStyle(

            fontSize: 20,

            fontWeight:
            FontWeight.bold,

            color: color,

          ),

        ),

        Text(

          label,

          style: const TextStyle(
            color: Colors.grey,
          ),

        ),

      ],

    );

  }

}