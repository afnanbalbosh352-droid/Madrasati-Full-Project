import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../General/app_colors.dart';
import '../api.dart';

class AdminClassScheduleScreen extends StatefulWidget {

  const AdminClassScheduleScreen({
    super.key,
  });

  @override
  State<AdminClassScheduleScreen> createState() =>
      _AdminClassScheduleScreenState();

}

class _AdminClassScheduleScreenState
    extends State<AdminClassScheduleScreen> {

  // =====================================================
  // DATA
  // =====================================================

  List grades = [];

  List sections = [];

  List subjects = [];

  bool isLoading = false;

  bool isSaving = false;

  String errorMessage = "";

  String? selectedGradeId;

  String? selectedSectionId;

  final List<String> periods = [

    "C1",
    "C2",
    "C3",
    "C4",
    "C5",
    "C6",

  ];

  final List<String> days = [

    "Sun",
    "Mon",
    "Tue",
    "Wed",
    "Thu",

  ];

  Map<String, List<dynamic>>
  scheduleData = {};

  // =====================================================
  // INIT
  // =====================================================

  @override
  void initState() {

    super.initState();

    initialize();

  }

  // =====================================================
  // INITIALIZE
  // =====================================================

  Future<void> initialize() async {

    setState(() {

      isLoading = true;

    });

    try {

      // =================================
      // INIT EMPTY TABLE
      // =================================

      for (var day in days) {

        scheduleData[day] =
            List.generate(

              periods.length,

                  (_) => null,

            );

      }

      await Future.wait([

        getGrades(),

        getSubjects(),

      ]);

    }

    catch (e) {

      debugPrint(
        "INITIALIZE ERROR => $e",
      );

      errorMessage =
      "Initialization failed";

    }

    finally {

      setState(() {

        isLoading = false;

      });

    }

  }

  // =====================================================
  // GET GRADES
  // =====================================================

  Future<void> getGrades() async {

    try {

      final response =
      await http.get(

        Uri.parse(
          Api.adminGrades,
        ),

      );

      debugPrint(
        "GRADES => ${response.body}",
      );

      final data =
      jsonDecode(response.body);

      if (
      response.statusCode == 200 &&
          data["success"] == true
      ) {

        grades =
            data["grades"] ?? [];

        if (grades.isNotEmpty) {

          selectedGradeId =
              grades.first["id"]
                  .toString();

          await getSections();

        }

      }

      else {

        errorMessage =
            data["message"] ??
                "Failed loading grades";

      }

    }

    catch (e) {

      debugPrint(
        "GET GRADES ERROR => $e",
      );

      errorMessage =
      "Error loading grades";

    }

  }

  // =====================================================
  // GET SECTIONS
  // =====================================================

  Future<void> getSections() async {

    try {

      final response =
      await http.get(

        Uri.parse(
          Api.adminSections,
        ),

      );

      debugPrint(
        "SECTIONS => ${response.body}",
      );

      final data =
      jsonDecode(response.body);

      if (
      response.statusCode == 200 &&
          data["success"] == true
      ) {

        final allSections =
            data["sections"] ?? [];

        sections =
            allSections.where((section) {

              return section["grade_level_id"]
                  .toString() ==
                  selectedGradeId;

            }).toList();

        if (sections.isNotEmpty) {

          selectedSectionId =
              sections.first["id"]
                  .toString();

          await getSchedule();

        }

        else {

          selectedSectionId = null;

          setState(() {});

        }

      }

      else {

        errorMessage =
            data["message"] ??
                "Failed loading sections";

      }

    }

    catch (e) {

      debugPrint(
        "GET SECTIONS ERROR => $e",
      );

      errorMessage =
      "Error loading sections";

    }

  }

  // =====================================================
  // GET SUBJECTS
  // =====================================================

  Future<void> getSubjects() async {

    try {

      final response =
      await http.get(

        Uri.parse(
          Api.adminSubjects,
        ),

      );

      debugPrint(
        "SUBJECTS => ${response.body}",
      );

      final data =
      jsonDecode(response.body);

      if (
      response.statusCode == 200 &&
          data["success"] == true
      ) {

        subjects =
            data["subjects"] ?? [];

      }

      else {

        errorMessage =
            data["message"] ??
                "Failed loading subjects";

      }

    }

    catch (e) {

      debugPrint(
        "GET SUBJECTS ERROR => $e",
      );

      errorMessage =
      "Error loading subjects";

    }

  }

  // =====================================================
  // GET SCHEDULE
  // =====================================================

  Future<void> getSchedule() async {

    try {

      final response =
      await http.get(

        Uri.parse(

          "${Api.adminClassSchedule}"
              "/$selectedSectionId",

        ),

      );

      debugPrint(
        "SCHEDULE => ${response.body}",
      );

      final data =
      jsonDecode(response.body);

      // =================================
      // RESET TABLE
      // =================================

      for (var day in days) {

        scheduleData[day] =
            List.generate(

              periods.length,

                  (_) => null,

            );

      }

      if (
      response.statusCode == 200 &&
          data["success"] == true
      ) {

        final schedules =
            data["schedule"] ?? [];

        for (var item in schedules) {

          final day =
          item["day"];

          final period =
          item["period"];

          final subjectId =
          item["subject_id"];

          final periodIndex =
          periods.indexOf(period);

          if (
          scheduleData.containsKey(day) &&
              periodIndex != -1
          ) {

            scheduleData[day]![periodIndex] =
                subjectId.toString();

          }

        }

      }

      else {

        errorMessage =
            data["message"] ??
                "Failed loading schedule";

      }

      setState(() {});

    }

    catch (e) {

      debugPrint(
        "GET SCHEDULE ERROR => $e",
      );

      errorMessage =
      "Error loading schedule";

      setState(() {});

    }

  }

  // =====================================================
  // SAVE SCHEDULE
  // =====================================================

  Future<void> saveSchedule() async {

    try {

      setState(() {

        isSaving = true;

      });

      List schedule = [];

      for (var day in days) {

        for (
        int i = 0;
        i < periods.length;
        i++
        ) {

          final subjectId =
          scheduleData[day]![i];

          if (subjectId != null) {

            schedule.add({

              "day_of_week":
              day,

              "period_number":
              periods[i],

              "subject_id":
              subjectId,

              "teacher_id":
              null,

              "start_time":
              "08:00",

              "end_time":
              "09:00",

            });

          }

        }

      }

      debugPrint(
        jsonEncode(schedule),
      );

      final response =
      await http.post(

        Uri.parse(
          Api.adminAddClassSchedule,
        ),

        headers: {

          "Content-Type":
          "application/json",

        },

        body: jsonEncode({

          "section_id":
          selectedSectionId,

          "schedule":
          schedule,

        }),

      );

      debugPrint(
        "SAVE => ${response.body}",
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

            backgroundColor:
            Colors.green,

            content: Text(
              "Schedule saved successfully",
            ),

          ),

        );

      }

      else {

        ScaffoldMessenger.of(context)
            .showSnackBar(

          SnackBar(

            backgroundColor:
            Colors.red,

            content: Text(

              data["message"] ??
                  "Failed saving schedule",

            ),

          ),

        );

      }

    }

    catch (e) {

      debugPrint(
        "SAVE ERROR => $e",
      );

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(

          content:
          Text(
            "Error saving schedule",
          ),

        ),

      );

    }

    finally {

      setState(() {

        isSaving = false;

      });

    }

  }

  // =====================================================
  // BUILD
  // =====================================================

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
      AppColors.background,

      appBar: AppBar(

        title:
        const Text(
          "Class Schedule Builder",
        ),

        backgroundColor:
        AppColors.primary,

        foregroundColor:
        Colors.white,

        actions: [

          IconButton(

            onPressed:
            isSaving
                ? null
                : saveSchedule,

            icon:

            isSaving

                ? const Padding(

              padding:
              EdgeInsets.all(10),

              child:
              CircularProgressIndicator(

                color:
                Colors.white,

                strokeWidth: 2,

              ),

            )

                : const Icon(
              Icons.save,
            ),

          ),

        ],

      ),

      body:

      isLoading

          ? const Center(
        child:
        CircularProgressIndicator(),
      )

          : errorMessage.isNotEmpty

          ? Center(
        child:
        Text(errorMessage),
      )

          : Column(

        children: [

          // =================================
          // FILTERS
          // =================================

          Card(

            margin:
            const EdgeInsets.all(12),

            child:
            Padding(

              padding:
              const EdgeInsets.all(14),

              child:
              Row(

                children: [

                  Expanded(

                    child:
                    DropdownButtonFormField<String>(

                      initialValue:

                      grades.any(
                            (g) =>
                        g["id"].toString() ==
                            selectedGradeId,
                      )

                          ? selectedGradeId

                          : null,

                      decoration:
                      const InputDecoration(

                        labelText:
                        "Grade",

                      ),

                      items:

                      grades.map<
                          DropdownMenuItem<String>>(

                            (grade) {

                          return DropdownMenuItem<String>(

                            value:
                            grade["id"]
                                .toString(),

                            child:
                            Text(
                              grade["name"],
                            ),

                          );

                        },

                      ).toList(),

                      onChanged:
                          (value) async {

                        selectedGradeId =
                            value;

                        await getSections();

                        setState(() {});

                      },

                    ),

                  ),

                  const SizedBox(width: 12),

                  Expanded(

                    child:
                    DropdownButtonFormField<String>(

                      initialValue:

                      sections.any(
                            (s) =>
                        s["id"].toString() ==
                            selectedSectionId,
                      )

                          ? selectedSectionId

                          : null,

                      decoration:
                      const InputDecoration(

                        labelText:
                        "Section",

                      ),

                      items:

                      sections.map<
                          DropdownMenuItem<String>>(

                            (section) {

                          return DropdownMenuItem<String>(

                            value:
                            section["id"]
                                .toString(),

                            child:
                            Text(
                              section["name"],
                            ),

                          );

                        },

                      ).toList(),

                      onChanged:
                          (value) async {

                        selectedSectionId =
                            value;

                        await getSchedule();

                        setState(() {});

                      },

                    ),

                  ),

                ],

              ),

            ),

          ),

          // =================================
          // TABLE
          // =================================

          Expanded(

            child:
            SingleChildScrollView(

              scrollDirection:
              Axis.horizontal,

              child:
              SingleChildScrollView(

                child:
                DataTable(

                  border:
                  TableBorder.all(

                    color:
                    Colors.grey.shade300,

                  ),

                  columns: [

                    const DataColumn(

                      label:
                      Text(
                        "Period",
                      ),

                    ),

                    ...days.map(

                          (day) {

                        return DataColumn(

                          label:
                          Text(day),

                        );

                      },

                    ),

                  ],

                  rows:
                  List.generate(

                    periods.length,

                        (rowIndex) {

                      return DataRow(

                        cells: [

                          DataCell(

                            Text(
                              periods[rowIndex],
                            ),

                          ),

                          ...days.map(

                                (day) {

                              return DataCell(

                                DropdownButton<String?>(

                                  value:

                                  scheduleData[day] != null

                                      ? scheduleData[day]![rowIndex]

                                      : null,

                                  isExpanded:
                                  true,

                                  underline:
                                  const SizedBox(),

                                  hint:
                                  const Text("-"),

                                  items: [

                                    const DropdownMenuItem<String?>(

                                      value:
                                      null,

                                      child:
                                      Text("-"),

                                    ),

                                    ...subjects.map<
                                        DropdownMenuItem<String?>>(
                                          (subject) {

                                        return DropdownMenuItem<String?>(

                                          value:
                                          subject["id"]
                                              .toString(),

                                          child:
                                          Text(

                                            subject["name"],

                                            overflow:
                                            TextOverflow
                                                .ellipsis,

                                          ),

                                        );

                                      },

                                    ),

                                  ],

                                  onChanged:
                                      (value) {

                                    setState(() {

                                      scheduleData[day]![rowIndex] =
                                          value;

                                    });

                                  },

                                ),

                              );

                            },

                          ),

                        ],

                      );

                    },

                  ),

                ),

              ),

            ),

          ),

        ],

      ),

    );

  }

}