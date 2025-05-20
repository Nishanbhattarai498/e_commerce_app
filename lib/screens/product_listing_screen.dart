import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/product_service.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/product_card.dart';
import '../widgets/category_filter.dart';

class ProductListingScreen extends StatefulWidget {
  const ProductListingScreen({Key? key}) : super(key: key);

  @override
  State<ProductListingScreen> createState() => _ProductListingScreenState();
}

class _ProductListingScreenState extends State<ProductListingScreen> {
  int _currentIndex = 1;
  int? _selectedCategoryId;
  String _sortBy = 'created_at';
  bool _ascending = false;
  String _searchQuery = '';
  final _searchController = TextEditingController();
  List<Category> _categories = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _fetchProducts();
      final productService = Provider.of<ProductService>(context, listen: false);
      _categories = await productService.getCategories();
      setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _fetchProducts() {
    final productService = Provider.of<ProductService>(context, listen: false);
    productService.fetchProducts(
      categoryId: _selectedCategoryId,
      searchQuery: _searchQuery,
      sortBy: _sortBy,
      sortAscending: _ascending,
    );
  }

  void _onCategorySelected(int? categoryId) {
    setState(() {
      _selectedCategoryId = categoryId;
    });
    _fetchProducts();
  }

  void _onSortChanged(String sortBy, bool ascending) {
    setState(() {
      _sortBy = sortBy;
      _ascending = ascending;
    });
    _fetchProducts();
  }

  void _onSearch(String query) {
    setState(() {
      _searchQuery = query;
    });
    _fetchProducts();
  }

  void _onNavBarTap(int index) {
    setState(() {
      _currentIndex = index;
    });

    // Navigate to the appropriate screen
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/');
        break;
      case 3:
        Navigator.pushNamed(context, '/cart');
        break;
      case 4:
        Navigator.pushNamed(context, '/account');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Products',
        cartItemCount: 3, // This would be dynamic in a real app
        onCartTap: () => Navigator.pushNamed(context, '/cart'),
        onAccountTap: () => Navigator.pushNamed(context, '/account'),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _onSearch('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onSubmitted: _onSearch,
            ),
          ),

          // Category Filter
          CategoryFilter(
            categories: _categories,
            selectedCategoryId: _selectedCategoryId,
            onCategorySelected: _onCategorySelected,
          ),

          // Sort Options
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Consumer<ProductService>(
                  builder: (context, productService, _) {
                    return Text(
                      '${productService.products.length} Products',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
                DropdownButton<String>(
                  value: _sortBy,
                  icon: const Icon(Icons.arrow_drop_down),
                  underline: Container(
                    height: 2,
                    color: Theme.of(context).primaryColor,
                  ),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      _onSortChanged(newValue, _ascending);
                    }
                  },
                  items: <String>['created_at', 'price', 'name', 'rating']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value == 'created_at'
                            ? 'Newest'
                            : value == 'price'
                                ? 'Price'
                                : value == 'name'
                                    ? 'Name'
                                    : 'Rating',
                      ),
                    );
                  }).toList(),
                ),
                IconButton(
                  icon: Icon(
                      _ascending ? Icons.arrow_upward : Icons.arrow_downward),
                  onPressed: () {
                    _onSortChanged(_sortBy, !_ascending);
                  },
                ),
              ],
            ),
          ),

          // Product Grid
          Expanded(
            child: Consumer<ProductService>(
              builder: (context, productService, _) {
                if (productService.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (productService.products.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No products found',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try changing your search or filter',
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: productService.products.length,
                  itemBuilder: (context, index) {
                    final product = productService.products[index];
                    return ProductCard(
                      product: product,
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/product',
                          arguments: product.id,
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavBarTap,
      ),
    );
  }
}
