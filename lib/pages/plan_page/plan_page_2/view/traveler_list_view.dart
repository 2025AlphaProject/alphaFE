import 'package:alpha_fe/pages/plan_page/plan_page_2/viewModel/traveler_list_viewModel.dart';
import '../viewModel/plan_page_2_viewModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';


class travelerList extends StatelessWidget {
  const travelerList({super.key});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    if (kIsWeb) {
      width = 430;
    }

    final vm = context.watch<travelersViewModel>();
    final travelers = vm.travelers;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: width * 0.025, vertical: 0.0115),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: height * 0.01),
          const Text(
            "여행자",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: height * 0.012),
          SizedBox(
            child: Wrap(
              spacing: width * 0.04,
              runSpacing: height * 0.01,
              children: [
                ...travelers.map((traveler) {
                  final rawUrl = traveler["imageUrl"] ?? '';
                  final imageUrl = (kIsWeb && rawUrl.startsWith('http://'))
                      ? 'https://images.weserv.nl/?url=${rawUrl.replaceFirst('http://', '')}'
                      : rawUrl;
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: width * 0.06,
                        backgroundImage: NetworkImage(imageUrl),
                      ),
                      SizedBox(height: height * 0.002),
                      SizedBox(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            traveler["name"]!,
                            style: const TextStyle(fontSize: 14.3),
                          ),
                        ),
                      ),
                    ],
                  );
                }),
                GestureDetector(
                  onTap: () {
                    final vmR = Provider.of<travelersViewModel>(context, listen: false);
                    final planVM = Provider.of<PlanPage2ViewModel>(context, listen: false);
                    vmR.onInviteTapped(
                      context,
                      planVM.tourId,
                      () => planVM.updateTourInfo(planVM.tourinfo),
                    );
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: width * 0.06,
                        backgroundColor: Colors.grey.shade200,
                        child: Icon(Icons.add, color: Colors.grey, size: width * 0.05),
                      ),
                      SizedBox(height: height * 0.002),
                      const SizedBox(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            "초대",
                            style: TextStyle(fontSize: 14.3),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
