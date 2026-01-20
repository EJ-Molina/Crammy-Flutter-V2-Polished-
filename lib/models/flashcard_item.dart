class FlashcardItem {
  final String question;
  final String answer;
  FlashcardItem({required this.question, required this.answer});

  factory FlashcardItem.fromJson(Map<String, dynamic> json) =>
      FlashcardItem(question: json['question'], answer: json['answer']);
}
