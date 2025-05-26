import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final int cartItemCount;
  final VoidCallback onCartTap;
  final VoidCallback onAccountTap;

  const CustomAppBar({
    Key? key,
    required this.title,
    required this.cartItemCount,
    required this.onCartTap,
    required this.onAccountTap,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              // Title
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              
              // Search Button
              Container(
                width: 44,
                height: 44,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.search_rounded,
                    color: Colors.black54,
                    size: 22,
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/products');
                  },
                ),
              ),
              
              // Cart Button with Badge
              Container(
                width: 44,
                height: 44,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Stack(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.shopping_bag_outlined,
                        color: Colors.black54,
                        size: 22,
                      ),
                      onPressed: onCartTap,
                    ),
                    if (cartItemCount > 0)
                      Positioned(
                        right: 6,
                        top: 6,
                        child: Container(
                          min: 18,
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 18,
                            minHeight: 18,
                          ),
                          child: Text(
                            cartItemCount > 99 ? '99+' : cartItemCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              
              // Account Button
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.person_outline_rounded,
                    color: Colors.black54,
                    size: 22,
                  ),
                  onPressed: onAccountTap,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  @override
  Size get preferredSize => const Size.fromHeight(80);
}
