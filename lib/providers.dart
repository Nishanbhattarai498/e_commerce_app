import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/supabase_service.dart';
import 'services/product_service.dart';
import 'services/cart_service.dart';
import 'services/auth_service.dart';
import 'services/order_service.dart';
import 'services/address_service.dart';

Future<void> initializeServices() async {
  try {
    final supabaseService = SupabaseService();
    await supabaseService.initialize();
    
    // Initialize other services if needed
    final authService = AuthService(supabaseService);
    final productService = ProductService(supabaseService);
    final cartService = CartService(supabaseService);
    final orderService = OrderService(supabaseService, cartService: cartService);
    final addressService = AddressService(supabaseService);
    
    // You can add any additional initialization logic here
  } catch (e) {
    print('Error initializing services: $e');
    rethrow;
  }
}

class AppProviders extends StatelessWidget {
  final Widget child;

  const AppProviders({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<SupabaseService>(
          create: (_) => SupabaseService(),
        ),
        ProxyProvider<SupabaseService, AuthService>(
          update: (_, supabaseService, __) => AuthService(supabaseService),
        ),
        ProxyProvider<SupabaseService, ProductService>(
          update: (_, supabaseService, __) => ProductService(supabaseService),
        ),
        ChangeNotifierProxyProvider<SupabaseService, CartService>(
          create: (context) => CartService(
            Provider.of<SupabaseService>(context, listen: false),
          ),
          update: (_, supabaseService, previous) =>
              previous ?? CartService(supabaseService),
        ),
        ProxyProvider2<SupabaseService, CartService, OrderService>(
          update: (_, supabaseService, cartService, __) => OrderService(supabaseService, cartService: cartService),
        ),
        ProxyProvider<SupabaseService, AddressService>(
          update: (_, supabaseService, __) => AddressService(supabaseService),
        ),
      ],
      child: child,
    );
  }
}
