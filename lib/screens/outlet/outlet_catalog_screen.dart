import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../models/inventory_item.dart';

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

  @override
  void initState() {
    super.initState();
    _loadInventory();
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
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // Search and Filter Section
          _buildSearchSection(),
          
          // Category Tabs
          _buildCategoryTabs(),
          
          // Items List
          Expanded(
            child: _buildItemsList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddItemDialog();
        },
        backgroundColor: Colors.orange[600],
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildSearchSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Expanded(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search by name or SKU...',
              hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
              prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
            onChanged: (value) {
              _filterItems();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return Container(
      height: 50,
      color: Colors.white,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
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
              margin: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.orange[600] : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? Colors.orange[600]! : Colors.grey[300]!,
                ),
              ),
              child: Text(
                category,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey[600],
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 14,
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
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Error Loading Items',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadInventory,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange[600],
              ),
              child: const Text(
                'Retry',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );
    }

    if (_filteredItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No Items Found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search or filters',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadInventory,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _filteredItems.length,
        itemBuilder: (context, index) => _buildMenuItem(_filteredItems[index]),
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

  Widget _buildMenuItem(InventoryItem item) {
    final currentQuantity = _quantities[item.id] ?? 0;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Item Image
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(12),
                image: item.imagePath != null
                    ? DecorationImage(
                        image: NetworkImage(item.imageUrl),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: item.imagePath == null
                  ? Icon(
                      Icons.fastfood,
                      color: Colors.orange[600],
                      size: 30,
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            
            // Item Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name and SKU
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        'SKU: ${item.sku}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // Price with unit and stock info
                  Row(
                    children: [
                      Text(
                        '₹${item.priceValue.toStringAsFixed(2)} /unit',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: item.isInStock 
                              ? Colors.green.withOpacity(0.1)
                              : Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Stock: ${item.availableStock.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 10,
                            color: item.isInStock ? Colors.green : Colors.red,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // Quantity Controls
                  Row(
                    children: [
                      // Quantity controls
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                              onTap: currentQuantity > 0 
                                  ? () => _updateQuantity(item.id, -1)
                                  : null,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                child: Icon(
                                  Icons.remove,
                                  size: 16,
                                  color: currentQuantity > 0 
                                      ? Colors.orange[600] 
                                      : Colors.grey[400],
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              child: Text(
                                currentQuantity.toString(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: item.isInStock 
                                  ? () => _updateQuantity(item.id, 1)
                                  : null,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                child: Icon(
                                  Icons.add,
                                  size: 16,
                                  color: item.isInStock 
                                      ? Colors.orange[600] 
                                      : Colors.grey[400],
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
              backgroundColor: Colors.orange[600],
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
              backgroundColor: Colors.orange[600],
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