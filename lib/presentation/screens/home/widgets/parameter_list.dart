import 'package:analyzer/presentation/controllers/entry_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../../controllers/parameter_controller.dart';
import 'parameter_card.dart';

class ParameterList extends StatelessWidget {
  const ParameterList({super.key});

  @override
  Widget build(BuildContext context) {
    final entryController = Get.find<EntryController>();
    final paramController = Get.find<ParameterController>();

    return Obx(() {
      final selectedDate = entryController.selectedDate.value;

      final visibleParams = paramController.parameters.where((param) {
        if (!param.isActive) return false;   // hide inactive habits
        final paramDate = DateTime(
          param.createdAt.year,
          param.createdAt.month,
          param.createdAt.day,
        );

        final selected = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
        );

        return !paramDate.isAfter(selected);
      }).toList();

      if (visibleParams.isEmpty) {
        return const SliverFillRemaining(
          child: Center(
            child: Text(
              'No Parameters For This Day',
              style: TextStyle(fontSize: 18),
            ),
          ),
        );
      }

      return SliverPadding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => ParameterEntryCard(param: visibleParams[index])
                .animate()
                .fadeIn(delay: Duration(milliseconds: 100 * index))
                .slideY(begin: 0.2, end: 0),
            childCount: visibleParams.length,
          ),
        ),
      );
    });
  }
}