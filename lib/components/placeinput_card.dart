import 'package:flutter/material.dart';
import '../pages/add_page/searchplace_page.dart';

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

class _PlaceInputCardState extends State<PlaceInputCard> {
  final _imageUrlController = TextEditingController();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _mapXController = TextEditingController();
  final _mapYController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          ElevatedButton(
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
          const SizedBox(height: 12),
          TextField(
            controller: _imageUrlController,
            decoration: const InputDecoration(labelText: '이미지 URL'),
          ),
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: '장소명'),
          ),
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(labelText: '설명'),
          ),
          TextField(
            controller: _mapXController,
            decoration: const InputDecoration(labelText: 'mapX'),
          ),
          TextField(
            controller: _mapYController,
            decoration: const InputDecoration(labelText: 'mapY'),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(onPressed: widget.onCancel, child: const Text("취소")),
              ElevatedButton(
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
                child: const Text("완료"),
              ),
            ],
          )
        ],
      ),
    );
  }

  void setPlaceInfo(Map<String, dynamic> place) {
    _imageUrlController.text = place['imageUrl'] ?? '';
    _titleController.text = place['title'] ?? '';
    _descriptionController.text = place['address'] ?? '';
    _mapXController.text = (place['mapX'] ?? '').toString();
    _mapYController.text = (place['mapY'] ?? '').toString();
  }

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