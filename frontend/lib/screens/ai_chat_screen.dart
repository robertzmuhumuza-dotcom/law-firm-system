import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AIChatScreen extends StatefulWidget {
  const AIChatScreen({Key? key}) : super(key: key);

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  final List<Map<String, String>> _messages = [
    {
      'sender': 'ai', 
      'text': 'Hello Counsel. Your AI Legal Co-pilot is live and synchronized with Gemini. How can I assist with your case analysis or statutory interpretation today?'
    }
  ];
  
  bool _isLoading = false;

  // Your live Render backend URL
  final String _backendUrl = 'https://law-firm-system-mrek.onrender.com/chat'; 

  Future<void> _sendMessage() async {
    final userMessage = _controller.text.trim();
    if (userMessage.isEmpty) return;

    setState(() {
      _messages.add({'sender': 'user', 'text': userMessage});
      _controller.clear();
      _isLoading = true;
    });

    _scrollToBottom();

    try {
      final response = await http.post(
        Uri.parse(_backendUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'prompt': userMessage, 
          'context': 'Ugandan jurisprudence, statutes, and civil procedure'
        }),
      );

      final contentType = response.headers['content-type'] ?? '';
      if (!contentType.contains('application/json')) {
        throw Exception('Server error (${response.statusCode}): Received HTML instead of JSON.');
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final aiReply = data['response'] ?? 'Analysis complete.';
        
        setState(() {
          _messages.add({'sender': 'ai', 'text': aiReply});
        });
      } else {
        setState(() {
          _messages.add({
            'sender': 'ai', 
            'text': 'Server error encountered while fetching AI response.'
          });
        });
      }
    } catch (e) {
      setState(() {
        _messages.add({
          'sender': 'ai', 
          'text': 'Network error: Unable to reach your Render backend.'
        });
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Legal Co-pilot (Live Gemini)'),
        backgroundColor: Colors.orange.shade800,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isUser = message['sender'] == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(12),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.orange.shade100 : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      message['text'] ?? '',
                      style: const TextStyle(fontSize: 15, color: Colors.black87),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: LinearProgressIndicator(color: Colors.orange),
            ),
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    onSubmitted: (_) => _sendMessage(),
                    decoration: const InputDecoration(
                      hintText: 'Consult AI legal assistant...',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.orange),
                  onPressed: _isLoading ? null : _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}