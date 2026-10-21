
import 'package:flutter/material.dart';

class RoomButton extends StatelessWidget {
  const RoomButton({
    super.key,
    required this.mapWidth, required this.width, required this.height, required this.name,
  });

  final double mapWidth;
   final double width;
   final  double height;
   final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        border: Border.all(color: Colors.cyanAccent, width: mapWidth * 0.005),
      //  borderRadius: BorderRadius.circular(mapWidth * 0.02),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: mapWidth * 0.01),
          child: Text(
            name,
            style: TextStyle(
              color: Colors.white,
              fontSize: mapWidth * 0.055,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
