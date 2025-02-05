import 'dart:io';
import 'package:flutter/material.dart';

class UploadSection extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController controller;
  final Function(String) onTextChanged;
  final VoidCallback onUploadText;
  final VoidCallback onPickImage;
  final VoidCallback onUploadImage;
  final File? imageFile;
  final bool isLoading;

  const UploadSection({
    Key? key,
    required this.formKey,
    required this.controller,
    required this.onTextChanged,
    required this.onUploadText,
    required this.onPickImage,
    required this.onUploadImage,
    this.imageFile,
    required this.isLoading,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade100.withOpacity(0.5),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Upload Medical Report',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 16),
          Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Enter medical report text...',
                hintStyle: TextStyle(color: Colors.grey),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "Please enter the report text.";
                }
                return null;
              },
              onChanged: onTextChanged,
            ),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: isLoading ? null : onUploadText,
                  icon: Icon(Icons.upload_file),
                  label: Text('Analyze Report'),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: isLoading ? null : onPickImage,
                  icon: Icon(Icons.image),
                  label: Text('Pick Image'),
                ),
              ),
            ],
          ),
          if (imageFile != null) ...[
            SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.file(
                imageFile!,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: isLoading ? null : onUploadImage,
              icon: Icon(Icons.cloud_upload),
              label: Text('Analyze Image'),
            ),
          ],
        ],
      ),
    );
  }
}
