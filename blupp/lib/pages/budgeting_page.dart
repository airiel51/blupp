import 'package:flutter/material.dart';

class BudgetingPage extends StatelessWidget {
  const BudgetingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final budgets = [
      {'category': 'Food', 'spent': 450.0, 'limit': 600.0, 'icon': Icons.fastfood},
      {'category': 'Transport', 'spent': 120.0, 'limit': 200.0, 'icon': Icons.directions_car},
      {'category': 'Entertainment', 'spent': 300.0, 'limit': 250.0, 'icon': Icons.movie},
      {'category': 'Shopping', 'spent': 200.0, 'limit': 500.0, 'icon': Icons.shopping_bag},
    ];

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
          ...budgets.map((budget) {
            final double percent = (budget['spent'] as double) / (budget['limit'] as double);
            final bool isOver = percent > 1.0;
            
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(budget['icon'] as IconData, color: Colors.teal),
                        const SizedBox(width: 12),
                        Text(
                          budget['category'] as String,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        Text(
                          "RM ${budget['spent']} / RM ${budget['limit']}",
                          style: TextStyle(
                            color: isOver ? Colors.red : Colors.grey.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: percent > 1.0 ? 1.0 : percent,
                      backgroundColor: Colors.grey.shade200,
                      color: isOver ? Colors.red : Colors.teal,
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
  }
}
