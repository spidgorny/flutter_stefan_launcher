import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:soundplayer/soundplayer.dart';

class SoundService {
  final Soundplayer soundPlayer = Soundplayer(16, 1);
  final ScrollController scrollController =
      ScrollController(); // Declare ScrollController
  late int soundId;
  double _previousScrollOffset = 0.0;

  void init(bool mounted) async {
    await loadTickSound();
    scrollController.addListener(onScroll); // Add the listener
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        initScrollPosition();
      }
    });
  }

  Future<void> loadTickSound() async {
    debugPrint('Sound player init...');
    soundPlayer.initSoundplayer(16);
    debugPrint('Sound player initialized');
    soundId = await soundPlayer.load("assets/click.wav");
    debugPrint('Sound loaded id=$soundId/**/');
  }

  void dispose() {
    scrollController.dispose(); // Dispose the controller
  }

  void onScroll() {
    // Get the current scroll offset
    double currentScrollOffset = scrollController.offset;

    // Check if the user is scrolling and if the scroll direction is bringing
    // new content into view.
    // We check if the list is not at the extreme ends to avoid triggering
    // the event when overscrolling.
    if (scrollController.position.userScrollDirection != ScrollDirection.idle &&
        !scrollController.position.atEdge) {
      var diff = (currentScrollOffset - _previousScrollOffset).abs();
      // debugPrint('diff: $diff');
      if (diff > 75) {
        debugPrint('play');
        soundPlayer.play(soundId);
        // Update the previous scroll offset for the next scroll event
        _previousScrollOffset = currentScrollOffset;
      }
    }
  }

  void initScrollPosition() {
    _previousScrollOffset = scrollController.offset;
  }
}
