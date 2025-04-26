
import 'package:uuid/uuid.dart';

class Product {
  final String id;
  final String name;
  final String description;
  final String sku;
  final String categoryId;
  final String? categoryName;
  final double price;
  final int stock;
  final bool isActive;
  final String? imageUrl;

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.sku,
    required this.categoryId,
    this.categoryName,
    required this.price,
    required this.stock,
    this.isActive = true,
    this.imageUrl,
  });

  factory Product.create({
    required String name,
    required String description,
    required String sku,
    required String categoryId,
    String? categoryName,
    required double price,
    required int stock,
    bool isActive = true,
    String? imageUrl,
  }) {
    return Product(
      id: const Uuid().v4(),
      name: name,
      description: description,
      sku: sku,
      categoryId: categoryId,
      categoryName: categoryName,
      price: price,
      stock: stock,
      isActive: isActive,
      imageUrl: imageUrl,
    );
  }

  Product copyWith({
    String? id,
    String? name,
    String? description,
    String? sku,
    String? categoryId,
    String? categoryName,
    double? price,
    int? stock,
    bool? isActive,
    String? imageUrl,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      sku: sku ?? this.sku,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      isActive: isActive ?? this.isActive,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}

// Extension for database serialization
extension ProductDatabaseExtension on Product {
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'sku': sku,
      'category_id': categoryId,
      'price': price,
      'stock': stock,
      'is_active': isActive ? 1 : 0,
    };
  }

  static Product fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      sku: map['sku'] as String,
      categoryId: map['category_id'] as String,
      categoryName: map['category_name'] as String?,
      price: map['price'] as double,
      stock: map['stock'] as int,
      isActive: (map['is_active'] as int) == 1,
      imageUrl: null,
    );
  }
}
