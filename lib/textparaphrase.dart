import 'dart:convert';
import 'package:gptgen/apikey.dart';
import 'package:gptgen/themes/loading.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:gptgen/main.dart';

import 'themes/change_theme_button_widget.dart';

class TextParaphrase extends StatefulWidget {
  const TextParaphrase({Key? key}) : super(key: key);

  @override
  State<TextParaphrase> createState() => _TextParaphraseState();
}

class _TextParaphraseState extends State<TextParaphrase> {

  final List<MessagetoParaphrase> _messages = [];
  final TextEditingController _textEditingController = TextEditingController();
  bool _isTyping = false;

  void onSendMessage() async {
    if(_textEditingController.text.isEmpty) return;
    MessagetoParaphrase input = MessagetoParaphrase(text: _textEditingController.text, isMe: true);
    _textEditingController.clear();
    setState(() {
      _messages.insert(0, input);
      _isTyping = true;
    });
    String response = await sendMessageToSummarizeText(input.text);
    MessagetoParaphrase textparaphrase = MessagetoParaphrase(text: response, isMe: false);
    setState(() {
      _messages.insert(0, textparaphrase);
    });
  }

  Future<String> sendMessageToSummarizeText(String text) async {
    Uri uri = Uri.parse("https://rewriter-paraphraser-text-changer-multi-language.p.rapidapi.com/rewrite");
    final body = {
      'language': 'en',
      'strength': 3,
      'text': text,
    };
    final response = await http.post(
      uri,
      headers: {
        'content-type': 'application/json',
        'X-RapidAPI-Key': APIKey.apiKey,
        'X-RapidAPI-Host': 'rewriter-paraphraser-text-changer-multi-language.p.rapidapi.com'
      },
      body: json.encode(body),
    );
    print(response.body);
    Map<String, dynamic> parsedReponse = json.decode(response.body);
    String reply = parsedReponse["rewrite"];
    setState(() {
      _isTyping = false;
    });
    print(reply);
    return reply;
  }

  Widget _buildMessage(MessagetoParaphrase message) {
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
                    message.isMe ? 'YOU' : 'PARAPHRASED',
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
        title: const Text('Text Paraphraser'),
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
          ],
        ),
      ),
    );
  }
}
class MessagetoParaphrase {
  final String text;
  final bool isMe;

  MessagetoParaphrase({required this.text, required this.isMe});
}