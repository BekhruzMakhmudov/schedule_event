import 'package:flutter/material.dart';

class ColorMapper {
  static String colorToString(Color color) {
    if (color == Colors.blue) return 'blue';
    if (color == Colors.red) return 'red';
    if (color == Colors.orange) return 'orange';
    return 'blue';
  }

  static Color stringToColor(String name) {
    switch (name) {
      case 'blue':
        return Colors.blue;
      case 'red':
        return Colors.red;
      case 'orange':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }
}
