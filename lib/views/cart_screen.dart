import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopping_cart/provider/cart_provider.dart';
import 'package:shopping_cart/widgets/cart_item_widget.dart';
import 'package:shopping_cart/widgets/total_price_display.dart';

class CartScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('C A R T'),centerTitle: true,
      ),
      body: cartProvider.cartItems.isEmpty
          ? const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
               Icon(Icons.add_shopping_cart,size: 200,),
               Center(child: Text('No items in the cart.')),
            ],
          )
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: cartProvider.cartItems.length,
              itemBuilder: (context, index) {
                final item = cartProvider.cartItems[index];
                return CartItemWidget(item: item, cartProvider: cartProvider);
              },
            ),
          ),
          TotalPriceDisplay(cartProvider: cartProvider),

        ],
      ),
    );
  }
}






