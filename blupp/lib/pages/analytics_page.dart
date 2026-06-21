import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/financial_data_service.dart';

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  String _getAiAdvice(FinancialDataService finance) {
    if (finance.spendingBalance > finance.totalFund * 0.5) {
      return "Your spending is quite high. Try to cut down on unnecessary expenses.";
    } else if (finance.savings < finance.totalFund * 0.2) {
      return "Consider increasing your savings rate for better financial security.";
    }
    return "Your finances look healthy! Keep up the good work.";
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FinancialDataService>(
      builder: (context, finance, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const Icon(Icons.psychology, size: 40, color: Colors.blue),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("AI Financial Advisor", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                            const SizedBox(height: 4),
                            Text(_getAiAdvice(finance), style: const TextStyle(fontSize: 14)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text("Spending Analytics", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildStatCard("Spending Balance", "\$${finance.spendingBalance.toStringAsFixed(2)}", Icons.trending_up, Colors.red),
              const SizedBox(height: 16),
              _buildStatCard("Total Savings", "\$${finance.savings.toStringAsFixed(2)}", Icons.account_balance_wallet, Colors.teal),
              const SizedBox(height: 24),
              const Text("Category Breakdown", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildSimpleChart(),
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

  Widget _buildSimpleChart() {
    return Column(
      children: [
        _buildChartBar("Housing", 0.4),
        _buildChartBar("Food", 0.25),
        _buildChartBar("Transport", 0.15),
        _buildChartBar("Others", 0.2),
      ],
    );
  }

  Widget _buildChartBar(String label, double percent) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label),
          const SizedBox(height: 4),
          Stack(
            children: [
              Container(
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              FractionallySizedBox(
                widthFactor: percent,
                child: Container(
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.teal,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
