import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../General/app_colors.dart';
import '../api.dart';

class MonthlyAssessmentScreen extends StatefulWidget {
  const MonthlyAssessmentScreen({super.key});

  @override
  State<MonthlyAssessmentScreen> createState() =>
      _MonthlyAssessmentScreenState();
}

class _MonthlyAssessmentScreenState extends State<MonthlyAssessmentScreen> {
  List assessments = [];
  bool isLoading = true;

  // =========================================
  // GET ASSESSMENTS
  // =========================================
  Future<void> getAssessments() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final studentId = prefs.getString("profile_id");

      final response = await http.get(
        Uri.parse(
          "${Api.studentAssessments}/$studentId",
        ),
        headers: {
          "Content-Type": "application/json",
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data["success"] == true) {
        setState(() {
          assessments = data["assessments"];
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      print(error);
    }
  }

  @override
  void initState() {
    super.initState();
    getAssessments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Monthly Assessment",
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      backgroundColor: AppColors.background,
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : assessments.isEmpty
              ? const Center(
                  child: Text(
                    "No Assessments Found",
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: assessments.length,
                  itemBuilder: (_, i) {
                    final assessment = assessments[i];
                    return buildAssessmentCard(
                      assessment,
                    );
                  },
                ),
    );
  }

  // =========================================
  // ASSESSMENT CARD
  // =========================================
  Widget buildAssessmentCard(
    Map<String, dynamic> assessment,
  ) {
    // تم تعديل هذا السطر لحماية التطبيق من القيم الفارغة (Null Safety)
    final rating = (assessment["rating"] ?? "Good").toString();

    return Card(
      margin: const EdgeInsets.only(
        bottom: 12,
      ),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
                  child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // =============================
            // SUBJECT
            // =============================
            Row(
              children: [
                Icon(
                  Icons.menu_book,
                  color: AppColors.primary,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  assessment["subject_name"] ?? "",
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // =============================
            // TITLE
            // =============================
            Text(
              assessment["evaluation_title"] ?? "",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),

            // =============================
            // RATING
            // =============================
            Row(
              children: [
                const Text(
                  "Assessment: ",
                ),
                Text(
                  rating,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: getRatingColor(
                      rating,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // =============================
            // NOTE
            // =============================
            Text(
              assessment["note"] ?? "",
              style: const TextStyle(
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================
  // RATING COLOR
  // =========================================
  Color getRatingColor(
    String rating,
  ) {
    final value = rating.toLowerCase();

    if (value.contains("excellent")) {
      return Colors.green;
    } else if (value.contains("very")) {
      return Colors.blue;
    } else if (value.contains("good")) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}