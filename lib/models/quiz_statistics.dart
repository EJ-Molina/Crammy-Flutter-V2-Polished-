class QuizStatistics {
  int timesAttempted;
  int perfectScores;
  int totalQuestionsAnswered;
  int totalCorrectAnswers;
  List<QuizAttempt> attempts;

  QuizStatistics({
    this.timesAttempted = 0,
    this.perfectScores = 0,
    this.totalQuestionsAnswered = 0,
    this.totalCorrectAnswers = 0,
    List<QuizAttempt>? attempts,
  }) : attempts = attempts ?? [];

  double get accuracy {
    if (totalQuestionsAnswered == 0) return 0.0;
    return (totalCorrectAnswers / totalQuestionsAnswered) * 100;
  }

  void addAttempt(int score, int totalQuestions) {
    timesAttempted++;
    totalQuestionsAnswered += totalQuestions;
    totalCorrectAnswers += score;

    if (score == totalQuestions) {
      perfectScores++;
    }

    attempts.add(QuizAttempt(
      score: score,
      totalQuestions: totalQuestions,
      date: DateTime.now(),
    ));
  }
}

class QuizAttempt {
  final int score;
  final int totalQuestions;
  final DateTime date;

  QuizAttempt({
    required this.score,
    required this.totalQuestions,
    required this.date,
  });

  double get percentage => (score / totalQuestions) * 100;
}
