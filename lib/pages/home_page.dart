import 'package:flutter/material.dart';
import 'package:responsi_prak_mobile/models/product_model.dart';
import 'package:responsi_prak_mobile/pages/detail_page.dart';
import 'package:responsi_prak_mobile/pages/login_page.dart';
import 'package:responsi_prak_mobile/services/api_service.dart';
import 'package:responsi_prak_mobile/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ApiService apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();
  
  List<Product> _productList = []; 
  List<Product> _spotlightProduct = [];
  List<Product> _favoriteProductList = []; 
  List<String> _favoriteIds = []; 
  bool _isLoading = true;
  String? _errorMessage;

  late PageController _pageController;
  String? _selectedType = 'All';
  final List<String> _productCategory = ['All', 'Men Clothing ', 'Jewelery', 'Electronics', 'Women Clothings'];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.85);
    _loadFavoritesAndFetchProducts(); 
    _fetchTopProduct();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFavoritesAndFetchProducts() async {
    await _loadFavoriteIds();
  }

  Future<void> _loadFavoriteIds() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> favoriteIds = prefs.getStringList('favorite_ids') ?? [];
    setState(() {
      _favoriteIds = favoriteIds;
    });
  }

  Future<void> _refreshFavorites() async {
    await _loadFavoriteIds(); 
    setState(() {
      _favoriteProductList = _productList
          .where((product) => _favoriteIds.contains(product.id.toString()))
          .toList();
    });
  }

  Future<void> _fetchTopProduct() async {
    setState(() {
      _isLoading = true;
      _isSearching = false;
      _errorMessage = null;
    });

    try {
      final productList = await apiService.fetchTopProduct(
        type: _selectedType == 'All' ? null : _selectedType?.toLowerCase(),
      );
      setState(() {
        _productList = productList; 

        _favoriteProductList = _productList
            .where((product) => _favoriteIds.contains(product.id.toString()))
            .toList();

        if (_selectedType == 'All') {
          _spotlightProduct = _productList.take(5).toList();
        } else {
          _spotlightProduct = [];
        }

        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _searchProduct(String query) async {
    if (query.isEmpty) {
      _fetchTopProduct();
      return;
    }

    setState(() {
      _isLoading = true;
      _isSearching = true;
      _errorMessage = null;
    });

    try {
      final productList = await apiService.searchProducts(query);
      setState(() {
        _productList = productList;
        _spotlightProduct = [];
        _favoriteProductList = []; 
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('username');

    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chamber'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => _logout(context),
          ),
        ],
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            _buildSearchBar(),
            if (!_isSearching) _buildCategoryFilters(),
            
          
            _buildWatchListSection(),

            if (_spotlightProduct.isNotEmpty && !_isSearching) ...[
              _buildSectionTitle("Product Spotlight"),
              _buildProductCarousel(_spotlightProduct),
            ],
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Text(
                _isSearching
                    ? 'Search Results'
                    : 'Top Product${_selectedType != 'All' ? ' - $_selectedType' : ''}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: ChamberColor.primary,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: _isLoading
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : _errorMessage != null
                      ? Center(child: Text('Error: $_errorMessage'))
                      : _productList.isEmpty
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.all(32.0),
                                child: Text('No product found.'),
                              ),
                            )
                          : _buildProductGrid(_productList),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWatchListSection() {
    if (_isLoading || _favoriteProductList.isEmpty || _isSearching) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Favorite Product"), 
        SizedBox(
          height: 180, 
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _favoriteProductList.length,
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            itemBuilder: (context, index) {
              final product = _favoriteProductList[index];
              return _buildFavoriteCard(product);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFavoriteCard(Product product) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DetailPage(product: product)),
        ).then((_) => _refreshFavorites()); 
      },
      child: Container(
        width: 120, 
        margin: const EdgeInsets.only(right: 12.0),
        child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(12.0)),
          child: Image.network(
            product.image,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => const Center(
              child: Icon(Icons.broken_image, color: ChamberColor.grey),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(24, 8, 24, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Discover",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: ChamberColor.primary,
                ),
              ),
              Text(
                "Find your next favorite product",
                style: TextStyle(
                  fontSize: 16,
                  color: ChamberColor.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: ChamberColor.primary,
        ),
      ),
    );
  }

  Widget _buildProductCarousel(List<Product> productList) {
    return SizedBox(
      height: 200,
      child: PageView.builder(
        controller: _pageController,
        itemCount: productList.length,
        itemBuilder: (context, index) {
          final product = productList[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailPage(product: product),
                ),
              ).then((_) => _refreshFavorites()); 
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8.0),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(24.0)),
                image: DecorationImage(
                  image: NetworkImage(product.image),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.4),
                    BlendMode.darken,
                  ),
                ),
              ),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    product.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: "Search product...",
          prefixIcon: const Icon(Icons.search, color: ChamberColor.grey),
          suffixIcon: _isSearching || _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _searchProduct('');
                  },
                )
              : null,
          fillColor: ChamberColor.surface,
          filled: true,
          enabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(16.0)),
            borderSide: BorderSide.none,
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(16.0)),
            borderSide: BorderSide(color: ChamberColor.primary, width: 2.0),
          ),
        ),
        onSubmitted: (value) {
          if (value.isNotEmpty) {
            _searchProduct(value);
          }
        },
      ),
    );
  }

  Widget _buildCategoryFilters() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 4.0),
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _productCategory.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final type = _productCategory[index];
          final isSelected = _selectedType == type;
          return ChoiceChip(
            label: Text(type),
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : ChamberColor.primary,
              fontWeight: FontWeight.w600,
            ),
            selected: isSelected,
            selectedColor: ChamberColor.primary,
            backgroundColor: ChamberColor.surface,
            shape: RoundedRectangleBorder(
              borderRadius: const BorderRadius.all(Radius.circular(20)),
              side: BorderSide(
                color:
                    isSelected ? ChamberColor.primary : ChamberColor.grey.withOpacity(0.5),
              ),
            ),
            onSelected: (selected) {
              if (selected) {
                setState(() {
                  _selectedType = type;
                });
                _fetchTopProduct();
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildProductGrid(List<Product> productList) {
    return GridView.builder(
      padding: const EdgeInsets.only(bottom: 20.0),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: productList.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemBuilder: (context, index) {
        final product = productList[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailPage(product: product),
              ),
            ).then((_) => _refreshFavorites()); 
          },
          child: Container(
            decoration: BoxDecoration(
              color: ChamberColor.surface,
              borderRadius: const BorderRadius.all(Radius.circular(16.0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.blueGrey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16.0),
                      topRight: Radius.circular(16.0),
                    ),
                    child: Image.network(
                      product.image,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Center(child: Icon(Icons.broken_image)),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    product.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: ChamberColor.primary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  child: Row(
                    children: [
                      const Icon(Icons.star_rounded,
                          color: ChamberColor.accent, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        product.price.toString(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: ChamberColor.primary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}