import 'package:craftshop/domain/models/line_item.dart';

abstract class LineItemRepository {
  Future<List<LineItem>> getLineItemsByBillId(String billId);
  Future<LineItem?> getLineItemById(String id);
  Future<void> addLineItem(LineItem lineItem);
  Future<void> addMultipleLineItems(List<LineItem> lineItems);
  Future<void> updateLineItem(LineItem lineItem);
  Future<void> deleteLineItem(String id);
  Future<void> deleteLineItemsByBillId(String billId);
}
