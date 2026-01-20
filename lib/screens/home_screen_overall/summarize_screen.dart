import 'package:crammy_app/models/file_data.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class SummarizeScreen extends StatelessWidget {
  const SummarizeScreen({super.key, required this.file});

  final FileInfo file;

  Widget _buildFormattedText(String text) {
    final lines = text.split('\n');
    List<Widget> widgets = [];

    for (var line in lines) {
      line = line.trim();
      if (line.isEmpty) {
        widgets.add(const SizedBox(height: 8));
        continue;
      }

      if (line.startsWith('•')) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(left: 8, top: 8, bottom: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '• ',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF364F6B),
                ),
              ),
              Expanded(
                child: _buildRichTextLine(line.substring(1).trim()),
              ),
            ],
          ),
        ));
      } else if (line.startsWith('◦')) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(left: 32, top: 4, bottom: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '◦ ',
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xFF3FC1C9),
                ),
              ),
              Expanded(
                child: _buildRichTextLine(line.substring(1).trim()),
              ),
            ],
          ),
        ));
      } else if (line.contains(':') && !line.contains('  ')) {
        final parts = line.split(':');
        if (parts.length == 2) {
          widgets.add(Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 4),
            child: _buildRichTextLine(line),
          ));
        } else {
          widgets.add(Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 4),
            child: _buildRichTextLine(line),
          ));
        }
      } else {
        widgets.add(Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 4),
          child: _buildRichTextLine(line),
        ));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  Widget _buildRichTextLine(String line) {
    final List<TextSpan> spans = [];
    final boldPattern = RegExp(r'\*\*(.*?)\*\*');
    int lastIndex = 0;

    for (final match in boldPattern.allMatches(line)) {
      if (match.start > lastIndex) {
        final beforeText = line.substring(lastIndex, match.start);
        spans.addAll(_parseColonText(beforeText));
      }

      spans.add(TextSpan(
        text: match.group(1),
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Color(0xFF364F6B),
        ),
      ));

      lastIndex = match.end;
    }

    if (lastIndex < line.length) {
      final remainingText = line.substring(lastIndex);
      spans.addAll(_parseColonText(remainingText));
    }

    if (spans.isEmpty) {
      spans.addAll(_parseColonText(line));
    }

    return RichText(
      text: TextSpan(
        style: const TextStyle(
          fontSize: 15,
          height: 1.6,
          color: Color(0xFF2D3E50),
        ),
        children: spans,
      ),
    );
  }

  List<TextSpan> _parseColonText(String text) {
    if (text.contains(':')) {
      final parts = text.split(':');
      if (parts.length >= 2) {
        return [
          TextSpan(
            text: '${parts[0].trim()}:',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF364F6B),
            ),
          ),
          TextSpan(text: ' ${parts.sublist(1).join(':').trim()}'),
        ];
      }
    }

    return [TextSpan(text: text)];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          file.origName,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF364F6B),
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: const Color(0xFF3FC1C9),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: const Text(
                    "Summary",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              const Gap(20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child:
                    _buildFormattedText(file.summary ?? file.contentGenerated),
              ),
              const Gap(30),
              const Divider(thickness: 2),
              const Gap(20),
              Center(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: const Color(0xFF364F6B),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: const Text(
                    "Full Content",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              const Gap(20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Text(
                  file.contentGenerated,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.6,
                    color: Color(0xFF333333),
                  ),
                  textAlign: TextAlign.justify,
                ),
              ),
              const Gap(20),
            ],
          ),
        ),
      ),
    );
  }
}
