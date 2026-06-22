import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/financial_data_service.dart';

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  String _getAiAdvice(FinancialDataService finance) {
    // Replaced removed properties with new ones
    if (finance.totalBankBalance > 1000) { 
      return "Your bank balance is looking healthy!";
    } else if (finance.netWorth < 0) {
      return "Your net worth is negative. Consider reviewing your loans.";
    }
    return "Your finances look steady. Keep tracking!";
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FinancialDataService>(
      builder: (context, finance, child) {
        final totalExpense = finance.transactions.where((t) => t.type == 'Expense').fold(0.0, (sum, t) => sum + t.amount);
        final totalIncome = finance.transactions.where((t) => t.type == 'Income').fold(0.0, (sum, t) => sum + t.amount);
        final balanceLeft = (totalIncome - totalExpense);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatCard("Spending Balance Left", "\$${balanceLeft.toStringAsFixed(2)}", Icons.trending_up, Colors.red),
              const SizedBox(height: 16),
              _buildStatCard("Total Savings Left", "\$${balanceLeft.toStringAsFixed(2)}", Icons.account_balance_wallet, Colors.teal),
              const SizedBox(height: 24),
              const Text("Category Breakdown", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ...finance.transactions.where((t) => t.type == 'Expense').map((t) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                child: ListTile(leading: const Icon(Icons.category), title: Text(t.category), trailing: Text('\$${t.amount.toStringAsFixed(2)}')),
              )),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.1),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.grey)),
                Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

