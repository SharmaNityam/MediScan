import 'dart:convert';

class ResponseFormatter {
  static Map<String, dynamic> parseAnalysis(String jsonString) {
    try {
      return json.decode(jsonString);
    } catch (e) {
      return {'error': 'Invalid response format'};
    }
  }

  static String formatAnalysisResponse(String jsonString) {
    try {
      final Map<String, dynamic> analysis = parseAnalysis(jsonString);
      StringBuffer formattedResponse = StringBuffer();

      if (analysis.containsKey('patient_details')) {
        formattedResponse.writeln('👤 Patient Details:');
        var patient = analysis['patient_details'];
        formattedResponse.writeln('• Name: ${patient['name']}');
        formattedResponse.writeln('• Age: ${patient['age']}');
        formattedResponse
            .writeln('• Gender: ${patient['gender'] ?? 'Not specified'}');
        formattedResponse.writeln();
      }

      if (analysis.containsKey('report_content')) {
        var report = analysis['report_content'];
        formattedResponse.writeln('📋 Report Content:');
        formattedResponse.writeln('• Date: ${report['date']}');
        formattedResponse
            .writeln('• Chief Complaint: ${report['chief_complaint']}');
        formattedResponse.writeln('• Diagnosis: ${report['diagnosis']}');

        if (report['vital_signs'] != null) {
          formattedResponse.writeln('\nVital Signs:');
          var vitals = report['vital_signs'];
          formattedResponse.writeln('• BP: ${vitals['blood_pressure']}');
          formattedResponse.writeln('• HR: ${vitals['heart_rate']}');
        }
        formattedResponse.writeln();
      }

      if (analysis.containsKey('model_insights')) {
        var insights = analysis['model_insights'];

        if (insights['summary'] != null) {
          formattedResponse.writeln('🔍 Summary:');
          formattedResponse.writeln(insights['summary']);
          formattedResponse.writeln();
        }

        if (insights['recommendations'] != null) {
          formattedResponse.writeln('💡 Recommendations:');
          for (var rec in insights['recommendations']) {
            formattedResponse.writeln('• $rec');
          }
          formattedResponse.writeln();
        }

        if (insights['questions_to_consider'] != null) {
          formattedResponse.writeln('❓ Questions to Consider:');
          for (var q in insights['questions_to_consider']) {
            formattedResponse.writeln('• $q');
          }
        }
      }

      return formattedResponse.toString();
    } catch (e) {
      return 'Error formatting response: $e';
    }
  }

  static String formatFollowUpResponse(String jsonString) {
    try {
      final Map<String, dynamic> response = json.decode(jsonString);

      if (response.containsKey('answer')) {
        String answer = response['answer'];
        answer = answer.replaceAll('**', '');
        answer = answer.replaceAll('*', '');
        answer = answer.replaceAll('*   ', '• ');
        answer = answer
            .split('\n')
            .map((line) => line.trim())
            .where((line) => line.isNotEmpty)
            .join('\n\n');

        return answer;
      }
      return 'No answer found in response';
    } catch (e) {
      try {
        final startIndex = jsonString.indexOf('"answer": "') + 10;
        final endIndex = jsonString.lastIndexOf('"');
        if (startIndex >= 0 && endIndex > startIndex) {
          String answer = jsonString.substring(startIndex, endIndex);

          answer = answer
              .replaceAll('**', '')
              .replaceAll('*', '')
              .replaceAll('*   ', '• ');

          return answer
              .split('\n')
              .map((line) => line.trim())
              .where((line) => line.isNotEmpty)
              .join('\n\n');
        }
      } catch (e2) {
        return 'Error formatting follow-up response: $e2';
      }
      return 'Error formatting follow-up response: $e';
    }
  }
}
