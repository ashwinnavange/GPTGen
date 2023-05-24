import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_toastr/flutter_toastr.dart';
import 'package:gptgen/apikey.dart';
import 'package:gptgen/main.dart';
import 'package:gptgen/themes/change_theme_button_widget.dart';
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
  String apikey = 'ed13609dccmsh26910f37b6ca854p1c4407jsn9fd90ad75bda';
  String? image1;
  String? image2;

  void getAIImage() async{
    if(inputText.text.isNotEmpty){

      var data ={
        "prompt": inputText.text,
        "n": 2,
        "size": "1024x1024",
      };

      var res = await http.post(
          Uri.parse('https://openai80.p.rapidapi.com/images/generations'),
          headers: {
            'content-type': 'application/json',
            'X-RapidAPI-Key': APIKey.apiKey,
            'X-RapidAPI-Host': 'openai80.p.rapidapi.com'
          },
          body:jsonEncode(data));
      print(res.body);
      var jsonResponse = jsonDecode(res.body);

      image1 = jsonResponse['data'][0]['url'];
      image2 = jsonResponse['data'][1]['url'];

      setState(() {

      });
    }else{
      print("Enter something");
    }
  }
  _download1() async {
    var status = await Permission.storage.request();
    if (status.isGranted) {
      var response = await Dio().get(
          image1!,
          options: Options(responseType: ResponseType.bytes));
      final result = await ImageGallerySaver.saveImage(
          Uint8List.fromList(response.data),
          quality: 60,
          name: "image1");
      print(result);
    }
    _showToast("Downloaded Image 1",duration: FlutterToastr.lengthLong,position: FlutterToastr.bottom);
  }
  _download2() async {
    var status = await Permission.storage.request();
    if (status.isGranted) {
      var response = await Dio().get(
          image2!,
          options: Options(responseType: ResponseType.bytes));
      final result = await ImageGallerySaver.saveImage(
          Uint8List.fromList(response.data),
          quality: 60,
          name: "image2");
      print(result);
    }
    _showToast("Downloaded Image 2",duration: FlutterToastr.lengthLong,position: FlutterToastr.bottom);
  }

  _showToast(String msg, {int? duration, int? position}) {
    FlutterToastr.show(msg, context, duration: duration, position: position);
    FlutterToastr.bottom;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('DALL-E AI'),
        centerTitle: true,
        elevation: 1,
        iconTheme: Theme.of(context).iconTheme,
        actions: [
          ChangeThemeButtonWidget(),
        ],
      ),
      drawer: const NavBar(),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 70),
        child: SpeedDial(
          spacing: 15,
          icon: Icons.menu,
          overlayColor: Colors.black,
          overlayOpacity: 0.4,
          children: [
            SpeedDialChild(
                child: Icon(Icons.download),
                label: "Image 2",
                onTap: ()=> image2 != null ? _download2() : _showToast("Not Found",duration: FlutterToastr.lengthLong,position: FlutterToastr.bottom),
            ),
            SpeedDialChild(
                child: Icon(Icons.download),
                label: "Image 1",
                onTap: ()=> image1 != null ? _download1() : _showToast("Not Found",duration: FlutterToastr.lengthLong,position: FlutterToastr.bottom),
            ),
          ],
        ),
      ),
      body: Center(
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
                      image1 != null ? Container(
                        width: 256,
                        height: 256,
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12),
                          image: DecorationImage(
                            image: NetworkImage(image1!),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ) : Container(child: Text("Please Enter Text To Generate AI image")),
                      SizedBox(height: 40),
                      image2 != null ?
                      Container(
                        width: 256,
                        height: 256,
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12),
                          image: DecorationImage(
                            image: NetworkImage(image2!),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ) : SizedBox(height: 40),
                      SizedBox(height: 80)
                    ],
                  );
                },
              ),
            ),
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
                        controller: inputText,
                        decoration: const InputDecoration.collapsed(hintText: "Send a message."),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.mic),
                      onPressed: () { },
                    ),
                    IconButton(
                      icon: Icon(Icons.send),
                      onPressed: getAIImage,
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

