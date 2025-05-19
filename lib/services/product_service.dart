import 'package:flutter/foundation.dart';
import 'package:postgrest/src/postgrest_builder.dart';
import 'package:postgrest/src/types.dart';
import '../models/product.dart';
import '../models/category.dart';
import 'supabase_service.dart';

class ProductService {
  final SupabaseService _supabaseService;

  ProductService(this._supabaseService);

  Future<List<Product>> getProducts({
    int? limit,
    int? offset,
    String? searchQuery,
    int? categoryId,
    String? sortBy,
    bool? isFeatured,
  }) async {
    try {
      PostgrestTransformBuilder<PostgrestList> query = _supabaseService.client
          .from('products')
          .select('*, category:categories(*)');

      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.ilike('name', '%$searchQuery%');
      }

      if (categoryId != null) {
        query = query.eq('category_id', categoryId);
      }

      if (isFeatured != null) {
        query = query.eq('is_featured', isFeatured);
      }

      if (sortBy != null) {
        switch (sortBy) {
          case 'price_asc':
            query = query.order('price', ascending: true);
            break;
          case 'price_desc':
            query = query.order('price', ascending: false);
            break;
          case 'name_asc':
            query = query.order('name', ascending: true);
            break;
          case 'name_desc':
            query = query.order('name', ascending: false);
            break;
          case 'rating':
            query = query.order('rating', ascending: false);
            break;
          default:
            query = query.order('created_at', ascending: false);
        }
      } else {
        query = query.order('created_at', ascending: false);
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      if (offset != null) {
        query = query.range(offset, offset + (limit ?? 10) - 1);
      }

      final data = await query;

      return data.map<Product>((json) => Product.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error fetching products: $e');
      rethrow;
    }
  }

  Future<Product> getProductById(int id) async {
    try {
      final data = await _supabaseService.client
          .from('products')
          .select('*, category:categories(*)')
          .eq('id', id)
          .single();

      final product = Product.fromJson(data);

      // Fetch product images
      final images = await _supabaseService.client
          .from('product_images')
          .select('*')
          .eq('product_id', id)
          .order('display_order', ascending: true);

      product.images =
          images.map<String>((json) => json['image_url'] as String).toList();

      // Fetch product variants
      final variants = await _supabaseService.client
          .from('product_variants')
          .select('*')
          .eq('product_id', id);

      // Group variants by name
      final Map<String, List<String>> variantMap = {};
      for (final variant in variants) {
        final name = variant['name'] as String;
        final value = variant['value'] as String;

        if (!variantMap.containsKey(name)) {
          variantMap[name] = [];
        }

        variantMap[name]!.add(value);
      }

      product.variants = variantMap;

      return product;
    } catch (e) {
      debugPrint('Error fetching product by id: $e');
      rethrow;
    }
  }

  Future<List<Category>> getCategories() async {
    try {
      final data = await _supabaseService.client
          .from('categories')
          .select('*')
          .order('name', ascending: true);

      return data.map<Category>((json) => Category.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error fetching categories: $e');
      rethrow;
    }
  }

  Future<Category> getCategoryById(int id) async {
    try {
      final data = await _supabaseService.client
          .from('categories')
          .select('*')
          .eq('id', id)
          .single();

      return Category.fromJson(data);
    } catch (e) {
      debugPrint('Error fetching category by id: $e');
      rethrow;
    }
  }
}
