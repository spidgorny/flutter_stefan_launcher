import 'package:DETOXD/pages/settings/settings_page.dart';
import 'package:DETOXD/pages/wheel/app_wheel.dart';
import 'package:flutter/material.dart';

class SwipeableScaffold extends StatefulWidget {
  const SwipeableScaffold({super.key});

  @override
  State<SwipeableScaffold> createState() => _SwipeableScaffoldState();
}

class _SwipeableScaffoldState extends State<SwipeableScaffold> {
  final PageController _pageController = PageController(initialPage: 1);
  // int _currentPageIndex = 1;

  // Your different widgets to display
  final List<Widget> _pages = [
    WidgetsPage(),
    Wheel(),
    // AppList(),
    SettingsPage(),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('Page ${_currentPageIndex + 1}'),
      //   actions: [
      //     IconButton(
      //       icon: const Icon(Icons.arrow_left),
      //       onPressed: _currentPageIndex > 0
      //           ? () {
      //               _pageController.previousPage(
      //                 duration: const Duration(milliseconds: 300),
      //                 curve: Curves.easeInOut,
      //               );
      //             }
      //           : null,
      //     ),
      //     IconButton(
      //       icon: const Icon(Icons.arrow_right),
      //       onPressed: _currentPageIndex < _pages.length - 1
      //           ? () {
      //               _pageController.nextPage(
      //                 duration: const Duration(milliseconds: 300),
      //                 curve: Curves.easeInOut,
      //               );
      //             }
      //           : null,
      //     ),
      //   ],
      // ),
      body: PageView(
        controller: _pageController,
        children: _pages,
        onPageChanged: (int index) {
          setState(() {
            // _currentPageIndex = index;
          });
        },
        // physics: const BouncingScrollPhysics(), // Optional: customize scroll physics
      ),
      // bottomNavigationBar: BottomNavigationBar(
      //   currentIndex: _currentPageIndex,
      //   onTap: (int index) {
      //     _pageController.animateToPage(
      //       index,
      //       duration: const Duration(milliseconds: 300),
      //       curve: Curves.easeInOut,
      //     );
      //   },
      //   items: const [
      //     BottomNavigationBarItem(icon: Icon(Icons.looks_one), label: 'Page 1'),
      //     BottomNavigationBarItem(icon: Icon(Icons.looks_two), label: 'Page 2'),
      //     BottomNavigationBarItem(icon: Icon(Icons.looks_3), label: 'Page 3'),
      //   ],
      // ),
    );
  }
}

class WidgetsPage extends StatelessWidget {
  const WidgetsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: const Image(
        image: AssetImage('assets/widgets-blur.png'),
        fit: BoxFit.cover,
        height: double.infinity,
        width: double.infinity,
        alignment: Alignment.center,
      ),
    );
  }
}
