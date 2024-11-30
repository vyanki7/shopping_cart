import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopping_cart/database/database.dart';
import 'package:shopping_cart/provider/cart_provider.dart';
import 'package:shopping_cart/provider/product_provider.dart';
import 'package:shopping_cart/views/cart_screen.dart';
import 'package:shopping_cart/widgets/product_widget.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    get();
  }

  void get() async {
    await DatabaseHelper().insertProductsWithOffers();
    Future.microtask(() {
      context.read<ProductProvider>().fetchProducts();
    });
    Future.microtask(() {
      context.read<CartProvider>().fetchCartItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    return Scaffold(
      appBar: AppBar(
        title: Text("S H O P P I N G  C A R T"),
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CartScreen()),
                );
              },
              icon: const Icon(Icons.shopping_cart)),
          const SizedBox(
            width: 10,
          )
        ],
      ),
      body: Consumer<ProductProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.products.isEmpty) {
            return const Center(child: Text('No products available.'));
          }
          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // Set 2 columns for the grid
              crossAxisSpacing: 5, // Space between columns
              mainAxisSpacing: 5, // Space between rows
              childAspectRatio: 0.60, // Controls the size of the cards
            ),
            itemCount: provider.products.length,
            itemBuilder: (context, index) {
              final product = provider.products[index];
              return ProductCard(
                product: product,
                onAddToCart: () async {
                  cartProvider.addToCart(product.product_id, 1);
                  // await DatabaseHelper().addProductToCart(product.product_id,1);
                },
              );
            },
          );
        },
      ),
    );
  }
}
