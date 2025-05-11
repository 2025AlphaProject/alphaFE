import 'package:alpha_fe/pages/loading_page/loading_view.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';


List<SingleChildWidget> appProviders = [
  ChangeNotifierProvider(create: (_) => LoadingViewModel()),
];