import 'package:flutter/material.dart';
import 'package:wyceny/features/common/screen_frame.dart';

class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({super.key, required this.title});
  @override
  Widget build(BuildContext context) => ScreenFrame(title: title);
}
