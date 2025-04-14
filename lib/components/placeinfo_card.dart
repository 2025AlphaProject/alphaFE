import 'package:flutter/material.dart';

class PlaceInfoBlock extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String description;
  final double mapX;
  final double mapY;

  const PlaceInfoBlock({
    Key? key,
    required this.imageUrl,
    required this.title,
    required this.description,
    required this.mapX,
    required this.mapY,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.network(
              imageUrl,
              width: 260,
              height: 180,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.location_on, size: 20, color: Color(0xFF000000)),
              const SizedBox(width: 3),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF000000),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFF7A7A7A),
            ),
          ),
        ],
      ),
    );
  }
}