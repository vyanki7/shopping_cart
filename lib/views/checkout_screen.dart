import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopping_cart/provider/cart_provider.dart';
import 'package:shopping_cart/provider/product_provider.dart';
import 'package:shopping_cart/utils.dart';
import 'package:shopping_cart/widgets/CustomElevatedButton.dart';

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(
        title:const Text("C H E C K O U T"),
        centerTitle: true,
      ),
      body: Center(
        child: CustomElevatedButton(
          onPressed: () {
            cartProvider.placeOrder();
            Navigator.of(context).pop();
            context.read<ProductProvider>().fetchProducts();
            // showToast("Order placed..!");
          },
          text: "Buy now",
        ),
      ),
    );
  }
}
