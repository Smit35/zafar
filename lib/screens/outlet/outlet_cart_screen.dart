import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../models/cart_models.dart';

class OutletCartScreen extends StatefulWidget {
  const OutletCartScreen({super.key});

  @override
  State<OutletCartScreen> createState() => _OutletCartScreenState();
}

class _OutletCartScreenState extends State<OutletCartScreen> {
  final ApiService _apiService = ApiService();
  
  List<CartItem> _cartItems = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCartItems();
  }

  Future<void> _loadCartItems() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _apiService.getCartItems();
      
      if (result['success']) {
        setState(() {
          _cartItems = result['items'] as List<CartItem>;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = result['message'];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load cart: $e';
        _isLoading = false;
      });
    }
  }


  Future<void> _updateQuantity(CartItem item, int newQuantity) async {
    if (newQuantity <= 0) {
      await _removeFromCart(item);
      return;
    }

    final result = await _apiService.updateCartItem(item.id, newQuantity);
    
    if (result['success']) {
      _loadCartItems(); // Reload cart
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update quantity: ${result['message']}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _removeFromCart(CartItem item) async {
    final result = await _apiService.removeFromCart(item.id);
    
    if (result['success']) {
      _loadCartItems(); // Reload cart
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${item.product.name} removed from cart'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to remove item: ${result['message']}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  double get _subtotal {
    return _cartItems.fold(0, (sum, item) => sum + item.totalPrice);
  }

  double get _gstAmount {
    return _subtotal * 0.18; // Static 18% GST as requested
  }

  double get _total {
    return _subtotal + _gstAmount;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Order Cart'),
        backgroundColor: Colors.white,
        elevation: 1,
        titleTextStyle: const TextStyle(
          color: Colors.black87,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
              ),
            )
          : _errorMessage != null
              ? _buildErrorState()
              : _cartItems.isEmpty
                  ? _buildEmptyState()
                  : Column(
                      children: [
                        // Order Summary
                        Expanded(
                          child: _buildOrderSummary(),
                        ),
                        
                        // Checkout Section
                        _buildCheckoutSection(),
                      ],
                    ),
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
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Error Loading Cart',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage!,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadCartItems,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange[600],
            ),
            child: const Text(
              'Retry',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Your cart is empty',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add items from the catalog to get started',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange[600],
            ),
            child: const Text(
              'Continue Shopping',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Summary',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          
          // Cart Items
          Expanded(
            child: ListView.builder(
              itemCount: _cartItems.length,
              itemBuilder: (context, index) {
                final item = _cartItems[index];
                return _buildCartItemCard(item);
              },
            ),
          ),
          
          const Divider(thickness: 1),
          const SizedBox(height: 8),
          
          // Order Total
          _buildOrderTotal(),
        ],
      ),
    );
  }

  Widget _buildCartItemCard(CartItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Product Image
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(8),
              image: item.product.imagePath != null
                  ? DecorationImage(
                      image: NetworkImage(item.product.imageUrl),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: item.product.imagePath == null
                ? Icon(
                    Icons.fastfood,
                    color: Colors.orange[600],
                    size: 24,
                  )
                : null,
          ),
          const SizedBox(width: 12),
          
          // Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  'SKU: ${item.product.sku}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '₹${item.product.priceValue.toStringAsFixed(2)}/${item.product.uom}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          
          // Quantity Controls
          Row(
            children: [
              GestureDetector(
                onTap: () => _updateQuantity(item, item.quantity.toInt() - 1),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    Icons.remove,
                    size: 14,
                    color: Colors.orange[600],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Text(
                  item.quantity.toStringAsFixed(0),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => _updateQuantity(item, item.quantity.toInt() + 1),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    Icons.add,
                    size: 14,
                    color: Colors.orange[600],
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(width: 12),
          
          // Total Price
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹${item.totalPrice.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              GestureDetector(
                onTap: () => _removeFromCart(item),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(
                    Icons.delete,
                    size: 18,
                    color: Colors.red,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderTotal() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Subtotal:',
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
            Text(
              '₹${_subtotal.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'GST (18%):',
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
            Text(
              '₹${_gstAmount.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ],
        ),
        const Divider(thickness: 1),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Total:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Text(
              '₹${_total.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCheckoutSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Clear Cart Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Order Summary',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              TextButton.icon(
                onPressed: _cartItems.isNotEmpty ? _clearCart : null,
                icon: const Icon(Icons.clear_all, size: 16),
                label: const Text('Clear Cart'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Order Summary Stats
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Items:',
                      style: TextStyle(fontSize: 14),
                    ),
                    Text(
                      '${_cartItems.fold(0, (sum, item) => sum + item.quantity.toInt())}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 16, thickness: 0.5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Subtotal:',
                      style: TextStyle(fontSize: 14),
                    ),
                    Text(
                      '₹${_subtotal.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'GST (18%):',
                      style: TextStyle(fontSize: 14),
                    ),
                    Text(
                      '₹${_gstAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 16, thickness: 1),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Amount:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '₹${_total.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange[600],
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Place Order Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _cartItems.isNotEmpty ? _placeOrder : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange[600],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: const Text(
                'Place Order',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _clearCart() async {
    final result = await _apiService.clearCart();
    
    if (result['success']) {
      setState(() {
        _cartItems.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Cart cleared successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to clear cart: ${result['message']}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _placeOrder() async {
    // TODO: Implement place order functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Order placement functionality coming soon!'),
        backgroundColor: Colors.blue,
      ),
    );
  }
}