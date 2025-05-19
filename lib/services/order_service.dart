import 'package:flutter/foundation.dart';
import '../models/order.dart';
import '../models/cart.dart';
import 'supabase_service.dart';
import 'cart_service.dart';

class OrderService extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();
  final CartService _cartService = CartService();
  List<Order> _orders = [];
  bool _isLoading = false;

  bool get isLoading => _isLoading;
  List<Order> get orders => _orders;

  Future<void> fetchOrders() async {
    if (!_supabaseService.isAuthenticated) return;

    _setLoading(true);
    try {
      final ordersResponse = await _supabaseService.client
          .from('orders')
          .select()
          .eq('user_id', _supabaseService.currentUser!.id)
          .order('created_at', ascending: false);

      final orders = await Future.wait(
        ordersResponse.map<Future<Order>>(
          (json) async {
            final orderItems = await _supabaseService.client
                .from('order_items')
                .select()
                .eq('order_id', json['id']);

            return Order.fromJson(
              json,
              items: orderItems
                  .map<OrderItem>((item) => OrderItem.fromJson(item))
                  .toList(),
            );
          },
        ),
      );

      _orders = orders;
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching orders: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<Order?> getOrderById(String id) async {
    if (!_supabaseService.isAuthenticated) return null;

    try {
      final orderResponse = await _supabaseService.client
          .from('orders')
          .select()
          .eq('id', id)
          .single();

      final orderItems = await _supabaseService.client
          .from('order_items')
          .select()
          .eq('order_id', id);

      return Order.fromJson(
        orderResponse,
        items: orderItems
            .map<OrderItem>((item) => OrderItem.fromJson(item))
            .toList(),
      );
    } catch (e) {
      debugPrint('Error getting order by ID: $e');
      return null;
    }
  }

  Future<Order?> createOrder({
    required Map<String, dynamic> shippingAddress,
    required Map<String, dynamic> billingAddress,
    required Map<String, dynamic> paymentMethod,
  }) async {
    if (!_supabaseService.isAuthenticated) return null;
    if (_cartService.cart == null || _cartService.cart!.items.isEmpty)
      return null;

    _setLoading(true);
    try {
      final cart = _cartService.cart!;

      // Create order
      final orderResponse =
          await _supabaseService.client.from('orders').insert({
        'user_id': _supabaseService.currentUser!.id,
        'status': 'pending',
        'total_amount': cart.total,
        'shipping_address': shippingAddress,
        'billing_address': billingAddress,
        'payment_method': paymentMethod,
      }).select();

      final orderId = orderResponse[0]['id'];

      // Create order items
      await Future.wait(
        cart.items
            .map((item) => _supabaseService.client.from('order_items').insert({
                  'order_id': orderId,
                  'product_id': item.productId,
                  'product_name': item.product?.name ?? 'Unknown Product',
                  'price': item.unitPrice,
                  'quantity': item.quantity,
                  'variant_options': item.variantOptions,
                })),
      );

      // Clear the cart
      await _cartService.clearCart();

      // Fetch the created order with items
      final order = await getOrderById(orderId);

      // Add to local orders list
      if (order != null) {
        _orders = [order, ..._orders];
        notifyListeners();
      }

      return order;
    } catch (e) {
      debugPrint('Error creating order: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
