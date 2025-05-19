import 'product.dart';

class Cart {
  final String id;
  final String userId;
  final List<CartItem> items;
  final DateTime createdAt;
  final DateTime updatedAt;

  Cart({
    required this.id,
    required this.userId,
    required this.items,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      id: json['id'],
      userId: json['user_id'],
      items: (json['items'] as List<dynamic>)
          .map((item) => CartItem.fromJson(item))
          .toList(),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  double get subtotal => items.fold(0, (sum, item) => sum + item.totalPrice);

  double get shipping => subtotal > 100 ? 0 : 10;

  double get tax => subtotal * 0.08;

  double get total => subtotal + shipping + tax;

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  Cart copyWith({
    String? id,
    String? userId,
    List<CartItem>? items,
    DateTime? updatedAt,
  }) {
    return Cart(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      items: items ?? this.items,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}

class CartItem {
  final int id;
  final String cartId;
  final int productId;
  final int quantity;
  final Map<String, dynamic>? variantOptions;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Product? product;

  CartItem({
    required this.id,
    required this.cartId,
    required this.productId,
    required this.quantity,
    this.variantOptions,
    required this.createdAt,
    required this.updatedAt,
    this.product,
  });

  factory CartItem.fromJson(Map<String, dynamic> json, {Product? product}) {
    return CartItem(
      id: json['id'],
      cartId: json['cart_id'],
      productId: json['product_id'],
      quantity: json['quantity'],
      variantOptions: json['variant_options'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      product: product,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cart_id': cartId,
      'product_id': productId,
      'quantity': quantity,
      'variant_options': variantOptions,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  double get unitPrice => product?.price ?? 0;

  double get totalPrice => unitPrice * quantity;

  CartItem copyWith({
    int? quantity,
    Map<String, dynamic>? variantOptions,
  }) {
    return CartItem(
      id: id,
      cartId: cartId,
      productId: productId,
      quantity: quantity ?? this.quantity,
      variantOptions: variantOptions ?? this.variantOptions,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      product: product,
    );
  }
}
