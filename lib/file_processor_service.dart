import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:docx_to_text/docx_to_text.dart';
import '../models/file_data.dart';

class FileProcessorService {
  static const String apiKey = 'AIzaSyDNOOZRiVsoa59XTkE5SAAsolcnvpCrX1o';
  static const String modelName = 'gemini-2.5-flash';

  static Future<FileInfo?> pickAndProcessFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        'pdf',
        'docx',
        'doc',
        'pptx',
        'ppt',
        'txt',
        'jpg',
        'jpeg',
        'png'
      ],
      withData: true,
    );

    if (result == null || result.files.isEmpty) {
      return null;
    }

    final file = result.files.first;
    final filePath = file.path;
    final fileBytes = file.bytes;

    if (filePath == null && fileBytes == null) {
      return null;
    }

    final extension = file.extension?.toLowerCase();

    if (extension == 'pptx' || extension == 'ppt') {
      throw Exception(
        'PowerPoint files are not fully supported yet. '
        'Please export your presentation as PDF and try again.',
      );
    }

    try {
      Uint8List bytes;
      if (fileBytes != null) {
        bytes = fileBytes;
      } else {
        bytes = await File(filePath!).readAsBytes();
      }

      String extractedText;

      if (extension == 'docx') {
        extractedText = await _extractTextFromDocx(bytes);

        if (extractedText.isEmpty) {
          throw Exception('No text could be extracted from the DOCX file');
        }
      } else if (extension == 'doc') {
        final mimeType = _getMimeType(extension);
        extractedText = await _extractTextWithGemini(bytes, mimeType);
      } else if (_isImageFile(extension)) {
        final mimeType = _getMimeType(extension);
        extractedText = await _extractTextFromImage(bytes, mimeType);
      } else if (extension == 'txt') {
        extractedText = String.fromCharCodes(bytes);
      } else {
        final mimeType = _getMimeType(extension);
        extractedText = await _extractTextWithGemini(bytes, mimeType);
      }

      if (extractedText.isEmpty) {
        throw Exception('No text could be extracted from the file');
      }

      final summary = await _generateSummary(extractedText);

      return FileInfo(
        origName: file.name,
        filepath: filePath,
        fileExtension: extension,
        fileSize: file.size,
        contentGenerated: extractedText,
        summary: summary,
      );
    } catch (e) {
      throw Exception('Error processing file: $e');
    }
  }

  static Future<String> _extractTextFromDocx(Uint8List bytes) async {
    try {
      final text = docxToText(bytes);

      if (text == null || text.trim().isEmpty) {
        throw Exception('No text found in DOCX file');
      }

      final lines = text.split('\n');
      final cleanedLines = <String>[];

      for (var line in lines) {
        final trimmed = line.trim();
        if (trimmed.isNotEmpty) {
          cleanedLines.add(trimmed);
        }
      }

      return cleanedLines.join('\n\n');
    } catch (e) {
      throw Exception('Failed to extract text from DOCX: $e');
    }
  }

  static bool _isImageFile(String? extension) {
    return extension == 'jpg' || extension == 'jpeg' || extension == 'png';
  }

  static String _getMimeType(String? extension) {
    switch (extension) {
      case 'pdf':
        return 'application/pdf';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case 'doc':
        return 'application/msword';
      case 'pptx':
        return 'application/vnd.openxmlformats-officedocument.presentationml.presentation';
      case 'ppt':
        return 'application/vnd.ms-powerpoint';
      case 'txt':
        return 'text/plain';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      default:
        return 'application/octet-stream';
    }
  }

  static Future<String> _extractTextFromImage(
    Uint8List bytes,
    String mimeType,
  ) async {
    final model = GenerativeModel(
      model: modelName,
      apiKey: apiKey,
    );

    try {
      final response = await model.generateContent([
        Content.multi([
          DataPart(mimeType, bytes),
          TextPart(
            'Extract ALL visible text from this image. '
            'Return ONLY the extracted text with no additional commentary. '
            'Preserve the original structure, formatting, and organization. '
            'If there are equations, formulas, or diagrams, describe them clearly. '
            'Format the text cleanly with:'
            '\n- Proper line breaks between paragraphs'
            '\n- Clear section headings'
            '\n- Numbered or bulleted lists where appropriate'
            '\n- Preserve all important information and educational content',
          ),
        ]),
      ]);

      return response.text?.trim() ?? '';
    } catch (e) {
      throw Exception('Failed to extract text from image: $e');
    }
  }

  static Future<String> _extractTextWithGemini(
    Uint8List bytes,
    String mimeType,
  ) async {
    final model = GenerativeModel(
      model: modelName,
      apiKey: apiKey,
    );

    try {
      final response = await model.generateContent([
        Content.multi([
          DataPart(mimeType, bytes),
          TextPart(
            'Extract ALL text content from this document. '
            'Return ONLY the extracted text with no commentary or explanations. '
            'Format the text cleanly with:'
            '\n- Proper line breaks between paragraphs'
            '\n- Clear section headings'
            '\n- Numbered or bulleted lists where appropriate'
            '\n- Remove any redundant spacing or formatting artifacts'
            '\n- Preserve all important information and educational content',
          ),
        ]),
      ]);

      return response.text?.trim() ?? '';
    } catch (e) {
      throw Exception('Failed to extract text with Gemini: $e');
    }
  }

  static Future<String> _generateSummary(String content) async {
    final model = GenerativeModel(
      model: modelName,
      apiKey: apiKey,
      systemInstruction: Content.system('''
You are an expert at creating clear, well-structured summaries of educational content.

FORMATTING RULES:
1. Start with a brief overview sentence
2. Organize main topics using bullet points (•)
3. Each bullet point should be a complete, informative sentence
4. Use sub-bullets (  ◦) for supporting details when needed
5. Keep language clear and direct
6. Focus on key concepts students need to learn

OUTPUT STRUCTURE:
[Brief overview sentence]

Key Topics:
• [Main topic 1 with brief explanation]
  ◦ [Supporting detail if needed]
• [Main topic 2 with brief explanation]
  ◦ [Supporting detail if needed]
• [Main topic 3 with brief explanation]

[Concluding sentence about importance/application]

EXAMPLE:
This lesson covers server maintenance, focusing on its importance and best practices for keeping systems running efficiently.

Key Topics:
• Server maintenance involves continuous monitoring, updating, and securing of servers to ensure optimal performance and reliability
  ◦ Prevents downtime and enhances overall system performance
• Servers can operate in different environments including on-premise, cloud-based, or hybrid configurations
  ◦ Each environment has unique maintenance requirements
• Effective maintenance follows Standard Operating Procedures (SOPs) and compliance requirements
  ◦ Includes proper labeling, record-keeping, and use of UPS systems

Understanding these principles is essential for maintaining robust and secure server infrastructure.

Now create a well-formatted summary:
'''),
    );

    try {
      final response = await model.generateContent([
        Content.text(content),
      ]);

      return response.text?.trim() ?? content;
    } catch (e) {
      return content;
    }
  }
}
