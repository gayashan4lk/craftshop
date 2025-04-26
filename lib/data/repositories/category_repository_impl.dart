import 'package:craftshop/data/data_sources/database_helper.dart';
import 'package:craftshop/domain/models/category.dart';
import 'package:craftshop/domain/repositories/category_repository.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final DatabaseHelper _databaseHelper;
  static const String tableName = 'categories';

  CategoryRepositoryImpl({DatabaseHelper? databaseHelper})
      : _databaseHelper = databaseHelper ?? DatabaseHelper.instance;

  @override
  Future<List<Category>> getAllCategories() async {
    final rows = await _databaseHelper.queryAllRows(tableName);
    return rows.map((row) => CategoryColorExtension.fromMap(row)).toList();
  }

  @override
  Future<Category?> getCategoryById(String id) async {
    final row = await _databaseHelper.queryById(tableName, id);
    return row != null ? CategoryColorExtension.fromMap(row) : null;
  }

  @override
  Future<void> addCategory(Category category) async {
    await _databaseHelper.insert(tableName, category.toMap());
  }

  @override
  Future<void> updateCategory(Category category) async {
    await _databaseHelper.update(tableName, category.toMap());
  }

  @override
  Future<void> deleteCategory(String id) async {
    await _databaseHelper.delete(tableName, id);
  }

  @override
  Future<int> getCategoryCount() async {
    return await _databaseHelper.count(tableName);
  }
}
