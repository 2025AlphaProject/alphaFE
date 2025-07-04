import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:provider/provider.dart';
import 'package:alpha_fe/components/proceed_button.dart';
import 'package:alpha_fe/components/custom_alert_dialog.dart';
import 'searchplace_view_model.dart';
import 'package:flutter/src/foundation/constants.dart';

class SearchPlacePage extends StatelessWidget {
  final void Function({
  required String imageUrl,
  required String title,
  required String address,
  required double mapX,
  required double mapY,
  }) onPlaceSelected;

  const SearchPlacePage({Key? key, required this.onPlaceSelected}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (kIsWeb) width = 430;
    final height = MediaQuery.of(context).size.height;

    final viewModel = Provider.of<SearchPlaceViewModel>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFFF),
        title: TextField(
          controller: viewModel.searchController,
          style: const TextStyle(fontSize: 16.5),
          decoration: InputDecoration(
            hintText: '서울 내의 장소를 입력하세요',
            suffixIcon: IconButton(
              icon: const Icon(Icons.search),
              onPressed: () async {
                FocusScope.of(context).unfocus();
                try {
                  await viewModel.searchPlace(viewModel.searchController.text);
                  await viewModel.updateMarkers(context);
                } catch (e) {
                  await showDialog(
                    context: context,
                    builder: (context) => const CustomAlertDialog(
                      title: '오류',
                      contentText: '연결이 불안정합니다',
                    ),
                  );
                }
              },
            ),
          ),
          onSubmitted: (value) async {
            FocusScope.of(context).unfocus();
            try {
              await viewModel.searchPlace(value);
              await viewModel.updateMarkers(context);
            } catch (e) {
              await showDialog(
                context: context,
                builder: (context) => const CustomAlertDialog(
                  title: '오류',
                  contentText: '연결이 불안정합니다',
                ),
              );
            }
          },
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                width: double.infinity,
                height: height * 0.35,
                color: const Color(0xFFFFFFFF),
                child: NaverMap(
                  onMapReady: (controller) {
                    viewModel.setMapController(controller);
                  },
                  options: const NaverMapViewOptions(
                    initialCameraPosition: NCameraPosition(
                      target: NLatLng(37.5665, 126.9780),
                      zoom: 12,
                    ),
                  ),
                ),
              ),
              SizedBox(height: height * 0.015),
              // 검색 결과 리스트
              Expanded(
                child: Container(
                  color: const Color(0xFFFFFFFF),
                  child: ListView.separated(
                    itemCount: viewModel.places.length,
                    separatorBuilder: (context, index) => Divider(
                      color: Colors.grey.shade300,
                      height: 1,
                    ),
                    itemBuilder: (context, index) {
                      final place = viewModel.places[index];
                      final isSelected = viewModel.selectedPlace?['id'] == place['id'];

                      final titleColor = isSelected ? Colors.black : Colors.grey.shade600;
                      final subtitleColor = isSelected ? Colors.black : Colors.grey.shade600;

                      return ListTile(
                        tileColor: Colors.white,
                        selected: isSelected,
                        selectedTileColor: Colors.grey.shade200,
                        title: Text(
                          place['place_name'] ?? '',
                          style: TextStyle(
                            fontSize: 14.3,
                            color: titleColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          place['road_address_name'] ?? '',
                          style: TextStyle(
                            fontSize: 14.3,
                            color: subtitleColor,
                          ),
                        ),
                        onTap: () async {
                          viewModel.selectPlace(place);

                          try {
                            viewModel.mapController.updateCamera(
                              NCameraUpdate.scrollAndZoomTo(
                                target: NLatLng(
                                  double.parse(place['y']),
                                  double.parse(place['x']),
                                ),
                                zoom: width > 500 ? 14 : 15,
                              ),
                            );
                          } catch (_) {
                            int retry = 0;
                            bool success = false;
                            while (retry < 3 && !success) {
                              try {
                                await viewModel.initNaverMapSdk();
                                viewModel.mapController.updateCamera(
                                  NCameraUpdate.scrollAndZoomTo(
                                    target: NLatLng(
                                      double.parse(place['y']),
                                      double.parse(place['x']),
                                    ),
                                    zoom: width > 500 ? 14 : 15,
                                  ),
                                );
                                success = true;
                              } catch (_) {
                                retry++;
                              }
                            }
                            if (!success && context.mounted) {
                              Navigator.pop(context);
                              await showDialog(
                                context: context,
                                builder: (context) => const CustomAlertDialog(
                                  title: '오류',
                                  contentText: '연결이 불안정합니다',
                                ),
                              );
                            }
                          }
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
          if (viewModel.selectedPlace != null)
            Positioned(
              bottom: height * 0.02,
              left: width * 0.235,
              width: width * 0.53,
              height: height * 0.055,
              child: ProceedButton(
                fontSize_: 14.3,
                fontWeight_: FontWeight.bold,
                text: "이 장소 추가하기",
                onTap: () {
                  onPlaceSelected(
                    imageUrl: viewModel.selectedPlace!['thumbnail'] ?? '',
                    title: viewModel.selectedPlace!['place_name'] ?? '제목 없음',
                    address: viewModel.selectedPlace!['road_address_name'] ?? '주소 없음',
                    mapX: double.parse(viewModel.selectedPlace!['x']),
                    mapY: double.parse(viewModel.selectedPlace!['y']),
                  );
                  Navigator.pop(context);
                },
                size_w: width * 0.53,
                size_h: height * 0.055,
              ),
            ),
        ],
      ),
    );
  }
}