import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../services/financial_data_service.dart';

class TrackingPage extends StatelessWidget {
  const TrackingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: const TabBar(tabs: [Tab(text: 'Expense'), Tab(text: 'Income')]),
        body: Consumer<FinancialDataService>(
          builder: (context, finance, child) {
            return TabBarView(
              children: [
                _buildTransactionList(finance.transactions.where((t) => t.type == 'Expense').toList()),
                _buildTransactionList(finance.transactions.where((t) => t.type == 'Income').toList()),
              ],
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _addTransaction(context),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildTransactionList(List<Transaction> transactions) {
    return ListView.builder(
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final t = transactions[index];
        return ListTile(title: Text(t.title), subtitle: Text(t.category), trailing: Text('\$${t.amount.toStringAsFixed(2)}'));
      },
    );
  }

  void _addTransaction(BuildContext context) {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    String category = 'food';
    String type = 'Expense';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Transaction'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Title')),
              TextField(controller: amountController, decoration: const InputDecoration(labelText: 'Amount'), keyboardType: TextInputType.number),
              DropdownButton<String>(
                value: category,
                items: ['food', 'mobile', 'grocery', 'transport', 'leisure', 'study expense', 'emergency', 'income', 'job', 'parents money']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (val) => setState(() => category = val!),
              ),
              DropdownButton<String>(
                value: type,
                items: ['Income', 'Expense'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (val) => setState(() => type = val!),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                final transaction = Transaction(
                  id: const Uuid().v4(),
                  title: titleController.text,
                  amount: double.parse(amountController.text),
                  date: DateTime.now(),
                  category: category,
                  type: type,
                );
                Provider.of<FinancialDataService>(context, listen: false).addTransaction(transaction);
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}

