import 'dart:convert'; // For JSON encoding/decoding
import 'package:flutter/material.dart'; // For Flutter widgets
import 'package:http/http.dart' as http; // For making HTTP requests
import 'package:my_member_link/views/shared/mydrawer.dart'; // Import your drawer widget
import 'package:my_member_link/views/product/cart_screen.dart'; // Import the CartScreen
import 'package:my_member_link/myconfig.dart'; // Import your configuration
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart'; // Import CachedNetworkImage

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  List products = [];
  int numOfPages = 1;
  int currentPage = 1;
  late double screenWidth, screenHeight;

  @override
  void initState() {
    super.initState();
    loadProductData(); // Load data on init
  }

  void loadProductData() {
    http
        .get(Uri.parse("${MyConfig.servername}/MyMemberLink/load_products.php?pageno=$currentPage"))
        .then((response) {
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['status'] == "success") {
          var result = data['data']['products'];
          setState(() {
            products.clear();
            for (var product in result) {
              product['product_id'] = int.tryParse(product['product_id'].toString()) ?? 0;
              product['product_price'] = double.tryParse(product['product_price'].toString()) ?? 0.0;
              product['quantity'] = int.tryParse(product['quantity'].toString()) ?? 0;
            }
            products.addAll(result);
            numOfPages = data['numofpage'];
          });
        } else {
          setState(() {
            products = [];
          });
        }
      } else {
        setState(() {
          products = [];
        });
      }
    }).catchError((e) {
      setState(() {
        products = [];
      });
      print(e);
    });
  }

  void addToCart(int productId, int quantity) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? adminId = prefs.getString("admin_id");
      String? adminEmail = prefs.getString("admin_email");

      if (adminId == null || adminEmail == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User details not found. Please log in again.")),
        );
        return;
      }

      final response = await http.post(
        Uri.parse("${MyConfig.servername}/MyMemberLink/add_to_cart.php"),
        body: {
          'product_id': productId.toString(),
          'quantity': quantity.toString(),
          'admin_id': adminId,
          'admin_email': adminEmail,
        },
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? "Product added to cart!")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to add to cart")),
        );
      }
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error adding to cart")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Membership Products"),
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CartScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: products.isEmpty
                ? Center(child: Text("No Products Available"))
                : GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, index) {

                      return Card(
                        child: InkWell(
                          onTap: () {
                            showProductDetails(index);
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: CachedNetworkImage(
                                  imageUrl: "https://drive.google.com/uc?export=view&id=${products[index]['product_image']}",  // Image URL from database
                                  placeholder: (context, url) => CircularProgressIndicator(),
                                  errorWidget: (context, url, error) => Icon(Icons.error),
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  products[index]['product_name'],
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Text("Price: \RM${products[index]['product_price']}",
                                    style: TextStyle(color: Colors.green)),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Text("Page $currentPage of $numOfPages"),
          SizedBox(
            height: screenHeight * 0.05,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: numOfPages,
              itemBuilder: (context, index) {
                return TextButton(
                  onPressed: () {
                    setState(() {
                      currentPage = index + 1;
                    });
                    loadProductData();
                  },
                  child: Text(
                    (index + 1).toString(),
                    style: TextStyle(
                      color: currentPage == (index + 1) ? Colors.red : Colors.black,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      drawer: const MyDrawer(),
    );
  }

  void showProductDetails(int index) {
    TextEditingController quantityController = TextEditingController();
    quantityController.text = "1";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {

        String imagePath = "https://drive.google.com/uc?export=view&id=${products[index]['product_image']}"; 
        // The value in product_image should just be the Google Drive file ID.

        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 16.0,
            left: 16.0,
            right: 16.0,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(products[index]['product_name'],
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                CachedNetworkImage(
                  imageUrl: imagePath,  // Use CachedNetworkImage for product details
                  placeholder: (context, url) => CircularProgressIndicator(),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
                SizedBox(height: 10),
                Text(products[index]['product_description']),
                SizedBox(height: 10),
                Text("Price: \RM${products[index]['product_price']}",
                    style: TextStyle(color: Colors.green, fontSize: 16)),
                Text("Available Quantity: ${products[index]['quantity']}",
                    style: TextStyle(fontSize: 14)),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Text(
                      "Enter Quantity:",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 1,
                              blurRadius: 3,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: quantityController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            hintText: "Enter quantity",
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 10.0),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text("Close"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        int? quantity = int.tryParse(quantityController.text);

                        if (quantity != null && quantity > 0 && quantity <= products[index]['quantity']) {
                          addToCart(products[index]['product_id'], quantity);
                          Navigator.pop(context);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Please enter a valid quantity")),
                          );
                        }
                      },
                      child: const Text("Add to Cart"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}









