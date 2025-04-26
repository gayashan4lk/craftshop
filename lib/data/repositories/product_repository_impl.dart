import 'package:craftshop/data/data_sources/database_helper.dart';
import 'package:craftshop/domain/models/product.dart';
import 'package:craftshop/domain/repositories/product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  final DatabaseHelper _databaseHelper;
  static const String tableName = 'products';

  ProductRepositoryImpl({DatabaseHelper? databaseHelper})
      : _databaseHelper = databaseHelper ?? DatabaseHelper.instance;

  @override
  Future<List<Product>> getAllProducts() async {
    final rows = await _databaseHelper.queryAllRows(tableName);
    return rows.map((row) => ProductDatabaseExtension.fromMap(row)).toList();
  }

  @override
  Future<List<Product>> getProductsByCategory(String categoryId) async {
    final db = await _databaseHelper.database;
    final rows = await db.query(
      tableName,
      where: 'category_id = ?',
      whereArgs: [categoryId],
    );
    return rows.map((row) => ProductDatabaseExtension.fromMap(row)).toList();
  }

  @override
  Future<Product?> getProductById(String id) async {
    final row = await _databaseHelper.queryById(tableName, id);
    return row != null ? ProductDatabaseExtension.fromMap(row) : null;
  }
  
  @override
  Future<Product?> getProductBySku(String sku) async {
    final db = await _databaseHelper.database;
    final rows = await db.query(
      tableName,
      where: 'sku = ?',
      whereArgs: [sku],
      limit: 1,
    );
    return rows.isNotEmpty ? ProductDatabaseExtension.fromMap(rows.first) : null;
  }

  @override
  Future<void> addProduct(Product product) async {
    await _databaseHelper.insert(tableName, product.toMap());
  }

  @override
  Future<void> updateProduct(Product product) async {
    await _databaseHelper.update(tableName, product.toMap());
  }

  @override
  Future<void> deleteProduct(String id) async {
    await _databaseHelper.delete(tableName, id);
  }

  @override
  Future<int> getProductCount() async {
    return await _databaseHelper.count(tableName);
  }
  
  @override
  Future<int> getProductCountByCategory(String categoryId) async {
    final db = await _databaseHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) FROM $tableName WHERE category_id = ?',
      [categoryId],
    );
    return result.first.values.first as int;
  }
}
