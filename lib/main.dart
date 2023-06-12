import 'package:flutter/material.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var result;
  File? _image;

  Future<void> main() async {
    final image = await pickImage();
    final response = await sendRequest(image);
    print(response.body);
    setState(() {
      _image = image;
    });
    setState(() {
      result = response.body.toString();
    });
  }

  Future<File> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    return File(pickedFile!.path);
  }

  Future<Response> sendRequest(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final bytesIO = Uint8List.fromList(bytes).buffer;
    final request = http.MultipartRequest(
        'POST', Uri.parse('http://127.0.0.1:8000/predict'));
    final multipartFile = http.MultipartFile.fromBytes(
        'file', bytesIO.asUint8List(),
        filename: 'image.jpg');
    request.files.add(multipartFile);
    final response = await request.send();
    var prediction = await http.Response.fromStream(response);
    return prediction;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Shani"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
                onPressed: main, child: const Icon(Icons.add_a_photo)),
            Container(
              alignment: Alignment.center,
              width: double.infinity,
              height: 300,
              color: Colors.grey[300],
              child: _image != null
                  ? Image.file(_image!)
                  : const Text('No Image Selected'),
            ),
            Container(
              alignment: Alignment.center,
              color: result != null ? Colors.yellow[300] : Colors.white10,
              child: result != null ? Text(result) : const Text('Result'),
            )
          ],
        ),
      ),
    );
  }
}
