import 'package:flutter/material.dart';

class IconText extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? color;
  final double iconSize;
  final double fontSize;
  final FontWeight? fontWeight;
  final int? maxLines;
  final TextOverflow overflow;
  final bool expandText;
  final EdgeInsetsGeometry spacing;

  const IconText({
    super.key,
    required this.icon,
    required this.text,
    this.color,
    this.iconSize = 16,
    this.fontSize = 12,
    this.fontWeight,
    this.maxLines,
    this.overflow = TextOverflow.ellipsis,
    this.expandText = false,
    this.spacing = const EdgeInsets.only(left: 8),
  });

  @override
  Widget build(BuildContext context) {
    final iconWidget = Icon(icon, size: iconSize, color: color);
    final textWidget = Text(
      text,
      maxLines: maxLines,
      overflow: overflow,
      style: TextStyle(
        color: color,
        fontSize: fontSize,
        fontWeight: fontWeight,
      ),
    );

    // If expandText is true, wrap only the text with Expanded, not the whole row.
    final double gap = (spacing is EdgeInsets)
        ? (spacing as EdgeInsets).left
        : 8;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        iconWidget,
        SizedBox(width: gap),
        if (expandText) Expanded(child: textWidget) else textWidget,
      ],
    );
  }
}
