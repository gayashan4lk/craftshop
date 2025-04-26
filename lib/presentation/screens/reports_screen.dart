import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String _selectedPeriod = 'This Month';
  final List<String> _periods = [
    'Today',
    'This Week',
    'This Month',
    'This Quarter',
    'This Year',
    'Custom Range',
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildSummaryCards(),
          const SizedBox(height: 24),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: _buildSalesChart()),
                const SizedBox(width: 24),
                Expanded(flex: 2, child: _buildTopSellingProducts()),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildCategoryBreakdown(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Reports',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedPeriod,
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedPeriod = newValue;
                      });
                    }
                  },
                  items:
                      _periods.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.download),
              label: const Text('Export Report'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCards() {
    return Row(
      children: [
        _buildSummaryCard(
          title: 'Total Sales',
          value: '\$8,540.50',
          change: '+18%',
          isUp: true,
        ),
        const SizedBox(width: 16),
        _buildSummaryCard(
          title: 'Total Orders',
          value: '324',
          change: '+12%',
          isUp: true,
        ),
        const SizedBox(width: 16),
        _buildSummaryCard(
          title: 'Average Order Value',
          value: '\$26.36',
          change: '+5%',
          isUp: true,
        ),
        const SizedBox(width: 16),
        _buildSummaryCard(
          title: 'Return Rate',
          value: '2.1%',
          change: '-0.5%',
          isUp: true,
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required String change,
    required bool isUp,
  }) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 12),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    isUp ? Icons.arrow_upward : Icons.arrow_downward,
                    color: isUp ? Colors.green : Colors.red,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    change,
                    style: TextStyle(
                      color: isUp ? Colors.green : Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'vs. previous',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSalesChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Sales Trend',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment<String>(value: 'Daily', label: Text('Daily')),
                    ButtonSegment<String>(
                      value: 'Weekly',
                      label: Text('Weekly'),
                    ),
                    ButtonSegment<String>(
                      value: 'Monthly',
                      label: Text('Monthly'),
                    ),
                  ],
                  selected: const {'Weekly'},
                  onSelectionChanged: (Set<String> newSelection) {
                    // Handle selection
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 6,
                  minY: 0,
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          const weeks = [
                            'Week 1',
                            'Week 2',
                            'Week 3',
                            'Week 4',
                          ];
                          final index = value.toInt();

                          if (index >= 0 && index < weeks.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                weeks[index],
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                  ),
                  barGroups: [
                    _generateBarGroup(0, 4.5),
                    _generateBarGroup(1, 3.2),
                    _generateBarGroup(2, 5.8),
                    _generateBarGroup(3, 4.9),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  BarChartGroupData _generateBarGroup(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          gradient: LinearGradient(
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).colorScheme.secondary,
            ],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
          width: 28,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(6),
            topRight: Radius.circular(6),
          ),
        ),
      ],
    );
  }

  Widget _buildTopSellingProducts() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Top Selling Products',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Icon(Icons.more_vert),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: List.generate(
                  5,
                  (index) => _buildProductItem(
                    name: 'Product ${index + 1}',
                    sales: (100 - index * 15).toString(),
                    amount: '\$${(500 - index * 75).toStringAsFixed(2)}',
                    growth:
                        index < 3
                            ? '+${(20 - index * 5).toString()}%'
                            : '-${(index * 2).toString()}%',
                    isUp: index < 3,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {},
                child: const Text('View All Products'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductItem({
    required String name,
    required String sales,
    required String amount,
    required String growth,
    required bool isUp,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[200]!, width: 1)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(child: Icon(Icons.shopping_bag_outlined)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text(
                  '$sales items sold',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(amount, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    isUp ? Icons.arrow_upward : Icons.arrow_downward,
                    color: isUp ? Colors.green : Colors.red,
                    size: 14,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    growth,
                    style: TextStyle(
                      fontSize: 12,
                      color: isUp ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBreakdown() {
    return SizedBox(
      height: 300,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Sales by Category',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 2,
                          centerSpaceRadius: 60,
                          sections: [
                            _buildPieChartSection('Clothing', 40, Colors.blue),
                            _buildPieChartSection(
                              'Accessories',
                              25,
                              Colors.green,
                            ),
                            _buildPieChartSection(
                              'Home Decor',
                              15,
                              Colors.orange,
                            ),
                            _buildPieChartSection('Jewelry', 12, Colors.purple),
                            _buildPieChartSection(
                              'Art Supplies',
                              8,
                              Colors.red,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildCategoryLegendItem('Clothing', 40, Colors.blue),
                    const SizedBox(height: 16),
                    _buildCategoryLegendItem('Accessories', 25, Colors.green),
                    const SizedBox(height: 16),
                    _buildCategoryLegendItem('Home Decor', 15, Colors.orange),
                    const SizedBox(height: 16),
                    _buildCategoryLegendItem('Jewelry', 12, Colors.purple),
                    const SizedBox(height: 16),
                    _buildCategoryLegendItem('Art Supplies', 8, Colors.red),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  PieChartSectionData _buildPieChartSection(
    String title,
    double value,
    Color color,
  ) {
    return PieChartSectionData(
      color: color,
      value: value,
      title: '$value%',
      radius: 80,
      titleStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  Widget _buildCategoryLegendItem(
    String category,
    double percentage,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(category)),
        Text(
          '$percentage%',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
