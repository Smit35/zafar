import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/manifest.dart';
import '../../providers/manifest_provider.dart';
import '../../utils/constants.dart';

class ManifestDetailsScreen extends StatefulWidget {
  final int manifestId;
  final VoidCallback? onDeliveryStarted;

  const ManifestDetailsScreen({
    super.key,
    required this.manifestId,
    this.onDeliveryStarted,
  });

  @override
  State<ManifestDetailsScreen> createState() => _ManifestDetailsScreenState();
}

class _ManifestDetailsScreenState extends State<ManifestDetailsScreen> {
  Manifest? _manifest;
  bool _isLoading = true;
  Map<int, bool> _otpGeneratedOrders = {};

  @override
  void initState() {
    super.initState();
    _loadManifestDetails();
  }

  Future<void> _loadManifestDetails() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final manifestProvider = Provider.of<ManifestProvider>(context, listen: false);
      final manifest = await manifestProvider.getManifestDetails(widget.manifestId);
      
      if (mounted) {
        setState(() {
          _manifest = manifest;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _manifest = null;
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _startDelivery() async {
    if (_manifest == null) return;

    final manifestProvider = Provider.of<ManifestProvider>(context, listen: false);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    final success = await manifestProvider.startDelivery(_manifest!.id);
    
    if (mounted) {
      Navigator.of(context).pop(); // Close loading dialog
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Delivery started successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
        
        // Refresh the manifest details
        await _loadManifestDetails();
        
        // Notify parent screen
        if (widget.onDeliveryStarted != null) {
          widget.onDeliveryStarted!();
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(manifestProvider.error.isNotEmpty 
                ? manifestProvider.error 
                : 'Failed to start delivery'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_manifest?.manifestNumber ?? 'Manifest Details'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : _manifest == null
              ? _buildErrorState()
              : _buildManifestDetails(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.error,
          ),
          const SizedBox(height: AppSizes.paddingMedium),
          const Text(
            'Failed to load manifest details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSizes.paddingLarge),
          ElevatedButton(
            onPressed: _loadManifestDetails,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildManifestDetails() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildManifestHeader(),
          // const SizedBox(height: AppSizes.paddingLarge),
          // _buildVehicleDetails(),
          const SizedBox(height: AppSizes.paddingLarge),
          _buildOrdersList(),
          if (_manifest!.isReadyToDispatch) ...[
            const SizedBox(height: AppSizes.paddingLarge),
            _buildStartDeliveryButton(),
          ],
        ],
      ),
    );
  }

  Widget _buildManifestHeader() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _manifest!.manifestNumber,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              _buildStatusChip(),
            ],
          ),
          const SizedBox(height: AppSizes.paddingSmall),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 8),
              Text(
                'Dispatch Date: ${_formatDate(_manifest!.dispatchDate)}',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.receipt_long, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 8),
              Text(
                'Total Orders: ${_manifest!.totalOrders}',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip() {
    Color backgroundColor;
    Color textColor;
    String statusText;

    switch (_manifest!.status) {
      case 'ready_to_dispatch':
        backgroundColor = AppColors.warning.withOpacity(0.1);
        textColor = AppColors.warning;
        statusText = 'Ready to Dispatch';
        break;
      case 'out_for_delivery':
        backgroundColor = AppColors.primary.withOpacity(0.1);
        textColor = AppColors.primary;
        statusText = 'Out for Delivery';
        break;
      case 'completed':
        backgroundColor = AppColors.success.withOpacity(0.1);
        textColor = AppColors.success;
        statusText = 'Completed';
        break;
      default:
        backgroundColor = AppColors.textLight.withOpacity(0.1);
        textColor = AppColors.textLight;
        statusText = _manifest!.status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingSmall,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  /*Widget _buildVehicleDetails() {
    final vehicle = _manifest!.vehicle;
    
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Vehicle Details',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSizes.paddingMedium),
          Row(
            children: [
              Icon(Icons.local_shipping, color: AppColors.primary, size: 24),
              const SizedBox(width: AppSizes.paddingMedium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vehicle.vehicleName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      vehicle.registrationNumber,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      '${vehicle.vehicleType} • ${vehicle.fuelType}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textLight,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }*/

  Widget _buildOrdersList() {
    if (_manifest!.orders == null || _manifest!.orders!.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          border: Border.all(color: AppColors.border),
        ),
        child: const Center(
          child: Text(
            'No orders found in this manifest',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Orders',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSizes.paddingMedium),
        ..._manifest!.orders!.map((order) => _buildOrderCard(order)),
      ],
    );
  }

  Widget _buildOrderCard(order) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.paddingMedium),
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                order.orderNumber,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  order.orderStatus,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingSmall),
          Text(
            order.outlet.outletName,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            order.outlet.fullAddress,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textLight,
            ),
          ),
          const SizedBox(height: AppSizes.paddingSmall),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${order.itemsCount} items',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                '₹${order.grandTotal.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          if (_manifest!.status == 'out_for_delivery') ...[
            const SizedBox(height: AppSizes.paddingMedium),
            _buildGenerateOTPButton(order),
          ],
        ],
      ),
    );
  }

  Widget _buildStartDeliveryButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _startDelivery,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          ),
          elevation: 0,
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.play_arrow, size: 20),
            SizedBox(width: 8),
            Text(
              'Start Delivery',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenerateOTPButton(order) {
    final isOTPGenerated = _otpGeneratedOrders[order.id] ?? false;
    final isDelivered = order.orderStatus == 'delivered';
    
    if (isDelivered) {
      return const SizedBox.shrink();
    }
    
    if (isOTPGenerated) {
      return Container(
        padding: const EdgeInsets.all(AppSizes.paddingSmall),
        decoration: BoxDecoration(
          color: AppColors.success.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          border: Border.all(color: AppColors.success.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: AppColors.success,
              size: 16,
            ),
            const SizedBox(width: 8),
            const Text(
              'OTP Generated',
              style: TextStyle(
                color: AppColors.success,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }
    
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _generateOTP(order.id),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.secondary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          ),
          elevation: 0,
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.security, size: 16),
            SizedBox(width: 8),
            Text(
              'Generate OTP',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _generateOTP(int orderId) async {
    final manifestProvider = Provider.of<ManifestProvider>(context, listen: false);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    final success = await manifestProvider.generateOTP(orderId);
    
    if (mounted) {
      Navigator.of(context).pop();
      
      if (success) {
        setState(() {
          _otpGeneratedOrders[orderId] = true;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('OTP generated successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(manifestProvider.error.isNotEmpty 
                ? manifestProvider.error 
                : 'Failed to generate OTP'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}