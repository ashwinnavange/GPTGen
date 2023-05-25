import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gptgen/themes/change_theme_button_widget.dart';
import 'package:gptgen/themes/loading.dart';
import 'package:http/http.dart' as http;
import 'package:gptgen/main.dart';
import 'package:gptgen/apikey.dart';

class ChatGPTScreen extends StatefulWidget {
  const ChatGPTScreen({super.key});

  @override
  _ChatGPTScreenState createState() => _ChatGPTScreenState();
}

class _ChatGPTScreenState extends State<ChatGPTScreen> {
  final List<Message> _messages = [];
  final TextEditingController _textEditingController = TextEditingController();
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void onSendMessage() async {
    if(_textEditingController.text.isEmpty) return;
    Message message = Message(text: _textEditingController.text, isMe: true);
    _textEditingController.clear();
    setState(() {
      _messages.insert(0, message);
      _isTyping = true;
    });
    String response = await sendMessageToChatGpt(message.text);
    Message chatGpt = Message(text: response, isMe: false);
    setState(() {
      _messages.insert(0, chatGpt);
    });
  }

  Future<String> sendMessageToChatGpt(String message) async {
    Uri uri = Uri.parse("https://chatgpt53.p.rapidapi.com/");
    Map<String, dynamic> body = {
      "messages": [
        {"role": "user", "content": message}
      ],
    };
    final response = await http.post(
      uri,
      headers: {
        'content-type': 'application/json',
        'X-RapidAPI-Key': APIKey.apiKey,
        'X-RapidAPI-Host': 'chatgpt53.p.rapidapi.com'
      },
      body: json.encode(body),
    );
    print(response.body);
    Map<String, dynamic> parsedReponse = json.decode(response.body);
    String reply = parsedReponse['choices'][0]['message']['content'];
    setState(() {
      _isTyping = false;
    });
    print(reply);
    return reply;
  }

  Widget _buildMessage(Message message) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        child: Column(
          crossAxisAlignment:
          message.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(15),
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.6),
              decoration: BoxDecoration(
                color: message.isMe ?
                    Theme.of(context).colorScheme.secondary : Colors.grey.shade800,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(15),
                  topRight: const Radius.circular(15),
                  bottomLeft: Radius.circular(message.isMe ? 15 : 0),
                  bottomRight: Radius.circular(message.isMe ? 0 : 15),
                )
              ),
              child: Column(
                children: [
                  Text(
                    textAlign: TextAlign.left,
                    message.isMe ? 'You' : 'GPT',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 7),
                  Text(message.text),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('ChatGPT'),
        centerTitle: true,
        elevation: 1,
        iconTheme: Theme.of(context).iconTheme,
        actions: [
          ChangeThemeButtonWidget(),
        ],
      ),
      drawer: const NavBar(),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Flexible(
              child: ListView.builder(
                reverse: true,
                padding: const EdgeInsets.all(8),
                itemCount: _messages.length,
                itemBuilder: (BuildContext context, int index) {
                    return _buildMessage(_messages[index]);
                },
              ),
            ),
            if(_isTyping) const Loading(),
            Container(
              height: 60,
              child: Container(
                decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.all(Radius.circular(30)),
                    border: Border.all(color: Colors.grey,width: 0.5)
                ),
                margin: const EdgeInsets.only(right: 10,left: 10,bottom: 10),
                padding: EdgeInsets.only(right: 5,left: 15),
                alignment: Alignment.center,
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: TextFormField(
                        maxLines: 3,
                        minLines: 1,
                        controller: _textEditingController,
                        decoration: const InputDecoration.collapsed(hintText: "Send a message."),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.mic),
                      onPressed: () { },
                    ),
                    IconButton(
                      icon: Icon(Icons.send),
                      onPressed: onSendMessage,
                    ),
                  ],
                ),
              ),
            ),
            //const Divider(height: 1.0),
            // Container(
            //   height: 60,
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.center,
            //     crossAxisAlignment: CrossAxisAlignment.center,
            //     children: [
            //       Expanded(
            //         child: Container(
            //           decoration: BoxDecoration(
            //               color: Theme.of(context).cardColor,
            //               borderRadius: BorderRadius.all(Radius.circular(30)),
            //               border: Border.all(color: Colors.grey,width: 0.5)
            //           ),
            //           margin: const EdgeInsets.only(left: 10,bottom: 7,top: 2),
            //           padding: EdgeInsets.only(right: 5,left: 15),
            //           alignment: Alignment.center,
            //           child: TextFormField(
            //             maxLines: 3,
            //             minLines: 1,
            //             controller: _textEditingController,
            //             decoration: const InputDecoration.collapsed(hintText: "Send a message."),
            //           ),
            //         ),
            //       ),
            //       Container(
            //         margin: const EdgeInsets.only(right: 5,bottom: 5),
            //         padding: EdgeInsets.only(right: 2,left: 3),
            //         child: Column(
            //           children: [
            //             if (_textEditingController.text.isNotEmpty)
            //               ElevatedButton(
            //               style: ElevatedButton.styleFrom(
            //                 shape: const CircleBorder(),
            //                 padding: EdgeInsets.all(13)
            //               ),
            //                 onPressed: onSendMessage,
            //                 child: Icon(Icons.send)
            //             )
            //             else ElevatedButton(
            //                 style: ElevatedButton.styleFrom(
            //                     shape: const CircleBorder(),
            //                     padding: EdgeInsets.all(13)
            //                 ),
            //                 onPressed: onSendMessage,
            //                 child: Icon(Icons.mic)
            //             ),
            //           ],
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}

class Message {
  final String text;
  final bool isMe;

  Message({required this.text, required this.isMe});
}