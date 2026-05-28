import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../General/app_colors.dart';
import '../api.dart';

class MessagesScreen extends StatefulWidget {

  final String name;

  const MessagesScreen({

    super.key,

    required this.name,

  });

  @override
  State<MessagesScreen> createState() =>
      _MessagesScreenState();

}

class _MessagesScreenState
    extends State<MessagesScreen> {

  // =====================================
  // CONTROLLERS
  // =====================================

  final TextEditingController
  controller =
  TextEditingController();

  final ScrollController
  scrollController =
  ScrollController();

  // =====================================
  // DATA
  // =====================================

  List chats = [];

  List messages = [];

  bool isLoadingChats = true;

  bool isLoadingMessages = false;

  bool isSending = false;

  String errorMessage = "";

  String messagesError = "";

  String? selectedChatId;

  String? selectedStudentName;

  String teacherId = "";

  String userId = "";

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

    controller.dispose();

    scrollController.dispose();

    super.dispose();

  }

  // =====================================
  // INITIALIZE
  // =====================================

  Future<void> initialize() async {

    try {

      final prefs =
      await SharedPreferences.getInstance();

      teacherId =
          prefs.getString(
            "profile_id",
          ) ??
              "";

      userId =
          prefs.getString(
            "user_id",
          ) ??
              "";

      if (teacherId.isEmpty ||
          userId.isEmpty) {

        setState(() {

          errorMessage =
          "Teacher session not found";

          isLoadingChats = false;

        });

        return;

      }

      await getChats();

    }

    catch (e) {

      setState(() {

        errorMessage =
        "Initialization failed";

        isLoadingChats = false;

      });

    }

  }

  // =====================================
  // GET CHATS
  // =====================================

  Future<void> getChats() async {

    try {

      setState(() {

        isLoadingChats = true;

        errorMessage = "";

      });

      final response =
      await http.get(

        Uri.parse(
          "${Api.teacherChats}/$teacherId",
        ),

      );

      final data =
      jsonDecode(response.body);

      if (response.statusCode == 200 &&
          data["success"] == true) {

        chats =
            data["chats"] ?? [];

        if (chats.isNotEmpty) {

          selectedChatId =
          chats[0]["chat_id"];

          selectedStudentName =
          chats[0]["student_name"];

          await getMessages(
            selectedChatId!,
          );

        }

        setState(() {

          isLoadingChats = false;

        });

      }

      else {

        setState(() {

          errorMessage =
              data["message"] ??
                  "Failed to load chats";

          isLoadingChats = false;

        });

      }

    }

    catch (e) {

      setState(() {

        errorMessage =
        "Error loading chats";

        isLoadingChats = false;

      });

    }

  }

  // =====================================
  // GET MESSAGES
  // =====================================

  Future<void> getMessages(
      String chatId,
      ) async {

    try {

      setState(() {

        isLoadingMessages = true;

        messagesError = "";

      });

      final response =
      await http.get(

        Uri.parse(
          "${Api.chatMessages}/$chatId",
        ),

      );

      final data =
      jsonDecode(response.body);

      if (response.statusCode == 200 &&
          data["success"] == true) {

        setState(() {

          messages =
              data["messages"] ?? [];

          isLoadingMessages = false;

        });

        scrollToBottom();

      }

      else {

        setState(() {

          messagesError =
              data["message"] ??
                  "Failed to load messages";

          isLoadingMessages = false;

        });

      }

    }

    catch (e) {

      setState(() {

        messagesError =
        "Error loading messages";

        isLoadingMessages = false;

      });

    }

  }

  // =====================================
  // SELECT CHAT
  // =====================================

  Future<void> selectChat(
      Map chat,
      ) async {

    setState(() {

      selectedChatId =
      chat["chat_id"];

      selectedStudentName =
      chat["student_name"];

      messages = [];

    });

    await getMessages(
      selectedChatId!,
    );

  }

  // =====================================
  // SEND MESSAGE
  // =====================================

  Future<void> sendMessage() async {

    if (controller.text
        .trim()
        .isEmpty) {

      return;

    }

    if (selectedChatId == null) {

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(

          content: Text(
            "Please select chat first",
          ),

        ),

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
          Api.sendMessage,
        ),

        headers: {

          "Content-Type":
          "application/json",

        },

        body: jsonEncode({

          "chat_id":
          selectedChatId,

          "sender_user_id":
          userId,

          "message":
          controller.text.trim(),

        }),

      );

      final data =
      jsonDecode(response.body);

      if (response.statusCode == 200 &&
          data["success"] == true) {

        controller.clear();

        await getMessages(
          selectedChatId!,
        );

      }

      else {

        ScaffoldMessenger.of(context)
            .showSnackBar(

          SnackBar(

            content: Text(

              data["message"] ??
                  "Failed to send message",

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
            "Error sending message",
          ),

        ),

      );

    }

    finally {

      setState(() {

        isSending = false;

      });

    }

  }

  // =====================================
  // AUTO SCROLL
  // =====================================

  void scrollToBottom() {

    Future.delayed(
      const Duration(milliseconds: 200),
          () {

        if (scrollController.hasClients) {

          scrollController.animateTo(

            scrollController.position.maxScrollExtent,

            duration:
            const Duration(milliseconds: 300),

            curve: Curves.easeOut,

          );

        }

      },

    );

  }

  // =====================================
  // FORMAT TIME
  // =====================================

  String formatTime(String dateTime) {

    try {

      final date =
      DateTime.parse(dateTime);

      final hour =
      date.hour > 12
          ? date.hour - 12
          : date.hour;

      final minute =
      date.minute
          .toString()
          .padLeft(2, '0');

      final period =
      date.hour >= 12
          ? "PM"
          : "AM";

      return "$hour:$minute $period";

    }

    catch (e) {

      return "";

    }

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
      AppColors.background,

      appBar: AppBar(

        title: const Text(
          "Messages",
        ),

        backgroundColor:
        AppColors.primary,

        foregroundColor:
        Colors.white,

      ),

      body:
      isLoadingChats

          ? const Center(
        child:
        CircularProgressIndicator(),
      )

          : errorMessage
          .isNotEmpty

          ? buildErrorState()

          : chats.isEmpty

          ? buildEmptyChats()

          : Row(

        children: [

          // =================================
          // CHAT LIST
          // =================================

          buildChatsList(),

          // =================================
          // CHAT AREA
          // =================================

          Expanded(

            child: Column(

              children: [

                buildHeader(),

                Expanded(

                  child:
                  isLoadingMessages

                      ? const Center(
                    child:
                    CircularProgressIndicator(),
                  )

                      : messagesError
                      .isNotEmpty

                      ? Center(
                    child: Text(
                      messagesError,
                    ),
                  )

                      : messages
                      .isEmpty

                      ? const Center(
                    child: Text(
                      "No messages yet",
                    ),
                  )

                      : ListView.builder(

                    controller:
                    scrollController,

                    padding:
                    const EdgeInsets.symmetric(
                      horizontal:
                      14,
                      vertical:
                      10,
                    ),

                    itemCount:
                    messages.length,

                    itemBuilder:
                        (_, i) {

                      final message =
                      messages[i];

                      final isMe =

                          message[
                          "sender_user_id"] ==
                              userId;

                      return Align(

                        alignment:
                        isMe
                            ? Alignment
                            .centerRight
                            : Alignment
                            .centerLeft,

                        child:
                        Container(

                          constraints:
                          BoxConstraints(

                            maxWidth:
                            MediaQuery.of(
                              context,
                            ).size.width *
                                0.65,

                          ),

                          margin:
                          const EdgeInsets.symmetric(
                            vertical: 4,
                          ),

                          padding:
                          const EdgeInsets.symmetric(

                            horizontal:
                            14,

                            vertical:
                            10,

                          ),

                          decoration:
                          BoxDecoration(

                            color:
                            isMe
                                ? AppColors
                                .primary
                                : Colors
                                .white,

                            borderRadius:
                            BorderRadius.only(

                              topLeft:
                              const Radius.circular(
                                18,
                              ),

                              topRight:
                              const Radius.circular(
                                18,
                              ),

                              bottomLeft:
                              Radius.circular(
                                isMe
                                    ? 18
                                    : 4,
                              ),

                              bottomRight:
                              Radius.circular(
                                isMe
                                    ? 4
                                    : 18,
                              ),

                            ),

                            boxShadow: [

                              BoxShadow(

                                color:
                                Colors.black
                                    .withOpacity(
                                  0.05,
                                ),

                                blurRadius:
                                4,

                                offset:
                                const Offset(
                                  0,
                                  2,
                                ),

                              ),

                            ],

                          ),

                          child:
                          Column(

                            crossAxisAlignment:
                            CrossAxisAlignment
                                .end,

                            children: [

                              Text(

                                message[
                                "message"],

                                style:
                                TextStyle(

                                  fontSize:
                                  15,

                                  height:
                                  1.4,

                                  color:
                                  isMe
                                      ? Colors
                                      .white
                                      : Colors
                                      .black87,

                                ),

                              ),

                              const SizedBox(
                                height: 4,
                              ),

                              Text(

                                message[
                                "created_at"] !=
                                    null

                                    ? formatTime(
                                  message[
                                  "created_at"],
                                )

                                    : "",

                                style:
                                TextStyle(

                                  fontSize:
                                  11,

                                  color:
                                  isMe
                                      ? Colors
                                      .white70
                                      : Colors
                                      .grey,

                                ),

                              ),

                            ],

                          ),

                        ),

                      );

                    },

                  ),

                ),

                buildInput(),

              ],

            ),

          ),

        ],

      ),

    );

  }

  // =====================================
  // CHAT LIST
  // =====================================

  Widget buildChatsList() {

    return Container(

      width: 110,

      decoration:
      const BoxDecoration(

        color: Colors.white,

        border: Border(

          right: BorderSide(
            color: Colors.black12,
          ),

        ),

      ),

      child: ListView.builder(

        itemCount: chats.length,

        itemBuilder: (_, index) {

          final chat =
          chats[index];

          final isSelected =
              selectedChatId ==
                  chat["chat_id"];

          return GestureDetector(

            onTap: () {

              selectChat(chat);

            },

            child: Container(

              padding:
              const EdgeInsets.symmetric(
                vertical: 14,
              ),

              color:
              isSelected

                  ? AppColors.primary
                  .withOpacity(0.1)

                  : Colors.transparent,

              child: Column(

                children: [

                  CircleAvatar(

                    radius: 25,

                    backgroundColor:

                    isSelected

                        ? AppColors.primary

                        : Colors.grey[300],

                    child: Text(

                      chat["student_name"][0],

                      style: TextStyle(

                        color:
                        isSelected

                            ? Colors.white

                            : Colors.black,

                        fontWeight:
                        FontWeight.bold,

                      ),

                    ),

                  ),

                  const SizedBox(
                    height: 6,
                  ),

                  Padding(

                    padding:
                    const EdgeInsets.symmetric(
                      horizontal: 4,
                    ),

                    child: Text(

                      chat["student_name"],

                      maxLines: 1,

                      overflow:
                      TextOverflow.ellipsis,

                      textAlign:
                      TextAlign.center,

                    ),

                  ),

                ],

              ),

            ),

          );

        },

      ),

    );

  }

  // =====================================
  // HEADER
  // =====================================

  Widget buildHeader() {

    return Container(

      width: double.infinity,

      padding:
      const EdgeInsets.all(16),

      decoration:
      const BoxDecoration(

        color: Colors.white,

        border: Border(

          bottom: BorderSide(
            color: Colors.black12,
          ),

        ),

      ),

      child: Row(

        children: [

          CircleAvatar(

            backgroundColor:
            AppColors.primary,

            child: Text(

              selectedStudentName != null

                  ? selectedStudentName![0]

                  : "?",

              style:
              const TextStyle(
                color: Colors.white,
              ),

            ),

          ),

          const SizedBox(
            width: 12,
          ),

          Text(

            selectedStudentName ?? "",

            style: const TextStyle(

              fontSize: 16,

              fontWeight:
              FontWeight.bold,

            ),

          ),

        ],

      ),

    );

  }

  // =====================================
  // INPUT
  // =====================================

  Widget buildInput() {

    return Container(

      padding:
      const EdgeInsets.fromLTRB(
        12,
        10,
        12,
        14,
      ),

      decoration:
      const BoxDecoration(

        color: Colors.white,

        border: Border(

          top: BorderSide(
            color: Colors.black12,
          ),

        ),

      ),

      child: SafeArea(

        child: Row(

          children: [

            Expanded(

              child: TextField(

                controller:
                controller,

                minLines: 1,

                maxLines: 5,

                decoration:
                InputDecoration(

                  hintText:
                  "Write message...",

                  filled: true,

                  fillColor:
                  Colors.grey[100],

                  contentPadding:
                  const EdgeInsets.symmetric(

                    horizontal: 18,

                    vertical: 12,

                  ),

                  border:
                  OutlineInputBorder(

                    borderRadius:
                    BorderRadius.circular(
                      30,
                    ),

                    borderSide:
                    BorderSide.none,

                  ),

                ),

              ),

            ),

            const SizedBox(
              width: 8,
            ),

            GestureDetector(

              onTap:
              isSending
                  ? null
                  : sendMessage,

              child: Container(

                padding:
                const EdgeInsets.all(
                  12,
                ),

                decoration:
                BoxDecoration(

                  color:
                  AppColors.primary,

                  shape:
                  BoxShape.circle,

                ),

                child:
                isSending

                    ? const SizedBox(

                  width: 18,

                  height: 18,

                  child:
                  CircularProgressIndicator(

                    color:
                    Colors.white,

                    strokeWidth: 2,

                  ),

                )

                    : const Icon(

                  Icons.send_rounded,

                  color:
                  Colors.white,

                ),

              ),

            ),

          ],

        ),

      ),

    );

  }

  // =====================================
  // EMPTY CHATS
  // =====================================

  Widget buildEmptyChats() {

    return const Center(

      child: Column(

        mainAxisAlignment:
        MainAxisAlignment.center,

        children: [

          Icon(

            Icons.chat_bubble_outline,

            size: 70,

            color: Colors.grey,

          ),

          SizedBox(
            height: 16,
          ),

          Text(
            "No chats available",
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

            size: 70,

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
            getChats,

            child: const Text(
              "Retry",
            ),

          ),

        ],

      ),

    );

  }

}