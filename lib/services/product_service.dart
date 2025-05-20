import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../models/category.dart' as app_models;
import 'supabase_service.dart';

class ProductService extends ChangeNotifier {
  final SupabaseService _supabaseService;
  List<Product> _products = [];
  bool _isLoading = false;

  ProductService(this._supabaseService);

  List<Product> get products => _products;
  bool get isLoading => _isLoading;

  Future<List<Product>> fetchProducts({
    String? searchQuery,
    int? categoryId,
    bool? isFeatured,
    String? sortBy,
    bool? sortAscending,
    int offset = 0,
    int limit = 10,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      var baseQuery = _supabaseService.client.from('products').select();
      if (searchQuery != null && searchQuery.isNotEmpty) {
        baseQuery = baseQuery.like('name', '%$searchQuery%');
      }
      if (categoryId != null) {
        baseQuery = baseQuery.eq('category_id', categoryId);
      }
      if (isFeatured != null) {
        baseQuery = baseQuery.eq('is_featured', isFeatured);
      }
      dynamic data;
      if (sortBy != null) {
        data = await baseQuery.order(sortBy, ascending: sortAscending ?? true);
      } else {
        data = await baseQuery;
      }
      List<Product> products = (data as List).map((json) => Product.fromJson(json)).toList();
      final paginated = products.skip(offset).take(limit).toList();
      _products = paginated;
      return _products;
    } catch (e) {
      debugPrint('Error fetching products: $e');
      return [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Product?> getProductById(int id) async {
    try {
      final response = await _supabaseService.client
          .from('products')
          .select('*, category:categories(*)')
          .eq('id', id)
          .single();
      return Product.fromJson(response);
    } catch (e) {
      debugPrint('Error fetching product by ID: $e');
      return null;
    }
  }

  Future<List<app_models.Category>> getCategories() async {
    try {
      final response = await _supabaseService.client
          .from('categories')
          .select();
      return response.map((json) => app_models.Category.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error fetching categories: $e');
      return [];
    }
  }

  Future<app_models.Category?> getCategoryById(int id) async {
    try {
      final response = await _supabaseService.client
          .from('categories')
          .select()
          .eq('id', id)
          .single();
      return app_models.Category.fromJson(response);
    } catch (e) {
      debugPrint('Error fetching category by ID: $e');
      return null;
    }
  }
}
