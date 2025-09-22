
// import 'package:expense_eye_flutter/models/transaction.dart' as trans;
// import 'package:path/path.dart';
// import 'package:sqflite/sqflite.dart';


// class DatabaseService {
//   static final DatabaseService _instance = DatabaseService._internal();
//   factory DatabaseService() => _instance;
//   DatabaseService._internal();

//   static Database? _database;

//   Future<Database> get database async {
//     if (_database != null) return _database!;
//     _database = await _initDatabase();
//     return _database!;
//   }

//   Future<Database> _initDatabase() async {
//     String path = join(await getDatabasesPath(), 'expense_tracker.db');
    
//     return await openDatabase(
//       path,
//       version: 1,
//       onCreate: _onCreate,
//     );
//   }

//   Future<void> _onCreate(Database db, int version) async {
//     // Create Categories table
//     await db.execute('''
//       CREATE TABLE categories(
//         id INTEGER PRIMARY KEY AUTOINCREMENT,
//         name TEXT NOT NULL,
//         icon TEXT NOT NULL,
//         color INTEGER NOT NULL,
//         type TEXT NOT NULL
//       )
//     ''');

//     // Create Transactions table
//     await db.execute('''
//       CREATE TABLE transactions(
//         id INTEGER PRIMARY KEY AUTOINCREMENT,
//         amount REAL NOT NULL,
//         categoryId INTEGER NOT NULL,
//         date TEXT NOT NULL,
//         description TEXT NOT NULL,
//         receiptPath TEXT,
//         type TEXT NOT NULL,
//         FOREIGN KEY (categoryId) REFERENCES categories (id)
//       )
//     ''');

//     // Create Budgets table
//     await db.execute('''
//       CREATE TABLE budgets(
//         id INTEGER PRIMARY KEY AUTOINCREMENT,
//         categoryId INTEGER NOT NULL,
//         amount REAL NOT NULL,
//         period TEXT NOT NULL,
//         startDate TEXT NOT NULL,
//         FOREIGN KEY (categoryId) REFERENCES categories (id)
//       )
//     ''');

//     // Insert default categories
//     await _insertDefaultCategories(db);
//   }

//   Future<void> _insertDefaultCategories(Database db) async {
//     final defaultCategories = [
//       // Expense categories
//       {'name': 'Food & Dining', 'icon': '🍽️', 'color': 0xFF4CAF50, 'type': 'expense'},
//       {'name': 'Transportation', 'icon': '🚗', 'color': 0xFF2196F3, 'type': 'expense'},
//       {'name': 'Shopping', 'icon': '🛍️', 'color': 0xFF9C27B0, 'type': 'expense'},
//       {'name': 'Entertainment', 'icon': '🎬', 'color': 0xFFFF5722, 'type': 'expense'},
//       {'name': 'Bills & Utilities', 'icon': '💡', 'color': 0xFFFF9800, 'type': 'expense'},
//       {'name': 'Healthcare', 'icon': '🏥', 'color': 0xFFF44336, 'type': 'expense'},
//       {'name': 'Education', 'icon': '📚', 'color': 0xFF607D8B, 'type': 'expense'},
//       {'name': 'Travel', 'icon': '✈️', 'color': 0xFF795548, 'type': 'expense'},
//       {'name': 'Others', 'icon': '📋', 'color': 0xFF9E9E9E, 'type': 'expense'},
      
//       // Income categories
//       {'name': 'Salary', 'icon': '💼', 'color': 0xFF4CAF50, 'type': 'income'},
//       {'name': 'Business', 'icon': '🏢', 'color': 0xFF2196F3, 'type': 'income'},
//       {'name': 'Investment', 'icon': '📈', 'color': 0xFF9C27B0, 'type': 'income'},
//       {'name': 'Gift', 'icon': '🎁', 'color': 0xFFFF5722, 'type': 'income'},
//       {'name': 'Other Income', 'icon': '💰', 'color': 0xFFFF9800, 'type': 'income'},
//     ];

//     for (var category in defaultCategories) {
//       await db.insert('categories', category);
//     }
//   }

//   // CRUD operations for Transactions
//   Future<int> insertTransaction(trans.Transaction transaction) async {
//     final db = await database;
//     return await db.insert('transactions', transaction.toMap());
//   }

//   Future<List<trans.Transaction>> getTransactions() async {
//     final db = await database;
//     final List<Map<String, dynamic>> maps = await db.query(
//       'transactions',
//       orderBy: 'date DESC',
//     );
//     return List.generate(maps.length, (i) => trans.Transaction.fromMap(maps[i]));
//   }

//   Future<List<trans.Transaction>> getTransactionsByDateRange(DateTime start, DateTime end) async {
//     final db = await database;
//     final List<Map<String, dynamic>> maps = await db.query(
//       'transactions',
//       where: 'date BETWEEN ? AND ?',
//       whereArgs: [start.toIso8601String(), end.toIso8601String()],
//       orderBy: 'date DESC',
//     );
//     return List.generate(maps.length, (i) => trans.Transaction.fromMap(maps[i]));
//   }

//   Future<void> updateTransaction(trans.Transaction transaction) async {
//     final db = await database;
//     await db.update(
//       'transactions',
//       transaction.toMap(),
//       where: 'id = ?',
//       whereArgs: [transaction.id],
//     );
//   }

//   Future<void> deleteTransaction(int id) async {
//     final db = await database;
//     await db.delete(
//       'transactions',
//       where: 'id = ?',
//       // whereArgs: [id],
//     );
//   }

//   // CRUD operations for Categories
//   Future<List<trans.Category>> getCategories() async {
//     final db = await database;
//     final List<Map<String, dynamic>> maps = await db.query('categories');
//     return List.generate(maps.length, (i) => trans.Category.fromMap(maps[i]));
//   }

//   Future<int> insertCategory(trans.Category category) async {
//     final db = await database;
//     return await db.insert('categories', category.toMap());
//   }

//   // Close database
//   Future<void> close() async {
//     final db = await database;
//     db.close();
//   }
// }


import 'package:mint_flow/models/transaction.dart' as trans;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';


class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'expense_tracker.db');
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create Categories table
    await db.execute('''
      CREATE TABLE categories(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        icon TEXT NOT NULL,
        color INTEGER NOT NULL,
        type TEXT NOT NULL
      )
    ''');

    // Create Transactions table
    await db.execute('''
      CREATE TABLE transactions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        amount REAL NOT NULL,
        categoryId INTEGER NOT NULL,
        date TEXT NOT NULL,
        description TEXT NOT NULL,
        receiptPath TEXT,
        type TEXT NOT NULL,
        FOREIGN KEY (categoryId) REFERENCES categories (id)
      )
    ''');

    // Create Budgets table
    await db.execute('''
      CREATE TABLE budgets(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        categoryId INTEGER NOT NULL,
        amount REAL NOT NULL,
        period TEXT NOT NULL,
        startDate TEXT NOT NULL,
        FOREIGN KEY (categoryId) REFERENCES categories (id)
      )
    ''');

    // Insert default categories
    await _insertDefaultCategories(db);
  }

  Future<void> _insertDefaultCategories(Database db) async {
    final defaultCategories = [
      // Expense categories
      {'name': 'Food & Dining', 'icon': '🍽️', 'color': 0xFF4CAF50, 'type': 'expense'},
      {'name': 'Transportation', 'icon': '🚗', 'color': 0xFF2196F3, 'type': 'expense'},
      {'name': 'Shopping', 'icon': '🛍️', 'color': 0xFF9C27B0, 'type': 'expense'},
      {'name': 'Entertainment', 'icon': '🎬', 'color': 0xFFFF5722, 'type': 'expense'},
      {'name': 'Bills & Utilities', 'icon': '💡', 'color': 0xFFFF9800, 'type': 'expense'},
      {'name': 'Healthcare', 'icon': '🏥', 'color': 0xFFF44336, 'type': 'expense'},
      {'name': 'Education', 'icon': '📚', 'color': 0xFF607D8B, 'type': 'expense'},
      {'name': 'Travel', 'icon': '✈️', 'color': 0xFF795548, 'type': 'expense'},
      {'name': 'Others', 'icon': '📋', 'color': 0xFF9E9E9E, 'type': 'expense'},
      
      // Income categories
      {'name': 'Salary', 'icon': '💼', 'color': 0xFF4CAF50, 'type': 'income'},
      {'name': 'Business', 'icon': '🏢', 'color': 0xFF2196F3, 'type': 'income'},
      {'name': 'Investment', 'icon': '📈', 'color': 0xFF9C27B0, 'type': 'income'},
      {'name': 'Gift', 'icon': '🎁', 'color': 0xFFFF5722, 'type': 'income'},
      {'name': 'Other Income', 'icon': '💰', 'color': 0xFFFF9800, 'type': 'income'},
    ];

    for (var category in defaultCategories) {
      await db.insert('categories', category);
    }
  }

  // CRUD operations for Transactions
  Future<int> insertTransaction(trans.Transaction transaction) async {
    final db = await database;
    return await db.insert('transactions', transaction.toMap());
  }

  Future<List<trans.Transaction>> getTransactions() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) => trans.Transaction.fromMap(maps[i]));
  }

  Future<List<trans.Transaction>> getTransactionsByDateRange(DateTime start, DateTime end) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: 'date BETWEEN ? AND ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) => trans.Transaction.fromMap(maps[i]));
  }

  Future<void> updateTransaction(trans.Transaction transaction) async {
    final db = await database;
    await db.update(
      'transactions',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  Future<void> deleteTransaction(int id) async {
    final db = await database;
    await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // CRUD operations for Categories
  Future<List<trans.Category>> getCategories() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('categories');
    return List.generate(maps.length, (i) => trans.Category.fromMap(maps[i]));
  }

  Future<int> insertCategory(trans.Category category) async {
    final db = await database;
    return await db.insert('categories', category.toMap());
  }

  Future<void> updateCategory(trans.Category category) async {
    final db = await database;
    await db.update(
      'categories',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  Future<bool> categoryHasTransactions(int categoryId) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'transactions',
      where: 'categoryId = ?',
      whereArgs: [categoryId],
      limit: 1,
    );
    return result.isNotEmpty;
  }

  Future<void> deleteCategory(int id) async {
    final db = await database;
    await db.delete(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // CRUD operations for Budgets
  Future<List<trans.Budget>> getBudgets() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'budgets',
      orderBy: 'startDate DESC',
    );
    return List.generate(maps.length, (i) => trans.Budget.fromMap(maps[i]));
  }

  Future<int> insertBudget(trans.Budget budget) async {
    final db = await database;
    return await db.insert('budgets', budget.toMap());
  }

  Future<void> updateBudget(trans.Budget budget) async {
    final db = await database;
    await db.update(
      'budgets',
      budget.toMap(),
      where: 'id = ?',
      whereArgs: [budget.id],
    );
  }

  Future<void> deleteBudget(int id) async {
    final db = await database;
    await db.delete(
      'budgets',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<trans.Budget>> getBudgetsByCategory(int categoryId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'budgets',
      where: 'categoryId = ?',
      whereArgs: [categoryId],
      orderBy: 'startDate DESC',
    );
    return List.generate(maps.length, (i) => trans.Budget.fromMap(maps[i]));
  }

  // Close database
  Future<void> close() async {
    final db = await database;
    db.close();
  }
}