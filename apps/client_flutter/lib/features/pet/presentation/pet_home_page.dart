import 'package:flutter/material.dart';

import '../domain/pet_state.dart';

class PetHomePage extends StatefulWidget {
  const PetHomePage({super.key});

  @override
  State<PetHomePage> createState() => _PetHomePageState();
}

class _PetHomePageState extends State<PetHomePage> {
  PetState _state = const PetState(
    mood: PetMood.encouraging,
    activity: PetActivity.waitingForTask,
    message: '今天的学习任务准备好啦。',
    level: 1,
    experience: 0,
    hasPendingTask: true,
  );

  void _startStudy() {
    setState(() {
      _state = PetState(
        mood: PetMood.encouraging,
        activity: PetActivity.studying,
        message: '先从 5 分钟开始，我陪着你。',
        level: _state.level,
        experience: _state.experience,
        hasPendingTask: _state.hasPendingTask,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircleAvatar(radius: 48, child: Icon(Icons.pets, size: 52)),
                const SizedBox(height: 16),
                Text(_state.message, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text('等级 ${_state.level} · 经验 ${_state.experience}'),
                const SizedBox(height: 16),
                FilledButton(onPressed: _startStudy, child: const Text('开始 5 分钟学习')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

