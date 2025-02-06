import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

import '../services/text_analysis_service.dart';
import '../services/image_analysis_service.dart';
import '../widgets/analysis_card.dart';
import '../widgets/upload_section.dart';
import '../widgets/follow_up_section.dart';

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
  String? _contextForFollowUp;
  final TextEditingController _followUpController = TextEditingController();
  String? _followUpResponse;

  final TextAnalysisService _textAnalysisService = TextAnalysisService();
  final ImageAnalysisService _imageAnalysisService = ImageAnalysisService();

  Future<void> uploadText() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _latestAnalysis = null;
      _followUpResponse = null;
    });

    try {
      if (FirebaseAuth.instance.currentUser == null) {
        await FirebaseAuth.instance.signInAnonymously();
      }

      DocumentReference docRef = await _firestore.collection('texts').add({
        'text': _textInput,
        'timestamp': FieldValue.serverTimestamp(),
      });

      final analysisResult = await _textAnalysisService.analyzeText(_textInput);

      await _firestore.collection('texts').doc(docRef.id).update({
        'analysis': analysisResult,
      });

      setState(() {
        _latestAnalysis =
            const JsonEncoder.withIndent('  ').convert(analysisResult);
        _contextForFollowUp = jsonEncode(analysisResult);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Text uploaded and analysis completed!')),
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

  Future<void> uploadImage() async {
  if (_imageFile == null) return;

  setState(() {
    _isLoading = true;
    _latestAnalysis = null;
    _followUpResponse = null;
  });

  try {
    final ImageAnalysisService analysisService = ImageAnalysisService();
    final analysisResult = await analysisService.analyzeImage(_imageFile!);

    if (analysisResult['isValidReport']) {
      setState(() {
        _latestAnalysis = const JsonEncoder.withIndent('  ').convert(analysisResult);
        _contextForFollowUp = jsonEncode(analysisResult);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image analyzed successfully!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(analysisResult['error'] ?? 'Invalid medical report')),
      );
    }
  } catch (e) {
    print("Error analyzing image: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Error analyzing image. Please try again.')),
    );
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
}

  Future<void> askFollowUpQuestion() async {
    if (_followUpController.text.isEmpty || _contextForFollowUp == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _textAnalysisService.askFollowUpQuestion(
          _followUpController.text, _contextForFollowUp!);

      setState(() {
        _followUpResponse = response['answer'];
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Follow-up question answered!')),
      );
    } catch (e) {
      print("Error asking follow-up question: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Error asking follow-up question. Please try again.')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _followUpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF4F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          'MediScan',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w700,
            fontSize: 24,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(Icons.help_outline, color: Colors.black54),
            onPressed: () {
              // Future: Add help/info dialog
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              UploadSection(
                formKey: _formKey,
                controller: _controller,
                onTextChanged: (value) => _textInput = value,
                onUploadText: uploadText,
                onPickImage: _pickImage,
                onUploadImage: uploadImage,
                imageFile: _imageFile,
                isLoading: _isLoading,
              ),
              SizedBox(height: 16),
              AnalysisCard(
                latestAnalysis: _latestAnalysis,
              ),
              SizedBox(height: 16),
              FollowUpSection(
                followUpController: _followUpController,
                followUpResponse: _followUpResponse,
                isLoading: _isLoading,
                onAskFollowUp: askFollowUpQuestion,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
