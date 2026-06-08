import '../models/category.dart';
import '../models/product.dart';
import 'catalog_api.dart';
import 'catalog_database.dart';

class ProductRepository {
  final CatalogDatabase _db;
  final CatalogApi _api;

  ProductRepository({CatalogDatabase? db, CatalogApi? api})
      : _db = db ?? CatalogDatabase.instance,
        _api = api ?? CatalogApi();

  Future<({List<Category> categories, List<Product> products})?> loadFromCache() {
    return _db.load();
  }

  Future<({List<Category> categories, List<Product> products})> refreshFromApi() async {
    final data = await _api.fetch();
    await _db.save(categories: data.categories, products: data.products);
    return data;
  }
}
