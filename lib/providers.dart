import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/supabase_service.dart';
import 'services/product_service.dart';
import 'services/cart_service.dart';

Future<void> initializeServices() async {
  final supabaseService = SupabaseService();
  await supabaseService.initialize();
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
        ProxyProvider<SupabaseService, ProductService>(
          update: (_, supabaseService, __) => ProductService(supabaseService),
        ),
        ChangeNotifierProxyProvider2<SupabaseService, ProductService,
            CartService>(
          create: (context) => CartService(
            Provider.of<SupabaseService>(context, listen: false),
            Provider.of<ProductService>(context, listen: false),
          ),
          update: (_, supabaseService, productService, previous) =>
              previous ?? CartService(supabaseService, productService),
        ),
      ],
      child: child,
    );
  }
}
