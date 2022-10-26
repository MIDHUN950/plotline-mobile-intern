import 'dart:io';
import 'dart:typed_data';

import 'package:edge_detection/screen/preview.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:progress_loading_button/progress_loading_button.dart';
import 'package:path/path.dart' as p;


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseAuth.instance.signInAnonymously();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // textfeild widget in dart?

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.purple,
      ),
      home: const MyHomePage(title: 'Edge Detector'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // text controller declaration in dart?
  final TextEditingController url = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  Future<void> _ImagebuttonHandle(ImageSource imgsrc, BuildContext context) async {
    try {
      final XFile? img = await _picker.pickImage(source: imgsrc);
      print(img?.mimeType);
      if(img?.path != null){
        Navigator.push(context, MaterialPageRoute(builder: (context) => ResultPreview(title: "Preview", path: img!.path, ext: p.extension(img.path))));
      }
    } catch(e){
      print(e);
    }
  }
  Future<void> convertUriToFile(Uri uriString) async {
    try {
      final http.Response responseData = await http.get(uriString);
      var uint8list = responseData.bodyBytes;
      var buffer = uint8list.buffer;
      ByteData byteData = ByteData.view(buffer);
      var tempDir = await getTemporaryDirectory();
      if(await File('${tempDir.path}/img.jpg').exists()){
        File('${tempDir.path}/img.jpg').delete();
      }
      File file = await File('${tempDir.path}/img.jpg').writeAsBytes(
          buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
      print(file.path);
      print(p.extension(file.path));
      if(file != null) {
        Navigator.push(context, MaterialPageRoute(builder: (context) =>
            ResultPreview(title: "Preview",
              path: file.path,
              ext: p.extension(file.path),)));
      }
    } catch (e) {
      print(e); // General exception
    }
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
  bool _checkUrl(String url){
    if(!Uri.parse(url).isAbsolute){
      _toast("Invalid Url");
      return false;
    }
    var regExp = r"(https?|http)://([-A-Z0-9.]+)(/[-A-Z0-9+&@#/%=~_|!:,.;]*)?(\?[A-Z0-9+&@#/%=~_|!:‌​,.;]*)?";
    if(!RegExp(regExp, caseSensitive: false).hasMatch(url)){
      _toast("Invalid image url");
      return false;
    }
    return true;
  }
  @override
  Widget build(BuildContext context) {
    double swidth = MediaQuery.of(context).size.width;
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).

          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            const SizedBox(
              height: 50,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: url,
                decoration: const InputDecoration(

                  focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color.fromARGB(255, 178, 40, 196), width: 2.0),
                    borderRadius: BorderRadius.all(Radius.circular(25.0)),
              ),
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color.fromARGB(255, 235, 168, 241), width: 1.0),
                borderRadius: BorderRadius.all(Radius.circular(20.0)),
              ),
              hintText: 'Enter Url',
                ),
              ),
            ),
            SizedBox(height: 10,),
            Center(
              child: Padding(
                padding:EdgeInsets.symmetric(horizontal: (35 * swidth /100)),
                child: LoadingButton(
                  loadingWidget: const CircularProgressIndicator(
                    color: Colors.white,
                  ),
                  borderRadius: 35,
                  color: Colors.purple,
                  defaultWidget: Text("Preview",
                      style: GoogleFonts.poppins(
                          fontSize: 20
                      )
                  ),
                  onPressed: () async {
                    if(_checkUrl(url.text)){
                      convertUriToFile(Uri.parse(url.text));
                    }
                  },
                ),
              ),
            ),
            SizedBox(height: 20,),
            Center(
              child: Padding(
                padding:EdgeInsets.symmetric(horizontal: (20 * swidth /100)),
                child: LoadingButton(
                  loadingWidget: const CircularProgressIndicator(
                    color: Colors.white,

                  ),
                  borderRadius: 35,
                  color: Colors.purple,
                  defaultWidget: Text("Take from camera",
                      style: GoogleFonts.poppins(
                          fontSize: 20
                      )
                  ),
                  onPressed: () async {
                    _ImagebuttonHandle(ImageSource.camera,context);
                  },
                ),
              ),
            ),SizedBox(height: 20,),
            Center(
              child: Padding(
                padding:EdgeInsets.symmetric(horizontal: (25 * swidth /100)),
                child: LoadingButton(
                  loadingWidget: const CircularProgressIndicator(
                    color: Colors.white,
                  ),
                  borderRadius: 35,
                  color: Colors.purple,
                  defaultWidget: Text("Pick from gallery",
                      style: GoogleFonts.poppins(
                          fontSize: 20
                      )
                  ),
                  onPressed: () async {
                    _ImagebuttonHandle(ImageSource.gallery,context);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: _incrementCounter,
      //   tooltip: 'Increment',
      //   child: const Icon(Icons.add),
      // ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
