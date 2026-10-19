
import 'package:flutter/material.dart';

class CustomIconSearchWidget extends StatelessWidget {
  const CustomIconSearchWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        //color: Colors.red.withAlpha(120),
        shape: BoxShape.circle,
        //  border: Border.all(color: Colors.white, width: 0),
      ),
      child: const Icon(Icons.search, color: Colors.white, size: 20),
    );
  }
}
