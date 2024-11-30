import 'package:shopping_cart/models/cart.dart';
import 'package:shopping_cart/models/product.dart';
import 'package:shopping_cart/utils.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../constant.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'app_database.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
    CREATE TABLE Offer (
      offer_id INTEGER PRIMARY KEY ,
      offer_details TEXT NOT NULL
    )
  ''');

    await db.execute('''
    CREATE TABLE Product (
      product_id INTEGER PRIMARY KEY ,
      name TEXT NOT NULL,
      image TEXT NOT NULL,
      price REAL NOT NULL,
      quantity INTEGER NOT NULL
    )
  ''');

    await db.execute('''
   CREATE TABLE bills (
  bill_id INTEGER PRIMARY KEY,
  bill_date TEXT NOT NULL,
  bill_total REAL NOT NULL
)
  ''');

    await db.execute('''
    CREATE TABLE billdetails (
  detail_id INTEGER PRIMARY KEY,
  bill_id INTEGER NOT NULL,
  cart_id INTEGER NOT NULL,
  product_id INTEGER NOT NULL,
  product_name TEXT NOT NULL,
  price REAL NOT NULL,
  product_quantity INTEGER NOT NULL,
  image TEXT,
  FOREIGN KEY (bill_id) REFERENCES bills (bill_id) ON DELETE CASCADE
)
 ''');

    await db.execute('''
  CREATE TABLE cart (
  cart_id INTEGER PRIMARY KEY,
  product_id INTEGER NOT NULL,
  product_quantity INTEGER NOT NULL,
  FOREIGN KEY (product_id) REFERENCES Product(product_id) ON DELETE CASCADE
   )
  ''');
  }

  Future<void> closeDatabase() async {
    final db = await database;
    db.close();
  }

  Future<void> insertBill({
    required double billTotal,
    required List<CartItem> cartItems,
  }) async {
    final db = await database;
    try {
      // Get the current date in a formatted string
      String currentDate = DateTime.now().toIso8601String(); // ISO 8601 format

      // Begin a transaction
      await db.transaction((txn) async {
        // Insert into the 'bills' table
        int billId = await txn.insert('bills', {
          'bill_date': currentDate,
          'bill_total': billTotal,
        });

        // Insert each CartItem into the 'billdetails' table and update product quantities
        for (var cartItem in cartItems) {
          // Fetch the current product quantity
          final product = await txn.query(
            'Product',
            where: 'product_id = ?',
            whereArgs: [cartItem.productId],
            limit: 1,
          );

          if (product.isEmpty) {
            print('Product with ID ${cartItem.productId} not found.');
            continue; // Skip if product is not found
          }

          int availableQuantity = product[0]['quantity'] as int;

          // Ensure the ordered quantity does not exceed available quantity
          if (cartItem.productQuantity > availableQuantity) {
            throw Exception(
                'Insufficient quantity for product "${product[0]['name']}".');
          }

          // Insert into the 'billdetails' table
          await txn.insert('billdetails', {
            'bill_id': billId,
            ...cartItem.toMap(),
          });

          // Update the product quantity in the 'Product' table
          await txn.update(
            'Product',
            {'quantity': availableQuantity - cartItem.productQuantity},
            where: 'product_id = ?',
            whereArgs: [cartItem.productId],
          );
        }
      });

      print('Bill and details added successfully');
      showToast('Order placed successfully!');
    } catch (e) {
      print('Error adding bill: $e');
      showToast('Failed to place order. Please try again.');
      rethrow;
    }
  }


  // Clear all items in the cart table
  Future<void> clearCart() async {
    final db = await database;
    try {
      await db.delete('cart'); // Clear all rows in the cart table
      print('Cart cleared successfully.');
    } catch (error) {
      print('Error clearing cart: $error');
      rethrow;
    }
  }

  Future<void> insertProductsWithOffers() async {
    final db = await database;
    for (var offer in offers) {
      await db.insert(
        'Offer',
        offer,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    for (var product in productList) {
      await db.insert(
        'Product',
        product,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    print('Products and Offers inserted successfully!');

    await fetchProducts();
  }

  Future<List<Product>> fetchProducts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('Product');

    print(maps);
    return List.generate(maps.length, (i) {
      return Product.fromJson(maps[i]);
    });
  }

  Future<void> addProductToCart(int productId, int quantity) async {
    print("add to cart");
    final db = await database;

    // Check if product is already in the cart
    final List<Map<String, dynamic>> existingCart = await db.query(
      'cart',
      where: 'product_id = ?',
      whereArgs: [productId],
    );

    if (existingCart.isNotEmpty) {
      print("already to cart");
      await db.update(
        'cart',
        {
          'product_quantity': existingCart.first['product_quantity'] + quantity,
        },
        where: 'product_id = ?',
        whereArgs: [productId],
      );
    } else {
      print("add to cart");
      await db.insert(
        'cart',
        {
          'product_id': productId,
          'product_quantity': quantity,
        },
      );
    }
  }

  Future<List<CartItem>> fetchCartItems() async {
    final db = await database;

    final result = await db.rawQuery('''
    SELECT 
      cart.cart_id,
      Product.name AS product_name,
      Product.price,
      Product.image,
      cart.product_id,
      cart.product_quantity,
      (Product.price * cart.product_quantity) AS total_price
    FROM cart
    JOIN Product ON cart.product_id = Product.product_id;
  ''');

    return result.map((item) => CartItem.fromMap(item)).toList();
  }

  Future<void> updateCartItemQuantity(
      int cartId, int productId, int newQuantity) async {
    final db = await database;

    try {
      // Fetch the available quantity for the product
      final product = await db.query(
        'Product',
        where: 'product_id = ?',
        whereArgs: [productId],
        limit: 1,
      );

      if (product.isEmpty) {
        showToast('Product not found.');
        return;
      }

      // Get the available quantity from the product row
      int availableQuantity = product[0]['quantity'] as int;

      // Check if the requested quantity exceeds the available quantity
      if (newQuantity > availableQuantity) {
        showToast(
            'Only $availableQuantity units of "${product[0]['name']}" are available.');
        return;
      }

      // If the new quantity is 0 or less, delete the cart item
      if (newQuantity <= 0) {
        await db.delete(
          'cart',
          where: 'cart_id = ?',
          whereArgs: [cartId],
        );
        // showToast('Cart item removed.');
      } else {
        // Update the cart quantity if valid
        await db.update(
          'cart',
          {'product_quantity': newQuantity},
          where: 'cart_id = ?',
          whereArgs: [cartId],
        );
        // showToast('Cart item updated successfully.');
      }

      print('Cart item with ID $cartId updated successfully.');
    } catch (e) {
      print('Error updating cart item quantity: $e');
      showToast('Failed to update cart item. Please try again.');
    }
  }

  Future<void> deleteCartItem(int cartId) async {
    final db = await database;

    try {
      await db.delete(
        'cart',
        where: 'cart_id = ?',
        whereArgs: [cartId],
      );
      print('Cart item with ID $cartId deleted successfully.');
    } catch (e) {
      print('Error deleting cart item: $e');
    }
  }
}
