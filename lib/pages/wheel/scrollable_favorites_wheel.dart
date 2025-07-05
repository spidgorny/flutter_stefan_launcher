import 'package:appcheck/appcheck.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:watch_it/watch_it.dart';

import '../../data/data_repo.dart';
import '../../data/settings.dart';
import '../../main.dart';
import '../../service/sound_service.dart';

class ScrollableFavoritesWheel extends StatefulWidget
    with WatchItStatefulWidgetMixin {
  const ScrollableFavoritesWheel({super.key});

  @override
  State<ScrollableFavoritesWheel> createState() =>
      _ScrollableFavoritesWheelState();
}

class _ScrollableFavoritesWheelState extends State<ScrollableFavoritesWheel> {
  final appCheck = AppCheck();
  final FixedExtentScrollController _scrollController =
      FixedExtentScrollController();
  final SoundService soundService = getIt<SoundService>();

  // It's good practice to add the listener in initState and remove in dispose
  @override
  void initState() {
    super.initState();
    soundService.init(_scrollController);
    // This listener will call setState whenever the scroll position changes,
    // forcing the build method (and thus the ListWheelScrollView's delegate) to re-evaluate.
    _scrollController.addListener(() {
      if (mounted) {
        // Ensure the widget is still in the tree
        // setState(() {});
        soundService.onScroll(_scrollController);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = watch(di<Settings>());
    final dataRepo = watch(di<DataRepo>());
    var items = dataRepo.favorites;
    final itemExtent = 50.0;

    return AnimatedBuilder(
      animation: _scrollController,
      builder: (BuildContext context, Widget? child) {
        //         // This builder is called whenever _scrollController notifies listeners
        return ListWheelScrollView.useDelegate(
          controller: _scrollController,
          diameterRatio: 50.0,
          offAxisFraction: 0,
          // useMagnifier: true,
          // magnification: 1.0,
          itemExtent: itemExtent,
          // overAndUnderCenterOpacity: 0.5,
          physics: FixedExtentScrollPhysics(
            parent: BouncingScrollPhysics(
              decelerationRate: ScrollDecelerationRate.normal,
            ),
          ),
          // renderChildrenOutsideViewport: true,
          // onSelectedItemChanged: (index) => {print(index)},
          childDelegate: ListWheelChildBuilderDelegate(
            builder: (BuildContext context, int visualIndex) {
              // This builder is called by ListWheelScrollView
              // We will make the *content* of this builder reactive using AnimatedBuilder
              // or rely on a parent AnimatedBuilder to rebuild this whole delegate part.

              // For simplicity and common practice, let's wrap ListWheelScrollView
              // in AnimatedBuilder. So this builder will be called when scroll changes.

              final dataIndex = visualIndex % items.length;
              final itemData = items[dataIndex];

              double itemScale = 1.0;
              double itemOpacity = 1.0;
              // double itemAngle = 0.0; // Example for rotation
              double difference = 0.0;
              double scrollPixels = 0;
              double itemIndexInTheMiddle = 0.0;
              FontWeight fontWeight = FontWeight.normal;

              if (_scrollController.hasClients &&
                  _scrollController.position.haveDimensions) {
                scrollPixels = _scrollController.position.pixels;
                // double halfHeight =
                _scrollController.position.viewportDimension / 2;

                itemIndexInTheMiddle = scrollPixels / itemExtent;

                // Calculate difference from the exact center
                difference = (itemIndexInTheMiddle - visualIndex).abs();

                itemScale = (3 - difference / 3.5).clamp(1, 3.0);
                itemOpacity = (1 - difference / 5).clamp(0.0, 1.0);

                var fontWeightMap = [
                  FontWeight.w700,
                  FontWeight.w600,
                  FontWeight.w500,
                  FontWeight.w400,
                  FontWeight.w400,
                  FontWeight.w400,
                  FontWeight.w400,
                  FontWeight.w400,
                  FontWeight.w400,
                  FontWeight.w400,
                  FontWeight.w400,
                  FontWeight.w400,
                ];

                fontWeight =
                    fontWeightMap[(difference * 2).round() %
                        fontWeightMap.length];
                if (fontWeight == null) fontWeight = FontWeight.normal;

                // fontWeight =
                //     FontWeight.lerp(
                //       FontWeight.w100,
                //       FontWeight.w900,
                //       1 - difference / 5,
                //     ) ??
                //     FontWeight.normal;
              }

              return Container(
                // decoration: BoxDecoration(
                //   border: Border.all(
                //     color: Colors.white.withOpacity(0.1),
                //     width: 1,
                //   ),
                // ),
                child: Transform.scale(
                  scale: itemScale,
                  child: Opacity(
                    opacity: itemOpacity,
                    child: Container(
                      // This is the base item structure
                      alignment: Alignment.center,
                      // decoration: BoxDecoration(
                      //   // color: Colors
                      //   //     .primaries[visualIndex % Colors.primaries.length]
                      //   //     .shade100, // Dynamic color example
                      //   borderRadius: BorderRadius.circular(10.0),
                      //   border: Border.all(
                      //     // color: Colors
                      //     //     .primaries[visualIndex % Colors.primaries.length]
                      //     //     .shade300,
                      //     width: 1.0,
                      //   ),
                      // ),
                      child: GestureDetector(
                        onTap: () => _launchApp(context, itemData.app),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              // (${difference.toStringAsFixed(2)})
                              "${itemData.app.appName}  (${fontWeight.toString().substring(12, 15)})",
                              style: GoogleFonts.inter(
                                fontSize: 15.0,
                                fontWeight: fontWeight,
                                color: settings.isDarkMode
                                    ? Colors.white
                                    : Colors.black,
                                shadows: settings.isDarkMode
                                    ? <Shadow>[
                                        // Adding text shadow for better readability
                                        Shadow(
                                          offset: Offset(1.0, 1.0),
                                          blurRadius: 10.0,
                                          color: Color.fromARGB(150, 0, 0, 0),
                                        ),
                                      ]
                                    : [],
                              ),
                            ),
                            // Text(
                            //   "${difference.toStringAsFixed(2)} ${itemScale.toStringAsFixed(2)}x",
                            //   style: TextStyle(
                            //     fontSize: 8.0,
                            //     color: Colors.white30,
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
            childCount: settings.isInfinityScroll
                ? items.length * 100
                : items.length,
          ),
        );
      },
    );
  }

  Future<void> _launchApp(BuildContext context, AppInfo app) async {
    try {
      await appCheck.launchApp(app.packageName);
      debugPrint("${app.appName ?? app.packageName} launched!");
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${app.appName ?? app.packageName} not found!")),
      );
      debugPrint("Error launching app: $e");
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(() {
      if (mounted) setState(() {});
    }); // Clean up
    _scrollController.dispose();
    soundService.dispose(); // Dispose the controller
    super.dispose();
  }
}
