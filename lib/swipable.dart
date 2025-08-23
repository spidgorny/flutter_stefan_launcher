import 'package:DETOXD/pages/applist/all_apps_launcher.dart';
import 'package:DETOXD/pages/settings/settings_page.dart';
import 'package:DETOXD/pages/wheel/app_wheel.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SwipeableScaffold extends StatefulWidget {
  const SwipeableScaffold({super.key});

  @override
  State<SwipeableScaffold> createState() => _SwipeableScaffoldState();

  static _SwipeableScaffoldState? of(BuildContext context) {
    return context.findAncestorStateOfType<_SwipeableScaffoldState>();
  }
}

class _SwipeableScaffoldState extends State<SwipeableScaffold> {
  void _handlePageOneReached() {
    // Add any specific handling when page 1 is reached
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }

  final PageController _pageController = PageController(initialPage: 1);
  int _currentPageIndex = 1;

  // Your different widgets to display
  final List<Widget> _pages = [
    SettingsPage(),
    Wheel(),
    // AppList(),
    AllAppsLauncher(),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  scrollBackToCenter() {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    _pageController.animateToPage(
      1,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_currentPageIndex != 1) {
          scrollBackToCenter();
          return false; // Prevent default back button behavior
        }
        return true; // Allow default back button behavior (exit app)
      },
      child: Scaffold(
        body: PageView(
          controller: _pageController,
          children: _pages,
          onPageChanged: (int index) {
            setState(() {
              _currentPageIndex = index;
            });
            if (index == 1) {
              _handlePageOneReached();
            }
          },
          physics: const BouncingScrollPhysics(),
          dragStartBehavior: DragStartBehavior.start,
        ),
      ),
    );
  }
}
