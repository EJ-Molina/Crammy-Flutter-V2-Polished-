import 'package:crammy_app/models/file_data.dart';
import 'package:crammy_app/models/quiz_item.dart';
import 'package:crammy_app/screens/learn_screen_overall/quiz/quiz_content.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class QuizPage extends StatefulWidget {
  QuizPage({super.key, this.quizData, required this.onDelete});
  final Function onDelete;
  List<FileInfo>? quizData;

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  String _getQuizTypeLabel(List<QuizItem> quiz) {
    if (quiz.isEmpty) return 'No Type';

    final types = quiz.map((q) => q.type).toSet();
    if (types.length > 1) return 'Mixed';

    switch (quiz.first.type) {
      case 'MC':
        return 'Multiple Choice';
      case 'TF':
        return 'True/False';
      case 'ID':
        return 'Identification';
      default:
        return quiz.first.type;
    }
  }

  void _showDetailedStatistics(
      BuildContext context, FileInfo quizFile, int index) {
    final quiz = quizFile.quizzesFromContent ?? [];
    final stats = quizFile.quizStatistics;
    final quizType = _getQuizTypeLabel(quiz);
    final createdDate = quizFile.createdAt ?? DateTime.now();
    final formattedDate =
        DateFormat('MMM dd, yyyy \'at\' hh:mm a').format(createdDate);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Quiz ${index + 1} Details'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF364F6B).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Quiz Type',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      quizType,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF364F6B),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF3FC1C9).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Created On',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formattedDate,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF3FC1C9),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _buildStatItem('Total Questions', quiz.length.toString()),
              const Divider(height: 20),
              if (stats != null && stats.timesAttempted > 0) ...[
                const Text(
                  'Performance Statistics',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF364F6B),
                  ),
                ),
                const SizedBox(height: 12),
                _buildStatItem(
                    'Times Attempted', stats.timesAttempted.toString()),
                _buildStatItem(
                    'Perfect Scores', stats.perfectScores.toString()),
                _buildStatItem(
                  'Overall Accuracy',
                  '${stats.accuracy.toStringAsFixed(1)}%',
                ),
                _buildStatItem(
                  'Total Questions Answered',
                  stats.totalQuestionsAnswered.toString(),
                ),
                _buildStatItem(
                  'Total Correct Answers',
                  stats.totalCorrectAnswers.toString(),
                ),
                if (stats.attempts.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const Text(
                    'Recent Attempts',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF364F6B),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...stats.attempts.take(3).map((attempt) {
                    final attemptDate =
                        DateFormat('MMM dd, hh:mm a').format(attempt.date);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              attemptDate,
                              style: const TextStyle(fontSize: 12),
                            ),
                            Text(
                              '${attempt.score}/${attempt.totalQuestions} (${attempt.percentage.toStringAsFixed(0)}%)',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: attempt.percentage >= 75
                                    ? Colors.green
                                    : attempt.percentage >= 50
                                        ? Colors.orange
                                        : Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Text(
                      'No attempts yet. Take the quiz to see statistics!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Color(0xFF3FC1C9),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: widget.quizData == null || widget.quizData!.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(
                    Icons.quiz_outlined,
                    size: 64,
                    color: Color(0xFF364F6B),
                  ),
                  SizedBox(height: 16),
                  Text(
                    "No Quizzes Created",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF364F6B),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Tap + to create quizzes from your files",
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF364F6B),
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemBuilder: (_, index) {
                var quizFile = widget.quizData![index];
                var quiz = quizFile.quizzesFromContent!;

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (_) => QuizContent(
                          quizzes: quiz,
                          index: index,
                          file: quizFile,
                        ),
                      ),
                    );
                  },
                  onLongPress: () {
                    _showDetailedStatistics(context, quizFile, index);
                  },
                  child: Dismissible(
                    key: Key(quizFile.quizSetId.toString() + quizFile.origName),
                    direction: DismissDirection.startToEnd,
                    background: Container(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.only(left: 20),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.delete,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    confirmDismiss: (direction) async {
                      return await showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Delete Quiz'),
                          content: const Text(
                            'Are you sure you want to delete this quiz?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            FilledButton(
                              onPressed: () => Navigator.pop(context, true),
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      );
                    },
                    onDismissed: (direction) {
                      widget.onDelete(quizFile, widget.quizData);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Quiz deleted successfully'),
                          backgroundColor: Colors.red,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    child: Card(
                      margin: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 12,
                      ),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF364F6B).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.quiz,
                                color: Color(0xFF364F6B),
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Quiz ${index + 1} - ${_getQuizTypeLabel(quiz)}",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF364F6B),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'From "${quizFile.origName}"',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (quizFile.quizStatistics != null &&
                                      quizFile.quizStatistics!.timesAttempted >
                                          0) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      'Attempts: ${quizFile.quizStatistics!.timesAttempted} | Accuracy: ${quizFile.quizStatistics!.accuracy.toStringAsFixed(1)}%',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFF3FC1C9),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 4),
                                  Text(
                                    'Long press for details',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey[600],
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Delete Quiz'),
                                    content: const Text(
                                      'Are you sure you want to delete this quiz?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Cancel'),
                                      ),
                                      FilledButton(
                                        onPressed: () {
                                          widget.onDelete(
                                              quizFile, widget.quizData);
                                          Navigator.pop(context);
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  'Quiz deleted successfully'),
                                              backgroundColor: Colors.red,
                                              duration: Duration(seconds: 2),
                                            ),
                                          );
                                        },
                                        style: FilledButton.styleFrom(
                                          backgroundColor: Colors.red,
                                        ),
                                        child: const Text('Delete'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                              ),
                              tooltip: 'Delete quiz',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
              itemCount: widget.quizData!.length,
            ),
    );
  }
}
