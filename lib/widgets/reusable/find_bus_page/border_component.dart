import 'package:flutter/material.dart';

class BorderComponent extends StatelessWidget {
  final String name;
  final IconData iconName;

  const BorderComponent({
    super.key,
    required this.iconName,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 3.0),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Icon(iconName, size: 18),
          const SizedBox(width: 6),
          Text(
            name,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
