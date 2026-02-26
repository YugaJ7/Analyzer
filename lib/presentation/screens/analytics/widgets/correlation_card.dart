// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../../../controllers/analytics_controller.dart';

// class CorrelationCard extends StatelessWidget {
//   const CorrelationCard({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final controller = Get.find<AnalyticsController>();

//     return Obx(() {
//       if (controller.correlationInsight.value.isEmpty) {
//         return const SizedBox();
//       }

//       return Container(
//         padding: const EdgeInsets.all(20),
//         decoration: BoxDecoration(
//           color: const Color(0xFF1E2749),
//           borderRadius: BorderRadius.circular(20),
//         ),
//         child: Text(
//           controller.correlationInsight.value,
//           style: const TextStyle(color: Colors.white),
//         ),
//       );
//     });
//   }
// }
