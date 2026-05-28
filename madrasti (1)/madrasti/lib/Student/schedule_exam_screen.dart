import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../General/app_colors.dart';
import '../api.dart';

class ScheduleExamScreen extends StatefulWidget {

  const ScheduleExamScreen({super.key});

  @override
  State<ScheduleExamScreen> createState() =>
      _ScheduleExamScreenState();

}

class _ScheduleExamScreenState
    extends State<ScheduleExamScreen> {

  List exams = [];

  bool isLoading = true;

  // =========================================
  // GET EXAMS
  // =========================================

  Future<void> getExams() async {

    try {

      final prefs =
      await SharedPreferences.getInstance();

      final studentId =
      prefs.getString("profile_id");

      final response = await http.get(

        Uri.parse(
          "${Api.studentExamSchedule}/$studentId",
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

          exams =
          data["exams"];

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

    getExams();

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title: const Text(
          "Exam Schedule",
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

          : exams.isEmpty

          ? const Center(
        child: Text(
          "No Exams Found",
        ),
      )

          : ListView.builder(

        padding:
        const EdgeInsets.all(16),

        itemCount:
        exams.length,

        itemBuilder:
            (_, i) {

          final exam =
          exams[i];

          return buildExamCard(
            exam,
          );

        },

      ),

    );

  }

  // =========================================
  // EXAM CARD
  // =========================================

  Widget buildExamCard(
      Map<String, dynamic> exam,
      ) {

    return Card(

      margin: const EdgeInsets.only(
        bottom: 12,
      ),

      elevation: 4,

      shape: RoundedRectangleBorder(
        borderRadius:
        BorderRadius.circular(16),
      ),

      child: ListTile(

        leading: Icon(
          Icons.event,
          color: AppColors.primary,
        ),

        title: Text(

          exam["subject_name"] ?? "",

          style: const TextStyle(
            fontWeight:
            FontWeight.bold,
          ),

        ),

        subtitle: Column(

          crossAxisAlignment:
          CrossAxisAlignment.start,

          children: [

            const SizedBox(height: 5),

            Text(
              exam["exam_title"] ?? "",
            ),

            const SizedBox(height: 5),

            Text(

              "${exam["exam_date"].toString().substring(0, 10)} - ${exam["exam_time"]}",

            ),

          ],

        ),

      ),

    );

  }

}