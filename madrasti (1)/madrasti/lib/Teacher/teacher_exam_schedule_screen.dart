import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../General/app_colors.dart';
import '../api.dart';

class TeacherExamScheduleScreen extends StatefulWidget {
  const TeacherExamScheduleScreen({super.key});

  @override
  State<TeacherExamScheduleScreen> createState() => _TeacherExamScheduleScreenState();
}

class _TeacherExamScheduleScreenState extends State<TeacherExamScheduleScreen> {
  // المتغيرات الأساسية
  List subjects = []; // قائمة المواد والشعب
  List examSchedule = []; // بيانات الجدول
  
  String? selectedSubjectId;
  String? selectedSectionId;
  
  bool isLoadingSubjects = true;
  bool isLoadingExams = false;

  @override
  void initState() {
    super.initState();
    getTeacherSubjects();
  }

  // 1. جلب المواد والشعب الخاصة بالمعلم
  Future<void> getTeacherSubjects() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final teacherId = prefs.getString("profile_id");

      // ملاحظة: تأكدي أن هذا الرابط موجود في ملف Api.dart
      final response = await http.get(
        Uri.parse("${Api.teacherSubjects}/$teacherId"),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data["success"] == true) {
        setState(() {
          subjects = data["subjects"];
          isLoadingSubjects = false;
        });
      } else {
        setState(() { isLoadingSubjects = false; });
      }
    } catch (e) {
      print("Error fetching subjects: $e");
      setState(() { isLoadingSubjects = false; });
    }
  }

  // 2. جلب جدول الامتحانات بناءً على الشعبة المختارة
  Future<void> getExamSchedule(String sectionId) async {
    setState(() {
      isLoadingExams = true;
      examSchedule = [];
    });

    try {
      // نفترض أن الرابط يستقبل الـ sectionId
      final response = await http.get(
        Uri.parse("${Api.baseUrl}/feature/exam-schedule/$sectionId"),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data["success"] == true) {
        setState(() {
          examSchedule = data["exams"];
          isLoadingExams = false;
        });
      } else {
        setState(() { isLoadingExams = false; });
      }
    } catch (e) {
      print("Error fetching exams: $e");
      setState(() { isLoadingExams = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Exam Schedule"),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: isLoadingSubjects
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // --- قسم الاختيار (Dropdowns) ---
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                    ),
                    child: Column(
                      children: [
                        // اختيار المادة
                        DropdownButtonFormField<String>(
                          decoration: const InputDecoration(labelText: "Select Subject"),
                          initialValue: selectedSubjectId,
                          items: subjects.map((s) {
                            return DropdownMenuItem<String>(
                              value: s['id'].toString(),
                              child: Text(s['subject_name']),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setState(() {
                              selectedSubjectId = val;
                              selectedSectionId = null; // تصفير الشعبة عند تغيير المادة
                            });
                          },
                        ),
                        const SizedBox(height: 15),
                        // اختيار الشعبة (تظهر فقط بعد اختيار المادة)
                        DropdownButtonFormField<String>(
                          decoration: const InputDecoration(labelText: "Select Section"),
                          initialValue: selectedSectionId,
                          items: subjects
                              .where((s) => s['id'].toString() == selectedSubjectId)
                              .expand((s) => s['sections'] as List)
                              .map((sec) {
                            return DropdownMenuItem<String>(
                              value: sec['id'].toString(),
                              child: Text(sec['section_name']),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setState(() {
                              selectedSectionId = val;
                            });
                            if (val != null) getExamSchedule(val);
                          },
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),

                  // --- قسم عرض الجدول ---
                  Expanded(
                    child: isLoadingExams
                        ? const Center(child: CircularProgressIndicator())
                        : examSchedule.isEmpty
                            ? const Center(child: Text("Select a section to see the schedule"))
                            : Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: DataTable(
                                    columns: const [
                                      DataColumn(label: Text("Date")),
                                      DataColumn(label: Text("Time")),
                                      DataColumn(label: Text("Subject")),
                                      DataColumn(label: Text("Room")),
                                    ],
                                    rows: examSchedule.map((exam) {
                                      return DataRow(cells: [
                                        DataCell(Text(exam['exam_date'] ?? "-")),
                                        DataCell(Text(exam['exam_time'] ?? "-")),
                                        DataCell(Text(exam['subject_name'] ?? "-")),
                                        DataCell(Text(exam['room_number'] ?? "-")),
                                      ]);
                                    }).toList(),
                                  ),
                                ),
                              ),
                  ),
                ],
              ),
            ),
    );
  }
}