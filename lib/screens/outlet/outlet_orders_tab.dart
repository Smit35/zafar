import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/order.dart';
import '../../services/api_service.dart';

class OutletOrdersTab extends StatefulWidget {
  const OutletOrdersTab({super.key});

  @override
  State<OutletOrdersTab> createState() => _OutletOrdersTabState();
}

class _OutletOrdersTabState extends State<OutletOrdersTab> {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();
  
  DateTime? _fromDate;
  DateTime? _toDate;
  List<Order> _orders = [];
  List<Order> _filteredOrders = [];
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _loadOrders();
    _searchController.addListener(_filterOrders);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      String? dateFrom = _fromDate?.toIso8601String().split('T')[0];
      String? dateTo = _toDate?.toIso8601String().split('T')[0];
      
      final result = await _apiService.getOutletOrders(
        dateFrom: dateFrom,
        dateTo: dateTo,
      );
      
      if (result['success'] == true) {
        setState(() {
          _orders = result['orders'] ?? [];
          _filteredOrders = _orders;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load orders: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterOrders() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredOrders = _orders.where((order) {
        return order.orderNumber.toLowerCase().contains(query);
      }).toList();
    });
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: _fromDate != null && _toDate != null
          ? DateTimeRange(start: _fromDate!, end: _toDate!)
          : null,
    );
    
    if (picked != null) {
      setState(() {
        _fromDate = picked.start;
        _toDate = picked.end;
      });
      _loadOrders();
    }
  }

  void _clearDateFilter() {
    setState(() {
      _fromDate = null;
      _toDate = null;
    });
    _loadOrders();
  }

  String _getStatusDisplayName(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'New';
      case 'accepted':
        return 'Preparing';
      case 'ready_for_dispatch':
        return 'Ready';
      case 'dispatched':
        return 'Dispatched';
      case 'delivered':
        return 'Delivered';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.blue;
      case 'accepted':
        return Colors.orange;
      case 'ready_for_dispatch':
        return Colors.green;
      case 'dispatched':
        return Colors.purple;
      case 'delivered':
        return Colors.grey;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // Order Stats Card
          _buildStatsCard(),
          // Search and Filter Section
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by order number...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.orange),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Date Filter
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _selectDateRange,
                        icon: const Icon(Icons.date_range),
                        label: Text(
                          _fromDate != null && _toDate != null
                              ? '${DateFormat('MMM dd').format(_fromDate!)} - ${DateFormat('MMM dd').format(_toDate!)}'
                              : 'Select Date Range',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange[600],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                    if (_fromDate != null || _toDate != null) ...[
                      const SizedBox(width: 12),
                      IconButton(
                        onPressed: _clearDateFilter,
                        icon: const Icon(Icons.clear),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.grey[100],
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          // Orders List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _loadOrders,
                    child: _filteredOrders.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.receipt_long_outlined,
                                  size: 64,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'No orders found',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _filteredOrders.length,
                            itemBuilder: (context, index) => _buildOrderCard(_filteredOrders[index]),
                          ),
                  ),
          ),
        ],
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
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem('31', 'Total', Colors.blue),
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.grey[300],
          ),
          Expanded(
            child: _buildStatItem('5', 'Placed', Colors.orange),
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.grey[300],
          ),
          Expanded(
            child: _buildStatItem('2', 'Transit', Colors.green),
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.grey[300],
          ),
          Expanded(
            child: _buildStatItem('24', 'Delivered', Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String count, String label, Color color) {
    return Column(
      children: [
        Text(
          count,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildOrderCard(Order order) {
    final statusColor = _getStatusColor(order.status);
    final statusName = _getStatusDisplayName(order.status);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Order Number and Status Badge
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        order.orderNumber,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        statusName,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Main Details Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left Column - Order Date and SKU
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Order Date
                          Text(
                            'Order Date',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            DateFormat('MMM dd, yyyy • HH:mm').format(order.createdAt),
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black87,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          
                          const SizedBox(height: 12),
                          
                          // SKU
                          Text(
                            'Items',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'SKU-${order.id}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black87,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(width: 16),
                    
                    // Right Column - Total Amount and Dispatch Date
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // Total Amount
                          Text(
                            'Total Amount',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '₹${order.grandTotal.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          
                          if (order.dispatchDate != null) ...[
                            const SizedBox(height: 12),
                            
                            // Dispatch Date
                            Text(
                              'Dispatch Date',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              DateFormat('MMM dd, HH:mm').format(order.dispatchDate!),
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black87,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                
                // Delivery OTP (if available)
                if (order.deliveryOtp != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.security,
                          color: Colors.orange[700],
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Delivery OTP: ',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.orange[700],
                          ),
                        ),
                        Text(
                          order.deliveryOtp!,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange[700],
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          // Invoice Button
          Container(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Invoice functionality will be implemented soon'),
                    ),
                  );
                },
                icon: const Icon(Icons.receipt_outlined),
                label: const Text('View Invoice'),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.grey[400]!),
                  foregroundColor: Colors.grey[700],
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderDetailItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}