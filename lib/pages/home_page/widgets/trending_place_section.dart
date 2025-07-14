import 'package:flutter/material.dart';
import '../../../components/proceed_button.dart';

class TrendingPlaceSection extends StatelessWidget {
  final Map<String, dynamic>? recommendedPlace;
  final String sigunguText;
  final String? username;
  final double width;
  final double height;
  final VoidCallback onTap;

  const TrendingPlaceSection({
    super.key,
    required this.recommendedPlace,
    required this.sigunguText,
    required this.username,
    required this.width,
    required this.height,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (recommendedPlace != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.network(
              recommendedPlace!['image1'],
              width: width * 0.87,
              height: height * 0.25,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => _errorImageBox(),
            ),
          ),
          SizedBox(height: height * 0.015),
          Row(
            children: [
              const Icon(Icons.location_on, size: 17),
              SizedBox(width: width * 0.013),
              Text(
                recommendedPlace!['title'],
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: height * 0.007),
          Padding(
            padding: EdgeInsets.only(left: width * 0.053),
            child: Text(
              "$sigunguText의 관광지인 ${recommendedPlace!['title']}!\n${username ?? ''} 님의 취향에 맞을지도 몰라요.",
              style: TextStyle(fontSize: 13, color: Colors.grey[700]),
            ),
          ),
          SizedBox(height: height * 0.017),
          Center(
            child: ProceedButton(
              size_w: width * 0.5,
              size_h: height * 0.05,
              text: "$sigunguText 코스 생성하기",
              fontSize_: 13,
              fontWeight_: FontWeight.bold,
              onTap: onTap,
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        _errorImageBox(),
        SizedBox(height: height * 0.015),
        Text('트렌딩 데이터를 불러오는 중입니다...', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
        SizedBox(height: height * 0.017),
        Center(
          child: ProceedButton(
            size_w: width * 0.5,
            size_h: height * 0.05,
            text: '가져오는 중...',
            fontSize_: 13,
            fontWeight_: FontWeight.bold,
            onTap: () {},
          ),
        ),
      ],
    );
  }

  Widget _errorImageBox() {
    return Container(
      width: width * 0.87,
      height: height * 0.25,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(
        child: Icon(Icons.broken_image, size: 40, color: Colors.grey),
      ),
    );
  }
}