import 'package:flutter/material.dart';
import '../../placeinput_card.dart';
import 'package:alpha_fe/pages/add_page/add_page_2/models/place_info.dart';

class PlaceInputArea extends StatelessWidget {
  final bool isAdding;
  final bool isWeb;
  final double width;
  final double height;
  final void Function() onTapAdd;
  final void Function() onCancel;
  final void Function(PlaceInfo) onComplete;
  final bool Function(String title, String description) isDuplicate;

  const PlaceInputArea({
    required this.isAdding,
    required this.isWeb,
    required this.width,
    required this.height,
    required this.onTapAdd,
    required this.onCancel,
    required this.onComplete,
    required this.isDuplicate,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isAdding && !isWeb) {
      return PlaceInputCard(
        onComplete: (imageUrl, title, description, mapX, mapY) {
          if (isDuplicate(title, description)) {
            showDialog(
              context: context,
              builder: (context) => const AlertDialog(
                title: Text('안내'),
                content: Text('이미 추가된 장소입니다'),
              ),
            );
            return;
          }
          final newPlace = PlaceInfo(
            imageUrl: imageUrl,
            title: title,
            description: description,
            mapX: mapX,
            mapY: mapY,
          );
          onComplete(newPlace);
        },
        onCancel: onCancel,
      );
    } else if (!isWeb) {
      return GestureDetector(
        onTap: onTapAdd,
        child: Container(
          width: width * 0.63,
          height: height * 0.2,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: Text(
              '+ 장소 추가',
              style: TextStyle(fontSize: 16.5),
            ),
          ),
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}