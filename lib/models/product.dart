class Product {
  final int id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final double rating;
  final List<String> sizes;
  final List<String> colors;
  final String category;
  final bool isFeatured;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.rating,
    required this.sizes,
    required this.colors,
    required this.category,
    this.isFeatured = false,
  });
}

List<Product> dummyProducts = [
  Product(
    id: 1,
    name: 'Premium Cotton T-Shirt',
    description:
        'Soft and comfortable premium cotton t-shirt with a modern fit. Perfect for everyday wear and available in multiple colors.',
    price: 29.99,
    imageUrl:
        'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
    rating: 4.5,
    sizes: ['S', 'M', 'L', 'XL'],
    colors: ['Black', 'White', 'Navy', 'Gray'],
    category: 'Men',
    isFeatured: true,
  ),
  Product(
    id: 2,
    name: 'Wireless Noise-Cancelling Headphones',
    description:
        'Premium wireless headphones with active noise cancellation, 30-hour battery life, and comfortable over-ear design.',
    price: 199.99,
    imageUrl:
        'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
    rating: 4.8,
    sizes: ['One Size'],
    colors: ['Black', 'Silver', 'Rose Gold'],
    category: 'Electronics',
    isFeatured: true,
  ),
  Product(
    id: 3,
    name: 'Slim Fit Jeans',
    description:
        'Classic slim fit jeans with stretch for comfort. Made from high-quality denim that lasts.',
    price: 59.99,
    imageUrl:
        'https://images.unsplash.com/photo-1542272604-787c3835535d?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
    rating: 4.3,
    sizes: ['28', '30', '32', '34', '36'],
    colors: ['Blue', 'Black', 'Gray'],
    category: 'Men',
  ),
  Product(
    id: 4,
    name: 'Smart Watch Series 5',
    description:
        'Track your fitness, receive notifications, and more with this advanced smartwatch. Water-resistant and long battery life.',
    price: 249.99,
    imageUrl:
        'https://images.unsplash.com/photo-1546868871-7041f2a55e12?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
    rating: 4.7,
    sizes: ['One Size'],
    colors: ['Black', 'Silver', 'Gold'],
    category: 'Electronics',
    isFeatured: true,
  ),
  Product(
    id: 5,
    name: 'Leather Crossbody Bag',
    description:
        'Elegant leather crossbody bag with adjustable strap and multiple compartments for organization.',
    price: 79.99,
    imageUrl:
        'https://images.unsplash.com/photo-1584917865442-de89df76afd3?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
    rating: 4.6,
    sizes: ['One Size'],
    colors: ['Brown', 'Black', 'Tan'],
    category: 'Women',
  ),
  Product(
    id: 6,
    name: 'Minimalist Home Desk Lamp',
    description:
        'Modern desk lamp with adjustable brightness and color temperature. Perfect for your home office.',
    price: 49.99,
    imageUrl:
        'https://images.unsplash.com/photo-1507473885765-e6ed057f782c?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
    rating: 4.4,
    sizes: ['One Size'],
    colors: ['White', 'Black', 'Silver'],
    category: 'Home',
  ),
  Product(
    id: 7,
    name: 'Summer Floral Dress',
    description:
        'Light and breezy floral dress perfect for summer days. Features a flattering cut and comfortable fabric.',
    price: 69.99,
    imageUrl:
        'https://images.unsplash.com/photo-1612336307429-8a898d10e223?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
    rating: 4.5,
    sizes: ['XS', 'S', 'M', 'L'],
    colors: ['Blue Floral', 'Pink Floral', 'Yellow Floral'],
    category: 'Women',
    isFeatured: true,
  ),
  Product(
    id: 8,
    name: 'Premium Coffee Maker',
    description:
        'Programmable coffee maker with thermal carafe to keep your coffee hot for hours. Makes up to 12 cups.',
    price: 129.99,
    imageUrl:
        'https://images.unsplash.com/photo-1517668808822-9ebb02f2a0e6?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
    rating: 4.7,
    sizes: ['One Size'],
    colors: ['Stainless Steel', 'Black'],
    category: 'Home',
  ),
];

List<String> categories = [
  'Men',
  'Women',
  'Electronics',
  'Home',
  'Accessories',
];
