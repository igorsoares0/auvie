import 'package:auvie/app/theme/app_theme.dart';
import 'package:flutter/material.dart';

class Wordmark extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return Text('AUVIE', style: context.type.wordmark);
  }
}
