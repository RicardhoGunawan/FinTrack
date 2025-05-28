import 'package:flutter/foundation.dart';
import 'transaction.dart';
import 'category.dart' as my_category;
import 'database_helper.dart';

class TransactionProvider extends ChangeNotifier {
  List<Transaction> _transactions = [];
  List<my_category.Category> _incomeCategories = [];
  List<my_category.Category> _expenseCategories = [];

  List<Transaction> get transactions => _transactions;
  List<my_category.Category> get incomeCategories => _incomeCategories;
  List<my_category.Category> get expenseCategories => _expenseCategories;

  Future<void> loadTransactions() async {
    _transactions = await DatabaseHelper.instance.getTransactions();
    notifyListeners();
  }

  Future<void> loadCategories() async {
    _incomeCategories = await DatabaseHelper.instance.getCategories('income');
    _expenseCategories = await DatabaseHelper.instance.getCategories('expense');
    notifyListeners();
  }

  Future<void> addTransaction(Transaction transaction) async {
    await DatabaseHelper.instance.insertTransaction(transaction);
    await loadTransactions();
  }

  Future<void> deleteTransaction(int id) async {
    await DatabaseHelper.instance.deleteTransaction(id);
    await loadTransactions();
  }

  Future<void> addCategory(my_category.Category category) async {
    await DatabaseHelper.instance.insertCategory(category);
    await loadCategories();
  }

  Future<void> deleteCategory(int id) async {
    await DatabaseHelper.instance.deleteCategory(id);
    await loadCategories();
  }

  double get totalIncome {
    return _transactions
        .where((t) => t.type == 'income')
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get totalExpense {
    return _transactions
        .where((t) => t.type == 'expense')
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get balance => totalIncome - totalExpense;

  Map<String, double> get expenseByCategory {
    final Map<String, double> categoryTotals = {};
    for (final transaction in _transactions.where((t) => t.type == 'expense')) {
      categoryTotals[transaction.category] = 
          (categoryTotals[transaction.category] ?? 0) + transaction.amount;
    }
    return categoryTotals;
  }
}