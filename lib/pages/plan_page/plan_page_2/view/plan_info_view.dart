import 'package:alpha_fe/pages/plan_page/plan_page_2/viewModel/plan_info_viewModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';

class PlanInfo extends StatelessWidget {
  const PlanInfo({super.key});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    if (kIsWeb) {
      width = 430;
    }
    final vm = context.watch<PlanInfoViewmodel>();

    return Padding(
      padding: EdgeInsets.only(left: width * 0.025),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            color: Colors.red[600],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(width * 0.01),
            ),
            // margin: const EdgeInsets.all(5),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.03, vertical: height * 0.0025),
              child: Text(
                vm.getRemainingStatus(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14.3,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: width * 0.0075),
            child:  Text(
              vm.tourName,
              style: const TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: width * 0.0075),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.calendar_today, size: 14.3, color: Colors.grey),
                SizedBox(width: width * 0.0125),
                Text(
                  "${vm.startDate} ~ ${vm.endDate}",
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          )
        ],
      ) ,
    );
  }
}
