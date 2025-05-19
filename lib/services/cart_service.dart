import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/cart.dart';
import '../models/cart_item.dart';
import '../models/product.dart';
import 'supabase_service.dart';
import 'product_service.dart';

class CartService extends ChangeNotifier {
  final SupabaseService _supabaseService;
  final ProductService _productService;

  Cart? _cart;
  bool _isLoading = false;

  CartService(this._supabaseService, this._productService);

  Cart? get cart => _cart;
  bool get isLoading => _isLoading;

  int get itemCount =>
      _cart?.items.fold(0, (sum, item) => sum + item.quantity) ?? 0;

  double get subtotal =>
      _cart?.items
          .fold(0, (sum, item) => sum + (item.product.price * item.quantity)) ??
      0;

  double get tax => subtotal * 0.1; // 10% tax

  double get shipping => 10.0; // Flat shipping rate

  double get total => subtotal + tax + shipping;

  Future<void> loadCart() async {
    if (_supabaseService.currentUser == null) {
      _cart = Cart(
        id: const Uuid().v4(),
        userId: '',
        items: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      // Check if user has a cart
      final cartData = await _supabaseService.client
          .from('carts')
          .select('*')
          .eq('user_id', _supabaseService.currentUser!.id)
          .maybeSingle();

      String cartId;

      if (cartData == null) {
        // Create a new cart
        final newCart = {
          'user_id': _supabaseService.currentUser!.id,
        };

        final result = await _supabaseService.client
            .from('carts')
            .insert(newCart)
            .select()
            .single();

        cartId = result['id'];
      } else {
        cartId = cartData['id'];
      }

      // Get cart items
      final cartItemsData = await _supabaseService.client
          .from('cart_items')
          .select('*, product:products(*)')
          .eq('cart_id', cartId);

      final items = await Future.wait(
        cartItemsData.map<Future<CartItem>>((item) async {
          final product = Product.fromJson(item['product']);

          return CartItem(
            id: item['id'],
            cartId: cartId,
            product: product,
            quantity: item['quantity'],
            variantOptions: item['variant_options'] != null
                ? Map<String, String>.from(item['variant_options'])
                : {},
          );
        }).toList(),
      );

      _cart = Cart(
        id: cartId,
        userId: _supabaseService.currentUser!.id,
        items: items,
        createdAt: DateTime.parse(
            cartData?['created_at'] ?? DateTime.now().toIso8601String()),
        updatedAt: DateTime.parse(
            cartData?['updated_at'] ?? DateTime.now().toIso8601String()),
      );
    } catch (e) {
      debugPrint('Error loading cart: $e');

      // Create an empty cart if there's an error
      _cart = Cart(
        id: const Uuid().v4(),
        userId: _supabaseService.currentUser?.id ?? '',
        items: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addToCart(
      Product product, int quantity, Map<String, String> variantOptions) async {
    if (_cart == null) {
      await loadCart();
    }

    _isLoading = true;
    notifyListeners();

    try {
      // Check if item already exists in cart
      final existingItemIndex = _cart!.items.indexWhere(
        (item) =>
            item.product.id == product.id &&
            _areVariantOptionsEqual(item.variantOptions, variantOptions),
      );

      if (existingItemIndex != -1) {
        // Update quantity
        final existingItem = _cart!.items[existingItemIndex];
        final newQuantity = existingItem.quantity + quantity;

        if (_supabaseService.isAuthenticated) {
          await _supabaseService.client
              .from('cart_items')
              .update({'quantity': newQuantity}).eq('id', existingItem.id);
        }

        _cart!.items[existingItemIndex] = CartItem(
          id: existingItem.id,
          cartId: existingItem.cartId,
          product: existingItem.product,
          quantity: newQuantity,
          variantOptions: existingItem.variantOptions,
        );
      } else {
        // Add new item
        if (_supabaseService.isAuthenticated) {
          final newItem = {
            'cart_id': _cart!.id,
            'product_id': product.id,
            'quantity': quantity,
            'variant_options': variantOptions,
          };

          final result = await _supabaseService.client
              .from('cart_items')
              .insert(newItem)
              .select()
              .single();

          _cart!.items.add(CartItem(
            id: result['id'],
            cartId: _cart!.id,
            product: product,
            quantity: quantity,
            variantOptions: variantOptions,
          ));
        } else {
          // For non-authenticated users, just add to local cart
          _cart!.items.add(CartItem(
            id: _cart!.items.length + 1,
            cartId: _cart!.id,
            product: product,
            quantity: quantity,
            variantOptions: variantOptions,
          ));
        }
      }
    } catch (e) {
      debugPrint('Error adding to cart: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateCartItemQuantity(CartItem item, int quantity) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (quantity <= 0) {
        await removeFromCart(item);
        return;
      }

      if (_supabaseService.isAuthenticated) {
        await _supabaseService.client
            .from('cart_items')
            .update({'quantity': quantity}).eq('id', item.id);
      }

      final index = _cart!.items.indexWhere((i) => i.id == item.id);
      if (index != -1) {
        _cart!.items[index] = CartItem(
          id: item.id,
          cartId: item.cartId,
          product: item.product,
          quantity: quantity,
          variantOptions: item.variantOptions,
        );
      }
    } catch (e) {
      debugPrint('Error updating cart item quantity: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> removeFromCart(CartItem item) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (_supabaseService.isAuthenticated) {
        await _supabaseService.client
            .from('cart_items')
            .delete()
            .eq('id', item.id);
      }

      _cart!.items.removeWhere((i) => i.id == item.id);
    } catch (e) {
      debugPrint('Error removing from cart: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> clearCart() async {
    _isLoading = true;
    notifyListeners();

    try {
      if (_supabaseService.isAuthenticated) {
        await _supabaseService.client
            .from('cart_items')
            .delete()
            .eq('cart_id', _cart!.id);
      }

      _cart!.items.clear();
    } catch (e) {
      debugPrint('Error clearing cart: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool _areVariantOptionsEqual(
      Map<String, String> options1, Map<String, String> options2) {
    if (options1.length != options2.length) {
      return false;
    }

    for (final key in options1.keys) {
      if (options1[key] != options2[key]) {
        return false;
      }
    }

    return true;
  }
}
