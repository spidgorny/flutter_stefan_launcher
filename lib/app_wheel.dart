import 'package:appcheck/appcheck.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stefan_launcher/sound_service.dart';
import 'package:go_router/go_router.dart';
import 'package:watch_it/watch_it.dart';

import 'bottom_buttons.dart';
import 'clock.dart';
import 'data_repo.dart';
import 'main.dart';

class Wheel extends StatefulWidget with WatchItStatefulWidgetMixin {
  const Wheel({super.key});

  @override
  State<Wheel> createState() => _WheelState();
}

class _WheelState extends State<Wheel> {
  final FixedExtentScrollController _scrollController =
      FixedExtentScrollController();

  final SoundService soundService = getIt<SoundService>();

  // It's good practice to add the listener in initState and remove in dispose
  @override
  void initState() {
    super.initState();
    soundService.init();
    // This listener will call setState whenever the scroll position changes,
    // forcing the build method (and thus the ListWheelScrollView's delegate) to re-evaluate.
    _scrollController.addListener(() {
      if (mounted) {
        // Ensure the widget is still in the tree
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final dataRepo = watch(di<DataRepo>());
    var items = dataRepo.favorites;
    final itemExtent = 75.0;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _scrollController,
            builder: (BuildContext context, Widget? child) {
              //         // This builder is called whenever _scrollController notifies listeners
              return ListWheelScrollView.useDelegate(
                controller: _scrollController,
                diameterRatio: 2.2,
                offAxisFraction: 0,
                // useMagnifier: true,
                // magnification: 1.0,
                itemExtent: itemExtent,
                // overAndUnderCenterOpacity: 0.5,
                physics: FixedExtentScrollPhysics(),
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

                    if (_scrollController.hasClients &&
                        _scrollController.position.haveDimensions) {
                      scrollPixels = _scrollController.position.pixels;
                      double halfHeight =
                          _scrollController.position.viewportDimension / 2;

                      itemIndexInTheMiddle = scrollPixels / itemExtent;

                      // Calculate difference from the exact center
                      difference = (itemIndexInTheMiddle - visualIndex).abs();

                      itemScale = (3 - difference / 3).clamp(0.5, 3.0);
                      itemOpacity = (1 - difference / 5).clamp(0.1, 1.0);
                    }

                    return Transform.scale(
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
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "${itemData.app.appName}",
                                style: TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.lerp(
                                    FontWeight.w100,
                                    FontWeight.w900,
                                    1 - difference / 2,
                                  ),
                                  color: Colors.white,
                                  shadows: <Shadow>[
                                    // Adding text shadow for better readability
                                    Shadow(
                                      offset: Offset(1.0, 1.0),
                                      blurRadius: 10.0,
                                      color: Color.fromARGB(150, 0, 0, 0),
                                    ),
                                  ],
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
                    );
                  },
                  childCount: items.length * 10,
                ),
              );
            },
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 0, 0.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LiveTimeWidget(),
                  IconButton(
                    icon: const Icon(Icons.settings),
                    onPressed: () {
                      GoRouter.of(context).push('/config');
                    },
                  ),

                  // FilledButton(
                  //   onPressed: () {
                  //     debugPrint("Fav len: ${dataRepo.favorites.length}");
                  //     dataRepo.loadFavorites();
                  //   },
                  //   child: Icon(Icons.settings),
                  // ),
                ],
              ),
            ),
          ),
        ],
      ),
      // children: List.generate(dataRepo.favorites.length, (index) => index)
      //     .map(
      //       (index) => Container(
      //         margin: EdgeInsets.only(left: 20, right: 20),
      //         color: Colors.transparent,
      //         child: Center(
      //           child: Text(
      //             dataRepo.favorites[index].app.appName ?? '',
      //             style: TextStyle(fontSize: 30, color: Colors.white),
      //           ),
      //         ),
      //       ),
      //     )
      //     .toList(),
      bottomNavigationBar: BottomButtons(appCheck: AppCheck()),
    );
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
