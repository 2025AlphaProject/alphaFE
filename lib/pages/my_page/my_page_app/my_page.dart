import 'package:alpha_fe/pages/my_page/mission_page_1/mission_page_1.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../../../components/app_bar.dart';
import '../mission_page_1/mission_page_1.dart';
import '../my_page_Q&A.dart';
import 'view/state_item.dart';
import 'view/menu_item.dart';
import 'viewModel/my_page_viewModel.dart';


class MyPage extends StatelessWidget {
  final String? accessToken;
  const MyPage({Key? key, this.accessToken}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: const DefaultAppBar(title: "마이페이지"),
      body: myPageBody(),
    );
  }
}

class myPageBody extends StatefulWidget {

  @override
  State<myPageBody> createState() => _myPageBodyState();
}

class _myPageBodyState extends State<myPageBody> {

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<MyPageViewmodel>(context, listen: false).initialize(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (kIsWeb) {
      width = 430;
    }
    final height = MediaQuery.of(context).size.height;

    final vm = context.watch<MyPageViewmodel>();

    return vm.isLoading
        ? const Center(child: CircularProgressIndicator())
        : Padding(
      padding: EdgeInsets.symmetric(vertical: height * 0.042, horizontal: width * 0.06),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            children: [
              SizedBox(height: height * 0.01),
              Container(
                width: width *0.25,
                height: height  * 0.115,
                alignment: Alignment.center,
                child: CircleAvatar(
                  radius: width * 51.3,
                  backgroundImage: NetworkImage(vm.profileImageUrl),
                  backgroundColor: Colors.transparent,
                ),
              ),
              SizedBox(height: height * 0.03),
              Text(
                vm.username,
                style: const TextStyle(
                  color: Color(0xFF757575),
                  fontSize: 24.6,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(offset: Offset(2, 2), blurRadius: 10, color: Color(0xFFCCCCCC))
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: height * 0.023),
          Row( //여행이랑 미션 수
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              StateItem(vm.tourCount.toString(), "여행", width, height),
              SizedBox(width: width * 0.08),
              StateItem(vm.missionCount.toString(), "미션", width, height),
            ],
          ),
          SizedBox(height: height * 0.05),
          Column( //미션진행도랑 자주묻는 질문 //TODO 여기 뒤에 다른것들이랑 같게 수정하기
            children: [
              menuItem(context, Icons.trending_up, "미션 진행도", MissionPage1(todayPlaces: vm.todayPlaces,)),
              menuItem(context, Icons.help_outline_outlined, "자주 묻는 질문", MyPage_QA()),
              //menuItem(context, Icons.logout, "로그아웃", const SizedBox(), onTap: () {LogoutByUser(context);}), //TODO 고치기
            ],
          ),
        ],
      ),
    );
  }
}
