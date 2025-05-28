import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'transaction.dart' as mymodel;
import 'category.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'fintrack.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE transactions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT NOT NULL,
        amount REAL NOT NULL,
        category TEXT NOT NULL,
        note TEXT,
        date INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE categories(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        icon TEXT NOT NULL,
        type TEXT NOT NULL
      )
    ''');

    // Insert default categories
    await _insertDefaultCategories(db);
  }

  Future<void> _insertDefaultCategories(Database db) async {
    final defaultCategories = [
      // Income categories
      {'name': 'Gaji', 'icon': '💰', 'type': 'income'},
      {'name': 'Freelance', 'icon': '💻', 'type': 'income'},
      {'name': 'Bonus', 'icon': '🎁', 'type': 'income'},
      {'name': 'Investasi', 'icon': '📈', 'type': 'income'},
      
      // Expense categories
      {'name': 'Makanan', 'icon': '🍽️', 'type': 'expense'},
      {'name': 'Transportasi', 'icon': '🚗', 'type': 'expense'},
      {'name': 'Belanja', 'icon': '🛒', 'type': 'expense'},
      {'name': 'Hiburan', 'icon': '🎬', 'type': 'expense'},
      {'name': 'Kesehatan', 'icon': '🏥', 'type': 'expense'},
      {'name': 'Pendidikan', 'icon': '📚', 'type': 'expense'},
      {'name': 'Tagihan', 'icon': '📄', 'type': 'expense'},
    ];

    for (final category in defaultCategories) {
      await db.insert('categories', category);
    }
  }

  // Transaction methods
  Future<int> insertTransaction(mymodel.Transaction transaction) async {
    final db = await database;
    return await db.insert('transactions', transaction.toMap());
  }

  Future<List<mymodel.Transaction>> getTransactions() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      orderBy: 'date DESC',
    );

    return List.generate(maps.length, (i) {
      return mymodel.Transaction.fromMap(maps[i]);
    });
  }

  Future<List<mymodel.Transaction>> getTransactionsByMonth(int year, int month) async {
    final db = await database;
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 0, 23, 59, 59);

    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: 'date >= ? AND date <= ?',
      whereArgs: [startDate.millisecondsSinceEpoch, endDate.millisecondsSinceEpoch],
      orderBy: 'date DESC',
    );

    return List.generate(maps.length, (i) {
      return mymodel.Transaction.fromMap(maps[i]);
    });
  }

  Future<void> deleteTransaction(int id) async {
    final db = await database;
    await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  // Category methods
  Future<int> insertCategory(Category category) async {
    final db = await database;
    return await db.insert('categories', category.toMap());
  }

  Future<List<Category>> getCategories(String type) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'categories',
      where: 'type = ?',
      whereArgs: [type],
    );

    return List.generate(maps.length, (i) {
      return Category.fromMap(maps[i]);
    });
  }

  Future<void> deleteCategory(int id) async {
    final db = await database;
    await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }
}