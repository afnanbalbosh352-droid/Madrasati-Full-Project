import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../General/app_colors.dart';
import '../api.dart';

class ChatScreen extends StatefulWidget {

  final String teacherName;

  final String teacherId;

  const ChatScreen({

    super.key,

    required this.teacherName,

    required this.teacherId,

  });

  @override
  State<ChatScreen> createState() =>
      _ChatScreenState();

}

class _ChatScreenState
    extends State<ChatScreen> {

  final TextEditingController
  messageController =
  TextEditingController();

  List messages = [];

  bool isLoading = true;

  String chatId = "";

  String userId = "";

  // =========================================
  // INIT
  // =========================================

  @override
  void initState() {

    super.initState();

    initializeChat();

  }

  // =========================================
  // INITIALIZE CHAT
  // =========================================

  Future<void> initializeChat() async {

    try {

      final prefs =
      await SharedPreferences.getInstance();

      userId =
          prefs.getString("user_id") ?? "";

      final studentId =
          prefs.getString("profile_id") ?? "";

      final response = await http.post(

        Uri.parse(Api.createOrGetChat),

        headers: {
          "Content-Type": "application/json",
        },

        body: jsonEncode({

          "student_id": studentId,

          "teacher_id":
          widget.teacherId,

        }),

      );

      final data =
      jsonDecode(response.body);

      if (response.statusCode == 200 &&
          data["success"] == true) {

        chatId =
        data["chat"]["id"];

        await getMessages();

      }

      else {

        setState(() {
          isLoading = false;
        });

      }

    }

    catch (error) {

      print(error);

      setState(() {
        isLoading = false;
      });

    }

  }

  // =========================================
  // GET MESSAGES
  // =========================================

  Future<void> getMessages() async {

    try {

      final response = await http.get(

        Uri.parse(
          "${Api.getMessages}/$chatId",
        ),

      );

      final data =
      jsonDecode(response.body);

      if (response.statusCode == 200 &&
          data["success"] == true) {

        setState(() {

          messages =
          data["messages"];

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

      print(error);

      setState(() {
        isLoading = false;
      });

    }

  }

  // =========================================
  // SEND MESSAGE
  // =========================================

  Future<void> sendMessage() async {

    if (messageController.text
        .trim()
        .isEmpty) {

      return;

    }

    try {

      final response = await http.post(

        Uri.parse(Api.sendMessage),

        headers: {
          "Content-Type": "application/json",
        },

        body: jsonEncode({

          "chat_id": chatId,

          "sender_user_id":
          userId,

          "message":
          messageController.text.trim(),

        }),

      );

      final data =
      jsonDecode(response.body);

      if (response.statusCode == 200 &&
          data["success"] == true) {

        messageController.clear();

        getMessages();

      }

    }

    catch (error) {

      print(error);

    }

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title: Text(
          widget.teacherName,
        ),

        backgroundColor:
        AppColors.primary,

        foregroundColor:
        Colors.white,

      ),

      body: Column(

        children: [

          // =================================
          // MESSAGES
          // =================================

          Expanded(

            child: isLoading

                ? const Center(
              child:
              CircularProgressIndicator(),
            )

                : messages.isEmpty

                ? const Center(
              child: Text(
                "No Messages",
              ),
            )

                : ListView.builder(

              padding:
              const EdgeInsets.all(16),

              itemCount:
              messages.length,

              itemBuilder:
                  (context, index) {

                final msg =
                messages[index];

                final isMe =
                    msg["sender_user_id"] ==
                        userId;

                return buildChatBubble(

                  msg["message"],

                  isMe,

                );

              },

            ),

          ),

          // =================================
          // INPUT
          // =================================

          buildMessageInput(),

        ],

      ),

    );

  }

  // =========================================
  // CHAT BUBBLE
  // =========================================

  Widget buildChatBubble(

      String text,
      bool isMe,

      ) {

    return Align(

      alignment:
      isMe
          ? Alignment.centerRight
          : Alignment.centerLeft,

      child: Container(

        margin:
        const EdgeInsets.symmetric(
          vertical: 5,
        ),

        padding:
        const EdgeInsets.symmetric(

          horizontal: 14,
          vertical: 10,

        ),

        decoration: BoxDecoration(

          color:
          isMe
              ? AppColors.primary
              : Colors.grey[300],

          borderRadius:
          BorderRadius.circular(15),

        ),

        child: Text(

          text,

          style: TextStyle(

            color:
            isMe
                ? Colors.white
                : Colors.black,

          ),

        ),

      ),

    );

  }

  // =========================================
  // INPUT
  // =========================================

  Widget buildMessageInput() {

    return Padding(

      padding: const EdgeInsets.all(8),

      child: Row(

        children: [

          Expanded(

            child: TextField(

              controller:
              messageController,

              decoration: InputDecoration(

                hintText:
                "Type a message...",

                border:
                OutlineInputBorder(

                  borderRadius:
                  BorderRadius.circular(25),

                ),

                contentPadding:
                const EdgeInsets.symmetric(
                  horizontal: 20,
                ),

              ),

            ),

          ),

          const SizedBox(width: 8),

          CircleAvatar(

            backgroundColor:
            AppColors.primary,

            child: IconButton(

              icon: const Icon(
                Icons.send,
                color: Colors.white,
              ),

              onPressed:
              sendMessage,

            ),

          ),

        ],

      ),

    );

  }

}