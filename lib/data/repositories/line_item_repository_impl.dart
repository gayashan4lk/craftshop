import 'package:craftshop/data/data_sources/database_helper.dart';
import 'package:craftshop/domain/models/line_item.dart';
import 'package:craftshop/domain/repositories/line_item_repository.dart';

class LineItemRepositoryImpl implements LineItemRepository {
  final DatabaseHelper _databaseHelper;
  static const String tableName = 'line_items';

  LineItemRepositoryImpl({DatabaseHelper? databaseHelper})
    : _databaseHelper = databaseHelper ?? DatabaseHelper.instance;

  @override
  Future<List<LineItem>> getLineItemsByBillId(String billId) async {
    const query = '''SELECT li.*, p.name as product_name 
                  FROM line_items li 
                  LEFT JOIN products p ON li.product_id = p.id 
                  WHERE li.bill_id = ?''';
    final rows = await _databaseHelper.rawQuery(query, [billId]);
    final lineItems =
        rows.map((row) => LineItemDatabaseExtension.fromMap(row)).toList();
    return lineItems;
  }

  @override
  Future<LineItem?> getLineItemById(String id) async {
    final row = await _databaseHelper.queryById(tableName, id);
    return row != null ? LineItemDatabaseExtension.fromMap(row) : null;
  }

  @override
  Future<void> addLineItem(LineItem lineItem) async {
    await _databaseHelper.insert(tableName, lineItem.toMap());
  }

  @override
  Future<void> addMultipleLineItems(List<LineItem> lineItems) async {
    final batch = await _databaseHelper.beginBatch();
    for (final lineItem in lineItems) {
      batch.insert(tableName, lineItem.toMap());
    }
    await _databaseHelper.commitBatch(batch);
  }

  @override
  Future<void> updateLineItem(LineItem lineItem) async {
    await _databaseHelper.update(tableName, lineItem.toMap());
  }

  @override
  Future<void> deleteLineItem(String id) async {
    await _databaseHelper.delete(tableName, id);
  }

  @override
  Future<void> deleteLineItemsByBillId(String billId) async {
    const query = 'DELETE FROM $tableName WHERE bill_id = ?';
    await _databaseHelper.rawExecute(query, [billId]);
  }
}
