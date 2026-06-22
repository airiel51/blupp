import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/financial_data_service.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  Future<void> _editBalance(BuildContext context, String title, double currentValue, Function(double) onSave) async {
    final TextEditingController controller = TextEditingController(text: currentValue.toString());
    
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Adjust $title'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Amount'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final newValue = double.tryParse(controller.text) ?? currentValue;
              onSave(newValue);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FinancialDataService>(
      builder: (context, finance, child) {
        return Scaffold(
          body: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              const Text('Total Net Worth', style: TextStyle(fontSize: 16, color: Colors.grey), textAlign: TextAlign.center),
              Text('\$${finance.netWorth.toStringAsFixed(2)}', style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.pink), textAlign: TextAlign.center),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Bank Accounts', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () => finance.loadData(),
                  ),
                ],
              ),
              if (finance.bankAccounts.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text('No bank accounts added yet.', style: TextStyle(color: Colors.grey)),
                ),
              ...finance.bankAccounts.map((account) => Card(
                child: ListTile(
                  leading: const Icon(Icons.account_balance, color: Colors.blue),
                  title: Text(account.name),
                  trailing: Text('\$${account.balance.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              )),
              const SizedBox(height: 24),
              const Text('Loans', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              if (finance.loans.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text('No loans added yet.', style: TextStyle(color: Colors.grey)),
                ),
              ...finance.loans.map((loan) => Card(
                child: ListTile(
                  leading: const Icon(Icons.money_off, color: Colors.red),
                  title: Text(loan.name),
                  subtitle: Text(loan.type),
                  trailing: Text('-\$${loan.amount.toStringAsFixed(2)}', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                ),
              )),
            ],
          ),
          floatingActionButton: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FloatingActionButton.extended(
                heroTag: 'addBank',
                onPressed: () => _addEntry(context, 'Bank Account', (name, amount, val) => finance.addBankAccount(name, amount)),
                label: const Text('Bank'),
                icon: const Icon(Icons.add),
              ),
              const SizedBox(height: 12),
              FloatingActionButton.extended(
                heroTag: 'addLoan',
                onPressed: () => _addEntry(context, 'Loan', (name, amount, val) => finance.addLoan(name, amount, val!)),
                label: const Text('Loan'),
                icon: const Icon(Icons.remove),
                backgroundColor: Colors.red.shade100,
                foregroundColor: Colors.red,
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _addEntry(BuildContext context, String title, Future<void> Function(String, double, String?) onSave) async {
    final nameController = TextEditingController();
    final amountController = TextEditingController();
    String? entryType = title == 'Loan' ? 'Personal' : null;
    
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Add $title'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name (e.g. Maybank, ShopeePay)')),
              TextField(controller: amountController, decoration: const InputDecoration(labelText: 'Amount'), keyboardType: TextInputType.number),
              if (title == 'Loan')
                DropdownButton<String>(
                  isExpanded: true,
                  value: entryType,
                  items: ['Personal', 'ShopeePay', 'Transport'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (val) => setState(() => entryType = val),
                ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                final amount = double.tryParse(amountController.text) ?? 0.0;
                if (nameController.text.isNotEmpty && amount > 0) {
                  print('DEBUG: Saving entry $title');
                  await onSave(nameController.text, amount, entryType);
                  print('DEBUG: Saved entry $title');
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('$title "${nameController.text}" added!')),
                    );
                    Navigator.pop(context);
                  }
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }


}
