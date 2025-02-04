import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

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
  File? _imageFile;

  Future<void> uploadText() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _latestAnalysis = null;
    });

    try {
      if (FirebaseAuth.instance.currentUser == null) {
        await FirebaseAuth.instance.signInAnonymously();
      }

      DocumentReference docRef = await _firestore.collection('texts').add({
        'text': _textInput,
        'timestamp': FieldValue.serverTimestamp(),
      });

      listenForAnalysisResults(docRef.id,
          isImage: false); 
      await analyzeText(docRef.id, _textInput);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Text uploaded and analysis started!')),
      );
    } catch (e) {
      print("Error uploading text: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Error uploading text. Please try again.')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> uploadImage() async {
    if (_imageFile == null) return;

    setState(() {
      _isLoading = true;
      _latestAnalysis = null;
    });

    try {
      if (FirebaseAuth.instance.currentUser == null) {
        await FirebaseAuth.instance.signInAnonymously();
      }

      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference storageReference =
          FirebaseStorage.instance.ref().child('images/$fileName.jpg');
      await storageReference.putFile(_imageFile!);

      String gsLink =
          'gs://${storageReference.bucket}/${storageReference.fullPath}';

      DocumentReference docRef = await _firestore.collection('images').add({
        'imageUrl': gsLink, 
        'timestamp': FieldValue.serverTimestamp(),
      });

      listenForAnalysisResults(docRef.id, isImage: true);
      await analyzeImage(docRef.id, gsLink);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image uploaded and analysis started!')),
      );
    } catch (e) {
      print("Error uploading image: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Error uploading image. Please try again.')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> analyzeText(String docId, String text) async {
    try {
      final response = await http.post(
        Uri.parse(
            ''),//enter the firebase function link here
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
        const SnackBar(
            content: Text('Error analyzing text. Please try again.')),
      );
    }
  }

  Future<void> analyzeImage(String docId, String imageUrl) async {
    try {
      final response = await http.post(
        Uri.parse(
            ''),//enter your firebase function link here
        body: jsonEncode({'imageUrl': imageUrl}),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        try {
          Map<String, dynamic> analysisData = jsonDecode(response.body);
          await _firestore.collection('images').doc(docId).update({
            'analysis': analysisData,
          });
        } catch (e) {
          print("Error parsing image analysis response: $e");
          await _firestore.collection('images').doc(docId).update({
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
      print("Error analyzing image: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Error analyzing image. Please try again.')),
      );
    }
  }

  void listenForAnalysisResults(String docId, {bool isImage = false}) {
    final collection = isImage
        ? _firestore.collection('images')
        : _firestore.collection('texts');
    collection.doc(docId).snapshots().listen((snapshot) {
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

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          'MediScan',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Upload Medical Report',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 16),
                      Form(
                        key: _formKey,
                        child: TextFormField(
                          controller: _controller,
                          maxLines: 5,
                          decoration: InputDecoration(
                            hintText: 'Enter medical report text',
                            hintStyle: TextStyle(color: Colors.grey),
                            fillColor: Colors.grey[100],
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
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
                        ),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _isLoading ? null : uploadText,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[600],
                          foregroundColor: Colors.white,
                          minimumSize: Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : Text(
                                'Analyze Report',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _pickImage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[600],
                          foregroundColor: Colors.white,
                          minimumSize: Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Upload Image',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      _imageFile != null
                          ? Image.file(
                              _imageFile!,
                              height: 100,
                              width: 100,
                              fit: BoxFit.cover,
                            )
                          : Container(),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _isLoading ? null : uploadImage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[600],
                          foregroundColor: Colors.white,
                          minimumSize: Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : Text(
                                'Analyze Image',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Analysis Result',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 16),
                        Expanded(
                          child: _latestAnalysis != null
                              ? Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: EdgeInsets.all(12),
                                  child: SingleChildScrollView(
                                    child: Text(
                                      _latestAnalysis!,
                                      style: TextStyle(
                                        fontFamily: 'monospace',
                                        fontSize: 14,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                )
                              : Center(
                                  child: Text(
                                    'Waiting for analysis',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
