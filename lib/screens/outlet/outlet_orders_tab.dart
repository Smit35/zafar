import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/order.dart';
import '../../services/api_service.dart';
import 'invoice_screen.dart';

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
  Map<String, dynamic>? _dashboardStats;
  
  @override
  void initState() {
    super.initState();
    _loadDashboardStats();
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
      // Load dashboard stats and orders in parallel
      final futures = <Future>[
        _loadDashboardStats(),
      ];
      
      String? dateFrom = _fromDate?.toIso8601String().split('T')[0];
      String? dateTo = _toDate?.toIso8601String().split('T')[0];
      
      futures.add(_apiService.getOutletOrders(
        dateFrom: dateFrom,
        dateTo: dateTo,
      ));
      
      final results = await Future.wait(futures);
      final ordersResult = results[1] as Map<String, dynamic>;
      
      if (ordersResult['success'] == true) {
        setState(() {
          _orders = ordersResult['orders'] ?? [];
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

  Future<void> _loadDashboardStats() async {
    try {
      final response = await _apiService.getOutletDashboard();
      print("Orders tab dashboard response: $response");
      
      if (response['success'] && mounted) {
        setState(() {
          _dashboardStats = response['dashboard']?['data']?['statistics'];
        });
        print("Orders tab dashboard stats loaded: $_dashboardStats");
      }
    } catch (e) {
      print("Orders tab dashboard error: $e");
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
        return Colors.blue[600]!;
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
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          // Order Stats Card
          SliverToBoxAdapter(
            child: _buildStatsCard(),
          ),
          
          // Search and Filter Section
          SliverToBoxAdapter(
            child: _buildSearchAndFilter(),
          ),
          
          // Orders List
          _isLoading
              ? const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4F46E5)),
                  )),
                )
              : _filteredOrders.isEmpty
                  ? const SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.receipt_long_outlined,
                              size: 64,
                              color: Color(0xFF9CA3AF),
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No orders found',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => _buildOrderCard(_filteredOrders[index]),
                          childCount: _filteredOrders.length,
                        ),
                      ),
                    ),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    final totalOrders = _dashboardStats?['total_orders']?.toString() ?? '0';
    final placedOrders = _dashboardStats?['draft_orders']?.toString() ?? '0';
    final transitOrders = _dashboardStats?['out_for_delivery_orders']?.toString() ?? '0';
    final deliveredOrders = _dashboardStats?['delivered_orders']?.toString() ?? '0';
    
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
            child: _buildStatItem(totalOrders, 'Total', Colors.blue),
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.grey[300],
          ),
          Expanded(
            child: _buildStatItem(placedOrders, 'Placed', Colors.blueGrey[600]!),
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.grey[300],
          ),
          Expanded(
            child: _buildStatItem(transitOrders, 'Transit', Colors.green),
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.grey[300],
          ),
          Expanded(
            child: _buildStatItem(deliveredOrders, 'Delivered', Colors.grey),
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

  Widget _buildSearchAndFilter() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      color: Colors.white,
      child: Column(
        children: [
          // Search Bar
          Container(
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
                hintText: 'Search orders...',
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
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Date Filter
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 40,
                  child: ElevatedButton.icon(
                    onPressed: _selectDateRange,
                    icon: const Icon(Icons.calendar_month_rounded, size: 16),
                    label: Text(
                      _fromDate != null && _toDate != null
                          ? '${DateFormat('MMM dd').format(_fromDate!)} - ${DateFormat('MMM dd').format(_toDate!)}'
                          : 'Select Date',
                      style: const TextStyle(fontSize: 13),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4F46E5),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
                ),
              ),
              if (_fromDate != null || _toDate != null) ...[
                const SizedBox(width: 8),
                Container(
                  height: 40,
                  width: 40,
                  child: IconButton(
                    onPressed: _clearDateFilter,
                    icon: const Icon(Icons.close_rounded, size: 18),
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFFF3F4F6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(Order order) {
    final statusColor = _getStatusColor(order.status);
    final statusName = _getStatusDisplayName(order.status);
    
    // Determine button eligibility
    final bool showInwardButton = order.shouldShowInwardButton && order.isOtpVerified;
    final bool showInvoiceButton = order.paymentStatus.toLowerCase() == 'paid';
    final bool showButtons = showInwardButton || showInvoiceButton;
    
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
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Left Status Color Line with proper spacing
            Container(
              width: 3,
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
                // borderRadius: BorderRadius.circular(2),
              ),
            ),
          
            // Main Content
            Expanded(
              child: Padding(
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
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF111827),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: statusColor,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          statusName,
                          style: TextStyle(
                            fontSize: 11,
                            color: statusColor,
                            fontWeight: FontWeight.w700,
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
                                fontSize: 10,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              DateFormat('MMM dd, yyyy • HH:mm').format(order.createdAt),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF374151),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            
                            const SizedBox(height: 10),
                            
                            // SKU
                            Text(
                              'Items',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'SKU-${order.id}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF374151),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(width: 16),
                      
                      // Right Column - Total Amount
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            // Total Amount
                            Text(
                              'Total Amount',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '₹${order.grandTotal.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF059669),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),

                  // Delivery OTP (if available)
                  if (order.hasOtp && order.deliveryOtp != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: order.isOtpExpired
                            ? Colors.red[50]
                            : order.isOtpVerified
                            ? Colors.green[50]
                            : Colors.orange[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: order.isOtpExpired
                              ? Colors.red[200]!
                              : order.isOtpVerified
                              ? Colors.green[200]!
                              : Colors.orange[200]!,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            order.isOtpExpired
                                ? Icons.access_time
                                : order.isOtpVerified
                                ? Icons.check_circle
                                : Icons.security,
                            color: order.isOtpExpired
                                ? Colors.red[700]
                                : order.isOtpVerified
                                ? Colors.green[700]
                                : Colors.orange[700],
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Delivery OTP: ',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: order.isOtpExpired
                                  ? Colors.red[700]
                                  : order.isOtpVerified
                                  ? Colors.green[700]
                                  : Colors.orange[700],
                            ),
                          ),
                          Text(
                            order.deliveryOtp!,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: order.isOtpExpired
                                  ? Colors.red[700]
                                  : order.isOtpVerified
                                  ? Colors.green[700]
                                  : Colors.orange[700],
                              letterSpacing: 2,
                            ),
                          ),
                          if (order.isOtpExpired) ...[
                            const Spacer(),
                            Text(
                              'EXPIRED',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.red[700],
                              ),
                            ),
                          ] else if (order.isOtpVerified) ...[
                            const Spacer(),
                            Text(
                              'VERIFIED',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.green[700],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  const SizedBox(height: 12),
                  ],
                  
                  // Separator Line (only show if buttons are available)
                  if (showButtons) ...[
                    Container(
                      height: 1,
                      color: const Color(0xFFE5E7EB),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Action Buttons Row
                    Row(
                      children: [
                        // Inward Button (only if OTP is verified)
                        if (showInwardButton) ...[
                          Expanded(
                            child: SizedBox(
                              height: 40,
                              child: ElevatedButton.icon(
                                onPressed: () => _showInwardDialog(order),
                                icon: const Icon(Icons.input_rounded, size: 16),
                                label: const Text(
                                  'Inward',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF10B981),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                ),
                              ),
                            ),
                          ),
                          if (showInvoiceButton) const SizedBox(width: 8),
                        ],
                        
                        // Invoice Button (only if payment is paid)
                        if (showInvoiceButton)
                          Expanded(
                            child: SizedBox(
                              height: 40,
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => InvoiceScreen(orderId: order.id.toString()),
                                    ),
                                  );
                                },
                                icon: const Icon(
                                  Icons.receipt_long_outlined, 
                                  size: 16,
                                  color: Color(0xFF4F46E5),
                                ),
                                label: const Text(
                                  'View Invoice',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF4F46E5),
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                    color: Color(0xFF4F46E5),
                                    width: 1.5,
                                  ),
                                  backgroundColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
        ),
      ),
    );
  }

  void _showInwardDialog(Order order) {
    showDialog(
      context: context,
      builder: (context) => InwardDialog(
        order: order,
        onInwardSuccess: () {
          _loadOrders(); // Refresh orders list after successful inward
        },
      ),
    );
  }
}

class InwardDialog extends StatefulWidget {
  final Order order;
  final VoidCallback onInwardSuccess;

  const InwardDialog({
    super.key,
    required this.order,
    required this.onInwardSuccess,
  });

  @override
  State<InwardDialog> createState() => _InwardDialogState();
}

class _InwardDialogState extends State<InwardDialog> {
  final ApiService _apiService = ApiService();
  final Map<int, TextEditingController> _quantityControllers = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with current quantities for items that can be inwarded
    for (final item in widget.order.items) {
      if (!item.inwardLocked) {
        _quantityControllers[item.id] = TextEditingController(
          text: item.qtyOrdered.toStringAsFixed(0),
        );
      }
    }
  }

  @override
  void dispose() {
    for (final controller in _quantityControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _submitInward() async {
    setState(() => _isLoading = true);

    try {
      // Build the items payload for the API
      final List<Map<String, dynamic>> inwardItems = [];
      
      for (final item in widget.order.items) {
        if (!item.inwardLocked && _quantityControllers.containsKey(item.id)) {
          final controller = _quantityControllers[item.id]!;
          final receivedQty = int.tryParse(controller.text) ?? 0;
          
          if (receivedQty > 0) {
            inwardItems.add({
              'order_item_id': item.id,
              'received_qty': receivedQty,
            });
          }
        }
      }

      if (inwardItems.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter valid quantities for at least one item'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final response = await _apiService.inwardOrderItems(
        widget.order.id.toString(),
        inwardItems,
      );

      if (mounted) {
        setState(() => _isLoading = false);

        if (response['success']) {
          Navigator.of(context).pop();
          widget.onInwardSuccess();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? 'Items marked as inward successfully'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          String errorMessage = response['message'] ?? 'Failed to mark items as inward';
          
          // Check for detailed field errors (similar to change password)
          if (response['errors'] != null) {
            final errors = response['errors'] as Map<String, dynamic>;
            final List<String> errorMessages = [];
            
            errors.forEach((field, messages) {
              if (messages is List) {
                errorMessages.addAll(messages.cast<String>());
              }
            });
            
            if (errorMessages.isNotEmpty) {
              errorMessage = errorMessages.join('\n');
            }
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final inwardableItems = widget.order.items.where((item) => !item.inwardLocked).toList();

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: [
          const Icon(Icons.input, color: Colors.green),
          const SizedBox(width: 8),
          Text(
            'Inward Items',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Order: ${widget.order.orderNumber}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 16),
            
            if (inwardableItems.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blueGrey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blueGrey[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.blueGrey[600]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'All items in this order have been locked for inward.',
                        style: TextStyle(color: Colors.blueGrey[700]),
                      ),
                    ),
                  ],
                ),
              )
            else
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.4,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: inwardableItems.map((item) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.productName,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Ordered: ${item.qtyOrdered.toStringAsFixed(0)} ${item.uom}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Text(
                                  'Received Qty:',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextField(
                                    controller: _quantityControllers[item.id],
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      hintText: 'Enter quantity',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(color: Colors.grey[300]!),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(color: Colors.green),
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        if (inwardableItems.isNotEmpty)
          ElevatedButton(
            onPressed: _isLoading ? null : _submitInward,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Submit Inward',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
      ],
    );
  }
}