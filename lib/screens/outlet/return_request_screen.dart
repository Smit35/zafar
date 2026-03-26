import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/api_service.dart';
import 'outlet_stock_screen.dart';

class ReturnRequestScreen extends StatefulWidget {
  final int orderId;
  final String orderNumber;

  const ReturnRequestScreen({
    super.key,
    required this.orderId,
    required this.orderNumber,
  });

  @override
  State<ReturnRequestScreen> createState() => _ReturnRequestScreenState();
}

class _ReturnRequestScreenState extends State<ReturnRequestScreen> {
  final ApiService _apiService = ApiService();
  final ImagePicker _picker = ImagePicker();
  
  Map<String, dynamic>? _orderDetails;
  List<Map<String, dynamic>> _orderItems = [];
  List<Map<String, dynamic>> _returnItems = [];
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _errorMessage;

  final List<String> _returnReasons = [
    'damaged',
    'expired',
    'wrong_product',
    'quality_issue',
    'other',
  ];

  final Map<String, String> _reasonLabels = {
    'damaged': 'Product Damaged/Defective',
    'expired': 'Near Expiry/Expired',
    'wrong_product': 'Received wrong item',
    'quality_issue': 'Quality issue',
    'other': 'Other Reason',
  };

  @override
  void initState() {
    super.initState();
    _loadOrderDetails();
  }

  Future<void> _loadOrderDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _apiService.getOrderForReturn(widget.orderId);
      
      if (response['success']) {
        setState(() {
          _orderDetails = response['order'];
          _orderItems = List<Map<String, dynamic>>.from(response['items'] ?? []);
          
          // Initialize return items for each order item
          _returnItems = _orderItems.map((item) => {
            'order_item_id': item['id'],
            'product_name': item['product_name'],
            'sku': item['sku'],
            'qty_ordered': double.parse(item['qty_ordered'].toString()),
            'returned_qty': 0.0,
            'rejection_reason': _returnReasons.first,
            'outlet_remarks': '',
            'photos': <File>[],
            'unit_price': item['unit_price'],
          }).toList();
          
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response['message'] ?? 'Failed to load order details';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading order: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Return Request - ${widget.orderNumber}',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.orange[600],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildErrorState()
              : _buildReturnForm(),
      bottomNavigationBar: _isLoading || _errorMessage != null
          ? null
          : _buildSubmitButton(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
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
              _errorMessage!,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadOrderDetails,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReturnForm() {
    return Column(
      children: [
        // Order info card
        _buildOrderInfoCard(),
        
        // Items list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _returnItems.length,
            itemBuilder: (context, index) {
              return _buildReturnItemCard(index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildOrderInfoCard() {
    if (_orderDetails == null) return const SizedBox();

    final hoursRemaining = _orderDetails!['hours_remaining']?.toDouble() ?? 0.0;
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Order Information',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: hoursRemaining > 12 
                      ? Colors.green.withOpacity(0.1)
                      : hoursRemaining > 6 
                          ? Colors.orange.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${hoursRemaining.round()}h remaining',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: hoursRemaining > 12 
                        ? Colors.green[700]
                        : hoursRemaining > 6 
                            ? Colors.orange[700]
                            : Colors.red[700],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Order #${_orderDetails!['order_number']}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Total: ₹${_orderDetails!['grand_total']}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          Text(
            'Delivered: ${_orderDetails!['delivered_at']}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReturnItemCard(int index) {
    final item = _returnItems[index];
    final maxQty = item['qty_ordered'];
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product info
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['product_name'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'SKU: ${item['sku']} • Max Qty: ${maxQty.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Return quantity
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Return Quantity',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: '0',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        onChanged: (value) {
                          final qty = double.tryParse(value) ?? 0.0;
                          setState(() {
                            item['returned_qty'] = qty;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Reason',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: item['rejection_reason'],
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        items: _returnReasons.map((reason) {
                          return DropdownMenuItem(
                            value: reason,
                            child: Text(
                              _reasonLabels[reason] ?? reason,
                              style: const TextStyle(fontSize: 14),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            item['rejection_reason'] = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Conditional Detailed Remarks for "other" reason
            if (item['rejection_reason'] == 'other')
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Detailed Remarks *',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: 'Please describe the issue in detail...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      contentPadding: const EdgeInsets.all(12),
                    ),
                    onChanged: (value) {
                      setState(() {
                        item['outlet_remarks'] = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            
            const SizedBox(height: 16),
            
            // Evidence photos
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Evidence Photos *',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: (item['photos'] as List).length < 5 ? () => _pickImage(index) : null,
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.orange[600],
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      icon: const Icon(Icons.add_a_photo, size: 18),
                      label: Text('Add Photo (${(item['photos'] as List).length}/5)'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (item['photos'].isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey[300]!,
                        style: BorderStyle.solid,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.camera_alt_outlined,
                          size: 32,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Add photos as evidence',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ...item['photos'].map<Widget>((photo) {
                        final photoIndex = item['photos'].indexOf(photo);
                        return Stack(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                image: DecorationImage(
                                  image: FileImage(photo),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 4,
                              right: 4,
                              child: GestureDetector(
                                onTap: () => _removeImage(index, photoIndex),
                                child: Container(
                                  width: 20,
                                  height: 20,
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    final hasItemsToReturn = _returnItems.any((item) => item['returned_qty'] > 0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: hasItemsToReturn && !_isSubmitting 
              ? _submitReturnRequest 
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange[600],
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: _isSubmitting
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text(
                  'Submit Return Request',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }

  Future<void> _pickImage(int itemIndex) async {
    final photos = _returnItems[itemIndex]['photos'] as List<File>;
    
    if (photos.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Maximum 5 photos allowed per item'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          photos.add(File(image.path));
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _removeImage(int itemIndex, int photoIndex) {
    setState(() {
      (_returnItems[itemIndex]['photos'] as List<File>).removeAt(photoIndex);
    });
  }

  Future<void> _submitReturnRequest() async {
    // Validate quantities and requirements before submission
    String? validationError = _validateReturnRequest();
    if (validationError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(validationError),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    setState(() {
      _isSubmitting = true;
    });

    try {
      // Filter only items that have return quantity > 0
      final itemsToReturn = _returnItems.where((item) => 
        item['returned_qty'] > 0
      ).map((item) => {
        'order_item_id': item['order_item_id'],
        'returned_qty': item['returned_qty'],
        'rejection_reason': item['rejection_reason'],
        if (item['rejection_reason'] == 'other')
          'outlet_remarks': item['outlet_remarks'],
      }).toList();

      // Collect all photos
      List<File> allPhotos = [];
      for (var item in _returnItems) {
        if (item['returned_qty'] > 0) {
          allPhotos.addAll(item['photos'] as List<File>);
        }
      }

      final response = await _apiService.submitReturnRequest(
        orderId: widget.orderId,
        items: itemsToReturn,
        photos: allPhotos,
      );

      if (response['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Return request submitted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Failed to submit return request'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error submitting return: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  String? _validateReturnRequest() {
    final itemsWithQty = _returnItems.where((item) => item['returned_qty'] > 0).toList();
    
    if (itemsWithQty.isEmpty) {
      return 'Please select at least one item to return';
    }
    
    for (var item in itemsWithQty) {
      final qty = item['returned_qty'] as double;
      final maxQty = item['qty_ordered'] as double;
      
      // Check quantity limit
      if (qty > maxQty) {
        return 'Return quantity must be less than or equal to $maxQty';
      }
      
      // Check photos requirement (at least 1, max 5)
      final photos = item['photos'] as List<File>;
      if (photos.isEmpty) {
        return 'At least one photo is required for each returned item';
      }
      
      // Check "other" reason remarks requirement
      if (item['rejection_reason'] == 'other' && 
          (item['outlet_remarks'] == null || item['outlet_remarks'].toString().trim().isEmpty)) {
        return 'Detailed remarks are required when "Other Reason" is selected';
      }
    }
    
    return null;
  }
}