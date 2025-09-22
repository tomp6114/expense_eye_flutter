import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../services/database_service.dart';

class TransactionProvider with ChangeNotifier {
  List<Transaction> _transactions = [];
  final DatabaseService _databaseService = DatabaseService();
  bool _isLoading = false;

  // Getters
  List<Transaction> get transactions => _transactions;
  bool get isLoading => _isLoading;

  List<Transaction> get expenses => 
      _transactions.where((t) => t.type == TransactionType.expense).toList();

  List<Transaction> get income => 
      _transactions.where((t) => t.type == TransactionType.income).toList();

  double get totalExpenses => expenses.fold(0, (sum, t) => sum + t.amount);
  double get totalIncome => income.fold(0, (sum, t) => sum + t.amount);
  double get balance => totalIncome - totalExpenses;

  // Get transactions for current month
  List<Transaction> get thisMonthTransactions {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);
    
    return _transactions.where((t) =>
        t.date.isAfter(startOfMonth.subtract(const Duration(days: 1))) &&
        t.date.isBefore(endOfMonth.add(const Duration(days: 1)))
    ).toList();
  }

  double get thisMonthExpenses => thisMonthTransactions
      .where((t) => t.type == TransactionType.expense)
      .fold(0, (sum, t) => sum + t.amount);

  double get thisMonthIncome => thisMonthTransactions
      .where((t) => t.type == TransactionType.income)
      .fold(0, (sum, t) => sum + t.amount);

  // Methods
  Future<void> loadTransactions() async {
    _setLoading(true);
    try {
      _transactions = await _databaseService.getTransactions();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading transactions: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addTransaction(Transaction transaction) async {
    try {
      await _databaseService.insertTransaction(transaction);
      await loadTransactions();
    } catch (e) {
      debugPrint('Error adding transaction: $e');
      rethrow;
    }
  }

  Future<void> updateTransaction(Transaction transaction) async {
    try {
      await _databaseService.updateTransaction(transaction);
      await loadTransactions();
    } catch (e) {
      debugPrint('Error updating transaction: $e');
      rethrow;
    }
  }

  Future<void> deleteTransaction(int id) async {
    try {
      await _databaseService.deleteTransaction(id);
      await loadTransactions();
    } catch (e) {
      debugPrint('Error deleting transaction: $e');
      rethrow;
    }
  }

  // Filter methods
  List<Transaction> getTransactionsByCategory(int categoryId) {
    return _transactions.where((t) => t.categoryId == categoryId).toList();
  }

  List<Transaction> getTransactionsByDateRange(DateTime start, DateTime end) {
    return _transactions.where((t) => 
        t.date.isAfter(start.subtract(const Duration(days: 1))) &&
        t.date.isBefore(end.add(const Duration(days: 1)))
    ).toList();
  }

  List<Transaction> getTransactionsByType(TransactionType type) {
    return _transactions.where((t) => t.type == type).toList();
  }

  List<Transaction> searchTransactions(String query) {
    if (query.isEmpty) return _transactions;
    
    final lowercaseQuery = query.toLowerCase();
    return _transactions.where((t) =>
        t.description.toLowerCase().contains(lowercaseQuery)
    ).toList();
  }

  // Get transactions grouped by date
  Map<String, List<Transaction>> get transactionsGroupedByDate {
    final Map<String, List<Transaction>> grouped = {};
    
    for (final transaction in _transactions) {
      final dateKey = '${transaction.date.year}-${transaction.date.month.toString().padLeft(2, '0')}-${transaction.date.day.toString().padLeft(2, '0')}';
      
      if (grouped[dateKey] == null) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(transaction);
    }
    
    return grouped;
  }

  // Analytics helpers
  Map<int, double> getExpensesByCategory() {
    final Map<int, double> categoryExpenses = {};
    
    for (final expense in expenses) {
      categoryExpenses[expense.categoryId] = 
          (categoryExpenses[expense.categoryId] ?? 0) + expense.amount;
    }
    
    return categoryExpenses;
  }

  Map<String, double> getMonthlyExpenses() {
    final Map<String, double> monthlyExpenses = {};
    
    for (final expense in expenses) {
      final monthKey = '${expense.date.year}-${expense.date.month.toString().padLeft(2, '0')}';
      monthlyExpenses[monthKey] = (monthlyExpenses[monthKey] ?? 0) + expense.amount;
    }
    
    return monthlyExpenses;
  }

  // Get recent transactions (last 5)
  List<Transaction> get recentTransactions {
    final sortedTransactions = List<Transaction>.from(_transactions)
      ..sort((a, b) => b.date.compareTo(a.date));
    return sortedTransactions.take(5).toList();
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Clear all transactions (for testing/reset purposes)
  Future<void> clearAllTransactions() async {
    try {
      for (final transaction in _transactions) {
        await _databaseService.deleteTransaction(transaction.id!);
      }
      _transactions.clear();
      notifyListeners();
    } catch (e) {
      debugPrint('Error clearing transactions: $e');
      rethrow;
    }
  }
}