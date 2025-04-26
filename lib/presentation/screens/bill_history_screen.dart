import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:craftshop/domain/models/bill.dart';
import 'package:craftshop/domain/models/line_item.dart';
import 'package:craftshop/presentation/view_models/bill_view_model.dart';

class BillHistoryScreen extends ConsumerStatefulWidget {
  const BillHistoryScreen({super.key});

  @override
  ConsumerState<BillHistoryScreen> createState() => _BillHistoryScreenState();
}

class _BillHistoryScreenState extends ConsumerState<BillHistoryScreen> {
  final currencyFormat = NumberFormat.currency(symbol: '\$');
  final dateFormat = DateFormat('MMM dd, yyyy');
  final timeFormat = DateFormat('hh:mm a');

  Bill? _selectedBill;

  @override
  void initState() {
    super.initState();
    // Load bills when screen initializes
    Future.microtask(() {
      // Load bills first
      ref.read(billProvider.notifier).loadBills();
    });
  }

  // Map to store line item counts by bill ID
  final Map<String, int> _billItemCounts = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Listen for changes in bill state and update when bill list loads
    final billState = ref.watch(billProvider);

    if (!billState.isLoading && billState.bills.isNotEmpty) {
      // If we have bills but no item counts, load them
      if (_billItemCounts.isEmpty) {
        _loadLineItemCounts(billState.bills);
      }
    }

    // Also update when a bill is selected with line items
    if (billState.selectedBill != null &&
        billState.selectedBill!.lineItems.isNotEmpty) {
      final bill = billState.selectedBill!;
      _billItemCounts[bill.id] = bill.lineItems.length;
    }
  }

  // Load line item counts for all bills from the database
  Future<void> _loadLineItemCounts(List<Bill> bills) async {
    final billIds = bills.map((bill) => bill.id).toList();
    final counts = await ref
        .read(billProvider.notifier)
        .getLineItemCountsForBills(billIds);

    setState(() {
      _billItemCounts.addAll(counts);
    });
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
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Bill list table
                Expanded(flex: 3, child: _buildBillsTable()),

                // Bill details section
                if (_selectedBill != null) ...[
                  const SizedBox(width: 16),
                  Expanded(flex: 2, child: _buildBillDetails()),
                ],
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
          'Bill History',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        Row(
          children: [
            OutlinedButton.icon(
              onPressed: () {
                // Export functionality would go here
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Export coming soon')),
                );
              },
              icon: const Icon(Icons.file_download_outlined),
              label: const Text('Export'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterBar() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search bills...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onChanged: (value) {
              // Search functionality placeholder
            },
          ),
        ),
        const SizedBox(width: 16),
        OutlinedButton.icon(
          onPressed: () {
            // Date range picker would go here
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Date filtering coming soon')),
            );
          },
          icon: const Icon(Icons.date_range),
          label: const Text('Date Range'),
        ),
      ],
    );
  }

  Widget _buildBillsTable() {
    return Consumer(
      builder: (context, ref, child) {
        final billState = ref.watch(billProvider);

        if (billState.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (billState.bills.isEmpty) {
          return const Center(
            child: Text(
              'No bills found',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        return Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: DataTable2(
              columnSpacing: 12,
              horizontalMargin: 12,
              minWidth: 600,
              columns: const [
                DataColumn2(label: Text('Bill #'), size: ColumnSize.S),
                DataColumn2(label: Text('Date'), size: ColumnSize.M),
                DataColumn2(label: Text('Time'), size: ColumnSize.M),
                DataColumn2(
                  label: Text('Items'),
                  size: ColumnSize.S,
                  numeric: true,
                ),
                DataColumn2(
                  label: Text('Total'),
                  size: ColumnSize.M,
                  numeric: true,
                ),
                DataColumn2(label: Text('Actions'), size: ColumnSize.S),
              ],
              rows:
                  billState.bills.map((bill) {
                    // Get item count from map or direct database query
                    final itemCount = _billItemCounts[bill.id] ?? 0;

                    return DataRow2(
                      selected: _selectedBill?.id == bill.id,
                      onTap: () {
                        setState(() {
                          _selectedBill = bill;
                        });
                        // Load bill details including line items
                        ref.read(billProvider.notifier).getBillById(bill.id);
                      },
                      cells: [
                        DataCell(Text(bill.id.substring(0, 8))),
                        DataCell(Text(dateFormat.format(bill.date))),
                        DataCell(Text(timeFormat.format(bill.date))),
                        DataCell(Text(itemCount.toString())),
                        DataCell(
                          Text(
                            currencyFormat.format(bill.totalAmount),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataCell(
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.receipt_long, size: 20),
                                tooltip: 'View Receipt',
                                onPressed: () {
                                  // View receipt details
                                  setState(() {
                                    _selectedBill = bill;
                                  });
                                  ref
                                      .read(billProvider.notifier)
                                      .getBillById(bill.id);
                                },
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  size: 20,
                                ),
                                tooltip: 'Delete Bill',
                                onPressed: () => _confirmDeleteBill(bill),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }).toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBillDetails() {
    return Consumer(
      builder: (context, ref, child) {
        final billState = ref.watch(billProvider);
        final bill = billState.selectedBill;

        if (bill == null) {
          return const Card(
            elevation: 2,
            child: Center(child: Text('Select a bill to view details')),
          );
        }

        final lineItems = bill.lineItems ?? <LineItem>[];

        return Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Bill #${bill.id.substring(0, 8)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        setState(() {
                          _selectedBill = null;
                        });
                      },
                    ),
                  ],
                ),
                const Divider(),
                Text(
                  'Date: ${dateFormat.format(bill.date)} at ${timeFormat.format(bill.date)}',
                ),
                const SizedBox(height: 16),
                const Text(
                  'Items',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.separated(
                    itemCount: lineItems.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final item = lineItems[index];
                      return ListTile(
                        dense: true,
                        title: Text(item.productName ?? 'Unknown Product'),
                        subtitle: Text(
                          '${item.quantity} x ${currencyFormat.format(item.unitPrice)}',
                        ),
                        trailing: Text(
                          currencyFormat.format(item.totalPrice),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      );
                    },
                  ),
                ),
                const Divider(),
                _buildBillSummary(bill),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    // Print receipt functionality would go here
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Print functionality coming soon'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.print),
                  label: const Text('Print Receipt'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(40),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBillSummary(Bill bill) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Subtotal'),
            Text(currencyFormat.format(bill.subtotal)),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Tax'),
            Text(currencyFormat.format(bill.taxAmount)),
          ],
        ),
        if (bill.discountAmount > 0) ...[
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Discount'),
              Text('-${currencyFormat.format(bill.discountAmount)}'),
            ],
          ),
        ],
        const Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Total', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(
              currencyFormat.format(bill.totalAmount),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
      ],
    );
  }

  void _confirmDeleteBill(Bill bill) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Bill'),
            content: Text(
              'Are you sure you want to delete bill #${bill.id.substring(0, 8)}?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ref.read(billProvider.notifier).deleteBill(bill.id);

                  if (_selectedBill?.id == bill.id) {
                    setState(() {
                      _selectedBill = null;
                    });
                  }

                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('Bill deleted')));
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }
}
