class Order {
  final String id;
  final String userId;
  final String status;
  final double totalAmount;
  final Map<String, dynamic> shippingAddress;
  final Map<String, dynamic> billingAddress;
  final Map<String, dynamic> paymentMethod;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<OrderItem> items;

  Order({
    required this.id,
    required this.userId,
    required this.status,
    required this.totalAmount,
    required this.shippingAddress,
    required this.billingAddress,
    required this.paymentMethod,
    required this.createdAt,
    required this.updatedAt,
    this.items = const [],
  });

  factory Order.fromJson(Map<String, dynamic> json, {List<OrderItem>? items}) {
    return Order(
      id: json['id'],
      userId: json['user_id'],
      status: json['status'],
      totalAmount: (json['total_amount'] as num).toDouble(),
      shippingAddress: json['shipping_address'],
      billingAddress: json['billing_address'],
      paymentMethod: json['payment_method'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      items: items ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'status': status,
      'total_amount': totalAmount,
      'shipping_address': shippingAddress,
      'billing_address': billingAddress,
      'payment_method': paymentMethod,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class OrderItem {
  final int id;
  final String orderId;
  final int productId;
  final String productName;
  final double price;
  final int quantity;
  final Map<String, dynamic>? variantOptions;
  final DateTime createdAt;

  OrderItem({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    this.variantOptions,
    required this.createdAt,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'],
      orderId: json['order_id'],
      productId: json['product_id'],
      productName: json['product_name'],
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'],
      variantOptions: json['variant_options'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'product_id': productId,
      'product_name': productName,
      'price': price,
      'quantity': quantity,
      'variant_options': variantOptions,
      'created_at': createdAt.toIso8601String(),
    };
  }

  double get totalPrice => price * quantity;
}
