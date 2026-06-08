import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/category.dart';
import '../models/product.dart';

class CatalogApi {
  static const _url = 'https://fefu2026spring.deploy.feip.dev/catalog';
  static const _token = 'Cmt7wdwFgDIi1_SRX8hlJIExs0jJKPr4axflLpExAxM';

  Future<({List<Category> categories, List<Product> products})> fetch() async {
    final response = await http
        .get(
          Uri.parse(_url),
          headers: {'Authorization': 'Bearer $_token'},
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}');
    }

    final json = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    return (
      categories: (json['categories'] as List)
          .map((e) => Category.fromJson(e as Map<String, dynamic>))
          .toList(),
      products: (json['items'] as List)
          .map((e) => Product.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
