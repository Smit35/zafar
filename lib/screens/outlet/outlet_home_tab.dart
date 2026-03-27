import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../services/api_service.dart';
import '../../models/order.dart';
import 'package:intl/intl.dart';

class OutletHomeTab extends StatefulWidget {
  final VoidCallback? onViewAllOrders;
  
  const OutletHomeTab({super.key, this.onViewAllOrders});

  @override
  State<OutletHomeTab> createState() => _OutletHomeTabState();
}

class _OutletHomeTabState extends State<OutletHomeTab> {
  final ApiService _apiService = ApiService();
  String _outletName = 'Outlet Name';
  List<Order> _todayOrders = [];
  bool _isLoading = true;

  // Dashboard statistics
  Map<String, dynamic>? _dashboardStats;
  int get _totalOrders => _dashboardStats?['total_orders'] ?? 0;
  int get _pendingOrders => _dashboardStats?['pending_orders'] ?? 0;
  int get _deliveredOrders => _dashboardStats?['delivered_orders'] ?? 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _loadOutletName();
    await _loadDashboardStats();
    await _loadTodayOrders();
  }

  Future<void> _loadOutletName() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final outletData = prefs.getString('outlet_data');
      if (outletData != null) {
        final data = jsonDecode(outletData);
        if (mounted) {
          setState(() {
            _outletName = data['outlet_name'] ?? 'Outlet Name';
          });
        }
      }
    } catch (e) {
      print("Outlet error $e");    }
  }

  Future<void> _loadDashboardStats() async {
    try {
      final response = await _apiService.getOutletDashboard();
      print("Dashboard response: $response");
      
      if (response['success'] && mounted) {
        setState(() {
          _dashboardStats = response['dashboard']?['data']?['statistics'];
        });
        print("Dashboard stats loaded: $_dashboardStats");
      }
    } catch (e) {
      print("Dashboard error $e");
    }
  }

  Future<void> _loadTodayOrders() async {
    try {
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final response = await _apiService.getOutletOrders(
        dateFrom: today,
        dateTo: today,
        perPage: 10, // Limit for recent orders display
      );

      if (response['success'] && mounted) {
        final orders = response['orders'] as List<Order>;
        setState(() {
          _todayOrders = orders;
          _isLoading = false;
        });
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      // Error loading today orders - keeping existing state
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: _loadData,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Card
                  _buildWelcomeCard(),
                  const SizedBox(height: 20),
                  
                  // Order Stats Row
                  _buildOrderStats(),
                  const SizedBox(height: 20),
                  
                  // Recent Orders Section
                  _buildRecentOrdersSection(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blueGrey[400]!, Colors.blueGrey[600]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blueGrey.withAlpha(77),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _outletName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(51),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.circle,
                            color: Colors.green,
                            size: 8,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Online',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
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
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(38),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.restaurant,
              color: Colors.white,
              size: 32,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Total Orders',
            _totalOrders.toString(),
            Icons.receipt_long_outlined,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Pending Orders',
            _pendingOrders.toString(),
            Icons.pending_outlined,
            Colors.blue[600]!,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Delivered Orders',
            _deliveredOrders.toString(),
            Icons.check_circle_outline,
            Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(26),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
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

  Widget _buildRecentOrdersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Recent Orders',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () {
                widget.onViewAllOrders?.call();
              },
              child: Text(
                'View All',
                style: TextStyle(
                  color: Colors.blueGrey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _todayOrders.isEmpty
          ? _buildEmptyOrdersWidget()
          : Column(
              children: _todayOrders.take(5).map((order) => _buildOrderCard(order)).toList(),
            ),
      ],
    );
  }

  Widget _buildEmptyOrdersWidget() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(26),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 12),
            Text(
              'No orders today',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Orders will appear here when customers place them',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(Order order) {
    Color statusColor = Colors.blue;
    switch (order.status.toLowerCase()) {
      case 'delivered':
        statusColor = Colors.green;
        break;
      case 'preparing':
      case 'accepted':
        statusColor = Colors.blue[600]!;
        break;
      case 'cancelled':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.blue;
    }

    final dateTime = _formatDateTime(order.createdAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(26),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                order.orderNumber,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              Text(
                '₹${order.grandTotal.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                dateTime,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withAlpha(26),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _capitalizeFirst(order.status),
                  style: TextStyle(
                    fontSize: 10,
                    color: statusColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    // Format: "Mar 17, 2026 at 12:54 PM"
    return DateFormat('MMM dd, yyyy \'at\' h:mm a').format(dateTime);
  }

  String _formatTimeAgo(DateTime dateTime) {
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

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

}