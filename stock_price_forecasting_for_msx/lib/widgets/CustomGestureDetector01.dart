import 'package:flutter/material.dart';

class CustomGestureDetector01 extends StatelessWidget {
  final IconData iconName;
  final String name;
  final Color? color;
  final IconData? arrow;
  final VoidCallback onTap;

  const CustomGestureDetector01({
    Key? key,
    required this.iconName,
    required this.name,
    this.arrow,
    this.color,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
        margin: const EdgeInsets.fromLTRB(0, 4, 0, 4),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 6, 0),
              child: Icon(iconName, size: 23, color: color),
            ),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Color.fromARGB(255, 232, 238, 240),
                      width: 1.0,
                    ),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 2, 0, 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(name, style: TextStyle(color: color)),
                      if (arrow != null)
                      Icon(arrow, size: 23),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
