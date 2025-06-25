import 'package:flutter/material.dart';

class BottomLauncher extends StatelessWidget {
  const BottomLauncher({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: 20, // The count of items in the grid
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, // The number of columns in the grid
      ),
      itemBuilder: (BuildContext context, int index) {
        // Create a GridTile for each item at the given index
        return GridTile(
          child: Image.network('https://example.com/image_$index.png'),
        );
      },
    );
  }
}
