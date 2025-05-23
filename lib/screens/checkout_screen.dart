import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/cart_service.dart';
import '../services/address_service.dart';
import '../services/order_service.dart';
import '../models/address.dart';
import '../models/cart.dart';
import '../widgets/custom_app_bar.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({Key? key}) : super(key: key);

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  int _currentStep = 0;
  Address? _selectedAddress;
  String _paymentMethod = 'Credit Card';
  bool _isPlacingOrder = false;

  @override
  void initState() {
    super.initState();
    // Fetch addresses when the screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AddressService>(context, listen: false).fetchAddresses();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Checkout',
        cartItemCount: 3, // This would be dynamic in a real app
        onCartTap: () => Navigator.pushNamed(context, '/cart'),
        onAccountTap: () => Navigator.pushNamed(context, '/account'),
      ),
      body: Consumer3<CartService, AddressService, OrderService>(
        builder: (context, cartService, addressService, orderService, _) {
          if (cartService.isLoading ||
              addressService.isLoading ||
              orderService.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final cart = cartService.cart;

          if (cart == null || cart.items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Your cart is empty',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add items to get started',
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/products');
                    },
                    child: const Text('Browse Products'),
                  ),
                ],
              ),
            );
          }

          // If no address is selected, select the default one
          if (_selectedAddress == null && addressService.addresses.isNotEmpty) {
            _selectedAddress = addressService.defaultAddress;
          }

          return Stepper(
            currentStep: _currentStep,
            onStepContinue: () {
              setState(() {
                if (_currentStep < 2) {
                  _currentStep += 1;
                } else {
                  _placeOrder(context, cart, orderService);
                }
              });
            },
            onStepCancel: () {
              setState(() {
                if (_currentStep > 0) {
                  _currentStep -= 1;
                }
              });
            },
            controlsBuilder: (context, details) {
              return Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Row(
                  children: [
                    ElevatedButton(
                      onPressed:
                          _isPlacingOrder ? null : details.onStepContinue,
                      child: _isPlacingOrder
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              _currentStep == 2 ? 'Place Order' : 'Continue'),
                    ),
                    if (_currentStep > 0) ...[
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: details.onStepCancel,
                        child: const Text('Back'),
                      ),
                    ],
                  ],
                ),
              );
            },
            steps: [
              // Step 1: Shipping Address
              Step(
                title: const Text('Shipping Address'),
                content: _buildShippingAddressStep(addressService),
                isActive: _currentStep >= 0,
                state:
                    _currentStep > 0 ? StepState.complete : StepState.indexed,
              ),

              // Step 2: Payment Method
              Step(
                title: const Text('Payment Method'),
                content: _buildPaymentMethodStep(),
                isActive: _currentStep >= 1,
                state:
                    _currentStep > 1 ? StepState.complete : StepState.indexed,
              ),

              // Step 3: Review Order
              Step(
                title: const Text('Review Order'),
                content: _buildReviewOrderStep(cart),
                isActive: _currentStep >= 2,
                state:
                    _currentStep > 2 ? StepState.complete : StepState.indexed,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildShippingAddressStep(AddressService addressService) {
    if (addressService.addresses.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'You don\'t have any saved addresses.',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/account');
            },
            child: const Text('Add Address'),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select a shipping address:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...addressService.addresses.map((address) {
          return RadioListTile<Address>(
            title: Text(address.name),
            subtitle: Text(address.formattedAddress),
            value: address,
            groupValue: _selectedAddress,
            onChanged: (value) {
              setState(() {
                _selectedAddress = value;
              });
            },
            secondary: address.isDefault
                ? const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                  )
                : null,
          );
        }).toList(),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: () {
            Navigator.pushNamed(context, '/account');
          },
          icon: const Icon(Icons.add),
          label: const Text('Add New Address'),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select a payment method:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        RadioListTile<String>(
          title: const Text('Credit Card'),
          subtitle:
              const Text('Pay with Visa, Mastercard, or American Express'),
          value: 'Credit Card',
          groupValue: _paymentMethod,
          onChanged: (value) {
            setState(() {
              _paymentMethod = value!;
            });
          },
          secondary: const Icon(Icons.credit_card),
        ),
        RadioListTile<String>(
          title: const Text('PayPal'),
          subtitle: const Text('Pay with your PayPal account'),
          value: 'PayPal',
          groupValue: _paymentMethod,
          onChanged: (value) {
            setState(() {
              _paymentMethod = value!;
            });
          },
          secondary: const Icon(Icons.account_balance_wallet),
        ),
        RadioListTile<String>(
          title: const Text('Cash on Delivery'),
          subtitle: const Text('Pay when you receive your order'),
          value: 'Cash on Delivery',
          groupValue: _paymentMethod,
          onChanged: (value) {
            setState(() {
              _paymentMethod = value!;
            });
          },
          secondary: const Icon(Icons.money),
        ),
      ],
    );
  }

  Widget _buildReviewOrderStep(Cart cart) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Order Summary',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 16),

        // Items
        ...cart.items.map((item) {
          return ListTile(
            contentPadding: EdgeInsets.zero,
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                item.product.imageUrl,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              ),
            ),
            title: Text(
              item.product.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              'Qty: ${item.quantity}',
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
            trailing: Text(
              '\$${item.totalPrice.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        }).toList(),

        const Divider(),

        // Subtotal
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Subtotal',
              style: TextStyle(
                color: Colors.grey[700],
              ),
            ),
            Text(
              '\$${cart.subtotal.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Shipping
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Shipping',
              style: TextStyle(
                color: Colors.grey[700],
              ),
            ),
            Text(
              cart.shipping > 0
                  ? '\$${cart.shipping.toStringAsFixed(2)}'
                  : 'Free',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: cart.shipping > 0 ? null : Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Tax
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Tax',
              style: TextStyle(
                color: Colors.grey[700],
              ),
            ),
            Text(
              '\$${cart.tax.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Divider(),
        const SizedBox(height: 8),

        // Total
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Total',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              '\$${cart.total.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Shipping Address
        const Text(
          'Shipping Address',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        if (_selectedAddress != null) ...[
          Text(_selectedAddress!.name),
          Text(_selectedAddress!.formattedAddress),
        ] else ...[
          const Text('No address selected'),
        ],
        const SizedBox(height: 16),

        // Payment Method
        const Text(
          'Payment Method',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Text(_paymentMethod),
      ],
    );
  }

  Future<void> _placeOrder(
    BuildContext context,
    Cart cart,
    OrderService orderService,
  ) async {
    if (_selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a shipping address'),
        ),
      );
      return;
    }

    setState(() {
      _isPlacingOrder = true;
    });

    try {
      final order = await orderService.createOrder(
        shippingAddress: {
          'name': _selectedAddress!.name,
          'address_line1': _selectedAddress!.addressLine1,
          'address_line2': _selectedAddress!.addressLine2,
          'city': _selectedAddress!.city,
          'state': _selectedAddress!.state,
          'postal_code': _selectedAddress!.postalCode,
          'country': _selectedAddress!.country,
        },
        billingAddress: {
          'name': _selectedAddress!.name,
          'address_line1': _selectedAddress!.addressLine1,
          'address_line2': _selectedAddress!.addressLine2,
          'city': _selectedAddress!.city,
          'state': _selectedAddress!.state,
          'postal_code': _selectedAddress!.postalCode,
          'country': _selectedAddress!.country,
        },
        paymentMethod: {
          'type': _paymentMethod,
        },
      );

      if (order != null) {
        // Show success dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('Order Placed!'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 80,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Your order has been placed successfully.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Order #${order.id.substring(0, 8)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/',
                    (route) => false,
                  );
                },
                child: const Text('Continue Shopping'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/account');
                },
                child: const Text('View Orders'),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to place order. Please try again.'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error placing order: $e'),
        ),
      );
    } finally {
      setState(() {
        _isPlacingOrder = false;
      });
    }
  }
}
