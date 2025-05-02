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
      appBar: DefaultAppBar(title: '문화행사'),
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
    final event = widget.eventData;
    return SingleChildScrollView(// 사진 크기 때문에 scrollview로
      child: Padding(
        padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.066),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              event['title'],
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width * 0.066,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.035),
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
                  errorBuilder: (context, error, stackTrace) => Center(
                    child: Icon(
                      Icons.broken_image,
                      size: MediaQuery.of(context).size.width * 0.13,
                    ),
                  ),
                ),
              ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.035),
            infoRow("유형", event['category'] ?? "-"), //전시유형
            SizedBox(height: MediaQuery.of(context).size.height * 0.012),
            infoRow("행사 기간", "${event['start_date'] ?? '-'} ~ ${event['end_date'] ?? '-'}"),  //기간
            SizedBox(height: MediaQuery.of(context).size.height * 0.012),
            infoRow( //행사별 웹사이트로 이동 가능 링크 연동
              "웹사이트",
              (event['homepage_url'] == null || event['homepage_url'].toString().isEmpty)
                  ? "-"
                  : "웹사이트 보러가기→",
              isLink: event['homepage_url'] != null && event['homepage_url'].toString().isNotEmpty,
              url: event['homepage_url'],
            ),
          ],
        ),
      ),
    );
  }

  //행사별 사이트 링크 연결
  Widget infoRow(String label, String value, {bool isLink = false, String? url}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.22,
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        Expanded(
          child: isLink
              ? GestureDetector(
                  onTap: () async {
                    if (url != null && await canLaunchUrl(Uri.parse(url))) {  //성공시 외부 링크로 이동
                      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                    } else {//열기 실패시
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("웹사이트를 열 수 없습니다.")),
                      );
                    }
                  },
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width * 0.035,
                      color: Colors.grey,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                )
              : Text(value, style: TextStyle(
                fontSize: MediaQuery.of(context).size.width * 0.035,
                color: Colors.grey,
                decoration: null,
              )),
        ),
      ],
    );
  }
}
