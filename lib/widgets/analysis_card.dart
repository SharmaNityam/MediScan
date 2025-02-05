import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/response_formatter.dart';

class AnalysisCard extends StatelessWidget {
  final String? latestAnalysis;

  const AnalysisCard({
    Key? key,
    this.latestAnalysis,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String formattedAnalysis = '';
    if (latestAnalysis != null && latestAnalysis!.isNotEmpty) {
      formattedAnalysis =
          ResponseFormatter.formatAnalysisResponse(latestAnalysis!);
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Analysis Result',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              if (formattedAnalysis.isNotEmpty)
                IconButton(
                  icon: Icon(Icons.copy, color: Colors.blue),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: formattedAnalysis));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Analysis copied to clipboard')),
                    );
                  },
                ),
            ],
          ),
          SizedBox(height: 16),
          Container(
            constraints: BoxConstraints(maxHeight: 400),
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(15),
            ),
            child: formattedAnalysis.isNotEmpty
                ? SingleChildScrollView(
                    child: Text(
                      formattedAnalysis,
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.5,
                        color: Colors.black87,
                      ),
                    ),
                  )
                : Center(
                    child: Text(
                      'Waiting for analysis',
                      style: TextStyle(
                        color: Colors.blue.shade300,
                        fontSize: 16,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
