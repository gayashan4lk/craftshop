import 'package:flutter/material.dart';

class Category {
  final String id;
  final String name;
  final String description;
  final Color color;
  final int itemCount;

  const Category({
    required this.id,
    required this.name,
    required this.description,
    required this.color,
    required this.itemCount,
  });
}

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  // Mock data - this would come from a repository in a real app
  final List<Category> _categories = [
    Category(
      id: '1',
      name: 'Clothing',
      description: 'Apparel and garments',
      color: Colors.blue,
      itemCount: 32,
    ),
    Category(
      id: '2',
      name: 'Accessories',
      description: 'Bags, hats, and other accessories',
      color: Colors.green,
      itemCount: 45,
    ),
    Category(
      id: '3',
      name: 'Home Decor',
      description: 'Decorative items for home',
      color: Colors.orange,
      itemCount: 28,
    ),
    Category(
      id: '4',
      name: 'Jewelry',
      description: 'Handmade jewelry items',
      color: Colors.purple,
      itemCount: 53,
    ),
    Category(
      id: '5',
      name: 'Art Supplies',
      description: 'Paints, brushes, and canvas',
      color: Colors.red,
      itemCount: 17,
    ),
  ];

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  Color _selectedColor = Colors.blue;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
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
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Categories list (2/3 of the width)
                Expanded(flex: 2, child: _buildCategoriesTable()),
                const SizedBox(width: 24),
                // Add/Edit form (1/3 of the width)
                Expanded(flex: 1, child: _buildCategoryForm()),
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
          'Categories',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.file_download_outlined),
          label: const Text('Export'),
        ),
      ],
    );
  }

  Widget _buildCategoriesTable() {
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
                  'All Categories',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search categories...',
                    prefixIcon: const Icon(Icons.search),
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    constraints: const BoxConstraints(maxWidth: 250),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: _categories.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: category.color,
                      child: Text(
                        category.name.substring(0, 1),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(
                      category.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(category.description),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Chip(
                          label: Text('${category.itemCount} items'),
                          backgroundColor: Colors.grey[200],
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          onPressed: () => _editCategory(category),
                          visualDensity: VisualDensity.compact,
                          splashRadius: 20,
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => _deleteCategory(category),
                          visualDensity: VisualDensity.compact,
                          splashRadius: 20,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryForm() {
    final List<Color> colorOptions = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add New Category',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Category Name',
                hintText: 'Enter category name',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Enter category description',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Category Color', style: TextStyle(fontSize: 14)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      colorOptions.map((color) {
                        final isSelected = _selectedColor == color;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedColor = color;
                            });
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border:
                                  isSelected
                                      ? Border.all(
                                        color: Colors.black,
                                        width: 2,
                                      )
                                      : null,
                            ),
                            child:
                                isSelected
                                    ? const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                    )
                                    : null,
                          ),
                        );
                      }).toList(),
                ),
              ],
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _resetForm,
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveCategory,
                    child: const Text('Save'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _editCategory(Category category) {
    _nameController.text = category.name;
    _descriptionController.text = category.description;
    setState(() {
      _selectedColor = category.color;
    });
  }

  void _deleteCategory(Category category) {
    // Show confirmation dialog in a real app
    setState(() {
      _categories.removeWhere((c) => c.id == category.id);
    });
  }

  void _saveCategory() {
    if (_nameController.text.isNotEmpty) {
      // In a real app, this would add to database
      final newCategory = Category(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        description: _descriptionController.text,
        color: _selectedColor,
        itemCount: 0,
      );

      setState(() {
        _categories.add(newCategory);
      });

      _resetForm();
    }
  }

  void _resetForm() {
    _nameController.clear();
    _descriptionController.clear();
    setState(() {
      _selectedColor = Colors.blue;
    });
  }
}
