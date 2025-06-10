import 'package:ami_invisible_admin/core/config/app_theme.dart';
import 'package:ami_invisible_admin/providers/auth_provider.dart';
import 'package:ami_invisible_admin/views/home.dart';
import 'package:ami_invisible_admin/views/message_screen.dart';
import 'package:ami_invisible_admin/views/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LayoutScreen extends StatefulWidget {

  const LayoutScreen({super.key});
  @override
  LayoutScreenState createState() => LayoutScreenState ();
}

class LayoutScreenState extends State<LayoutScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    Home(),
    MessageScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Consumer<AuthProvider>(
          builder: (context, provider, _) {
            return _pages[provider.selectedIndex];
          },
        ),
        bottomNavigationBar: Builder(
          builder: (context) {
            return Consumer<AuthProvider>(
              builder: (context, provider, _) {
                return BottomNavigationBar(
                  currentIndex: provider.selectedIndex,
                  onTap: provider.changeTab,
                  type: BottomNavigationBarType.fixed,
                  backgroundColor: const Color(0xFFC4C4C4),
                  selectedItemColor: Colors.transparent,
                  unselectedItemColor: Colors.grey,
                  items: [
                    _buildNavItem(context, Icons.local_fire_department, 'Découvrir', 0),
                    _buildNavItem(context, Icons.message, 'Messages', 1),
                    _buildNavItem(context, Icons.person, 'Profil', 2),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

    BottomNavigationBarItem _buildNavItem(BuildContext context,
      IconData icon, String label, int index) {
    final bool isSelected = Provider.of<AuthProvider>(context,listen: true).selectedIndex == index;
    final int unreadCount =0;

    Widget iconWidget;

    if (index == 2) {
      iconWidget = Stack(
        clipBehavior: Clip.none,
        children: [
          isSelected
          ? ShaderMask(
              shaderCallback: (bounds) =>
                  AppTheme.primaryGradient.createShader(bounds),
              child: Icon(icon, color: Colors.white),
            )
          : Icon(icon),
          if (unreadCount > 0)
            Positioned(
              right: -6,
              top: -3,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                constraints: const BoxConstraints(
                  minWidth: 16,
                  minHeight: 16,
                ),
                child: Text(
                  unreadCount > 99 ? '99+' : unreadCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      );
    } else {
      // Autres onglets: gradient seulement si sélectionné
      iconWidget = isSelected
          ? ShaderMask(
              shaderCallback: (bounds) =>
                  AppTheme.primaryGradient.createShader(bounds),
              child: Icon(icon, color: Colors.white),
            )
          : Icon(icon);
    }

    return BottomNavigationBarItem(
      icon: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          iconWidget,
          const SizedBox(height: 4),
          isSelected
              ? ShaderMask(
                  shaderCallback: (bounds) =>
                      AppTheme.primaryGradient.createShader(bounds),
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              : Text(
                  label,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
        ],
      ),
      label: '', // on désactive le label automatique
    );
  }


  }
