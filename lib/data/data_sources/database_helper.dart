import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static const _databaseName = "craftshop.db";
  static const _databaseVersion = 3;
  
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
      onUpgrade: _onUpgrade,
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
    
    // Create products table
    await _createProductsTable(db);
    
    // Create bills table
    await _createBillsTable(db);
    
    // Create line items table
    await _createLineItemsTable(db);
  }
  
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add products table in version 2
      await _createProductsTable(db);
    }
    
    if (oldVersion < 3) {
      // Add bills and line items tables in version 3
      await _createBillsTable(db);
      await _createLineItemsTable(db);
    }
  }
  
  Future<void> _createProductsTable(Database db) async {
    await db.execute('''
      CREATE TABLE products(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        sku TEXT NOT NULL UNIQUE,
        category_id TEXT NOT NULL,
        price REAL NOT NULL,
        stock INTEGER NOT NULL DEFAULT 0,
        is_active INTEGER NOT NULL DEFAULT 1,
        FOREIGN KEY (category_id) REFERENCES categories (id) ON DELETE CASCADE
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
  
  Future<List<Map<String, dynamic>>> rawQuery(String query, [List<dynamic>? arguments]) async {
    final db = await database;
    return await db.rawQuery(query, arguments);
  }
  
  Future<void> rawExecute(String query, [List<dynamic>? arguments]) async {
    final db = await database;
    await db.execute(query, arguments);
  }
  
  Future<Batch> beginBatch() async {
    final db = await database;
    return db.batch();
  }
  
  Future<List<Object?>> commitBatch(Batch batch) async {
    return await batch.commit();
  }
  
  Future<void> _createBillsTable(Database db) async {
    await db.execute('''
      CREATE TABLE bills(
        id TEXT PRIMARY KEY,
        date INTEGER NOT NULL,
        subtotal REAL NOT NULL,
        tax_amount REAL NOT NULL,
        discount_amount REAL NOT NULL,
        total_amount REAL NOT NULL,
        created_at INTEGER NOT NULL
      )
    ''');
  }
  
  Future<void> _createLineItemsTable(Database db) async {
    await db.execute('''
      CREATE TABLE line_items(
        id TEXT PRIMARY KEY,
        bill_id TEXT NOT NULL,
        product_id TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        unit_price REAL NOT NULL,
        discount REAL NOT NULL,
        total_price REAL NOT NULL,
        FOREIGN KEY (bill_id) REFERENCES bills (id) ON DELETE CASCADE,
        FOREIGN KEY (product_id) REFERENCES products (id) ON DELETE RESTRICT
      )
    ''');
  }
}
