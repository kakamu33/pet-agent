import 'package:flutter/material.dart';

import '../features/pet/presentation/pet_home_page.dart';

class PetAgentApp extends StatelessWidget {
  const PetAgentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '猫咪桌宠',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFD49B63)),
        useMaterial3: true,
      ),
      home: const PetHomePage(),
    );
  }
}

