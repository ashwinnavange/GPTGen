import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:gptgen/themes/change_theme_button_widget.dart';
import 'package:http/http.dart' as http;
import 'package:gptgen/main.dart';
import 'package:gptgen/apikey.dart';

class TextSummarize extends StatefulWidget {
  const TextSummarize({Key? key}) : super(key: key);

  @override
  State<TextSummarize> createState() => _TextSummarizeState();
}

class _TextSummarizeState extends State<TextSummarize> {

  final List<MessagetoSummarize> _messages = [];
  final TextEditingController _textEditingController = TextEditingController();

  void onSendMessage() async {
    if(_textEditingController.text.isEmpty) return;
    MessagetoSummarize input = MessagetoSummarize(text: _textEditingController.text, isMe: true);
    _textEditingController.clear();
    setState(() {
      _messages.insert(0, input);
    });
    String response = await sendMessageToSummarizeText(input.text);
    MessagetoSummarize textsummarizer = MessagetoSummarize(text: response, isMe: false);
    setState(() {
      _messages.insert(0, textsummarizer);
    });
  }

  Future<String> sendMessageToSummarizeText(String text) async {
    Uri uri = Uri.parse("https://gpt-summarization.p.rapidapi.com/summarize");
    final body = {
      'text': text,
      'num_sentences': 3,
    };
    final response = await http.post(
      uri,
      headers: {
        'content-type': 'application/json',
        'X-RapidAPI-Key': APIKey.apiKey,
        'X-RapidAPI-Host': 'gpt-summarization.p.rapidapi.com'
      },
      body: json.encode(body),
    );
    print(response.body);
    Map<String, dynamic> parsedReponse = json.decode(response.body);
    String reply = parsedReponse["summary"];
    print(reply);
    return reply;
  }

  Widget _buildMessage(MessagetoSummarize message) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        child: Column(
          crossAxisAlignment:
          message.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              message.isMe ? 'You' : 'Summarized Text',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(message.text),
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
        title: const Text('Text Summarize'),
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
            //const Divider(height: 1.0),
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
                      child: TextField(
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
          ],
        ),
      ),
    );
  }
}
class MessagetoSummarize {
  final String text;
  final bool isMe;

  MessagetoSummarize({required this.text, required this.isMe});
}