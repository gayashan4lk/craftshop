import 'package:uuid/uuid.dart';

class LineItem {
  final String id;
  final String billId;
  final String productId;
  final String? productName;
  final int quantity;
  final double unitPrice;
  final double discount;
  final double totalPrice;

  const LineItem({
    required this.id,
    required this.billId,
    required this.productId,
    this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.discount,
    required this.totalPrice,
  });

  factory LineItem.create({
    required String billId,
    required String productId,
    String? productName,
    required int quantity,
    required double unitPrice,
    double discount = 0.0,
  }) {
    final totalPrice = (unitPrice * quantity) - discount;
    
    return LineItem(
      id: const Uuid().v4(),
      billId: billId,
      productId: productId,
      productName: productName,
      quantity: quantity,
      unitPrice: unitPrice,
      discount: discount,
      totalPrice: totalPrice,
    );
  }

  LineItem copyWith({
    String? id,
    String? billId,
    String? productId,
    String? productName,
    int? quantity,
    double? unitPrice,
    double? discount,
    double? totalPrice,
  }) {
    return LineItem(
      id: id ?? this.id,
      billId: billId ?? this.billId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      discount: discount ?? this.discount,
      totalPrice: totalPrice ?? this.totalPrice,
    );
  }
}

// Extension for database serialization
extension LineItemDatabaseExtension on LineItem {
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bill_id': billId,
      'product_id': productId,
      'quantity': quantity,
      'unit_price': unitPrice,
      'discount': discount,
      'total_price': totalPrice,
    };
  }

  static LineItem fromMap(Map<String, dynamic> map) {
    return LineItem(
      id: map['id'] as String,
      billId: map['bill_id'] as String,
      productId: map['product_id'] as String,
      productName: map['product_name'] as String?,
      quantity: map['quantity'] as int,
      unitPrice: map['unit_price'] as double,
      discount: map['discount'] as double,
      totalPrice: map['total_price'] as double,
    );
  }
}
