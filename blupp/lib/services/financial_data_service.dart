import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Transaction {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final String category;
  final String type; // 'Income' or 'Expense'
  final String? bankAccountId;

  Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
    required this.type,
    this.bankAccountId,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'amount': amount,
        'date': date.toIso8601String(),
        'category': category,
        'type': type,
        'bank_account_id': bankAccountId,
      };

  factory Transaction.fromMap(Map<String, dynamic> map) => Transaction(
        id: map['id'].toString(),
        title: map['title'] as String,
        amount: (map['amount'] as num).toDouble(),
        date: DateTime.parse(map['date'] as String),
        category: map['category'] as String,
        type: map['type'] as String,
        bankAccountId: map['bank_account_id'] as String?,
      );
}

class BankAccount {
  final String? id;
  final String name;
  final double balance;
  final String category;

  BankAccount({this.id, required this.name, required this.balance, required this.category});
}

class Loan {
  final String? id;
  final String name;
  final double amount;
  final String type;
  bool isPaid;

  Loan({this.id, required this.name, required this.amount, required this.type, this.isPaid = false});
}

class PlannedExpense {
  final String id;
  final String title;
  final double amount;
  final DateTime date;

  PlannedExpense({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'amount': amount,
        'date': date.toIso8601String(),
      };

  factory PlannedExpense.fromMap(Map<String, dynamic> map) => PlannedExpense(
        id: map['id'].toString(),
        title: map['title'] as String,
        amount: (map['amount'] as num).toDouble(),
        date: DateTime.parse(map['date'] as String),
      );
}

class FinancialDataService extends ChangeNotifier {
  List<BankAccount> _bankAccounts = [];
  List<Loan> _loans = [];
  List<Transaction> _transactions = [];
  List<PlannedExpense> _plannedExpenses = [];
  final _supabase = Supabase.instance.client;

  FinancialDataService() {
    loadData();
  }

  List<BankAccount> get bankAccounts => _bankAccounts;
  List<Loan> get loans => _loans;
  List<Transaction> get transactions => _transactions;
  List<PlannedExpense> get plannedExpenses => _plannedExpenses;

  double get totalBankBalance => _bankAccounts.fold(0.0, (sum, acc) => sum + acc.balance);
  double get totalLoans => _loans.fold(0.0, (sum, loan) => sum + loan.amount);
  double get totalIncome => _transactions.where((t) => t.type == 'Income').fold(0.0, (sum, t) => sum + t.amount);
  double get totalExpense => _transactions.where((t) => t.type == 'Expense').fold(0.0, (sum, t) => sum + t.amount);
  
  double get netWorth => totalBankBalance - totalLoans - totalExpense;

  double get savingsBalance => _bankAccounts.where((a) => a.category == 'Savings').fold(0.0, (sum, acc) => sum + acc.balance);
  double get spendingBalance => (_bankAccounts.where((a) => a.category == 'Spending').fold(0.0, (sum, acc) => sum + acc.balance)) - totalExpense;
  double get investmentBalance => _bankAccounts.where((a) => a.category == 'Investment').fold(0.0, (sum, acc) => sum + acc.balance);

  Future<void> loadData() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      print('DEBUG: loadData - No user logged in');
      return;
    }

    print('DEBUG: loadData - Fetching for user: $userId');

    try {
      final bankRes = await _supabase.from('bank_accounts').select('*').eq('user_id', userId);
      _bankAccounts = (bankRes as List).map((m) => BankAccount(
        id: m['id'].toString(), 
        name: m['name'] as String, 
        balance: (m['balance'] as num? ?? 0).toDouble(),
        category: m['category'] as String? ?? 'Savings'
      )).toList();

      final loanRes = await _supabase.from('loans').select('*').eq('user_id', userId);
      _loans = (loanRes as List).map((m) => Loan(
        id: m['id'].toString(), 
        name: m['name'] as String, 
        amount: (m['balance'] as num? ?? 0).toDouble(), 
        type: m['type'] as String,
        isPaid: false
      )).toList();

      final transRes = await _supabase.from('transactions').select('*').eq('user_id', userId);
      _transactions = (transRes as List).map((m) => Transaction.fromMap(m)).toList();

      final plannedRes = await _supabase.from('planned_expenses').select('*').eq('user_id', userId);
      _plannedExpenses = (plannedRes as List).map((m) => PlannedExpense.fromMap(m)).toList();
      
    } catch (e) {
      print('DEBUG: loadData - Error: $e');
    }
    
    notifyListeners();
  }

  Future<void> addTransaction(Transaction transaction) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;
    
    final data = transaction.toMap();
    data.remove('id');
    
    await _supabase.from('transactions').insert({
      ...data,
      'user_id': userId,
    });

    // Update bank balance if it's an income transaction
    if (transaction.type == 'Income' && transaction.bankAccountId != null) {
      final bankAccount = _bankAccounts.firstWhere((a) => a.id == transaction.bankAccountId);
      final newBalance = bankAccount.balance + transaction.amount;
      await updateBankAccount(transaction.bankAccountId!, newBalance);
    }
    
    await loadData();
  }

  Future<void> addPlannedExpense(PlannedExpense expense) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;
    
    final data = expense.toMap();
    data.remove('id');
    
    await _supabase.from('planned_expenses').insert({
      ...data,
      'user_id': userId,
    });
    await loadData();
  }

  Future<bool> addBankAccount(String name, double balance, String category) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return false;
    
    try {
      await _supabase.from('bank_accounts').insert({
        'name': name, 
        'balance': balance,
        'category': category,
        'user_id': userId
      });
      await loadData();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> updateBankAccount(String id, double newBalance) async {
    try {
      await _supabase.from('bank_accounts').update({'balance': newBalance}).eq('id', id);
      await loadData();
    } catch (e) {
      print('DEBUG: updateBankAccount ERROR: $e');
    }
  }

  Future<void> updateLoan(String id, double newAmount) async {
    try {
      await _supabase.from('loans').update({'balance': newAmount}).eq('id', id);
      await loadData();
    } catch (e) {
      print('DEBUG: updateLoan ERROR: $e');
    }
  }

  Future<void> deleteBankAccount(String id) async {
    try {
      await _supabase.from('bank_accounts').delete().eq('id', id);
      await loadData();
    } catch (e) {
      print('DEBUG: deleteBankAccount ERROR: $e');
    }
  }

  Future<void> deleteLoan(String id) async {
    try {
      await _supabase.from('loans').delete().eq('id', id);
      await loadData();
    } catch (e) {
      print('DEBUG: deleteLoan ERROR: $e');
    }
  }

  Future<void> addLoan(String name, double amount, String type) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;
    
    try {
      await _supabase.from('loans').insert({
        'name': name, 
        'balance': amount,
        'type': type,
        'user_id': userId
      });
      await loadData();
    } catch (e) {
      print('DEBUG: addLoan ERROR: $e');
    }
  }
}
