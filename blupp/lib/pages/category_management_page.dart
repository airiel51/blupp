import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/financial_data_service.dart';

class CategoryManagementPage extends StatelessWidget {
  final String category;

  const CategoryManagementPage({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Manage $category')),
      body: Consumer<FinancialDataService>(
        builder: (context, finance, child) {
          final accounts = finance.bankAccounts.where((a) => a.category == category).toList();
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: accounts.length,
                  itemBuilder: (context, index) {
                    final account = accounts[index];
                    return ListTile(
                      title: Text(account.name),
                      trailing: Text('RM${account.balance.toStringAsFixed(2)}'),
                      onLongPress: () => finance.deleteBankAccount(account.id!),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () => _showAddAccountDialog(context, finance),
                  child: Text('Add Account to $category'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showAddAccountDialog(BuildContext context, FinancialDataService finance) {
    final nameController = TextEditingController();
    final amountController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add $category Account'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name')),
            TextField(controller: amountController, decoration: const InputDecoration(labelText: 'Amount'), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final amount = double.tryParse(amountController.text) ?? 0.0;
              if (nameController.text.isNotEmpty && amount > 0) {
                final success = await finance.addBankAccount(nameController.text, amount, category);
                if (success) {
                  if (context.mounted) Navigator.pop(context);
                } else {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Failed to add bank account')),
                    );
                  }
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
