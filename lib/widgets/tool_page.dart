import 'package:flutter/material.dart';

class ToolPage extends StatelessWidget {
  final String title;
  final String description;
  final Widget child;

  const ToolPage({
    super.key,
    required this.title,
    required this.description,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 6),
        Text(
          description,
          style: TextStyle(color: Colors.grey.shade400, height: 1.45),
        ),
        const SizedBox(height: 18),
        child,
      ],
    );
  }
}
