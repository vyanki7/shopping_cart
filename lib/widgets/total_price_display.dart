import 'package:flutter/material.dart';
import 'package:shopping_cart/provider/cart_provider.dart';
import 'package:shopping_cart/views/checkout_screen.dart';
import 'package:shopping_cart/widgets/CustomElevatedButton.dart';

class TotalPriceDisplay extends StatelessWidget {
  final CartProvider cartProvider;
  const TotalPriceDisplay({required this.cartProvider});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                '\$${cartProvider.totalCartValue.toStringAsFixed(2)}',
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          cartProvider.totalCartValue > 100
              ? const Text('10% discount applied')
              : const SizedBox.shrink(),
          CustomElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CheckoutScreen()),
              );
            },
            text: 'Checkout',
          )
        ],
      ),
    );
  }
}
