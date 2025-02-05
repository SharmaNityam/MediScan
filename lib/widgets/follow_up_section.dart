import 'package:flutter/material.dart';
import '../utils/response_formatter.dart';

class FollowUpSection extends StatelessWidget {
  final TextEditingController followUpController;
  final String? followUpResponse;
  final bool isLoading;
  final VoidCallback onAskFollowUp;

  const FollowUpSection({
    Key? key,
    required this.followUpController,
    this.followUpResponse,
    required this.isLoading,
    required this.onAskFollowUp,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String formattedResponse = '';
    if (followUpResponse != null && followUpResponse!.isNotEmpty) {
      formattedResponse =
          ResponseFormatter.formatFollowUpResponse(followUpResponse!);
    }

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
            'Ask Follow-up Question',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 16),
          TextFormField(
            controller: followUpController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Enter your follow-up question...',
              hintStyle: TextStyle(color: Colors.grey),
              prefixIcon: Icon(Icons.help_outline, color: Colors.blue),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: isLoading ? null : onAskFollowUp,
            icon: Icon(Icons.send),
            label: Text('Ask Question'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          if (formattedResponse.isNotEmpty) ...[
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Answer:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    formattedResponse,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
