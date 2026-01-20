import 'package:crammy_app/models/file_data.dart';
import 'package:crammy_app/models/flashcard_item.dart';
import 'package:crammy_app/models/mnemonics_item.dart';
import 'package:crammy_app/models/quiz_item.dart';
import 'package:crammy_app/models/quiz_statistics.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class CrammyDbHelper {
  static const String dbName = 'crammy.db';
  static const int dbVersion = 2;

  static const String filesTB = 'files';
  static const String filesColId = 'id';
  static const String filesColOrigName = 'origName';
  static const String filesColFilepath = 'filepath';
  static const String filesColFileExtension = 'fileExtension';
  static const String filesColFileSize = 'fileSize';
  static const String filesColContentGenerated = 'contentGenerated';
  static const String filesColSummary = 'summary';
  static const String filesColCreatedAt = 'createdAt';

  static const String flashcardsTB = 'flashcard_items';
  static const String flashcardsColId = 'id';
  static const String flashcardsColFileId = 'fileId';
  static const String flashcardsColQuestion = 'question';
  static const String flashcardsColAnswer = 'answer';

  static const String mnemonicsTB = 'mnemonic_items';
  static const String mnemonicsColId = 'id';
  static const String mnemonicsColFileId = 'fileId';
  static const String mnemonicsColMnemonics = 'mnemonics';
  static const String mnemonicsColExplanation = 'explanation';

  static const String quizSetsTB = 'quiz_sets';
  static const String quizSetsColId = 'id';
  static const String quizSetsColFileId = 'fileId';
  static const String quizSetsColCreatedAt = 'createdAt';

  static const String quizItemsTB = 'quiz_items';
  static const String quizItemsColId = 'id';
  static const String quizItemsColQuizSetId = 'quizSetId';
  static const String quizItemsColType = 'type';
  static const String quizItemsColQuestion = 'question';
  static const String quizItemsColChoices = 'choices';
  static const String quizItemsColAnswer = 'answer';

  static const String quizStatsTB = 'quiz_statistics';
  static const String quizStatsColId = 'id';
  static const String quizStatsColQuizSetId = 'quizSetId';
  static const String quizStatsColTimesAttempted = 'timesAttempted';
  static const String quizStatsColPerfectScores = 'perfectScores';
  static const String quizStatsColTotalQuestionsAnswered =
      'totalQuestionsAnswered';
  static const String quizStatsColTotalCorrectAnswers = 'totalCorrectAnswers';

  static const String quizAttemptsTB = 'quiz_attempts';
  static const String quizAttemptsColId = 'id';
  static const String quizAttemptsColQuizSetId = 'quizSetId';
  static const String quizAttemptsColScore = 'score';
  static const String quizAttemptsColTotalQuestions = 'totalQuestions';
  static const String quizAttemptsColDate = 'date';

  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await openDb();
    return _database!;
  }

  static Future<Database> openDb() async {
    var path = join(await getDatabasesPath(), dbName);

    var createFilesSql = '''CREATE TABLE IF NOT EXISTS $filesTB (
      $filesColId INTEGER PRIMARY KEY AUTOINCREMENT,
      $filesColOrigName TEXT NOT NULL,
      $filesColFilepath TEXT,
      $filesColFileExtension TEXT,
      $filesColFileSize INTEGER,
      $filesColContentGenerated TEXT NOT NULL,
      $filesColSummary TEXT,
      $filesColCreatedAt INTEGER NOT NULL
    )''';

    var createFlashcardsSql = '''CREATE TABLE IF NOT EXISTS $flashcardsTB (
      $flashcardsColId INTEGER PRIMARY KEY AUTOINCREMENT,
      $flashcardsColFileId INTEGER NOT NULL,
      $flashcardsColQuestion TEXT NOT NULL,
      $flashcardsColAnswer TEXT NOT NULL,
      FOREIGN KEY ($flashcardsColFileId) REFERENCES $filesTB($filesColId) ON DELETE CASCADE
    )''';

    var createMnemonicsSql = '''CREATE TABLE IF NOT EXISTS $mnemonicsTB (
      $mnemonicsColId INTEGER PRIMARY KEY AUTOINCREMENT,
      $mnemonicsColFileId INTEGER NOT NULL,
      $mnemonicsColMnemonics TEXT NOT NULL,
      $mnemonicsColExplanation TEXT NOT NULL,
      FOREIGN KEY ($mnemonicsColFileId) REFERENCES $filesTB($filesColId) ON DELETE CASCADE
    )''';

    var createQuizSetsSql = '''CREATE TABLE IF NOT EXISTS $quizSetsTB (
      $quizSetsColId INTEGER PRIMARY KEY AUTOINCREMENT,
      $quizSetsColFileId INTEGER NOT NULL,
      $quizSetsColCreatedAt INTEGER NOT NULL,
      FOREIGN KEY ($quizSetsColFileId) REFERENCES $filesTB($filesColId) ON DELETE CASCADE
    )''';

    var createQuizItemsSql = '''CREATE TABLE IF NOT EXISTS $quizItemsTB (
      $quizItemsColId INTEGER PRIMARY KEY AUTOINCREMENT,
      $quizItemsColQuizSetId INTEGER NOT NULL,
      $quizItemsColType TEXT NOT NULL,
      $quizItemsColQuestion TEXT NOT NULL,
      $quizItemsColChoices TEXT,
      $quizItemsColAnswer TEXT,
      FOREIGN KEY ($quizItemsColQuizSetId) REFERENCES $quizSetsTB($quizSetsColId) ON DELETE CASCADE
    )''';

    var createQuizStatsSql = '''CREATE TABLE IF NOT EXISTS $quizStatsTB (
      $quizStatsColId INTEGER PRIMARY KEY AUTOINCREMENT,
      $quizStatsColQuizSetId INTEGER NOT NULL,
      $quizStatsColTimesAttempted INTEGER DEFAULT 0,
      $quizStatsColPerfectScores INTEGER DEFAULT 0,
      $quizStatsColTotalQuestionsAnswered INTEGER DEFAULT 0,
      $quizStatsColTotalCorrectAnswers INTEGER DEFAULT 0,
      FOREIGN KEY ($quizStatsColQuizSetId) REFERENCES $quizSetsTB($quizSetsColId) ON DELETE CASCADE
    )''';

    var createQuizAttemptsSql = '''CREATE TABLE IF NOT EXISTS $quizAttemptsTB (
      $quizAttemptsColId INTEGER PRIMARY KEY AUTOINCREMENT,
      $quizAttemptsColQuizSetId INTEGER NOT NULL,
      $quizAttemptsColScore INTEGER NOT NULL,
      $quizAttemptsColTotalQuestions INTEGER NOT NULL,
      $quizAttemptsColDate INTEGER NOT NULL,
      FOREIGN KEY ($quizAttemptsColQuizSetId) REFERENCES $quizSetsTB($quizSetsColId) ON DELETE CASCADE
    )''';

    var db = await openDatabase(
      path,
      version: dbVersion,
      onCreate: (db, version) async {
        await db.execute(createFilesSql);
        await db.execute(createFlashcardsSql);
        await db.execute(createMnemonicsSql);
        await db.execute(createQuizSetsSql);
        await db.execute(createQuizItemsSql);
        await db.execute(createQuizStatsSql);
        await db.execute(createQuizAttemptsSql);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (newVersion <= oldVersion) return;
        await db.execute('DROP TABLE IF EXISTS $quizAttemptsTB');
        await db.execute('DROP TABLE IF EXISTS $quizStatsTB');
        await db.execute('DROP TABLE IF EXISTS $quizItemsTB');
        await db.execute('DROP TABLE IF EXISTS $quizSetsTB');
        await db.execute('DROP TABLE IF EXISTS $mnemonicsTB');
        await db.execute('DROP TABLE IF EXISTS $flashcardsTB');
        await db.execute('DROP TABLE IF EXISTS $filesTB');
        await db.execute(createFilesSql);
        await db.execute(createFlashcardsSql);
        await db.execute(createMnemonicsSql);
        await db.execute(createQuizSetsSql);
        await db.execute(createQuizItemsSql);
        await db.execute(createQuizStatsSql);
        await db.execute(createQuizAttemptsSql);
      },
    );
    return db;
  }

  static Future<int> insertFile(FileInfo file) async {
    var db = await database;
    return await db.insert(filesTB, {
      filesColOrigName: file.origName,
      filesColFilepath: file.filepath,
      filesColFileExtension: file.fileExtension,
      filesColFileSize: file.fileSize,
      filesColContentGenerated: file.contentGenerated,
      filesColSummary: file.summary,
      filesColCreatedAt: DateTime.now().millisecondsSinceEpoch,
    });
  }

  static Future<List<FileInfo>> fetchAllFiles() async {
    var db = await database;
    var files = await db.query(filesTB, orderBy: '$filesColCreatedAt DESC');
    return files.map((file) => _fileFromMap(file)).toList();
  }

  static Future<void> deleteFile(int fileId) async {
    var db = await database;
    await db.delete(filesTB, where: '$filesColId = ?', whereArgs: [fileId]);
  }

  static Future<void> deleteAllFiles() async {
    var db = await database;
    await db.delete(filesTB);
  }

  static Future<int> insertFlashcardSet(
    int fileId,
    List<FlashcardItem> flashcards,
  ) async {
    var db = await database;
    await db.transaction((txn) async {
      for (var flashcard in flashcards) {
        await txn.insert(flashcardsTB, {
          flashcardsColFileId: fileId,
          flashcardsColQuestion: flashcard.question,
          flashcardsColAnswer: flashcard.answer,
        });
      }
    });
    return fileId;
  }

  static Future<List<FileInfo>> fetchAllFlashcardSets() async {
    var db = await database;
    var result = await db.rawQuery('''
      SELECT DISTINCT f.* FROM $filesTB f
      INNER JOIN $flashcardsTB fc ON f.$filesColId = fc.$flashcardsColFileId
      ORDER BY f.$filesColCreatedAt DESC
    ''');

    List<FileInfo> files = [];
    for (var fileMap in result) {
      var file = _fileFromMap(fileMap);
      file.flashcardsFromContent = await _fetchFlashcardsForFile(file.id!);
      files.add(file);
    }
    return files;
  }

  static Future<List<FlashcardItem>> _fetchFlashcardsForFile(int fileId) async {
    var db = await database;
    var flashcards = await db.query(
      flashcardsTB,
      where: '$flashcardsColFileId = ?',
      whereArgs: [fileId],
    );
    return flashcards
        .map((fc) => FlashcardItem(
              question: fc[flashcardsColQuestion] as String,
              answer: fc[flashcardsColAnswer] as String,
            ))
        .toList();
  }

  static Future<void> deleteFlashcardSet(int fileId) async {
    var db = await database;
    await db.delete(
      flashcardsTB,
      where: '$flashcardsColFileId = ?',
      whereArgs: [fileId],
    );
  }

  static Future<int> insertMnemonicsSet(
    int fileId,
    List<MnemonicsItem> mnemonics,
  ) async {
    var db = await database;
    await db.transaction((txn) async {
      for (var mnemonic in mnemonics) {
        await txn.insert(mnemonicsTB, {
          mnemonicsColFileId: fileId,
          mnemonicsColMnemonics: mnemonic.mnemonics,
          mnemonicsColExplanation: mnemonic.explanation,
        });
      }
    });
    return fileId;
  }

  static Future<List<FileInfo>> fetchAllMnemonicsSets() async {
    var db = await database;
    var result = await db.rawQuery('''
      SELECT DISTINCT f.* FROM $filesTB f
      INNER JOIN $mnemonicsTB m ON f.$filesColId = m.$mnemonicsColFileId
      ORDER BY f.$filesColCreatedAt DESC
    ''');

    List<FileInfo> files = [];
    for (var fileMap in result) {
      var file = _fileFromMap(fileMap);
      file.mnemonicsFromContent = await _fetchMnemonicsForFile(file.id!);
      files.add(file);
    }
    return files;
  }

  static Future<List<MnemonicsItem>> _fetchMnemonicsForFile(int fileId) async {
    var db = await database;
    var mnemonics = await db.query(
      mnemonicsTB,
      where: '$mnemonicsColFileId = ?',
      whereArgs: [fileId],
    );
    return mnemonics
        .map((m) => MnemonicsItem(
              mnemonics: m[mnemonicsColMnemonics] as String,
              explanation: m[mnemonicsColExplanation] as String,
            ))
        .toList();
  }

  static Future<void> deleteMnemonicsSet(int fileId) async {
    var db = await database;
    await db.delete(
      mnemonicsTB,
      where: '$mnemonicsColFileId = ?',
      whereArgs: [fileId],
    );
  }

  static Future<int> insertQuizSet(
    int fileId,
    List<QuizItem> quizItems,
  ) async {
    var db = await database;
    int quizSetId = 0;
    await db.transaction((txn) async {
      // First, create the quiz set
      quizSetId = await txn.insert(quizSetsTB, {
        quizSetsColFileId: fileId,
        quizSetsColCreatedAt: DateTime.now().millisecondsSinceEpoch,
      });

      // Then insert all quiz items linked to this quiz set
      for (var quiz in quizItems) {
        await txn.insert(quizItemsTB, {
          quizItemsColQuizSetId: quizSetId,
          quizItemsColType: quiz.type,
          quizItemsColQuestion: quiz.question,
          quizItemsColChoices: quiz.choices?.join('|||'),
          quizItemsColAnswer: quiz.answer,
        });
      }

      // Create statistics for this quiz set
      await txn.insert(quizStatsTB, {
        quizStatsColQuizSetId: quizSetId,
        quizStatsColTimesAttempted: 0,
        quizStatsColPerfectScores: 0,
        quizStatsColTotalQuestionsAnswered: 0,
        quizStatsColTotalCorrectAnswers: 0,
      });
    });
    return quizSetId;
  }

  static Future<List<FileInfo>> fetchAllQuizSets() async {
    var db = await database;
    // Get all quiz sets with their associated file info
    var result = await db.rawQuery('''
      SELECT qs.$quizSetsColId as quizSetId, qs.$quizSetsColCreatedAt as quizCreatedAt, f.* 
      FROM $quizSetsTB qs
      INNER JOIN $filesTB f ON qs.$quizSetsColFileId = f.$filesColId
      ORDER BY qs.$quizSetsColCreatedAt DESC
    ''');

    List<FileInfo> quizSets = [];
    for (var row in result) {
      var file = _fileFromMap(row);
      file.quizSetId = row['quizSetId'] as int;
      file.createdAt =
          DateTime.fromMillisecondsSinceEpoch(row['quizCreatedAt'] as int);
      file.quizzesFromContent =
          await _fetchQuizItemsForQuizSet(file.quizSetId!);
      file.quizStatistics = await _fetchQuizStatistics(file.quizSetId!);
      quizSets.add(file);
    }
    return quizSets;
  }

  static Future<List<QuizItem>> _fetchQuizItemsForQuizSet(int quizSetId) async {
    var db = await database;
    var quizItems = await db.query(
      quizItemsTB,
      where: '$quizItemsColQuizSetId = ?',
      whereArgs: [quizSetId],
    );
    return quizItems.map((q) {
      var choicesStr = q[quizItemsColChoices] as String?;
      List<String>? choices =
          choicesStr != null ? choicesStr.split('|||') : null;
      return QuizItem(
        type: q[quizItemsColType] as String,
        question: q[quizItemsColQuestion] as String,
        choices: choices,
        answer: q[quizItemsColAnswer] as String?,
      );
    }).toList();
  }

  static Future<QuizStatistics> _fetchQuizStatistics(int quizSetId) async {
    var db = await database;
    var stats = await db.query(
      quizStatsTB,
      where: '$quizStatsColQuizSetId = ?',
      whereArgs: [quizSetId],
    );

    if (stats.isEmpty) {
      return QuizStatistics();
    }

    var stat = stats.first;
    var attempts = await _fetchQuizAttempts(quizSetId);

    return QuizStatistics(
      timesAttempted: stat[quizStatsColTimesAttempted] as int,
      perfectScores: stat[quizStatsColPerfectScores] as int,
      totalQuestionsAnswered: stat[quizStatsColTotalQuestionsAnswered] as int,
      totalCorrectAnswers: stat[quizStatsColTotalCorrectAnswers] as int,
      attempts: attempts,
    );
  }

  static Future<List<QuizAttempt>> _fetchQuizAttempts(int quizSetId) async {
    var db = await database;
    var attempts = await db.query(
      quizAttemptsTB,
      where: '$quizAttemptsColQuizSetId = ?',
      whereArgs: [quizSetId],
      orderBy: '$quizAttemptsColDate DESC',
    );

    return attempts
        .map((a) => QuizAttempt(
              score: a[quizAttemptsColScore] as int,
              totalQuestions: a[quizAttemptsColTotalQuestions] as int,
              date: DateTime.fromMillisecondsSinceEpoch(
                  a[quizAttemptsColDate] as int),
            ))
        .toList();
  }

  static Future<void> updateQuizStatistics(
    int quizSetId,
    int score,
    int totalQuestions,
  ) async {
    var db = await database;
    await db.transaction((txn) async {
      var stats = await txn.query(
        quizStatsTB,
        where: '$quizStatsColQuizSetId = ?',
        whereArgs: [quizSetId],
      );

      if (stats.isEmpty) return;

      var currentStats = stats.first;
      int timesAttempted =
          (currentStats[quizStatsColTimesAttempted] as int) + 1;
      int perfectScores = (currentStats[quizStatsColPerfectScores] as int) +
          (score == totalQuestions ? 1 : 0);
      int totalQuestionsAnswered =
          (currentStats[quizStatsColTotalQuestionsAnswered] as int) +
              totalQuestions;
      int totalCorrectAnswers =
          (currentStats[quizStatsColTotalCorrectAnswers] as int) + score;

      await txn.update(
        quizStatsTB,
        {
          quizStatsColTimesAttempted: timesAttempted,
          quizStatsColPerfectScores: perfectScores,
          quizStatsColTotalQuestionsAnswered: totalQuestionsAnswered,
          quizStatsColTotalCorrectAnswers: totalCorrectAnswers,
        },
        where: '$quizStatsColQuizSetId = ?',
        whereArgs: [quizSetId],
      );

      await txn.insert(quizAttemptsTB, {
        quizAttemptsColQuizSetId: quizSetId,
        quizAttemptsColScore: score,
        quizAttemptsColTotalQuestions: totalQuestions,
        quizAttemptsColDate: DateTime.now().millisecondsSinceEpoch,
      });
    });
  }

  static Future<void> deleteQuizSet(int quizSetId) async {
    var db = await database;
    await db.transaction((txn) async {
      await txn.delete(
        quizAttemptsTB,
        where: '$quizAttemptsColQuizSetId = ?',
        whereArgs: [quizSetId],
      );

      await txn.delete(
        quizStatsTB,
        where: '$quizStatsColQuizSetId = ?',
        whereArgs: [quizSetId],
      );

      await txn.delete(
        quizItemsTB,
        where: '$quizItemsColQuizSetId = ?',
        whereArgs: [quizSetId],
      );

      await txn.delete(
        quizSetsTB,
        where: '$quizSetsColId = ?',
        whereArgs: [quizSetId],
      );
    });
  }

  static FileInfo _fileFromMap(Map<String, dynamic> map) {
    return FileInfo(
      origName: map[filesColOrigName] as String,
      filepath: map[filesColFilepath] as String?,
      fileExtension: map[filesColFileExtension] as String?,
      fileSize: map[filesColFileSize] as int?,
      contentGenerated: map[filesColContentGenerated] as String,
      summary: map[filesColSummary] as String?,
    )..id = map[filesColId] as int;
  }
}

final crammyDbHelper = CrammyDbHelper();
