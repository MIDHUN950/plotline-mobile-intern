
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path_provider/path_provider.dart';


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
  bool errImg = false;
  Future<String> uploadPic(File img,String uid,int count) async {
    final Reference storageReference = FirebaseStorage.instance
        .ref()
        .child("AnonymousImages")
        .child("${uid}img${DateTime.now().toString().replaceAll(" ", "")}$count.png");
    String downloadURL;

    UploadTask uploadTask = storageReference.putFile(img);

    downloadURL = await (await uploadTask).ref.getDownloadURL();
//     final storageRef = FirebaseStorage.instance.ref();
//     final mountainsRef = storageRef.child("img$count.jpg");
//     final mountainImagesRef = storageRef.child("AnonymousImages/$uid/img$count.jpg");
// // While the file names are the same, the references point to different files
//     assert(mountainsRef.name == mountainImagesRef.name);
//     assert(mountainsRef.fullPath != mountainImagesRef.fullPath);
//     await mountainsRef.putFile(img);
    //returns the download url
    return downloadURL;
  }
  uploadToCloud(String img1Path, String imgBase64) async{
    final bytes = base64Decode(imgBase64);
    var tempDir = await getTemporaryDirectory();
    if(await File('${tempDir.path}/result.jpg').exists()){
      File('${tempDir.path}/result.jpg').delete();
    }
    File f1 = File(img1Path);
    File f2 = File('${tempDir.path}/result.jpg');
    f2.writeAsBytesSync(bytes);
    String? uid =  FirebaseAuth.instance.currentUser?.uid;
    String url1 = await uploadPic(f1, uid!, 1);
    String url2 = await uploadPic(f2, uid!, 1);
    await FirebaseFirestore.instance.collection('AnonymousImages/').doc(uid).set(
      {
        "image1": url1,
        "image2": url2,
        "createdAt": FieldValue.serverTimestamp()
      }
    );
  }
  void getResult() async{
    setState(() {
      isLoading = true;
    });
    String res = "";
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
        "id": FirebaseAuth.instance.currentUser?.uid,
        },
        options: Options(
          sendTimeout: 1000,
          receiveTimeout: 10000
      )
      );
      print(response);
      print(response.data);
      res = response.data;
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print(e);
    }
    await uploadToCloud(widget.path, res);
    setState(() {
      imgBas64 = res;
      isLoading = false;
    });
  }
  _toast(String msg){
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0
    );
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
            errorBuilder: (context, error, stackTrace) {
            errImg = true;
              return Image.asset(
                  'assets/404.webp',
                  fit: BoxFit.fitWidth);
            },
          ): Image.memory(
            base64.decode(imgBas64),
            fit: BoxFit.fill,
          ),
        ),
      ),
      floatingActionButton: GestureDetector(
        onTap: () {
          if(imgBas64==""){
            if(!errImg && !isLoading){
              getResult();
            }
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
