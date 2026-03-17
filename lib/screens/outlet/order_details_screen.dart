import 'package:flutter/material.dart';
import '../../models/order.dart';
import '../../services/api_service.dart';

class OrderDetailsScreen extends StatefulWidget {
  final Order order;

  const OrderDetailsScreen({super.key, required this.order});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  final ApiService _apiService = ApiService();
  late Order _order;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _order = widget.order;
  }

  Future<void> _updateOrderStatus(
    String status, {
    String? reason,
    int? preparationTime,
  }) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _apiService.updateOutletOrderStatus(
        _order.id,
        status,
        reason: reason,
        preparationTime: preparationTime,
      );

      if (response['success']) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                response['message'] ?? 'Order updated successfully',
              ),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true); // Return true to indicate update
        }
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
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _generateOTP() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _apiService.generateDeliveryOTP(_order.id);

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
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'This OTP is valid for 15 minutes',
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
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? 'Failed to generate OTP'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
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
        title: Text('Order #${_order.orderNumber ?? _order.id}'),
        elevation: 0,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildOrderStatus(),
                const SizedBox(height: 16),
                _buildCustomerInfo(),
                const SizedBox(height: 16),
                _buildOrderItems(),
                const SizedBox(height: 16),
                _buildOrderSummary(),
                const SizedBox(height: 80), // Space for bottom action bar
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
        ],
      ),
      bottomSheet: _buildActionBar(),
    );
  }

  Widget _buildOrderStatus() {
    Color statusColor = Colors.grey;
    String statusText = _order.status.toUpperCase();
    IconData statusIcon = Icons.receipt;

    switch (_order.status) {
      case 'NEW ORDER'://OrderStatus.assigned:
        statusColor = Colors.orange;
        statusText = 'NEW ORDER';
        statusIcon = Icons.notifications;
        break;
      case 'NEW ORDER'://OrderStatus.active:
        statusColor = Colors.blue;
        statusText = 'PREPARING';
        statusIcon = Icons.restaurant;
        break;
      case 'NEW ORDER'://OrderStatus.delivered:
        statusColor = Colors.green;
        statusText = 'COMPLETED';
        statusIcon = Icons.check_circle;
        break;
      case 'NEW ORDER'://OrderStatus.cancelled:
        statusColor = Colors.red;
        statusText = 'CANCELLED';
        statusIcon = Icons.cancel;
        break;
      default:
        break;
    }

    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(statusIcon, color: statusColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Order placed: ${_formatDateTime(_order.createdAt)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                // if (_order.estimatedDeliveryTime != null)
                //   Text(
                //     'Estimated delivery: ${_order.estimatedDeliveryTime}',
                //     style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                //   ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.person, color: Colors.blue, size: 20),
              SizedBox(width: 8),
              Text(
                'Customer Information',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Name', _order.customerName ?? 'N/A'),
          _buildInfoRow('Phone', _order.customerPhone ?? 'N/A'),
          _buildInfoRow('Address', _order.deliveryAddress ?? 'N/A'),
          if (_order.specialInstructions?.isNotEmpty == true)
            _buildInfoRow('Special Instructions', _order.specialInstructions!),
        ],
      ),
    );
  }

  Widget _buildOrderItems() {
    return Container(
      padding: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.restaurant_menu, color: Colors.orange, size: 20),
              SizedBox(width: 8),
              Text(
                'Order Items',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_order.items?.isNotEmpty == true)
            ...(_order.items!.map((item) => _buildOrderItem(item)).toList())
          else
            const Text('No items found', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildOrderItem(dynamic item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Icon(Icons.fastfood, color: Colors.orange, size: 20),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.menuItem?.name ?? 'Item',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Qty: ${item.quantity} × ₹${item.menuItem?.price?.toStringAsFixed(0) ?? "0"}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Text(
            '₹${(item.quantity * (item.menuItem?.price ?? 0)).toStringAsFixed(0)}',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.receipt_long, color: Colors.green, size: 20),
              SizedBox(width: 8),
              Text(
                'Order Summary',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSummaryRow(
            'Subtotal',
            '₹${_order.subtotal?.toStringAsFixed(0) ?? "0"}',
          ),
          // _buildSummaryRow(
          //   'Tax',
          //   '₹${_order.taxAmount?.toStringAsFixed(0) ?? "0"}',
          // ),
          // _buildSummaryRow(
          //   'Delivery Fee',
          //   '₹${_order.deliveryFee?.toStringAsFixed(0) ?? "0"}',
          // ),
          // if (_order.discountAmount != null && _order.discountAmount! > 0)
          //   _buildSummaryRow(
          //     'Discount',
          //     '-₹${_order.discountAmount!.toStringAsFixed(0)}',
          //     isDiscount: true,
          //   ),
          const Divider(),
          _buildSummaryRow(
            'Total',
            '₹${_order.totalAmount.toStringAsFixed(0)}',
            isTotal: true,
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            'Payment Method',
            _order.paymentMethod ?? 'Cash on Delivery',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    bool isTotal = false,
    bool isDiscount = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isDiscount ? Colors.green : Colors.black,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: isDiscount
                  ? Colors.green
                  : (isTotal ? Colors.orange[600] : Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            offset: Offset(0, -2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(children: _getActionButtons()),
    );
  }

  List<Widget> _getActionButtons() {
    switch (_order.status) {
      // case OrderStatus.assigned:
      //   return [
      //     Expanded(
      //       child: OutlinedButton(
      //         onPressed: _isLoading ? null : () => _showRejectDialog(),
      //         style: OutlinedButton.styleFrom(
      //           side: const BorderSide(color: Colors.red),
      //           foregroundColor: Colors.red,
      //         ),
      //         child: const Text('Reject'),
      //       ),
      //     ),
      //     const SizedBox(width: 12),
      //     Expanded(
      //       flex: 2,
      //       child: ElevatedButton(
      //         onPressed: _isLoading ? null : () => _showAcceptDialog(),
      //         style: ElevatedButton.styleFrom(
      //           backgroundColor: Colors.green,
      //           foregroundColor: Colors.white,
      //         ),
      //         child: const Text('Accept Order'),
      //       ),
      //     ),
      //   ];
      // case OrderStatus.active:
      //   return [
      //     Expanded(
      //       child: ElevatedButton(
      //         onPressed: _isLoading ? null : () => _updateOrderStatus('ready'),
      //         style: ElevatedButton.styleFrom(
      //           backgroundColor: Colors.orange[600],
      //           foregroundColor: Colors.white,
      //         ),
      //         child: const Text('Mark as Ready'),
      //       ),
      //     ),
      //   ];
      // case OrderStatus.delivered:
      //   return [
      //     Expanded(
      //       child: ElevatedButton(
      //         onPressed: _isLoading ? null : _generateOTP,
      //         style: ElevatedButton.styleFrom(
      //           backgroundColor: Colors.blue,
      //           foregroundColor: Colors.white,
      //         ),
      //         child: const Text('Generate Delivery OTP'),
      //       ),
      //     ),
      //   ];
      default:
        return [];
    }
  }

  void _showAcceptDialog() {
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

  void _showRejectDialog() {
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
              _updateOrderStatus('rejected', reason: reasonController.text);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return 'N/A';

    return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
