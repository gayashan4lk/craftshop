import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';

part 'category.freezed.dart';
part 'category.g.dart';

@freezed
class Category with _$Category {
  const factory Category({
    required String id,
    required String name,
    required String description,
    @JsonKey(includeFromJson: false, includeToJson: false) Color? color,
    @Default(0) int itemCount,
  }) = _Category;

  factory Category.create({
    required String name,
    required String description,
    required Color color,
    int itemCount = 0,
  }) {
    return Category(
      id: const Uuid().v4(),
      name: name,
      description: description,
      color: color,
      itemCount: itemCount,
    );
  }

  factory Category.fromJson(Map<String, dynamic> json) =>
      _$CategoryFromJson(json);
}

// Extension for color serialization
extension CategoryColorExtension on Category {
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'color_value':
          color?.value ?? 0xFF2196F3, // 0xFF2196F3 is Colors.blue's value
      'item_count': itemCount,
    };
  }

  static Category fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id']?.toString() ?? const Uuid().v4(),
      name: map['name']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      color:
          map['color_value'] != null
              ? Color(map['color_value'] as int)
              : Colors.blue,
      itemCount: map['item_count'] != null ? map['item_count'] as int : 0,
    );
  }
}
