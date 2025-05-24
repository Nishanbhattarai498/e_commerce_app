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
    // You can add any additional initialization logic here
  } catch (e) {
    print('Error initializing services');
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
        ChangeNotifierProxyProvider<SupabaseService, AuthService>(
          create: (context) => AuthService(),
          update: (_, supabaseService, previous) => previous ?? AuthService(),
        ),
        ChangeNotifierProxyProvider<SupabaseService, ProductService>(
          create: (context) => ProductService(
              Provider.of<SupabaseService>(context, listen: false)),
          update: (_, supabaseService, previous) =>
              previous ?? ProductService(supabaseService),
        ),
        ChangeNotifierProxyProvider<SupabaseService, CartService>(
          create: (context) =>
              CartService(Provider.of<SupabaseService>(context, listen: false)),
          update: (_, supabaseService, previous) =>
              previous ?? CartService(supabaseService),
        ),
        ChangeNotifierProxyProvider2<SupabaseService, CartService,
            OrderService>(
          create: (context) => OrderService(
            Provider.of<SupabaseService>(context, listen: false),
            cartService: Provider.of<CartService>(context, listen: false),
          ),
          update: (_, supabaseService, cartService, previous) =>
              previous ??
              OrderService(supabaseService, cartService: cartService),
        ),
        ChangeNotifierProxyProvider<SupabaseService, AddressService>(
          create: (context) => AddressService(
              Provider.of<SupabaseService>(context, listen: false)),
          update: (_, supabaseService, previous) =>
              previous ?? AddressService(supabaseService),
        ),
      ],
      child: child,
    );
  }
}
