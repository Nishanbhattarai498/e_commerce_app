import 'product.dart';

class CartItem {
  final Product product;
  int quantity;
  final String size;
  final String color;

  CartItem({
    required this.product,
    this.quantity = 1,
    required this.size,
    required this.color,
  });

  double get totalPrice => product.price * quantity;
}

class Cart {
  List<CartItem> items = [];

  double get subtotal => items.fold(0, (sum, item) => sum + item.totalPrice);
  double get shipping => subtotal > 100 ? 0 : 10;
  double get tax => subtotal * 0.08;
  double get total => subtotal + shipping + tax;

  void addItem(CartItem item) {
    items.add(item);
  }

  void removeItem(int index) {
    items.removeAt(index);
  }

  void updateQuantity(int index, int quantity) {
    items[index].quantity = quantity;
  }

  void clear() {
    items.clear();
  }
}
