import 'package:flutter/material.dart';

class CategoryFilter extends StatelessWidget {
  const CategoryFilter({
    required this.selectedCategory,
    required this.onChanged,
    super.key,
  });

  final String selectedCategory;
  final ValueChanged<String> onChanged;

  static const categories = [
    'historical',
    'religious',
    'adventure',
    'nature',
    'food',
    'family',
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SegmentedButton<String>(
        showSelectedIcon: false,
        segments: [
          for (final category in categories)
            ButtonSegment<String>(
              value: category,
              label: Text(category),
            ),
        ],
        selected: {selectedCategory},
        onSelectionChanged: (values) => onChanged(values.first),
      ),
    );
  }
}
