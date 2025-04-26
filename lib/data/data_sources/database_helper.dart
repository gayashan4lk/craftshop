import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static const _databaseName = "craftshop.db";
  static const _databaseVersion = 1;
  
  // Singleton pattern
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  
  static Database? _database;
  
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }
  
  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, _databaseName);
    
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }
  
  Future<void> _onCreate(Database db, int version) async {
    // Create category table
    await db.execute('''
      CREATE TABLE categories(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        color_value INTEGER NOT NULL,
        item_count INTEGER DEFAULT 0
      )
    ''');
  }
  
  // Helper methods for transactions
  Future<List<Map<String, dynamic>>> queryAllRows(String table) async {
    final db = await database;
    return await db.query(table);
  }
  
  Future<Map<String, dynamic>?> queryById(String table, String id) async {
    final db = await database;
    final results = await db.query(
      table,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    
    return results.isNotEmpty ? results.first : null;
  }
  
  Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert(table, data);
  }
  
  Future<int> update(String table, Map<String, dynamic> data) async {
    final db = await database;
    final id = data['id'];
    return await db.update(
      table,
      data,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  
  Future<int> delete(String table, String id) async {
    final db = await database;
    return await db.delete(
      table,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  
  Future<int> count(String table) async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) FROM $table');
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
