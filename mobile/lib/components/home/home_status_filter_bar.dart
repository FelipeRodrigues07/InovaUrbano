import 'package:flutter/material.dart';

/// Horizontal status chips for suggestion filters (Home dashboard).
class HomeStatusFilterBar extends StatelessWidget {
  const HomeStatusFilterBar({
    super.key,
    required this.items,
    required this.selected,
    required this.onSelected,
  });

  final List<String> items;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 35,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        itemBuilder: (context, index) {
          final label = items[index];
          final isActive = selected == label;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ElevatedButton(
              onPressed: () => onSelected(label),
              style: ElevatedButton.styleFrom(
                backgroundColor: isActive
                    ? const Color.fromARGB(255, 199, 195, 195)
                    : Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: const BorderSide(color: Colors.black),
                ),
                elevation: 0,
                foregroundColor: Colors.black,
                splashFactory: InkSplash.splashFactory,
              ),
              child: Text(
                label,
                style: const TextStyle(color: Colors.black),
              ),
            ),
          );
        },
      ),
    );
  }
}
