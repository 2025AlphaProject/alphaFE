
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
  final _imageUrlController = TextEditingController();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _mapXController = TextEditingController();
  final _mapYController = TextEditingController();

  // 카드 UI 구성
  // 검색 버튼, 텍스트 필드, 취소/완료 버튼
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Container(
      width: width * 0.63,
      padding: EdgeInsets.symmetric(horizontal: width * 0.016, vertical: height * .03),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          // 🔹 '장소 찾아보기' 버튼: 외부 검색 화면으로 이동
          SizedBox(
            width: width * 0.45,
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("🔍 장소 찾아보기", style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
          ),
          SizedBox(height: height * 0.012),

          // 장소 정보를 입력하는 필드들, 검색을 통해 장소를 선택하면 자동으로 채워짐
          // 이미지 URL, 장소명, 설명, 위도(mapX), 경도(mapY)
          SizedBox(
            width: width * 0.55,
            child: TextField(
              controller: _imageUrlController,
              decoration: const InputDecoration(labelText: '이미지 URL'),
            ),
          ),
          SizedBox(
            width: width * 0.55,
            child: TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: '장소명'),
            ),
          ),
          SizedBox(
            width: width * 0.55,
            child: TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: '설명'),
            ),
          ),
          SizedBox(
            width: width * 0.55,
            child: TextField(
              controller: _mapXController,
              decoration: const InputDecoration(labelText: 'mapX'),
            ),
          ),
          SizedBox(
            width: width * 0.55,
            child: TextField(
              controller: _mapYController,
              decoration: const InputDecoration(labelText: 'mapY'),
            ),
          ),
          SizedBox(height: height * 0.012),

          // 완료, 취소 버튼
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(onPressed: widget.onCancel, child: const Text("취소", style: TextStyle(color: Colors.black),)),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade700
                ),
                // 🔹 완료 버튼 클릭 시 현재 입력된 정보로 onComplete 콜백 호출
                onPressed: () {
                  final mapX = double.tryParse(_mapXController.text) ?? 0.0;
                  final mapY = double.tryParse(_mapYController.text) ?? 0.0;
                  widget.onComplete(
                    _imageUrlController.text,
                    _titleController.text,
                    _descriptionController.text,
                    mapX,
                    mapY,
                  );
                },
                child: const Text("완료", style: TextStyle(color: Colors.white),),
              ),
            ],
          )
        ],
      ),
    );
  }

  // 외부 검색 화면에서 장소를 선택했을 때 입력값을 자동으로 채워넣음
  void setPlaceInfo(Map<String, dynamic> place) {
    _imageUrlController.text = place['imageUrl'] ?? '';
    _titleController.text = place['title'] ?? '';
    _descriptionController.text = place['address'] ?? '';
    _mapXController.text = (place['mapX'] ?? '').toString();
    _mapYController.text = (place['mapY'] ?? '').toString();
  }

  // 페이지 종료 시 텍스트 필드 컨트롤러 메모리 해제
  @override
  void dispose() {
    _imageUrlController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _mapXController.dispose();
    _mapYController.dispose();
    super.dispose();
  }
}