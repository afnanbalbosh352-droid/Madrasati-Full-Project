import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../General/app_colors.dart';
import '../api.dart';

class ActivitiesTeacherScreen extends StatefulWidget {

  const ActivitiesTeacherScreen({super.key});

  @override
  State<ActivitiesTeacherScreen> createState() =>
      _ActivitiesTeacherScreenState();

}

class _ActivitiesTeacherScreenState
    extends State<ActivitiesTeacherScreen> {

  // =====================================
  // CONTROLLERS
  // =====================================

  final TextEditingController
  titleController =
  TextEditingController();

  final TextEditingController
  descController =
  TextEditingController();

  // =====================================
  // DATA
  // =====================================

  List sections = [];

  List activities = [];

  bool isLoadingSections = true;

  bool isLoadingActivities = true;

  bool isAdding = false;

  String sectionsError = "";

  String activitiesError = "";

  String? selectedSectionId;

  String? selectedSectionName;

  String teacherId = "";

  // =====================================
  // INIT
  // =====================================

  @override
  void initState() {

    super.initState();

    initialize();

  }

  // =====================================
  // DISPOSE
  // =====================================

  @override
  void dispose() {

    titleController.dispose();

    descController.dispose();

    super.dispose();

  }

  // =====================================
  // INITIALIZE
  // =====================================

  Future<void> initialize() async {

    final prefs =
    await SharedPreferences.getInstance();

    teacherId =
        prefs.getString(
          "profile_id",
        ) ??
            "";

    if (teacherId.isEmpty) {

      setState(() {

        sectionsError =
        "Teacher session not found";

        isLoadingSections = false;

      });

      return;

    }

    await getSections();

    await getActivities();

  }

  // =====================================
  // GET SECTIONS
  // =====================================

  Future<void> getSections() async {

    try {

      setState(() {

        isLoadingSections = true;

        sectionsError = "";

      });

      final response =
      await http.get(

        Uri.parse(
          "${Api.teacherSections}/$teacherId",
        ),

      );

      final data =
      jsonDecode(response.body);

      if (response.statusCode == 200 &&
          data["success"] == true) {

        sections =
            data["sections"] ?? [];

        if (sections.isNotEmpty) {

          selectedSectionId =
              sections[0]["id"]
                  .toString();

          selectedSectionName =
          sections[0]["section_name"];

        }

        setState(() {

          isLoadingSections = false;

        });

      }

      else {

        setState(() {

          sectionsError =
              data["message"] ??
                  "Failed to load sections";

          isLoadingSections = false;

        });

      }

    }

    catch (e) {

      setState(() {

        sectionsError =
        "Error loading sections";

        isLoadingSections = false;

      });

    }

  }

  // =====================================
  // GET ACTIVITIES
  // =====================================

  Future<void> getActivities() async {

    try {

      setState(() {

        isLoadingActivities = true;

        activitiesError = "";

      });

      final response =
      await http.get(

        Uri.parse(
          "${Api.teacherActivities}/$teacherId",
        ),

      );

      final data =
      jsonDecode(response.body);

      if (response.statusCode == 200 &&
          data["success"] == true) {

        setState(() {

          activities =
              data["activities"] ?? [];

          isLoadingActivities = false;

        });

      }

      else {

        setState(() {

          activitiesError =
              data["message"] ??
                  "Failed to load activities";

          isLoadingActivities = false;

        });

      }

    }

    catch (e) {

      setState(() {

        activitiesError =
        "Error loading activities";

        isLoadingActivities = false;

      });

    }

  }

  // =====================================
  // ADD ACTIVITY
  // =====================================

  Future<void> addActivity() async {

    if (selectedSectionId == null) {

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(

          content: Text(
            "No section selected",
          ),

        ),

      );

      return;

    }

    if (titleController.text
        .trim()
        .isEmpty) {

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(

          content: Text(
            "Please enter activity title",
          ),

        ),

      );

      return;

    }

    if (descController.text
        .trim()
        .isEmpty) {

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(

          content: Text(
            "Please enter activity description",
          ),

        ),

      );

      return;

    }

    try {

      setState(() {

        isAdding = true;

      });

      final response =
      await http.post(

        Uri.parse(
          Api.teacherAddActivity,
        ),

        headers: {

          "Content-Type":
          "application/json",

        },

        body: jsonEncode({

          "teacher_id":
          teacherId,

          "section_id":
          selectedSectionId,

          "title":
          titleController.text.trim(),

          "description":
          descController.text.trim(),

        }),

      );

      final data =
      jsonDecode(response.body);

      if (response.statusCode == 200 &&
          data["success"] == true) {

        titleController.clear();

        descController.clear();

        ScaffoldMessenger.of(context)
            .showSnackBar(

          SnackBar(

            backgroundColor:
            Colors.green,

            content: Text(

              data["message"] ??
                  "Activity added successfully",

            ),

          ),

        );

        await getActivities();

      }

      else {

        ScaffoldMessenger.of(context)
            .showSnackBar(

          SnackBar(

            content: Text(

              data["message"] ??
                  "Failed to add activity",

            ),

          ),

        );

      }

    }

    catch (e) {

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(

          content: Text(
            "Error adding activity",
          ),

        ),

      );

    }

    finally {

      setState(() {

        isAdding = false;

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
          "Activities Management",
        ),

        backgroundColor:
        AppColors.primary,

        foregroundColor:
        Colors.white,

      ),

      body:
      isLoadingSections

          ? const Center(
        child:
        CircularProgressIndicator(),
      )

          : sectionsError
          .isNotEmpty

          ? buildSectionsError()

          : sections.isEmpty

          ? buildNoSections()

          : RefreshIndicator(

        onRefresh: () async {

          await getSections();

          await getActivities();

        },

        child: Padding(

          padding:
          const EdgeInsets.all(16),

          child: Column(

            children: [

              // =========================
              // FORM
              // =========================

              Card(

                shape:
                RoundedRectangleBorder(

                  borderRadius:
                  BorderRadius.circular(
                    16,
                  ),

                ),

                child: Padding(

                  padding:
                  const EdgeInsets.all(
                    16,
                  ),

                  child: Column(

                    children: [

                      // =====================
                      // SECTION
                      // =====================

                      DropdownButtonFormField<String>(

                        initialValue:
                        selectedSectionId,

                        decoration:
                        const InputDecoration(

                          labelText:
                          "Section",

                          border:
                          OutlineInputBorder(),

                        ),

                        items:
                        sections.map((s) {

                          return DropdownMenuItem<String>(

                            value:
                            s["id"]
                                .toString(),

                            child: Text(

                              "${s["grade_name"]} - ${s["section_name"]}",

                            ),

                          );

                        }).toList(),

                        onChanged: (val) {

                          final section =
                          sections.firstWhere(
                                (s) =>
                            s["id"]
                                .toString() ==
                                val,
                          );

                          setState(() {

                            selectedSectionId =
                                val;

                            selectedSectionName =
                            section["section_name"];

                          });

                        },

                      ),

                      const SizedBox(
                        height: 14,
                      ),

                      // =====================
                      // TITLE
                      // =====================

                      TextField(

                        controller:
                        titleController,

                        decoration:
                        const InputDecoration(

                          labelText:
                          "Activity Title",

                          border:
                          OutlineInputBorder(),

                        ),

                      ),

                      const SizedBox(
                        height: 14,
                      ),

                      // =====================
                      // DESCRIPTION
                      // =====================

                      TextField(

                        controller:
                        descController,

                        maxLines: 4,

                        decoration:
                        const InputDecoration(

                          labelText:
                          "Activity Description",

                          border:
                          OutlineInputBorder(),

                          alignLabelWithHint:
                          true,

                        ),

                      ),

                      const SizedBox(
                        height: 18,
                      ),

                      // =====================
                      // BUTTON
                      // =====================

                      SizedBox(

                        width:
                        double.infinity,

                        height: 50,

                        child:
                        ElevatedButton.icon(

                          onPressed:
                          isAdding
                              ? null
                              : addActivity,

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

                          icon:
                          isAdding

                              ? const SizedBox(

                            width: 18,

                            height: 18,

                            child:
                            CircularProgressIndicator(

                              color:
                              Colors.white,

                              strokeWidth:
                              2,

                            ),

                          )

                              : const Icon(

                            Icons.add,

                            color:
                            Colors.white,

                          ),

                          label: Text(

                            isAdding

                                ? "Adding..."

                                : "Add Activity",

                            style:
                            const TextStyle(

                              color:
                              Colors.white,

                              fontWeight:
                              FontWeight.bold,

                            ),

                          ),

                        ),

                      ),

                    ],

                  ),

                ),

              ),

              const SizedBox(
                height: 20,
              ),

              // =========================
              // TITLE
              // =========================

              const Align(

                alignment:
                Alignment.centerLeft,

                child: Text(

                  "My Activities",

                  style: TextStyle(

                    fontSize: 18,

                    fontWeight:
                    FontWeight.bold,

                  ),

                ),

              ),

              const SizedBox(
                height: 10,
              ),

              // =========================
              // ACTIVITIES LIST
              // =========================

              Expanded(

                child:
                isLoadingActivities

                    ? const Center(
                  child:
                  CircularProgressIndicator(),
                )

                    : activitiesError
                    .isNotEmpty

                    ? Center(
                  child: Text(
                    activitiesError,
                  ),
                )

                    : activities.isEmpty

                    ? const Center(

                  child: Column(

                    mainAxisAlignment:
                    MainAxisAlignment.center,

                    children: [

                      Icon(

                        Icons.event_busy,

                        size: 70,

                        color: Colors.grey,

                      ),

                      SizedBox(
                        height: 14,
                      ),

                      Text(
                        "No activities available",
                      ),

                    ],

                  ),

                )

                    : ListView.builder(

                  itemCount:
                  activities.length,

                  itemBuilder:
                      (_, i) {

                    final activity =
                    activities[i];

                    return Card(

                      margin:
                      const EdgeInsets.only(
                        bottom: 12,
                      ),

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

                        child: Column(

                          crossAxisAlignment:
                          CrossAxisAlignment
                              .start,

                          children: [

                            Row(

                              children: [

                                CircleAvatar(

                                  backgroundColor:
                                  AppColors
                                      .primary
                                      .withOpacity(
                                    0.1,
                                  ),

                                  child:
                                  const Icon(

                                    Icons.event,

                                    color:
                                    AppColors
                                        .primary,

                                  ),

                                ),

                                const SizedBox(
                                  width: 12,
                                ),

                                Expanded(

                                  child: Column(

                                    crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,

                                    children: [

                                      Text(

                                        activity["title"] ??
                                            "",

                                        style:
                                        const TextStyle(

                                          fontSize:
                                          16,

                                          fontWeight:
                                          FontWeight
                                              .bold,

                                        ),

                                      ),

                                      const SizedBox(
                                        height:
                                        4,
                                      ),

                                      Text(

                                        "Status: ${activity["status"] ?? "Pending"}",

                                        style:
                                        TextStyle(

                                          color:

                                          activity["status"] ==
                                              "approved"

                                              ? Colors.green

                                              : Colors.orange,

                                          fontWeight:
                                          FontWeight.w600,

                                        ),

                                      ),

                                    ],

                                  ),

                                ),

                              ],

                            ),

                            const SizedBox(
                              height: 14,
                            ),

                            Text(

                              activity["description"] ??
                                  "",

                              style:
                              const TextStyle(

                                fontSize: 14,

                                height: 1.5,

                              ),

                            ),

                            const SizedBox(
                              height: 14,
                            ),

                            Row(

                              children: [

                                const Icon(

                                  Icons.access_time,

                                  size: 16,

                                  color:
                                  Colors.grey,

                                ),

                                const SizedBox(
                                  width: 6,
                                ),

                                Text(

                                  formatDate(
                                    activity[
                                    "created_at"],
                                  ),

                                  style:
                                  const TextStyle(

                                    color:
                                    Colors.grey,

                                    fontSize:
                                    12,

                                  ),

                                ),

                              ],

                            ),

                          ],

                        ),

                      ),

                    );

                  },

                ),

              ),

            ],

          ),

        ),

      ),

    );

  }

  // =====================================
  // NO SECTIONS
  // =====================================

  Widget buildNoSections() {

    return const Center(

      child: Column(

        mainAxisAlignment:
        MainAxisAlignment.center,

        children: [

          Icon(

            Icons.school_outlined,

            size: 80,

            color: Colors.grey,

          ),

          SizedBox(
            height: 16,
          ),

          Text(

            "You are not assigned to any section",

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

  Widget buildSectionsError() {

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
            sectionsError,
          ),

          const SizedBox(
            height: 20,
          ),

          ElevatedButton(

            onPressed:
            getSections,

            child: const Text(
              "Retry",
            ),

          ),

        ],

      ),

    );

  }

}