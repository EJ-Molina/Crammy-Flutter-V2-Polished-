import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvironmentConfig {
  static String get geminiApiKey {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception(
        'GEMINI_API_KEY not found in environment variables. '
        'Please check your .env file.',
      );
    }
    return apiKey;
  }

  static const String geminiModel = 'gemini-2.5-flash';
}