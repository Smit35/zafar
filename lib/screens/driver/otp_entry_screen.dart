import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/order.dart';
import '../../providers/order_provider.dart';
import '../../utils/constants.dart';
import 'delivery_success_screen.dart';

class OtpEntryScreen extends StatefulWidget {
  final Order order;

  const OtpEntryScreen({
    super.key,
    required this.order,
  });

  @override
  State<OtpEntryScreen> createState() => _OtpEntryScreenState();
}

class _OtpEntryScreenState extends State<OtpEntryScreen>
    with TickerProviderStateMixin {
  final List<TextEditingController> _controllers = 
      List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = 
      List.generate(6, (index) => FocusNode());
  
  bool _isLoading = false;
  int? _remainingAttempts;
  String? _errorMessage;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
    
    // Auto-focus first box
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    _shakeController.dispose();
    super.dispose();
  }

  String get _otp => _controllers.map((c) => c.text).join();
  bool get _isOtpComplete => _otp.length == 6;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: Text('Confirm Delivery — Order #${widget.order.id}'),
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSizes.paddingLarge),
              
              // Instruction text
              const Text(
                'Ask the outlet to share their OTP with you. Enter it below to confirm delivery.',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textPrimary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: AppSizes.paddingLarge),
              
              // Outlet information card
              Container(
                padding: const EdgeInsets.all(AppSizes.paddingMedium),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Delivery Address',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.order.deliveryAddress,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Customer: ${widget.order.customerName}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: AppSizes.paddingLarge * 2),
              
              // OTP Input
              AnimatedBuilder(
                animation: _shakeAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(_shakeAnimation.value, 0),
                    child: Column(
                      children: [
                        const Text(
                          'Enter 6-digit OTP',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: AppSizes.paddingLarge),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(6, (index) => _buildOtpBox(index)),
                        ),
                      ],
                    ),
                  );
                },
              ),
              
              // Error message
              if (_errorMessage != null) ...[
                const SizedBox(height: AppSizes.paddingMedium),
                Text(
                  _errorMessage!,
                  style: const TextStyle(
                    color: AppColors.error,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              
              // Attempts counter
              if (_remainingAttempts != null) ...[
                const SizedBox(height: AppSizes.paddingSmall),
                Text(
                  '$_remainingAttempts attempt(s) remaining. OTP will be locked after 0 attempts.',
                  style: const TextStyle(
                    color: AppColors.error,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              
              const Spacer(),
              
              // Confirm button
              ElevatedButton(
                onPressed: _isOtpComplete && !_isLoading ? _confirmDelivery : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                  ),
                  elevation: 2,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Confirm Delivery',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              
              const SizedBox(height: AppSizes.paddingMedium),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOtpBox(int index) {
    return Container(
      width: 45,
      height: 55,
      decoration: BoxDecoration(
        border: Border.all(
          color: _focusNodes[index].hasFocus 
              ? AppColors.primary 
              : AppColors.border,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        color: AppColors.surface,
      ),
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        decoration: const InputDecoration(
          counterText: '',
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
        onChanged: (value) {
          if (value.isNotEmpty) {
            // Move to next box
            if (index < 5) {
              _focusNodes[index + 1].requestFocus();
            } else {
              _focusNodes[index].unfocus();
            }
          } else if (value.isEmpty && index > 0) {
            // Move to previous box on backspace
            _focusNodes[index - 1].requestFocus();
          }
          setState(() {});
        },
        onTap: () {
          // Clear error when user starts typing
          if (_errorMessage != null) {
            setState(() {
              _errorMessage = null;
            });
          }
        },
      ),
    );
  }

  void _confirmDelivery() async {
    // Check internet connectivity first
    // In a real app, use connectivity_plus package
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final orderProvider = Provider.of<OrderProvider>(context, listen: false);
      final result = await orderProvider.confirmDelivery(widget.order.id, _otp);

      if (result['success'] == true) {
        // Navigate to success screen
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => DeliverySuccessScreen(
                order: widget.order,
                deliveryTimestamp: DateTime.now(),
              ),
            ),
          );
        }
      } else {
        // Handle different error types
        final errorType = result['error_type'];
        
        if (errorType == 'incorrect') {
          _remainingAttempts = result['remaining_attempts'] ?? 0;
          _clearOtpBoxes();
          _shakeOtpBoxes();
          _focusNodes[0].requestFocus();
        } else if (errorType == 'expired') {
          _clearOtpBoxes();
        } else if (errorType == 'locked') {
          _showLockedDialog();
          return;
        } else if (errorType == 'already_delivered') {
          _showAlreadyDeliveredDialog();
          return;
        }
        
        setState(() {
          _errorMessage = result['message'];
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Network error. Please check your connection.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _clearOtpBoxes() {
    for (var controller in _controllers) {
      controller.clear();
    }
    setState(() {});
  }

  void _shakeOtpBoxes() {
    _shakeController.reset();
    _shakeController.repeat(reverse: true);
    
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        _shakeController.stop();
      }
    });
  }

  void _showLockedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('OTP Locked'),
        content: const Text(
          'Maximum attempts reached. OTP is locked. Please contact the warehouse to resolve this delivery.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Go back to order detail
            },
            child: const Text(
              'Contact Warehouse',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  void _showAlreadyDeliveredDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Already Delivered'),
        content: const Text(
          'This order has already been delivered.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Go back to order detail
            },
            child: const Text(
              'OK',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}