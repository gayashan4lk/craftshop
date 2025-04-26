import 'package:flutter/material.dart';
import 'package:craftshop/presentation/screens/home_screen.dart';
import 'package:craftshop/presentation/screens/dashboard_screen.dart';
import 'package:craftshop/presentation/screens/inventory_screen.dart';
import 'package:craftshop/presentation/screens/reports_screen.dart';
import 'package:craftshop/presentation/screens/categories_screen.dart';
import 'package:craftshop/presentation/screens/debug_screen.dart';
import 'package:craftshop/presentation/widgets/sidebar_navigation.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  NavigationItem _selectedItem = NavigationItem.home;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          SidebarNavigation(
            selectedItem: _selectedItem,
            onItemSelected: _handleNavigationItemSelected,
          ),
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  void _handleNavigationItemSelected(NavigationItem item) {
    setState(() {
      _selectedItem = item;
    });
  }

  Widget _buildContent() {
    switch (_selectedItem) {
      case NavigationItem.home:
        return const HomeScreen();
      case NavigationItem.dashboard:
        return const DashboardScreen();
      case NavigationItem.inventory:
        return const InventoryScreen();
      case NavigationItem.categories:
        return const CategoriesScreen();
      case NavigationItem.reports:
        return const ReportsScreen();
      case NavigationItem.debug:
        return const DebugScreen();
    }
  }
}
