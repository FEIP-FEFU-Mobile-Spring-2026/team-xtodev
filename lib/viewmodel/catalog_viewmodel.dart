import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
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
  bool _isOffline = false;
  bool _tabRestored = false;
  bool _recovering = false;

  late final StreamSubscription<List<ConnectivityResult>> _connectivitySub;

  CatalogViewModel(this._repository, {Stream<List<ConnectivityResult>>? connectivityStream}) {
    _connectivitySub = (connectivityStream ?? Connectivity().onConnectivityChanged)
        .listen(_onConnectivityChanged);
  }

  CatalogStatus get status => _status;
  String? get error => _error;
  int get selectedTabIndex => _selectedTabIndex;
  bool get isOffline => _isOffline;
  List<Product> get products => List.unmodifiable(_products);

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

  void _onConnectivityChanged(List<ConnectivityResult> results) {
    final hasNetwork = results.any((r) => r != ConnectivityResult.none);
    if (hasNetwork && _isOffline) {
      _recover();
    }
  }

  Future<void> _recover() async {
    if (_recovering) return;
    _recovering = true;
    try {
      final data = await _repository.refreshFromApi();
      _categories = data.categories;
      _products = data.products;
      _status = CatalogStatus.success;
      _error = null;
      _isOffline = false;
      if (!_tabRestored) {
        await _restoreTabIndex();
        _tabRestored = true;
      }
      notifyListeners();
    } catch (_) {
    } finally {
      _recovering = false;
    }
  }

  Future<void> load() async {
    _isOffline = false;

    if (_status != CatalogStatus.success) {
      _status = CatalogStatus.loading;
      _error = null;
      notifyListeners();
    }

    if (_products.isEmpty) {
      final cached = await _repository.loadFromCache();
      if (cached != null) {
        _categories = cached.categories;
        _products = cached.products;
        _status = CatalogStatus.success;
        if (!_tabRestored) {
          await _restoreTabIndex();
          _tabRestored = true;
        }
        notifyListeners();
      }
    }

    try {
      final data = await _repository.refreshFromApi();
      _categories = data.categories;
      _products = data.products;
      _status = CatalogStatus.success;
      if (!_tabRestored) {
        await _restoreTabIndex();
        _tabRestored = true;
      }
      notifyListeners();
    } catch (_) {
      _isOffline = true;
      if (_products.isEmpty) {
        _error = 'Нет соединения с сетью';
        _status = CatalogStatus.error;
      }
      notifyListeners();
    }
  }

  Future<void> _restoreTabIndex() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getInt('selected_tab_index') ?? 0;
    _selectedTabIndex = saved.clamp(0, tabs.length - 1);
  }

  Future<void> selectTab(int index) async {
    if (_selectedTabIndex == index) return;
    _selectedTabIndex = index;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selected_tab_index', index);
  }

  @override
  void dispose() {
    _connectivitySub.cancel();
    super.dispose();
  }
}
