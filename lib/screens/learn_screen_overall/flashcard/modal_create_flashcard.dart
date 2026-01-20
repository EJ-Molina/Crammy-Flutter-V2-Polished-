import 'dart:convert';
import 'package:crammy_app/models/file_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../../helpers/environment_config.dart';
import '../../../models/flashcard_item.dart';

class ShowModalCreateFlashCard extends StatefulWidget {
  const ShowModalCreateFlashCard({
    super.key,
    required this.files,
    required this.onCreate,
  });

  final List<FileInfo> files;
  final Function onCreate;

  @override
  State<ShowModalCreateFlashCard> createState() =>
      _ShowModalCreateFlashCardState();
}

class _ShowModalCreateFlashCardState extends State<ShowModalCreateFlashCard> {
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
          "Choose a file to create flashcards",
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
                onTap: () async {
                  final generatedFC = await _generateFlashcards(context, file);

                  if (!mounted) return;

                  if (generatedFC.isEmpty) {
                    return;
                  }

                  Navigator.pop(context);

                  final FileInfo newFcFile = FileInfo(
                    origName: file.origName,
                    filepath: file.filepath,
                    fileExtension: file.fileExtension,
                    fileSize: file.fileSize,
                    contentGenerated: file.contentGenerated,
                    flashcardsFromContent: generatedFC,
                  )..id = file.id;

                  widget.onCreate(newFcFile);
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

  Future<List<FlashcardItem>> _generateFlashcards(
    BuildContext dialogContext,
    FileInfo file,
  ) async {
    final model = GenerativeModel(
      model: EnvironmentConfig.geminiModel,
      apiKey: EnvironmentConfig.geminiApiKey,
      systemInstruction: Content.system('''
You are an expert flashcard creator. Your goal is to extract ALL key facts and concepts from the content and create comprehensive flashcards that cover the ENTIRE material.

RULES:
1. Use EXACT terminology and phrases from the source material
2. Keep questions clear and specific
3. Keep answers direct and factual
4. Do NOT paraphrase technical terms or key concepts
5. Each flashcard should test one specific piece of knowledge
6. Generate AT LEAST 15-20 flashcards (or more if content is extensive)
7. Cover ALL major topics, subtopics, definitions, concepts, and important details

COVERAGE REQUIREMENTS:
- Create flashcards for every major concept
- Create flashcards for key definitions
- Create flashcards for important processes or procedures
- Create flashcards for significant facts or data points
- Create flashcards for relationships between concepts
- Ensure no important information is left out

OUTPUT FORMAT (JSON array only, no markdown):
[
  {"question": "What is photosynthesis?", "answer": "The process by which plants convert light energy into chemical energy to produce glucose"},
  {"question": "What pigment is primarily responsible for photosynthesis?", "answer": "Chlorophyll"},
  {"question": "Where does photosynthesis occur in plant cells?", "answer": "In the chloroplasts"}
]

Now process this content and generate comprehensive flashcards that cover ALL the material:
'''),
    );

// will to pop
    showDialog(
      context: dialogContext,
      barrierDismissible: false,
      builder: (context) => const PopScope(
        canPop: false,
        child: const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Expanded(child: Text('Creating flashcards...')),
            ],
          ),
        ),
      ),
    );

    try {
      final response = await model.generateContent([
        Content.text(file.contentGenerated),
      ]);

      if (mounted && Navigator.canPop(dialogContext)) {
        Navigator.of(dialogContext).pop();
      }

      final responseText = response.text?.trim();
      if (responseText == null || responseText.isEmpty) {
        if (mounted) {
          _showErrorDialog(
              dialogContext, 'No response from AI. Please try again.');
        }
        return [];
      }

      var jsonString = responseText;
      if (jsonString.startsWith('```')) {
        jsonString =
            jsonString.replaceAll(RegExp(r'```[a-zA-Z]*\n?'), '').trim();
      }

      final List<dynamic> jsonList = json.decode(jsonString);
      final flashcards =
          jsonList.map((json) => FlashcardItem.fromJson(json)).toList();

      return flashcards;
    } catch (e) {
      if (mounted && Navigator.canPop(dialogContext)) {
        Navigator.of(dialogContext).pop();
      }

      if (mounted) {
        _showErrorDialog(dialogContext, 'Failed to generate flashcards: $e');
      }
      return [];
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
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
