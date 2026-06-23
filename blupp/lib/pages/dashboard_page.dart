import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/financial_data_service.dart';
import 'combined_tracking_page.dart';
import 'category_management_page.dart';
import '../widgets/financial_advice_widget.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Consumer<FinancialDataService>(
      builder: (context, finance, child) {
        if (finance.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final netWorth = finance.netWorth;

        return Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [theme.colorScheme.primary, theme.colorScheme.primary.withValues(alpha: 0.8)]),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    children: [
                      const Text('Total Net Worth', style: TextStyle(fontSize: 16, color: Colors.white70)),
                      Text('RM${netWorth.toStringAsFixed(2)}', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(child: _buildNavCard('Savings', 'RM${finance.savingsBalance.toStringAsFixed(2)}', Icons.savings, theme.colorScheme.tertiary, () => _navigateToPage(context, 'Savings'))),
                    const SizedBox(width: 16),
                    Expanded(child: _buildNavCard('Spending', 'RM${finance.spendingBalance.toStringAsFixed(2)}', Icons.account_balance_wallet, theme.colorScheme.secondary, () => _navigateToPage(context, 'Spending'))),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildNavCard('Investment', 'RM${finance.investmentBalance.toStringAsFixed(2)}', Icons.trending_up, theme.colorScheme.primary, () => _navigateToPage(context, 'Investment'))),
                    const SizedBox(width: 16),
                    Expanded(child: _buildNavCard('Total Spending', 'RM${finance.totalExpense.toStringAsFixed(2)}', Icons.list_alt, theme.colorScheme.error, () => _navigateToTracking(context))),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('All Bank Accounts', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () => _showAddAccountDialog(context, finance),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: finance.bankAccounts.isEmpty 
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.account_balance, size: 64, color: theme.colorScheme.primary.withValues(alpha: 0.5)),
                          const SizedBox(height: 16),
                          const Text("No bank accounts yet."),
                          const SizedBox(height: 16),
                          ElevatedButton(onPressed: () => _showAddAccountDialog(context, finance), child: const Text("Add First Account")),
                        ],
                      )
                    : ListView.builder(
                    itemCount: finance.bankAccounts.length,
                    itemBuilder: (context, index) {
                      final account = finance.bankAccounts[index];
                      return Dismissible(
                        key: Key(account.id!),
                        direction: DismissDirection.endToStart,
                        onDismissed: (direction) => finance.deleteBankAccount(account.id!),
                        background: Container(color: Colors.red, alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20), child: const Icon(Icons.delete, color: Colors.white)),
                        child: Card(
                          child: ListTile(
                            leading: Icon(Icons.account_balance, color: _getCategoryColor(account.category)),
                            title: Text(account.name),
                            subtitle: Text(account.category),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('RM${account.balance.toStringAsFixed(2)}'),
                                IconButton(icon: const Icon(Icons.edit), onPressed: () => _showEditAccountDialog(context, finance, account)),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEditAccountDialog(BuildContext context, FinancialDataService finance, BankAccount account) {
    final balanceController = TextEditingController(text: account.balance.toString());
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit ${account.name}'),
        content: TextField(controller: balanceController, decoration: const InputDecoration(labelText: 'Balance'), keyboardType: TextInputType.number),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final newBalance = double.tryParse(balanceController.text) ?? account.balance;
              finance.updateBankAccount(account.id!, newBalance);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showAddAccountDialog(BuildContext context, FinancialDataService finance) {
    final nameController = TextEditingController();
    final amountController = TextEditingController();
    String category = 'Savings';
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Bank Account'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name')),
              TextField(controller: amountController, decoration: const InputDecoration(labelText: 'Amount'), keyboardType: TextInputType.number),
              DropdownButton<String>(
                value: category,
                isExpanded: true,
                items: ['Savings', 'Spending', 'Investment'].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (val) => setState(() => category = val!),
              ),
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
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Savings': return Colors.green;
      case 'Spending': return Colors.orange;
      case 'Investment': return Colors.purple;
      default: return Colors.grey;
    }
  }

  Widget _buildNavCard(String title, String amount, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Icon(icon, size: 48, color: color),
              const SizedBox(height: 16),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(amount, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: color)),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToPage(BuildContext context, String title) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CategoryManagementPage(category: title)),
    );
  }

  void _navigateToTracking(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CombinedTrackingPage()),
    );
  }
}
