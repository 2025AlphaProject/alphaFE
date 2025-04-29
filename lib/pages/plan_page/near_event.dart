import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class nearEvents extends StatelessWidget {
  final Map<String, dynamic> eventData;
  const nearEvents({super.key,
    required this.eventData,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("주변 문화행사")),
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
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              event['title'],
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              height: 300,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(8),
              ),
              clipBehavior: Clip.hardEdge,
              child: event['image_url'] != null && event['image_url'].toString().isNotEmpty
                  ? Image.network(event['image_url'], fit: BoxFit.cover)
                  : const Center(child: Icon(Icons.image_not_supported, size: 48)),
            ),
            const SizedBox(height: 24),
            infoRow("유형", event['category'] ?? "-"),
            const SizedBox(height: 8),
            infoRow("행사 기간", "${event['start_date'] ?? '-'} ~ ${event['end_date'] ?? '-'}"),
            const SizedBox(height: 8),
            infoRow(
              "웹사이트",
              (event['homepage_url'] == null || event['homepage_url'].toString().isEmpty)
                  ? "-"
                  : "웹사이트 보기→",
              isLink: event['homepage_url'] != null && event['homepage_url'].toString().isNotEmpty,
              url: event['homepage_url'],
            ),
          ],
        ),
      ),
    );
  }

  Widget infoRow(String label, String value, {bool isLink = false, String? url}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
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
                    style: const TextStyle(color: Colors.grey, decoration: TextDecoration.underline),
                  ),
                )
              : Text(value, style: const TextStyle(color: Colors.grey)),
        ),
      ],
    );
  }
}
