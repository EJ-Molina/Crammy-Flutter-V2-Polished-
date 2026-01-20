import 'package:crammy_app/models/quiz_item.dart';
import 'package:crammy_app/models/quiz_statistics.dart';
import 'flashcard_item.dart';
import 'mnemonics_item.dart';

class FileInfo {
  int? id;
  int? quizSetId;
  String origName;
  String? filepath;
  String? fileExtension;
  int? fileSize;
  String contentGenerated;
  String? summary;
  List<FlashcardItem>? flashcardsFromContent;
  List<MnemonicsItem>? mnemonicsFromContent;
  List<QuizItem>? quizzesFromContent;
  QuizStatistics? quizStatistics;
  DateTime? createdAt;

  FileInfo({
    this.id,
    this.quizSetId,
    required this.origName,
    this.filepath,
    this.fileExtension,
    this.fileSize,
    required this.contentGenerated,
    this.summary,
    this.flashcardsFromContent,
    this.mnemonicsFromContent,
    this.quizzesFromContent,
    this.quizStatistics,
    this.createdAt,
  }) {
    if (quizzesFromContent != null && quizStatistics == null) {
      quizStatistics = QuizStatistics();
    }
    if (createdAt == null) {
      createdAt = DateTime.now();
    }
  }
}
