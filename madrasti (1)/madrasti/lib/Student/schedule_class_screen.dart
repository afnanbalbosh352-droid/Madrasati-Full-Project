import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../General/app_colors.dart';
import '../api.dart';

class ScheduleClassScreen extends StatefulWidget {

  const ScheduleClassScreen({super.key});

  @override
  State<ScheduleClassScreen> createState() =>
      _ScheduleClassScreenState();

}

class _ScheduleClassScreenState
    extends State<ScheduleClassScreen> {

  List schedule = [];

  bool isLoading = true;

  final List<String> days = [

    "Sunday",
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",

  ];

  final List<String> times = [

    "8",
    "9",
    "10",
    "11",
    "12",

  ];

  // =========================================
  // GET SCHEDULE
  // =========================================

  Future<void> getSchedule() async {

    try {

      final prefs =
      await SharedPreferences.getInstance();

      final studentId =
      prefs.getString("profile_id");

      final response = await http.get(

        Uri.parse(
          "${Api.studentClassSchedule}/$studentId",
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

      setState(() {
        isLoading = false;
      });

      print(error);

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
      String period,
      ) {

    try {

      return schedule.firstWhere(

            (item) =>

        item["day_of_week"] == day &&

            item["period_number"]
                .toString() ==
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

      appBar: AppBar(

        title: const Text(
          "Class Schedule",
        ),

        backgroundColor:
        AppColors.primary,

        foregroundColor:
        Colors.white,

      ),

      backgroundColor:
      AppColors.background,

      body: isLoading

          ? const Center(
        child:
        CircularProgressIndicator(),
      )

          : SingleChildScrollView(

        scrollDirection:
        Axis.horizontal,

        child: SingleChildScrollView(

          child: DataTable(

            headingRowColor:
            WidgetStateProperty.all(

              AppColors.primary
                  .withOpacity(0.1),

            ),

            columns: [

              const DataColumn(
                label: Text("Time"),
              ),

              ...days.map(

                    (day) => DataColumn(
                  label: Text(day),
                ),

              ),

            ],

            rows: times.map((time) {

              return DataRow(

                cells: [

                  // =====================
                  // TIME
                  // =====================

                  DataCell(

                    Text(

                      "$time-${int.parse(time) + 1}",

                      style: const TextStyle(
                        fontWeight:
                        FontWeight.bold,
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
                      time,
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

                                  "${subject["subject_name"]} - ${subject["teacher_name"]}",

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
                              0.1,
                            ),

                            borderRadius:
                            BorderRadius.circular(
                              10,
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

            }).toList(),

          ),

        ),

      ),

    );

  }

}