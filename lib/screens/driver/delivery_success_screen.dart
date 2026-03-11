import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/order.dart';
import '../../utils/constants.dart';

class DeliverySuccessScreen extends StatefulWidget {
  final Order order;
  final DateTime deliveryTimestamp;

  const DeliverySuccessScreen({
    super.key,
    required this.order,
    required this.deliveryTimestamp,
  });

  @override
  State<DeliverySuccessScreen> createState() => _DeliverySuccessScreenState();
}

class _DeliverySuccessScreenState extends State<DeliverySuccessScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
    ));
    
    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeInOut),
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Override back button behavior
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          _navigateToOrders();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.paddingLarge),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),
                
                // Animated checkmark
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: const BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 60,
                        ),
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: AppSizes.paddingLarge * 2),
                
                // Animated content
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _opacityAnimation.value,
                      child: Column(
                        children: [
                          // Success title
                          const Text(
                            'Delivery Confirmed!',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          
                          const SizedBox(height: AppSizes.paddingMedium),
                          
                          // Order ID
                          Text(
                            'Order #${widget.order.id}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          
                          const SizedBox(height: AppSizes.paddingSmall),
                          
                          // Customer name
                          Text(
                            widget.order.customerName,
                            style: const TextStyle(
                              fontSize: 16,
                              color: AppColors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          
                          const SizedBox(height: AppSizes.paddingMedium),
                          
                          // Delivery timestamp
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSizes.paddingMedium,
                              vertical: AppSizes.paddingSmall,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Text(
                              'Delivered on ${_formatDeliveryTime()}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                
                const Spacer(),
                
                // Action buttons
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _opacityAnimation.value,
                      child: Column(
                        children: [
                          // Back to Orders button
                          ElevatedButton(
                            onPressed: _navigateToOrders,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                              ),
                              elevation: 2,
                            ),
                            child: const Text(
                              'Back to Orders',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: AppSizes.paddingMedium),
                          
                          // Go to Dashboard button
                          OutlinedButton(
                            onPressed: _navigateToDashboard,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              side: const BorderSide(color: AppColors.primary),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                              ),
                            ),
                            child: const Text(
                              'Go to Dashboard',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: AppSizes.paddingMedium),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDeliveryTime() {
    final DateFormat dateFormat = DateFormat('EEEE, MMM d, yyyy');
    final DateFormat timeFormat = DateFormat('h:mm a');
    
    return '${dateFormat.format(widget.deliveryTimestamp)} at ${timeFormat.format(widget.deliveryTimestamp)}';
  }

  void _navigateToOrders() {
    // Navigate to orders screen and clear the navigation stack
    Navigator.of(context).pushNamedAndRemoveUntil(
      '/orders', 
      (route) => false,
    );
  }

  void _navigateToDashboard() {
    // Navigate to dashboard and clear the navigation stack
    Navigator.of(context).pushNamedAndRemoveUntil(
      '/dashboard', 
      (route) => false,
    );
  }
}