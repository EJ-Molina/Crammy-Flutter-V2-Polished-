import 'package:crammy_app/models/file_data.dart';
import 'package:crammy_app/models/mnemonics_item.dart';
import 'package:flutter/material.dart';

class MnemonicsContent extends StatefulWidget {
  const MnemonicsContent({super.key, required this.file, required this.index});

  final FileInfo file;
  final int index;

  @override
  State<MnemonicsContent> createState() => _MnemonicsContentState();
}

class _MnemonicsContentState extends State<MnemonicsContent> {
  List<TextSpan> _parseMarkdownText(String text) {
    final List<TextSpan> spans = [];
    final doubleBoldPattern = RegExp(r'\*\*(.*?)\*\*');
    final singleBoldPattern = RegExp(r'\*(.*?)\*');

    int lastIndex = 0;

    final matches = doubleBoldPattern.allMatches(text).toList();

    if (matches.isEmpty) {
      final singleMatches = singleBoldPattern.allMatches(text).toList();

      if (singleMatches.isEmpty) {
        return [TextSpan(text: text)];
      }

      for (final match in singleMatches) {
        if (match.start > lastIndex) {
          spans.add(TextSpan(text: text.substring(lastIndex, match.start)));
        }
        spans.add(TextSpan(
          text: match.group(1),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3E50),
          ),
        ));
        lastIndex = match.end;
      }

      if (lastIndex < text.length) {
        spans.add(TextSpan(text: text.substring(lastIndex)));
      }

      return spans;
    }

    for (final match in matches) {
      if (match.start > lastIndex) {
        spans.add(TextSpan(text: text.substring(lastIndex, match.start)));
      }
      spans.add(TextSpan(
        text: match.group(1),
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Color(0xFF2D3E50),
        ),
      ));
      lastIndex = match.end;
    }

    if (lastIndex < text.length) {
      spans.add(TextSpan(text: text.substring(lastIndex)));
    }

    return spans;
  }

  Widget _buildFormattedText(String text) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(
          fontSize: 14,
          height: 1.5,
          color: Color(0xFF333333),
        ),
        children: _parseMarkdownText(text),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<MnemonicsItem> mnemonicsData =
        widget.file.mnemonicsFromContent ?? [];

    if (mnemonicsData.isEmpty) {
      return Scaffold(
        appBar: AppBar(
            title: Text("Mnemonics ${widget.index + 1}",
                style: TextStyle(color: Colors.white))),
        body: const Center(child: Text('No mnemonics available')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Mnemonics ${widget.index + 1}"),
        backgroundColor: const Color(0xFF364F6B),
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemBuilder: (_, index) {
          var mnemonicData = mnemonicsData[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3FC1C9).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: _buildFormattedText(mnemonicData.mnemonics),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Divider(color: Colors.grey, thickness: 1),
                    ),
                    const Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        "Explanation:",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Color(0xFF2D3E50),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.topLeft,
                      child: _buildFormattedText(mnemonicData.explanation),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        itemCount: mnemonicsData.length,
      ),
    );
  }
}
