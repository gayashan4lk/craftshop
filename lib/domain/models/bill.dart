import 'package:uuid/uuid.dart';
import 'package:craftshop/domain/models/line_item.dart';

class Bill {
  final String id;
  final DateTime date;
  final double subtotal;
  final double taxAmount;
  final double discountAmount;
  final double totalAmount;
  final DateTime createdAt;
  final List<LineItem> lineItems;

  const Bill({
    required this.id,
    required this.date,
    required this.subtotal,
    required this.taxAmount,
    required this.discountAmount,
    required this.totalAmount,
    required this.createdAt,
    this.lineItems = const [],
  });

  factory Bill.create({
    required DateTime date,
    required double subtotal,
    required double taxAmount,
    required double discountAmount,
    required double totalAmount,
    List<LineItem>? lineItems,
  }) {
    return Bill(
      id: const Uuid().v4(),
      date: date,
      subtotal: subtotal,
      taxAmount: taxAmount,
      discountAmount: discountAmount,
      totalAmount: totalAmount,
      createdAt: DateTime.now(),
      lineItems: lineItems ?? [],
    );
  }

  Bill copyWith({
    String? id,
    DateTime? date,
    double? subtotal,
    double? taxAmount,
    double? discountAmount,
    double? totalAmount,
    DateTime? createdAt,
    List<LineItem>? lineItems,
  }) {
    return Bill(
      id: id ?? this.id,
      date: date ?? this.date,
      subtotal: subtotal ?? this.subtotal,
      taxAmount: taxAmount ?? this.taxAmount,
      discountAmount: discountAmount ?? this.discountAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      createdAt: createdAt ?? this.createdAt,
      lineItems: lineItems ?? this.lineItems,
    );
  }
}

// Extension for database serialization
extension BillDatabaseExtension on Bill {
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.millisecondsSinceEpoch,
      'subtotal': subtotal,
      'tax_amount': taxAmount,
      'discount_amount': discountAmount,
      'total_amount': totalAmount,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  static Bill fromMap(Map<String, dynamic> map, [List<LineItem>? lineItems]) {
    return Bill(
      id: map['id'] as String,
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] as int),
      subtotal: map['subtotal'] as double,
      taxAmount: map['tax_amount'] as double,
      discountAmount: map['discount_amount'] as double,
      totalAmount: map['total_amount'] as double,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      lineItems: lineItems ?? [],
    );
  }
}
