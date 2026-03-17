import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/order.dart';
import '../../models/cart_item.dart';
import '../../models/menu_item.dart';
import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';
import 'order_details_screen.dart';

class DriverDashboardScreen extends StatefulWidget {
  const DriverDashboardScreen({super.key});

  @override
  State<DriverDashboardScreen> createState() => _DriverDashboardScreenState();
}

class _DriverDashboardScreenState extends State<DriverDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Mock data for demonstration
  // final List<Order> _activeOrders = [
  //   Order(
  //     id: 'ORD001',
  //     outletId: 'outlet_123',
  //     driverId: 'driver_456',
  //     items: [
  //       CartItem(
  //         menuItem: MenuItem(
  //           id: '1',
  //           name: 'Chicken Biryani',
  //           description: 'Aromatic basmati rice with tender chicken pieces',
  //           price: 299.0,
  //           image: '🍛',
  //           category: 'Main Course',
  //         ),
  //         quantity: 2,
  //       ),
  //       CartItem(
  //         menuItem: MenuItem(
  //           id: '3',
  //           name: 'Chicken Tikka',
  //           description: 'Grilled chicken marinated in spices',
  //           price: 199.0,
  //           image: '🍗',
  //           category: 'Starter',
  //         ),
  //         quantity: 1,
  //       ),
  //     ],
  //     totalAmount: 797.0,
  //     status: OrderStatus.active,
  //     paymentMethod: 'COD',
  //     createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
  //     deliveryAddress: '123 Main Street, Downtown, City - 400001',
  //     customerName: 'John Doe',
  //     customerPhone: '+91 9876543210',
  //   ),
  //   Order(
  //     id: 'ORD002',
  //     outletId: 'outlet_123',
  //     driverId: 'driver_456',
  //     items: [
  //       CartItem(
  //         menuItem: MenuItem(
  //           id: '2',
  //           name: 'Paneer Butter Masala',
  //           description: 'Creamy tomato curry with cottage cheese',
  //           price: 249.0,
  //           image: '🍛',
  //           category: 'Main Course',
  //         ),
  //         quantity: 1,
  //       ),
  //     ],
  //     totalAmount: 347.0,
  //     status: OrderStatus.assigned,
  //     paymentMethod: 'Online',
  //     createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
  //     deliveryAddress: '456 Park Avenue, Uptown, City - 400002',
  //     customerName: 'Jane Smith',
  //     customerPhone: '+91 8765432109',
  //   ),
  //   Order(
  //     id: 'ORD004',
  //     outletId: 'outlet_123',
  //     driverId: 'driver_456',
  //     items: [
  //       CartItem(
  //         menuItem: MenuItem(
  //           id: '5',
  //           name: 'Pizza Margherita',
  //           description: 'Fresh mozzarella, tomato sauce, basil',
  //           price: 399.0,
  //           image: '🍕',
  //           category: 'Main Course',
  //         ),
  //         quantity: 1,
  //       ),
  //     ],
  //     totalAmount: 399.0,
  //     status: OrderStatus.delivered,
  //     paymentMethod: 'COD',
  //     createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
  //     deliveryAddress: '789 Oak Street, Midtown, City - 400003',
  //     customerName: 'Alice Johnson',
  //     customerPhone: '+91 7654321098',
  //   ),
  // ];
  //
  // final List<Order> _completedOrders = [
  //   Order(
  //     id: 'ORD003',
  //     outletId: 'outlet_123',
  //     driverId: 'driver_456',
  //     items: [
  //       CartItem(
  //         menuItem: MenuItem(
  //           id: '4',
  //           name: 'Dal Makhani',
  //           description: 'Rich and creamy black lentil curry',
  //           price: 179.0,
  //           image: '🍲',
  //           category: 'Main Course',
  //         ),
  //         quantity: 1,
  //       ),
  //     ],
  //     totalAmount: 179.0,
  //     status: OrderStatus.completed,
  //     paymentMethod: 'COD',
  //     createdAt: DateTime.now().subtract(const Duration(hours: 2)),
  //     deliveryAddress: '789 Oak Street, Midtown, City - 400003',
  //     customerName: 'Mike Johnson',
  //     customerPhone: '+91 7654321098',
  //   ),
  // ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
      appBar: AppBar(
        backgroundColor: Colors.orange[600],
        foregroundColor: Colors.white,
        title: const Text('Driver Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await Provider.of<AuthProvider>(context, listen: false).logout();
              if (mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              }
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.orange[200],
          indicatorColor: Colors.white,
          tabs: const [
            Tab(
              icon: Icon(Icons.assignment),
              text: 'New Orders',
            ),
            Tab(
              icon: Icon(Icons.local_shipping),
              text: 'Active Orders',
            ),
            // Tab(
            //   icon: Icon(Icons.check_circle),
            //   text: 'Completed',
            // ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // _buildNewOrdersList(),
          // _buildActiveOrdersList(),
          // _buildCompletedOrdersList(),
        ],
      ),
    );
  }

/*  Widget _buildNewOrdersList() {
    // Filter orders that are assigned but not yet active
    final newOrders = _activeOrders.where((order) => order.status == OrderStatus.assigned).toList();
    
    if (newOrders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assignment_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No new orders',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'New orders will appear here',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: newOrders.length,
      itemBuilder: (context, index) {
        final order = newOrders[index];
        return _buildOrderCard(order, true);
      },
    );
  }

  Widget _buildActiveOrdersList() {
    // Filter orders that are active (not assigned, not completed)
    final activeOrders = _activeOrders.where((order) => 
        order.status == OrderStatus.active || 
        order.status == OrderStatus.delivered
    ).toList();
    if (activeOrders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_shipping_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No active orders',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'New orders will appear here',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: activeOrders.length,
      itemBuilder: (context, index) {
        final order = activeOrders[index];
        return _buildOrderCard(order, true);
      },
    );
  }*/

  // Commented out completed orders tab
  // Widget _buildCompletedOrdersList() {
  //   if (_completedOrders.isEmpty) {
  //     return Center(
  //       child: Column(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: [
  //           Icon(
  //             Icons.check_circle_outlined,
  //             size: 80,
  //             color: Colors.grey[400],
  //           ),
  //           const SizedBox(height: 16),
  //           Text(
  //             'No completed orders',
  //             style: TextStyle(
  //               fontSize: 18,
  //               color: Colors.grey[600],
  //             ),
  //           ),
  //           const SizedBox(height: 8),
  //           Text(
  //             'Completed orders will appear here',
  //             style: TextStyle(
  //               fontSize: 14,
  //               color: Colors.grey[500],
  //             ),
  //           ),
  //         ],
  //       ),
  //     );
  //   }

  //   return ListView.builder(
  //     padding: const EdgeInsets.all(16),
  //     itemCount: _completedOrders.length,
  //     itemBuilder: (context, index) {
  //       final order = _completedOrders[index];
  //       return _buildOrderCard(order, false);
  //     },
  //   );
  // }

  Widget _buildOrderCard(Order order, bool isActive) {
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
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => OrderDetailsScreen(
                order: order,
                onStatusUpdate: isActive ? (updatedOrder) {
                  setState(() {
                    // if (updatedOrder.status == OrderStatus.completed) {
                    //   _activeOrders.removeWhere((o) => o.id == order.id);
                    //   _completedOrders.insert(0, updatedOrder);
                    // } else {
                    //   // Update the order in active orders list
                    //   final index = _activeOrders.indexWhere((o) => o.id == order.id);
                    //   if (index != -1) {
                    //     _activeOrders[index] = updatedOrder;
                    //   }
                    // }
                  });
                } : null,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order #${order.id}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // _buildStatusBadge(order.status, isActive),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.person,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    order.customerName,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.phone,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    order.customerPhone,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      order.deliveryAddress,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.payment,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: order.paymentMethod == 'COD' ? Colors.green[50] : Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: order.paymentMethod == 'COD' ? Colors.green[300]! : Colors.blue[300]!,
                        width: 0.5,
                      ),
                    ),
                    child: Text(
                      order.paymentMethod == 'COD' ? 'Cash' : 'Paid',
                      style: TextStyle(
                        fontSize: 12,
                        color: order.paymentMethod == 'COD' ? Colors.green[700] : Colors.blue[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${order.items.length} items',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '₹${order.totalAmount.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _getTimeAgo(order.createdAt),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

 /* Widget _buildStatusBadge(OrderStatus status, bool isActive) {
    Color backgroundColor;
    Color textColor;
    String text;
    
    switch (status) {
      case OrderStatus.active:
        backgroundColor = Colors.orange[100]!;
        textColor = Colors.orange[700]!;
        text = 'Active';
        break;
      case OrderStatus.assigned:
        backgroundColor = Colors.blue[100]!;
        textColor = Colors.blue[700]!;
        text = 'Assigned';
        break;
      case OrderStatus.delivered:
        backgroundColor = Colors.purple[100]!;
        textColor = Colors.purple[700]!;
        text = 'Delivered';
        break;
      case OrderStatus.completed:
        backgroundColor = Colors.green[100]!;
        textColor = Colors.green[700]!;
        text = 'Completed';
        break;
      case OrderStatus.cancelled:
        backgroundColor = Colors.red[100]!;
        textColor = Colors.red[700]!;
        text = 'Cancelled';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }*/

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else {
      return '${difference.inDays} days ago';
    }
  }
}