import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../General/app_colors.dart';
import '../api.dart';

class NotificationsScreen extends StatefulWidget {

  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() =>
      _NotificationsScreenState();

}

class _NotificationsScreenState
    extends State<NotificationsScreen> {

  List notifications = [];

  bool isLoading = true;

  // =========================================
  // GET NOTIFICATIONS
  // =========================================

  Future<void> getNotifications() async {

    try {

      final response = await http.get(

        Uri.parse(
          Api.studentNotifications,
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

          notifications =
          data["notifications"];

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

    getNotifications();

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title: const Text(
          "Notifications",
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

          : notifications.isEmpty

          ? const Center(
        child: Text(
          "No Notifications Found",
        ),
      )

          : ListView.builder(

        padding:
        const EdgeInsets.all(16),

        itemCount:
        notifications.length,

        itemBuilder:
            (context, index) {

          final notification =
          notifications[index];

          return buildNotificationCard(
            notification,
          );

        },

      ),

    );

  }

  // =========================================
  // NOTIFICATION CARD
  // =========================================

  Widget buildNotificationCard(
      Map<String, dynamic> notification,
      ) {

    return Card(

      margin: const EdgeInsets.only(
        bottom: 10,
      ),

      elevation: 4,

      shape: RoundedRectangleBorder(
        borderRadius:
        BorderRadius.circular(12),
      ),

      child: ListTile(

        leading: Icon(
          Icons.notifications,
          color: AppColors.primary,
        ),

        title: Text(
          notification["title"] ?? "",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        subtitle: Column(

          crossAxisAlignment:
          CrossAxisAlignment.start,

          children: [

            const SizedBox(height: 5),

            Text(
              notification["description"] ??
                  "",
            ),

            const SizedBox(height: 8),

            Text(

              notification["created_at"]
                  .toString()
                  .substring(0, 10),

              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),

            ),

          ],

        ),

      ),

    );

  }

}