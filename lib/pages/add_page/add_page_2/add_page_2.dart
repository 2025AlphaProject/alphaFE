import 'package:alpha_fe/pages/add_page/add_page_2/view_models/show_tour_course_view_model.dart';
import 'package:alpha_fe/pages/add_page/add_page_2/view_models/add_page_2_view_model.dart';
import 'package:alpha_fe/services/http/save_tour_course/save_tour_course_from_add.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../../components/app_bar.dart';
import '../../../components/proceed_button.dart';
import '../../../components/placeinfo_card.dart';
import '../../../components/placeinput_card.dart';
import '../../../components/ai_loading_page.dart';
import '../../../components/date_dropdown.dart';
import '../../../components/custom_alert_dialog.dart';
import 'package:alpha_fe/pages/add_page/add_page_2/models/place_info.dart';

class AddPage_2 extends StatefulWidget {
  final String title;
  final int tourId;

  const AddPage_2({
    required this.title,
    required this.tourId,
    Key? key,
  }) : super(key: key);

  @override
  State<AddPage_2> createState() => _AddPage_2State();
}

class _AddPage_2State extends State<AddPage_2> {
  late ScrollController _scrollController;
  bool _didReset = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    Future.microtask(() {
      final viewModel = Provider.of<ShowTourCourseViewModel>(context, listen: false);
      viewModel.fetchCourseRecommendation(
        context: context,
        tourId: widget.tourId,
        areaName: widget.title,
        isWeb: kIsWeb,
      );
    });
  }



  // PlaceInfoBlock 목록 상단에 표시되는 안내 문구
  Widget _buildTitleBlock() {
    double width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    if (kIsWeb) {
      width = 430;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("📍${widget.title}", style: const TextStyle(fontSize: 26.7, fontWeight: FontWeight.w900)),
        const Padding(
          padding: EdgeInsets.only(left: 37.5),
          child: Text('근처 코스를 알려드릴게요', style: TextStyle(fontSize: 14.3, color: Color(0xFF757575))),
        ),
        SizedBox(height: height * 0.0138),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: width * 0.02),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              const Text('최근 업데이트: ', style: TextStyle(fontSize: 14.3, fontWeight: FontWeight.bold, color: Color(0xFF7F7F7F))),
              SizedBox(width: width * 0.01),
              // 오늘 날짜를 yyyy-MM-dd 형식으로 표시
              Text(DateTime.now().toLocal().toString().substring(0, 10), style: TextStyle(fontSize: width * 0.03, color: const Color(0xFF7F7F7F))),
            ],
          ),
        ),
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AddPage2ViewModel>(
      create: (_) => AddPage2ViewModel(),
      builder: (context, _) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.read<AddPage2ViewModel>().onViewEnter();
        });
        final height = MediaQuery.of(context).size.height;
        double width = MediaQuery.of(context).size.width;
        final viewModel = context.watch<ShowTourCourseViewModel>();
        final addPage2ViewModel = context.watch<AddPage2ViewModel>();

        if (addPage2ViewModel.placeInfos.isEmpty && viewModel.placeMap.isNotEmpty) {
          addPage2ViewModel.placeInfos.addEntries(
            viewModel.placeMap.entries.map((e) =>
              MapEntry<String, List<PlaceInfo>>(e.key, List<PlaceInfo>.from(e.value))
            ),
          );
          if (addPage2ViewModel.selectedDate.value == null) {
            addPage2ViewModel.selectedDate.value = viewModel.placeMap.keys.first;
          }
        }

        if (kIsWeb) {
          width = 430;
        }
        if (viewModel.isLoading) {
          return const AILoadingView();
        }
        return Scaffold(
          backgroundColor: const Color(0xFFFFFFFF),
          appBar: const DefaultAppBar(title: "새 여행지 추가"),
          body: Stack(
            alignment: Alignment.center,
            children: [
              NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  addPage2ViewModel.handleScrollNotification(notification);
                  return false;
                },
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: height * 0.0138,
                      horizontal: width * 0.06,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: height,
                        minWidth: width,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: height * 0.028),
                          _buildTitleBlock(),
                          SizedBox(height: height * 0.0267),
                          DateDropdown(
                            selectedDate: addPage2ViewModel.selectedDate,
                            dates: addPage2ViewModel.placeInfos.keys.toList(),
                            height: height,
                            width: width,
                            onChanged: (value) {
                              addPage2ViewModel.updateSelectedDate(value);
                            },
                          ),
                          if (addPage2ViewModel.placeInfos.isNotEmpty &&
                              addPage2ViewModel.placeInfos.entries.any((e) => e.value.isNotEmpty))
                            Align(
                              alignment: Alignment.centerRight,
                              child: IconButton(
                                icon: Icon(
                                  addPage2ViewModel.isEditMode ? Icons.save : Icons.edit,
                                  color: Colors.black87,
                                ),
                                onPressed: () {
                                  addPage2ViewModel.toggleEditMode();
                                },
                              ),
                            ),
                          if (addPage2ViewModel.selectedDate.value != null)
                            for (var info in addPage2ViewModel.placeInfos[addPage2ViewModel.selectedDate.value!] ?? []) ...[
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
                                  if (addPage2ViewModel.isEditMode)
                                    Positioned(
                                      top: 0,
                                      left: 0,
                                      child: GestureDetector(
                                        onTap: () {
                                          addPage2ViewModel.removePlace(addPage2ViewModel.selectedDate.value!, info);
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.red.withOpacity(0.8),
                                            shape: BoxShape.circle,
                                          ),
                                          padding: EdgeInsets.symmetric(
                                            vertical: height * .004,
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
                          if (addPage2ViewModel.selectedDate.value != null)
                            (addPage2ViewModel.isAddingPlaceMap[addPage2ViewModel.selectedDate.value!] == true && !kIsWeb)
                                ? PlaceInputCard(
                                    onComplete: (imageUrl, title, description, mapX, mapY) {
                                      if (addPage2ViewModel.isDuplicatePlace(addPage2ViewModel.selectedDate.value!, title, description)) {
                                        showDialog(
                                          context: context,
                                          builder: (context) => const CustomAlertDialog(
                                            title: '안내',
                                            contentText: '이미 추가된 장소입니다',
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
                                      addPage2ViewModel.addNewPlace(addPage2ViewModel.selectedDate.value!, newPlace);
                                    },
                                    onCancel: () => addPage2ViewModel.toggleAddingPlace(addPage2ViewModel.selectedDate.value!, false),
                                  )
                                : (!kIsWeb
                                    ? GestureDetector(
                                        onTap: () => addPage2ViewModel.toggleAddingPlace(addPage2ViewModel.selectedDate.value!, true),
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
                                      )
                                    : const SizedBox.shrink()),
                          SizedBox(height: height * 0.0184),
                          SizedBox(height: height * 0.13),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Visibility(
                visible: addPage2ViewModel.visibleButton,
                maintainSize: false,
                maintainAnimation: true,
                maintainState: true,
                child: Stack(
                  children: [
                    Positioned(
                      bottom: height * 0.0344,
                      left: 0,
                      right: 0,
                      child: AnimatedSlide(
                        duration: const Duration(milliseconds: 300),
                        offset: addPage2ViewModel.visibleButton ? Offset.zero : const Offset(0, 1.2),
                        curve: Curves.easeInOut,
                        child: Center(
                          child: ProceedButton(
                            size_w: width * 0.53,
                            size_h: height * 0.055,
                            text: "이 코스로 할게요!",
                            fontSize_: 14.3,
                            fontWeight_: FontWeight.bold,
                            onTap: () async {
                              await SaveTourCourseFromAdd().saveCourse(
                                context: context,
                                placeWidgets: addPage2ViewModel.placeInfos.entries.toList(),
                                tourId: widget.tourId,
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }
}