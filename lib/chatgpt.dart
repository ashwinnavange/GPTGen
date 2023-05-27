import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gptgen/features/speechapi.dart';
import 'package:gptgen/themes/change_theme_button_widget.dart';
import 'package:gptgen/themes/loading.dart';
import 'package:http/http.dart' as http;
import 'package:gptgen/main.dart';
import 'package:gptgen/apikey.dart';
import 'package:gptgen/features/pdfgenerator.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ChatGPTScreen extends StatefulWidget {
  const ChatGPTScreen({super.key});

  @override
  _ChatGPTScreenState createState() => _ChatGPTScreenState();
}

class _ChatGPTScreenState extends State<ChatGPTScreen> {
  String mictext = '';
  final List<Message> _messages = [];
  final TextEditingController _textEditingController = TextEditingController();
  bool _isTyping = false;
  final VoiceHandler voiceHandler = VoiceHandler();
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

  @override
  void dispose() {
    super.dispose();
  }

  void onSendMessage() async {
    if (_textEditingController.text.isEmpty) return;
    Message message = Message(text: _textEditingController.text, isMe: true);
    yourtext = _textEditingController.text;
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
    pdfmessage();
  }

  Future<String> sendMessageToChatGpt(String message) async {
    try{
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
        isShowSendButton = false;
      });
      print(reply);
      bottext = reply;
      return reply;
    } catch(e){
      return 'Bad response';
    }
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
      _textEditingController.text = result;
    }
    setState(() {
      isShowSendButton = true;
    });
  }

  void pdfmessage() {
    totaltext =
        '$totaltext$yourtext\n\n$bottext\n--------------------------------------------------------------------------------------------------------------------------------\n';
  }

  Widget _buildMessage(Message message) {
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
                      ? Theme.of(context).colorScheme.secondary
                      : Colors.grey.shade800,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(15),
                    topRight: const Radius.circular(15),
                    bottomLeft: Radius.circular(message.isMe ? 15 : 0),
                    bottomRight: Radius.circular(message.isMe ? 0 : 15),
                  )),
              child: Column(
                children: [
                  Text(
                    message.isMe ? 'YOU' : 'GPT',
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
              if (_isTyping) const Loading(),
              BottomSearchBar(),
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
                        icon: const Icon(
                          FontAwesomeIcons.solidFilePdf,
                          color: Colors.white,
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
                    backgroundColor: const Color(0xFF128C7E),
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
                    backgroundColor: const Color(0xFF128C7E),
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

class Message {
  final String text;
  final bool isMe;

  Message({required this.text, required this.isMe});
}
