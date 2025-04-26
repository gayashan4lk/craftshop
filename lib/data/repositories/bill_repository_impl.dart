import 'package:craftshop/data/data_sources/database_helper.dart';
import 'package:craftshop/domain/models/bill.dart';
import 'package:craftshop/domain/models/line_item.dart';
import 'package:craftshop/domain/repositories/bill_repository.dart';
import 'package:craftshop/domain/repositories/line_item_repository.dart';

class BillRepositoryImpl implements BillRepository {
  final DatabaseHelper _databaseHelper;
  final LineItemRepository _lineItemRepository;
  static const String tableName = 'bills';

  BillRepositoryImpl({
    required LineItemRepository lineItemRepository,
    DatabaseHelper? databaseHelper,
  })
      : _databaseHelper = databaseHelper ?? DatabaseHelper.instance,
        _lineItemRepository = lineItemRepository;

  @override
  Future<List<Bill>> getAllBills() async {
    final rows = await _databaseHelper.queryAllRows(tableName);
    return rows.map((row) => BillDatabaseExtension.fromMap(row)).toList();
  }

  @override
  Future<Bill?> getBillById(String id, {bool includeLineItems = false}) async {
    final row = await _databaseHelper.queryById(tableName, id);
    if (row == null) return null;

    final bill = BillDatabaseExtension.fromMap(row);
    
    if (includeLineItems) {
      final lineItems = await _lineItemRepository.getLineItemsByBillId(id);
      return bill.copyWith(lineItems: lineItems);
    }
    
    return bill;
  }

  @override
  Future<String> addBill(Bill bill, List<LineItem> lineItems) async {
    await _databaseHelper.insert(tableName, bill.toMap());
    await _lineItemRepository.addMultipleLineItems(lineItems);
    return bill.id;
  }

  @override
  Future<void> updateBill(Bill bill) async {
    await _databaseHelper.update(tableName, bill.toMap());
  }

  @override
  Future<void> deleteBill(String id) async {
    await _lineItemRepository.deleteLineItemsByBillId(id);
    await _databaseHelper.delete(tableName, id);
  }

  @override
  Future<int> getBillCount() async {
    return await _databaseHelper.count(tableName);
  }
  
  @override
  Future<List<Bill>> getRecentBills(int limit) async {
    final query = '''SELECT * FROM $tableName 
                     ORDER BY created_at DESC 
                     LIMIT ?''';
    final rows = await _databaseHelper.rawQuery(query, [limit]);
    return rows.map((row) => BillDatabaseExtension.fromMap(row)).toList();
  }
  
  @override
  Future<Map<String, int>> getLineItemCountsForBills(List<String> billIds) async {
    if (billIds.isEmpty) {
      return {};
    }
    
    // Instead of a complex query, just iterate through the bills and count items
    final countMap = <String, int>{};
    
    for (final billId in billIds) {
      // Get all line items for this bill 
      final lineItems = await _lineItemRepository.getLineItemsByBillId(billId);
      countMap[billId] = lineItems.length;
    }
    
    return countMap;
  }
}
