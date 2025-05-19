import 'product.dart';

class CartItem {
  final int id;
  final String cartId;
  final Product product;
  final int quantity;
  final Map<String, String> variantOptions;

  CartItem({
    required this.id,
    required this.cartId,
    required this.product,
    required this.quantity,
    required this.variantOptions,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      cartId: json['cart_id'],
      product: Product.fromJson(json['product']),
      quantity: json['quantity'],
      variantOptions: json['variant_options'] != null
          ? Map<String, String>.from(json['variant_options'])
          : {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cart_id': cartId,
      'product_id': product.id,
      'quantity': quantity,
      'variant_options': variantOptions,
    };
  }

  double get totalPrice => product.price * quantity;
}
