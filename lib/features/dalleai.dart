import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_toastr/flutter_toastr.dart';
import 'package:gptgen/secrets/apikey.dart';
import 'package:gptgen/themes/navbar.dart';
import 'package:gptgen/utils/speechapi.dart';
import 'package:gptgen/themes/change_theme_button_widget.dart';
import 'package:gptgen/themes/loading.dart';
import 'package:http/http.dart' as http;
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';

class DallEAIScreen extends StatefulWidget {
  const DallEAIScreen({Key? key}) : super(key: key);

  @override
  State<DallEAIScreen> createState() => _DallEAIScreenState();
}

class _DallEAIScreenState extends State<DallEAIScreen> {
  final TextEditingController inputText = TextEditingController();
  final VoiceHandler voiceHandler = VoiceHandler();
  bool _isTyping = false;
  bool changeicon = false;
  bool isShowSendButton = false;
  String? image1;
  String? image2;

  @override
  void initState() {
    voiceHandler.initSpeech();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> getAIImage() async {
    if (inputText.text.isNotEmpty) {
      Message message = Message(text: inputText.text);
      inputText.clear();
      print(message.text);
      setState(() {
        _isTyping = true;
      });
      Map<String, String> data = {
        "prompt": message.text,
      };
      final Uri uri = Uri.parse('https://stability-ai5.p.rapidapi.com/images');
      final Map<String, String> headers = {
        'content-type': 'application/json',
        'X-RapidAPI-Processor': 'sync',
        'X-RapidAPI-Key': APIKey.apiKey,
        'X-RapidAPI-Host': 'stability-ai5.p.rapidapi.com',
      };
      final res = await http.post(
        uri,
        headers: headers,
        body: jsonEncode(data),
      );
      if (res.statusCode == 200) {
        print(res.body);
      } else {
        print('Request failed with status: ${res.statusCode}');
      }
      final Map<String, dynamic> jsonResponse = json.decode(res.body);
      image1 = jsonResponse['url'];
      //image2 = jsonResponse['url'];
      setState(() {
        _isTyping = false;
        isShowSendButton = false;
      });
    } else {
      return;
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
      inputText.text = result;
    }
  }

  _download1() async {
    var status = await Permission.storage.request();
    if (status.isGranted) {
      var response = await Dio()
          .get(image1!, options: Options(responseType: ResponseType.bytes));
      final result = await ImageGallerySaver.saveImage(
          Uint8List.fromList(response.data),
          quality: 60,
          name: "image1");
      print(result);
    }
    _showToast("Downloaded Image 1",
        duration: FlutterToastr.lengthLong, position: FlutterToastr.bottom);
  }

  _download2() async {
    var status = await Permission.storage.request();
    if (status.isGranted) {
      var response = await Dio()
          .get(image2!, options: Options(responseType: ResponseType.bytes));
      final result = await ImageGallerySaver.saveImage(
          Uint8List.fromList(response.data),
          quality: 60,
          name: "image2");
      print(result);
    }
    _showToast("Downloaded Image 2",
        duration: FlutterToastr.lengthLong, position: FlutterToastr.bottom);
  }

  _showToast(String msg, {int? duration, int? position}) {
    FlutterToastr.show(msg, context, duration: duration, position: position);
    FlutterToastr.bottom;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: Theme.of(context).primaryIconTheme,
        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.4),
        title: Text('DALL-E AI',style: TextStyle(color: Theme.of(context).highlightColor)),
        centerTitle: true,
        elevation: 1,
        actions: [
          ChangeThemeButtonWidget(),
        ],
      ),
      drawer: const NavBar(),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 70),
        child: SpeedDial(
          iconTheme: Theme.of(context).iconTheme,
          backgroundColor: Theme.of(context).dividerColor,
          spacing: 15,
          icon: Icons.menu,
          overlayColor: Colors.black,
          overlayOpacity: 0.5,
          children: [
            // SpeedDialChild(
            //   child: const Icon(Icons.download),
            //   label: "Image 2",
            //   onTap: () => image2 != null
            //       ? _download2()
            //       : _showToast("Not Found",
            //           duration: FlutterToastr.lengthLong,
            //           position: FlutterToastr.bottom),
            // ),
            SpeedDialChild(
              child: const Icon(Icons.download),
              label: "Image 1",
              onTap: () => image1 != null
                  ? _download1()
                  : _showToast("Not Found",
                      duration: FlutterToastr.lengthLong,
                      position: FlutterToastr.bottom),
            ),
          ],
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Flexible(
                child: ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.all(8),
                  itemCount: 1,
                  itemBuilder: (BuildContext context, int index) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        image1 != null ?
                          Image.network(
                            image1!,
                            width: 512,
                            height: 512,
                            scale: 1,
                            loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                              if (loadingProgress == null) {
                                return child;
                              } else if (loadingProgress.cumulativeBytesLoaded == loadingProgress.expectedTotalBytes) {
                                return child;
                              } else {
                                return CircularProgressIndicator();
                              }
                            },
                            errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                              return Text('Error loading image');
                            },
                          ) : _isTyping == true
                            ? const Loading()
                            : const Text(
                            "Please Enter Text To Generate AI image"),
                        // image1 != null
                        //     ? Container(
                        //         width: 512,
                        //         height: 512,
                        //         decoration: BoxDecoration(
                        //           borderRadius: BorderRadius.circular(12),
                        //           image: DecorationImage(
                        //             image: NetworkImage(image1!),
                        //             fit: BoxFit.cover,
                        //           ),
                        //         ),
                        //       )
                        //     : _isTyping == true
                        //         ? const Loading()
                        //         : const Text(
                        //             "Please Enter Text To Generate AI image"),
                        // const SizedBox(height: 40),
                        // image2 != null
                        //     ? Container(
                        //         width: 512,
                        //         height: 512,
                        //         decoration: BoxDecoration(
                        //           borderRadius: BorderRadius.circular(12),
                        //           image: DecorationImage(
                        //             image: NetworkImage(image2!),
                        //             fit: BoxFit.cover,
                        //           ),
                        //         ),
                        //       )
                        //     : const SizedBox(height: 40),
                        const SizedBox(height: 80)
                      ],
                    );
                  },
                ),
              ),
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
              controller: inputText,
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
                      onTap: _isTyping ? null : getAIImage,
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

class Message {
  final String text;

  Message({required this.text});
}
