import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:craftshop/core/di/service_locator.dart';
import 'package:craftshop/utils/logger.dart';
import 'package:craftshop/domain/models/product.dart';
import 'package:craftshop/domain/repositories/product_repository.dart';
import 'package:craftshop/domain/repositories/category_repository.dart';

enum ProductState { initial, loading, loaded, error }

class ProductViewModel {
  final List<Product> products;
  final List<Product> filteredProducts;
  final Product? selectedProduct;
  final ProductState state;
  final String? errorMessage;
  final List<Map<String, dynamic>> categories; // Contains id and name pairs

  const ProductViewModel({
    this.products = const [],
    this.filteredProducts = const [],
    this.selectedProduct,
    this.state = ProductState.initial,
    this.errorMessage,
    this.categories = const [],
  });

  ProductViewModel copyWith({
    List<Product>? products,
    List<Product>? filteredProducts,
    Product? selectedProduct,
    ProductState? state,
    String? errorMessage,
    List<Map<String, dynamic>>? categories,
  }) {
    return ProductViewModel(
      products: products ?? this.products,
      filteredProducts: filteredProducts ?? this.filteredProducts,
      selectedProduct: selectedProduct,
      state: state ?? this.state,
      errorMessage: errorMessage,
      categories: categories ?? this.categories,
    );
  }
}

class ProductNotifier extends StateNotifier<ProductViewModel> {
  final ProductRepository _productRepository;
  final CategoryRepository _categoryRepository;
  final _logger = AppLogger.getLogger('ProductNotifier');

  ProductNotifier({
    ProductRepository? productRepository,
    CategoryRepository? categoryRepository,
  }) : _productRepository = productRepository ?? getIt<ProductRepository>(),
       _categoryRepository = categoryRepository ?? getIt<CategoryRepository>(),
       super(const ProductViewModel()) {
    loadProducts();
    loadCategories();
  }

  Future<void> loadProducts() async {
    try {
      state = state.copyWith(state: ProductState.loading);
      final products = await _productRepository.getAllProducts();

      // Add category names to products
      final productsWithCategoryNames = await _addCategoryNamesToProducts(
        products,
      );

      state = state.copyWith(
        products: productsWithCategoryNames,
        state: ProductState.loaded,
      );
    } catch (e) {
      state = state.copyWith(
        state: ProductState.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<List<Product>> _addCategoryNamesToProducts(
    List<Product> products,
  ) async {
    final categoryMap = <String, String>{};
    for (final product in products) {
      if (!categoryMap.containsKey(product.categoryId)) {
        final category = await _categoryRepository.getCategoryById(
          product.categoryId,
        );
        if (category != null) {
          categoryMap[product.categoryId] = category.name;
        }
      }
    }

    return products.map((product) {
      return product.copyWith(
        categoryName: categoryMap[product.categoryId] ?? 'Unknown',
      );
    }).toList();
  }

  Future<void> loadCategories() async {
    try {
      final categories = await _categoryRepository.getAllCategories();
      final categoryList =
          categories
              .map((category) => {'id': category.id, 'name': category.name})
              .toList();
      _logger.info('Categories loaded: $categoryList');
      state = state.copyWith(categories: categoryList);
    } catch (e) {
      // Just log the error, don't change state since this is a secondary operation
      _logger.warning('Error loading categories: $e');
    }
  }

  Future<void> addProduct(Product product) async {
    try {
      state = state.copyWith(state: ProductState.loading);
      await _productRepository.addProduct(product);
      await loadProducts();
    } catch (e) {
      state = state.copyWith(
        state: ProductState.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> updateProduct(Product product) async {
    try {
      state = state.copyWith(state: ProductState.loading);
      await _productRepository.updateProduct(product);
      await loadProducts();
    } catch (e) {
      state = state.copyWith(
        state: ProductState.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      state = state.copyWith(state: ProductState.loading);
      await _productRepository.deleteProduct(id);
      await loadProducts();
    } catch (e) {
      state = state.copyWith(
        state: ProductState.error,
        errorMessage: e.toString(),
      );
    }
  }

  void selectProduct(String? id) {
    if (id == null) {
      state = state.copyWith(selectedProduct: null);
      return;
    }

    final product = state.products.firstWhere(
      (product) => product.id == id,
      orElse: () => state.selectedProduct!,
    );

    state = state.copyWith(selectedProduct: product);
  }

  Future<void> filterProductsByCategory(String categoryId) async {
    try {
      state = state.copyWith(state: ProductState.loading);
      List<Product> products;

      if (categoryId == 'all') {
        products = await _productRepository.getAllProducts();
      } else {
        products = await _productRepository.getProductsByCategory(categoryId);
      }

      // Add category names to products
      final productsWithCategoryNames = await _addCategoryNamesToProducts(
        products,
      );

      state = state.copyWith(
        products: productsWithCategoryNames,
        state: ProductState.loaded,
      );
    } catch (e) {
      state = state.copyWith(
        state: ProductState.error,
        errorMessage: e.toString(),
      );
    }
  }

  // Search products by name
  void searchProducts(String query) {
    if (query.isEmpty) {
      // If query is empty, reset to show all products
      state = state.copyWith(filteredProducts: const []);
      return;
    }

    final lowercaseQuery = query.toLowerCase();
    final filtered =
        state.products
            .where(
              (product) =>
                  product.name.toLowerCase().contains(lowercaseQuery) ||
                  product.description.toLowerCase().contains(lowercaseQuery),
            )
            .toList();

    state = state.copyWith(filteredProducts: filtered);
  }
}

final productProvider =
    StateNotifierProvider<ProductNotifier, ProductViewModel>(
      (ref) => ProductNotifier(),
    );
