import 'package:alpha_fe/pages/add_page/add_page_0/view_model/tour_create_view_model.dart';
import 'package:alpha_fe/pages/add_page/add_page_2/view_models/show_tour_course_view_model.dart';
import 'package:alpha_fe/pages/add_page/add_page_3/view_model/show_final_tour_view_model.dart';
import 'package:alpha_fe/pages/home_page/home_page_view_model/plan_view_model.dart';
import 'package:alpha_fe/pages/home_page/home_page_view_model/recommend_place_view_model.dart';
import 'package:alpha_fe/pages/loading_page/loading_view/loading_view.dart';
import 'package:alpha_fe/pages/plan_page/add_user/viewModel/add_user_view_model.dart';
import 'package:alpha_fe/providers/auth_provider.dart';
import 'package:alpha_fe/services/websocket/show_tour_course/show_tour_course_api.dart';
import 'package:alpha_fe/services/websocket/show_tour_course/show_tour_course_websocket.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:alpha_fe/pages/home_page/home_page_view_model/home_page_view_model.dart';
import 'package:alpha_fe/pages/add_page/add_page_0/view_model/add_page_0_view_model.dart';
import 'package:alpha_fe/components/appbars/search_appbar/search_appbar_view_model.dart';



List<SingleChildWidget> appProviders = [
  ChangeNotifierProvider(create: (_) => HomePageViewModel()),
  ChangeNotifierProvider(create: (_) => AddPage0ViewModel()),
  ChangeNotifierProvider(create: (_) => AuthProvider()),
  ChangeNotifierProvider(create: (_) => PlanViewModel()),
  ChangeNotifierProvider(create: (_) => LoadingViewModel()),
  ChangeNotifierProvider(create: (_) => TourCreateViewModel()),
  ChangeNotifierProvider(create: (_) => RecommendPlaceViewModel()),
  ChangeNotifierProvider(create: (_) => ShowTourCourseViewModel(apiService: ShowTourCourseApi(), socketService: ShowTourCourseWebsocket(),),),
  ChangeNotifierProvider(create: (_) => ShowFinalTourViewModel()),
  ChangeNotifierProvider(create: (_) => AddUserViewModel()),
  ChangeNotifierProvider(create: (_) => SearchAppBarViewModel()),
];