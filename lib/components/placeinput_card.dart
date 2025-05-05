import 'package:flutter/material.dart';
import '../pages/add_page/searchplace_page.dart';

// 사용자가 장소를 입력하거나 검색하여 정보를 입력할 수 있는 카드
class PlaceInputCard extends StatefulWidget {
  final void Function(String imageUrl, String title, String description, double mapX, double mapY) onComplete;
  final VoidCallback onCancel;

  const PlaceInputCard({
    Key? key,
    required this.onComplete,
    required this.onCancel,
  }) : super(key: key);

  @override
  State<PlaceInputCard> createState() => _PlaceInputCardState();
}

// PlaceInputCard의 상태 관리 클래스
// 텍스트 필드 컨트롤러로 입력값을 관리
class _PlaceInputCardState extends State<PlaceInputCard> {
  // 입력된 장소명 저장
  String _title = '';
  // 입력된 주소 저장
  String _description = '';
  String _imageUrl = '';
  double _mapX = 0.0;
  double _mapY = 0.0;

  // 카드 UI 구성
  // 검색 버튼, 텍스트 필드(장소명, 주소), 취소/완료 버튼
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Container(
      width: width * 0.63,
      padding: EdgeInsets.symmetric(horizontal: width * 0.016, vertical: height * .03),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(width * 0.05),
      ),
      child: Column(
        children: [
          // 🔹 '장소 찾아보기' 버튼: 외부 검색 화면으로 이동
          SizedBox(
            width: width * 0.38,
            child: ElevatedButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SearchPlacePage(
                      onPlaceSelected: ({
                        required String title,
                        required String address,
                        required String imageUrl,
                        required double mapX,
                        required double mapY,
                      }) {
                        if (mounted) {
                          setPlaceInfo({
                            'title': title,
                            'address': address,
                            'imageUrl': imageUrl,
                            'mapX': mapX,
                            'mapY': mapY,
                          });
                        }
                      },
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade700,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("🔍 장소 찾아보기", style: TextStyle(color: Colors.white, fontSize: 12.3)),
                ],
              ),
            ),
          ),

          SizedBox(height: height * 0.04),

          // 장소명 표시용 위젯
          Container(
            width: width * 0.5,
            height: height * 0.045,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade400),
            ),
            padding: EdgeInsets.symmetric(horizontal: width * 0.04),
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                const Text('🏠', style: TextStyle(fontSize: 10.2)),
                SizedBox(width: width * 0.02),
                Expanded(
                  child: Text(
                    _title,
                    style: const TextStyle(
                        fontSize: 12.3,
                        color: Color(0xFFB3B3B3),
                    ),
                    // 긴 텍스트일 경우 말줄임 표시
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: height * 0.02,),

          // 주소 표시용 위젯
          Container(
            width: width * 0.5,
            height: height * 0.045,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade400),
            ),
            padding: EdgeInsets.symmetric(horizontal: width * 0.04),
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                const Text('📍', style: TextStyle(fontSize: 10.2)),
                SizedBox(width: width * 0.02),
                Expanded(
                  child: Text(
                    _description,
                    style: const TextStyle(
                      fontSize: 10.2,
                      color: Color(0xFFB3B3B3),
                    ),
                    // 긴 텍스트일 경우 말줄임 표시
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: height * 0.06),

          // 완료, 취소 버튼
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: widget.onCancel,
                child: const Text("취소", style: TextStyle(color: Colors.black)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade700,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                // 입력 값 유효성 검사: 타이틀, 설명, 좌표가 올바른지 확인
                onPressed: () {
                  if (_title.isEmpty || _description.isEmpty || _mapX == 0.0 || _mapY == 0.0) {
                    // 유효하지 않은 경우 경고 다이얼로그 표시 후 함수 종료
                    showDialog(
                      context: context,
                      builder: (BuildContext dialogContext) => AlertDialog(
                        title: const Text('올바르지 않은 장소입니다'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(dialogContext).pop();
                            },
                            child: const Text('확인'),
                          ),
                        ],
                      ),
                    );
                    return;
                  }

                  // 모든 값이 유효할 때만 onComplete 호출
                  widget.onComplete(
                    _imageUrl,
                    _title,
                    _description,
                    _mapX,
                    _mapY,
                  );
                },
                child: const Text("완료", style: TextStyle(color: Colors.white)),
              ),
            ],
          )
        ],
      ),
    );
  }

  // 외부 검색 화면에서 장소를 선택했을 때 입력값을 자동으로 채워넣음
  void setPlaceInfo(Map<String, dynamic> place) {
    _imageUrl = place['imageUrl'] ?? '';
    _title = place['title'] ?? '';
    _description = place['address'] ?? '';
    _mapX = place['mapX'] ?? 0.0;
    _mapY = place['mapY'] ?? 0.0;
    setState(() {});
  }
}