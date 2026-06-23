import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/financial_data_service.dart';

class BudgetingPage extends StatelessWidget {
  const BudgetingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Consumer<FinancialDataService>(
      builder: (context, finance, child) {
        if (finance.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final now = DateTime.now();
        final currentMonthTransactions = finance.transactions.where((t) => 
            t.type == 'Expense' && 
            t.date.month == now.month && 
            t.date.year == now.year
        ).toList();

        // Dynamically calculate spent per category
        final Map<String, double> categorySpent = {};
        for (var t in currentMonthTransactions) {
          categorySpent[t.category] = (categorySpent[t.category] ?? 0.0) + t.amount;
        }

        // Define limits (could be moved to a separate settings/service)
        final Map<String, double> categoryLimits = {
          'Food & Dining': 600.0,
          'Transportation': 200.0,
          'Entertainment': 250.0,
          'Groceries': 500.0,
        };

        if (categoryLimits.isEmpty) {
          return const Center(child: Text("No budget categories defined."));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Monthly Budgets",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ...categoryLimits.entries.map((entry) {
                final category = entry.key;
                final limit = entry.value;
                final spent = categorySpent[category] ?? 0.0;
                final percent = spent / limit;
                final bool isOver = percent > 1.0;
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.category, color: theme.colorScheme.primary),
                            const SizedBox(width: 12),
                            Text(category, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            const Spacer(),
                            Text(
                              "RM ${spent.toStringAsFixed(2)} / RM ${limit.toStringAsFixed(2)}",
                              style: TextStyle(
                                color: isOver ? theme.colorScheme.error : Colors.grey.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        LinearProgressIndicator(
                          value: percent > 1.0 ? 1.0 : percent,
                          backgroundColor: Colors.grey.shade200,
                          color: isOver ? theme.colorScheme.error : theme.colorScheme.secondary,
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}
