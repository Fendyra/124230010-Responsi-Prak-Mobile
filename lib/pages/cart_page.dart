import 'package:flutter/material.dart';
// import 'package:responsi_prak_mobile/pages/detail_page.dart';
// import 'package:responsi_prak_mobile/services/api_service.dart';
// import 'package:responsi_prak_mobile/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}
class _CartPageState extends State<CartPage> {
  late SharedPreferences _prefs;
  bool _isLoading = true;
  List<String> _cartItems = [];

  @override
  void initState() {
    super.initState();
    _loadCartData();
  }

  Future<void> _loadCartData() async {
    setState(() => _isLoading = true);

    _prefs = await SharedPreferences.getInstance();
    final List<String>? cartItems = _prefs.getStringList('cart_items');

    setState(() {
      _cartItems = cartItems ?? [];
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart Page'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _cartItems.isEmpty
              ? const Center(child: Text('Your cart is empty.'))
              : ListView.builder(
                  itemCount: _cartItems.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(_cartItems[index]),
                    );
                  },
                ),
    );
  }
}

