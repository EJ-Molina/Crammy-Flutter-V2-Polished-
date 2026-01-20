class MnemonicsItem {
  final String mnemonics;
  final String explanation;

  MnemonicsItem({required this.mnemonics, required this.explanation});

  factory MnemonicsItem.fromJson(Map<String, dynamic> json) =>  MnemonicsItem(
    mnemonics: json["Mnemonics"],
    explanation: json['Explanation'],
  );
}
