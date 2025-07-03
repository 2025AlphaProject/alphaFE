import 'package:alpha_fe/pages/add_page/add_page_2/view_models/show_tour_course_view_model.dart';
import 'package:alpha_fe/pages/add_page/add_page_2/view_models/add_page_2_view_model.dart';
import 'package:alpha_fe/services/http/save_tour_course/save_tour_course_from_add.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../../components/appbars/default_appbar/default_appbar.dart';
import '../../../components/proceed_button.dart';
import 'ai_loading_page.dart';
import 'package:alpha_fe/pages/add_page/add_page_2/models/place_info.dart';
import 'widgets/title_block.dart';
import 'widgets/date_selector.dart';
import 'widgets/place_info_list_section.dart';
import 'widgets/place_input_area.dart';

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
                          TitleBlock(title: widget.title),
                          SizedBox(height: height * 0.0267),
                          DateSelector(
                            dates: addPage2ViewModel.placeInfos.keys.toList(),
                            selectedDate: addPage2ViewModel.selectedDate,
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
                            PlaceInfoListSection(
                              placeList: addPage2ViewModel.placeInfos[addPage2ViewModel.selectedDate.value!] ?? [],
                              isEditMode: addPage2ViewModel.isEditMode,
                              width: width,
                              height: height,
                              onRemove: (info) {
                                addPage2ViewModel.removePlace(addPage2ViewModel.selectedDate.value!, info);
                              },
                            ),
                          if (addPage2ViewModel.selectedDate.value != null)
                            PlaceInputArea(
                              isAdding: addPage2ViewModel.isAddingPlaceMap[addPage2ViewModel.selectedDate.value!] == true,
                              isWeb: kIsWeb,
                              width: width,
                              height: height,
                              onTapAdd: () => addPage2ViewModel.toggleAddingPlace(addPage2ViewModel.selectedDate.value!, true),
                              onCancel: () => addPage2ViewModel.toggleAddingPlace(addPage2ViewModel.selectedDate.value!, false),
                              onComplete: (info) {
                                addPage2ViewModel.addNewPlace(addPage2ViewModel.selectedDate.value!, info);
                              },
                              isDuplicate: (title, desc) =>
                                addPage2ViewModel.isDuplicatePlace(addPage2ViewModel.selectedDate.value!, title, desc),
                            ),
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