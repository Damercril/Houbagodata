import 'package:flutter/material.dart';
import 'package:houbago/houbago/houbago_theme.dart';
import 'package:houbago/houbago/screens/home/home_screen.dart';
import 'package:houbago/houbago/screens/search/search_screen.dart';
import 'package:houbago/houbago/screens/account/account_screen.dart';
import 'package:houbago/houbago/screens/add/add_screen.dart';
import 'package:houbago/houbago/screens/objectives/objectives_screen.dart';
import 'package:houbago/houbago/ui_view/custom_bottom_bar.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const SearchScreen(),
    const AddScreen(),
    const ObjectivesScreen(),
    const AccountScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HoubagoTheme.background,
      body: Stack(
        children: [
          IndexedStack(
            index: _selectedIndex,
            children: _screens,
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: CustomBottomBar(
              selectedIndex: _selectedIndex,
              onItemTapped: _onItemTapped,
            ),
          ),
        ],
      ),
    );
  }
}
