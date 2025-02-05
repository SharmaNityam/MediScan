import 'dart:convert';
import 'package:http/http.dart' as http;

class TextAnalysisService {
  static const String _baseUrl =
      'https://us-central1-medical-21ff2.cloudfunctions.net';

  Future<Map<String, dynamic>> analyzeText(String text) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/analyzeTextReportHttp'),
        body: jsonEncode({'text': text}),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to analyze text: ${response.body}');
      }
    } catch (e) {
      print('Error in text analysis: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> askFollowUpQuestion(
      String question, String context) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/askFollowUpQuestionHttp'),
        body: jsonEncode({
          'question': question,
          'context': context,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to ask follow-up question: ${response.body}');
      }
    } catch (e) {
      print('Error in follow-up question: $e');
      rethrow;
    }
  }
}
