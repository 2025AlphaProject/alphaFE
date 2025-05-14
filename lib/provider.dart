import 'package:alpha_fe/pages/add_page/add_page_0/view_model/tour_create_view_model.dart';
import 'package:alpha_fe/pages/add_page/add_page_2/view_models/show_tour_course_view_model.dart';
import 'package:alpha_fe/pages/home_page/home_page_view_model/plan_view_model.dart';
import 'package:alpha_fe/pages/home_page/home_page_view_model/recommend_place_view_model.dart';
import 'package:alpha_fe/pages/home_page/home_page_view_model/save_tour_course_view_model.dart';
import 'package:alpha_fe/pages/loading_page/loading_view/loading_view.dart';
import 'package:alpha_fe/providers/auth_provider.dart';
import 'package:alpha_fe/services/websocket/show_tour_course/show_tour_course_api.dart';
import 'package:alpha_fe/services/websocket/show_tour_course/show_tour_course_websocket.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';


List<SingleChildWidget> appProviders = [
  ChangeNotifierProvider(create: (_) => AuthProvider()),
  ChangeNotifierProvider(create: (_) => PlanViewModel()),
  ChangeNotifierProvider(create: (_) => LoadingViewModel()),
  ChangeNotifierProvider(create: (_) => TourCourseViewModel()),
  ChangeNotifierProvider(create: (_) => TourCreateViewModel()),
  ChangeNotifierProvider(create: (_) => RecommendPlaceViewModel()),
  ChangeNotifierProvider(create: (_) => ShowTourCourseViewModel(
    apiService: ShowTourCourseApi(),
    socketService: ShowTourCourseWebsocket(),
    ),
  ),
];