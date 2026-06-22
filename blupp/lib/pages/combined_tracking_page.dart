import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../services/financial_data_service.dart';

class CombinedTrackingPage extends StatefulWidget {
  const CombinedTrackingPage({super.key});

  @override
  State<CombinedTrackingPage> createState() => _CombinedTrackingPageState();
}

class _CombinedTrackingPageState extends State<CombinedTrackingPage> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  String _category = 'food';
  String _type = 'Expense';

  void _addTransaction(BuildContext context) {
    final title = _titleController.text;
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    
    if (title.isNotEmpty && amount > 0) {
      final transaction = Transaction(
        id: const Uuid().v4(),
        title: title,
        amount: amount,
        date: DateTime.now(),
        category: _category,
        type: _type,
      );
      Provider.of<FinancialDataService>(context, listen: false).addTransaction(transaction);
      _titleController.clear();
      _amountController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FinancialDataService>(
      builder: (context, finance, child) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(controller: _titleController, decoration: const InputDecoration(labelText: 'Title')),
              TextField(controller: _amountController, decoration: const InputDecoration(labelText: 'Amount'), keyboardType: TextInputType.number),
              DropdownButton<String>(
                value: _category,
                onChanged: (value) => setState(() => _category = value!),
                items: ['food', 'mobile', 'grocery', 'transport', 'leisure', 'study expense', 'emergency', 'income', 'job', 'parents money']
                    .map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              ),
              DropdownButton<String>(
                value: _type,
                onChanged: (value) => setState(() => _type = value!),
                items: ['Income', 'Expense'].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              ),
              ElevatedButton(onPressed: () => _addTransaction(context), child: const Text('Add Transaction')),
              Expanded(
                child: ListView.builder(
                  itemCount: finance.transactions.length,
                  itemBuilder: (context, index) {
                    final tx = finance.transactions[index];
                    return ListTile(title: Text(tx.title), subtitle: Text(tx.category), trailing: Text('${tx.type == 'Income' ? '+' : '-'}\$${tx.amount.toStringAsFixed(2)}'));
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
