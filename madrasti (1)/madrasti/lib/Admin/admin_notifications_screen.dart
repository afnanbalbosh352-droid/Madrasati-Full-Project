import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../General/app_colors.dart';
import '../api.dart';

class AdminNotificationsScreen extends StatefulWidget {

  const AdminNotificationsScreen({
    super.key,
  });

  @override
  State<AdminNotificationsScreen> createState() =>
      _AdminNotificationsScreenState();

}

class _AdminNotificationsScreenState
    extends State<AdminNotificationsScreen> {

  // =====================================
  // CONTROLLERS
  // =====================================

  final TextEditingController
  titleController =
  TextEditingController();

  final TextEditingController
  descriptionController =
  TextEditingController();

  // =====================================
  // DATA
  // =====================================

  List notifications = [];

  bool isLoading = true;

  bool isSending = false;

  String errorMessage = "";

  String adminId = "";

  // =====================================
  // TARGET TYPES
  // =====================================

  final List<Map<String, String>>
  targetTypes = [

    {
      "value": "all_students",
      "label": "All Students",
    },

    {
      "value": "all_teachers",
      "label": "All Teachers",
    },

    {
      "value": "grade",
      "label": "Grade",
    },

    {
      "value": "section",
      "label": "Section",
    },

    {
      "value": "specific_student",
      "label": "Specific Student",
    },

    {
      "value": "specific_teacher",
      "label": "Specific Teacher",
    },

  ];

  String selectedTarget =
      "all_students";

  // =====================================
  // INIT
  // =====================================

  @override
  void initState() {

    super.initState();

    initialize();

  }

  // =====================================
  // INITIALIZE
  // =====================================

  Future<void> initialize() async {

    try {

      final prefs =
      await SharedPreferences.getInstance();

      adminId =
          prefs.getString(
            "profile_id",
          ) ??
              "";

      if (adminId.isEmpty) {

        setState(() {

          errorMessage =
          "Admin not found";

          isLoading = false;

        });

        return;

      }

      await loadNotifications();

    }

    catch (e) {

      debugPrint(
        e.toString(),
      );

      setState(() {

        errorMessage =
        "Initialization failed";

        isLoading = false;

      });

    }

  }

  // =====================================
  // LOAD NOTIFICATIONS
  // =====================================

  Future<void>
  loadNotifications() async {

    try {

      setState(() {

        isLoading = true;

      });

      final response =
      await http.get(

        Uri.parse(
          Api.adminNotifications,
        ),

      );

      final data =
      jsonDecode(
        response.body,
      );

      if (

      response.statusCode == 200 &&

          data["success"] == true

      ) {

        notifications =
            data["notifications"] ??
                [];

      }

      else {

        errorMessage =
        "Failed to load notifications";

      }

    }

    catch (e) {

      debugPrint(
        e.toString(),
      );

      errorMessage =
      "Error loading notifications";

    }

    finally {

      setState(() {

        isLoading = false;

      });

    }

  }

  // =====================================
  // SEND NOTIFICATION
  // =====================================

  Future<void>
  sendNotification() async {

    if (

    titleController.text
        .trim()
        .isEmpty

    ) {

      showMessage(
        "Please enter title",
      );

      return;

    }

    if (

    descriptionController.text
        .trim()
        .isEmpty

    ) {

      showMessage(
        "Please enter description",
      );

      return;

    }

    try {

      setState(() {

        isSending = true;

      });

      final response =
      await http.post(

        Uri.parse(
          Api.adminSendNotification,
        ),

        headers: {

          "Content-Type":
          "application/json",

        },

        body: jsonEncode({

          "admin_id":
          adminId,

          "title":
          titleController.text.trim(),

          "description":
          descriptionController.text
              .trim(),

          "target_type":
          selectedTarget,

        }),

      );

      final data =
      jsonDecode(
        response.body,
      );

      if (

      response.statusCode == 200 &&

          data["success"] == true

      ) {

        titleController.clear();

        descriptionController.clear();

        selectedTarget =
        "all_students";

        showMessage(
          "Notification sent successfully",
        );

        await loadNotifications();

      }

      else {

        showMessage(

          data["message"] ??
              "Failed to send notification",

        );

      }

    }

    catch (e) {

      debugPrint(
        e.toString(),
      );

      showMessage(
        "Error sending notification",
      );

    }

    finally {

      setState(() {

        isSending = false;

      });

    }

  }

  // =====================================
  // DELETE NOTIFICATION
  // =====================================

  Future<void>
  deleteNotification(
      String id,
      ) async {

    try {

      final response =
      await http.delete(

        Uri.parse(

          "${Api.adminDeleteNotification}/$id",

        ),

      );

      final data =
      jsonDecode(
        response.body,
      );

      if (

      response.statusCode == 200 &&

          data["success"] == true

      ) {

        showMessage(
          "Notification deleted successfully",
        );

        await loadNotifications();

      }

      else {

        showMessage(

          data["message"] ??
              "Delete failed",

        );

      }

    }

    catch (e) {

      showMessage(
        "Error deleting notification",
      );

    }

  }

  // =====================================
  // MESSAGE
  // =====================================

  void showMessage(
      String message,
      ) {

    ScaffoldMessenger.of(context)
        .showSnackBar(

      SnackBar(

        content:
        Text(message),

      ),

    );

  }

  // =====================================
  // GET TARGET LABEL
  // =====================================

  String getTargetLabel(
      String value,
      ) {

    final target =
    targetTypes.firstWhere(

          (item) =>
      item["value"] == value,

      orElse: () => {

        "label": value,

      },

    );

    return target["label"]!;

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

          ? Center(
        child:
        Text(errorMessage),
      )

          : SingleChildScrollView(

        padding:
        const EdgeInsets.all(16),

        child: Column(

          crossAxisAlignment:
          CrossAxisAlignment.start,

          children: [

            // =====================================
            // SEND CARD
            // =====================================

            Card(

              elevation: 3,

              shape:
              RoundedRectangleBorder(

                borderRadius:
                BorderRadius.circular(
                  16,
                ),

              ),

              child: Padding(

                padding:
                const EdgeInsets.all(16),

                child: Column(

                  children: [

                    // =========================
                    // TARGET
                    // =========================

                    DropdownButtonFormField<
                        String>(

                      initialValue:
                      selectedTarget,

                      decoration:
                      const InputDecoration(

                        hintText:
                        "Target Audience",

                        border:
                        OutlineInputBorder(),

                      ),

                      items:
                      targetTypes.map(

                            (target) {

                          return DropdownMenuItem<

                              String>(

                            value:
                            target["value"],

                            child:
                            Text(

                              target["label"]!,

                            ),

                          );

                        },

                      ).toList(),

                      onChanged:
                          (value) {

                        setState(() {

                          selectedTarget =
                          value!;

                        });

                      },

                    ),

                    const SizedBox(
                      height: 16,
                    ),

                    // =========================
                    // TITLE
                    // =========================

                    TextField(

                      controller:
                      titleController,

                      decoration:
                      const InputDecoration(

                        labelText:
                        "Notification Title",

                        border:
                        OutlineInputBorder(),

                      ),

                    ),

                    const SizedBox(
                      height: 16,
                    ),

                    // =========================
                    // DESCRIPTION
                    // =========================

                    TextField(

                      controller:
                      descriptionController,

                      maxLines: 4,

                      decoration:
                      const InputDecoration(

                        labelText:
                        "Notification Description",

                        border:
                        OutlineInputBorder(),

                      ),

                    ),

                    const SizedBox(
                      height: 20,
                    ),

                    // =========================
                    // BUTTON
                    // =========================

                    SizedBox(

                      width:
                      double.infinity,

                      height: 50,

                      child: ElevatedButton(

                        onPressed:

                        isSending
                            ? null
                            : sendNotification,

                        style:
                        ElevatedButton.styleFrom(

                          backgroundColor:
                          AppColors.primary,

                          shape:
                          RoundedRectangleBorder(

                            borderRadius:
                            BorderRadius.circular(
                              12,
                            ),

                          ),

                        ),

                        child:

                        isSending

                            ? const SizedBox(

                          width: 22,

                          height: 22,

                          child:
                          CircularProgressIndicator(

                            strokeWidth: 2,

                            color:
                            Colors.white,

                          ),

                        )

                            : const Text(

                          "Send Notification",

                          style: TextStyle(

                            color:
                            Colors.white,

                            fontWeight:
                            FontWeight.bold,

                            fontSize: 16,

                          ),

                        ),

                      ),

                    ),

                  ],

                ),

              ),

            ),

            const SizedBox(
              height: 24,
            ),

            // =====================================
            // TITLE
            // =====================================

            const Text(

              "Sent Notifications",

              style: TextStyle(

                fontSize: 20,

                fontWeight:
                FontWeight.bold,

              ),

            ),

            const SizedBox(
              height: 16,
            ),

            // =====================================
            // EMPTY
            // =====================================

            if (notifications.isEmpty)

              const Center(

                child: Padding(

                  padding:
                  EdgeInsets.all(30),

                  child: Text(

                    "No notifications found",

                  ),

                ),

              )

            else

              ListView.builder(

                shrinkWrap: true,

                physics:
                const NeverScrollableScrollPhysics(),

                itemCount:
                notifications.length,

                itemBuilder:
                    (_, index) {

                  final notification =
                  notifications[index];

                  return Card(

                    margin:
                    const EdgeInsets.only(
                      bottom: 14,
                    ),

                    shape:
                    RoundedRectangleBorder(

                      borderRadius:
                      BorderRadius.circular(
                        16,
                      ),

                    ),

                    child: ListTile(

                      contentPadding:
                      const EdgeInsets.all(
                        14,
                      ),

                      leading:
                      CircleAvatar(

                        backgroundColor:
                        AppColors.primary
                            .withOpacity(0.1),

                        child: const Icon(

                          Icons.notifications,

                          color:
                          AppColors.primary,

                        ),

                      ),

                      title: Text(

                        notification["title"] ??
                            "",

                        style:
                        const TextStyle(

                          fontWeight:
                          FontWeight.bold,

                        ),

                      ),

                      subtitle: Column(

                        crossAxisAlignment:
                        CrossAxisAlignment.start,

                        children: [

                          const SizedBox(
                            height: 6,
                          ),

                          Text(

                            notification[
                            "description"] ??
                                "",

                          ),

                          const SizedBox(
                            height: 8,
                          ),

                          Container(

                            padding:
                            const EdgeInsets.symmetric(

                              horizontal: 10,

                              vertical: 4,

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
                                20,
                              ),

                            ),

                            child: Text(

                              "Target: ${getTargetLabel(notification["target_type"])}",

                              style:
                              const TextStyle(

                                fontSize: 12,

                                color:
                                AppColors.primary,

                                fontWeight:
                                FontWeight.w600,

                              ),

                            ),

                          ),

                        ],

                      ),

                      trailing:
                      IconButton(

                        onPressed: () {

                          deleteNotification(

                            notification["id"]
                                .toString(),

                          );

                        },

                        icon: const Icon(

                          Icons.delete,

                          color: Colors.red,

                        ),

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

}