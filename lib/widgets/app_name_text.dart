import 'package:flutter/material.dart';

import 'package:shimmer/shimmer.dart';
import '/widgets/title_text.dart';

class AppNameTextWidget extends StatelessWidget {
  final double fontSize;

  const AppNameTextWidget({this.fontSize = 20, super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      period: const Duration(seconds: 10),
      baseColor: Colors.purple,
      highlightColor: Colors.red,
      child: TitlesTextWidget(
        label: "Shop Smart",
        fontSize: fontSize,
      ),
    );
  }
}
