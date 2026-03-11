import 'package:flutter/material.dart';
import '../models/manifest.dart';
import '../utils/constants.dart';

class ManifestCard extends StatelessWidget {
  final Manifest manifest;
  final VoidCallback? onTap;
  final VoidCallback? onStartDelivery;

  const ManifestCard({
    super.key,
    required this.manifest,
    this.onTap,
    this.onStartDelivery,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: AppSizes.paddingSmall),
              _buildVehicleInfo(),
              const SizedBox(height: AppSizes.paddingMedium),
              _buildOrderSummary(),
              if (manifest.isReadyToDispatch && onStartDelivery != null) ...[
                const SizedBox(height: AppSizes.paddingMedium),
                _buildStartDeliveryButton(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                manifest.manifestNumber,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _formatDate(manifest.dispatchDate),
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        _buildStatusChip(),
      ],
    );
  }

  Widget _buildStatusChip() {
    Color backgroundColor;
    Color textColor;
    String statusText;

    switch (manifest.status) {
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
        statusText = manifest.status;
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

  Widget _buildVehicleInfo() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingSmall),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.local_shipping,
            size: 18,
            color: AppColors.primary,
          ),
          const SizedBox(width: AppSizes.paddingSmall),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  manifest.vehicle.vehicleName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  manifest.vehicle.registrationNumber,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Row(
      children: [
        Icon(
          Icons.receipt_long,
          size: 16,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: AppSizes.paddingSmall),
        Text(
          '${manifest.totalOrders} ${manifest.totalOrders == 1 ? 'Order' : 'Orders'}',
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        const Spacer(),
        if (manifest.orders?.isNotEmpty == true)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.location_on,
                  size: 12,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  'View Details',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildStartDeliveryButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onStartDelivery,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.play_arrow, size: 18),
            const SizedBox(width: 8),
            const Text(
              'Start Delivery',
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dispatchDay = DateTime(date.year, date.month, date.day);

    if (dispatchDay == today) {
      return 'Today';
    } else if (dispatchDay == yesterday) {
      return 'Yesterday';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}