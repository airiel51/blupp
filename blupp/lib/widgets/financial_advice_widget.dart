import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FinancialAdviceWidget extends StatefulWidget {
  const FinancialAdviceWidget({super.key});

  @override
  State<FinancialAdviceWidget> createState() => _FinancialAdviceWidgetState();
}

class _FinancialAdviceWidgetState extends State<FinancialAdviceWidget> {
  String _advice = "Tap the refresh icon to ask your Gemini AI coach for advice.";
  bool _isLoading = false;
  
  // This is the exact User ID from the original main.dart
  final String userId = "0165f8cb-7deb-4dd3-b9b5-59db5e70c2f1"; 

  Future<void> fetchAdvice() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final url = Uri.parse('http://127.0.0.1:8000/api/advice/$userId');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _advice = data['advice'];
        });
      } else {
        setState(() {
          _advice = "Server Error: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        _advice = "Connection Error: Is your Python server running? ($e)";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.teal.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.teal.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: Colors.teal, size: 20),
              const SizedBox(width: 8),
              const Text(
                "AI Financial Coach",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              if (_isLoading)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.teal),
                )
              else ...[
                IconButton(
                  icon: const Icon(Icons.refresh, size: 18, color: Colors.teal),
                  onPressed: fetchAdvice,
                  tooltip: 'Refresh Advice',
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.chat_bubble_outline, size: 18, color: Colors.teal),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("AI Consultation feature coming soon!")),
                    );
                  },
                  tooltip: 'Start Consultation',
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _advice,
            style: const TextStyle(fontSize: 14, height: 1.4, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}
