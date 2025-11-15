import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ChatBotPage extends StatefulWidget {
  @override
  _ChatBotPageState createState() => _ChatBotPageState();
}



class _ChatBotPageState extends State<ChatBotPage> {
  List<Map<String, String>> messages = [
    {
      'role': 'assistant',
      'content':
      'Hello! 👋 I\'m your ReFood AI assistant. I can help with food waste tips, recipes, and storage advice.'
    }
  ];
  TextEditingController _controller = TextEditingController();
  bool isLoading = false;

  final List<String> quickActions = [
    'How can I reduce food waste?',
    'Recipe ideas with leftovers',
    'Best way to store vegetables',
    'Tips for meal planning'
  ];

  ScrollController _scrollController = ScrollController();

  void scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent + 100,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  Future<String> callGemeniAPI(String userMessage) async {
    final apiKey =dotenv.env['GEMINI_API_KEY'] ?? '';
    final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent');
    final payload = {
      "contents": [
        {
          "parts": [
            {"text": "You are a helpful ReFood AI assistant.Rules:1. Only answer questions related to food waste, recipes, cooking, food storage, meal planning, or other food-related topics. Do not answer questions about unrelated topics.2. Provide practical and friendly advice.3. Respond in plain text only. Do NOT use Markdown, asterisks, dashes, or bullet points. Give text in simple sentences or numbered steps if needed.User question:$userMessage"}
          ]
        }
      ]
    };


    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'x-goog-api-key': apiKey,
        },
        body: jsonEncode(payload),
      );


      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);


        final output = data['candidates'][0]['content']['parts'][0]['text'];


        return output;
      } else {
        print('Error from API: ${response.body}');
        return 'I apologize, but I encountered an error: ${response
            .statusCode}';
      }
    } catch (e) {
      print('Exception during API call: $e');
      return 'I encountered an error.';
    }
  }
  void handleSend() async {
    String userMessage = _controller.text.trim();
    if (userMessage.isEmpty || isLoading) return;

    setState(() {
      messages.add({'role': 'user', 'content': userMessage});
      _controller.clear();
      isLoading = true;
    });

    scrollToBottom();

    String aiResponse = await callGemeniAPI(userMessage);

    setState(() {
      messages.add({'role': 'assistant', 'content': aiResponse});
      isLoading = false;
    });

    scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AI Assistant'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: [
          // Messages List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.all(16),
              itemCount: messages.length + (isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == messages.length) {
                  return Row(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(width: 10),
                      Text('Thinking...'),
                    ],
                  );
                }

                final message = messages[index];
                bool isUser = message['role'] == 'user';
                return Container(
                  margin: EdgeInsets.symmetric(vertical: 5),
                  alignment:
                  isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    padding:
                    EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.blueAccent : Colors.grey[200],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      message['content']!,
                      style: TextStyle(
                        color: isUser ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Quick Actions
          if (messages.length == 1)
            Wrap(
              spacing: 8,
              children: quickActions.map((action) {
                return ElevatedButton(
                  onPressed: () {
                    _controller.text = action;
                  },
                  child: Text(action),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    foregroundColor: Colors.black87,
                    shape: StadiumBorder(),
                  ),
                );
              }).toList(),
            ),

          // Input Field
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    onSubmitted: (_) => handleSend(),
                    decoration: InputDecoration(
                      hintText: 'Ask me anything about food waste...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: handleSend,
                  style: ElevatedButton.styleFrom(
                    shape: CircleBorder(),
                    padding: EdgeInsets.all(12),
                  ),
                  child: isLoading
                      ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
