import 'package:flutter/material.dart';
import 'package:craftshop/domain/models/product.dart';
import 'package:craftshop/domain/models/line_item.dart';
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
      // Initialize discount controller with current value
      _discountController.text =
          ref.read(billProvider).discountAmount.toString();
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

    // Directly add the product to the bill with quantity 1
    ref.read(billProvider.notifier).addLineItemFromProduct(product, 1);
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
                leading: IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20),
                  onPressed:
                      () =>
                          ref.read(billProvider.notifier).removeLineItem(index),
                ),

                contentPadding: EdgeInsets.zero,
                title: Text(
                  lineItem.productName ?? 'Unknown Product',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Row(
                  children: [
                    // Decrease quantity button
                    IconButton(
                      icon: const Icon(
                        Icons.remove_circle_outline,
                        size: 20,
                        color: Colors.red,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      visualDensity: VisualDensity.compact,
                      onPressed:
                          lineItem.quantity > 1
                              ? () {
                                final updatedLineItem = LineItem.create(
                                  billId: lineItem.billId,
                                  productId: lineItem.productId,
                                  productName: lineItem.productName,
                                  quantity: lineItem.quantity - 1,
                                  unitPrice: lineItem.unitPrice,
                                  discount: lineItem.discount,
                                );
                                ref
                                    .read(billProvider.notifier)
                                    .updateLineItem(index, updatedLineItem);
                              }
                              : null,
                    ),

                    // Quantity display
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        '${lineItem.quantity}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),

                    // Increase quantity button
                    IconButton(
                      icon: const Icon(
                        Icons.add_circle_outline,
                        size: 20,
                        color: Colors.green,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      visualDensity: VisualDensity.compact,
                      onPressed: () {
                        final updatedLineItem = LineItem.create(
                          billId: lineItem.billId,
                          productId: lineItem.productId,
                          productName: lineItem.productName,
                          quantity: lineItem.quantity + 1,
                          unitPrice: lineItem.unitPrice,
                          discount: lineItem.discount,
                        );
                        ref
                            .read(billProvider.notifier)
                            .updateLineItem(index, updatedLineItem);
                      },
                    ),

                    const SizedBox(width: 4),

                    Text('x ${currencyFormat.format(lineItem.unitPrice)}'),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      currencyFormat.format(lineItem.totalPrice),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
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

        // Update discount controller text when bill state changes
        // This ensures the text field updates when bill is cleared
        if (_discountController.text != billState.discountAmount.toString()) {
          _discountController.text = billState.discountAmount.toString();
        }
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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text('Discount'),
                  SizedBox(
                    width: 120,
                    height: 40,
                    child: TextField(
                      controller: _discountController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      textAlign: TextAlign.right,
                      style: const TextStyle(fontSize: 14),
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 12,
                        ),
                        prefixText: '\$',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                      onSubmitted: (value) {
                        final discountAmount = double.tryParse(value) ?? 0.0;
                        ref
                            .read(billProvider.notifier)
                            .setDiscountAmount(discountAmount);
                      },
                      onTapOutside: (_) {
                        // Apply discount when user taps outside
                        final discountAmount =
                            double.tryParse(_discountController.text) ?? 0.0;
                        ref
                            .read(billProvider.notifier)
                            .setDiscountAmount(discountAmount);
                      },
                    ),
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
                            // Reset bill creation status
                            ref.read(billProvider.notifier).resetCreationStatus();
                            
                            // Refresh product list to show updated stock values
                            ref.read(productProvider.notifier).loadProducts();
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
