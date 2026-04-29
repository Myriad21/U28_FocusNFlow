import 'package:flutter/material.dart';

import '../../services/app_navigation.dart';
import '../groups/groups_screen.dart';
import '../home/dashboard_screen.dart';
import '../planner/weekly_planner_screen.dart';
import '../profile/profile_screen.dart';
import '../rooms/room_finder_screen.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key});

  static const List<Widget> _screens = [
    DashboardScreen(),
    WeeklyPlannerScreen(),
    GroupsScreen(),
    RoomFinderScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: AppNavigation.selectedTab,
      builder: (context, selectedIndex, _) {
        return Scaffold(
          body: IndexedStack(index: selectedIndex, children: _screens),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: const Border(top: BorderSide(color: Color(0xFFE2E8F0))),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.07),
                  blurRadius: 24,
                  offset: const Offset(0, -8),
                ),
              ],
            ),
            child: NavigationBar(
              height: 74,
              backgroundColor: Colors.white,
              indicatorColor: const Color(0xFFE0E7FF),
              selectedIndex: selectedIndex,
              onDestinationSelected: AppNavigation.goTo,
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon: Icon(Icons.dashboard),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(Icons.auto_awesome_outlined),
                  selectedIcon: Icon(Icons.auto_awesome),
                  label: 'Planner',
                ),
                NavigationDestination(
                  icon: Icon(Icons.groups_outlined),
                  selectedIcon: Icon(Icons.groups),
                  label: 'Groups',
                ),
                NavigationDestination(
                  icon: Icon(Icons.meeting_room_outlined),
                  selectedIcon: Icon(Icons.meeting_room),
                  label: 'Rooms',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline),
                  selectedIcon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
