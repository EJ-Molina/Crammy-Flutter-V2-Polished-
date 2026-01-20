import 'dart:convert';
import 'package:crammy_app/models/file_data.dart';
import 'package:crammy_app/models/mnemonics_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../../helpers/environment_config.dart';

class ShowModalCreateMnemonics extends StatefulWidget {
  const ShowModalCreateMnemonics({
    super.key,
    required this.files,
    required this.onCreate,
  });

  final Function onCreate;
  final List<FileInfo> files;

  @override
  State<ShowModalCreateMnemonics> createState() =>
      _ShowModalCreateMnemonicsState();
}

class _ShowModalCreateMnemonicsState extends State<ShowModalCreateMnemonics> {
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
          "Choose a file to create mnemonics",
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
                  final generatedMnemonics =
                      await _generateMnemonics(context, file);

                  if (!mounted) return;

                  if (generatedMnemonics.isEmpty) {
                    return;
                  }

                  Navigator.pop(context);

                  final newMnemonicsFile = FileInfo(
                    origName: file.origName,
                    filepath: file.filepath,
                    fileExtension: file.fileExtension,
                    fileSize: file.fileSize,
                    contentGenerated: file.contentGenerated,
                    mnemonicsFromContent: generatedMnemonics,
                  )..id = file.id;

                  widget.onCreate(newMnemonicsFile);
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

  Future<List<MnemonicsItem>> _generateMnemonics(
    BuildContext dialogContext,
    FileInfo file,
  ) async {
    final model = GenerativeModel(
      model: EnvironmentConfig.geminiModel,
      apiKey: EnvironmentConfig.geminiApiKey,
      systemInstruction: Content.system('''
You are an expert at creating memorable mnemonics for learning. Your goal is to create comprehensive memory aids that cover ALL the important concepts in the material.

RULES:
1. Create SHORT, memorable acronyms or phrases (3-8 words ideal)
2. Each mnemonic should be EASY to remember and recall
3. Explanations should be brief and clear (1-2 sentences)
4. Focus on concepts that students struggle to remember
5. Make mnemonics fun, relatable, or visual when possible
6. Generate AT LEAST 10-15 mnemonics (or more for extensive content)
7. Cover ALL major topics and important lists/sequences

COVERAGE REQUIREMENTS:
- Create mnemonics for key terms or concepts
- Create mnemonics for processes with multiple steps
- Create mnemonics for lists or categories
- Create mnemonics for important sequences
- Ensure comprehensive coverage of the material

GOOD EXAMPLES:
- "PEMDAS" → "Please Excuse My Dear Aunt Sally" (Order of operations)
- "ROY G. BIV" → Easy name to remember rainbow colors
- "HOMES" → Names of Great Lakes (Huron, Ontario, Michigan, Erie, Superior)

OUTPUT FORMAT (JSON array only, no markdown):
[
  {"Mnemonics": "PEMDAS", "Explanation": "Helps remember order of operations: Parentheses, Exponents, Multiplication, Division, Addition, Subtraction"},
  {"Mnemonics": "Every Good Boy Does Fine", "Explanation": "Remembers the lines of treble clef: E, G, B, D, F"}
]

Now create comprehensive mnemonics that cover ALL the important concepts from this content:
'''),
    );
//
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
                Expanded(child: Text('Creating mnemonics...')),
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
      final mnemonics =
          jsonList.map((json) => MnemonicsItem.fromJson(json)).toList();

      return mnemonics;
    } catch (e) {
      if (mounted && Navigator.canPop(dialogContext)) {
        Navigator.of(dialogContext).pop();
      }

      if (mounted) {
        _showErrorDialog(dialogContext, 'Failed to generate mnemonics: $e');
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
