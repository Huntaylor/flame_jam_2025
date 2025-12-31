import 'package:flutter/material.dart';

class UpgradeButton extends StatelessWidget {
  const UpgradeButton(
      {super.key,
      required this.upgradeName,
      required this.upgradeCost,
      required this.onUpgradePressed});
  final String upgradeName;
  final int upgradeCost;
  final VoidCallback onUpgradePressed;

  @override
  Widget build(BuildContext context) {
    const whiteTextColor = Color.fromRGBO(255, 255, 255, 1.0);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          upgradeName,
          style: TextStyle(
            color: whiteTextColor,
            fontSize: 12,
          ),
        ),
        const SizedBox(
          height: 40,
        ),
        TextButton(
          onPressed: onUpgradePressed,
          child: Text(
            '-$upgradeCost Points-',
            style: TextStyle(fontSize: 12),
          ),
        ),
      ],
    );
  }
}
