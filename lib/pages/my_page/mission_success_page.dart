import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class MissionSuccessPage extends StatelessWidget {
  final int tdp_id;

  const MissionSuccessPage({
    required this.tdp_id,
    Key? key,
  }) : super(key: key);

  Future<String?> fetchMissionImage(int tdpId) async {
    final dio = Dio();
    try {
      final response = await dio.get('http://conever.duckdns.org:8000/mission/get_mission_img/$tdpId');
      return response.data['mission_image'] as String?;
    } catch (e) {
      print('이미지 요청 실패: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    if (kIsWeb) {
      width = 430;
    }
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      backgroundColor: Colors.white,
      body: FutureBuilder<String?>(
        future: fetchMissionImage(tdp_id),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          final imageUrl = snapshot.data;

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: width * 0.048),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: height * 0.023),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green, size: 28),
                    SizedBox(width: width * 0.019),
                    const Text(
                      "성공한 미션",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: height * 0.034),
                if (imageUrl != null && imageUrl.isNotEmpty)
                  Container(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height * 0.4,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey.shade300,
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                SizedBox(height: height * 0.023),
                const Text(
                  "🎉 성공한 미션입니다!",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}