import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'login.dart';
import 'track.dart';
import 'welcome.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  int _currentIndex = 0;

  // قائمة الشاشات التي نريد التنقل بينها
  final List<Widget> _screens = [
    WelcomeScreen(),
    TrackScreen(),
    LoginScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          body: _screens[_currentIndex],
          bottomNavigationBar: GNav(
              onTabChange: (value) => setState(() => _currentIndex = value),
              activeColor: Theme.of(context).colorScheme.tertiary,
              tabActiveBorder: Border.all(),
              color: Theme.of(context).colorScheme.secondary,
              duration: Duration(milliseconds: 500),
              tabs: const [
                GButton(icon: Icons.home, text: 'الرئيسية'),
                GButton(icon: Icons.track_changes_outlined, text: 'تتبع الشحنات'),
                GButton(icon: Icons.person, text: 'تسجيل الدخول'),
              ])
          ),
    );
  }
}
