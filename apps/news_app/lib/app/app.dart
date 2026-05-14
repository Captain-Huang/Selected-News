import 'package:flutter/material.dart';

import 'router.dart';

class SelectedNewsApp extends StatelessWidget {
  const SelectedNewsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Selected News',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1976D2)),
      ),
      routerConfig: appRouter,
    );
  }
}
