import 'package:flutter/material.dart';

class OutletOrdersTab extends StatefulWidget {
  const OutletOrdersTab({super.key});

  @override
  State<OutletOrdersTab> createState() => _OutletOrdersTabState();
}

class _OutletOrdersTabState extends State<OutletOrdersTab> 
    with SingleTickerProviderStateMixin {
  
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // Order Stats Card
          _buildStatsCard(),
          
          // Tab Bar
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.orange[600],
              unselectedLabelColor: Colors.grey[600],
              indicatorColor: Colors.orange[600],
              labelStyle: const TextStyle(fontWeight: FontWeight.w600),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
              tabs: const [
                Tab(text: 'New'),
                Tab(text: 'Preparing'),
                Tab(text: 'Ready'),
                Tab(text: 'Completed'),
              ],
            ),
          ),
          
          // Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOrdersList('new'),
                _buildOrdersList('preparing'),
                _buildOrdersList('ready'),
                _buildOrdersList('completed'),
              ],
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
            color: Colors.grey.withOpacity(0.1),
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

  Widget _buildOrdersList(String status) {
    return RefreshIndicator(
      onRefresh: () async {
        // Refresh orders
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: status == 'new' ? 3 : status == 'preparing' ? 5 : status == 'ready' ? 2 : 8,
        itemBuilder: (context, index) => _buildOrderCard(status, index),
      ),
    );
  }

  Widget _buildOrderCard(String status, int index) {
    final orders = {
      'new': [
        {
          'id': '#12348',
          'customer': 'Rahul Sharma',
          'items': 3,
          'amount': 420,
          'time': '2 mins ago',
          'address': 'Block A, Sector 21, Noida',
          'phone': '+91 98765 43210',
        },
        {
          'id': '#12347',
          'customer': 'Priya Patel',
          'items': 2,
          'amount': 280,
          'time': '5 mins ago',
          'address': 'H-123, Green Park, Delhi',
          'phone': '+91 87654 32109',
        },
        {
          'id': '#12346',
          'customer': 'Amit Kumar',
          'items': 1,
          'amount': 150,
          'time': '8 mins ago',
          'address': 'Flat 45, Nehru Place, Delhi',
          'phone': '+91 76543 21098',
        },
      ],
      'preparing': [
        {
          'id': '#12345',
          'customer': 'John Doe',
          'items': 2,
          'amount': 320,
          'time': '15 mins ago',
          'address': 'Villa 12, Gurgaon',
          'phone': '+91 98765 43210',
          'prepTime': '20 mins',
        },
      ],
      'ready': [
        {
          'id': '#12344',
          'customer': 'Jane Smith',
          'items': 4,
          'amount': 680,
          'time': '25 mins ago',
          'address': 'Tower B, DLF Phase 3',
          'phone': '+91 87654 32109',
        },
      ],
      'completed': [
        {
          'id': '#12343',
          'customer': 'Mike Wilson',
          'items': 1,
          'amount': 120,
          'time': '1 hour ago',
          'address': 'Street 15, Model Town',
          'phone': '+91 76543 21098',
        },
      ],
    };

    final orderList = orders[status] ?? [];
    if (index >= orderList.length) {
      return Container();
    }

    final order = orderList[index % orderList.length];
    Color statusColor = _getStatusColor(status);

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
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Order Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.receipt_long,
                        color: statusColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                order['id'] as String,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '₹${order['amount']}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                order['customer'] as String,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '${order['items']} items • ${order['time']}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Customer Info
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            color: Colors.grey[600],
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              order['address'] as String,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.phone_outlined,
                            color: Colors.grey[600],
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            order['phone'] as String,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
                            ),
                          ),
                          const Spacer(),
                          if (status == 'preparing' && order['prepTime'] != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Est. ${order['prepTime']}',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.orange[700],
                                  fontWeight: FontWeight.w500,
                                ),
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
          
          // Action Buttons
          _buildActionButtons(status, order),
        ],
      ),
    );
  }

  Widget _buildActionButtons(String status, Map<String, dynamic> order) {
    switch (status) {
      case 'new':
        return Container(
          padding: const EdgeInsets.all(16),
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
                  onPressed: () => _showRejectDialog(order),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    foregroundColor: Colors.red,
                  ),
                  child: const Text('Reject'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () => _showAcceptDialog(order),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Accept'),
                ),
              ),
            ],
          ),
        );
        
      case 'preparing':
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(12),
              bottomRight: Radius.circular(12),
            ),
          ),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _markAsReady(order),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange[600],
                foregroundColor: Colors.white,
              ),
              child: const Text('Mark as Ready'),
            ),
          ),
        );
        
      case 'ready':
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(12),
              bottomRight: Radius.circular(12),
            ),
          ),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _generateOTP(order),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Generate OTP'),
            ),
          ),
        );
        
      default:
        return Container();
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'new':
        return Colors.blue;
      case 'preparing':
        return Colors.orange;
      case 'ready':
        return Colors.green;
      case 'completed':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  void _showRejectDialog(Map<String, dynamic> order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Order'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Are you sure you want to reject order ${order['id']}?'),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Reason (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
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
              // Reject order logic
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reject', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAcceptDialog(Map<String, dynamic> order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Accept Order'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Accept order ${order['id']}?'),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Estimated preparation time (minutes)',
                border: OutlineInputBorder(),
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
              // Accept order logic
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Accept', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _markAsReady(Map<String, dynamic> order) {
    // Mark order as ready logic
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Order ${order['id']} marked as ready'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _generateOTP(Map<String, dynamic> order) {
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
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                '1234',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'OTP valid for 15 minutes',
              style: TextStyle(fontSize: 12, color: Colors.grey),
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
  }
}