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
  
  void _changeTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
  
  List<Widget> get _screens => [
    HomeScreen(onTabChange: _changeTab),
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
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  icon: Icons.home_rounded,
                  label: 'Home',
                  index: 0,
                ),
                _buildNavItem(
                  icon: Icons.history_rounded,
                  label: 'Riwayat',
                  index: 1,
                ),
                _buildNavItem(
                  icon: Icons.camera_alt_rounded,
                  label: 'Aduan Cepat',
                  index: 2,
                  isSpecial: true, // Make this button special
                ),
                _buildNavItem(
                  icon: Icons.notifications_rounded,
                  label: 'Notifikasi',
                  index: 3,
                ),
                _buildNavItem(
                  icon: Icons.settings_rounded,
                  label: 'Pengaturan',
                  index: 4,
                ),
              ],
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
    
    return GestureDetector(
      onTap: () => _changeTab(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSpecial 
              ? (isSelected ? const Color(0xFF667eea) : const Color(0xFF667eea).withOpacity(0.8))
              : (isSelected ? const Color(0xFF667eea).withOpacity(0.1) : Colors.transparent),
          borderRadius: BorderRadius.circular(isSpecial ? 16 : 12),
          boxShadow: isSpecial ? [
            BoxShadow(
              color: const Color(0xFF667eea).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ] : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(4),
              child: Icon(
                icon,
                color: isSpecial 
                    ? Colors.white
                    : (isSelected ? const Color(0xFF667eea) : Colors.grey[600]),
                size: isSpecial ? 28 : 24,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: isSpecial ? 11 : 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSpecial 
                    ? Colors.white
                    : (isSelected ? const Color(0xFF667eea) : Colors.grey[600]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}