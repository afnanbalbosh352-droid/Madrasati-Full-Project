import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../General/app_colors.dart';
import '../api.dart';

class AdminNotificationsScreen extends StatefulWidget {

  const AdminNotificationsScreen({super.key});

  @override
  State<AdminNotificationsScreen> createState() =>
      _AdminNotificationsScreenState();

}

class _AdminNotificationsScreenState
    extends State<AdminNotificationsScreen> {

  // =====================================
  // DATA
  // =====================================

  List notifications = [];

  bool isLoading = true;

  String errorMessage = "";

  // =====================================
  // INIT
  // =====================================

  @override
  void initState() {

    super.initState();

    getNotifications();

  }

  // =====================================
  // GET NOTIFICATIONS
  // =====================================

  Future<void> getNotifications() async {

    try {

      setState(() {

        isLoading = true;

        errorMessage = "";

      });

      final response =
      await http.get(

        Uri.parse(
          Api.teacherNotifications,
        ),

      );

      final data =
      jsonDecode(response.body);

      if (response.statusCode == 200 &&
          data["success"] == true) {

        setState(() {

          notifications =
              data["notifications"] ?? [];

          isLoading = false;

        });

      }

      else {

        setState(() {

          errorMessage =
              data["message"] ??
                  "Failed to load notifications";

          isLoading = false;

        });

      }

    }

    catch (e) {

      setState(() {

        errorMessage =
        "Error loading notifications";

        isLoading = false;

      });

    }

  }

  // =====================================
  // FORMAT DATE
  // =====================================

  String formatDate(String? date) {

    if (date == null) {

      return "";

    }

    try {

      final parsed =
      DateTime.parse(date);

      return
        "${parsed.year}-${parsed.month.toString().padLeft(2, '0')}-${parsed.day.toString().padLeft(2, '0')}";

    }

    catch (e) {

      return "";

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
          "Admin Notifications",
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

          : notifications.isEmpty

          ? buildEmptyState()

          : RefreshIndicator(

        onRefresh:
        getNotifications,

        child: ListView.builder(

          padding:
          const EdgeInsets.all(16),

          itemCount:
          notifications.length,

          itemBuilder:
              (context, index) {

            final notification =
            notifications[index];

            return Card(

              margin:
              const EdgeInsets.only(
                bottom: 12,
              ),

              elevation: 2,

              shape:
              RoundedRectangleBorder(

                borderRadius:
                BorderRadius.circular(
                  14,
                ),

              ),

              child: Padding(

                padding:
                const EdgeInsets.all(
                  14,
                ),

                child: Row(

                  crossAxisAlignment:
                  CrossAxisAlignment.start,

                  children: [

                    // ===================
                    // ICON
                    // ===================

                    CircleAvatar(

                      radius: 24,

                      backgroundColor:

                      AppColors.primary
                          .withOpacity(
                        0.1,
                      ),

                      child: const Icon(

                        Icons
                            .admin_panel_settings,

                        color:
                        AppColors.primary,

                      ),

                    ),

                    const SizedBox(
                      width: 14,
                    ),

                    // ===================
                    // CONTENT
                    // ===================

                    Expanded(

                      child: Column(

                        crossAxisAlignment:
                        CrossAxisAlignment
                            .start,

                        children: [

                          Text(

                            notification["title"] ??
                                "Notification",

                            style:
                            const TextStyle(

                              fontSize: 16,

                              fontWeight:
                              FontWeight.bold,

                            ),

                          ),

                          const SizedBox(
                            height: 6,
                          ),

                          Text(

                            notification["message"] ??
                                "",

                            style:
                            const TextStyle(

                              fontSize: 14,

                              height: 1.5,

                              color:
                              Colors.black87,

                            ),

                          ),

                          const SizedBox(
                            height: 10,
                          ),

                          Row(

                            children: [

                              const Icon(

                                Icons.access_time,

                                size: 15,

                                color:
                                Colors.grey,

                              ),

                              const SizedBox(
                                width: 5,
                              ),

                              Text(

                                formatDate(
                                  notification[
                                  "created_at"],
                                ),

                                style:
                                const TextStyle(

                                  fontSize: 12,

                                  color:
                                  Colors.grey,

                                ),

                              ),

                            ],

                          ),

                        ],

                      ),

                    ),

                  ],

                ),

              ),

            );

          },

        ),

      ),

    );

  }

  // =====================================
  // EMPTY STATE
  // =====================================

  Widget buildEmptyState() {

    return const Center(

      child: Column(

        mainAxisAlignment:
        MainAxisAlignment.center,

        children: [

          Icon(

            Icons.notifications_off_outlined,

            size: 80,

            color: Colors.grey,

          ),

          SizedBox(
            height: 16,
          ),

          Text(

            "No notifications available",

            style: TextStyle(
              fontSize: 16,
            ),

          ),

        ],

      ),

    );

  }

  // =====================================
  // ERROR STATE
  // =====================================

  Widget buildErrorState() {

    return Center(

      child: Column(

        mainAxisAlignment:
        MainAxisAlignment.center,

        children: [

          const Icon(

            Icons.error_outline,

            size: 80,

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
            getNotifications,

            child: const Text(
              "Retry",
            ),

          ),

        ],

      ),

    );

  }

}