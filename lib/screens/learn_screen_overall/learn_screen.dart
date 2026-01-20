import 'package:crammy_app/models/file_data.dart';
import 'package:crammy_app/screens/learn_screen_overall/flashcard/flashcard_page.dart';
import 'package:crammy_app/screens/learn_screen_overall/mnemonics/mnemonics_page.dart';
import 'package:crammy_app/screens/learn_screen_overall/quiz/quiz_page.dart';
import 'package:flutter/material.dart';

import '../header_humburger/header_humburger_part_component.dart';

class LearnScreen extends StatefulWidget {
  LearnScreen({
    required this.onTabChanged,
    super.key,
    this.flashCardData,
    this.mnemonicsData,
    this.quizData,
    required this.onDelete,
  });

  final Function onDelete;
  List<FileInfo>? flashCardData;
  List<FileInfo>? mnemonicsData;
  List<FileInfo>? quizData;

  final Function onTabChanged;
  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> {
  int _selectedIndex = 0;

  final List<String> _tabs = ["Flashcard", "Mnemonics", "Quizzes"];

  List<Widget> get _pages => [
        FlashcardPage(
          flashcardData: widget.flashCardData,
          onDelete: widget.onDelete,
        ),
        MnemonicsPage(
          mnemonicsData: widget.mnemonicsData,
          onDelete: widget.onDelete,
        ),
        QuizPage(
          quizData: widget.quizData,
          onDelete: widget.onDelete,
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            const HeaderPart(),
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(_tabs.length, (index) {
                  bool isSelected = _selectedIndex == index;
                  return GestureDetector(
                    onTap: () {
                      widget.onTabChanged(index);
                      setState(() => _selectedIndex = index);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF2D3E50)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _tabs[index],
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _pages[_selectedIndex],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
