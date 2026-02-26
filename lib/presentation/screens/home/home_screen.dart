import 'package:analyzer/presentation/controllers/entry_controller.dart';
import 'package:analyzer/presentation/screens/analytics/analytics_screen.dart';
import 'package:analyzer/presentation/screens/home/widgets/date_selector.dart';
import 'package:analyzer/presentation/screens/home/widgets/home_header.dart';
import 'package:analyzer/presentation/screens/home/widgets/parameter_list.dart';
import 'package:analyzer/presentation/screens/home/widgets/progress_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final EntryController _entryController = Get.find<EntryController>();

  final RxInt _selectedIndex = 0.obs;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _entryController.loadEntries());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
        () => IndexedStack(
          index: _selectedIndex.value,
          children: const [
            _HomeTab(),
            AnalyticsScreen(),
            Center(child: Text("Profile")),
          ],
        ),
      ),
      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
          currentIndex: _selectedIndex.value,
          onTap: (i) => _selectedIndex.value = i,
          backgroundColor: const Color(0xFF1E2749),
          selectedItemColor: const Color(0xFF6C63FF),
          unselectedItemColor: Colors.white70,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(
              icon: Icon(Icons.insights),
              label: "Analytics",
            ),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          ],
        ),
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HomeHeader(),
                  SizedBox(height: 24),
                  DateSelector(),
                  SizedBox(height: 20),
                  ProgressCard(),
                  SizedBox(height: 24),
                  Text(
                    "Your Habits",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 16),
                ],
              ),
            ),
          ),
          ParameterList(),
        ],
      ),
    );
  }
}
