import 'package:auvie/app/widgets/pending_screen.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return const PendingScreen(title: 'Settings', milestone: 'M9');
  }
}
