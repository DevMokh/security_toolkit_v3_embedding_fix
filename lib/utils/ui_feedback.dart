import 'package:flutter/material.dart';

void showMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

Widget sectionCard({required Widget child, EdgeInsets padding = const EdgeInsets.all(14)}) {
  return Card(
    child: Padding(
      padding: padding,
      child: child,
    ),
  );
}
