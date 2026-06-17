import 'dart:io';
import 'package:image_picker/image_picker.dart';

class CameraService {
  final ImagePicker _picker = ImagePicker();

  Future<File?> getImageFromCamera() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }
}

//실사용 예시

// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'camera_service.dart'; // 새로 만든 서비스 import
//
// void main() {
//   runApp(MaterialApp(
//     home: CameraPickPage(),
//   ));
// }
//
// class CameraPickPage extends StatefulWidget {
//   @override
//   _CameraPickPageState createState() => _CameraPickPageState();
// }
//
// class _CameraPickPageState extends State<CameraPickPage> {
//   File? _image;
//   final CameraService _cameraService = CameraService();
//
//   Future<void> _getImageFromCamera() async {
//     final File? image = await _cameraService.getImageFromCamera();
//     if (image != null) {
//       setState(() {
//         _image = image;
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('카메라로 사진 찍기')),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             _image == null
//                 ? Text('아직 사진 없음')
//                 : Image.file(_image!, width: 300, height: 300),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: _getImageFromCamera,
//               child: Text('카메라 실행'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }