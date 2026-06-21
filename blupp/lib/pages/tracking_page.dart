import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../services/financial_data_service.dart';

class TrackingPage extends StatelessWidget {
  const TrackingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<FinancialDataService>(
        builder: (context, finance, child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "Recent Transactions",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: finance.transactions.length,
                  itemBuilder: (context, index) {
                    final transaction = finance.transactions[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: transaction.category == 'Income' ? Colors.green.shade100 : Colors.red.shade100,
                        child: Icon(transaction.category == 'Income' ? Icons.add : Icons.remove, color: transaction.category == 'Income' ? Colors.green : Colors.red),
                      ),
                      title: Text(transaction.title),
                      subtitle: Text("${transaction.date.toLocal()}".split(' ')[0]),
                      trailing: Text(
                        "${transaction.category == 'Income' ? '+' : '-'} \$${transaction.amount.toStringAsFixed(2)}",
                        style: TextStyle(
                          color: transaction.category == 'Income' ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addTransaction(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _addTransaction(BuildContext context) {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    String category = 'Expense';

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
                items: ['Income', 'Expense'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (val) => setState(() => category = val!),
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
