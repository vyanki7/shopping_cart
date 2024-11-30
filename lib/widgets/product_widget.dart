import 'package:flutter/material.dart';
import 'package:shopping_cart/models/product.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onAddToCart;

  const ProductCard({
    required this.product,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4,
      child: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Product Image
            ClipRRect(
              child: Image.asset(
                product.image,
                width: double.infinity,
                height: 150, // Adjust as needed
                fit: BoxFit.fill,
              ),
            ),
            const SizedBox(height: 16),
            // Product Details
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text('Price: \$${product.price.toStringAsFixed(2)}'),
                  const SizedBox(height: 4),
                  product.quantity > 0
                      ? Text('Quantity: ${product.quantity}')
                      :const Text(
                          "Out of stock",
                          style: TextStyle(color: Colors.red),
                        ),
                  const SizedBox(height: 16),
                  product.quantity > 0
                      ? OutlinedButton(
                          onPressed: onAddToCart,
                          style: ElevatedButton.styleFrom(
                            minimumSize:
                                Size(double.infinity, 36), // Full-width button
                          ),
                          child: Text('Add to Cart'),
                        )
                      : SizedBox.shrink(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
