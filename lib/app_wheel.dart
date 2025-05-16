import 'dart:math' as Math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:watch_it/watch_it.dart';

import 'data_repo.dart';

class Wheel extends StatefulWidget with WatchItStatefulWidgetMixin {
  const Wheel({super.key});

  @override
  State<Wheel> createState() => _WheelState();
}

class _WheelState extends State<Wheel> {
  final FixedExtentScrollController _scrollController =
      FixedExtentScrollController();

  // It's good practice to add the listener in initState and remove in dispose
  @override
  void initState() {
    super.initState();
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
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: AppBar(
          // backgroundColor: Colors.transparent,
          automaticallyImplyLeading: true,
          surfaceTintColor: Colors.white30,
          // backgroundColor: Colors.amber,
          foregroundColor: Colors.blueAccent,
          actions: [
            IconButton(
              icon: const Icon(
                Icons.settings,
              ), // Replace with your desired icon
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
      body: AnimatedBuilder(
        animation: _scrollController,
        builder: (BuildContext context, Widget? child) {
          //         // This builder is called whenever _scrollController notifies listeners
          return ListWheelScrollView.useDelegate(
            controller: _scrollController,
            // diameterRatio: 1.2,
            offAxisFraction: 0,
            // useMagnifier: true,
            // magnification: 1.0,
            itemExtent: 50,
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

                if (_scrollController.hasClients &&
                    _scrollController.position.haveDimensions) {
                  scrollPixels = _scrollController.position.pixels;
                  double halfHeight =
                      _scrollController.position.viewportDimension / 2;

                  // Calculate difference from the exact center
                  difference = (halfHeight - scrollPixels).abs();

                  itemScale = (difference * visualIndex).clamp(0.0, 2.0);
                  itemOpacity = Math.max(
                    0.3,
                    1.0 - difference * 0.3,
                  ).clamp(0.0, 1.0);
                  // itemAngle = (normalizedCurrentItem - normalizedSelectedItem) * 0.1; // Small rotation
                }

                return Transform.scale(
                  scale: itemScale,
                  child: Opacity(
                    opacity: itemOpacity,
                    child: Container(
                      // This is the base item structure
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors
                            .primaries[visualIndex % Colors.primaries.length]
                            .shade100, // Dynamic color example
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(
                          color: Colors
                              .primaries[visualIndex % Colors.primaries.length]
                              .shade300,
                          width: 1.0,
                        ),
                      ),
                      child: Text(
                        "${scrollPixels.toStringAsFixed(2)} ${difference.toStringAsFixed(2)} ${itemData.app.appName}",
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
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
    );
  }

  @override
  void dispose() {
    _scrollController.removeListener(() {
      if (mounted) setState(() {});
    }); // Clean up
    _scrollController.dispose();
    super.dispose();
  }
}
