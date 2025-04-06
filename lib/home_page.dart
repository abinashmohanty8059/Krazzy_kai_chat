import 'dart:io';
import 'dart:typed_data';

import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'main.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Gemini gemini = Gemini.instance;
  final stt.SpeechToText _speech = stt.SpeechToText();

  List<ChatMessage> messages = [];

  ChatUser currentUser = ChatUser(id: "0", firstName: "user");
  ChatUser geminiUser = ChatUser(
    id: "1",
    firstName: "gemini",
    profileImage: 'assets/images/gemini-logo.png',
  );

  bool _isListening = false;
  String _voiceText = "";

  @override
  void initState() {
    super.initState();
    requestMicPermission();
  }

  Future<void> requestMicPermission() async {
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      await Permission.microphone.request();
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Gemini Chat"),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: isDarkMode
                ? const LinearGradient(
                    colors: [Colors.blue, Colors.black],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : const LinearGradient(
                    colors: [Colors.white, Colors.yellow],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              themeNotifier.value == ThemeMode.dark
                  ? Icons.dark_mode
                  : Icons.light_mode,
            ),
            onPressed: () {
              themeNotifier.value = themeNotifier.value == ThemeMode.dark
                  ? ThemeMode.light
                  : ThemeMode.dark;
            },
          ),
        ],
      ),
      body: _buildUi(),
      bottomNavigationBar: Container(
        height: kToolbarHeight / 2,
        decoration: BoxDecoration(
          gradient: isDarkMode
              ? const LinearGradient(
                  colors: [Colors.blue, Colors.black],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                )
              : const LinearGradient(
                  colors: [Colors.white, Colors.yellow],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
        ),
      ),
    );
  }

  Widget _buildUi() {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return DashChat(
      inputOptions: InputOptions(
        trailing: [
          IconButton(
            onPressed: _sendMediaMessage,
            icon: const Icon(Icons.image),
          ),
          IconButton(
            onPressed: _listenVoiceInput,
            icon: Icon(_isListening ? Icons.mic : Icons.mic_none),
          ),
        ],
      ),
      messageOptions: MessageOptions(
        currentUserContainerColor: isDarkMode ? Colors.blue : null,
        currentUserTextColor: isDarkMode ? Colors.white : null,
      ),
      currentUser: currentUser,
      onSend: _sendMessage,
      messages: messages,
    );
  }

  void _sendMessage(ChatMessage chatMessage) {
    setState(() {
      messages = [chatMessage, ...messages];
    });

    try {
      String question = chatMessage.text;
      List<Uint8List>? images;

      if (chatMessage.medias?.isNotEmpty ?? false) {
        images = [
          File(chatMessage.medias!.first.url).readAsBytesSync(),
        ];
      }

      gemini
          .streamGenerateContent(
        question,
        images: images,
      )
          .listen((event) {
        ChatMessage? lastMessage = messages.firstOrNull;

        String response = event.content?.parts?.fold("", (previous, current) {
              if (current is TextPart) {
                return "$previous ${current.text}";
              }
              return previous;
            }) ??
            "";

        if (lastMessage != null && lastMessage.user.id == geminiUser.id) {
          lastMessage = messages.removeAt(0);
          lastMessage.text += response;
          setState(() {
            messages = [lastMessage!, ...messages];
          });
        } else {
          ChatMessage message = ChatMessage(
            user: geminiUser,
            createdAt: DateTime.now(),
            text: response,
          );

          setState(() {
            messages = [message, ...messages];
          });
        }
      });
    } catch (e) {
      print("Error while sending message: $e");
    }
  }

  Future<void> _sendMediaMessage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);

    if (file != null) {
      ChatMessage previewMessage = ChatMessage(
        user: currentUser,
        createdAt: DateTime.now(),
        text: "",
        medias: [
          ChatMedia(
            url: file.path,
            fileName: "",
            type: MediaType.image,
          ),
        ],
      );

      setState(() {
        messages = [previewMessage, ...messages];
      });

      String? userText = await _showTextInputDialog();

      if (userText != null && userText.trim().isNotEmpty) {
        setState(() {
          messages.remove(previewMessage);
        });

        ChatMessage fullMessage = ChatMessage(
          user: currentUser,
          createdAt: DateTime.now(),
          text: userText.trim(),
          medias: previewMessage.medias,
        );

        _sendMessage(fullMessage);
      } else {
        setState(() {
          messages.remove(previewMessage);
        });
      }
    }
  }

  Future<String?> _showTextInputDialog() async {
    TextEditingController controller = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Describe the image"),
          content: TextField(
            controller: controller,
            decoration:
                const InputDecoration(hintText: "Enter your message..."),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: const Text("Send"),
            ),
          ],
        );
      },
    );
  }

  void _listenVoiceInput() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (status) => print('Speech Status: $status'),
        onError: (error) => print('Speech Error: $error'),
      );

      if (available) {
        setState(() => _isListening = true);

        _speech.listen(
          onResult: (val) {
            setState(() {
              _voiceText = val.recognizedWords;
            });

            if (val.finalResult) {
              _speech.stop();
              setState(() => _isListening = false);

              if (_voiceText.trim().isNotEmpty) {
                ChatMessage voiceMessage = ChatMessage(
                  user: currentUser,
                  createdAt: DateTime.now(),
                  text: _voiceText,
                );
                _sendMessage(voiceMessage);
              }
            }
          },
          listenFor: const Duration(seconds: 6),
          pauseFor: const Duration(seconds: 2),
          localeId: "en_US",
          cancelOnError: true,
          partialResults: true,
        );
      } else {
        print("Speech not available");
      }
    } else {
      _speech.stop();
      setState(() => _isListening = false);
    }
  }
}