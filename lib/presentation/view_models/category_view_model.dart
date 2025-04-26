import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:craftshop/domain/models/category.dart';
import 'package:craftshop/domain/repositories/category_repository.dart';
import 'package:craftshop/data/repositories/category_repository_impl.dart';

enum CategoryState { initial, loading, loaded, error }

class CategoryNotifier extends StateNotifier<CategoryViewModel> {
  final CategoryRepository _repository;

  CategoryNotifier({CategoryRepository? repository})
    : _repository = repository ?? CategoryRepositoryImpl(),
      super(CategoryViewModel());

  Future<void> loadCategories() async {
    state = state.copyWith(state: CategoryState.loading);
    try {
      final categories = await _repository.getAllCategories();
      state = state.copyWith(
        categories: categories,
        state: CategoryState.loaded,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        state: CategoryState.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> addCategory(String name, String description, Color color) async {
    if (name.isEmpty) return;

    state = state.copyWith(state: CategoryState.loading);

    try {
      final category = Category.create(
        name: name,
        description: description,
        color: color,
      );

      await _repository.addCategory(category);
      await loadCategories();
    } catch (e) {
      state = state.copyWith(
        state: CategoryState.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> updateCategory(
    Category category, {
    String? name,
    String? description,
    Color? color,
  }) async {
    state = state.copyWith(state: CategoryState.loading);

    try {
      final updatedCategory = category.copyWith(
        name: name ?? category.name,
        description: description ?? category.description,
        color: color ?? category.color,
      );

      await _repository.updateCategory(updatedCategory);
      await loadCategories();
    } catch (e) {
      state = state.copyWith(
        state: CategoryState.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> deleteCategory(String id) async {
    state = state.copyWith(state: CategoryState.loading);

    try {
      await _repository.deleteCategory(id);
      await loadCategories();
    } catch (e) {
      state = state.copyWith(
        state: CategoryState.error,
        errorMessage: e.toString(),
      );
    }
  }

  void setSelectedCategory(Category? category) {
    state = state.copyWith(selectedCategory: category);
  }

  void clearSelectedCategory() {
    state = state.copyWith(selectedCategory: null);
  }
}

class CategoryViewModel {
  final List<Category> categories;
  final CategoryState state;
  final String? errorMessage;
  final Category? selectedCategory;

  CategoryViewModel({
    this.categories = const [],
    this.state = CategoryState.initial,
    this.errorMessage,
    this.selectedCategory,
  });

  CategoryViewModel copyWith({
    List<Category>? categories,
    CategoryState? state,
    String? errorMessage,
    Category? selectedCategory,
  }) {
    return CategoryViewModel(
      categories: categories ?? this.categories,
      state: state ?? this.state,
      errorMessage: errorMessage,
      selectedCategory: selectedCategory,
    );
  }
}

final categoryProvider =
    StateNotifierProvider<CategoryNotifier, CategoryViewModel>(
      (ref) => CategoryNotifier(),
    );
