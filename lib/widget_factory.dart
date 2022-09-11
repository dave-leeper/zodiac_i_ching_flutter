import 'package:flutter/material.dart';

ButtonStyleButton buildElevatedButton(String label, VoidCallback onPressed, [Key? key, ButtonStyle? style, VoidCallback? onLongPress, ValueChanged<bool>? onHover, ValueChanged<bool>? onFocusChange]) {
  var newButton = ElevatedButton(onPressed: onPressed, onLongPress: onLongPress, onHover: onHover, onFocusChange: onFocusChange, key: key, style: style, child: Text(label));
  return newButton;
}

Text buildText(String text, TextStyle? textStyle, [TextAlign? textAlign = TextAlign.left]) {
  var newText = Text(text, textAlign: textAlign, style: textStyle);
  return newText;
}
