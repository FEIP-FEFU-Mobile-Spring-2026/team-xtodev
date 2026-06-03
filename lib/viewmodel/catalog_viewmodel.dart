import 'package:flutter/foundation.dart' hide Category;
import 'package:shared_preferences/shared_preferences.dart';
import '../data/product_repository.dart';
import '../models/category.dart';
import '../models/product.dart';

enum CatalogStatus { initial, loading, success, error }

class CatalogViewModel extends ChangeNotifier {
  final ProductRepository _repository;

  CatalogStatus _status = CatalogStatus.initial;
  List<Category> _categories = [];
  List<Product> _products = [];
  int _selectedTabIndex = 0;
  String? _error;

  CatalogViewModel(this._repository);

  CatalogStatus get status => _status;
  String? get error => _error;
  int get selectedTabIndex => _selectedTabIndex;

  List<Category> get tabs => [
        const Category(id: Category.newId, name: Category.newName),
        ..._categories,
      ];

  List<Product> get filteredProducts {
    if (_status != CatalogStatus.success) return [];
    final currentTabs = tabs;
    if (_selectedTabIndex >= currentTabs.length) return [];
    final tab = currentTabs[_selectedTabIndex];
    if (tab.id == Category.newId) {
      return _products.where((p) => p.isNew).toList();
    }
    return _products.where((p) => p.categoryId == tab.id).toList();
  }

  Future<void> load() async {
    _status = CatalogStatus.loading;
    _error = null;
    notifyListeners();

    try {
      final data = await _repository.loadCatalog();
      _categories = data.categories;
      _products = data.products;
      _status = CatalogStatus.success;

      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getInt('selected_tab_index') ?? 0;
      _selectedTabIndex = saved.clamp(0, tabs.length - 1);
    } catch (e) {
      _error = 'Не удалось загрузить каталог';
      _status = CatalogStatus.error;
    }

    notifyListeners();
  }

  Future<void> selectTab(int index) async {
    if (_selectedTabIndex == index) return;
    _selectedTabIndex = index;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selected_tab_index', index);
  }
}
