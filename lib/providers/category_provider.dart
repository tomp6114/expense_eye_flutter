import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../services/database_service.dart';

class CategoryProvider with ChangeNotifier {
  List<Category> _categories = [];
  final DatabaseService _databaseService = DatabaseService();
  bool _isLoading = false;

  // Getters
  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;
  
  List<Category> get expenseCategories => 
      _categories.where((c) => c.type == CategoryType.expense).toList();
      
  List<Category> get incomeCategories => 
      _categories.where((c) => c.type == CategoryType.income).toList();

  // Get categories count
  int get totalCategories => _categories.length;
  int get expenseCategoriesCount => expenseCategories.length;
  int get incomeCategoriesCount => incomeCategories.length;

  // Methods
  Future<void> loadCategories() async {
    _setLoading(true);
    try {
      _categories = await _databaseService.getCategories();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading categories: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addCategory(Category category) async {
    try {
      final id = await _databaseService.insertCategory(category);
      // Add the new category with the returned ID to local list
      final newCategory = Category(
        id: id,
        name: category.name,
        icon: category.icon,
        color: category.color,
        type: category.type,
      );
      _categories.add(newCategory);
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding category: $e');
      rethrow;
    }
  }

  Future<void> updateCategory(Category category) async {
    try {
      await _databaseService.updateCategory(category);
      final index = _categories.indexWhere((c) => c.id == category.id);
      if (index != -1) {
        _categories[index] = category;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating category: $e');
      rethrow;
    }
  }

  Future<void> deleteCategory(int id) async {
    try {
      // Check if category has transactions
      final hasTransactions = await _databaseService.categoryHasTransactions(id);
      if (hasTransactions) {
        throw Exception('Cannot delete category that has transactions');
      }
      
      await _databaseService.deleteCategory(id);
      _categories.removeWhere((c) => c.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting category: $e');
      rethrow;
    }
  }

  // Helper methods
  Category? getCategoryById(int id) {
    try {
      return _categories.firstWhere((c) => c.id == id);
    } catch (e) {
      debugPrint('Category with id $id not found');
      return null;
    }
  }

  Category? getCategoryByName(String name) {
    try {
      return _categories.firstWhere((c) => c.name.toLowerCase() == name.toLowerCase());
    } catch (e) {
      debugPrint('Category with name "$name" not found');
      return null;
    }
  }

  List<Category> getCategoriesByType(CategoryType type) {
    return _categories.where((c) => c.type == type).toList();
  }

  bool categoryExists(String name, CategoryType type) {
    return _categories.any((c) => 
        c.name.toLowerCase() == name.toLowerCase() && c.type == type
    );
  }

  // Search categories
  List<Category> searchCategories(String query) {
    if (query.isEmpty) return _categories;
    
    final lowercaseQuery = query.toLowerCase();
    return _categories.where((c) =>
        c.name.toLowerCase().contains(lowercaseQuery)
    ).toList();
  }

  // Get default categories for quick setup
  List<Map<String, dynamic>> get defaultExpenseCategories => [
    {'name': 'Food & Dining', 'icon': '🍽️', 'color': 0xFF4CAF50},
    {'name': 'Transportation', 'icon': '🚗', 'color': 0xFF2196F3},
    {'name': 'Shopping', 'icon': '🛍️', 'color': 0xFF9C27B0},
    {'name': 'Entertainment', 'icon': '🎬', 'color': 0xFFFF5722},
    {'name': 'Bills & Utilities', 'icon': '💡', 'color': 0xFFFF9800},
    {'name': 'Healthcare', 'icon': '🏥', 'color': 0xFFF44336},
    {'name': 'Education', 'icon': '📚', 'color': 0xFF607D8B},
    {'name': 'Travel', 'icon': '✈️', 'color': 0xFF795548},
    {'name': 'Personal Care', 'icon': '💄', 'color': 0xFFE91E63},
    {'name': 'Groceries', 'icon': '🛒', 'color': 0xFF8BC34A},
    {'name': 'Fuel', 'icon': '⛽', 'color': 0xFF3F51B5},
    {'name': 'Insurance', 'icon': '🛡️', 'color': 0xFF009688},
    {'name': 'Rent', 'icon': '🏠', 'color': 0xFF673AB7},
    {'name': 'Others', 'icon': '📋', 'color': 0xFF9E9E9E},
  ];

  List<Map<String, dynamic>> get defaultIncomeCategories => [
    {'name': 'Salary', 'icon': '💼', 'color': 0xFF4CAF50},
    {'name': 'Business', 'icon': '🏢', 'color': 0xFF2196F3},
    {'name': 'Investment', 'icon': '📈', 'color': 0xFF9C27B0},
    {'name': 'Freelance', 'icon': '💻', 'color': 0xFFFF5722},
    {'name': 'Gift', 'icon': '🎁', 'color': 0xFFFF9800},
    {'name': 'Bonus', 'icon': '💰', 'color': 0xFFF44336},
    {'name': 'Rental Income', 'icon': '🏠', 'color': 0xFF607D8B},
    {'name': 'Interest', 'icon': '🏦', 'color': 0xFF795548},
    {'name': 'Refund', 'icon': '↩️', 'color': 0xFFE91E63},
    {'name': 'Other Income', 'icon': '💵', 'color': 0xFF9E9E9E},
  ];

  // Utility methods
  Future<void> addDefaultCategories() async {
    try {
      // Add default expense categories
      for (final categoryData in defaultExpenseCategories) {
        if (!categoryExists(categoryData['name'], CategoryType.expense)) {
          final category = Category(
            name: categoryData['name'],
            icon: categoryData['icon'],
            color: categoryData['color'],
            type: CategoryType.expense,
          );
          await addCategory(category);
        }
      }

      // Add default income categories
      for (final categoryData in defaultIncomeCategories) {
        if (!categoryExists(categoryData['name'], CategoryType.income)) {
          final category = Category(
            name: categoryData['name'],
            icon: categoryData['icon'],
            color: categoryData['color'],
            type: CategoryType.income,
          );
          await addCategory(category);
        }
      }
    } catch (e) {
      debugPrint('Error adding default categories: $e');
      rethrow;
    }
  }

  // Get category statistics
  Map<String, dynamic> getCategoryStats() {
    return {
      'total': totalCategories,
      'expense': expenseCategoriesCount,
      'income': incomeCategoriesCount,
    };
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Reset categories (for testing purposes)
  Future<void> resetCategories() async {
    try {
      // Note: This should only be used for testing
      // In production, you might want to be more careful about this
      _categories.clear();
      notifyListeners();
      await loadCategories();
    } catch (e) {
      debugPrint('Error resetting categories: $e');
      rethrow;
    }
  }

  // Validate category data
  bool isValidCategory(String name, String icon, CategoryType type) {
    return name.trim().isNotEmpty && 
           icon.trim().isNotEmpty && 
           !categoryExists(name.trim(), type);
  }

  // Get available colors for new categories
  List<int> get availableColors => [
    0xFF4CAF50, 0xFF2196F3, 0xFF9C27B0, 0xFFFF5722, 
    0xFFFF9800, 0xFFF44336, 0xFF607D8B, 0xFF795548,
    0xFFE91E63, 0xFF8BC34A, 0xFF3F51B5, 0xFF009688,
    0xFF673AB7, 0xFFCDDC39, 0xFFFF9E80, 0xFF90CAF9,
  ];

  // Get available icons for new categories
  List<String> get availableIcons => [
    '🍽️', '🚗', '🛍️', '🎬', '💡', '🏥', '📚', '✈️',
    '💄', '🛒', '⛽', '🛡️', '🏠', '💼', '🏢', '📈',
    '💻', '🎁', '💰', '🏦', '↩️', '💵', '📋', '⚽',
    '🎵', '📱', '🍕', '☕', '🏋️', '🎮', '📖', '🌟',
  ];
}