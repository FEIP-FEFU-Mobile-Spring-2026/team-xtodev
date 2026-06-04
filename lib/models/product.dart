class Product {
  final String id;
  final String name;
  final int priceInKopecks;
  final String imageUrl;
  final List<String> tags;
  final String categoryId;

  const Product({
    required this.id,
    required this.name,
    required this.priceInKopecks,
    required this.imageUrl,
    required this.tags,
    required this.categoryId,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      priceInKopecks: json['priceInKopecks'] as int,
      imageUrl: json['imageUrl'] as String,
      tags: List<String>.from(json['tags'] as List),
      categoryId: json['categoryId'] as String,
    );
  }

  bool get isNew => tags.contains('New');
}
