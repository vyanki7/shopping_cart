class Product {
  final int product_id;
  final String name;
  final double price;
  final int quantity;
  final String image;

  Product(
      {required this.product_id,
      required this.name,
      required this.price,
      required this.quantity,
      required this.image});

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
        product_id: json['product_id'] as int,
        name: json['name'] as String,
        price: (json['price'] as num).toDouble(),
        quantity: json['quantity'] as int,
        image: json['image']);
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': product_id,
      'name': name,
      'price': price,
      'quantity': quantity,
      'image': image
    };
  }
}
