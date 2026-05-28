import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../General/app_colors.dart';
import '../api.dart';

class NotificationScreen extends StatefulWidget {
  final bool isViewOnly;
  const NotificationScreen({super.key, this.isViewOnly = false});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List notifications = [];
  bool isLoading = true;

  // المتغيرات الجديدة للبيانات الديناميكية
  List<dynamic> allSections = [];
  List<String> uniqueGrades = [];
  String? selectedGradeName;
  String? selectedSectionId;

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  // جلب البيانات من السيرفر
  Future<void> fetchData() async {
    final prefs = await SharedPreferences.getInstance();
    final teacherId = prefs.getString("profile_id");

    try {
      // 1. جلب الشعب والصفوف
      final sectionResponse = await http.get(Uri.parse("${Api.baseUrl}/api/sections/$teacherId"));
      
      // 2. جلب الإشعارات السابقة
      String url = widget.isViewOnly 
          ? "${Api.teacherNotifications}?teacher_id=$teacherId" 
          : "${Api.teacherSentNotifications}?teacher_id=$teacherId";
      final notifyResponse = await http.get(Uri.parse(url));

      if (sectionResponse.statusCode == 200 && notifyResponse.statusCode == 200) {
        setState(() {
          allSections = json.decode(sectionResponse.body)['sections'];
          uniqueGrades = allSections.map((s) => s['grade_name'].toString()).toSet().toList();
          notifications = json.decode(notifyResponse.body);
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Future<void> sendNotification() async {
    final prefs = await SharedPreferences.getInstance();
    final teacherId = prefs.getString("profile_id");

    if (selectedSectionId == null || titleController.text.isEmpty || descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("يرجى تعبئة جميع الحقول")));
      return;
    }

    try {
      final response = await http.post(
        Uri.parse("${Api.baseUrl}/api/send-notification"),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "teacher_id": teacherId,
          "section_id": selectedSectionId,
          "title": titleController.text,
          "message": descriptionController.text,
          "type": "general",
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          // إضافة الإشعار الجديد للقائمة فوراً ليظهر تحت البوكس
          notifications.insert(0, {
            "title": titleController.text,
            "message": descriptionController.text
          });
          titleController.clear();
          descriptionController.clear();
          selectedGradeName = null;
          selectedSectionId = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("تم الإرسال بنجاح")));
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.isViewOnly ? "Incoming Notifications" : "Create Notification"),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  if (!widget.isViewOnly)
                    Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                // اختيار الصف
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    decoration: const InputDecoration(labelText: "الصف (Class)", border: OutlineInputBorder()),
                                    items: uniqueGrades.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                                    onChanged: (val) => setState(() {
                                      selectedGradeName = val;
                                      selectedSectionId = null;
                                    }),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                // اختيار الشعبة
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    decoration: const InputDecoration(labelText: "الشعبة (Section)", border: OutlineInputBorder()),
                                    initialValue: selectedSectionId,
                                    items: allSections
                                        .where((s) => s['grade_name'] == selectedGradeName)
                                        .map((s) => DropdownMenuItem(value: s['id'].toString(), child: Text(s['section_name'])))
                                        .toList(),
                                    onChanged: (val) => setState(() => selectedSectionId = val),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            TextField(controller: titleController, decoration: const InputDecoration(labelText: "Title", border: OutlineInputBorder())),
                            const SizedBox(height: 10),
                            TextField(controller: descriptionController, maxLines: 3, decoration: const InputDecoration(labelText: "Description", border: OutlineInputBorder())),
                            const SizedBox(height: 15),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.all(15)),
                                onPressed: sendNotification,
                                child: const Text("Send Notification", style: TextStyle(color: Colors.white)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final item = notifications[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          leading: const Icon(Icons.notifications_active, color: AppColors.primary),
                          title: Text(item['title'] ?? ""),
                          subtitle: Text(item['message'] ?? ""),
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