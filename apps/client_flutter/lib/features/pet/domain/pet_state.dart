enum PetMood { idle, encouraging, thinking, celebrating, resting }

enum PetActivity { waitingForTask, studying, resting, celebrating }

class PetState {
  const PetState({
    required this.mood,
    required this.activity,
    required this.message,
    required this.level,
    required this.experience,
    required this.hasPendingTask,
  });

  final PetMood mood;
  final PetActivity activity;
  final String message;
  final int level;
  final int experience;
  final bool hasPendingTask;
}

