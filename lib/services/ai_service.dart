import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';

class AIService {
  static const String _apiKey = 'AIzaSyD501LHuReylkx8ElCGO5L6Prak0YBDXN4';

  /// Validates if the uploaded file content matches the task requirements.
  /// Returns a Map with 'isValid' (bool) and 'reason' (String).
  static Future<Map<String, dynamic>> validateTaskFile({
    required String fileContent,
    required String fileName,
    required String taskName,
    required String taskDescription,
  }) async {
    try {
      final model = GenerativeModel(
        model: 'gemini-2.5-flash',
        apiKey: _apiKey,
      );

      final prompt = '''
You are a technical task validator. Your job is to verify if an uploaded file matches the requirements of a specific task.

Task Name: $taskName
Task Description: $taskDescription
Uploaded File Name: $fileName

Uploaded File Content:
---
$fileContent
---

Analyze the content and determine if it fulfills the task. 
Respond ONLY in JSON format with the following keys:
1. "isValid": boolean (true if it matches, false otherwise)
2. "reason": string (a brief explanation for the user)
3. "suggestions": list of strings (if not valid, what's missing?)

IMPORTANT: Respond strictly in English.

If the file content is empty or irrelevant, isValid should be false.
''';

      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);

      final text = response.text;
      if (text == null) {
        return {
          'isValid': false,
          'reason': 'AI could not analyze the file.',
          'suggestions': ['Please try again later.'],
        };
      }

      // Clean the JSON response
      String cleanJson = text;
      final jsonRegex = RegExp(r'\{.*\}', dotAll: true);
      final match = jsonRegex.firstMatch(text);
      if (match != null) {
        cleanJson = match.group(0)!;
      }

      final Map<String, dynamic> result = jsonDecode(cleanJson);

      return {
        'isValid': result['isValid'] ?? false,
        'reason': result['reason'] ?? 'Validation failed.',
        'suggestions': List<String>.from(result['suggestions'] ?? []),
      };
    } catch (e) {
      return {
        'isValid': false,
        'reason': 'Error connecting to AI: $e',
        'suggestions': ['Check your internet connection.'],
      };
    }
  }
}
