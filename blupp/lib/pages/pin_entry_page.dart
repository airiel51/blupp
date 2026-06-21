import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class PinEntryPage extends StatefulWidget {
  const PinEntryPage({super.key});

  @override
  State<PinEntryPage> createState() => _PinEntryPageState();
}

class _PinEntryPageState extends State<PinEntryPage> {
  final TextEditingController _pinController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Enter PIN')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _pinController,
              keyboardType: TextInputType.number,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'PIN'),
            ),
            ElevatedButton(
              onPressed: () {
                Provider.of<AuthService>(context, listen: false)
                    .authenticatePin(_pinController.text);
              },
              child: const Text('Unlock'),
            ),
          ],
        ),
      ),
    );
  }
}
