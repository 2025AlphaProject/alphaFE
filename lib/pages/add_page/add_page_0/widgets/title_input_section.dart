import 'package:flutter/material.dart';
import 'package:alpha_fe/pages/add_page/add_page_0/view_model/add_page_0_view_model.dart';

class TitleInputSection extends StatelessWidget {
  final AddPage0ViewModel viewModel;
  final double width;
  final double height;

  const TitleInputSection({
    super.key,
    required this.viewModel,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "✏️ 여행 제목",
          style: TextStyle(
            fontSize: 20.5,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: height * 0.01),
        SizedBox(
          height: height * 0.06,
          child: TextField(
            controller: viewModel.titleController,
            maxLength: 10,
            decoration: InputDecoration(
              isDense: true,
              hintText: "예) 여름 방학 서울 여행",
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
        const Text(
          "• 한글, 영문, 특수기호 구분없이 10자 이내로 입력",
          style: TextStyle(fontSize: 12.3, color: Colors.grey),
        ),
        const Text(
          "• 결정 후 수정할 수 없으니 신중히 정해주세요",
          style: TextStyle(fontSize: 12.3, color: Colors.grey),
        ),
      ],
    );
  }
}