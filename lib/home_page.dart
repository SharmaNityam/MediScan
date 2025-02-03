import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _formKey = GlobalKey<FormState>();
  String _textInput = "";
  bool _isLoading = false;
  String? _latestAnalysis;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _controller = TextEditingController();

  // Upload Text to Firestore and Analyze
  Future<void> uploadText() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _latestAnalysis = null;
    });

    try {
      // Ensure user is authenticated before uploading text
      if (FirebaseAuth.instance.currentUser == null) {
        await FirebaseAuth.instance.signInAnonymously();
      }

      // Add text to Firestore
      DocumentReference docRef = await _firestore.collection('texts').add({
        'text': _textInput,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Start listening for analysis results
      listenForAnalysisResults(docRef.id);

      // Call HTTP endpoint for text analysis
      await analyzeText(docRef.id, _textInput);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Text uploaded and analysis started!')),
      );
    } catch (e) {
      print("Error uploading text: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading text. Please try again.')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Analyze Text via Firebase Genkit
  Future<void> analyzeText(String docId, String text) async {
    try {
      final response = await http.post(
        Uri.parse(
            'ENTER_LINK_HERE'),
        body: jsonEncode({'text': text}),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        try {
          Map<String, dynamic> analysisData = jsonDecode(response.body);
          await _firestore.collection('texts').doc(docId).update({
            'analysis': analysisData,
          });
        } catch (e) {
          print("Error parsing text analysis response: $e");
          await _firestore.collection('texts').doc(docId).update({
            'analysis': {
              'error': 'Failed to parse analysis',
              'rawResponse': response.body,
            },
          });
        }
      } else {
        print("HTTP Error: ${response.statusCode}, Body: ${response.body}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Server error: ${response.statusCode}. Please try again.')),
        );
      }
    } catch (e) {
      print("Error analyzing text: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error analyzing text. Please try again.')),
      );
    }
  }

  // Listen for Firestore updates and display analysis results in real time
  void listenForAnalysisResults(String docId) {
    _firestore.collection('texts').doc(docId).snapshots().listen((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        final data = snapshot.data();
        if (data!.containsKey('analysis')) {
          setState(() {
            _latestAnalysis =
                const JsonEncoder.withIndent('  ').convert(data['analysis']);
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildTextInput() {
    return TextFormField(
      controller: _controller,
      maxLines: 5,
      decoration: InputDecoration(
        labelText: "Enter Medical Report Text",
        hintText: "Type or paste the report here...",
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return "Please enter the report text.";
        }
        return null;
      },
      onChanged: (value) {
        _textInput = value;
      },
    );
  }

  Widget _buildAnalysisDisplay() {
    return _latestAnalysis != null
        ? Container(
            padding: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: SingleChildScrollView(
              child: Text(
                _latestAnalysis!,
                style: TextStyle(fontSize: 16, fontFamily: 'Courier'),
              ),
            ),
          )
        : Center(
            child: Text(
              "Waiting for analysis result...",
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Medical Report Analyzer"),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Form(
                key: _formKey,
                child: _buildTextInput(),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : uploadText,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        )
                      : Text(
                          "Upload & Analyze Text",
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),
              SizedBox(height: 30),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Analysis Result:",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 10),
              Container(
                height: 300,
                child: _buildAnalysisDisplay(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
