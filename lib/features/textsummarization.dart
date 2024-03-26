import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gptgen/utils/pdfgenerator.dart';
import 'package:gptgen/utils/speechapi.dart';
import 'dart:convert';
import 'package:gptgen/themes/change_theme_button_widget.dart';
import 'package:gptgen/themes/loading.dart';
import 'package:http/http.dart' as http;
import 'package:gptgen/themes/navbar.dart';
import 'package:gptgen/secrets/apikey.dart';

class TextSummarize extends StatefulWidget {
  const TextSummarize({Key? key}) : super(key: key);

  @override
  State<TextSummarize> createState() => _TextSummarizeState();
}

class _TextSummarizeState extends State<TextSummarize> {
  final List<MessagetoSummarize> _messages = [];
  final TextEditingController _textEditingController = TextEditingController();
  final VoiceHandler voiceHandler = VoiceHandler();
  bool _isTyping = false;
  bool isShowSendButton = false;
  bool changeicon = false;
  String yourtext = '';
  String bottext = '';
  String totaltext = '';

  @override
  void initState() {
    voiceHandler.initSpeech();
    super.initState();
  }

  void onSendMessage() async {
    if (_textEditingController.text.isEmpty) return;
    MessagetoSummarize input =
        MessagetoSummarize(text: _textEditingController.text, isMe: true);
    yourtext = _textEditingController.text;
    _textEditingController.clear();
    setState(() {
      _messages.insert(0, input);
      _isTyping = true;
    });
    String response = await sendMessageToSummarizeText(input.text);
    MessagetoSummarize textsummarizer =
        MessagetoSummarize(text: response, isMe: false);
    setState(() {
      _messages.insert(0, textsummarizer);
    });
    pdfmessage();
  }

  Future<String> sendMessageToSummarizeText(String text) async {
    Uri uri = Uri.parse("https://open-ai21.p.rapidapi.com/summary");
    final body = {
      'text': text,
    };

    final response = await http.post(
      uri,
      headers: {
        'content-type': 'application/json',
        'X-RapidAPI-Host': 'open-ai21.p.rapidapi.com',
        'X-RapidAPI-Key': APIKey.apiKey,
      },
      body: json.encode(body),

    );
    print(response);
    Map<String, dynamic> parsedReponse = json.decode(response.body);
    String reply = parsedReponse["result"];
    setState(() {
      _isTyping = false;
      isShowSendButton = false;
    });
    print(reply);
    bottext = reply;
    return reply;
  }

  void sendVoiceMessage() async {
    if (!voiceHandler.isEnabled) {
      print('Not supported');
      return;
    }
    if (voiceHandler.speechToText.isListening) {
      await voiceHandler.stopListening();
    } else {
      final result = await voiceHandler.startListening();
      if(result.isEmpty){
        setState(() {
          isShowSendButton = false;
        });
      }
      else{
        setState(() {
          isShowSendButton = true;
        });
      }
      _textEditingController.text = result;
    }
  }

  void pdfmessage() {
    totaltext =
        '$totaltext$yourtext\n\n$bottext\n--------------------------------------------------------------------------------------------------------------------------------\n';
  }

  Widget _buildMessage(MessagetoSummarize message) {
    return Container(
      margin: const EdgeInsets.only(top: 10.0, bottom: 10),
      child: Padding(
        padding: const EdgeInsets.only(right: 20, left: 20),
        child: Column(
          crossAxisAlignment:
              message.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(15),
              constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.7),
              decoration: BoxDecoration(
                  color: message.isMe
                      ? Theme.of(context).focusColor
                      : Theme.of(context).focusColor,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(15),
                    topRight: const Radius.circular(15),
                    bottomLeft: Radius.circular(message.isMe ? 15 : 0),
                    bottomRight: Radius.circular(message.isMe ? 0 : 15),
                  )),
              child: Column(
                children: [
                  Text(
                    message.isMe ? 'YOU' : 'SUMMARIZED TEXT',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 7),
                  SelectableText(message.text),
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
        iconTheme: Theme.of(context).primaryIconTheme,
        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.4),
        title: Text('Text Summarize',style: TextStyle(color: Theme.of(context).highlightColor)),
        centerTitle: true,
        elevation: 1,
        actions: [
          ChangeThemeButtonWidget(),
        ],
      ),
      drawer: const NavBar(),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
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
              if (_isTyping) const Loading(),
              BottomSearchBar()
            ],
          ),
        ),
      ),
    );
  }

  Padding BottomSearchBar() {
    return Padding(
      padding: const EdgeInsets.only(right: 5, left: 5),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              maxLines: 3,
              minLines: 1,
              controller: _textEditingController,
              onChanged: (val) {
                if (val.isNotEmpty) {
                  setState(() {
                    isShowSendButton = true;
                  });
                } else {
                  setState(() {
                    isShowSendButton = false;
                  });
                }
              },
              decoration: InputDecoration(
                filled: true,
                hintText: 'Send a message.',
                suffixIcon: SizedBox(
                  width: 10,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        onPressed: () {
                          CreatePdf().downloadReport(totaltext);
                        },
                        icon: Icon(
                          FontAwesomeIcons.filePdf,
                          color: Theme.of(context).highlightColor,
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  borderSide: const BorderSide(
                    width: 0,
                    style: BorderStyle.none,
                  ),
                ),
                contentPadding: const EdgeInsets.all(10),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              bottom: 8,
              right: 2,
              left: 2,
            ),
            child: isShowSendButton
                ? CircleAvatar(
                    backgroundColor: Theme.of(context).iconTheme.color,
                    radius: 25,
                    child: GestureDetector(
                      onTap: _isTyping ? null : onSendMessage,
                      child: const Icon(
                        Icons.send,
                        color: Colors.white,
                      ),
                    ),
                  )
                : CircleAvatar(
                    backgroundColor: Theme.of(context).iconTheme.color,
                    radius: 25,
                    child: GestureDetector(
                      onTap: sendVoiceMessage,
                      child: const Icon(
                        Icons.mic,
                        color: Colors.white,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class MessagetoSummarize {
  final String text;
  final bool isMe;

  MessagetoSummarize({required this.text, required this.isMe});
}
