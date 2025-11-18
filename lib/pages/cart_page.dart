import 'package:flutter/material.dart';
import 'package:responsi_prak_mobile/models/product_model.dart';
import 'package:responsi_prak_mobile/pages/detail_page.dart';
import 'package:responsi_prak_mobile/services/api_service.dart';
import 'package:responsi_prak_mobile/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final ApiService _apiService = ApiService();
  List<Product> _cartProducts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCartItems();
  }

  Future<void> _loadCartItems() async {
    setState(() {
      _isLoading = true;
    });

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final cartIds = prefs.getStringList('cart_ids') ?? [];
    
    if (cartIds.isEmpty) {
      setState(() {
        _cartProducts = [];
        _isLoading = false;
      });
      return;
    }

    try {
      final allProducts = await _apiService.fetchTopProduct();
      
      final cartProducts = allProducts
          .where((product) => cartIds.contains(product.id.toString()))
          .toList();

      if (mounted) {
        setState(() {
          _cartProducts = cartProducts;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading cart: $e')),
        );
      }
    }
  }

  Future<void> _removeFromCart(String productId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> cartIds = prefs.getStringList('cart_ids') ?? [];
    cartIds.remove(productId);
    await prefs.setStringList('cart_ids', cartIds);
    
    _loadCartItems();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Removed from cart'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  double _calculateTotal() {
    return _cartProducts.fold(0, (sum, product) => sum + product.price);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart'),
        backgroundColor: Colors.transparent,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _cartProducts.isEmpty
              ? _buildEmptyCart()
              : _buildCartList(),
      bottomNavigationBar: _cartProducts.isNotEmpty
          ? _buildCheckoutButton()
          : null,
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 120,
            color: ChamberColor.grey.withOpacity(0.3),
          ),
          const SizedBox(height: 24),
          const Text(
            'Your cart is empty',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: ChamberColor.primary,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Add products to your cart from the store.',
            style: TextStyle(
              fontSize: 16,
              color: ChamberColor.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCartList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _cartProducts.length,
      itemBuilder: (context, index) {
        final product = _cartProducts[index];
        return _buildCartItem(product);
      },
    );
  }

  Widget _buildCartItem(Product product) {
    return Dismissible(
      key: Key(product.id.toString()),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        _removeFromCart(product.id.toString());
      },
      background: Container(
        margin: const EdgeInsets.only(bottom: 16.0),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(16.0),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
          size: 32,
        ),
      ),
      child: GestureDetector(
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailPage(product: product),
            ),
          );
          _loadCartItems();
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 16.0),
          decoration: BoxDecoration(
            color: ChamberColor.surface,
            borderRadius: BorderRadius.circular(16.0),
            boxShadow: [
              BoxShadow(
                color: Colors.blueGrey.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16.0),
                  bottomLeft: Radius.circular(16.0),
                ),
                child: Image.network(
                  product.image,
                  width: 100,
                  height: 140,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 100,
                      height: 140,
                      color: Colors.grey[200],
                      child: const Icon(Icons.broken_image, size: 40),
                    );
                  },
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: ChamberColor.primary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: ChamberColor.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          product.category,
                          style: const TextStyle(
                            fontSize: 12,
                            color: ChamberColor.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                color: Colors.amber,
                                size: 20,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                product.rating.toString(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: ChamberColor.primary,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '\$${product.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: ChamberColor.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(right: 12.0),
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: ChamberColor.grey,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCheckoutButton() {
    final total = _calculateTotal();
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total',
                      style: TextStyle(
                        fontSize: 14,
                        color: ChamberColor.grey,
                      ),
                    ),
                    Text(
                      '\$${total.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: ChamberColor.primary,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${_cartProducts.length} item${_cartProducts.length > 1 ? 's' : ''}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: ChamberColor.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: ChamberColor.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Checkout ${_cartProducts.length} item${_cartProducts.length > 1 ? 's' : ''} - \$${total.toStringAsFixed(2)}',
                    ),
                    backgroundColor: Colors.green,
                    duration: const Duration(seconds: 3),
                  ),
                );
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_bag, color: Colors.white),
                  SizedBox(width: 12),
                  Text(
                    'Proceed to Checkout',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
