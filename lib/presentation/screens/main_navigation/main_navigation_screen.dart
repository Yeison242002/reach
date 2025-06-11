import 'package:flutter/material.dart';
import 'package:reach/presentation/screens/home/home_screen.dart';
import 'package:reach/presentation/screens/timer/timer_screen.dart';
import 'package:reach/presentation/screens/dashboard/dashboard_screen.dart';
import 'package:reach/presentation/screens/info/info_screen.dart';
import 'package:reach/presentation/screens/consumption_history/consumption_history_screen.dart';



class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    TimerScreen(),
    DashboardScreen(),
    //ConsumptionHistoryScreen(),
    InfoScreen(),


  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF1F1B2E),
        selectedItemColor: const Color.fromARGB(255, 178, 51, 153),
        unselectedItemColor: const Color.fromARGB(255, 182, 162, 162),
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.access_alarm), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.info), label: ''),
          
        ],
      ),
    );
  }
}
