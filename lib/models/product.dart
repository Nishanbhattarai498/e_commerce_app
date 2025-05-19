import 'category.dart';

class Product {
  final int id;
  final String name;
  final String description;
  final double price;
  final double? compareAtPrice;
  final int categoryId;
  final Category? category;
  final int inventoryQuantity;
  final bool isFeatured;
  final double rating;
  final String imageUrl;
  List<String> images;
  Map<String, List<String>> variants;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.compareAtPrice,
    required this.categoryId,
    this.category,
    required this.inventoryQuantity,
    required this.isFeatured,
    required this.rating,
    required this.imageUrl,
    this.images = const [],
    this.variants = const {},
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: (json['price'] as num).toDouble(),
      compareAtPrice: json['compare_at_price'] != null
          ? (json['compare_at_price'] as num).toDouble()
          : null,
      categoryId: json['category_id'],
      category:
          json['category'] != null ? Category.fromJson(json['category']) : null,
      inventoryQuantity: json['inventory_quantity'],
      isFeatured: json['is_featured'],
      rating: (json['rating'] as num).toDouble(),
      imageUrl: json['image_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'compare_at_price': compareAtPrice,
      'category_id': categoryId,
      'inventory_quantity': inventoryQuantity,
      'is_featured': isFeatured,
      'rating': rating,
      'image_url': imageUrl,
    };
  }

  double get discountPercentage {
    if (compareAtPrice == null || compareAtPrice! <= price) {
      return 0;
    }

    return ((compareAtPrice! - price) / compareAtPrice! * 100).roundToDouble();
  }

  bool get isOnSale => compareAtPrice != null && compareAtPrice! > price;
}
