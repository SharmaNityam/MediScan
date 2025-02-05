import 'dart:convert';
import 'package:http/http.dart' as http;

class ImageAnalysisService {
  static const String _baseUrl =
      'https://us-central1-medical-21ff2.cloudfunctions.net';

  Future<Map<String, dynamic>> analyzeImage(String imageUrl) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/analyzeImageReportHttp'),
        body: jsonEncode({'imageUrl': imageUrl}),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to analyze image: ${response.body}');
      }
    } catch (e) {
      print('Error in image analysis: $e');
      rethrow;
    }
  }
}
