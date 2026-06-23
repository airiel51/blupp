import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/financial_data_service.dart';

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<FinancialDataService>(
      builder: (context, finance, child) {
        if (finance.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final expenses = finance.transactions.where((t) => t.type == 'Expense').toList();
        final totalExpense = expenses.fold(0.0, (sum, t) => sum + t.amount);
        
        if (expenses.isEmpty) {
          return const Center(child: Text("No expense data available."));
        }
        
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
              
              // Pie Chart
              SizedBox(
                height: 250,
                child: PieChart(
                  PieChartData(
                    sections: categoryMap.entries.map((entry) {
                      final index = categoryMap.keys.toList().indexOf(entry.key);
                      final colors = [Colors.pink, Colors.blue, Colors.green, Colors.orange, Colors.purple, Colors.teal];
                      return PieChartSectionData(
                        value: entry.value,
                        title: '${(entry.value / totalExpense * 100).toInt()}%',
                        color: colors[index % colors.length],
                        radius: 50,
                        titleStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              ...categoryMap.entries.map((entry) {
                final percentage = totalExpense > 0 ? entry.value / totalExpense : 0.0;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      Container(width: 16, height: 16, color: Colors.pink),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(entry.key, style: const TextStyle(fontWeight: FontWeight.w500)),
                            Text("RM${entry.value.toStringAsFixed(2)} (${(percentage * 100).toInt()}%)"),
                          ],
                        ),
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
