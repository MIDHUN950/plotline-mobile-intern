
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';


class ResultPreview extends StatefulWidget {
  ResultPreview({Key? key, required this.title, required this.path, required this.ext}) : super(key: key);
  String title,path;
  String ext;
  @override
  State<ResultPreview> createState() => _ResultPreviewState();
}

class _ResultPreviewState extends State<ResultPreview> {
  bool isLoading = false;
  var imgBas64 = "";
  void getResult() async{
    setState(() {
      isLoading = true;
    });
    var formData = FormData.fromMap({
      "file" : await MultipartFile.fromFile(
        widget.path,
        filename: 'img'+widget.ext,
        contentType: MediaType("image",widget.ext.replaceAll(".", "")),
      )
    });
    try {
      // var response = await http.post(
      //     Uri.parse('http://192.168.0.198:5000/opencv'),
      //     headers:{ "Content-Type":"multipart/form-data" } ,
      //     body: { "lang":"fas" , "image":bytes},
      //     encoding: Encoding.getByName("utf-8")
      // );
      var response = await Dio().post('http://opencv-server.herokuapp.com/opencv',
        data: formData,
        queryParameters: {
        "id": "hu3g83f8634g"
        },
        options: Options(
          sendTimeout: 1000,
          receiveTimeout: 10000
      )
      );
      print(response);
      print(response.data);
      setState(() {
        imgBas64 = response.data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print(e);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.black87,
      ),
      body: Padding(
        padding: const EdgeInsets.only(bottom: 90),
        child: Center(
          child: imgBas64==""?Image.file(File(widget.path),
            fit: BoxFit.fill,
          ): Image.memory(
            base64.decode(imgBas64),
            fit: BoxFit.fill,
          ),
        ),
      ),
      floatingActionButton: GestureDetector(
        onTap: () {
          if(imgBas64==""){
            getResult();
          }
          else{
            Navigator.pop(context);
          }
        },
        child: CircleAvatar(
            radius: 30.0,
            backgroundColor: Colors.white,
            child: isLoading? const CircularProgressIndicator(
              color: Colors.purple,
            ): FaIcon(imgBas64==""?FontAwesomeIcons.wandMagicSparkles:FontAwesomeIcons.house, color: Colors.purple,)
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
