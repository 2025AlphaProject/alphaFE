import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(MaterialApp(
    home: CameraPickPage(),
  ));
}

class CameraPickPage extends StatefulWidget {
  @override
  _CameraPickPageState createState() => _CameraPickPageState();
}

class _CameraPickPageState extends State<CameraPickPage> {
  File? _image;
  final ImagePicker _picker = ImagePicker();

  Future<void> _getImageFromCamera() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('카메라로 사진 찍기')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _image == null
                ? Text('아직 사진 없음')
                : Image.file(_image!, width: 300, height: 300),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _getImageFromCamera,
              child: Text('카메라 실행'),
            ),
          ],
        ),
      ),
    );
  }
}