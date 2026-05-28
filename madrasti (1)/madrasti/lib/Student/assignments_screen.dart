import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../General/app_colors.dart';
import '../api.dart';

class AssignmentsScreen extends StatefulWidget {

  const AssignmentsScreen({super.key});

  @override
  State<AssignmentsScreen> createState() =>
      _AssignmentsScreenState();

}

class _AssignmentsScreenState
    extends State<AssignmentsScreen> {

  List assignments = [];

  bool isLoading = true;

  // =========================================
  // GET ASSIGNMENTS
  // =========================================

  Future<void> getAssignments() async {

    try {

      final prefs =
      await SharedPreferences.getInstance();

      final studentId =
      prefs.getString("profile_id");

      final response = await http.get(

        Uri.parse(
          "${Api.studentAssignments}/$studentId",
        ),

        headers: {
          "Content-Type": "application/json",
        },

      );
       print(response.body);

      final data =
      jsonDecode(response.body);

      if (response.statusCode == 200 &&
          data["success"] == true) {

        setState(() {

          assignments =
          data["assignments"];

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

    getAssignments();

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title: const Text("Assignments"),

        backgroundColor: AppColors.primary,

        foregroundColor: Colors.white,

      ),

      backgroundColor: AppColors.background,

      body: isLoading

          ? const Center(
        child: CircularProgressIndicator(),
      )

          : assignments.isEmpty

          ? const Center(
        child: Text("No Assignments Found"),
      )

          : ListView.builder(

        padding: const EdgeInsets.all(16),

        itemCount: assignments.length,

        itemBuilder: (_, i) {

          final assignment =
          assignments[i];

          return buildAssignmentCard(
            assignment,
          );

        },

      ),

    );

  }

  // =========================================
  // ASSIGNMENT CARD
  // =========================================

  Widget buildAssignmentCard(
      Map<String, dynamic> assignment,
      ) {

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

          crossAxisAlignment:
          CrossAxisAlignment.start,

          children: [

            // =================================
            // DUE DATE
            // =================================

            Row(

              children: [

                Icon(
                  Icons.schedule,
                  size: 18,
                  color: AppColors.primary,
                ),

                const SizedBox(width: 8),

                Text(

                  "Submission: ${assignment["due_date"].toString().substring(0, 10)}",

                  style: const TextStyle(
                    color: Colors.grey,
                  ),

                ),

              ],

            ),

            const SizedBox(height: 10),

            // =================================
            // TITLE
            // =================================

            Text(

              assignment["title"] ?? "",

              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),

            ),

            const SizedBox(height: 8),

            // =================================
            // DESCRIPTION
            // =================================

            Text(

              assignment["description"] ?? "",

              style: const TextStyle(
                color: Colors.black87,
              ),

            ),

            const SizedBox(height: 12),

            // =================================
            // BUTTON
            // =================================

            Align(

              alignment: Alignment.centerRight,

              child: TextButton(

                onPressed: () {

                  ScaffoldMessenger.of(context)
                      .showSnackBar(

                    SnackBar(

                      content: Text(
                        assignment["title"] ??
                            "Assignment Opened",
                      ),

                    ),

                  );

                },

                child: const Text(
                  "View",
                ),

              ),

            ),

          ],

        ),

      ),

    );

  }

}