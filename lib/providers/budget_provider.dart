import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../services/database_service.dart';

class BudgetProvider with ChangeNotifier {
  List<Budget> _budgets = [];
  final DatabaseService _databaseService = DatabaseService();
  bool _isLoading = false;

  // Getters
  List<Budget> get budgets => _budgets;
  bool get isLoading => _isLoading;

  List<Budget> get activeBudgets {
    final now = DateTime.now();
    return _budgets.where((budget) {
      switch (budget.period) {
        case BudgetPeriod.weekly:
          final weekStart = budget.startDate;
          final weekEnd = weekStart.add(const Duration(days: 7));
          return now.isAfter(weekStart.subtract(const Duration(days: 1))) && now.isBefore(weekEnd);
          
        case BudgetPeriod.monthly:
          final monthStart = budget.startDate;
          final monthEnd = DateTime(monthStart.year, monthStart.month + 1, 0);
          return now.isAfter(monthStart.subtract(const Duration(days: 1))) && 
                 now.isBefore(monthEnd.add(const Duration(days: 1)));
          
        case BudgetPeriod.yearly:
          final yearStart = budget.startDate;
          final yearEnd = DateTime(yearStart.year + 1, yearStart.month, yearStart.day);
          return now.isAfter(yearStart.subtract(const Duration(days: 1))) && now.isBefore(yearEnd);
      }
    }).toList();
  }

  int get totalBudgets => _budgets.length;
  int get activeBudgetsCount => activeBudgets.length;

  // Methods
  Future<void> loadBudgets() async {
    _setLoading(true);
    try {
      _budgets = await _databaseService.getBudgets();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading budgets: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addBudget(Budget budget) async {
    try {
      // Check if budget already exists for this category and period
      if (_budgetExistsForCategory(budget.categoryId, budget.period, budget.startDate)) {
        throw Exception('Budget already exists for this category and period');
      }

      final id = await _databaseService.insertBudget(budget);
      final newBudget = Budget(
        id: id,
        categoryId: budget.categoryId,
        amount: budget.amount,
        period: budget.period,
        startDate: budget.startDate,
      );
      _budgets.add(newBudget);
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding budget: $e');
      rethrow;
    }
  }

  Future<void> updateBudget(Budget budget) async {
    try {
      await _databaseService.updateBudget(budget);
      final index = _budgets.indexWhere((b) => b.id == budget.id);
      if (index != -1) {
        _budgets[index] = budget;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating budget: $e');
      rethrow;
    }
  }

  Future<void> deleteBudget(int id) async {
    try {
      await _databaseService.deleteBudget(id);
      _budgets.removeWhere((b) => b.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting budget: $e');
      rethrow;
    }
  }

  // Helper methods
  Budget? getBudgetById(int id) {
    try {
      return _budgets.firstWhere((b) => b.id == id);
    } catch (e) {
      debugPrint('Budget with id $id not found');
      return null;
    }
  }

  List<Budget> getBudgetsByCategory(int categoryId) {
    return _budgets.where((b) => b.categoryId == categoryId).toList();
  }

  List<Budget> getBudgetsByPeriod(BudgetPeriod period) {
    return _budgets.where((b) => b.period == period).toList();
  }

  Budget? getCurrentBudgetForCategory(int categoryId) {
    final categoryBudgets = getBudgetsByCategory(categoryId);
    final now = DateTime.now();
    
    for (final budget in categoryBudgets) {
      if (_isBudgetActive(budget, now)) {
        return budget;
      }
    }
    return null;
  }

  // Budget progress calculation
  double getBudgetProgress(Budget budget, List<Transaction> transactions) {
    final spent = _getSpentAmount(budget, transactions);
    return budget.amount > 0 ? spent / budget.amount : 0.0;
  }

  double getSpentAmount(Budget budget, List<Transaction> transactions) {
    return _getSpentAmount(budget, transactions);
  }

  double getRemainingAmount(Budget budget, List<Transaction> transactions) {
    final spent = _getSpentAmount(budget, transactions);
    return budget.amount - spent;
  }

  bool isBudgetExceeded(Budget budget, List<Transaction> transactions) {
    return _getSpentAmount(budget, transactions) > budget.amount;
  }

  // Budget alerts
  List<Budget> getBudgetsNearLimit(List<Transaction> transactions, {double threshold = 0.8}) {
    return activeBudgets.where((budget) {
      final progress = getBudgetProgress(budget, transactions);
      return progress >= threshold && progress <= 1.0;
    }).toList();
  }

  List<Budget> getExceededBudgets(List<Transaction> transactions) {
    return activeBudgets.where((budget) {
      return isBudgetExceeded(budget, transactions);
    }).toList();
  }

  // Statistics
  Map<String, dynamic> getBudgetStats(List<Transaction> transactions) {
    final active = activeBudgets;
    final exceeded = getExceededBudgets(transactions);
    final nearLimit = getBudgetsNearLimit(transactions);
    
    double totalBudgetAmount = 0;
    double totalSpent = 0;
    
    for (final budget in active) {
      totalBudgetAmount += budget.amount;
      totalSpent += _getSpentAmount(budget, transactions);
    }

    return {
      'totalBudgets': totalBudgets,
      'activeBudgets': active.length,
      'exceededBudgets': exceeded.length,
      'budgetsNearLimit': nearLimit.length,
      'totalBudgetAmount': totalBudgetAmount,
      'totalSpent': totalSpent,
      'remainingBudget': totalBudgetAmount - totalSpent,
      'overallProgress': totalBudgetAmount > 0 ? totalSpent / totalBudgetAmount : 0.0,
    };
  }

  // Utility methods
  DateTime getBudgetEndDate(Budget budget) {
    switch (budget.period) {
      case BudgetPeriod.weekly:
        return budget.startDate.add(const Duration(days: 7));
      case BudgetPeriod.monthly:
        return DateTime(budget.startDate.year, budget.startDate.month + 1, 0);
      case BudgetPeriod.yearly:
        return DateTime(budget.startDate.year + 1, budget.startDate.month, budget.startDate.day);
    }
  }

  int getDaysRemainingInBudget(Budget budget) {
    final endDate = getBudgetEndDate(budget);
    final now = DateTime.now();
    final daysRemaining = endDate.difference(now).inDays;
    return daysRemaining > 0 ? daysRemaining : 0;
  }

  String getBudgetPeriodDisplayName(BudgetPeriod period) {
    switch (period) {
      case BudgetPeriod.weekly:
        return 'Weekly';
      case BudgetPeriod.monthly:
        return 'Monthly';
      case BudgetPeriod.yearly:
        return 'Yearly';
    }
  }

  // Budget analysis methods
  List<Budget> getBudgetsOnTrack(List<Transaction> transactions) {
    return activeBudgets.where((budget) {
      final progress = getBudgetProgress(budget, transactions);
      return progress < 0.8; // Less than 80% spent
    }).toList();
  }

  double getAverageBudgetUtilization(List<Transaction> transactions) {
    if (activeBudgets.isEmpty) return 0.0;
    
    double totalUtilization = 0;
    for (final budget in activeBudgets) {
      totalUtilization += getBudgetProgress(budget, transactions);
    }
    
    return totalUtilization / activeBudgets.length;
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  bool _budgetExistsForCategory(int categoryId, BudgetPeriod period, DateTime startDate) {
    return _budgets.any((budget) {
      if (budget.categoryId != categoryId || budget.period != period) {
        return false;
      }

      // Check if the dates overlap based on the period
      switch (period) {
        case BudgetPeriod.weekly:
          final existingWeekEnd = budget.startDate.add(const Duration(days: 7));
          final newWeekEnd = startDate.add(const Duration(days: 7));
          return (startDate.isBefore(existingWeekEnd) && newWeekEnd.isAfter(budget.startDate));
          
        case BudgetPeriod.monthly:
          return budget.startDate.year == startDate.year && 
                 budget.startDate.month == startDate.month;
                 
        case BudgetPeriod.yearly:
          return budget.startDate.year == startDate.year;
      }
    });
  }

  bool _isBudgetActive(Budget budget, DateTime now) {
    switch (budget.period) {
      case BudgetPeriod.weekly:
        final weekEnd = budget.startDate.add(const Duration(days: 7));
        return now.isAfter(budget.startDate.subtract(const Duration(days: 1))) && now.isBefore(weekEnd);
        
      case BudgetPeriod.monthly:
        final monthEnd = DateTime(budget.startDate.year, budget.startDate.month + 1, 0);
        return now.isAfter(budget.startDate.subtract(const Duration(days: 1))) && 
               now.isBefore(monthEnd.add(const Duration(days: 1)));
        
      case BudgetPeriod.yearly:
        final yearEnd = DateTime(budget.startDate.year + 1, budget.startDate.month, budget.startDate.day);
        return now.isAfter(budget.startDate.subtract(const Duration(days: 1))) && now.isBefore(yearEnd);
    }
  }

  double _getSpentAmount(Budget budget, List<Transaction> transactions) {
    final budgetTransactions = _getBudgetTransactions(budget, transactions);
    return budgetTransactions.fold(0.0, (sum, transaction) => sum + transaction.amount);
  }

  List<Transaction> _getBudgetTransactions(Budget budget, List<Transaction> transactions) {
    final startDate = budget.startDate;
    final endDate = getBudgetEndDate(budget);
    
    return transactions.where((transaction) {
      return transaction.categoryId == budget.categoryId &&
             transaction.type == TransactionType.expense &&
             transaction.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
             transaction.date.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }

  // Quick setup methods
  Future<void> createDefaultBudgets(List<Category> categories) async {
    try {
      final expenseCategories = categories.where((c) => c.type == CategoryType.expense).toList();
      final now = DateTime.now();
      final monthStart = DateTime(now.year, now.month, 1);

      // Create default monthly budgets for major categories
      final defaultBudgetAmounts = {
        'Food & Dining': 15000.0,
        'Transportation': 8000.0,
        'Bills & Utilities': 5000.0,
        'Shopping': 5000.0,
        'Entertainment': 3000.0,
        'Healthcare': 3000.0,
        'Groceries': 10000.0,
        'Personal Care': 2000.0,
        'Fuel': 4000.0,
        'Rent': 20000.0,
      };

      for (final category in expenseCategories) {
        final defaultAmount = defaultBudgetAmounts[category.name];
        if (defaultAmount != null && !_budgetExistsForCategory(category.id!, BudgetPeriod.monthly, monthStart)) {
          final budget = Budget(
            categoryId: category.id!,
            amount: defaultAmount,
            period: BudgetPeriod.monthly,
            startDate: monthStart,
          );
          await addBudget(budget);
        }
      }
    } catch (e) {
      debugPrint('Error creating default budgets: $e');
      rethrow;
    }
  }

  // Advanced budget methods
  Future<void> duplicateBudgetForNextPeriod(Budget budget) async {
    try {
      DateTime nextPeriodStart;
      
      switch (budget.period) {
        case BudgetPeriod.weekly:
          nextPeriodStart = budget.startDate.add(const Duration(days: 7));
          break;
        case BudgetPeriod.monthly:
          nextPeriodStart = DateTime(budget.startDate.year, budget.startDate.month + 1, 1);
          break;
        case BudgetPeriod.yearly:
          nextPeriodStart = DateTime(budget.startDate.year + 1, budget.startDate.month, budget.startDate.day);
          break;
      }

      if (!_budgetExistsForCategory(budget.categoryId, budget.period, nextPeriodStart)) {
        final nextBudget = Budget(
          categoryId: budget.categoryId,
          amount: budget.amount,
          period: budget.period,
          startDate: nextPeriodStart,
        );
        await addBudget(nextBudget);
      }
    } catch (e) {
      debugPrint('Error duplicating budget: $e');
      rethrow;
    }
  }

  Future<void> adjustBudgetBasedOnSpending(Budget budget, List<Transaction> transactions, {double adjustmentFactor = 1.1}) async {
    try {
      final spent = _getSpentAmount(budget, transactions);
      final newAmount = spent * adjustmentFactor;
      
      final updatedBudget = Budget(
        id: budget.id,
        categoryId: budget.categoryId,
        amount: newAmount,
        period: budget.period,
        startDate: budget.startDate,
      );
      
      await updateBudget(updatedBudget);
    } catch (e) {
      debugPrint('Error adjusting budget: $e');
      rethrow;
    }
  }

  // Clear all budgets (for testing purposes)
  Future<void> clearAllBudgets() async {
    try {
      for (final budget in _budgets) {
        await _databaseService.deleteBudget(budget.id!);
      }
      _budgets.clear();
      notifyListeners();
    } catch (e) {
      debugPrint('Error clearing budgets: $e');
      rethrow;
    }
  }

  // Get budget recommendations based on spending patterns
  Map<String, double> getBudgetRecommendations(List<Transaction> recentTransactions, List<Category> categories) {
    final recommendations = <String, double>{};
    
    // Calculate average spending per category over the last 3 months
    final threeMonthsAgo = DateTime.now().subtract(const Duration(days: 90));
    final recentExpenses = recentTransactions.where((t) => 
        t.type == TransactionType.expense && t.date.isAfter(threeMonthsAgo)
    ).toList();

    final categorySpending = <int, List<double>>{};
    
    for (final expense in recentExpenses) {
      categorySpending.putIfAbsent(expense.categoryId, () => []).add(expense.amount);
    }

    for (final entry in categorySpending.entries) {
      final categoryId = entry.key;
      final amounts = entry.value;
      final category = categories.firstWhere(
        (c) => c.id == categoryId, 
        orElse: () => Category(
          name: 'Unknown', 
          icon: '📋', 
          color: 0xFF9E9E9E, 
          type: CategoryType.expense
        )
      );
      
      // Calculate average monthly spending and add 20% buffer
      final totalSpent = amounts.fold(0.0, (sum, amount) => sum + amount);
      const monthsOfData = 3;
      final averageMonthlySpending = totalSpent / monthsOfData;
      final recommendedBudget = averageMonthlySpending * 1.2; // 20% buffer
      
      if (recommendedBudget > 100) { // Only recommend if significant spending
        recommendations[category.name] = recommendedBudget;
      }
    }
    
    return recommendations;
  }

  // Budget validation methods
  bool isValidBudgetAmount(double amount) {
    return amount > 0 && amount <= 1000000; // Reasonable upper limit
  }

  bool isValidBudgetPeriod(DateTime startDate, BudgetPeriod period) {
    final now = DateTime.now();
    final maxFutureDate = now.add(const Duration(days: 365));
    
    return startDate.isAfter(now.subtract(const Duration(days: 365))) && 
           startDate.isBefore(maxFutureDate);
  }

  String? validateBudget(Budget budget, List<Category> categories) {
    // Check if category exists
    final category = categories.firstWhere(
      (c) => c.id == budget.categoryId,
      orElse: () => Category(name: '', icon: '', color: 0, type: CategoryType.expense),
    );
    
    if (category.name.isEmpty) {
      return 'Invalid category selected';
    }
    
    if (category.type != CategoryType.expense) {
      return 'Budgets can only be created for expense categories';
    }
    
    if (!isValidBudgetAmount(budget.amount)) {
      return 'Budget amount must be between ₹1 and ₹10,00,000';
    }
    
    if (!isValidBudgetPeriod(budget.startDate, budget.period)) {
      return 'Invalid budget period selected';
    }
    
    if (_budgetExistsForCategory(budget.categoryId, budget.period, budget.startDate)) {
      return 'Budget already exists for this category and period';
    }
    
    return null; // Valid budget
  }

  // Export budget data
  Map<String, dynamic> exportBudgetData() {
    return {
      'budgets': _budgets.map((b) => b.toMap()).toList(),
      'activeBudgetsCount': activeBudgetsCount,
      'totalBudgets': totalBudgets,
      'exportTimestamp': DateTime.now().toIso8601String(),
    };
  }
}