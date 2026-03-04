import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import '../../models/order.dart';
import '../../utils/constants.dart';

class EnhancedOrderDetails extends StatefulWidget {
  final Order order;
  final Function(Order)? onStatusUpdate;

  const EnhancedOrderDetails({
    super.key,
    required this.order,
    this.onStatusUpdate,
  });

  @override
  State<EnhancedOrderDetails> createState() => _EnhancedOrderDetailsState();
}

class _EnhancedOrderDetailsState extends State<EnhancedOrderDetails> {
  late Order _currentOrder;

  @override
  void initState() {
    super.initState();
    _currentOrder = widget.order;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Order #${_currentOrder.id}'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.phone),
            onPressed: () => _makePhoneCall(_currentOrder.customerPhone),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusCard(),
            const SizedBox(height: AppSizes.paddingMedium),
            _buildCustomerInfoCard(),
            const SizedBox(height: AppSizes.paddingMedium),
            _buildOrderItemsCard(),
            const SizedBox(height: AppSizes.paddingMedium),
            _buildDeliveryInfoCard(),
            const SizedBox(height: AppSizes.paddingMedium),
            _buildPaymentInfoCard(),
            const SizedBox(height: AppSizes.paddingLarge),
          ],
        ),
      ),
      bottomNavigationBar: _buildActionButtons(),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.paddingLarge),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _getStatusGradient(_currentOrder.status),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
      ),
      child: Column(
        children: [
          Icon(
            _getStatusIcon(_currentOrder.status),
            size: 48,
            color: Colors.white,
          ),
          const SizedBox(height: AppSizes.paddingSmall),
          Text(
            _getStatusText(_currentOrder.status),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Order placed ${_getTimeAgo(_currentOrder.createdAt)}',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerInfoCard() {
    return _buildInfoCard(
      title: 'Customer Information',
      icon: Icons.person,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow(
            icon: Icons.person_outline,
            label: 'Name',
            value: _currentOrder.customerName,
          ),
          const SizedBox(height: AppSizes.paddingSmall),
          _buildInfoRow(
            icon: Icons.phone_outlined,
            label: 'Phone',
            value: _currentOrder.customerPhone,
            onTap: () => _makePhoneCall(_currentOrder.customerPhone),
            isClickable: true,
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItemsCard() {
    return _buildInfoCard(
      title: 'Order Items',
      icon: Icons.restaurant_menu,
      child: Column(
        children: [
          ...(_currentOrder.items.map((item) => Container(
            margin: const EdgeInsets.only(bottom: AppSizes.paddingSmall),
            padding: const EdgeInsets.all(AppSizes.paddingSmall),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                  ),
                  child: Center(
                    child: Text(
                      item.menuItem.image,
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ),
                const SizedBox(width: AppSizes.paddingSmall),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.menuItem.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '₹${item.menuItem.price.toStringAsFixed(0)} × ${item.quantity}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '₹${(item.menuItem.price * item.quantity).toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          )).toList()),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Amount',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '₹${_currentOrder.totalAmount.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryInfoCard() {
    return _buildInfoCard(
      title: 'Delivery Information',
      icon: Icons.location_on,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow(
            icon: Icons.location_on_outlined,
            label: 'Address',
            value: _currentOrder.deliveryAddress,
            maxLines: 3,
          ),
          const SizedBox(height: AppSizes.paddingMedium),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _openMaps(_currentOrder.deliveryAddress),
              icon: const Icon(Icons.directions, size: 18),
              label: const Text('Open in Maps'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentInfoCard() {
    return _buildInfoCard(
      title: 'Payment Information',
      icon: Icons.payment,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow(
            icon: _currentOrder.paymentMethod == 'COD'
                ? Icons.money
                : Icons.credit_card,
            label: 'Payment Method',
            value: _currentOrder.paymentMethod == 'COD'
                ? 'Cash on Delivery'
                : 'Paid Online',
          ),
          const SizedBox(height: AppSizes.paddingSmall),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.paddingSmall,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: _currentOrder.paymentMethod == 'COD'
                  ? AppColors.warning.withValues(alpha: 0.1)
                  : AppColors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
            ),
            child: Text(
              _currentOrder.paymentMethod == 'COD'
                  ? 'Collect ₹${_currentOrder.totalAmount.toStringAsFixed(0)}'
                  : 'Payment Completed',
              style: TextStyle(
                color: _currentOrder.paymentMethod == 'COD'
                    ? AppColors.warning
                    : AppColors.success,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: AppSizes.paddingSmall),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingMedium),
          child,
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    VoidCallback? onTap,
    bool isClickable = false,
    int maxLines = 1,
  }) {
    Widget content = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.textSecondary, size: 16),
        const SizedBox(width: AppSizes.paddingSmall),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isClickable ? AppColors.primary : AppColors.textPrimary,
                ),
                maxLines: maxLines,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        if (isClickable)
          Icon(
            Icons.arrow_forward_ios,
            color: AppColors.primary,
            size: 12,
          ),
      ],
    );

    if (isClickable && onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: content,
      );
    }
    return content;
  }

  Widget _buildActionButtons() {
    if (_currentOrder.status == OrderStatus.completed ||
        _currentOrder.status == OrderStatus.cancelled) {
      return const SizedBox.shrink();
    }

    List<Widget> buttons = [];

    switch (_currentOrder.status) {
      case OrderStatus.assigned:
        buttons = [
          Expanded(
            child: OutlinedButton(
              onPressed: () => _updateOrderStatus(OrderStatus.cancelled),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.error),
                foregroundColor: AppColors.error,
              ),
              child: const Text('Decline'),
            ),
          ),
          const SizedBox(width: AppSizes.paddingMedium),
          Expanded(
            child: ElevatedButton(
              onPressed: () => _updateOrderStatus(OrderStatus.active),
              child: const Text('Accept Order'),
            ),
          ),
        ];
        break;
      case OrderStatus.active:
        buttons = [
          Expanded(
            child: ElevatedButton(
              onPressed: () => _updateOrderStatus(OrderStatus.delivered),
              child: const Text('Mark as Delivered'),
            ),
          ),
        ];
        break;
      case OrderStatus.delivered:
        buttons = [
          Expanded(
            child: ElevatedButton(
              onPressed: () => _updateOrderStatus(OrderStatus.completed),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
              ),
              child: const Text('Complete Order'),
            ),
          ),
        ];
        break;
      default:
        break;
    }

    if (buttons.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.border, width: 0.5),
        ),
      ),
      child: SafeArea(
        child: Row(children: buttons),
      ),
    );
  }

  void _updateOrderStatus(OrderStatus newStatus) {
    setState(() {
      _currentOrder = Order(
        id: _currentOrder.id,
        outletId: _currentOrder.outletId,
        driverId: _currentOrder.driverId,
        items: _currentOrder.items,
        totalAmount: _currentOrder.totalAmount,
        status: newStatus,
        paymentMethod: _currentOrder.paymentMethod,
        createdAt: _currentOrder.createdAt,
        deliveryAddress: _currentOrder.deliveryAddress,
        customerName: _currentOrder.customerName,
        customerPhone: _currentOrder.customerPhone,
      );
    });

    widget.onStatusUpdate?.call(_currentOrder);

    String message = '';
    switch (newStatus) {
      case OrderStatus.active:
        message = 'Order accepted successfully!';
        break;
      case OrderStatus.delivered:
        message = 'Order marked as delivered!';
        break;
      case OrderStatus.completed:
        message = 'Order completed successfully!';
        break;
      case OrderStatus.cancelled:
        message = 'Order declined';
        break;
      default:
        message = 'Order status updated';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: newStatus == OrderStatus.cancelled
            ? AppColors.error
            : AppColors.success,
      ),
    );

    if (newStatus == OrderStatus.completed || newStatus == OrderStatus.cancelled) {
      Navigator.of(context).pop();
    }
  }

  void _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  void _openMaps(String address) async {
    final Uri mapsUri = Uri.parse('https://maps.google.com/?q=${Uri.encodeComponent(address)}');
    if (await canLaunchUrl(mapsUri)) {
      await launchUrl(mapsUri);
    }
  }

  List<Color> _getStatusGradient(OrderStatus status) {
    switch (status) {
      case OrderStatus.assigned:
        return [AppColors.warning, AppColors.warning.withValues(alpha: 0.8)];
      case OrderStatus.active:
        return [AppColors.info, AppColors.info.withValues(alpha: 0.8)];
      case OrderStatus.delivered:
        return [AppColors.secondary, AppColors.secondary.withValues(alpha: 0.8)];
      case OrderStatus.completed:
        return [AppColors.success, AppColors.success.withValues(alpha: 0.8)];
      case OrderStatus.cancelled:
        return [AppColors.error, AppColors.error.withValues(alpha: 0.8)];
    }
  }

  IconData _getStatusIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.assigned:
        return Icons.assignment;
      case OrderStatus.active:
        return Icons.local_shipping;
      case OrderStatus.delivered:
        return Icons.check_circle;
      case OrderStatus.completed:
        return Icons.check_circle;
      case OrderStatus.cancelled:
        return Icons.cancel;
    }
  }

  String _getStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.assigned:
        return 'New Order';
      case OrderStatus.active:
        return 'Picked Up';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.completed:
        return 'Completed';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return DateFormat('MMM dd, yyyy').format(dateTime);
    }
  }
}