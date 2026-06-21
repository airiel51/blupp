import 'package:flutter/foundation.dart';

class Transaction {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final String category; // 'Income' or 'Expense'

  Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
  });
}

class FinancialDataService extends ChangeNotifier {
  double _totalFund = 1000.0;
  double _spendingBalance = 500.0;
  double _investment = 300.0;
  double _savings = 200.0;
  final List<Transaction> _transactions = [];

  double get totalFund => _totalFund;
  double get spendingBalance => _spendingBalance;
  double get investment => _investment;
  double get savings => _savings;
  List<Transaction> get transactions => _transactions;

  void adjustTotalFund(double newAmount) {
    _totalFund = newAmount;
    notifyListeners();
  }

  void addTransaction(Transaction transaction) {
    _transactions.add(transaction);
    if (transaction.category == 'Income') {
      _totalFund += transaction.amount;
    } else {
      _totalFund -= transaction.amount;
    }
    notifyListeners();
  }

  void updateCategories(double spending, double investment, double savings) {
    _spendingBalance = spending;
    _investment = investment;
    _savings = savings;
    notifyListeners();
  }
}
