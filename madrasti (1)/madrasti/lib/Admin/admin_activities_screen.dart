import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../General/app_colors.dart';
import '../api.dart';

class AdminActivitiesScreen extends StatefulWidget {

  const AdminActivitiesScreen({super.key});

  @override
  State<AdminActivitiesScreen> createState() =>
      _AdminActivitiesScreenState();

}

class _AdminActivitiesScreenState
    extends State<AdminActivitiesScreen> {

  // =========================================================
  // LOADING
  // =========================================================

  bool isLoading = true;

  // =========================================================
  // DATA
  // =========================================================

  List teacherRequests = [];

  List schoolEvents = [];

  // =========================================================
  // CONTROLLERS
  // =========================================================

  final titleController =
  TextEditingController();

  final descController =
  TextEditingController();

  // =========================================================
  // INIT
  // =========================================================

  @override
  void initState() {

    super.initState();

    getPendingActivities();

    getNotifications();

  }

  // =========================================================
  // GET PENDING ACTIVITIES
  // =========================================================

  Future<void> getPendingActivities() async {

    try {

      final response =
      await http.get(

        Uri.parse(
          Api.adminPendingActivities,
        ),

      );

      final data =
      jsonDecode(response.body);

      if (
      response.statusCode == 200 &&
          data["success"] == true
      ) {

        setState(() {

          teacherRequests =
          data["activities"];

        });

      }

    }

    catch (e) {

      debugPrint(e.toString());

    }

    finally {

      setState(() {

        isLoading = false;

      });

    }

  }

  // =========================================================
  // GET NOTIFICATIONS
  // =========================================================

  Future<void> getNotifications() async {

    try {

      final response =
      await http.get(

        Uri.parse(
          Api.adminNotifications,
        ),

      );

      final data =
      jsonDecode(response.body);

      if (
      response.statusCode == 200 &&
          data["success"] == true
      ) {

        setState(() {

          schoolEvents =
          data["notifications"];

        });

      }

    }

    catch (e) {

      debugPrint(e.toString());

    }

  }

  // =========================================================
  // APPROVE ACTIVITY
  // =========================================================

  Future<void> approveActivity(
      String activityId,
      ) async {

    try {

      final response =
      await http.post(

        Uri.parse(
          Api.adminApproveActivity,
        ),

        headers: {
          "Content-Type":
          "application/json",
        },

        body: jsonEncode({

          "activity_id":
          activityId,

        }),

      );

      final data =
      jsonDecode(response.body);

      if (
      response.statusCode == 200 &&
          data["success"] == true
      ) {

        ScaffoldMessenger.of(context)
            .showSnackBar(

          const SnackBar(

            content: Text(
              "Activity Approved",
            ),

          ),

        );

        getPendingActivities();

      }

    }

    catch (e) {

      debugPrint(e.toString());

    }

  }

  // =========================================================
  // REJECT ACTIVITY
  // =========================================================

  Future<void> rejectActivity(
      String activityId,
      ) async {

    try {

      final response =
      await http.post(

        Uri.parse(
          Api.adminRejectActivity,
        ),

        headers: {
          "Content-Type":
          "application/json",
        },

        body: jsonEncode({

          "activity_id":
          activityId,

        }),

      );

      final data =
      jsonDecode(response.body);

      if (
      response.statusCode == 200 &&
          data["success"] == true
      ) {

        ScaffoldMessenger.of(context)
            .showSnackBar(

          const SnackBar(

            content: Text(
              "Activity Rejected",
            ),

          ),

        );

        getPendingActivities();

      }

    }

    catch (e) {

      debugPrint(e.toString());

    }

  }

  // =========================================================
  // ADD SCHOOL EVENT
  // =========================================================

  Future<void> addSchoolEvent() async {

    if (
    titleController.text.trim().isEmpty
    ) {
      return;
    }

    try {

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
          "1",

          "title":
          titleController.text,

          "description":
          descController.text,

          "target_type":
          "all",

        }),

      );

      final data =
      jsonDecode(response.body);

      if (
      response.statusCode == 200 &&
          data["success"] == true
      ) {

        titleController.clear();

        descController.clear();

        Navigator.pop(context);

        getNotifications();

        ScaffoldMessenger.of(context)
            .showSnackBar(

          const SnackBar(

            content: Text(
              "Event Posted Successfully",
            ),

          ),

        );

      }

    }

    catch (e) {

      debugPrint(e.toString());

    }

  }

  // =========================================================
  // STATUS COLOR
  // =========================================================

  Color getStatusColor(
      String status,
      ) {

    switch (status.toLowerCase()) {

      case "approved":
        return Colors.green;

      case "rejected":
        return Colors.red;

      default:
        return Colors.orange;

    }

  }

  // =========================================================
  // ADD EVENT DIALOG
  // =========================================================

  void showAddEventDialog() {

    showDialog(

      context: context,

      builder: (_) {

        return AlertDialog(

          shape:
          RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(20),
          ),

          title:
          const Text(
            "Add School Event",
          ),

          content: Column(

            mainAxisSize:
            MainAxisSize.min,

            children: [

              TextField(

                controller:
                titleController,

                decoration:
                InputDecoration(

                  labelText:
                  "Event Title",

                  border:
                  OutlineInputBorder(
                    borderRadius:
                    BorderRadius.circular(14),
                  ),

                ),

              ),

              const SizedBox(height: 14),

              TextField(

                controller:
                descController,

                maxLines: 3,

                decoration:
                InputDecoration(

                  labelText:
                  "Description",

                  border:
                  OutlineInputBorder(
                    borderRadius:
                    BorderRadius.circular(14),
                  ),

                ),

              ),

            ],

          ),

          actions: [

            TextButton(

              onPressed: () {

                Navigator.pop(context);

              },

              child:
              const Text("Cancel"),

            ),

            ElevatedButton(

              style:
              ElevatedButton.styleFrom(

                backgroundColor:
                AppColors.primary,

              ),

              onPressed:
              addSchoolEvent,

              child:
              const Text("Post"),

            ),

          ],

        );

      },

    );

  }

  // =========================================================
  // DISPOSE
  // =========================================================

  @override
  void dispose() {

    titleController.dispose();

    descController.dispose();

    super.dispose();

  }

  // =========================================================
  // UI
  // =========================================================

  @override
  Widget build(BuildContext context) {

    return DefaultTabController(

      length: 2,

      child: Scaffold(

        backgroundColor:
        AppColors.background,

        appBar: AppBar(

          centerTitle: true,

          title: const Text(
            "School Activities",
          ),

          bottom: const TabBar(

            tabs: [

              Tab(

                text:
                "Teacher Requests",

                icon:
                Icon(Icons.pending_actions),

              ),

              Tab(

                text:
                "School Events",

                icon:
                Icon(Icons.campaign),

              ),

            ],

          ),

        ),

        floatingActionButton:
        FloatingActionButton(

          backgroundColor:
          AppColors.primary,

          onPressed:
          showAddEventDialog,

          child:
          const Icon(Icons.add),

        ),

        body: isLoading

            ? const Center(
          child:
          CircularProgressIndicator(),
        )

            : TabBarView(

          children: [

            buildTeacherRequests(),

            buildSchoolEvents(),

          ],

        ),

      ),

    );

  }

  // =========================================================
  // TEACHER REQUESTS
  // =========================================================

  Widget buildTeacherRequests() {

    if (
    teacherRequests.isEmpty
    ) {

      return const Center(

        child:
        Text(
          "No Pending Activities",
        ),

      );

    }

    return ListView.builder(

      padding:
      const EdgeInsets.all(16),

      itemCount:
      teacherRequests.length,

      itemBuilder: (_, i) {

        final activity =
        teacherRequests[i];

        return Card(

          elevation: 2,

          margin:
          const EdgeInsets.only(
            bottom: 14,
          ),

          shape:
          RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(18),
          ),

          child: Padding(

            padding:
            const EdgeInsets.all(16),

            child: Column(

              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [

                Text(

                  activity["title"],

                  style:
                  const TextStyle(

                    fontSize: 17,

                    fontWeight:
                    FontWeight.bold,

                  ),

                ),

                const SizedBox(height: 8),

                Text(
                  activity["description"],
                ),

                const SizedBox(height: 14),

                Row(

                  children: [

                    const Icon(
                      Icons.person,
                      size: 18,
                    ),

                    const SizedBox(width: 6),

                    Expanded(

                      child: Text(
                        activity["teacher_name"] ??
                            "",
                      ),

                    ),

                  ],

                ),

                const SizedBox(height: 16),

                Row(

                  children: [

                    Expanded(

                      child:
                      ElevatedButton.icon(

                        style:
                        ElevatedButton.styleFrom(

                          backgroundColor:
                          Colors.green,

                          foregroundColor:
                          Colors.white,

                        ),

                        onPressed: () {

                          approveActivity(
                            activity["id"],
                          );

                        },

                        icon:
                        const Icon(Icons.check),

                        label:
                        const Text("Approve"),

                      ),

                    ),

                    const SizedBox(width: 12),

                    Expanded(

                      child:
                      ElevatedButton.icon(

                        style:
                        ElevatedButton.styleFrom(

                          backgroundColor:
                          Colors.red,

                          foregroundColor:
                          Colors.white,

                        ),

                        onPressed: () {

                          rejectActivity(
                            activity["id"],
                          );

                        },

                        icon:
                        const Icon(Icons.close),

                        label:
                        const Text("Reject"),

                      ),

                    ),

                  ],

                ),

              ],

            ),

          ),

        );

      },

    );

  }

  // =========================================================
  // SCHOOL EVENTS
  // =========================================================

  Widget buildSchoolEvents() {

    if (
    schoolEvents.isEmpty
    ) {

      return const Center(

        child:
        Text(
          "No Events Found",
        ),

      );

    }

    return ListView.builder(

      padding:
      const EdgeInsets.all(16),

      itemCount:
      schoolEvents.length,

      itemBuilder: (_, i) {

        final event =
        schoolEvents[i];

        return Container(

          margin:
          const EdgeInsets.only(
            bottom: 14,
          ),

          decoration:
          BoxDecoration(

            color:
            Colors.blue.shade50,

            borderRadius:
            BorderRadius.circular(18),

            border: Border.all(
              color:
              AppColors.primary,
            ),

          ),

          child: ListTile(

            contentPadding:
            const EdgeInsets.all(14),

            leading:
            CircleAvatar(

              backgroundColor:
              Colors.white,

              child:
              Icon(

                Icons.campaign,

                color:
                AppColors.primary,

              ),

            ),

            title:
            Text(

              event["title"],

              style:
              const TextStyle(
                fontWeight:
                FontWeight.bold,
              ),

            ),

            subtitle:
            Padding(

              padding:
              const EdgeInsets.only(
                top: 6,
              ),

              child:
              Text(
                event["description"] ??
                    "",
              ),

            ),

            trailing:
            Text(

              event["created_at"] == null
                  ? ""
                  : event["created_at"]
                  .toString()
                  .split("T")[0],

              style:
              const TextStyle(
                fontSize: 11,
                color: Colors.grey,
              ),

            ),

          ),

        );

      },

    );

  }

}