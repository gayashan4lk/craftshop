import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:craftshop/domain/models/bill.dart';
import 'package:craftshop/domain/models/line_item.dart';
import 'package:craftshop/domain/repositories/bill_repository.dart';
import 'package:craftshop/domain/repositories/line_item_repository.dart';
import 'package:craftshop/domain/repositories/product_repository.dart';
import 'package:craftshop/domain/models/product.dart';
import 'package:craftshop/core/di/service_locator.dart';

enum BillCreationStatus { idle, loading, success, error }

class BillState {
  final List<Bill> bills;
  final List<LineItem> currentLineItems;
  final double subtotal;
  final double taxAmount;
  final double discountAmount;
  final double totalAmount;
  final bool isLoading;
  final Bill? selectedBill;
  final String? errorMessage;
  final BillCreationStatus creationStatus;
  final String? createdBillId;

  const BillState({
    this.bills = const [],
    this.currentLineItems = const [],
    this.subtotal = 0.0,
    this.taxAmount = 0.0,
    this.discountAmount = 0.0,
    this.totalAmount = 0.0,
    this.isLoading = false,
    this.selectedBill,
    this.errorMessage,
    this.creationStatus = BillCreationStatus.idle,
    this.createdBillId,
  });

  BillState copyWith({
    List<Bill>? bills,
    List<LineItem>? currentLineItems,
    double? subtotal,
    double? taxAmount,
    double? discountAmount,
    double? totalAmount,
    bool? isLoading,
    Bill? selectedBill,
    String? errorMessage,
    BillCreationStatus? creationStatus,
    String? createdBillId,
  }) {
    return BillState(
      bills: bills ?? this.bills,
      currentLineItems: currentLineItems ?? this.currentLineItems,
      subtotal: subtotal ?? this.subtotal,
      taxAmount: taxAmount ?? this.taxAmount,
      discountAmount: discountAmount ?? this.discountAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      isLoading: isLoading ?? this.isLoading,
      selectedBill: selectedBill ?? this.selectedBill,
      errorMessage: errorMessage,
      creationStatus: creationStatus ?? this.creationStatus,
      createdBillId: createdBillId ?? this.createdBillId,
    );
  }
}

class BillNotifier extends StateNotifier<BillState> {
  final BillRepository _billRepository;

  BillNotifier({
    BillRepository? billRepository,
    LineItemRepository? lineItemRepository,
    ProductRepository? productRepository,
  }) : _billRepository = billRepository ?? getIt<BillRepository>(),
       super(const BillState());

  Future<void> loadBills() async {
    state = state.copyWith(isLoading: true);

    try {
      // Load all bills (line items are loaded separately in the UI)
      final bills = await _billRepository.getAllBills();
      state = state.copyWith(bills: bills, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      rethrow;
    }
  }

  Future<void> getBillById(String id) async {
    state = state.copyWith(isLoading: true);

    try {
      final bill = await _billRepository.getBillById(
        id,
        includeLineItems: true,
      );
      state = state.copyWith(selectedBill: bill, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      rethrow;
    }
  }

  Future<List<Bill>> getRecentBills(int limit) async {
    try {
      return await _billRepository.getRecentBills(limit);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      rethrow;
    }
  }
  
  Future<Map<String, int>> getLineItemCountsForBills(List<String> billIds) async {
    try {
      return await _billRepository.getLineItemCountsForBills(billIds);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return {};
    }
  }

  void addLineItem(LineItem lineItem) {
    final updatedLineItems = [...state.currentLineItems, lineItem];
    _recalculateAmounts(updatedLineItems);
  }

  Future<void> addLineItemFromProduct(Product product, int quantity) async {
    // Create a temporary bill ID for the line item
    const tempBillId = 'temp';

    final lineItem = LineItem.create(
      billId: tempBillId,
      productId: product.id,
      productName: product.name,
      quantity: quantity,
      unitPrice: product.price,
    );

    addLineItem(lineItem);
  }

  void updateLineItem(int index, LineItem lineItem) {
    if (index >= 0 && index < state.currentLineItems.length) {
      final updatedLineItems = [...state.currentLineItems];
      updatedLineItems[index] = lineItem;
      _recalculateAmounts(updatedLineItems);
    }
  }

  void removeLineItem(int index) {
    if (index >= 0 && index < state.currentLineItems.length) {
      final updatedLineItems = [...state.currentLineItems];
      updatedLineItems.removeAt(index);
      _recalculateAmounts(updatedLineItems);
    }
  }

  void _recalculateAmounts(List<LineItem> lineItems) {
    final subtotal = lineItems.fold(0.0, (sum, item) => sum + item.totalPrice);

    // Apply default tax rate of 7%
    final taxAmount = subtotal * 0.07;

    final totalAmount = subtotal + taxAmount - state.discountAmount;

    state = state.copyWith(
      currentLineItems: lineItems,
      subtotal: subtotal,
      taxAmount: taxAmount,
      totalAmount: totalAmount,
    );
  }

  void setDiscountAmount(double amount) {
    state = state.copyWith(discountAmount: amount);
    _recalculateAmounts(state.currentLineItems);
  }

  Future<String> saveBill() async {
    if (state.currentLineItems.isEmpty) {
      throw Exception('Cannot save a bill without line items');
    }

    final bill = Bill.create(
      date: DateTime.now(),
      subtotal: state.subtotal,
      taxAmount: state.taxAmount,
      discountAmount: state.discountAmount,
      totalAmount: state.totalAmount,
    );

    // Update line items with the new bill ID
    final lineItems =
        state.currentLineItems
            .map(
              (item) => LineItem.create(
                billId: bill.id,
                productId: item.productId,
                productName: item.productName,
                quantity: item.quantity,
                unitPrice: item.unitPrice,
                discount: item.discount,
              ),
            )
            .toList();

    final billId = await _billRepository.addBill(bill, lineItems);

    // Reset current bill state including discount
    state = state.copyWith(discountAmount: 0.0);
    _recalculateAmounts([]);

    return billId;
  }

  void clearCurrentBill() {
    // Reset discount amount to zero and clear line items
    state = state.copyWith(discountAmount: 0.0);
    _recalculateAmounts([]);
    
    // Also reset the UI state for created bills
    state = state.copyWith(
      creationStatus: BillCreationStatus.idle,
      createdBillId: null,
      errorMessage: null
    );
  }

  Future<void> deleteBill(String id) async {
    await _billRepository.deleteBill(id);
    await loadBills(); // Refresh the list
  }

  // New method for creating bill with UI state management
  Future<void> createBillWithUIStates() async {
    try {
      // Set state to loading
      state = state.copyWith(
        creationStatus: BillCreationStatus.loading,
        errorMessage: null,
        createdBillId: null,
      );

      if (state.currentLineItems.isEmpty) {
        state = state.copyWith(
          creationStatus: BillCreationStatus.error,
          errorMessage: 'Cannot save a bill without line items',
        );
        return;
      }

      // Get product repository to update inventory
      final productRepository = getIt<ProductRepository>();
      
      // Track inventory updates to make
      final inventoryUpdates = <String, int>{};
      
      // Aggregate quantities by product ID
      for (final lineItem in state.currentLineItems) {
        final productId = lineItem.productId;
        final quantity = lineItem.quantity;
        
        // Add to inventory updates (combine quantities for same product)
        inventoryUpdates[productId] = (inventoryUpdates[productId] ?? 0) + quantity;
      }
      
      // Check stock levels and update inventory
      for (final entry in inventoryUpdates.entries) {
        final productId = entry.key;
        final quantityToReduce = entry.value;
        
        // Get current product to check inventory
        final product = await productRepository.getProductById(productId);
        if (product == null) {
          state = state.copyWith(
            creationStatus: BillCreationStatus.error,
            errorMessage: 'Product not found in inventory',
          );
          return;
        }
        
        // Check if we have enough inventory
        if (product.stock < quantityToReduce) {
          state = state.copyWith(
            creationStatus: BillCreationStatus.error,
            errorMessage: 'Insufficient stock for ${product.name}',
          );
          return;
        }
        
        // Update product inventory
        final updatedProduct = product.copyWith(stock: product.stock - quantityToReduce);
        await productRepository.updateProduct(updatedProduct);
      }

      // Save the bill and get ID
      final billId = await saveBill();

      // Update state with success
      state = state.copyWith(
        creationStatus: BillCreationStatus.success,
        createdBillId: billId,
      );
    } catch (e) {
      // Update state with error
      state = state.copyWith(
        creationStatus: BillCreationStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  // Reset creation status to idle
  void resetCreationStatus() {
    state = state.copyWith(
      creationStatus: BillCreationStatus.idle,
      errorMessage: null,
      createdBillId: null,
    );
  }
}

final billProvider = StateNotifierProvider<BillNotifier, BillState>((ref) {
  return BillNotifier();
});
