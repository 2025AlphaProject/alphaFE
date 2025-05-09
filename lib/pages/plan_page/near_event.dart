import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:alpha_fe/components/app_bar.dart';

//각 장소별 상세정보페이지
class nearEvents extends StatelessWidget {
  final Map<String, dynamic> eventData;
  const nearEvents({super.key,
    required this.eventData,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: DefaultAppBar(title: '주변문화행사'),
      body: nearEvent(eventData),
    );
  }
}


class nearEvent extends StatefulWidget {
  final Map<String, dynamic> eventData;
  const nearEvent(this.eventData, {super.key});

  @override
  State<nearEvent> createState() => _nearEventState();
}

class _nearEventState extends State<nearEvent> {
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    if (kIsWeb) {
      width = 430;
    }
    final event = widget.eventData;
    return SingleChildScrollView(// 사진 크기 때문에 scrollview로
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: width * 0.066, vertical: height* 0.0306),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(top: height * 0.05),
              child: Text(
                event['title'],
                style: const TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: height * 0.035),
            if (event['img_url'] != null && event['img_url'].toString().isNotEmpty) //사진 url 있으면 사진 나타내기
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(8),
                ),
                clipBehavior: Clip.hardEdge,
                child: Image.network(
                  event['img_url'],
                  fit: BoxFit.fitWidth,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(child: CircularProgressIndicator());
                  },
                  errorBuilder: (context, error, stackTrace) => const Center(
                    child: Icon(
                      Icons.broken_image,
                      size: 53.5,
                    ),
                  ),
                ),
              ),
            SizedBox(height: height * 0.035),
            infoRow("유형", event['category'] ?? "-", width, height), //전시유형
            SizedBox(height: height * 0.012),
            infoRow("행사 기간", "${event['start_date'] ?? '-'} ~ ${event['end_date'] ?? '-'}", width, height),  //기간
            SizedBox(height: height * 0.012),
            infoRow( //행사별 웹사이트로 이동 가능 링크 연동
              "웹사이트",
              (event['homepage_url'] == null || event['homepage_url'].toString().isEmpty)
                  ? "-"
                  : "웹사이트 보러가기→",
              width, height,
              isLink: event['homepage_url'] != null && event['homepage_url'].toString().isNotEmpty,
              url: event['homepage_url'],
            ),
            SizedBox(height: height * 0.03)
          ],
        ),
      ),
    );
  }

  //행사별 사이트 링크 연결
  Widget infoRow(String label, String value, double width, double height, {bool isLink = false, String? url}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: height * 0.0066),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: width * 0.25,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
          Expanded(
            child: isLink
                ? GestureDetector(
                    onTap: () async {
                      if (url != null && await canLaunchUrl(Uri.parse(url))) {
                        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("웹사이트를 열 수 없습니다.")),
                        );
                      }
                    },
                    child: Text(
                      value,
                      style: TextStyle(
                        fontSize: 15,
                        color: Theme.of(context).colorScheme.primary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  )
                : Text(
                    value,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.grey,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
