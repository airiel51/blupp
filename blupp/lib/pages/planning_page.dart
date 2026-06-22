import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../services/financial_data_service.dart';

class PlanningPage extends StatefulWidget {
  const PlanningPage({super.key});

  @override
  State<PlanningPage> createState() => _PlanningPageState();
}

class _PlanningPageState extends State<PlanningPage> {
  DateTime _selectedDate = DateTime.now();
  DateTime _focusedMonth = DateTime.now();

  List<PlannedExpense> _getExpensesForDay(List<PlannedExpense> expenses, DateTime day) {
    return expenses.where((e) => 
      e.date.year == day.year && 
      e.date.month == day.month && 
      e.date.day == day.day
    ).toList();
  }

  void _addPlannedExpense(BuildContext context, String title, double amount) {
    if (title.isNotEmpty && amount > 0) {
      final expense = PlannedExpense(
        id: const Uuid().v4(),
        title: title,
        amount: amount,
        date: _selectedDate,
      );
      Provider.of<FinancialDataService>(context, listen: false).addPlannedExpense(expense);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FinancialDataService>(
      builder: (context, finance, child) {
        final dayExpenses = _getExpensesForDay(finance.plannedExpenses, _selectedDate);
        return Scaffold(
          body: Column(
            children: [
              _buildCalendar(),
              Expanded(
                child: ListView.builder(
                  itemCount: dayExpenses.length,
                  itemBuilder: (context, index) {
                    final expense = dayExpenses[index];
                    return Card(
                      child: ListTile(
                        title: Text(expense.title),
                        trailing: Text('RM${expense.amount.toStringAsFixed(2)}'),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          floatingActionButton: Container(
            margin: const EdgeInsets.only(bottom: 50.0),
            child: FloatingActionButton(
              onPressed: () => _showAddDialog(context),
              child: const Icon(Icons.add),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCalendar() {
    final daysInMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0).day;
    final firstDayOfMonth = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final startWeekday = firstDayOfMonth.weekday % 7; // Sunday=0...Saturday=6
    
    final monthNames = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(icon: const Icon(Icons.chevron_left), onPressed: () => setState(() => _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1))),
            Text('${monthNames[_focusedMonth.month]} ${_focusedMonth.year}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            IconButton(icon: const Icon(Icons.chevron_right), onPressed: () => setState(() => _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1))),
          ],
        ),
        Row(
          children: ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa']
              .map((d) => Expanded(child: Center(child: Text(d, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))))).toList(),
        ),
        GridView.builder(
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7),
          itemCount: daysInMonth + startWeekday,
          itemBuilder: (context, index) {
            if (index < startWeekday) return const SizedBox();
            final day = index - startWeekday + 1;
            final date = DateTime(_focusedMonth.year, _focusedMonth.month, day);
            final isWeekend = date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
            final isSelected = date.year == _selectedDate.year && date.month == _selectedDate.month && date.day == _selectedDate.day;
            
            return GestureDetector(
              onTap: () => setState(() => _selectedDate = date),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? Colors.pink.withValues(alpha: 0.3) : null, 
                  borderRadius: BorderRadius.circular(8)
                ),
                child: Center(
                  child: Text('$day', style: TextStyle(color: isWeekend ? Colors.red : null, fontWeight: isSelected ? FontWeight.bold : null)),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  void _showAddDialog(BuildContext context) {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 16, right: 16, top: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Expense Name')),
            TextField(controller: amountController, decoration: const InputDecoration(labelText: 'Amount'), keyboardType: TextInputType.number),
            ElevatedButton(onPressed: () => _addPlannedExpense(context, titleController.text, double.tryParse(amountController.text) ?? 0.0), child: const Text('Save Plan')),
          ],
        ),
      ),
    );
  }
}
