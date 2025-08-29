import 'package:appcheck/appcheck.dart';
import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../data/data_repo.dart';
import '../../data/settings.dart';
import '../../main.dart';
import '../../services/sound_service.dart';
import 'wheel_item.dart'; // Added import for the new file

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
  final itemExtent = 50.0;
  final SoundService soundService = getIt<SoundService>();

  // It's good practice to add the listener in initState and remove in dispose
  @override
  void initState() {
    super.initState();
    soundService.init(_scrollController, itemExtent);
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
                //
                // var fontWeightMap = [
                //   FontWeight.w700,
                //   FontWeight.w600,
                //   FontWeight.w500,
                //   FontWeight.w400,
                //   FontWeight.w400,
                //   FontWeight.w400,
                //   FontWeight.w400,
                //   FontWeight.w400,
                //   FontWeight.w400,
                //   FontWeight.w400,
                //   FontWeight.w400,
                //   FontWeight.w400,
                // ];
                //
                // fontWeight =
                //     fontWeightMap[(difference * 2).round() %
                //         fontWeightMap.length];

                fontWeight =
                    FontWeight.lerp(
                      FontWeight.w100,
                      FontWeight.w900,
                      1 - difference / 5,
                    ) ??
                    FontWeight.normal;
              }

              return Stack(
                alignment: Alignment.center,
                fit: StackFit.expand,
                children: [
                  Container(
                    // decoration: BoxDecoration(
                    //   border: Border.all(
                    //     color: Colors.blue.withOpacity(0.5),
                    //     width: 1,
                    //   ),
                    // ),
                    child: Transform.scale(
                      // scale: 1,
                      scale: itemScale,
                      child: Opacity(
                        opacity: itemOpacity,
                        child: WheelItem(
                          itemData: itemData,
                          fontWeight: fontWeight,
                        ),
                      ),
                    ),
                  ),

                  Container(
                    width: 30,
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.only(right: 8),
                    child: Container(
                      // This is the base item structure
                      width: 1 + itemScale * 10,
                      height: 5 * itemScale / 1.5,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(
                          itemOpacity,
                        ), // Dynamic color example
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        // borderRadius: BorderRadius.only(
                        //   topLeft: Radius.circular(10.0),
                        //   bottomLeft: Radius.circular(10.0),
                        // ),
                      ),
                    ),
                  ),
                ],
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
