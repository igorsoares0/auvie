import 'package:auvie/app/router/router.dart';
import 'package:auvie/app/theme/app_theme.dart';
import 'package:auvie/app/widgets/system_bars.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuvieApp extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Auvie',
      debugShowCheckedModeBanner: false,
      // Browsing screens are always paper; editor routes apply EditorTheme.
      theme: AuvieTheme.paper(),
      routerConfig: ref.watch(routerProvider),
      builder: (context, child) => SystemBars(child: child!),
    );
  }
}
