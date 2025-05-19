import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../services/product_service.dart';
import '../services/cart_service.dart';
import '../models/product.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/bottom_nav_bar.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({Key? key}) : super(key: key);

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _currentIndex = 1;
  int _currentImageIndex = 0;
  int _quantity = 1;
  Map<String, String> _selectedVariants = {};
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final productId = ModalRoute.of(context)!.settings.arguments as int;

    return FutureBuilder<Product?>(
      future: Provider.of<ProductService>(context, listen: false)
          .getProductById(productId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Product Not Found'),
            ),
            body: Center(
              child: Text(
                'Error loading product: ${snapshot.error ?? "Product not found"}',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        final product = snapshot.data!;

        // Initialize selected variants if not already done
        if (_selectedVariants.isEmpty && product.variants.isNotEmpty) {
          final variantNames =
              product.variants.map((v) => v.name).toSet().toList();

          for (final name in variantNames) {
            final variants =
                product.variants.where((v) => v.name == name).toList();

            if (variants.isNotEmpty) {
              _selectedVariants[name] = variants.first.value;
            }
          }
        }

        return Scaffold(
          appBar: CustomAppBar(
            title: product.name,
            cartItemCount: 3, // This would be dynamic in a real app
            onCartTap: () => Navigator.pushNamed(context, '/cart'),
            onAccountTap: () => Navigator.pushNamed(context, '/account'),
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Images Carousel
                Stack(
                  children: [
                    CarouselSlider(
                      options: CarouselOptions(
                        height: 300,
                        viewportFraction: 1.0,
                        enlargeCenterPage: false,
                        onPageChanged: (index, reason) {
                          setState(() {
                            _currentImageIndex = index;
                          });
                        },
                      ),
                      items: product.images.isEmpty
                          ? [
                              Image.network(
                                product.imageUrl ??
                                    'https://via.placeholder.com/300',
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                            ]
                          : product.images.map((image) {
                              return Image.network(
                                image.imageUrl,
                                fit: BoxFit.cover,
                                width: double.infinity,
                              );
                            }).toList(),
                    ),

                    // Image indicators
                    if (product.images.length > 1)
                      Positioned(
                        bottom: 10,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: product.images.asMap().entries.map((entry) {
                            return Container(
                              width: 8,
                              height: 8,
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _currentImageIndex == entry.key
                                    ? Theme.of(context).primaryColor
                                    : Colors.white.withOpacity(0.5),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                  ],
                ),

                // Product Info
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Name and Rating
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              product.name,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 20,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                product.rating.toString(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Price
                      Row(
                        children: [
                          if (product.isOnSale) ...[
                            Text(
                              '\$${product.price.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '\$${product.compareAtPrice!.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 18,
                                decoration: TextDecoration.lineThrough,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red[100],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${product.discountPercentage.toInt()}% OFF',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red[800],
                                ),
                              ),
                            ),
                          ] else ...[
                            Text(
                              '\$${product.price.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Variants
                      ..._buildVariantSelectors(product),

                      const SizedBox(height: 16),

                      // Quantity Selector
                      Row(
                        children: [
                          const Text(
                            'Quantity:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove),
                                  onPressed: _quantity > 1
                                      ? () {
                                          setState(() {
                                            _quantity--;
                                          });
                                        }
                                      : null,
                                ),
                                Text(
                                  _quantity.toString(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add),
                                  onPressed:
                                      _quantity < product.inventoryQuantity
                                          ? () {
                                              setState(() {
                                                _quantity++;
                                              });
                                            }
                                          : null,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Add to Cart Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading
                              ? null
                              : () => _addToCart(context, product),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Add to Cart',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Buy Now Button
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: _isLoading
                              ? null
                              : () {
                                  _addToCart(context, product, buyNow: true);
                                },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text(
                            'Buy Now',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Description
                      const Text(
                        'Description',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        product.description,
                        style: TextStyle(
                          color: Colors.grey[700],
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Reviews
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Reviews',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              // Show all reviews
                            },
                            child: const Text('See All'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Review summary
                      FutureBuilder<List<dynamic>>(
                        future: Future.wait([
                          Provider.of<ProductService>(context, listen: false)
                              .getProductReviews(product.id),
                        ]),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          if (snapshot.hasError || !snapshot.hasData) {
                            return const Text('Error loading reviews');
                          }

                          final reviews = snapshot.data![0];

                          if (reviews.isEmpty) {
                            return const Text('No reviews yet');
                          }

                          return Column(
                            children: [
                              // Review stats
                              Row(
                                children: [
                                  Text(
                                    product.rating.toString(),
                                    style: const TextStyle(
                                      fontSize: 48,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: List.generate(5, (index) {
                                          return Icon(
                                            index < product.rating.floor()
                                                ? Icons.star
                                                : index < product.rating
                                                    ? Icons.star_half
                                                    : Icons.star_border,
                                            color: Colors.amber,
                                            size: 20,
                                          );
                                        }),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Based on ${reviews.length} reviews',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // Sample review
                              if (reviews.isNotEmpty)
                                Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            CircleAvatar(
                                              backgroundImage: reviews[0]
                                                          .userAvatarUrl !=
                                                      null
                                                  ? NetworkImage(
                                                      reviews[0].userAvatarUrl!)
                                                  : null,
                                              child: reviews[0].userAvatarUrl ==
                                                      null
                                                  ? const Icon(Icons.person)
                                                  : null,
                                            ),
                                            const SizedBox(width: 8),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  reviews[0].userFullName ??
                                                      'Anonymous',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Text(
                                                  reviews[0]
                                                      .createdAt
                                                      .toString()
                                                      .substring(0, 10),
                                                  style: TextStyle(
                                                    color: Colors.grey[600],
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const Spacer(),
                                            Row(
                                              children:
                                                  List.generate(5, (index) {
                                                return Icon(
                                                  index < reviews[0].rating
                                                      ? Icons.star
                                                      : Icons.star_border,
                                                  color: Colors.amber,
                                                  size: 16,
                                                );
                                              }),
                                            ),
                                          ],
                                        ),
                                        if (reviews[0].title != null) ...[
                                          const SizedBox(height: 8),
                                          Text(
                                            reviews[0].title!,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                        if (reviews[0].content != null) ...[
                                          const SizedBox(height: 4),
                                          Text(reviews[0].content!),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: BottomNavBar(
            currentIndex: _currentIndex,
            onTap: (index) {
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
            },
          ),
        );
      },
    );
  }

  List<Widget> _buildVariantSelectors(Product product) {
    final variantNames = product.variants.map((v) => v.name).toSet().toList();

    return variantNames.map((name) {
      final variants = product.variants
          .where((v) => v.name == name)
          .map((v) => v.value)
          .toSet()
          .toList();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$name:',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: variants.map((value) {
              final isSelected = _selectedVariants[name] == value;

              return ChoiceChip(
                label: Text(value),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _selectedVariants[name] = value;
                    });
                  }
                },
                backgroundColor: Colors.grey[200],
                selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
        ],
      );
    }).toList();
  }

  Future<void> _addToCart(BuildContext context, Product product,
      {bool buyNow = false}) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final cartService = Provider.of<CartService>(context, listen: false);

      await cartService.addToCart(
        product: product,
        quantity: _quantity,
        variantOptions: _selectedVariants.isNotEmpty
            ? _selectedVariants.map((key, value) => MapEntry(key, value))
            : null,
      );

      if (buyNow) {
        Navigator.pushNamed(context, '/cart');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${product.name} added to cart'),
            action: SnackBarAction(
              label: 'View Cart',
              onPressed: () {
                Navigator.pushNamed(context, '/cart');
              },
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding to cart: $e'),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
