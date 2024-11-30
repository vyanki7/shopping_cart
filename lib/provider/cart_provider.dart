import 'package:flutter/material.dart';
import 'package:shopping_cart/database/database.dart';
import 'package:shopping_cart/models/cart.dart';

class CartProvider extends ChangeNotifier {
  List<CartItem> _cartItems = [];

  List<CartItem> get cartItems => _cartItems;

  // Variable to calculate total value of all items in the cart
  double get totalCartValue {
    double total = _cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);
    if (total > 100) {
      total *= 0.9; // Apply 10% discount
    }
    return total;
  }

  // Fetch cart items from the database
  Future<void> fetchCartItems() async {
    notifyListeners();
    try {
      _cartItems = await DatabaseHelper().fetchCartItems();
      print('Fetched cart items: $_cartItems');
    } catch (error) {
      print('Error fetching cart items: $error');
    } finally {
      notifyListeners();
    }
  }

  // Add a product to the cart
  Future<void> addToCart(int productId, int quantity) async {
    try {
      await DatabaseHelper().addProductToCart(productId, quantity);
      await fetchCartItems(); // Refresh the cart items
    } catch (error) {
      print('Error adding product to cart: $error');
    }
  }

  // Update the quantity of a cart item
  Future<void> updateCartItemQuantity(
      int cartId, int productId, int newQuantity) async {
    try {
      if (newQuantity <= 0) {
        await DatabaseHelper().deleteCartItem(cartId);
      } else {
        await DatabaseHelper()
            .updateCartItemQuantity(cartId, productId, newQuantity);
      }
      await fetchCartItems(); // Refresh the cart items
    } catch (error) {
      print('Error updating cart item quantity: $error');
    }
  }

  // Delete a cart item
  Future<void> deleteCartItem(int cartId) async {
    try {
      await DatabaseHelper().deleteCartItem(cartId); // Call the database method
      await fetchCartItems(); // Refresh the cart items after deletion
    } catch (e) {
      print('Error deleting cart item: $e');
    }
  }

  // Place an order and insert bill details into the database
  Future<void> placeOrder() async {
    if (_cartItems.isEmpty) {
      print('Cart is empty. Cannot place an order.');
      return;
    }

    try {
      double billTotal = totalCartValue;

      // Insert the bill and bill details into the database
      await DatabaseHelper().insertBill(
        billTotal: billTotal,
        cartItems: _cartItems,
      );

      // Clear the cart after placing the order
      await DatabaseHelper().clearCart();
      _cartItems.clear(); // Clear the local cart items
      notifyListeners();

      print('Order placed successfully.');
    } catch (error) {
      print('Error placing order: $error');
    }
  }
}
