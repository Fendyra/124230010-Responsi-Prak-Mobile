import 'package:flutter/material.dart';
import 'package:responsi_prak_mobile/models/product_model.dart';
// import 'package:responsi_prak_mobile/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DetailPage extends StatefulWidget {
  final Product product;

  const DetailPage({super.key, required this.product});

  @override
  State<DetailPage> createState() => _DetailPageState();
}
class _DetailPageState extends State<DetailPage> {
  late SharedPreferences _prefs;
  bool _isInCart = false;
  
  TextStyle? get textStyleBody => null;
  
  get textStyleHeading => null;
  
  get textStyleSubHeading => null;

  @override
  void initState() {
    super.initState();
    _loadCartStatus();
  }

  Future<void> _loadCartStatus() async {
    _prefs = await SharedPreferences.getInstance();
    final List<String>? cartItems = _prefs.getStringList('cart_items');

    setState(() {
      _isInCart = cartItems?.contains(widget.product.id.toString()) ?? false;
    });
  }
  Future<void> _toggleCartStatus() async {
    final List<String> cartItems = _prefs.getStringList('cart_items') ?? [];

    setState(() {
      if (_isInCart) {
        cartItems.remove(widget.product.id.toString());
        _isInCart = false;
      } else {
        cartItems.add(widget.product.id.toString());
        _isInCart = true;
      }
      _prefs.setStringList('cart_items', cartItems);
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.network(
                widget.product.image,
                height: 200,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.product.title,
              style: textStyleHeading.copyWith(fontSize: 22),
            ),
            const SizedBox(height: 8),
            Text(
              '\$${widget.product.price.toStringAsFixed(2)}',
              style: textStyleSubHeading.copyWith(fontSize: 18, color: Colors.green),
            ),
            const SizedBox(height: 16),
            Text(
              widget.product.description,
              style: textStyleBody,
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _toggleCartStatus,
                style: ElevatedButton.styleFrom(      
                  backgroundColor: _isInCart ? Colors.red : Colors.blue,
                ),
                child: Text(
                  _isInCart ? 'Remove from Cart' : 'Add to Cart',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}