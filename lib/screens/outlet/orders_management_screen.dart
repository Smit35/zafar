import 'package:flutter/material.dart';
import '../../models/order.dart';
import '../../services/api_service.dart';
import 'order_details_screen.dart';

class OrdersManagementScreen extends StatefulWidget {
  const OrdersManagementScreen({super.key});

  @override
  State<OrdersManagementScreen> createState() => _OrdersManagementScreenState();
}

class _OrdersManagementScreenState extends State<OrdersManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ApiService _apiService = ApiService();

  List<Order> _newOrders = [];
  List<Order> _preparingOrders = [];
  List<Order> _readyOrders = [];
  List<Order> _completedOrders = [];

  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadOrders();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      // Load orders for each status
      final futures = await Future.wait([
        _apiService.getOutletOrders(status: 'new'),
        _apiService.getOutletOrders(status: 'preparing'),
        _apiService.getOutletOrders(status: 'ready'),
        _apiService.getOutletOrders(status: 'completed'),
      ]);

      if (mounted) {
        setState(() {
          _newOrders = futures[0]['success'] ? futures[0]['orders'] : [];
          _preparingOrders = futures[1]['success'] ? futures[1]['orders'] : [];
          _readyOrders = futures[2]['success'] ? futures[2]['orders'] : [];
          _completedOrders = futures[3]['success'] ? futures[3]['orders'] : [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load orders: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _updateOrderStatus(
    Order order,
    String newStatus, {
    String? reason,
    int? preparationTime,
  }) async {
    try {
      final response = await _apiService.updateOutletOrderStatus(
        order.id,
        newStatus,
        reason: reason,
        preparationTime: preparationTime,
      );

      if (response['success']) {
        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                response['message'] ?? 'Order updated successfully',
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
        // Reload orders
        _loadOrders();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? 'Failed to update order'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating order: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.orange[600],
        foregroundColor: Colors.white,
        title: const Text('Orders Management'),
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadOrders),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          tabs: [
            Tab(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('New'),
                  if (_newOrders.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 2),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _newOrders.length.toString(),
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.orange[600],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Tab(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Preparing'),
                  if (_preparingOrders.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 2),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _preparingOrders.length.toString(),
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.orange[600],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Tab(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Ready'),
                  if (_readyOrders.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 2),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _readyOrders.length.toString(),
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.orange[600],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const Tab(text: 'History'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    _error,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadOrders,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOrdersList(_newOrders, OrderTab.newOrders),
                _buildOrdersList(_preparingOrders, OrderTab.preparing),
                _buildOrdersList(_readyOrders, OrderTab.ready),
                _buildOrdersList(_completedOrders, OrderTab.history),
              ],
            ),
    );
  }

  Widget _buildOrdersList(List<Order> orders, OrderTab tab) {
    if (orders.isEmpty) {
      return _buildEmptyState(tab);
    }

    return RefreshIndicator(
      onRefresh: _loadOrders,
      color: Colors.orange[600],
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return _buildOrderCard(order, tab);
        },
      ),
    );
  }

  Widget _buildEmptyState(OrderTab tab) {
    String message = 'No orders found';
    IconData icon = Icons.receipt_long_outlined;

    switch (tab) {
      case OrderTab.newOrders:
        message = 'No new orders';
        icon = Icons.notifications_none;
        break;
      case OrderTab.preparing:
        message = 'No orders being prepared';
        icon = Icons.restaurant;
        break;
      case OrderTab.ready:
        message = 'No orders ready for pickup';
        icon = Icons.done_all;
        break;
      case OrderTab.history:
        message = 'No completed orders';
        icon = Icons.history;
        break;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(Order order, OrderTab tab) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
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
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '#${order.orderNumber ?? order.id}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            order.customerName ?? 'Customer',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '₹${order.totalAmount.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatOrderTime(order.createdAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (order.items?.isNotEmpty == true) ...[
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 8),
                  ...order.items!
                      .take(3)
                      .map(
                        (item) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            children: [
                              Text(
                                '${item.quantity}x',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  item.menuItem?.name ?? 'Item',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                              Text(
                                '₹${item.menuItem?.price?.toStringAsFixed(0) ?? "0"}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  if (order.items!.length > 3)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '+${order.items!.length - 3} more items',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                ],
              ],
            ),
          ),
          _buildOrderActions(order, tab),
        ],
      ),
    );
  }

  Widget _buildOrderActions(Order order, OrderTab tab) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OrderDetailsScreen(order: order),
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.orange[600]!),
                foregroundColor: Colors.orange[600],
              ),
              child: const Text('View Details'),
            ),
          ),
          const SizedBox(width: 8),
          ..._getActionButtons(order, tab),
        ],
      ),
    );
  }

  List<Widget> _getActionButtons(Order order, OrderTab tab) {
    switch (tab) {
      case OrderTab.newOrders:
        return [
          Expanded(
            child: ElevatedButton(
              onPressed: () => _showAcceptDialog(order),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text('Accept'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ElevatedButton(
              onPressed: () => _showRejectDialog(order),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Reject'),
            ),
          ),
        ];
      case OrderTab.preparing:
        return [
          Expanded(
            child: ElevatedButton(
              onPressed: () => _updateOrderStatus(order, 'ready'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange[600],
                foregroundColor: Colors.white,
              ),
              child: const Text('Mark Ready'),
            ),
          ),
        ];
      case OrderTab.ready:
        return [
          Expanded(
            child: ElevatedButton(
              onPressed: () => _showGenerateOTPDialog(order),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Generate OTP'),
            ),
          ),
        ];
      case OrderTab.history:
        return [];
    }
  }

  void _showAcceptDialog(Order order) {
    final preparationTimeController = TextEditingController(text: '20');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Accept Order'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter estimated preparation time:'),
            const SizedBox(height: 16),
            TextField(
              controller: preparationTimeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Preparation Time (minutes)',
                border: OutlineInputBorder(),
              ),
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
              _updateOrderStatus(
                order,
                'accepted',
                preparationTime:
                    int.tryParse(preparationTimeController.text) ?? 20,
              );
            },
            child: const Text('Accept'),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(Order order) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Order'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please provide a reason for rejection:'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Reason',
                border: OutlineInputBorder(),
              ),
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
              _updateOrderStatus(
                order,
                'rejected',
                reason: reasonController.text,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  void _showGenerateOTPDialog(Order order) async {
    try {
      final response = await _apiService.generateDeliveryOTP(order.id);

      if (response['success']) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delivery OTP'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Share this OTP with the delivery driver:'),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    response['otp']?.toString() ?? 'N/A',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4,
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Failed to generate OTP'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  String _formatOrderTime(DateTime? dateTime) {
    if (dateTime == null) return 'N/A';

    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

enum OrderTab { newOrders, preparing, ready, history }
