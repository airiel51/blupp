import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';

class FinancialAdviceWidget extends StatelessWidget {
  const FinancialAdviceWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => _showAdviceDialog(context),
      icon: const Icon(Icons.auto_awesome, color: Colors.teal, size: 32),
    );
  }

  void _showAdviceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AdviceDialog(),
    );
  }
}

class AdviceDialog extends StatefulWidget {
  const AdviceDialog({super.key});

  @override
  State<AdviceDialog> createState() => _AdviceDialogState();
}

class _AdviceDialogState extends State<AdviceDialog> {
  String _advice = "Loading advice...";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAdvice();
  }

  Future<void> fetchAdvice() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        setState(() {
          _advice = "Please log in to get financial advice.";
          _isLoading = false;
        });
        return;
      }
    
      final url = Uri.parse('http://10.0.2.2:8000/api/advice/$userId');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _advice = data['advice'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _advice = "Server Error: ${response.statusCode}";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _advice = "Connection Error: ($e)";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("AI Financial Coach"),
      content: _isLoading
          ? const SizedBox(height: 100, child: Center(child: CircularProgressIndicator()))
          : SingleChildScrollView(child: Text(_advice)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        IconButton(icon: const Icon(Icons.refresh), onPressed: fetchAdvice),
      ],
    );
  }
}
