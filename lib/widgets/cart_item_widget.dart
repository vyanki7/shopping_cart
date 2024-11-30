import 'package:flutter/material.dart';
import 'package:shopping_cart/models/cart.dart';
import 'package:shopping_cart/provider/cart_provider.dart';
import 'package:shopping_cart/widgets/cart_item_action.dart';

class CartItemWidget extends StatelessWidget {
  final CartItem item;
  final CartProvider cartProvider;

  const CartItemWidget({required this.item, required this.cartProvider});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        height: 50,
        width: 50,
        child: ClipRRect(
          child: Image.asset(
            item.image,
            width: double.infinity,
            height: 50, // Adjust as needed
            fit: BoxFit.fill,
          ),
        ),
      ),
      title: Text(item.productName),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Price: \$${item.price.toStringAsFixed(2)}'),
          Text('Total: \$${item.totalPrice.toStringAsFixed(2)}'),
        ],
      ),
      trailing: CartItemActions(item: item, cartProvider: cartProvider),
    );
  }
}
