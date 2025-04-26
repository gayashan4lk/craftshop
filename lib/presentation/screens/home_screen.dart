import 'package:flutter/material.dart';
import 'package:craftshop/domain/models/product.dart';
import 'package:craftshop/presentation/view_models/bill_view_model.dart';
import 'package:craftshop/presentation/view_models/product_view_model.dart'
    show productProvider, ProductState;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final currencyFormat = NumberFormat.currency(symbol: '\$');
  final _searchController = TextEditingController();
  final _discountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load products when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(productProvider.notifier).loadProducts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _discountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product selection column
                Expanded(
                  flex: 3,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSearchBar(),
                          const SizedBox(height: 16),
                          _buildProductGrid(),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                // Bill details column
                Expanded(
                  flex: 2,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Current Bill',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildLineItemsList(),
                          const Divider(),
                          _buildBillSummary(),
                          const SizedBox(height: 16),
                          _buildActionButtons(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'New Bill',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        OutlinedButton.icon(
          onPressed: () {
            // View past bills functionality
          },
          icon: const Icon(Icons.history),
          label: const Text('View Past Bills'),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Search products...',
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 16,
        ),
      ),
      onChanged: (value) {
        // Filter products as user types
        ref.read(productProvider.notifier).searchProducts(value);
      },
    );
  }

  Widget _buildProductGrid() {
    return Consumer(
      builder: (context, ref, child) {
        final productViewModel = ref.watch(productProvider);
        if (productViewModel.state == ProductState.loading) {
          return const Expanded(
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final products =
            productViewModel.filteredProducts.isNotEmpty
                ? productViewModel.filteredProducts
                : productViewModel.products;

        if (products.isEmpty) {
          return const Expanded(
            child: Center(child: Text('No products found')),
          );
        }

        return Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.only(top: 16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1.2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return _buildProductCard(product);
            },
          ),
        );
      },
    );
  }

  Widget _buildProductCard(Product product) {
    return InkWell(
      onTap: () => _addProductToBill(product),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              product.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              product.sku,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  currencyFormat.format(product.price),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Stock: ${product.stock}',
                  style: TextStyle(
                    color: product.stock > 0 ? Colors.green : Colors.red,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _addProductToBill(Product product) {
    if (product.stock <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product is out of stock'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        int quantity = 1;
        return AlertDialog(
          title: Text('Add ${product.name}'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Text('Quantity: '),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed:
                            quantity > 1
                                ? () => setState(() => quantity--)
                                : null,
                        icon: const Icon(Icons.remove_circle_outline),
                      ),
                      Text(
                        quantity.toString(),
                        style: const TextStyle(fontSize: 16),
                      ),
                      IconButton(
                        onPressed:
                            quantity < product.stock
                                ? () => setState(() => quantity++)
                                : null,
                        icon: const Icon(Icons.add_circle_outline),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Total: ${currencyFormat.format(product.price * quantity)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ref
                    .read(billProvider.notifier)
                    .addLineItemFromProduct(product, quantity);
              },
              child: const Text('Add to Bill'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLineItemsList() {
    return Consumer(
      builder: (context, ref, child) {
        final billState = ref.watch(billProvider);
        final lineItems = billState.currentLineItems;

        if (lineItems.isEmpty) {
          return const Expanded(
            child: Center(
              child: Text(
                'No items added yet. Click on a product to add it to the bill.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ),
          );
        }

        return Expanded(
          child: ListView.separated(
            itemCount: lineItems.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final lineItem = lineItems[index];
              return ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  lineItem.productName ?? 'Unknown Product',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  '${lineItem.quantity} x ${currencyFormat.format(lineItem.unitPrice)}',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      currencyFormat.format(lineItem.totalPrice),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed:
                          () => ref
                              .read(billProvider.notifier)
                              .removeLineItem(index),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildBillSummary() {
    return Consumer(
      builder: (context, ref, child) {
        final billState = ref.watch(billProvider);
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Subtotal'),
                  Text(currencyFormat.format(billState.subtotal)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Tax (7%)'),
                  Text(currencyFormat.format(billState.taxAmount)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Discount'),
                  Row(
                    children: [
                      Text(
                        '-${currencyFormat.format(billState.discountAmount)}',
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, size: 16),
                        onPressed: () => _showDiscountDialog(context),
                      ),
                    ],
                  ),
                ],
              ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  Text(
                    currencyFormat.format(billState.totalAmount),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDiscountDialog(BuildContext context) {
    final billNotifier = ref.read(billProvider.notifier);
    _discountController.text = ref.read(billProvider).discountAmount.toString();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Discount'),
          content: TextField(
            controller: _discountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Discount Amount',
              prefixText: '\$',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final discountAmount =
                    double.tryParse(_discountController.text) ?? 0.0;
                billNotifier.setDiscountAmount(discountAmount);
                Navigator.pop(context);
              },
              child: const Text('Apply'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildActionButtons() {
    return Consumer(
      builder: (context, ref, child) {
        final billState = ref.watch(billProvider);
        final hasItems = billState.currentLineItems.isNotEmpty;

        // Handle different bill creation states
        switch (billState.creationStatus) {
          case BillCreationStatus.loading:
            // Show loading state
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 8),
                  Text('Creating bill...'),
                ],
              ),
            );

          case BillCreationStatus.success:
            // Show success dialog when bill is created
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (billState.createdBillId != null) {
                showDialog(
                  context: context,
                  builder: (ctx) {
                    return AlertDialog(
                      title: const Text('Bill Completed'),
                      content: Text(
                        'Bill #${billState.createdBillId} has been created successfully.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            ref
                                .read(billProvider.notifier)
                                .resetCreationStatus();
                          },
                          child: const Text('OK'),
                        ),
                      ],
                    );
                  },
                );
              }
            });
            // Fall through to show regular buttons
            break;

          case BillCreationStatus.error:
            // Show error snackbar
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Error creating bill: ${billState.errorMessage}',
                  ),
                  backgroundColor: Colors.red,
                ),
              );
              // Reset status after showing error
              ref.read(billProvider.notifier).resetCreationStatus();
            });
            // Fall through to show regular buttons
            break;

          case BillCreationStatus.idle:
            // Default no-op for idle state
            break;
        }

        // Show regular buttons for idle state or after handling success/error
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            OutlinedButton(
              onPressed:
                  hasItems
                      ? () => ref.read(billProvider.notifier).clearCurrentBill()
                      : null,
              child: const Text('Clear'),
            ),
            const SizedBox(width: 16),
            ElevatedButton.icon(
              onPressed: hasItems ? () => _createBill(context) : null,
              icon: const Icon(Icons.check),
              label: const Text('Create Bill'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        );
      },
    );
  }

  void _createBill(BuildContext context) {
    // Use the notifier's createBillWithUIStates method to handle the async logic
    // This avoids BuildContext async gap issues entirely
    ref.read(billProvider.notifier).createBillWithUIStates();
  }
}
