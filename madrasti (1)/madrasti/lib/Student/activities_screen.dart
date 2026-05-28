import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../General/app_colors.dart';
import '../api.dart';

class ActivitiesScreen extends StatefulWidget {

  const ActivitiesScreen({super.key});

  @override
  State<ActivitiesScreen> createState() =>
      _ActivitiesScreenState();

}

class _ActivitiesScreenState
    extends State<ActivitiesScreen> {

  List activities = [];

  bool isLoading = true;

  // =========================================
  // GET ACTIVITIES
  // =========================================

  Future<void> getActivities() async {

    try {

      final prefs =
      await SharedPreferences.getInstance();

      final studentId =
      prefs.getString("profile_id");

      final response = await http.get(

        Uri.parse(
          "${Api.studentActivities}/$studentId",
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

          activities = data["activities"];

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

    getActivities();

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title: const Text("Activities"),

        backgroundColor: AppColors.primary,

        foregroundColor: Colors.white,

      ),

      backgroundColor: AppColors.background,

      body: isLoading

          ? const Center(
        child: CircularProgressIndicator(),
      )

          : activities.isEmpty

          ? const Center(
        child: Text("No Activities Found"),
      )

          : ListView.builder(

        padding: const EdgeInsets.all(16),

        itemCount: activities.length,

        itemBuilder: (context, index) {

          final activity =
          activities[index];

          return buildActivity(
            activity,
          );

        },

      ),

    );

  }

  // =========================================
  // ACTIVITY CARD
  // =========================================

  Widget buildActivity(
      Map<String, dynamic> activity,
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
            // DATE
            // =================================

            Row(

              children: [

                Icon(
                  Icons.calendar_today,
                  size: 18,
                  color: AppColors.primary,
                ),

                const SizedBox(width: 8),

                Text(

                  activity["created_at"]
                      .toString()
                      .substring(0, 10),

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

              activity["title"] ?? "",

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

              activity["description"] ?? "",

              style: const TextStyle(
                color: Colors.black87,
              ),

            ),

          ],

        ),

      ),

    );

  }

}