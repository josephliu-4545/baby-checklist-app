import 'package:flutter/material.dart';

import '../features/items/presentation/screens/add_item_screen.dart';
import '../features/items/presentation/screens/home_screen.dart';
import '../features/items/presentation/screens/summary_screen.dart';
import '../features/auth/presentation/screens/profile_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  int _homeReloadToken = 0;

  List<Widget> get _pages => [
        HomeScreen(key: ValueKey(_homeReloadToken)),
        const SizedBox.shrink(),
        const SummaryScreen(),
        const ProfileScreen(),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => _onTabSelected(context, index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline),
            selectedIcon: Icon(Icons.add_circle),
            label: 'Add',
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics_outlined),
            selectedIcon: Icon(Icons.analytics),
            label: 'Summary',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Future<void> _onTabSelected(BuildContext context, int index) async {
    if (index == 1) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AddItemScreen()),
      );

      setState(() {
        _homeReloadToken++;
        _currentIndex = 0;
      });
      return;
    }

    setState(() {
      _currentIndex = index;
    });
  }
}

