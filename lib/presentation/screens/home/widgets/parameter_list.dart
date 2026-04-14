import 'package:analyzer/core/utils/app_strings.dart';
import 'package:analyzer/core/utils/helper.dart';
import 'package:analyzer/domain/entities/parameter_entity.dart';
import 'package:analyzer/presentation/controllers/entry_controller.dart';
import 'package:flutter/material.dart';
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
      /// LOADING STATE
      if (paramController.isLoading.value) {
        final fakeParams = [
          fakeParam("water"),
          fakeParam("money", type: ParameterType.value),
          fakeParam("reading"),
        ];

        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ParameterEntryCard(
                  param: fakeParams[index],
                ),
              );
            },
            childCount: fakeParams.length,
          ),
        );
      }

      final selectedDate = entryController.selectedDate.value;

      final visibleParams = paramController.parameters.where((param) {
        if (!param.isActive) return false;

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
        return SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Text(
              AppStrings.noParametersForDay,
              style: TextStyle(
                color: Colors.white54,
              ),
            ),
          ),
        );
      }

      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: index == visibleParams.length - 1 ? 0 : 12,
              ),
              child: ParameterEntryCard(
                param: visibleParams[index],
              ),
            );
          },
          childCount: visibleParams.length,
        ),
      );
    });
  }
}