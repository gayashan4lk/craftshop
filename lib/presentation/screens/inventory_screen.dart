import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:craftshop/domain/models/product.dart';
import 'package:craftshop/presentation/view_models/product_view_model.dart';

class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({super.key});

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen> {
  // Form controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _skuController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();

  String _selectedCategoryId = 'all';
  bool _isActive = true;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    // Load products when screen initializes
    Future.microtask(() {
      ref.read(productProvider.notifier).loadProducts();
      ref.read(productProvider.notifier).loadCategories();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _skuController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildFilterBar(),
          const SizedBox(height: 16),
          Expanded(child: _buildInventoryTable()),
          const SizedBox(height: 16),
          _buildPagination(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Inventory',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        Row(
          children: [
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.file_download_outlined),
              label: const Text('Export'),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: () => _showProductForm(),
              icon: const Icon(Icons.add),
              label: const Text('Add Product'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterBar() {
    final viewModel = ref.watch(productProvider);

    return Row(
      children: [
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search inventory...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onChanged: (value) {
              // We'd implement search functionality here in a real app
              // For now it's just a placeholder field
            },
          ),
        ),
        const SizedBox(width: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedCategoryId,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedCategoryId = newValue;
                  });
                  ref
                      .read(productProvider.notifier)
                      .filterProductsByCategory(newValue);
                }
              },
              items: [
                const DropdownMenuItem<String>(
                  value: 'all',
                  child: Text('All Categories'),
                ),
                ...viewModel.categories.map<DropdownMenuItem<String>>((
                  category,
                ) {
                  return DropdownMenuItem<String>(
                    value: category['id'] as String,
                    child: Text(category['name'] as String),
                  );
                }).toList(),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        OutlinedButton.icon(
          onPressed: () => _showFilters(),
          icon: const Icon(Icons.filter_list),
          label: const Text('More Filters'),
        ),
      ],
    );
  }

  void _showFilters() {
    // A placeholder for advanced filtering functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Advanced filtering coming soon')),
    );
  }

  // Product CRUD Operations
  void _showProductForm() {
    final viewModel = ref.read(productProvider);
    setState(() {
      _isEditing = false;
      _nameController.clear();
      _descriptionController.clear();
      _skuController.clear();
      _priceController.clear();
      _stockController.clear();
      _selectedCategoryId =
          viewModel.categories.isNotEmpty
              ? viewModel.categories.first['id'] as String
              : 'all';
      _isActive = true;
    });

    showDialog(
      context: context,
      builder: (context) => _buildProductDialog('Add New Product'),
    );
  }

  void _editProduct(Product product) {
    setState(() {
      _isEditing = true;
      _nameController.text = product.name;
      _descriptionController.text = product.description;
      _skuController.text = product.sku;
      _priceController.text = product.price.toString();
      _stockController.text = product.stock.toString();
      _selectedCategoryId = product.categoryId;
      _isActive = product.isActive;
    });

    showDialog(
      context: context,
      builder: (context) => _buildProductDialog('Edit Product'),
    );
  }

  void _deleteProduct(Product product) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirm Delete'),
            content: Text('Are you sure you want to delete ${product.name}?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  ref.read(productProvider.notifier).deleteProduct(product.id);
                },
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }

  void _saveProduct() {
    // Basic validation
    if (_nameController.text.isEmpty ||
        _skuController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _stockController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    try {
      final price = double.parse(_priceController.text);
      final stock = int.parse(_stockController.text);

      final viewModel = ref.read(productProvider);
      final productNotifier = ref.read(productProvider.notifier);

      if (_isEditing && viewModel.selectedProduct != null) {
        final updatedProduct = viewModel.selectedProduct!.copyWith(
          name: _nameController.text,
          description: _descriptionController.text,
          sku: _skuController.text,
          categoryId: _selectedCategoryId,
          price: price,
          stock: stock,
          isActive: _isActive,
        );

        productNotifier.updateProduct(updatedProduct);
      } else {
        final newProduct = Product.create(
          name: _nameController.text,
          description: _descriptionController.text,
          sku: _skuController.text,
          categoryId: _selectedCategoryId,
          price: price,
          stock: stock,
          isActive: _isActive,
        );

        productNotifier.addProduct(newProduct);
      }

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Invalid input: ${e.toString()}')));
    }
  }

  Widget _buildProductDialog(String title) {
    final viewModel = ref.watch(productProvider);

    return AlertDialog(
      title: Text(title),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Product Name',
                  hintText: '',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: '',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _skuController,
                      decoration: const InputDecoration(
                        labelText: 'SKU',
                        hintText: '',
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Category'),
                      value: _selectedCategoryId,
                      items:
                          viewModel.categories.map((category) {
                            return DropdownMenuItem<String>(
                              value: category['id'] as String,
                              child: Text(category['name'] as String),
                            );
                          }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedCategoryId = value;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _priceController,
                      decoration: const InputDecoration(
                        labelText: 'Price',
                        prefixText: '\$',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _stockController,
                      decoration: const InputDecoration(labelText: 'Stock'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Checkbox(
                    value: _isActive,
                    onChanged: (value) {
                      setState(() {
                        _isActive = value ?? true;
                      });
                    },
                  ),
                  const Text('Product is active'),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveProduct,
          child: Text(_isEditing ? 'Update' : 'Save'),
        ),
      ],
    );
  }

  Widget _buildInventoryTable() {
    final viewModel = ref.watch(productProvider);

    if (viewModel.state == ProductState.loading) {
      return const Card(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(50.0),
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    if (viewModel.state == ProductState.error) {
      return Card(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(50.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(viewModel.errorMessage ?? 'An error occurred'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed:
                      () => ref.read(productProvider.notifier).loadProducts(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (viewModel.products.isEmpty) {
      return Card(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(50.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.inventory_2_outlined,
                  size: 48,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                const Text('No products found'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _showProductForm(),
                  child: const Text('Add New Product'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: DataTable2(
          columnSpacing: 12,
          horizontalMargin: 12,
          minWidth: 600,
          columns: const [
            DataColumn2(
              label: Text(
                'Product',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              size: ColumnSize.L,
            ),
            DataColumn(
              label: Text('SKU', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            DataColumn(
              label: Text(
                'Category',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Price',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              numeric: true,
            ),
            DataColumn(
              label: Text(
                'Stock',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              numeric: true,
            ),
            DataColumn(
              label: Text(
                'Status',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Actions',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
          rows: List<DataRow>.generate(viewModel.products.length, (index) {
            final product = viewModel.products[index];
            return DataRow(
              selected: viewModel.selectedProduct?.id == product.id,
              onSelectChanged: (selected) {
                if (selected ?? false) {
                  ref.read(productProvider.notifier).selectProduct(product.id);
                } else {
                  ref.read(productProvider.notifier).selectProduct(null);
                }
              },
              cells: [
                DataCell(
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child:
                            product.imageUrl != null
                                ? ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: Image.network(
                                    product.imageUrl!,
                                    fit: BoxFit.cover,
                                  ),
                                )
                                : Center(
                                  child: Text(
                                    product.name.isNotEmpty
                                        ? product.name[0].toUpperCase()
                                        : 'P',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          product.name,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ),
                    ],
                  ),
                ),
                DataCell(Text(product.sku)),
                DataCell(Text(product.categoryName ?? 'Unknown')),
                DataCell(Text('\$${product.price.toStringAsFixed(2)}')),
                DataCell(Text(product.stock.toString())),
                DataCell(
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: product.isActive ? Colors.green : Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(product.isActive ? 'Active' : 'Inactive'),
                    ],
                  ),
                ),
                DataCell(
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 20),
                        onPressed: () => _editProduct(product),
                        tooltip: 'Edit',
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 20),
                        onPressed: () => _deleteProduct(product),
                        tooltip: 'Delete',
                      ),
                    ],
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildPagination() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Showing 1-15 of 120 items',
          style: TextStyle(color: Colors.grey[600]),
        ),
        Row(
          children: [
            IconButton(onPressed: () {}, icon: const Icon(Icons.chevron_left)),
            _buildPageButton('1', isSelected: true),
            _buildPageButton('2'),
            _buildPageButton('3'),
            const Text('...'),
            _buildPageButton('8'),
            IconButton(onPressed: () {}, icon: const Icon(Icons.chevron_right)),
          ],
        ),
      ],
    );
  }

  Widget _buildPageButton(String text, {bool isSelected = false}) {
    return Container(
      width: 32,
      height: 32,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color:
              isSelected
                  ? Theme.of(context).primaryColor
                  : Colors.grey.shade300,
        ),
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
