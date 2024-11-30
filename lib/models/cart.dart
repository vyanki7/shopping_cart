class CartItem {
  final int cartId;
  final int productId;
  final String productName;
  final double price;
  final int productQuantity;
  final double totalPrice;
  final String image;

  CartItem({
    required this.cartId,
    required this.productId,
    required this.productName,
    required this.price,
    required this.productQuantity,
    required this.image,
  }) : totalPrice = price * productQuantity;

  // Factory constructor to create a CartItem from a database query result.
  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      cartId: map['cart_id'],
      productId: map['product_id'],
      productName: map['product_name'],
      price: map['price'],
      productQuantity: map['product_quantity'],
      image: map['image']
    );
  }

  // Convert CartItem to a map for database operations.
  Map<String, dynamic> toMap() {
    return {
      'cart_id': cartId,
      'product_id': productId,
      'product_name': productName,
      'price': price,
      'product_quantity': productQuantity,
      'image':image
    };
  }
}
