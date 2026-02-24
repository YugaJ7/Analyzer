import 'package:analyzer/presentation/controllers/entry_controller.dart';
import 'package:analyzer/presentation/controllers/parameter_controller.dart';
import 'package:analyzer/core/utils/helper.dart';
import 'package:analyzer/data/models/parameter_model.dart';
import 'package:analyzer/domain/entities/parameter_entity.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ParameterController _paramController = Get.find<ParameterController>();
  final EntryController _entryController = Get.find<EntryController>();
  final FocusNode _focusNode = FocusNode();
  final RxInt _selectedIndex = 0.obs;

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      await _entryController.loadEntries();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        switch (_selectedIndex.value) {
          case 0:
            return _buildHomeContent();
          case 1:
            return _buildAnalyticsPlaceholder();
          case 2:
            return _buildProfilePlaceholder();
          default:
            return _buildHomeContent();
        }
      }),

      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
          currentIndex: _selectedIndex.value,
          onTap: (index) {
            _selectedIndex.value = index;
          },

          backgroundColor: const Color(0xFF1E2749),
          selectedItemColor: const Color(0xFF6C63FF),
          unselectedItemColor: Colors.white70,

          type: BottomNavigationBarType.fixed,
          elevation: 20,

          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.insights_rounded),
              label: 'Analytics',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  @override
void dispose() {
  _focusNode.dispose();
  super.dispose();
}

  Widget _buildHomeContent() {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildDateSelector(),
                  const SizedBox(height: 20),
                  _buildProgressCard(),
                  const SizedBox(height: 24),
                  const Text(
                    'Your Habits',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          _buildParametersList(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello,',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withValues(alpha: 0.6),
              ),
            ),
            const Text(
              'Welcome Back',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ).animate().fadeIn().slideX(begin: -0.2, end: 0),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF6C63FF).withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.wb_sunny_rounded,
            color: Color(0xFF6C63FF),
            size: 28,
          ),
        ).animate().scale(delay: 200.ms),
      ],
    );
  }

  Widget _buildDateSelector() {
    return Obx(() {
      final selectedDate = _entryController.selectedDate.value;
      final isToday = _isSameDay(selectedDate, DateTime.now());

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E2749),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () {
                _entryController.changeSelectedDate(
                  selectedDate.subtract(const Duration(days: 1)),
                );
              },
              icon: const Icon(Icons.chevron_left, color: Colors.white),
            ),
            GestureDetector(
              onTap: () async {
                final picked = await showDatePicker(
                  context: Get.context!,
                  initialDate: selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                  builder: (context, child) {
                    return Theme(
                      data: ThemeData.dark().copyWith(
                        colorScheme: const ColorScheme.dark(
                          primary: Color(0xFF6C63FF),
                          surface: Color(0xFF1E2749),
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                if (picked != null) {
                  _entryController.changeSelectedDate(picked);
                }
              },
              child: Column(
                children: [
                  Text(
                    DateFormat('EEEE').format(selectedDate),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('MMM dd, yyyy').format(selectedDate),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  if (isToday)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4ECDC4).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Today',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF4ECDC4),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            IconButton(
              onPressed: _isSameDay(selectedDate, DateTime.now())
                  ? null
                  : () {
                      _entryController.changeSelectedDate(
                        selectedDate.add(const Duration(days: 1)),
                      );
                    },
              icon: Icon(
                Icons.chevron_right,
                color: _isSameDay(selectedDate, DateTime.now())
                    ? Colors.white.withValues(alpha: 0.3)
                    : Colors.white,
              ),
            ),
          ],
        ),
      ).animate().fadeIn(delay: 100.ms);
    });
  }

  Widget _buildProgressCard() {
    return Obx(() {
      final selectedDate = _entryController.selectedDate.value;
      final isToday = _isSameDay(selectedDate, DateTime.now());

      final visibleParams = _paramController.parameters.where((param) {
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

      final totalParams = visibleParams.length;

      final completedParams = _entryController.selectedDateEntries.length;

      final completion = totalParams == 0
          ? 0
          : (completedParams / totalParams) * 100;

      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6C63FF), Color(0xFF4ECDC4)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6C63FF).withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isToday ? 'Today\'s Progress' : 'Progress',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '$completedParams / $totalParams',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: completion / 100),
                duration: const Duration(milliseconds: 1200),
                curve: Curves.easeOutCubic,
                builder: (context, value, _) {
                  return LinearProgressIndicator(
                    value: value,
                    minHeight: 12,
                    backgroundColor: Colors.white.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(10),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.white,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '${completion.toStringAsFixed(0)}% Complete',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ).animate().fadeIn(),
          ],
        ),
      );
    });
  }

  Widget _buildParametersList() {
    return Obx(() {
      final selectedDate = _entryController.selectedDate.value;

      final visibleParams = _paramController.parameters.where((param) {
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
          delegate: SliverChildBuilderDelegate((context, index) {
            final param = visibleParams[index];
            return _buildParameterEntryCard(param)
                .animate()
                .fadeIn(delay: Duration(milliseconds: 100 * index))
                .slideX(begin: 0.2, end: 0);
          }, childCount: visibleParams.length),
        ),
      );
    });
  }

  Widget _buildParameterEntryCard(ParameterModel param) {
    final color = getColorForParam(param.color);

    return Obx(() {
      final entry = _entryController.selectedDateEntries[param.id];
      final isCompleted = entry != null;

      return GestureDetector(
        onTap: () {
          if (param.type == ParameterType.checklist) {
            _entryController.toggleEntry(param.id, true);
          }
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 18),
          decoration: BoxDecoration(
            color: const Color(0xFF1E2749),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isCompleted
                              ? const Color(0xFF6C63FF)
                              : Colors.white.withValues(alpha: 0.4),
                          width: 2,
                        ),
                        color: isCompleted
                            ? const Color(0xFF6C63FF)
                            : Colors.transparent,
                      ),
                      child: isCompleted
                          ? const Icon(
                              Icons.check,
                              size: 16,
                              color: Colors.white,
                            )
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        param.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.local_fire_department_rounded,
                          color: color,
                          size: 22,
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          "0",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                //const SizedBox(height: 20),
                ?_buildModernValueDisplay(param),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget? _buildModernValueDisplay(ParameterModel param) {
    switch (param.type) {
      case ParameterType.checklist:
        return null;

      case ParameterType.value:
        return _buildNumericPreview(param);

      case ParameterType.optionSelector:
        return _buildOptionPreview(param);
    }
  }

  Widget _buildOptionPreview(ParameterModel param) {
    final entry = _entryController.selectedDateEntries[param.id];
    final selectedValue = entry?.value;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: param.options!.map<Widget>((option) {
          final isSelected = selectedValue == option;

          return GestureDetector(
            onTap: () {
              _entryController.toggleEntry(param.id, option);
            },
            child: Container(
              margin: const EdgeInsets.fromLTRB(0, 20, 12, 0),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF6C63FF)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF6C63FF)
                      : Colors.white.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: Text(
                option,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.6),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildNumericPreview(ParameterModel param) {
    return Obx(() {
      final entry = _entryController.selectedDateEntries[param.id];
      final currentValue = entry?.value?.toString() ?? '';

      final controller = TextEditingController(text: currentValue);

      controller.selection = TextSelection.fromPosition(
        TextPosition(offset: controller.text.length),
      );

      return AnimatedBuilder(
  animation: _focusNode,
  builder: (context, child) {
    final bool isFocused = _focusNode.hasFocus;

    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Colors.transparent,
        border: Border.all(
          strokeAlign: BorderSide.strokeAlignCenter, // 🔥 ensures border doesn't affect layout
          color: isFocused
              ? const Color(0xFF6C63FF)             // 🔥 focused color
              : Colors.white.withOpacity(0.3),
          width: isFocused ? 2 : 1,           // 🔥 stroke thickness
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          IntrinsicWidth(
            child: TextField(
              focusNode: _focusNode,  // 🔥 IMPORTANT
              controller: controller,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
              decoration: const InputDecoration(
                isDense: true,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                hintText: "Enter value",
                hintStyle: TextStyle(
                  color: Colors.white38,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            param.unit ?? '',
            style: const TextStyle(
              color: Colors.white38,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  },
);
    });
  }

  Widget _buildAnalyticsPlaceholder() {
    return const Center(
      child: Text('Analytics Screen - Navigate using bottom nav'),
    );
  }

  Widget _buildProfilePlaceholder() {
    return const Center(
      child: Text('Profile Screen - Navigate using bottom nav'),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
