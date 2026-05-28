import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../General/app_colors.dart';
import '../api.dart';

class TeacherScheduleScreen extends StatefulWidget {

  const TeacherScheduleScreen({super.key});

  @override
  State<TeacherScheduleScreen> createState() =>
      _TeacherScheduleScreenState();

}

class _TeacherScheduleScreenState
    extends State<TeacherScheduleScreen> {

  List schedule = [];

  bool isLoading = true;

  final List<String> days = [

    "Sunday",
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",

  ];

  // =========================================
  // GET SCHEDULE
  // =========================================

  Future<void> getSchedule() async {

    try {

      final prefs =
      await SharedPreferences.getInstance();

      final teacherId =
      prefs.getString("profile_id");

      final response = await http.get(

        Uri.parse(
          "${Api.teacherSchedule}/$teacherId",
        ),

        headers: {
          "Content-Type": "application/json",
        },

      );

      final data =
      jsonDecode(response.body);

      if (response.statusCode == 200 &&
          data["success"] == true) {

        setState(() {

          schedule =
          data["schedule"];

          isLoading = false;

        });

      }

      else {

        setState(() {
          isLoading = false;
        });

      }

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

    getSchedule();

  }

  // =========================================
  // GET SUBJECT
  // =========================================

  Map<String, dynamic>? getSubject(

      String day,
      int period,

      ) {

    try {

      return schedule.firstWhere(

            (item) =>

        item["day_of_week"] == day &&

            item["period_number"] ==
                period,

      );

    }

    catch (e) {

      return null;

    }

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
      AppColors.background,

      appBar: AppBar(

        title: const Text(
          "Teacher Schedule",
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

          : Padding(

        padding:
        const EdgeInsets.all(12),

        child: Container(

          decoration: BoxDecoration(

            color: Colors.white,

            borderRadius:
            BorderRadius.circular(14),

            boxShadow: const [

              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
              ),

            ],

          ),

          child: SingleChildScrollView(

            scrollDirection:
            Axis.vertical,

            child: SingleChildScrollView(

              scrollDirection:
              Axis.horizontal,

              child: DataTable(

                headingRowColor:
                WidgetStateProperty.all(

                  AppColors.primary
                      .withOpacity(0.1),

                ),

                columns: [

                  const DataColumn(

                    label: Text(

                      "Class",

                      style: TextStyle(
                        fontWeight:
                        FontWeight.bold,
                      ),

                    ),

                  ),

                  ...days.map(

                        (d) => DataColumn(

                      label: Text(

                        d,

                        style:
                        const TextStyle(
                          fontWeight:
                          FontWeight.bold,
                        ),

                      ),

                    ),

                  ),

                ],

                rows: List.generate(7,
                      (i) {

                    final period =
                        i + 1;

                    return DataRow(

                      cells: [

                        // =====================
                        // PERIOD
                        // =====================

                        DataCell(

                          Text(

                            "Class $period",

                            style:
                            const TextStyle(
                              fontWeight:
                              FontWeight.w500,
                            ),

                          ),

                        ),

                        // =====================
                        // DAYS
                        // =====================

                        ...days.map((day) {

                          final subject =
                          getSubject(
                            day,
                            period,
                          );

                          return DataCell(

                            GestureDetector(

                              onTap: () {

                                if (subject !=
                                    null) {

                                  ScaffoldMessenger
                                      .of(context)
                                      .showSnackBar(

                                    SnackBar(

                                      content: Text(

                                        "${subject["subject_name"]} - ${subject["section_name"]}",

                                      ),

                                    ),

                                  );

                                }

                              },

                              child: Container(

                                padding:
                                const EdgeInsets.all(
                                  8,
                                ),

                                decoration:
                                BoxDecoration(

                                  color:
                                  AppColors.primary
                                      .withOpacity(
                                    0.08,
                                  ),

                                  borderRadius:
                                  BorderRadius.circular(
                                    8,
                                  ),

                                ),

                                child: Text(

                                  subject == null

                                      ? "-"

                                      : subject[
                                  "subject_name"],

                                  textAlign:
                                  TextAlign.center,

                                ),

                              ),

                            ),

                          );

                        }),

                      ],

                    );

                  },

                ),

              ),

            ),

          ),

        ),

      ),

    );

  }

}