import 'package:craftshop/domain/models/bill.dart';
import 'package:craftshop/domain/models/line_item.dart';

abstract class BillRepository {
  Future<List<Bill>> getAllBills();
  Future<Bill?> getBillById(String id, {bool includeLineItems = false});
  Future<String> addBill(Bill bill, List<LineItem> lineItems);
  Future<void> updateBill(Bill bill);
  Future<void> deleteBill(String id);
  Future<int> getBillCount();
  Future<List<Bill>> getRecentBills(int limit);
}
