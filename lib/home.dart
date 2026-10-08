import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const new({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int selectedIndex = 0; // 0 Home, 1 Cart, 2 Favorites, 3 Profile

  String userName = "User";
  String userEmail = "";

  String searchText = "";
  TextEditingController searchController = TextEditingController();

  // Products collection (Admin Dashboard isi mein add karta hai)
  final CollectionReference products = FirebaseFirestore.instance.collection(
    "products",
  );

  // Cart: har item = {id, name, price, qty}
  List<Map<String, dynamic>> cartItems = [];

  // Favorite products ke ids
  List<String> favorites = [];

  //==============cart function ================

  void addToCart(String id, String name, double price) {
    bool found = false;

    for (var item in cartItems) {
      if (item['id'] == id) {
        item['qty'] = item['qty'] + 1;
        found = true;
      }
    }

    if (!found) {
      cartItems.add({'id': id, 'name': name, 'price': price, 'qty': 1});
    }

    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("$name added to cart"),
        duration: const Duration(seconds: 2),
      ), // SnackBar
    );
  }

  void increaseQty(Map<String, dynamic> item) {
    setState(() {
      item['qty'] = item['qty'] + 1;
    });
  }

  void decreaseQty(Map<String, dynamic> item) {
    setState(() {
      if (item['qty'] > 1) {
        item['qty'] = item['qty'] - 1;
      } else {
        cartItems.remove(item);
      }
    });
  }

  int totalItems() {
    int total = 0;
    for (var item in cartItems) {
      total = total + (item['qty'] as int);
    }
    return total;
  }

  double totalPrice() {
    double total = 0;
    for (var item in cartItems) {
      total = total + (item['price'] * item['qty']);
    }
    return total;
  }

  //================ Favorite ================
  // ===================

  void toggleFavorite(String id) {
    setState(() {
      if (favorites.contains(id)) {
        favorites.remove(id);
      } else {
        favorites.add(id);
      }
    });
  }

  //================== Logout ==================

  void signOut() {
    Navigator.pushNamedAndRemoveUntil(context, '/mylogin', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
