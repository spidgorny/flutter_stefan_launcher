import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Wheel extends StatefulWidget {
  const Wheel({super.key});

  @override
  State<Wheel> createState() => _WheelState();
}

class _WheelState extends State<Wheel> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: AppBar(
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
      body: ListWheelScrollView(
        diameterRatio: 2,
        offAxisFraction: 0,
        useMagnifier: true,
        magnification: 1.5,
        itemExtent: 50,
        onSelectedItemChanged: (index) => {print(index)},

        children: List.generate(1000, (index) => index)
            .map(
              (text) => Container(
                margin: EdgeInsets.only(left: 20, right: 20),
                color:
                    Colors.primaries[Random().nextInt(Colors.primaries.length)],
                child: Center(child: Text(text.toString())),
              ),
            )
            .toList(),
      ),
    );
  }
}
