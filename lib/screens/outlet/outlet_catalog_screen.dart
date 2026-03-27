import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../models/inventory_item.dart';
import '../../models/cart_models.dart';
import 'outlet_cart_screen.dart';

class OutletCatalogScreen extends StatefulWidget {
  const OutletCatalogScreen({super.key});

  @override
  State<OutletCatalogScreen> createState() => _OutletCatalogScreenState();
}

class _OutletCatalogScreenState extends State<OutletCatalogScreen> {
  String _selectedCategory = 'All Items';
  final TextEditingController _searchController = TextEditingController();
  final ApiService _apiService = ApiService();

  List<InventoryItem> _allItems = [];
  List<InventoryItem> _filteredItems = [];
  List<String> _categories = ['All Items'];
  bool _isLoading = true;
  String? _errorMessage;
  Map<int, int> _quantities = {};
  List<CartItem> _cartItems = [];
  bool _loadingCart = false;

  @override
  void initState() {
    super.initState();
    _loadInventory();
    _loadCartItems();
  }

  Future<void> _loadInventory() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _apiService.getOutletInventory();
      
      if (result['success']) {
        final items = result['items'] as List<InventoryItem>;
        final uniqueCategories = <String>{'All Items'};
        
        for (var item in items) {
          uniqueCategories.add(item.category.name);
        }
        
        setState(() {
          _allItems = items;
          _categories = uniqueCategories.toList();
          _filteredItems = items;
          _isLoading = false;
        });
        
        _filterItems();
      } else {
        setState(() {
          _errorMessage = result['message'];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load inventory: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadCartItems() async {
    setState(() {
      _loadingCart = true;
    });

    try {
      final result = await _apiService.getCartItems();
      
      if (result['success']) {
        setState(() {
          _cartItems = result['items'] as List<CartItem>;
          _loadingCart = false;
        });
      } else {
        setState(() {
          _cartItems = [];
          _loadingCart = false;
        });
      }
    } catch (e) {
      setState(() {
        _cartItems = [];
        _loadingCart = false;
      });
    }
  }

  void _filterItems() {
    List<InventoryItem> filtered = _allItems;
    
    // Filter by category
    if (_selectedCategory != 'All Items') {
      filtered = filtered.where((item) => item.category.name == _selectedCategory).toList();
    }
    
    // Filter by search text
    final searchQuery = _searchController.text.toLowerCase();
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((item) {
        return item.name.toLowerCase().contains(searchQuery) ||
               item.sku.toLowerCase().contains(searchQuery);
      }).toList();
    }
    
    setState(() {
      _filteredItems = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    final totalItems = _quantities.values.fold(0, (sum, qty) => sum + qty);
    final cartHasItems = _cartItems.isNotEmpty;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          // Search Section
          SliverToBoxAdapter(
            child: _buildSearchSection(),
          ),
          
          // Category Tabs
          SliverToBoxAdapter(
            child: _buildCategoryTabs(),
          ),
          
          // Items List
          _buildItemsList(),
        ],
      ),
      // Floating checkout button when items are selected or cart has items
      floatingActionButton: (totalItems > 0 || cartHasItems)
          ? Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: FloatingActionButton.extended(
                onPressed: totalItems > 0 ? _proceedToCheckout : _goToCart,
                backgroundColor: Colors.blueGrey[600],
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                label: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      totalItems > 0
                          ? '$totalItems ${totalItems == 1 ? 'item' : 'items'} added'
                          : 'Cart: ${_cartItems.fold(0, (sum, item) => sum + item.quantity.toInt())} items',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          totalItems > 0 ? 'Proceed to checkout' : 'Go to Checkout',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                          size: 20,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildSearchSection() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      color: Colors.white,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFE5E7EB),
            width: 1,
          ),
        ),
        child: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Search products by name or SKU...',
            hintStyle: TextStyle(
              color: Color(0xFF9CA3AF),
              fontSize: 15,
              fontWeight: FontWeight.w400,
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: Color(0xFF6B7280),
              size: 20,
            ),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          style: const TextStyle(
            fontSize: 15,
            color: Color(0xFF111827),
            fontWeight: FontWeight.w500,
          ),
          onChanged: (value) {
            _filterItems();
          },
        ),
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return Container(
      height: 72,
      color: Colors.white,
      padding: const EdgeInsets.only(bottom: 16, top: 4),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategory == category;
          
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategory = category;
              });
              _filterItems();
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              constraints: const BoxConstraints(minHeight: 48),
              decoration: BoxDecoration(
                color: isSelected 
                    ? const Color(0xFF4F46E5) 
                    : const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected 
                      ? const Color(0xFF4F46E5) 
                      : const Color(0xFFE5E7EB),
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  category,
                  style: TextStyle(
                    color: isSelected 
                        ? Colors.white 
                        : const Color(0xFF374151),
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildItemsList() {
    if (_isLoading) {
      return const SliverFillRemaining(
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4F46E5)),
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Color(0xFF9CA3AF),
              ),
              const SizedBox(height: 16),
              const Text(
                'Error Loading Items',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF374151),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadInventory,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_filteredItems.isEmpty) {
      return const SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inventory_2_outlined,
                size: 64,
                color: Color(0xFF9CA3AF),
              ),
              SizedBox(height: 16),
              Text(
                'No Items Found',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF374151),
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Try adjusting your search or filters',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => _buildMenuItem(_filteredItems[index]),
          childCount: _filteredItems.length,
        ),
      ),
    );
  }

  void _updateQuantity(int itemId, int change) {
    setState(() {
      final currentQty = _quantities[itemId] ?? 0;
      final newQty = (currentQty + change).clamp(0, double.infinity).toInt();
      if (newQty == 0) {
        _quantities.remove(itemId);
      } else {
        _quantities[itemId] = newQty;
      }
    });
  }

  Future<void> _proceedToCheckout() async {
    // Add all items to cart via API
    bool hasError = false;
    
    for (final entry in _quantities.entries) {
      final productId = entry.key;
      final quantity = entry.value;
      
      final request = AddToCartRequest(
        productId: productId,
        quantity: quantity,
      );
      
      final result = await _apiService.addToCart(request);
      if (!result['success']) {
        hasError = true;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add item to cart: ${result['message']}'),
            backgroundColor: Colors.red,
          ),
        );
        break;
      }
    }
    
    if (!hasError) {
      // Clear local quantities since items are now in cart
      setState(() {
        _quantities.clear();
      });
      
      // Refresh cart data
      await _loadCartItems();
      
      // Navigate to cart screen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const OutletCartScreen()),
      ).then((_) {
        // Refresh cart when returning from cart screen
        _loadCartItems();
      });
    }
  }
  
  Future<void> _goToCart() async {
    // Navigate directly to cart screen
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const OutletCartScreen()),
    ).then((_) {
      // Refresh cart when returning from cart screen
      _loadCartItems();
    });
  }

  Widget _buildMenuItem(InventoryItem item) {
    final currentQuantity = _quantities[item.id] ?? 0;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Top Row - Image, Details, and Price
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFFE5E7EB),
                      width: 1,
                    ),
                    image: item.imagePath != null && item.imagePath!.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(item.imageUrl),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: item.imagePath == null || item.imagePath!.isEmpty
                      ? const Icon(
                          Icons.inventory_2_outlined,
                          color: Color(0xFF9CA3AF),
                          size: 28,
                        )
                      : null,
                ),
                
                const SizedBox(width: 12),
                
                // Product Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF111827),
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'SKU: ${item.sku}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          // Stock Status Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: item.isInStock 
                                    ? const Color(0xFF10B981)
                                    : const Color(0xFFEF4444),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              item.isInStock 
                                  ? 'In Stock (${item.availableStock.toStringAsFixed(0)})'
                                  : 'Out of Stock',
                              style: TextStyle(
                                fontSize: 10,
                                color: item.isInStock 
                                    ? const Color(0xFF10B981)
                                    : const Color(0xFFEF4444),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // Price
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          const TextSpan(
                            text: '₹',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF059669),
                            ),
                          ),
                          TextSpan(
                            text: item.priceValue.toStringAsFixed(2),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF059669),
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'per ${item.uom}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF6B7280),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Bottom Row - Quantity Controls
            Row(
              children: [
                const Expanded(child: SizedBox()), // Spacer
                
                // Quantity Controls
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFFD1D5DB),
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Decrease Button
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: currentQuantity > 0 
                              ? () => _updateQuantity(item.id, -1)
                              : null,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(9),
                            bottomLeft: Radius.circular(9),
                          ),
                          child: Container(
                            width: 38,
                            height: 38,
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.remove,
                              size: 16,
                              color: currentQuantity > 0 
                                  ? const Color(0xFF4F46E5) 
                                  : const Color(0xFFD1D5DB),
                            ),
                          ),
                        ),
                      ),
                      
                      // Quantity Display
                      Container(
                        width: 44,
                        height: 38,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          border: Border.symmetric(
                            vertical: BorderSide(
                              color: Color(0xFFD1D5DB),
                              width: 1,
                            ),
                          ),
                        ),
                        child: Text(
                          currentQuantity.toString(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF111827),
                          ),
                        ),
                      ),
                      
                      // Increase Button
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: item.isInStock 
                              ? () => _updateQuantity(item.id, 1)
                              : null,
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(9),
                            bottomRight: Radius.circular(9),
                          ),
                          child: Container(
                            width: 38,
                            height: 38,
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.add,
                              size: 16,
                              color: item.isInStock 
                                  ? const Color(0xFF4F46E5) 
                                  : const Color(0xFFD1D5DB),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddItemDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Item'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Item Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Price',
                border: OutlineInputBorder(),
                prefixText: '₹',
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Add item logic
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueGrey[600],
            ),
            child: const Text('Add Item', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showEditItemDialog(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Item'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Item Name',
                border: OutlineInputBorder(),
              ),
              controller: TextEditingController(text: item['name'] as String),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              controller: TextEditingController(text: item['description'] as String),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Price',
                border: OutlineInputBorder(),
                prefixText: '₹',
              ),
              controller: TextEditingController(text: item['price'].toString()),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Update item logic
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueGrey[600],
            ),
            child: const Text('Update', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item'),
        content: Text('Are you sure you want to delete "${item['name']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Delete item logic
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}