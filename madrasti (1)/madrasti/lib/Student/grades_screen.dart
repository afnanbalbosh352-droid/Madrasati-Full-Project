import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../General/app_colors.dart';
import '../api.dart';

class GradesScreen extends StatefulWidget {

  const GradesScreen({super.key});

  @override
  State<GradesScreen> createState() =>
      _GradesScreenState();

}

class _GradesScreenState
    extends State<GradesScreen> {

  List grades = [];

  bool isLoading = true;

  // =========================================
  // GET GRADES
  // =========================================

  Future<void> getGrades() async {

    try {

      final prefs =
      await SharedPreferences.getInstance();

      final studentId =
      prefs.getString("profile_id");

      final response = await http.get(

        Uri.parse(
          "${Api.studentGrades}/$studentId",
        ),

        headers: {
          "Content-Type":
          "application/json",
        },

      );

      final data =
      jsonDecode(response.body);

      if (response.statusCode == 200 &&
          data["success"] == true) {

        setState(() {

          grades =
          data["grades"];

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

    getGrades();

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title: const Text(
          "Grades",
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

          : grades.isEmpty

          ? const Center(
        child: Text(
          "No Grades Found",
        ),
      )

          : ListView.builder(

        padding:
        const EdgeInsets.all(16),

        itemCount:
        grades.length,

        itemBuilder:
            (context, index) {

          final grade =
          grades[index];

          return buildGradeCard(
            grade,
          );

        },

      ),

    );

  }

  // =========================================
  // GRADE CARD
  // =========================================

  Widget buildGradeCard(
      Map<String, dynamic> grade,
      ) {

    final double gradeValue =
        double.tryParse(
          grade["grade_value"]
              .toString(),
        ) ??
            0;

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

        contentPadding:
        const EdgeInsets.symmetric(

          horizontal: 16,
          vertical: 10,

        ),

        leading: CircleAvatar(

          backgroundColor:
          AppColors.primary,

          child: Text(

            grade["subject_name"]
                .toString()
                .substring(0, 1)
                .toUpperCase(),

            style: const TextStyle(
              color: Colors.white,
              fontWeight:
              FontWeight.bold,
            ),

          ),

        ),

        title: Text(

          grade["subject_name"] ?? "",

          style: const TextStyle(
            fontWeight:
            FontWeight.bold,
          ),

        ),

        subtitle: Padding(

          padding:
          const EdgeInsets.only(
            top: 5,
          ),

          child: Text(
            grade["exam_type"] ?? "",
          ),

        ),

        trailing: Column(

          mainAxisAlignment:
          MainAxisAlignment.center,

          children: [

            Text(

              gradeValue.toString(),

              style: TextStyle(

                fontSize: 18,

                fontWeight:
                FontWeight.bold,

                color:

                gradeValue >= 90
                    ? Colors.green

                    : gradeValue >= 70
                    ? Colors.orange

                    : Colors.red,

              ),

            ),

            const SizedBox(height: 4),

            Container(

              padding:
              const EdgeInsets.symmetric(

                horizontal: 8,
                vertical: 2,

              ),

              decoration: BoxDecoration(

                color:
                grade["is_approved"] == true
                    ? Colors.green
                    .withOpacity(0.1)
                    : Colors.orange
                    .withOpacity(0.1),

                borderRadius:
                BorderRadius.circular(
                  20,
                ),

              ),

              child: Text(

                grade["is_approved"] == true
                    ? "Approved"
                    : "Pending",

                style: TextStyle(

                  fontSize: 11,

                  fontWeight:
                  FontWeight.bold,

                  color:
                  grade["is_approved"] == true
                      ? Colors.green
                      : Colors.orange,

                ),

              ),

            ),

          ],

        ),

      ),

    );

  }

}