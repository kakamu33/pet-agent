import 'package:flutter/material.dart';

import '../features/pet/presentation/pet_home_page.dart';

class PetAgentApp extends StatelessWidget {
  const PetAgentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pet Agent',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6750A4)),
        useMaterial3: true,
      ),
      home: const PetHomePage(),
    );
  }
}

