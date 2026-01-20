class QuizItem {
  String type;
  String question;
  final List<String>? choices;
  final String? answer;

  QuizItem({
    required this.type,
    required this.question,
    this.choices,
    this.answer,
  });

  factory QuizItem.fromJson(Map<String, dynamic> json) {
    switch (json['type']) {
      case 'MC':
        return QuizItem(
          type: 'MC',
          question: json['question'],
          choices: List<String>.from(json['choices']),
          answer: json['answer'],
        );
      case 'TF':
        return QuizItem(
          type: 'TF',
          question: json['question'],
          answer: json['answer'],
        );
      case 'ID':
        return QuizItem(
          type: 'ID',
          question: json['question'],
          answer: json['answer'],
        );
      default:
        throw Exception('Unknown quiz type');
    }
  }
}
