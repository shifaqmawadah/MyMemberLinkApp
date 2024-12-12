import 'dart:convert'; // For jsonDecode
import 'package:flutter/material.dart'; // For Flutter widgets
import 'package:http/http.dart' as http; // For making HTTP requests
import 'package:my_member_link/myconfig.dart'; // For accessing your configuration (like server URL)

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List cartItems = [];

  @override
  void initState() {
    super.initState();
    loadCartData(); // Load cart data on init
  }

  void loadCartData() async {
    try {
      final response = await http.get(Uri.parse("${MyConfig.servername}/MyMemberLink/load_cart.php"));
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['status'] == "success") {
          setState(() {
            cartItems = data['data']['cart_items']; // Populate cart items list with data
          });
        } else {
          setState(() {
            cartItems = []; // Clear cart items if no data is available
          });
        }
      } else {
        setState(() {
          cartItems = []; // Clear cart items on error
        });
      }
    } catch (e) {
      setState(() {
        cartItems = []; // Clear cart items on error
      });
      print("Error loading cart: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Shopping Cart"),
      ),
      body: cartItems.isEmpty 
          ? Center(child: Text("No items in your cart"))
          : ListView.builder(
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        // Product Image
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.network(
                            cartItems[index]['product_image'],
                            width: 80, // Image width
                            height: 80, // Image height
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Product Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                cartItems[index]['product_name'],
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "\$${cartItems[index]['product_price']}",
                                style: const TextStyle(fontSize: 14, color: Colors.green),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Quantity: ${cartItems[index]['quantity']}",
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

