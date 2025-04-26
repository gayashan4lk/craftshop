import 'package:craftshop/domain/models/product.dart';

abstract class ProductRepository {
  Future<List<Product>> getAllProducts();
  Future<List<Product>> getProductsByCategory(String categoryId);
  Future<Product?> getProductById(String id);
  Future<Product?> getProductBySku(String sku);
  Future<void> addProduct(Product product);
  Future<void> updateProduct(Product product);
  Future<void> deleteProduct(String id);
  Future<int> getProductCount();
  Future<int> getProductCountByCategory(String categoryId);
}
