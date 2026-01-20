import 'package:flutter/material.dart';

class HeaderPart extends StatelessWidget {
  const HeaderPart({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
          icon: const Icon(Icons.menu, size: 32),
        ),
        Row(
          children: [
            Image.asset(
              'assets/images/crammy_logo.png',
              height: 49.6,
              width: 53.39,
            ),
            const SizedBox(width: 10),
            const Text(
              "Crammy",
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 24,
              ),
            ),
          ],
        ),
        const SizedBox(width: 38),
      ],
    );
  }
}
