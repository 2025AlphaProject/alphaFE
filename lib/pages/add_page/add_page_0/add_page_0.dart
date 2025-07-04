import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:alpha_fe/components/custom_alert_dialog.dart';
import '../../../components/proceed_button.dart';
import '../../../components/appbars/default_appbar/default_appbar.dart';
import 'package:alpha_fe/pages/add_page/add_page_0/view_model/add_page_0_view_model.dart';
import 'package:alpha_fe/pages/add_page/add_page_0/widgets/date_select_section.dart';
import 'package:alpha_fe/pages/add_page/add_page_0/widgets/title_input_section.dart';


// 추가 탭 0번째 페이지: 여행 이름과 날짜 입력
class AddPage_0 extends StatefulWidget {
  final String? sigun;
  const AddPage_0({Key? key, this.sigun}) : super(key: key);

  @override
  _AddPage_0State createState() => _AddPage_0State();
}

class _AddPage_0State extends State<AddPage_0> {


  @override
  void initState() {
    super.initState();
    // ViewModel의 이전값 리셋
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AddPage0ViewModel>().resetState();
    });
  }


  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AddPage0ViewModel>();
    double width = MediaQuery.of(context).size.width;
    if (kIsWeb) {
      width = 430;
    }
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: const DefaultAppBar(title: "새 여행지 추가"),
      body: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: width * 0.08,
            vertical: height * 0.03,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // 페이지 제목
              const Center(
                child: Text(
                  "여행 추가하기",
                  style: TextStyle(
                    fontSize: 26.7,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              SizedBox(height: height * 0.05),

              TitleInputSection(
                viewModel: viewModel,
                width: width,
                height: height,
              ),

              SizedBox(height: height * 0.05),

              // 여행 날짜 선택 영역 - DateSelectSection 위젯 분리 적용
              DateSelectSection(
                width: width,
                height: height,
                viewModel: viewModel,
              ),

              SizedBox(height: height * 0.073,),
              // 새 여행 만들기 버튼 - 여행 id 발급 및 행정구역 선택 페이지로 이동
              Padding(
                padding: EdgeInsets.symmetric(horizontal: width * 0.106, vertical: height * 0.086),
                child: Center(
                  child: ProceedButton(
                    size_w: width * 0.8,
                    size_h: height * 0.06,
                    text: "새 여행 만들기",
                    fontSize_: 18.5,
                    fontWeight_: FontWeight.bold,
                    onTap: () {
                      final success = viewModel.createTour(
                        context: context,
                        sigun: widget.sigun,
                      );

                      if (!success) {
                        showDialog(
                          context: context,
                          builder: (context) => const CustomAlertDialog(
                            title: '입력 오류',
                            contentText: '여행 이름(10자 이내)과 날짜를 모두 입력해주세요',
                          ),
                        );
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
