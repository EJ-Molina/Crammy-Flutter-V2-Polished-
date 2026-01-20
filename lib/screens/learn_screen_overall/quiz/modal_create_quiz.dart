import 'package:crammy_app/models/file_data.dart';
import 'package:crammy_app/models/quiz_item.dart';
import 'package:crammy_app/quiz_generation_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ShowModalCreateQuiz extends StatefulWidget {
  const ShowModalCreateQuiz({
    super.key,
    required this.files,
    required this.onCreate,
  });

  final Function onCreate;
  final List<FileInfo> files;

  @override
  State<ShowModalCreateQuiz> createState() => _ShowModalCreateQuizState();
}

class _ShowModalCreateQuizState extends State<ShowModalCreateQuiz> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 15),
        SvgPicture.asset(
          'assets/svg/line_choose_file.svg',
          height: 7,
          width: 14,
        ),
        const SizedBox(height: 15),
        const Text(
          "Choose a file to create quiz",
          style: TextStyle(
            color: Color(0xFF2D3E50),
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.4,
          ),
          child: ListView.builder(
            shrinkWrap: true,
            itemBuilder: (_, index) {
              var file = widget.files[index];
              return GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  _showQuizConfigDialog(file);
                },
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Card(
                    elevation: 3,
                    child: ListTile(
                      leading: const Icon(Icons.file_copy),
                      title: Text(file.origName),
                    ),
                  ),
                ),
              );
            },
            itemCount: widget.files.length,
          ),
        ),
      ],
    );
  }

  void _showQuizConfigDialog(FileInfo file) {
    showDialog(
      context: context,
      builder: (context) => QuizConfigDialog(
        file: file,
        onCreate: widget.onCreate,
      ),
    );
  }
}

class QuizConfigDialog extends StatefulWidget {
  const QuizConfigDialog({
    super.key,
    required this.file,
    required this.onCreate,
  });

  final FileInfo file;
  final Function onCreate;

  @override
  State<QuizConfigDialog> createState() => _QuizConfigDialogState();
}

class _QuizConfigDialogState extends State<QuizConfigDialog> {
  String selectedType = 'MC';
  String selectedDifficulty = 'Medium';
  int questionCount = 5;

  bool isMixed = false;
  Set<String> mixedTypes = {'MC'};

  final Map<String, int> maxQuestions = {
    'MC': 50,
    'TF': 10,
    'ID': 10,
  };

  final List<String> difficulties = ['Easy', 'Medium', 'Hard'];

  int get currentMaxQuestions {
    if (isMixed) return 50;
    return maxQuestions[selectedType]!;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Quiz Configuration',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Checkbox(
                  value: isMixed,
                  onChanged: (value) {
                    setState(() {
                      isMixed = value ?? false;
                      if (!isMixed) {
                        mixedTypes = {selectedType};
                        if (questionCount > maxQuestions[selectedType]!) {
                          questionCount = maxQuestions[selectedType]!;
                        }
                      }
                    });
                  },
                ),
                const Text('Mixed Quiz'),
              ],
            ),
            const Divider(),
            if (isMixed) ...[
              const Text(
                'Select Question Types:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              CheckboxListTile(
                title: const Text('Multiple Choice'),
                value: mixedTypes.contains('MC'),
                onChanged: (value) {
                  setState(() {
                    if (value ?? false) {
                      mixedTypes.add('MC');
                    } else if (mixedTypes.length > 1) {
                      mixedTypes.remove('MC');
                    }
                  });
                },
              ),
              CheckboxListTile(
                title: const Text('True/False'),
                value: mixedTypes.contains('TF'),
                onChanged: (value) {
                  setState(() {
                    if (value ?? false) {
                      mixedTypes.add('TF');
                    } else if (mixedTypes.length > 1) {
                      mixedTypes.remove('TF');
                    }
                  });
                },
              ),
              CheckboxListTile(
                title: const Text('Identification'),
                value: mixedTypes.contains('ID'),
                onChanged: (value) {
                  setState(() {
                    if (value ?? false) {
                      mixedTypes.add('ID');
                    } else if (mixedTypes.length > 1) {
                      mixedTypes.remove('ID');
                    }
                  });
                },
              ),
            ] else ...[
              const Text(
                'Question Type:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildTypeButton('MC', 'Multiple\nChoice'),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildTypeButton('TF', 'True/\nFalse'),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildTypeButton('ID', 'Identifi-\ncation'),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            const Text(
              'Difficulty:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: difficulties.map((difficulty) {
                final isSelected = selectedDifficulty == difficulty;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          selectedDifficulty = difficulty;
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        backgroundColor: isSelected
                            ? const Color(0xFF3FC1C9)
                            : Colors.transparent,
                        foregroundColor:
                            isSelected ? Colors.white : Colors.black87,
                        side: BorderSide(
                          color: isSelected
                              ? const Color(0xFF3FC1C9)
                              : Colors.grey,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        difficulty,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Text(
              'Number of Questions: $questionCount',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Slider(
              value: questionCount.toDouble(),
              min: 1,
              max: currentMaxQuestions.toDouble(),
              divisions: currentMaxQuestions - 1,
              label: questionCount.toString(),
              onChanged: (value) {
                setState(() {
                  questionCount = value.toInt();
                });
              },
            ),
            Text(
              'Max: $currentMaxQuestions questions',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () async {
            await _generateQuiz(context);
          },
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF3FC1C9),
          ),
          child: const Text('Generate Quiz'),
        ),
      ],
    );
  }

  Widget _buildTypeButton(String type, String label) {
    final isSelected = selectedType == type;
    return OutlinedButton(
      onPressed: () {
        setState(() {
          selectedType = type;
          if (questionCount > maxQuestions[type]!) {
            questionCount = maxQuestions[type]!;
          }
        });
      },
      style: OutlinedButton.styleFrom(
        backgroundColor:
            isSelected ? const Color(0xFF3FC1C9) : Colors.transparent,
        foregroundColor: isSelected ? Colors.white : Colors.black87,
        side: BorderSide(
          color: isSelected ? const Color(0xFF3FC1C9) : Colors.grey,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          height: 1.2,
        ),
      ),
    );
  }

  Future<void> _generateQuiz(BuildContext dialogContext) async {
    showDialog(
      context: dialogContext,
      barrierDismissible: false,
      builder: (context) => const PopScope(
        canPop: false,
        child: AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Expanded(child: Text('Generating quiz...')),
            ],
          ),
        ),
      ),
    );

    try {
      final quizItems = isMixed
          ? await QuizGenerationService.generateMixedQuiz(
              file: widget.file,
              context: dialogContext,
              questionCount: questionCount,
              difficulty: selectedDifficulty,
              types: mixedTypes.toList(),
            )
          : await _generateSingleTypeQuiz(dialogContext);

      if (mounted && Navigator.canPop(dialogContext)) {
        Navigator.of(dialogContext).pop();
      }

      if (quizItems.isEmpty) {
        if (mounted && Navigator.canPop(dialogContext)) {
          Navigator.of(dialogContext).pop();
        }
        return;
      }

      if (mounted && Navigator.canPop(dialogContext)) {
        Navigator.of(dialogContext).pop();
      }

      final newQuizFile = FileInfo(
        origName: widget.file.origName,
        filepath: widget.file.filepath,
        fileExtension: widget.file.fileExtension,
        fileSize: widget.file.fileSize,
        contentGenerated: widget.file.contentGenerated,
        quizzesFromContent: quizItems,
      )..id = widget.file.id;

      widget.onCreate(newQuizFile);
    } catch (e) {
      if (mounted && Navigator.canPop(dialogContext)) {
        Navigator.of(dialogContext).pop();
      }

      if (mounted) {
        _showError(dialogContext, 'Failed to generate quiz: $e');
      }
    }
  }

  Future<List<QuizItem>> _generateSingleTypeQuiz(BuildContext context) async {
    switch (selectedType) {
      case 'MC':
        return QuizGenerationService.generateMultipleChoiceQuiz(
          file: widget.file,
          context: context,
          questionCount: questionCount,
          difficulty: selectedDifficulty,
        );
      case 'TF':
        return QuizGenerationService.generateTrueFalseQuiz(
          file: widget.file,
          context: context,
          questionCount: questionCount,
          difficulty: selectedDifficulty,
        );
      case 'ID':
        return QuizGenerationService.generateIdentificationQuiz(
          file: widget.file,
          context: context,
          questionCount: questionCount,
          difficulty: selectedDifficulty,
        );
      default:
        return [];
    }
  }

  void _showError(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
