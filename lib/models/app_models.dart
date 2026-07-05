enum CategoryType { INCOME, EXPENSE }

class UserModel {
  final String id;
  final String email;
  final String fullName;
  final String role;
  final String? avatar;

  UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    this.avatar,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    String roleStr = 'USER';
    if (json['role'] is String) {
      roleStr = json['role'] as String;
    } else if (json['role'] is Map && json['role']['name'] is String) {
      roleStr = json['role']['name'] as String;
    }

    return UserModel(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      role: roleStr,
      avatar: json['avatar'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'fullName': fullName,
        'role': role,
        'avatar': avatar,
      };
}

class CategoryModel {
  final String id;
  final String name;
  final CategoryType type;
  final bool isSystem;

  CategoryModel({
    required this.id,
    required this.name,
    required this.type,
    required this.isSystem,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      type: json['type'] == 'INCOME' ? CategoryType.INCOME : CategoryType.EXPENSE,
      isSystem: json['isSystem'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type == CategoryType.INCOME ? 'INCOME' : 'EXPENSE',
        'isSystem': isSystem,
      };
}

class TransactionModel {
  final String id;
  final int amount; // Smallest unit integer
  final String transactionDate;
  final String notes;
  final String categoryId;
  final CategoryModel? category;
  final String? fileUrl;

  TransactionModel({
    required this.id,
    required this.amount,
    required this.transactionDate,
    required this.notes,
    required this.categoryId,
    this.category,
    this.fileUrl,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String? ?? '',
      amount: (json['amount'] is String)
          ? int.parse(json['amount'])
          : (json['amount'] as num? ?? 0).toInt(),
      transactionDate: json['transactionDate'] as String? ?? '',
      notes: json['notes'] as String? ?? '',
      categoryId: json['categoryId'] as String? ?? '',
      category: json['category'] != null
          ? CategoryModel.fromJson(json['category'] as Map<String, dynamic>)
          : null,
      fileUrl: json['fileUrl'] as String? ?? json['file'] as String?,
    );
  }
}

class BudgetModel {
  final String id;
  final String categoryId;
  final int limitAmount;
  final int month;
  final int year;
  final int spentAmount;
  final String? warningLevel;
  final CategoryModel? category;

  BudgetModel({
    required this.id,
    required this.categoryId,
    required this.limitAmount,
    required this.month,
    required this.year,
    required this.spentAmount,
    this.warningLevel,
    this.category,
  });

  factory BudgetModel.fromJson(Map<String, dynamic> json) {
    return BudgetModel(
      id: json['id'] as String? ?? '',
      categoryId: json['categoryId'] as String? ?? '',
      limitAmount: (json['limitAmount'] as num? ?? 0).toInt(),
      month: (json['month'] as num? ?? 1).toInt(),
      year: (json['year'] as num? ?? 2026).toInt(),
      spentAmount: (json['spentAmount'] as num? ?? 0).toInt(),
      warningLevel: json['warningLevel'] as String?,
      category: json['category'] != null
          ? CategoryModel.fromJson(json['category'] as Map<String, dynamic>)
          : null,
    );
  }
}

class GoalModel {
  final String id;
  final String name;
  final int targetAmount;
  final int currentAmount;
  final String deadline;

  GoalModel({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
    required this.deadline,
  });

  factory GoalModel.fromJson(Map<String, dynamic> json) {
    return GoalModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      targetAmount: (json['targetAmount'] as num? ?? 0).toInt(),
      currentAmount: (json['currentAmount'] as num? ?? 0).toInt(),
      deadline: json['deadline'] as String? ?? '',
    );
  }
}

class DashboardSummaryModel {
  final int totalIncome;
  final int totalExpenses;
  final int netBalance;

  DashboardSummaryModel({
    required this.totalIncome,
    required this.totalExpenses,
    required this.netBalance,
  });

  factory DashboardSummaryModel.fromJson(Map<String, dynamic> json) {
    return DashboardSummaryModel(
      totalIncome: (json['totalIncome'] as num? ?? 0).toInt(),
      totalExpenses: (json['totalExpenses'] as num? ?? 0).toInt(),
      netBalance: (json['netBalance'] as num? ?? 0).toInt(),
    );
  }
}

class CategoryBreakdownModel {
  final String categoryId;
  final String categoryName;
  final CategoryType type;
  final int totalAmount;
  final double percentage;

  CategoryBreakdownModel({
    required this.categoryId,
    required this.categoryName,
    required this.type,
    required this.totalAmount,
    required this.percentage,
  });

  factory CategoryBreakdownModel.fromJson(Map<String, dynamic> json) {
    return CategoryBreakdownModel(
      categoryId: json['categoryId'] as String? ?? '',
      categoryName: json['categoryName'] as String? ?? 'Others',
      type: json['type'] == 'INCOME' ? CategoryType.INCOME : CategoryType.EXPENSE,
      totalAmount: (json['totalAmount'] as num? ?? 0).toInt(),
      percentage: (json['percentage'] as num? ?? 0.0).toDouble(),
    );
  }
}

class TrendPointModel {
  final String month;
  final int income;
  final int expense;

  TrendPointModel({
    required this.month,
    required this.income,
    required this.expense,
  });

  factory TrendPointModel.fromJson(Map<String, dynamic> json) {
    return TrendPointModel(
      month: json['month'] as String? ?? json['date'] as String? ?? '',
      income: (json['income'] as num? ?? 0).toInt(),
      expense: (json['expense'] as num? ?? 0).toInt(),
    );
  }
}
