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
        final inventoryData = response['items'] ?? [];
        setState(() {
          _inventoryItems = inventoryData.map<Map<String, dynamic>>((item) {
            // Handle the API response structure from your example
            final inventory = item['inventory'] ?? {};
            return {
              'id': item['id'],
              'name': item['name'] ?? '',
              'sku': item['sku'] ?? '',
              'category': item['category']?['name'] ?? '',
              'available_stock': double.parse(inventory['available_stock']?.toString() ?? '0'),
              'min_alert_level': double.parse(inventory['min_alert_level']?.toString() ?? '0'),
              'total_stock': double.parse(inventory['total_stock']?.toString() ?? '0'),
              'reserved_stock': double.parse(inventory['reserved_stock']?.toString() ?? '0'),
              'uom': item['uom'] ?? '',
              'price': item['price'] ?? '',
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
      item['available_stock'] <= item['min_alert_level']
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
          final name = item['name'].toString().toLowerCase();
          final sku = item['sku'].toString().toLowerCase();
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
        child: Column(
          children: [
            _buildStatsCard(),
            _buildSearchSection(),
            Expanded(
              child: _buildInventoryTable(),
            ),
          ],
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
                    backgroundColor: Colors.orange[50],
                    foregroundColor: Colors.orange[600],
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
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
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
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search by product name or SKU...',
          hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
          prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        onChanged: (value) => _filterInventory(),
      ),
    );
  }

  Widget _buildInventoryTable() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_filteredItems.isEmpty) {
      return Center(
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
      );
    }

    return Container(
      margin: const EdgeInsets.all(16),
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
          Container(
            padding: const EdgeInsets.all(16),
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
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                child: DataTable(
                  columnSpacing: 20,
                  headingRowColor: WidgetStateProperty.all(Colors.grey[50]),
                  columns: const [
                    DataColumn(
                      label: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Product Details',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Min Level',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Available Stock',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Status',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                  rows: _filteredItems.map((item) {
                    final availableStock = item['available_stock'];
                    final minLevel = item['min_alert_level'];
                    final isLowStock = availableStock <= minLevel;
                    
                    return DataRow(
                      cells: [
                        DataCell(
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                item['name'],
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                'SKU: ${item['sku']}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        DataCell(
                          Text(
                            '${minLevel.toStringAsFixed(0)} ${item['uom']}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                        DataCell(
                          Text(
                            '${availableStock.toStringAsFixed(0)} ${item['uom']}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isLowStock ? Colors.red : Colors.green,
                            ),
                          ),
                        ),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isLowStock 
                                  ? Colors.red.withOpacity(0.1)
                                  : Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              isLowStock ? 'LOW STOCK' : 'IN STOCK',
                              style: TextStyle(
                                color: isLowStock ? Colors.red : Colors.green,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}