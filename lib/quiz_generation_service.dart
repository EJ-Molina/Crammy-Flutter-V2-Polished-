import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../helpers/environment_config.dart';
import '../models/file_data.dart';
import '../models/quiz_item.dart';

class QuizGenerationService {

  static Future<List<QuizItem>> generateMultipleChoiceQuiz({
    required FileInfo file,
    required BuildContext context,
    required int questionCount,
    required String difficulty,
  }) async {
    final model = GenerativeModel(
      model: EnvironmentConfig.geminiModel,
      apiKey: EnvironmentConfig.geminiApiKey,
      systemInstruction: Content.system('''
You are an expert quiz creator specializing in multiple choice questions.

DIFFICULTY LEVELS:
- Easy: Basic recall and understanding questions
- Medium: Application and analysis questions
- Hard: Complex evaluation and synthesis questions

RULES:
1. Generate EXACTLY $questionCount questions (no more, no less)
2. Each question has exactly 4 choices labeled A, B, C, D
3. Make distractors (wrong answers) plausible but clearly incorrect
4. Difficulty: $difficulty
5. Use exact terminology from source material
6. One correct answer per question
7. Ensure choices are roughly equal length

OUTPUT FORMAT (JSON array only, no markdown):
[
  {
    "type": "MC",
    "question": "Clear, specific question?",
    "choices": ["Choice A", "Choice B", "Choice C", "Choice D"],
    "answer": "Choice A"
  }
]

Generate $questionCount ${difficulty.toLowerCase()} difficulty multiple choice questions:
'''),
    );

    try {
      final response = await model.generateContent([
        Content.text(file.contentGenerated),
      ]);

      final responseText = response.text?.trim();
      if (responseText == null || responseText.isEmpty) {
        throw Exception('No response from AI');
      }

      var jsonString = responseText;
      if (jsonString.startsWith('```')) {
        jsonString =
            jsonString.replaceAll(RegExp(r'```[a-zA-Z]*\n?'), '').trim();
      }

      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((json) => QuizItem.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to generate quiz: $e');
    }
  }

  static Future<List<QuizItem>> generateTrueFalseQuiz({
    required FileInfo file,
    required BuildContext context,
    required int questionCount,
    required String difficulty,
  }) async {
    final model = GenerativeModel(
      model: EnvironmentConfig.geminiModel,
      apiKey: EnvironmentConfig.geminiApiKey,
      systemInstruction: Content.system('''
You are an expert at creating True/False questions.

DIFFICULTY LEVELS:
- Easy: Straightforward factual statements
- Medium: Requires careful reading and understanding
- Hard: Subtle distinctions and nuanced understanding

RULES:
1. Generate EXACTLY $questionCount questions (no more, no less)
2. Difficulty: $difficulty
3. Mix of true and false statements (roughly 50/50)
4. Avoid absolute words like "always," "never" unless accurate
5. Make false statements believable but clearly incorrect
6. Answer must be exactly "true" or "false" (lowercase)

OUTPUT FORMAT (JSON array only, no markdown):
[
  {
    "type": "TF",
    "question": "Statement that can be evaluated as true or false",
    "answer": "true"
  },
  {
    "type": "TF",
    "question": "Another statement",
    "answer": "false"
  }
]

Generate $questionCount ${difficulty.toLowerCase()} difficulty true/false questions:
'''),
    );

    try {
      final response = await model.generateContent([
        Content.text(file.contentGenerated),
      ]);

      final responseText = response.text?.trim();
      if (responseText == null || responseText.isEmpty) {
        throw Exception('No response from AI');
      }

      var jsonString = responseText;
      if (jsonString.startsWith('```')) {
        jsonString =
            jsonString.replaceAll(RegExp(r'```[a-zA-Z]*\n?'), '').trim();
      }

      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((json) => QuizItem.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to generate quiz: $e');
    }
  }

  static Future<List<QuizItem>> generateIdentificationQuiz({
    required FileInfo file,
    required BuildContext context,
    required int questionCount,
    required String difficulty,
  }) async {
    final model = GenerativeModel(
      model: EnvironmentConfig.geminiModel,
      apiKey: EnvironmentConfig.geminiApiKey,
      systemInstruction: Content.system('''
You are an expert at creating identification questions.

DIFFICULTY LEVELS:
- Easy: Direct recall of key terms and concepts
- Medium: Requires understanding relationships
- Hard: Complex processes and detailed knowledge

RULES:
1. Generate EXACTLY $questionCount questions (no more, no less)
2. Difficulty: $difficulty
3. Questions should prompt for specific terms, names, or concepts
4. Answers should be 1-5 words typically
5. Use exact terminology from the source material
6. Format questions as "What is...", "Who was...", "Identify the..."

OUTPUT FORMAT (JSON array only, no markdown):
[
  {
    "type": "ID",
    "question": "What is the process by which plants convert light to energy?",
    "answer": "Photosynthesis"
  }
]

Generate $questionCount ${difficulty.toLowerCase()} difficulty identification questions:
'''),
    );

    try {
      final response = await model.generateContent([
        Content.text(file.contentGenerated),
      ]);

      final responseText = response.text?.trim();
      if (responseText == null || responseText.isEmpty) {
        throw Exception('No response from AI');
      }

      var jsonString = responseText;
      if (jsonString.startsWith('```')) {
        jsonString =
            jsonString.replaceAll(RegExp(r'```[a-zA-Z]*\n?'), '').trim();
      }

      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((json) => QuizItem.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to generate quiz: $e');
    }
  }

  static Future<List<QuizItem>> generateMixedQuiz({
    required FileInfo file,
    required BuildContext context,
    required int questionCount,
    required String difficulty,
    required List<String> types,
  }) async {
    final typeDistribution = _calculateTypeDistribution(questionCount, types);
    final typesList = types.join(', ');

    final distributionString = typeDistribution.entries
        .map((entry) => '- ${entry.key}: ${entry.value} questions')
        .join('\n');

    final model = GenerativeModel(
      model: EnvironmentConfig.geminiModel,
      apiKey: EnvironmentConfig.geminiApiKey,
      systemInstruction: Content.system('''
You are an expert quiz creator specializing in mixed-format assessments.

QUIZ COMPOSITION:
- Total questions: $questionCount
- Types included: $typesList
- Difficulty: $difficulty
$distributionString

QUESTION TYPE FORMATS:

Multiple Choice (MC):
- 4 choices labeled A, B, C, D
- One correct answer
- Plausible distractors

True/False (TF):
- Statement that can be evaluated
- Answer: "true" or "false" (lowercase)
- Mix of both answers

Identification (ID):
- Prompt for specific term or concept
- Answer: 1-5 words typically
- Direct recall question

RULES:
1. Generate EXACTLY $questionCount questions total
2. Follow the distribution specified above
3. Mix question types throughout (don't group by type)
4. Difficulty: $difficulty
5. Use exact terminology from source

OUTPUT FORMAT (JSON array only, no markdown):
[
  {"type": "MC", "question": "...", "choices": ["A", "B", "C", "D"], "answer": "A"},
  {"type": "TF", "question": "...", "answer": "true"},
  {"type": "ID", "question": "...", "answer": "Answer"}
]

Generate $questionCount mixed questions:
'''),
    );

    try {
      final response = await model.generateContent([
        Content.text(file.contentGenerated),
      ]);

      final responseText = response.text?.trim();
      if (responseText == null || responseText.isEmpty) {
        throw Exception('No response from AI');
      }

      var jsonString = responseText;
      if (jsonString.startsWith('```')) {
        jsonString =
            jsonString.replaceAll(RegExp(r'```[a-zA-Z]*\n?'), '').trim();
      }

      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((json) => QuizItem.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to generate quiz: $e');
    }
  }

  static Map<String, int> _calculateTypeDistribution(
      int total, List<String> types) {
    final distribution = <String, int>{};
    final perType = (total / types.length).floor();
    var remaining = total - (perType * types.length);

    for (var type in types) {
      distribution[type] = perType + (remaining > 0 ? 1 : 0);
      if (remaining > 0) remaining--;
    }

    return distribution;
  }
}
