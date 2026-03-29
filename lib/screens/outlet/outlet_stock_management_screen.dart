import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class OutletStockManagementScreen extends StatefulWidget {
  const OutletStockManagementScreen({super.key});

  @override
  State<OutletStockManagementScreen> createState() => _OutletStockManagementScreenState();
}

class _OutletStockManagementScreenState extends State<OutletStockManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ApiService _apiService = ApiService();
  
  List<Map<String, dynamic>> _inventoryItems = [];
  List<Map<String, dynamic>> _filteredItems = [];
  bool _isLoading = true;
  bool _isRefreshing = false;
  
  // Static values for now
  int _totalTrackedProducts = 0;
  int _lowStockAlerts = 0;

  @override
  void initState() {
    super.initState();
    _loadInventory();
  }

  Future<void> _loadInventory() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _apiService.getOutletInventory();
      
      if (response['success']) {
        final inventoryItems = response['items'] ?? [];
        setState(() {
          _inventoryItems = inventoryItems.where((item) => item != null).map<Map<String, dynamic>>((item) {
            return {
              'id': item.id,
              'product_name': item.name ?? 'Unknown Product',
              'product_sku': item.sku ?? '',
              'product_image': item.imagePath ?? '',
              'category_name': item.category?.name ?? 'Unknown Category',
              'available_stock': item.stockSummary?.availableStock?.toDouble() ?? 0.0,
              'min_alert_level': double.tryParse(item.minAlertLevel.toString()) ?? 0.0,
              'is_low_stock': item.stockSummary?.isLowStock ?? false,
              'base_unit_name': item.uom ?? 'PCS',
              'base_unit_abbreviation': item.uom ?? 'PCS',
              'product_price': item.price ?? '0',
            };
          }).toList();
          
          _filteredItems = _inventoryItems;
          _calculateStats();
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response['message'] ?? 'Failed to load inventory')),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading inventory: $e')),
        );
      }
    }
  }

  void _calculateStats() {
    _totalTrackedProducts = _inventoryItems.length;
    _lowStockAlerts = _inventoryItems.where((item) => 
      item['is_low_stock'] == true
    ).length;
  }

  Future<void> _refreshInventory() async {
    setState(() {
      _isRefreshing = true;
    });
    
    await _loadInventory();
    
    setState(() {
      _isRefreshing = false;
    });
  }

  void _filterInventory() {
    final query = _searchController.text.toLowerCase().trim();
    
    if (query.isEmpty) {
      setState(() {
        _filteredItems = _inventoryItems;
      });
    } else {
      setState(() {
        _filteredItems = _inventoryItems.where((item) {
          final name = item['product_name'].toString().toLowerCase();
          final sku = item['product_sku'].toString().toLowerCase();
          return name.contains(query) || sku.contains(query);
        }).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: RefreshIndicator(
        onRefresh: _refreshInventory,
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildStatsCard(),
              _buildSearchSection(),
              _buildInventoryList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
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
      child: Column(
        children: [
          Row(
            children: [
              const Text(
                'Stock Overview',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              if (_isRefreshing)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                IconButton(
                  onPressed: _refreshInventory,
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.blueGrey[50],
                    foregroundColor: Colors.blueGrey[600],
                    padding: const EdgeInsets.all(8),
                  ),
                  icon: const Icon(Icons.refresh, size: 20),
                  tooltip: 'Refresh Stock Data',
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildOverviewCard(
                  'Total Products',
                  _totalTrackedProducts.toString(),
                  Colors.blue,
                  Icons.inventory_2,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildOverviewCard(
                  'Low Stock Alerts',
                  _lowStockAlerts.toString(),
                  _lowStockAlerts > 0 ? Colors.red : Colors.green,
                  Icons.warning,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewCard(String title, String count, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Icon(icon, color: color, size: 32),
          // const SizedBox(height: 8),
          Text(
            count,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSection() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      color: Colors.white,
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: const Color(0xFFE5E7EB),
            width: 1,
          ),
        ),
        child: TextField(
          controller: _searchController,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF111827),
          ),
          decoration: const InputDecoration(
            hintText: 'Search by product name or SKU...',
            hintStyle: TextStyle(
              color: Color(0xFF9CA3AF),
              fontSize: 14,
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: Color(0xFF6B7280),
              size: 18,
            ),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
          onChanged: (value) => _filterInventory(),
        ),
      ),
    );
  }

  Widget _buildInventoryList() {
    if (_isLoading) {
      return Container(
        height: 200,
        margin: const EdgeInsets.all(16),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_filteredItems.isEmpty) {
      return Container(
        height: 200,
        margin: const EdgeInsets.all(16),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _searchController.text.isNotEmpty 
                    ? Icons.search_off 
                    : Icons.inventory_2_outlined,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                _searchController.text.isNotEmpty 
                    ? 'No products found'
                    : 'No inventory items',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              if (_searchController.text.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'Try searching with a different term',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                const Text(
                  'Inventory Details',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '${_filteredItems.length} products',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          ..._filteredItems.map((item) => _buildInventoryCard(item)).toList(),
        ],
      ),
    );
  }

  Widget _buildInventoryCard(Map<String, dynamic> item) {
    final isLowStock = item['is_low_stock'] as bool;
    final availableStock = item['available_stock'];
    final minAlertLevel = item['min_alert_level'];
    final baseUnitAbbr = item['base_unit_abbreviation'];
    
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
        child: Row(
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
                image: item['product_image'] != null && item['product_image'].isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(
                          '${ApiService.baseUrl}/storage/${item['product_image']}',
                        ),
                        fit: BoxFit.cover,
                        onError: (error, stackTrace) {
                          // Handle image loading error
                        },
                      )
                    : null,
              ),
              child: item['product_image'] == null || item['product_image'].isEmpty
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
                    item['product_name'],
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
                    'SKU: ${item['product_sku']}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Category: ${item['category_name']}',
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
                            color: isLowStock 
                                ? const Color(0xFFEF4444)
                                : const Color(0xFF10B981),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          isLowStock 
                              ? 'Low Stock (${availableStock.toStringAsFixed(0)})'
                              : 'In Stock (${availableStock.toStringAsFixed(0)})',
                          style: TextStyle(
                            fontSize: 10,
                            color: isLowStock 
                                ? const Color(0xFFEF4444)
                                : const Color(0xFF10B981),
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
            
            // Price and Min Level
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
                          color: Color(0xFF111827),
                        ),
                      ),
                      TextSpan(
                        text: item['product_price'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111827),
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                // const SizedBox(height: 4),
                // Text(
                //   'Min: ${minAlertLevel.toStringAsFixed(0)} $baseUnitAbbr',
                //   style: const TextStyle(
                //     fontSize: 11,
                //     color: Color(0xFF6B7280),
                //     fontWeight: FontWeight.w500,
                //   ),
                // ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}