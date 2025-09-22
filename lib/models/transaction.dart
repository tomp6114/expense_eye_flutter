// models/transaction.dart
class Transaction {
  final int? id;
  final double amount;
  final int categoryId;
  final DateTime date;
  final String description;
  final String? receiptPath;
  final TransactionType type;

  Transaction({
    this.id,
    required this.amount,
    required this.categoryId,
    required this.date,
    required this.description,
    this.receiptPath,
    required this.type,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'categoryId': categoryId,
      'date': date.toIso8601String(),
      'description': description,
      'receiptPath': receiptPath,
      'type': type.name,
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      amount: map['amount'].toDouble(),
      categoryId: map['categoryId'],
      date: DateTime.parse(map['date']),
      description: map['description'],
      receiptPath: map['receiptPath'],
      type: TransactionType.values.firstWhere((e) => e.name == map['type']),
    );
  }

  Transaction copyWith({
    int? id,
    double? amount,
    int? categoryId,
    DateTime? date,
    String? description,
    String? receiptPath,
    TransactionType? type,
  }) {
    return Transaction(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      date: date ?? this.date,
      description: description ?? this.description,
      receiptPath: receiptPath ?? this.receiptPath,
      type: type ?? this.type,
    );
  }
}

enum TransactionType {
  income,
  expense,
}

// models/category.dart
class Category {
  final int? id;
  final String name;
  final String icon;
  final int color;
  final CategoryType type;

  Category({
    this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.type,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'color': color,
      'type': type.name,
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'],
      name: map['name'],
      icon: map['icon'],
      color: map['color'],
      type: CategoryType.values.firstWhere((e) => e.name == map['type']),
    );
  }
}

enum CategoryType {
  income,
  expense,
}

// models/budget.dart
class Budget {
  final int? id;
  final int categoryId;
  final double amount;
  final BudgetPeriod period;
  final DateTime startDate;

  Budget({
    this.id,
    required this.categoryId,
    required this.amount,
    required this.period,
    required this.startDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'categoryId': categoryId,
      'amount': amount,
      'period': period.name,
      'startDate': startDate.toIso8601String(),
    };
  }

  factory Budget.fromMap(Map<String, dynamic> map) {
    return Budget(
      id: map['id'],
      categoryId: map['categoryId'],
      amount: map['amount'].toDouble(),
      period: BudgetPeriod.values.firstWhere((e) => e.name == map['period']),
      startDate: DateTime.parse(map['startDate']),
    );
  }
}

enum BudgetPeriod {
  weekly,
  monthly,
  yearly,
}