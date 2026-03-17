import 'package:flutter/material.dart';

class OutletNotificationScreen extends StatefulWidget {
  const OutletNotificationScreen({super.key});

  @override
  State<OutletNotificationScreen> createState() => _OutletNotificationScreenState();
}

class _OutletNotificationScreenState extends State<OutletNotificationScreen> {
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Orders', 'Payments', 'System', 'Promotions'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => _markAllAsRead(),
            child: Text(
              'Mark all read',
              style: TextStyle(
                color: Colors.orange[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: Colors.grey[600]),
            onSelected: (value) {
              switch (value) {
                case 'settings':
                  _showNotificationSettings();
                  break;
                case 'clear':
                  _clearAllNotifications();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings, size: 18),
                    SizedBox(width: 8),
                    Text('Settings'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.clear_all, size: 18, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Clear All'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Tabs
          _buildFilterTabs(),
          
          // Notification List
          Expanded(
            child: _buildNotificationList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      height: 60,
      color: Colors.white,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = _selectedFilter == filter;
          
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedFilter = filter;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.orange[600] : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? Colors.orange[600]! : Colors.grey[300]!,
                ),
              ),
              child: Center(
                child: Text(
                  filter,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey[600],
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNotificationList() {
    return RefreshIndicator(
      onRefresh: () async {
        // Refresh notifications
        await Future.delayed(const Duration(seconds: 1));
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 15,
        itemBuilder: (context, index) => _buildNotificationItem(index),
      ),
    );
  }

  Widget _buildNotificationItem(int index) {
    final notifications = [
      {
        'type': 'order',
        'title': 'New Order Received',
        'message': 'Order #12348 from Rahul Sharma - ₹420',
        'time': '2 mins ago',
        'isRead': false,
        'icon': Icons.shopping_bag,
        'color': Colors.blue,
        'action': 'View Order',
      },
      {
        'type': 'payment',
        'title': 'Payment Received',
        'message': 'Payment of ₹420 for order #12348 has been credited',
        'time': '5 mins ago',
        'isRead': false,
        'icon': Icons.payment,
        'color': Colors.green,
        'action': 'View Details',
      },
      {
        'type': 'system',
        'title': 'Menu Updated',
        'message': 'Your menu items have been successfully updated',
        'time': '1 hour ago',
        'isRead': true,
        'icon': Icons.restaurant_menu,
        'color': Colors.orange,
        'action': null,
      },
      {
        'type': 'order',
        'title': 'Order Cancelled',
        'message': 'Order #12347 has been cancelled by customer',
        'time': '2 hours ago',
        'isRead': true,
        'icon': Icons.cancel,
        'color': Colors.red,
        'action': 'View Details',
      },
      {
        'type': 'promotion',
        'title': 'Special Promotion',
        'message': 'Boost your sales with 20% discount promotion this weekend',
        'time': '3 hours ago',
        'isRead': true,
        'icon': Icons.local_offer,
        'color': Colors.purple,
        'action': 'Learn More',
      },
      {
        'type': 'system',
        'title': 'Stock Alert',
        'message': 'Low stock alert: Chicken is running low (2kg remaining)',
        'time': '4 hours ago',
        'isRead': false,
        'icon': Icons.warning,
        'color': Colors.orange,
        'action': 'Update Stock',
      },
      {
        'type': 'payment',
        'title': 'Weekly Settlement',
        'message': 'Your weekly payment of ₹15,240 has been processed',
        'time': '1 day ago',
        'isRead': true,
        'icon': Icons.account_balance,
        'color': Colors.green,
        'action': 'View Statement',
      },
      {
        'type': 'order',
        'title': 'Order Ready for Pickup',
        'message': 'Order #12345 is ready for delivery pickup',
        'time': '1 day ago',
        'isRead': true,
        'icon': Icons.local_shipping,
        'color': Colors.blue,
        'action': 'Generate OTP',
      },
    ];

    final notification = notifications[index % notifications.length];
    final isRead = notification['isRead'] as bool;
    final type = notification['type'] as String;

    // Filter notifications based on selected filter
    if (_selectedFilter != 'All') {
      final filterType = _selectedFilter.toLowerCase();
      if (type != filterType.substring(0, filterType.length - 1)) {
        return const SizedBox.shrink();
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isRead ? Colors.transparent : Colors.orange.withOpacity(0.3),
          width: isRead ? 0 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _handleNotificationTap(notification),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Notification Icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: (notification['color'] as Color).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  notification['icon'] as IconData,
                  color: notification['color'] as Color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              
              // Notification Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification['title'] as String,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isRead ? FontWeight.w500 : FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        if (!isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: Colors.orange[600],
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification['message'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          notification['time'] as String,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[500],
                          ),
                        ),
                        if (notification['action'] != null) ...[
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange[50],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              notification['action'] as String,
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.orange[700],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              
              // More Menu
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, color: Colors.grey[400], size: 18),
                onSelected: (value) {
                  switch (value) {
                    case 'mark_read':
                      _markAsRead(notification);
                      break;
                    case 'delete':
                      _deleteNotification(notification);
                      break;
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'mark_read',
                    child: Row(
                      children: [
                        Icon(
                          isRead ? Icons.mark_email_unread : Icons.mark_email_read,
                          size: 16,
                          color: Colors.blue,
                        ),
                        const SizedBox(width: 8),
                        Text(isRead ? 'Mark Unread' : 'Mark Read'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 16, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleNotificationTap(Map<String, dynamic> notification) {
    final type = notification['type'] as String;
    final action = notification['action'] as String?;
    
    // Mark as read
    _markAsRead(notification);
    
    // Handle different notification types
    switch (type) {
      case 'order':
        if (action == 'View Order' || action == 'View Details') {
          // Navigate to order details
          _showOrderDetails();
        } else if (action == 'Generate OTP') {
          _showOTPDialog();
        }
        break;
      case 'payment':
        if (action == 'View Details' || action == 'View Statement') {
          // Navigate to payment details
          _showPaymentDetails();
        }
        break;
      case 'system':
        if (action == 'Update Stock') {
          // Navigate to stock management
          _showStockUpdate();
        }
        break;
      case 'promotion':
        if (action == 'Learn More') {
          _showPromotionDetails();
        }
        break;
    }
  }

  void _markAsRead(Map<String, dynamic> notification) {
    setState(() {
      notification['isRead'] = true;
    });
  }

  void _markAllAsRead() {
    setState(() {
      // Mark all notifications as read
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All notifications marked as read'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _deleteNotification(Map<String, dynamic> notification) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Notification deleted'),
        backgroundColor: Colors.red,
        action: SnackBarAction(
          label: 'Undo',
          textColor: Colors.white,
          onPressed: () {
            // Restore notification
          },
        ),
      ),
    );
  }

  void _clearAllNotifications() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Notifications'),
        content: const Text('Are you sure you want to clear all notifications? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                // Clear all notifications
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All notifications cleared'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Clear All', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showNotificationSettings() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Notification Settings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            SwitchListTile(
              title: const Text('Order Notifications'),
              subtitle: const Text('New orders, cancellations, updates'),
              value: true,
              onChanged: (value) {},
            ),
            SwitchListTile(
              title: const Text('Payment Notifications'),
              subtitle: const Text('Payment confirmations, settlements'),
              value: true,
              onChanged: (value) {},
            ),
            SwitchListTile(
              title: const Text('System Notifications'),
              subtitle: const Text('App updates, maintenance alerts'),
              value: false,
              onChanged: (value) {},
            ),
            SwitchListTile(
              title: const Text('Marketing Notifications'),
              subtitle: const Text('Promotions, tips, offers'),
              value: true,
              onChanged: (value) {},
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange[600],
                ),
                child: const Text('Save Settings', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Sample action methods
  void _showOrderDetails() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening order details...')),
    );
  }

  void _showOTPDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delivery OTP'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('OTP for order delivery:'),
            SizedBox(height: 16),
            Text(
              '1234',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 8,
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
  }

  void _showPaymentDetails() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening payment details...')),
    );
  }

  void _showStockUpdate() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening stock management...')),
    );
  }

  void _showPromotionDetails() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Weekend Promotion'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Boost your sales with our special weekend promotion!'),
            SizedBox(height: 16),
            Text('• 20% discount on all items'),
            Text('• Increased visibility'),
            Text('• Valid this weekend only'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Maybe Later'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange[600],
            ),
            child: const Text('Activate Now', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}