import 'package:flutter/material.dart';
import 'package:security_app/views/all_images_screen.dart';
import 'package:security_app/views/homescreen.dart';

class LandingView extends StatefulWidget {
  const LandingView({super.key});

  @override
  State<LandingView> createState() => _LandingViewState();
}

class _LandingViewState extends State<LandingView> {
  int _selectedIndex = 0;

  // List of screens to switch between
  static const List<Widget> _screens = <Widget>[
    SecurityAppHomescreen(),
    AllImagesScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.teal,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey.shade400,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_rounded),
            label: 'Record',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
