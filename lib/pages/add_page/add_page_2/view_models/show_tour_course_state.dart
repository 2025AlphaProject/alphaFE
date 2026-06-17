import '../models/place_info.dart';

class ShowTourCourseState {
  bool isLoading = true;
  bool hasError = false;
  bool receivedData = false;
  String errorMessage = '';
  Map<String, List<PlaceInfo>> placeMap = {};

  void reset() {
    isLoading = true;
    hasError = false;
    receivedData = false;
    errorMessage = '';
    placeMap = {};
  }
}