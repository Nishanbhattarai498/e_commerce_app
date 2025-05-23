import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../services/product_service.dart';
import '../models/category.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/product_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  int _currentBannerIndex = 0;
  List<Category> _categories = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final productService =
          Provider.of<ProductService>(context, listen: false);
      productService.fetchProducts(isFeatured: true);
      _categories = await productService.getCategories();
      setState(() {});
    });
  }

  void _onNavBarTap(int index) {
    setState(() {
      _currentIndex = index;
    });

    // Navigate to the appropriate screen
    switch (index) {
      case 1:
        Navigator.pushNamed(context, '/products');
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
        title: 'Modern E-Commerce',
        cartItemCount: 3, // This would be dynamic in a real app
        onCartTap: () => Navigator.pushNamed(context, '/cart'),
        onAccountTap: () => Navigator.pushNamed(context, '/account'),
      ),
      body: Consumer<ProductService>(
        builder: (context, productService, _) {
          if (productService.isLoading && productService.products.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await productService.fetchProducts(isFeatured: true);
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Banner Carousel
                  Stack(
                    children: [
                      CarouselSlider(
                        options: CarouselOptions(
                          height: 200,
                          viewportFraction: 1.0,
                          autoPlay: true,
                          autoPlayInterval: const Duration(seconds: 5),
                          onPageChanged: (index, reason) {
                            setState(() {
                              _currentBannerIndex = index;
                            });
                          },
                        ),
                        items: [
                          _buildBanner(
                            'Summer Sale',
                            'Up to 50% off on selected items',
                            'https://images.unsplash.com/photo-1607082348824-0a96f2a4b9da?ixlib=rb-1.2.1&auto=format&fit=crop&w=1000&q=80',
                            () => Navigator.pushNamed(context, '/products'),
                          ),
                          _buildBanner(
                            'New Arrivals',
                            'Check out our latest products',
                            'https://images.unsplash.com/photo-1607083206968-13611e3d76db?ixlib=rb-1.2.1&auto=format&fit=crop&w=1000&q=80',
                            () => Navigator.pushNamed(context, '/products'),
                          ),
                          _buildBanner(
                            'Free Shipping',
                            'On orders over \$100',
                            'https://images.unsplash.com/photo-1607082349566-187342175e2f?ixlib=rb-1.2.1&auto=format&fit=crop&w=1000&q=80',
                            () => Navigator.pushNamed(context, '/products'),
                          ),
                        ],
                      ),

                      // Banner indicators
                      Positioned(
                        bottom: 10,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [0, 1, 2].map((index) {
                            return Container(
                              width: 8,
                              height: 8,
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _currentBannerIndex == index
                                    ? Theme.of(context).primaryColor
                                    : Colors.white.withOpacity(0.5),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),

                  // Categories
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Categories',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/products');
                          },
                          child: const Text('See All'),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        final category = _categories[index];
                        return _buildCategoryCard(
                          context,
                          category,
                          () => Navigator.pushNamed(context, '/products',
                              arguments: category),
                        );
                      },
                    ),
                  ),

                  // Featured Products
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: const Text(
                      'Featured Products',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.75,
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
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavBarTap,
      ),
    );
  }

  Widget _buildBanner(
      String title, String subtitle, String imageUrl, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Image.network(
            imageUrl,
            fit: BoxFit.cover,
            width: double.infinity,
          ),
          Container(
            color: Colors.black.withOpacity(0.5),
            width: double.infinity,
            height: double.infinity,
          ),
          Positioned(
            bottom: 20,
            left: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(
      BuildContext context, Category category, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 16),
        width: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey[200],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.category,
              size: 40,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 8),
            Text(
              category.name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
