import 'package:flutter/material.dart';
import 'package:alpha_fe/pages/add_page/add_page_2/models/place_info.dart';
import '../placeinfo_card.dart';

class PlaceInfoListSection extends StatelessWidget {
  final List<PlaceInfo> placeList;
  final bool isEditMode;
  final double width;
  final double height;
  final void Function(PlaceInfo) onRemove;

  const PlaceInfoListSection({
    required this.placeList,
    required this.isEditMode,
    required this.width,
    required this.height,
    required this.onRemove,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: placeList.map((info) {
        return Column(
          children: [
            Stack(
              children: [
                PlaceInfoBlock(
                  imageUrl: info.imageUrl,
                  title: info.title,
                  description: info.description,
                  mapX: info.mapX,
                  mapY: info.mapY,
                  width: width * 0.63,
                  height: height * 0.2,
                ),
                if (isEditMode)
                  Positioned(
                    top: 0,
                    left: 0,
                    child: GestureDetector(
                      onTap: () => onRemove(info),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.8),
                          shape: BoxShape.circle,
                        ),
                        padding: EdgeInsets.symmetric(
                          vertical: height * 0.004,
                          horizontal: width * 0.01,
                        ),
                        child: const Icon(Icons.close, size: 18.5, color: Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: height * 0.0268),
          ],
        );
      }).toList(),
    );
  }
}