import 'package:flutter/foundation.dart';
import 'database_helper.dart';

class Transaction {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final String category;
  final String type; // 'Income' or 'Expense'

  Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
    required this.type,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'amount': amount,
        'date': date.toIso8601String(),
        'category': category,
        'type': type,
      };

  factory Transaction.fromMap(Map<String, dynamic> map) => Transaction(
        id: map['id'],
        title: map['title'],
        amount: map['amount'],
        date: DateTime.parse(map['date']),
        category: map['category'],
        type: map['type'],
      );
}

class BankAccount {
  final int? id;
  final String name;
  final double balance;

  BankAccount({this.id, required this.name, required this.balance});
}

class Loan {
  final int? id;
  final String name;
  final double amount;
  final String type;

  Loan({this.id, required this.name, required this.amount, required this.type});
}

class FinancialDataService extends ChangeNotifier {
  List<BankAccount> _bankAccounts = [];
  List<Loan> _loans = [];
  List<Transaction> _transactions = [];

  FinancialDataService() {
    loadData();
  }

  List<BankAccount> get bankAccounts => _bankAccounts;
  List<Loan> get loans => _loans;
  List<Transaction> get transactions => _transactions;

  double get totalBankBalance => _bankAccounts.fold(0, (sum, acc) => sum + acc.balance);
  double get totalLoans => _loans.fold(0, (sum, loan) => sum + loan.amount);
  double get netWorth => totalBankBalance - totalLoans; // Add investment/savings if applicable

  Future<void> loadData() async {
    final db = await DatabaseHelper.instance.database;
    final bankMaps = await db.query('bank_accounts');
    print('DEBUG: loadData - Found ${bankMaps.length} bank accounts');
    _bankAccounts = bankMaps.map((m) => BankAccount(
      id: m['id'] as int, 
      name: m['name'] as String, 
      balance: (m['balance'] as num).toDouble()
    )).toList();
    
    final loanMaps = await db.query('loans');
    _loans = loanMaps.map((m) => Loan(
      id: m['id'] as int, 
      name: m['name'] as String, 
      amount: (m['amount'] as num).toDouble(), 
      type: m['type'] as String
    )).toList();

    final transMaps = await db.query('transactions');
    _transactions = transMaps.map((m) => Transaction(
      id: m['id'] as String,
      title: m['title'] as String,
      amount: (m['amount'] as num).toDouble(),
      date: DateTime.parse(m['date'] as String),
      category: m['category'] as String,
      type: m['type'] as String,
    )).toList();
    notifyListeners();
  }

  Future<void> addTransaction(Transaction transaction) async {
    final db = await DatabaseHelper.instance.database;
    await db.insert('transactions', transaction.toMap());
    await loadData();
  }

  Future<void> addBankAccount(String name, double balance) async {
    final db = await DatabaseHelper.instance.database;
    final id = await db.insert('bank_accounts', {'name': name, 'balance': balance});
    print('DEBUG: addBankAccount - Inserted account $name with ID $id');
    await loadData();
  }

  Future<void> addLoan(String name, double amount, String type) async {
    final db = await DatabaseHelper.instance.database;
    await db.insert('loans', {'name': name, 'amount': amount, 'type': type});
    await loadData();
  }
}
