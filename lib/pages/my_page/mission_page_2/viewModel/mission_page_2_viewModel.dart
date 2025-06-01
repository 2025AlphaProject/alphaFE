import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../services/dio/authorized_dio.dart';
import 'package:alpha_fe/components/camera.dart';

class MissionPage2Viewmodel extends ChangeNotifier {
  final CameraService _cameraService = CameraService();

  File? _image;
  int _selectedPoseIndex = 1;
  int? _selectedMissionId = 1;

  File? get image => _image;
  int get selectedPoseIndex => _selectedPoseIndex;
  int? get selectedMissionId => _selectedMissionId;

  // 카메라로 사진 촬영
  Future<void> takePicture() async {
    final File? img = await _cameraService.getImageFromCamera();
    if (img != null) {
      _image = img;
      notifyListeners();
    }
  }

  // 포즈 선택
  void selectPose(int index) {
    _selectedPoseIndex = index;
    _selectedMissionId = index;
    notifyListeners();
  }

  void reset() {
    _image = null;
    _selectedPoseIndex = 1;
    _selectedMissionId = 1;
    notifyListeners();
  }

}