import 'package:flutter/material.dart';
import 'package:shopping_cart/models/cart.dart';
import 'package:shopping_cart/provider/cart_provider.dart';

class CartItemActions extends StatelessWidget {
  final CartItem item;
  final CartProvider cartProvider;

  const CartItemActions({required this.item, required this.cartProvider});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.remove),
          onPressed: () {
            if (item.productQuantity > 1) {
              cartProvider.updateCartItemQuantity(item.cartId,item.productId, item.productQuantity - 1);
            } else {
              cartProvider.deleteCartItem(item.cartId);
            }
          },
        ),
        Text('${item.productQuantity}',style: TextStyle(fontSize: 15),),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () {
            cartProvider.updateCartItemQuantity(item.cartId,item.productId, item.productQuantity + 1);
          },
        ),
        IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () {
            cartProvider.deleteCartItem(item.cartId);
          },
        ),
      ],
    );
  }
}