import 'package:flutter/material.dart';

enum NavigationItem { home, inventory, categories, reports }

class SidebarNavigation extends StatelessWidget {
  final NavigationItem selectedItem;
  final Function(NavigationItem) onItemSelected;

  const SidebarNavigation({
    super.key,
    required this.selectedItem,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      color: Theme.of(context).colorScheme.primary,
      child: Column(
        children: [
          const SizedBox(height: 40),
          _buildLogo(),
          const SizedBox(height: 40),
          _buildNavigationItems(),
          const Spacer(),
          _buildFooter(context),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Icon(Icons.storefront_rounded, color: Colors.white, size: 32),
          SizedBox(width: 12),
          Text(
            'CraftShop POS',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationItems() {
    return Column(
      children: [
        _buildNavItem(
          icon: Icons.home_rounded,
          title: 'Home',
          item: NavigationItem.home,
        ),
        _buildNavItem(
          icon: Icons.inventory_2_rounded,
          title: 'Inventory',
          item: NavigationItem.inventory,
        ),
        _buildNavItem(
          icon: Icons.category_rounded,
          title: 'Categories',
          item: NavigationItem.categories,
        ),
        _buildNavItem(
          icon: Icons.bar_chart_rounded,
          title: 'Reports',
          item: NavigationItem.reports,
        ),
      ],
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String title,
    required NavigationItem item,
  }) {
    final bool isSelected = selectedItem == item;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white.withAlpha(26) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => onItemSelected(item),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(icon, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      child: const Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.white24,
            radius: 20,
            child: Icon(Icons.person, color: Colors.white),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Admin',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Store Manager',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
