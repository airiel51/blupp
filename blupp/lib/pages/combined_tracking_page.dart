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

  final Map<String, List<String>> _categoryMap = {
    'Income': ['Salary', 'Investment Return', 'Freelance', 'Dividends', 'Other'],
    'Expense': ['Food & Dining', 'Utilities', 'Transportation', 'Groceries', 'Entertainment', 'Education', 'Health', 'Emergency', 'Other'],
  };

  String? _selectedBankAccountId;

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
        bankAccountId: _type == 'Income' ? _selectedBankAccountId : null,
      );
      Provider.of<FinancialDataService>(context, listen: false).addTransaction(transaction);
      _titleController.clear();
      _amountController.clear();
      Navigator.pop(context);
    }
  }

  void _showAddTransactionDialog(BuildContext context) {
    // Reset defaults when opening dialog
    setState(() {
      _category = _categoryMap[_type]!.first;
      _selectedBankAccountId = null; // Reset bank selection
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Consumer<FinancialDataService>(
          builder: (context, finance, child) {
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 16, right: 16, top: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: _titleController, decoration: const InputDecoration(labelText: 'Title')),
                  TextField(controller: _amountController, decoration: const InputDecoration(labelText: 'Amount'), keyboardType: TextInputType.number),
                  DropdownButton<String>(
                    value: _type,
                    onChanged: (value) => setState(() {
                      _type = value!;
                      _category = _categoryMap[_type]!.first;
                      _selectedBankAccountId = null;
                      setModalState(() {}); // Refresh modal
                    }),
                    items: ['Income', 'Expense'].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  ),
                  DropdownButton<String>(
                    value: _category,
                    onChanged: (value) => setModalState(() => _category = value!),
                    items: _categoryMap[_type]!.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  ),
                  if (_type == 'Income')
                    DropdownButton<String>(
                      value: _selectedBankAccountId,
                      hint: const Text('Select Bank Account'),
                      onChanged: (value) => setModalState(() => _selectedBankAccountId = value!),
                      items: finance.bankAccounts.map((account) => DropdownMenuItem(
                        value: account.id,
                        child: Text(account.name),
                      )).toList(),
                    ),
                  ElevatedButton(onPressed: () => _addTransaction(context), child: const Text('Add Transaction')),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FinancialDataService>(
      builder: (context, finance, child) {
        return DefaultTabController(
          length: 2,
          child: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: _buildSummaryCard('Income', 'RM${finance.totalIncome.toStringAsFixed(2)}', Colors.green)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildSummaryCard('Expenses', 'RM${finance.totalExpense.toStringAsFixed(2)}', Colors.red)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const TabBar(
                    labelColor: Colors.pink,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: Colors.pink,
                    tabs: [
                      Tab(text: 'Income'),
                      Tab(text: 'Expense'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildTransactionList(finance.transactions.where((t) => t.type == 'Income')),
                        _buildTransactionList(finance.transactions.where((t) => t.type == 'Expense')),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
            floatingActionButton: Container(
              margin: const EdgeInsets.only(bottom: 50.0), // Lift it up
              child: FloatingActionButton(
                onPressed: () => _showAddTransactionDialog(context),
                child: const Icon(Icons.add),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTransactionList(Iterable<Transaction> transactions) {
    final list = transactions.toList();
    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (context, index) {
        final tx = list[index];
        return Card(
          child: ListTile(
            title: Text(tx.title),
            subtitle: Text(tx.category),
            trailing: Text(
              '${tx.type == 'Income' ? '+' : '-'}RM${tx.amount.toStringAsFixed(2)}',
              style: TextStyle(color: tx.type == 'Income' ? Colors.green : Colors.red),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummaryCard(String title, String amount, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(amount, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
