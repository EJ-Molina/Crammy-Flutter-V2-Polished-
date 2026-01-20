import 'package:crammy_app/models/file_data.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../../models/flashcard_item.dart';

class FlashcardContent extends StatefulWidget {
  const FlashcardContent({required this.file, required this.index, super.key});

  final FileInfo file;
  final int index;

  @override
  State<FlashcardContent> createState() => _FlashcardContentState();
}

class _FlashcardContentState extends State<FlashcardContent> {
  int cardIndex = 0;
  bool isQuestion = true;

  @override
  Widget build(BuildContext context) {
    final List<FlashcardItem> flashcards =
        widget.file.flashcardsFromContent ?? [];

    if (flashcards.isEmpty) {
      return Scaffold(
        appBar: AppBar(
            title: Text("Flashcard ${widget.index + 1}",
                style: TextStyle(color: Colors.white))),
        body: const Center(child: Text('No flashcards available')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Flashcard ${widget.index + 1}",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF364F6B),
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFA1C4FD), Color(0xFFC2E9FB)],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: cardIndex > 0
                      ? () {
                          setState(() {
                            cardIndex--;
                            isQuestion = true;
                          });
                        }
                      : null,
                  icon: const Icon(Icons.arrow_back_ios),
                  color: cardIndex > 0 ? Colors.black87 : Colors.grey,
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        isQuestion = !isQuestion;
                      });
                    },
                    child: Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Container(
                        height: 300,
                        padding: const EdgeInsets.all(24),
                        child: Center(
                          child: Text(
                            isQuestion
                                ? flashcards[cardIndex].question
                                : flashcards[cardIndex].answer,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: const Color(0xFF333333),
                              fontSize: isQuestion ? 18 : 16,
                              fontWeight: isQuestion
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: cardIndex < flashcards.length - 1
                      ? () {
                          setState(() {
                            cardIndex++;
                            isQuestion = true;
                          });
                        }
                      : null,
                  icon: const Icon(Icons.arrow_forward_ios),
                  color: cardIndex < flashcards.length - 1
                      ? Colors.black87
                      : Colors.grey,
                ),
              ],
            ),
            const Gap(20),
            Text(
              "${cardIndex + 1}/${flashcards.length}",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const Gap(10),
            Text(
              isQuestion
                  ? "Tap card to see answer"
                  : "Tap card to see question",
              style: TextStyle(
                fontSize: 12,
                color: Colors.black.withOpacity(0.6),
              ),
            ),
            const Gap(20),
            FilledButton.icon(
              onPressed: () {
                setState(() {
                  isQuestion = !isQuestion;
                });
              },
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF3FC1C9),
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
              ),
              icon: const Icon(Icons.flip),
              label: const Text("Flip Card"),
            ),
          ],
        ),
      ),
    );
  }
}
