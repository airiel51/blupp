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
        final expenses = finance.transactions.where((t) => t.type == 'Expense').toList();
        final totalExpense = expenses.fold(0.0, (sum, t) => sum + t.amount);
        
        // Group expenses by category
        final Map<String, double> categoryMap = {};
        for (var t in expenses) {
          categoryMap[t.category] = (categoryMap[t.category] ?? 0.0) + t.amount;
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatCard("Total Income", "RM${finance.totalIncome.toStringAsFixed(2)}", Icons.arrow_upward, Colors.green),
              const SizedBox(height: 16),
              _buildStatCard("Total Expenses", "RM${totalExpense.toStringAsFixed(2)}", Icons.arrow_downward, Colors.red),
              const SizedBox(height: 24),
              const Text("Category Breakdown (Expenses)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ...categoryMap.entries.map((entry) {
                final percentage = totalExpense > 0 ? entry.value / totalExpense : 0.0;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(entry.key, style: const TextStyle(fontWeight: FontWeight.w500)),
                          Text("RM${entry.value.toStringAsFixed(2)} (${(percentage * 100).toInt()}%)"),
                        ],
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: percentage,
                        backgroundColor: Colors.grey[200],
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.pinkAccent),
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
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

