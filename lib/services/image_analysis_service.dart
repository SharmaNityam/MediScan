import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ImageAnalysisService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  final String apiKey =
      Platform.environment[''] ?? 'AIzaSyCwIeG4dNtzoGxg79mqApuxRp8B02Y_l-M';
  final String apiUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';

  Future<Map<String, dynamic>> analyzeImage(File imageFile) async {
    try {
      print('Uploading image to Firebase Storage...');
      final imageUrl = await _uploadImageToStorage(imageFile);

      print('Converting image to Base64...');
      final imageBytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(imageBytes);

      final body = {
        "contents": [
          {
            "parts": [
              {
                "text": '''
                Analyze the images and check if they are a medical document. 
                If they are a medical report, provide the following details:
                {
                  "patient_details": {
                    "name": "",
                    "age": "",
                    "gender": ""
                  },
                  "report_content": {
                    "date": "",
                    "chief_complaint": "",
                    "diagnosis": "",
                    "past_medical_history": "",
                    "vital_signs": {
                      "blood_pressure": "",
                      "heart_rate": ""
                    },
                    "tests": [
                      "",
                      ""
                    ],
                    "treatment_plan": {
                      "medications": [""],
                      "lifestyle_modifications": ""
                    },
                    "follow_up": ""
                  },
                  "doctor_details": {
                    "name": "",
                    "age": "",
                    "qualification": ""
                  },
                  "model_insights": {
                    "summary": "",
                    "recommendations": []
                  }
                }
                Always mention that you are just an AI model, and the patient should consult a doctor before taking any steps. 
                If some details are missing, mention they are unavailable but return other available details. 
                If the image is not a medical report, respond: "This doesn't appear to be a medical report. Please upload the correct image."
                If random text is provided, respond appropriately without forcing medical context.
                '''
              },
              {
                "inlineData": {"mimeType": "image/jpeg", "data": base64Image}
              }
            ]
          }
        ],
        "generationConfig": {
          "temperature": 0.75,
          "topK": 40,
          "topP": 0.95,
          "maxOutputTokens": 8192,
          "responseMimeType": 'application/json',
        }
      };

      print('Sending image to Gemini API...');
      final response = await http.post(
        Uri.parse('$apiUrl?key=$apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      print('API Response Status Code: ${response.statusCode}');
      print('API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final responseText =
            data['candidates'][0]['content']['parts'][0]['text'];

        if (responseText
            .contains("This doesn't appear to be a medical report")) {
          return {
            'isValidReport': false,
            'error':
                "This doesn't appear to be a medical report. Please upload the correct image.",
          };
        }

        final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(responseText);
        if (jsonMatch == null) {
          print('No valid JSON found in the response.');
          return {
            'isValidReport': false,
            'error': 'Unable to parse the report content. Please try again.',
          };
        }

        final cleanedJsonString = jsonMatch.group(0)!;
        final analysisResult = jsonDecode(cleanedJsonString);

        await _firestore.collection('medical_reports').add({
          'imageUrl': imageUrl,
          'analysis': analysisResult,
          'timestamp': FieldValue.serverTimestamp(),
        });

        return {
          'isValidReport': true,
          ...analysisResult,
        };
      } else {
        print('API Error: ${response.body}');
        return {
          'isValidReport': false,
          'error': 'Error from Gemini API. Please try again.',
        };
      }
    } catch (e) {
      print('Error during image analysis: $e');
      return {
        'isValidReport': false,
        'error':
            'An error occurred while analyzing the image. Please try again.',
      };
    }
  }

  Future<String> _uploadImageToStorage(File imageFile) async {
    try {
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final ref = _storage.ref().child('uploaded_images/$fileName.jpg');
      await ref.putFile(imageFile);
      return await ref.getDownloadURL();
    } catch (e) {
      throw Exception('Error uploading image to Firebase Storage: $e');
    }
  }
}
