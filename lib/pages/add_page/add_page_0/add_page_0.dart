import 'package:alpha_fe/pages/add_page/add_page_0/view_model/tour_create_view_model.dart';
import 'package:alpha_fe/pages/add_page/add_page_1/add_page_1.dart';
import 'package:alpha_fe/pages/add_page/add_page_2/add_page_2.dart';
import 'package:alpha_fe/providers/auth_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../components/custom_alert_dialog.dart';
import '../../../components/proceed_button.dart';
import '../../../components/app_bar.dart';
import 'package:alpha_fe/pages/add_page/add_page_0/view_model/add_page_0_view_model.dart';


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

              // 여행 제목 입력 - 10글자 제한
              const Text("✏️ 여행 제목",
                  style: TextStyle(
                    fontSize: 20.5,
                    fontWeight: FontWeight.bold,
                  )),
              SizedBox(height: height * 0.01),
              SizedBox(
                height: height * 0.06,
                child: TextField(
                  controller: viewModel.titleController,
                  maxLength: 10,
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: viewModel.selectedDateRange == null
                        ? ""
                        : "${viewModel.selectedDateRange!.start.year}.${viewModel.selectedDateRange!.start.month.toString().padLeft(2, '0')}.${viewModel.selectedDateRange!.start.day.toString().padLeft(2, '0')} ~ "
                        "${viewModel.selectedDateRange!.end.year}.${viewModel.selectedDateRange!.end.month.toString().padLeft(2, '0')}.${viewModel.selectedDateRange!.end.day.toString().padLeft(2, '0')}",
                    hintStyle: const TextStyle(
                      fontSize: 14.3,
                      color: Colors.grey,
                      fontWeight: FontWeight.w400,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    counterText: "",
                    contentPadding: EdgeInsets.symmetric(
                      vertical: height * 0.02,
                      horizontal: width * 0.03,
                    ),
                  ),
                ),
              ),
              SizedBox(height: height * 0.005),
              const Text("• 한글, 영문, 특수기호 구분없이 10자 이내로 입력",
                  style: TextStyle(fontSize: 12.3, color: Colors.grey)),
              const Text("• 결정 후 수정할 수 없으니 신중히 정해주세요",
                  style: TextStyle(fontSize: 12.3, color: Colors.grey)),

              SizedBox(height: height * 0.05),

              // 여행 날짜 입력 - material.dart의 DateRangePicker 사용
              const Text("✏️ 여행 날짜",
                  style: TextStyle(
                    fontSize: 20.5,
                    fontWeight: FontWeight.bold,
                  )),
              SizedBox(height: height * 0.01),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [

                  // 날짜 표시 필드
                  Expanded(
                    child: SizedBox(
                      height: height * 0.06,
                      child: TextField(
                        readOnly: true,
                        cursorColor: const Color(0xFF2C2C2C),
                        decoration: InputDecoration(
                          isDense: true,
                          hintText: viewModel.selectedDateRange == null
                              ? ""
                              : "${viewModel.selectedDateRange!.start.year}.${viewModel.selectedDateRange!.start.month.toString().padLeft(2, '0')}.${viewModel.selectedDateRange!.start.day.toString().padLeft(2, '0')} ~ "
                                "${viewModel.selectedDateRange!.end.year}.${viewModel.selectedDateRange!.end.month.toString().padLeft(2, '0')}.${viewModel.selectedDateRange!.end.day.toString().padLeft(2, '0')}",
                          hintStyle: const TextStyle(
                            fontSize: 12.3,
                            color: Colors.grey,
                            fontWeight: FontWeight.w400,
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF5F5F5),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          counterText: "",
                          contentPadding: EdgeInsets.symmetric(
                            vertical: height * 0.02,
                            horizontal: width * 0.03,
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(width: width * 0.02),

                  // 날짜 선택 버튼 - showDateRangePicker 호출
                  SizedBox(
                    height: height * 0.058,
                    width: width * 0.14,
                    child: ElevatedButton(
                      onPressed: () => viewModel.selectDateRange(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2C2C2C),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "🗓️",
                        style: TextStyle(
                          fontSize: 18.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: height * 0.005),

              Text(
                  "• 지금은 3일만 선택할 수 있습니다",
                  style: TextStyle(fontSize: 12.3, color: Colors.red.shade500)
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
                    onTap: () => viewModel.createTour(context, widget.sigun),
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
