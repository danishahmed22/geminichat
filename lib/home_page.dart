import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';

class homepage extends StatefulWidget {
  const homepage({super.key});

  @override
  State<homepage> createState() => _homepageState();
}

class _homepageState extends State<homepage> {
  bool _isLoading = false;
  final Gemini gemini = Gemini.instance;
  List<ChatMessage> messages = [];
  ChatUser currentUser = ChatUser(id: '0', firstName: 'User', );

  ChatUser geminiUser = ChatUser(
    id: '1',
    firstName: 'Gemini',
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlue.shade300,
        centerTitle: true,
        title: const Text(
          'Flutter AI'
        ),
      ),
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    return Container(
      color: Colors.lightBlue.shade100,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DashChat(
              currentUser: currentUser,
              onSend: _sendMessage,
              messages: messages,
            ),
          ),
          if (_isLoading)
            Positioned(
              bottom: 70,  // Adjust this value as needed
              left: 0,
              right: 0,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
  void _sendMessage(ChatMessage chatMessage) {
    setState(() {
      messages = [chatMessage, ...messages];
      _isLoading = true;
    });
    try {
      String question = chatMessage.text;
      String promptPrefix = "You are a Flutter expert AI assistant. Your task is to answer questions and provide help specifically related to Flutter development. Please focus your responses on Flutter-specific information, best practices, and solutions. If a question is not related to Flutter, politely redirect the conversation back to Flutter topics. Now, please answer the following question about Flutter: ";

      String fullPrompt = promptPrefix + question;

      gemini.streamGenerateContent(fullPrompt).listen((event) {
        ChatMessage? lastMessage = messages.firstOrNull;
        if (lastMessage != null && lastMessage.user == geminiUser) {
          lastMessage = messages.removeAt(0);
          String response = event.content?.parts?.fold('', (previous, current) => '$previous ${current.text}') ?? '';
          lastMessage.text += response;
          setState(() {
            messages = [lastMessage!, ...messages];
          });
        } else { 
          String question = event.content?.parts?.fold('', (previous, current) => '$previous ${current.text}') ?? '';
          ChatMessage message = ChatMessage(user: geminiUser, createdAt: DateTime.now(), text: question);
          setState(() {
            messages = [message, ...messages];
            _isLoading = false;  // Stop loading when we get the first response
          });
        }
      }, onDone: () {
        setState(() {
          _isLoading = false;  // Ensure loading is stopped when stream is done
        });
      });
    } catch (e) {
      print(e);
      setState(() {
        _isLoading = false;  // Stop loading if there's an error
      });
    }
  }
}
