import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'history_screen.dart';
import 'quick_complaint_screen.dart';
import 'notification_screen.dart';
import 'settings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final GlobalKey _homeKey = GlobalKey();
  
  void _changeTab(int index) {
    setState(() {
      _currentIndex = index;
    });

    // When switching to Home tab, refresh the profile data
    if (index == 0) {
      final state = _homeKey.currentState;
      try {
        (state as dynamic)?.refreshProfile();
      } catch (_) {}
    }
  }
  
  List<Widget> get _screens => [
    HomeScreen(key: _homeKey, onTabChange: _changeTab),
    const HistoryScreen(),
    const QuickComplaintScreen(),
    const NotificationScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 32,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SizedBox(
              height: 68,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Left side menus
                  Row(
                    children: [
                      _buildNavItem(
                        icon: Icons.home_rounded,
                        label: 'Home',
                        index: 0,
                      ),
                      const SizedBox(width: 24),
                      _buildNavItem(
                        icon: Icons.history_rounded,
                        label: 'Riwayat',
                        index: 1,
                      ),
                    ],
                  ),
                  
                  // Center special button
                  _buildNavItem(
                    icon: Icons.add_circle_outline_rounded,
                    label: 'Aduan',
                    index: 2,
                    isSpecial: true,
                  ),
                  
                  // Right side menus
                  Row(
                    children: [
                      _buildNavItem(
                        icon: Icons.notifications_rounded,
                        label: 'Notifikasi',
                        index: 3,
                      ),
                      const SizedBox(width: 24),
                      _buildNavItem(
                        icon: Icons.person_rounded,
                        label: 'Profil',
                        index: 4,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    bool isSpecial = false,
  }) {
    final isSelected = _currentIndex == index;
    
    if (isSpecial) {
      // Modern floating action button style
      return GestureDetector(
        onTap: () => _changeTab(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutBack,
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFFff5001),
                const Color(0xFFe64100),
              ],
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFff5001).withOpacity(0.3),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(height: 1),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
    
    // Modern minimalist nav items
    return GestureDetector(
      onTap: () => _changeTab(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 40,
              height: 28,
              decoration: BoxDecoration(
                color: isSelected 
                    ? const Color(0xFFff5001).withOpacity(0.15)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: AnimatedScale(
                  scale: isSelected ? 1.1 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    icon,
                    color: isSelected 
                        ? const Color(0xFFff5001)
                        : Colors.grey[500],
                    size: 22,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 2),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected 
                    ? const Color(0xFFff5001)
                    : Colors.grey[500],
              ),
              child: Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
