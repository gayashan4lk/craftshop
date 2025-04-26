import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:craftshop/domain/models/category.dart';
import 'package:craftshop/presentation/view_models/category_view_model.dart';

class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({super.key});

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen> {
  @override
  void initState() {
    super.initState();
    // Load categories when screen initializes
    Future.microtask(() => ref.read(categoryProvider.notifier).loadCategories());
  }

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  Color _selectedColor = Colors.blue;
  bool _isEditing = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
  
  void _resetForm() {
    _nameController.clear();
    _descriptionController.clear();
    setState(() {
      _selectedColor = Colors.blue;
      _isEditing = false;
    });
    ref.read(categoryProvider.notifier).clearSelectedCategory();
  }

  void _saveCategory() {
    if (_nameController.text.isEmpty) return;
    
    final viewModel = ref.read(categoryProvider);
    final notifier = ref.read(categoryProvider.notifier);
    
    if (_isEditing && viewModel.selectedCategory != null) {
      notifier.updateCategory(
        viewModel.selectedCategory!,
        name: _nameController.text,
        description: _descriptionController.text,
        color: _selectedColor,
      );
    } else {
      notifier.addCategory(
        _nameController.text,
        _descriptionController.text,
        _selectedColor,
      );
    }
    
    _resetForm();
  }

  void _editCategory(Category category) {
    ref.read(categoryProvider.notifier).setSelectedCategory(category);
    _nameController.text = category.name;
    _descriptionController.text = category.description;
    setState(() {
      _selectedColor = category.color ?? Colors.blue;
      _isEditing = true;
    });
  }

  void _deleteCategory(Category category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete ${category.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(categoryProvider.notifier).deleteCategory(category.id);
              if (_isEditing && ref.read(categoryProvider).selectedCategory?.id == category.id) {
                _resetForm();
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
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
    final viewModel = ref.watch(categoryProvider);
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Categories',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            if (viewModel.state == CategoryState.loaded)
              Text(
                '${viewModel.categories.length} categories total',
                style: TextStyle(color: Colors.grey[600]),
              ),
          ],
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
    final viewModel = ref.watch(categoryProvider);
    
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
              child: _buildCategoriesList(viewModel),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCategoriesList(CategoryViewModel viewModel) {
    if (viewModel.state == CategoryState.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (viewModel.state == CategoryState.error) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(viewModel.errorMessage ?? 'An error occurred'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.read(categoryProvider.notifier).loadCategories(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    
    if (viewModel.categories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.category_outlined, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('No categories yet'),
            const SizedBox(height: 8),
            const Text(
              'Add a category using the form on the right',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }
    
    return ListView.separated(
      itemCount: viewModel.categories.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final category = viewModel.categories[index];
        final isSelected = viewModel.selectedCategory?.id == category.id;
        
        return ListTile(
          selected: isSelected,
          selectedTileColor: Colors.grey.withAlpha(20),
          leading: CircleAvatar(
            backgroundColor: category.color ?? Colors.blue,
            child: Text(
              category.name.substring(0, 1).toUpperCase(),
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
          onTap: () => _editCategory(category),
        );
      },
    );
  }

  Widget _buildCategoryForm() {
    final viewModel = ref.watch(categoryProvider);
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
            Text(
              _isEditing ? 'Edit Category' : 'Add New Category',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                  children: colorOptions.map((color) {
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
                          border: isSelected
                              ? Border.all(color: Colors.black, width: 2)
                              : null,
                        ),
                        child: isSelected
                            ? const Icon(Icons.check, color: Colors.white)
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
                    onPressed: viewModel.state == CategoryState.loading
                        ? null
                        : _resetForm,
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: viewModel.state == CategoryState.loading
                        ? null
                        : _saveCategory,
                    child: viewModel.state == CategoryState.loading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(_isEditing ? 'Update' : 'Save'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }


}
