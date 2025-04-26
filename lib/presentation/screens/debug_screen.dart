import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:craftshop/domain/models/product.dart';
import 'package:craftshop/domain/models/category.dart';
import 'package:craftshop/presentation/view_models/product_view_model.dart';
import 'package:craftshop/presentation/view_models/category_view_model.dart';
import 'package:craftshop/utils/database_utils.dart';

class DebugScreen extends ConsumerStatefulWidget {
  const DebugScreen({super.key});

  @override
  ConsumerState<DebugScreen> createState() => _DebugScreenState();
}

class _DebugScreenState extends ConsumerState<DebugScreen> {
  bool _isResetInProgress = false;
  String _status = 'Ready';

  @override
  Widget build(BuildContext context) {
    final productViewModel = ref.watch(productProvider);
    final categoryViewModel = ref.watch(categoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Database Debug'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Database Status', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 12),
                    ListTile(
                      leading: Icon(
                        _isResetInProgress ? Icons.sync : Icons.check_circle,
                        color: _isResetInProgress ? Colors.orange : Colors.green,
                      ),
                      title: Text(_status),
                      subtitle: const Text('Current status of the database'),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _isResetInProgress
                          ? null
                          : () => _resetDatabase(),
                      child: const Text('Force Database Reset'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Categories (${categoryViewModel.categories.length})', 
                               style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 12),
                          if (categoryViewModel.categories.isEmpty)
                            const Text('No categories found')
                          else
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: categoryViewModel.categories.length,
                              itemBuilder: (context, index) {
                                final category = categoryViewModel.categories[index];
                                return ListTile(
                                  title: Text(category.name),
                                  subtitle: Text(category.id),
                                );
                              },
                            ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _addSampleCategory,
                            child: const Text('Add Sample Category'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Products (${productViewModel.products.length})', 
                               style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 12),
                          if (productViewModel.state == ProductState.loading)
                            const Center(child: CircularProgressIndicator())
                          else if (productViewModel.products.isEmpty)
                            const Text('No products found')
                          else
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: productViewModel.products.length,
                              itemBuilder: (context, index) {
                                final product = productViewModel.products[index];
                                return ListTile(
                                  title: Text(product.name),
                                  subtitle: Text('SKU: ${product.sku}, Category: ${product.categoryName}'),
                                  trailing: Text('\$${product.price.toStringAsFixed(2)}'),
                                );
                              },
                            ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: categoryViewModel.categories.isEmpty
                                ? null
                                : _addSampleProduct,
                            child: const Text('Add Sample Product'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _resetDatabase() async {
    setState(() {
      _isResetInProgress = true;
      _status = 'Resetting database...';
    });

    try {
      await DatabaseUtils.forceReset();
      setState(() {
        _status = 'Database reset successfully';
      });
      
      // Reload categories and products
      await ref.read(categoryProvider.notifier).loadCategories();
      await ref.read(productProvider.notifier).loadProducts();
      await ref.read(productProvider.notifier).loadCategories();
      
    } catch (e) {
      setState(() {
        _status = 'Error: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isResetInProgress = false;
      });
    }
  }

  Future<void> _addSampleCategory() async {
    try {
      setState(() {
        _status = 'Adding sample category...';
      });
      
      final newCategory = Category.create(
        name: 'Sample Category ${DateTime.now().millisecondsSinceEpoch}',
        description: 'This is a sample category for testing',
        color: Colors.blue,
      );
      
      await ref.read(categoryProvider.notifier).addCategory(newCategory.name, newCategory.description, newCategory.color ?? Colors.blue);
      setState(() {
        _status = 'Sample category added successfully';
      });
    } catch (e) {
      setState(() {
        _status = 'Error adding category: ${e.toString()}';
      });
    }
  }

  Future<void> _addSampleProduct() async {
    try {
      setState(() {
        _status = 'Adding sample product...';
      });
      
      final categories = ref.read(categoryProvider).categories;
      if (categories.isEmpty) {
        setState(() {
          _status = 'Error: No categories available. Add a category first.';
        });
        return;
      }
      
      final randomCategory = categories.first;
      
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final newProduct = Product.create(
        name: 'Sample Product $timestamp',
        description: 'This is a sample product for testing purposes',
        sku: 'SKU-$timestamp',
        categoryId: randomCategory.id,
        price: 19.99,
        stock: 10,
      );
      
      await ref.read(productProvider.notifier).addProduct(newProduct);
      setState(() {
        _status = 'Sample product added successfully';
      });
    } catch (e) {
      setState(() {
        _status = 'Error adding product: ${e.toString()}';
      });
    }
  }
}
