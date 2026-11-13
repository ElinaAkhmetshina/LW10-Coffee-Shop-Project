import 'package:flutter/material.dart';

class CategoryBadge extends StatelessWidget {
  final String category;
  final bool large;

  const CategoryBadge({super.key, required this.category, this.large = false});

  @override
  Widget build(BuildContext context) {
    final label = category.isEmpty ? category : category[0].toUpperCase() + category.substring(1);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: large ? 12 : 8, vertical: large ? 4 : 2),
      decoration: BoxDecoration(
        color: Colors.brown[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.brown.shade200),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: large ? 13 : 11,
          color: Colors.brown[800],
          fontWeight: large ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }
}