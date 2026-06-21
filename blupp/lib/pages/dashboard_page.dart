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
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Total Net Worth', style: TextStyle(fontSize: 16, color: Colors.grey), textAlign: TextAlign.center),
              Text('\$${finance.totalFund.toStringAsFixed(2)}', style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.pink), textAlign: TextAlign.center),
              const SizedBox(height: 32),
              _buildCategoryCard(context, 'Spending Balance', finance.spendingBalance, (val) => finance.updateCategories(val, finance.investment, finance.savings)),
              _buildCategoryCard(context, 'Investment', finance.investment, (val) => finance.updateCategories(finance.spendingBalance, val, finance.savings)),
              _buildCategoryCard(context, 'Savings', finance.savings, (val) => finance.updateCategories(finance.spendingBalance, finance.investment, val)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryCard(BuildContext context, String title, double value, Function(double) onEdit) {
    return Card(
      child: ListTile(
        title: Text(title),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('\$${value.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
            IconButton(icon: const Icon(Icons.edit), onPressed: () => _editBalance(context, title, value, onEdit)),
          ],
        ),
      ),
    );
  }
}
