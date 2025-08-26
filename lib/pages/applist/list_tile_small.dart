import 'package:flutter/material.dart';

class ListTileSmall extends StatelessWidget {
  final Widget title;
  final Widget trailing;
  final GestureTapCallback onTap;
  final GestureLongPressCallback onLongPress;
  const ListTileSmall({
    super.key,
    required this.title,
    required this.trailing,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    bool isLongPressing = false;
    return StatefulBuilder(
      builder: (context, setState) => Material(
        color: Colors.transparent,
        child: InkWell(
          onTapDown: (TapDownDetails details) {
            setState(() => isLongPressing = true);
          },
          onTapUp: (TapUpDetails details) {
            setState(() => isLongPressing = false);
          },
          onTapCancel: () {
            setState(() => isLongPressing = false);
          },
          onTap: onTap,
          onLongPress: onLongPress,
          child: Container(
            decoration: BoxDecoration(
              color: isLongPressing ? Colors.grey.withOpacity(0.3) : null,
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 0, 16, 0),
                    child: trailing,
                  ),
                  Expanded(child: title),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
