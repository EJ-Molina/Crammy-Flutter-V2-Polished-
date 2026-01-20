import 'package:crammy_app/helpers/crammy_db_helper.dart';
import 'package:crammy_app/models/file_data.dart';
import 'package:crammy_app/models/quiz_item.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:linear_progress_bar/linear_progress_bar.dart';

class QuizContent extends StatefulWidget {
  const QuizContent({
    super.key,
    required this.quizzes,
    required this.index,
    required this.file,
  });

  final List<QuizItem> quizzes;
  final int index;
  final FileInfo file;

  @override
  State<QuizContent> createState() => _QuizContentState();
}

class _QuizContentState extends State<QuizContent> {
  int currentQuestionIndex = 0;
  int score = 0;
  bool isQuizComplete = false;
  List<String?> userAnswers = [];
  final TextEditingController answerController = TextEditingController();

  bool get isMixedQuiz {
    final types = widget.quizzes.map((q) => q.type).toSet();
    return types.length > 1;
  }

  String get quizTitle {
    if (isMixedQuiz) {
      return 'Mixed Quiz';
    }
    switch (widget.quizzes.first.type) {
      case 'MC':
        return 'Multiple Choice Quiz';
      case 'TF':
        return 'True/False Quiz';
      case 'ID':
        return 'Identification Quiz';
      default:
        return 'Quiz';
    }
  }

  @override
  void initState() {
    super.initState();
    userAnswers = List.filled(widget.quizzes.length, null);
  }

  @override
  void dispose() {
    answerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz ${widget.index + 1} - $quizTitle'),
        backgroundColor: const Color(0xFF364F6B),
        foregroundColor: Colors.white,
      ),
      body: isQuizComplete ? _buildResultScreen() : _buildQuestionScreen(),
    );
  }

  Widget _buildQuestionScreen() {
    final currentQuiz = widget.quizzes[currentQuestionIndex];

    return Padding(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          children: [
            _buildProgressBar(),
            const Gap(20),
            Text(
              "Question ${currentQuestionIndex + 1} / ${widget.quizzes.length}",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (isMixedQuiz) ...[
              const Gap(8),
              _buildQuestionTypeBadge(currentQuiz.type),
            ],
            const Gap(20),
            _buildQuestionCard(currentQuiz),
            const Gap(20),
            _buildAnswerOptions(currentQuiz),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 0.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: LinearProgressBar(
        maxSteps: widget.quizzes.length,
        progressType: LinearProgressBar.progressTypeLinear,
        currentStep: currentQuestionIndex + 1,
        progressColor: const Color(0xFF3FC1C9),
        backgroundColor: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        minHeight: 13,
      ),
    );
  }

  Widget _buildQuestionTypeBadge(String type) {
    String label;
    Color color;

    switch (type) {
      case 'MC':
        label = 'Multiple Choice';
        color = Colors.blue;
        break;
      case 'TF':
        label = 'True/False';
        color = Colors.orange;
        break;
      case 'ID':
        label = 'Identification';
        color = Colors.purple;
        break;
      default:
        label = type;
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildQuestionCard(QuizItem quiz) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          quiz.question,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildAnswerOptions(QuizItem quiz) {
    switch (quiz.type) {
      case 'MC':
        return _buildMultipleChoiceOptions(quiz);
      case 'TF':
        return _buildTrueFalseOptions();
      case 'ID':
        return _buildIdentificationInput();
      default:
        return const Text('Unknown question type');
    }
  }

  Widget _buildMultipleChoiceOptions(QuizItem quiz) {
    if (quiz.choices == null || quiz.choices!.isEmpty) {
      return const Text('No choices available');
    }

    return Column(
      children: quiz.choices!.map((choice) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: ElevatedButton(
            onPressed: () => _submitAnswer(choice),
            style: ElevatedButton.styleFrom(
              alignment: Alignment.centerLeft,
              backgroundColor: const Color(0xFF364F6B),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              minimumSize: const Size(double.infinity, 50),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                choice,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTrueFalseOptions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildTrueFalseButton('true', true),
        _buildTrueFalseButton('false', false),
      ],
    );
  }

  Widget _buildTrueFalseButton(String value, bool isTrue) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: ElevatedButton(
          onPressed: () => _submitAnswer(value),
          style: ElevatedButton.styleFrom(
            backgroundColor:
                isTrue ? const Color(0xFF3FC1C9) : const Color(0xFFE94141),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
            minimumSize: const Size(0, 75),
          ),
          child: Text(
            value[0].toUpperCase() + value.substring(1),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIdentificationInput() {
    return Column(
      children: [
        TextField(
          controller: answerController,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            labelText: "Type your answer",
          ),
          textCapitalization: TextCapitalization.sentences,
        ),
        const Gap(20),
        ElevatedButton(
          onPressed: () {
            final answer = answerController.text.trim();
            if (answer.isNotEmpty) {
              _submitAnswer(answer);
            }
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 70, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
            backgroundColor: const Color(0xFF3FC1C9),
            foregroundColor: Colors.white,
          ),
          child: const Text(
            "Submit",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
      ],
    );
  }

  void _submitAnswer(String answer) {
    final currentQuiz = widget.quizzes[currentQuestionIndex];
    userAnswers[currentQuestionIndex] = answer;

    bool isCorrect = false;
    final correctAnswer = currentQuiz.answer ?? '';

    if (currentQuiz.type == 'ID') {
      isCorrect =
          answer.trim().toLowerCase() == correctAnswer.trim().toLowerCase();
    } else if (currentQuiz.type == 'TF') {
      isCorrect =
          answer.trim().toLowerCase() == correctAnswer.trim().toLowerCase();
    } else {
      isCorrect = answer == correctAnswer;
    }

    if (isCorrect) {
      score++;
    }

    if (currentQuestionIndex < widget.quizzes.length - 1) {
      setState(() {
        currentQuestionIndex++;
        answerController.clear();
      });
    } else {
      setState(() {
        isQuizComplete = true;
      });

      _saveQuizStatistics();
    }
  }

  Future<void> _saveQuizStatistics() async {
    if (widget.file.quizSetId != null) {
      try {
        await CrammyDbHelper.updateQuizStatistics(
          widget.file.quizSetId!,
          score,
          widget.quizzes.length,
        );

        widget.file.quizStatistics?.addAttempt(score, widget.quizzes.length);
      } catch (e) {
        print('Failed to save quiz statistics: $e');
      }
    }
  }

  Widget _buildResultScreen() {
    final percentage = widget.quizzes.isEmpty
        ? 0
        : (score / widget.quizzes.length * 100).round();

    return Center(
      child: Column(
        children: [
          const Gap(20),
          Card(
            margin: const EdgeInsets.all(20),
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                children: [
                  const Text(
                    'Quiz Completed!',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 24,
                    ),
                  ),
                  const Gap(20),
                  const Text(
                    "Your Score:",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
                  ),
                  const Gap(10),
                  Text(
                    "$score / ${widget.quizzes.length}",
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 32,
                      color: Color(0xFF3FC1C9),
                    ),
                  ),
                  const Gap(10),
                  Text(
                    "$percentage%",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: percentage >= 75
                          ? Colors.green
                          : percentage >= 50
                              ? Colors.orange
                              : Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (widget.file.quizStatistics != null) ...[
            FilledButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => _buildStatsDialog(),
                );
              },
              icon: const Icon(Icons.analytics),
              label: const Text('View Statistics'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF3FC1C9),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
            const Gap(20),
          ],
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: const Color(0xFF364F6B),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
            child: const Text(
              "Review Answers",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: widget.quizzes.length,
              itemBuilder: (_, index) => _buildAnswerReviewCard(index),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsDialog() {
    final stats = widget.file.quizStatistics!;
    return AlertDialog(
      title: const Text('Quiz Statistics'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatRow('Times Attempted', stats.timesAttempted.toString()),
            _buildStatRow('Perfect Scores', stats.perfectScores.toString()),
            _buildStatRow(
              'Overall Accuracy',
              '${stats.accuracy.toStringAsFixed(1)}%',
            ),
            _buildStatRow(
              'Total Questions',
              stats.totalQuestionsAnswered.toString(),
            ),
            _buildStatRow(
              'Total Correct',
              stats.totalCorrectAnswers.toString(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color(0xFF3FC1C9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerReviewCard(int index) {
    final quiz = widget.quizzes[index];
    final userAnswer = userAnswers[index];
    final correctAnswer = quiz.answer ?? '';

    bool isCorrect;
    if (quiz.type == 'ID' || quiz.type == 'TF') {
      isCorrect = userAnswer?.trim().toLowerCase() ==
          correctAnswer.trim().toLowerCase();
    } else {
      isCorrect = userAnswer == correctAnswer;
    }

    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildQuestionTypeBadge(quiz.type),
                const Spacer(),
                Icon(
                  isCorrect ? Icons.check_circle : Icons.cancel,
                  color: isCorrect ? Colors.green : Colors.red,
                  size: 28,
                ),
              ],
            ),
            const Gap(12),
            Text(
              'Q${index + 1}: ${quiz.question}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const Gap(12),
            if (quiz.type == 'MC' && quiz.choices != null) ...[
              ...quiz.choices!.map((choice) {
                Color? color;
                if (choice == correctAnswer) {
                  color = const Color(0xFF3FC1C9);
                }
                if (userAnswer != correctAnswer && choice == userAnswer) {
                  color = Colors.red;
                }

                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 2),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color?.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(5),
                    border: color != null
                        ? Border.all(color: color, width: 2)
                        : null,
                  ),
                  child: Text(
                    choice,
                    style: TextStyle(
                      fontWeight:
                          color != null ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              }),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF3FC1C9).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color: const Color(0xFF3FC1C9),
                    width: 2,
                  ),
                ),
                child: Text(
                  'Correct Answer: $correctAnswer',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const Gap(8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isCorrect
                      ? const Color(0xFF3FC1C9).withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color: isCorrect ? const Color(0xFF3FC1C9) : Colors.red,
                    width: 2,
                  ),
                ),
                child: Text(
                  'Your Answer: ${userAnswer ?? "Not answered"}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
