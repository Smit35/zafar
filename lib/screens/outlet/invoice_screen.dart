import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../../models/order.dart';
import '../../services/api_service.dart';

class InvoiceScreen extends StatefulWidget {
  final String orderId;

  const InvoiceScreen({super.key, required this.orderId});

  @override
  State<InvoiceScreen> createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends State<InvoiceScreen> {
  final ApiService _apiService = ApiService();
  Order? _order;
  bool _isLoading = true;
  bool _isDownloading = false;
  bool _isSharing = false;

  @override
  void initState() {
    super.initState();
    _loadOrderDetails();
  }

  Future<void> _loadOrderDetails() async {
    try {
      final response = await _apiService.getOutletOrderDetails(widget.orderId);
      if (response['success'] && mounted) {
        setState(() {
          _order = response['order'];
          _isLoading = false;
        });
      } else if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Failed to load order details'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _getOutletAddress() {
    if (_order?.outlet == null) return '';
    final outlet = _order!.outlet!;
    final parts = <String>[];
    if (outlet.addressLine1.isNotEmpty) parts.add(outlet.addressLine1);
    if (outlet.addressLine2.isNotEmpty) parts.add(outlet.addressLine2);
    if (outlet.city.isNotEmpty) parts.add(outlet.city);
    if (outlet.state.isNotEmpty) parts.add(outlet.state);
    if (outlet.pinCode.isNotEmpty) parts.add(outlet.pinCode);
    return parts.join(', ');
  }

  Future<void> _generateAndSharePdf() async {
    if (_order == null) return;

    setState(() => _isSharing = true);

    try {
      final pdf = pw.Document();
      
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(20),
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'ZAFAR',
                      style: pw.TextStyle(
                        fontSize: 28,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.orange600,
                      ),
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          'INVOICE',
                          style: pw.TextStyle(
                            fontSize: 24,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.Text(
                          'Invoice Copy - ${_order!.orderNumber}',
                          style: const pw.TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
                
                pw.SizedBox(height: 30),
                
                // Order Details Row
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Order No: ${_order!.orderNumber}',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                        pw.SizedBox(height: 5),
                        pw.Text(
                          'Order Date: ${DateFormat('dd/MM/yyyy').format(_order!.createdAt)}',
                        ),
                        if (_order!.dispatchDate != null)
                          pw.Text(
                            'Dispatch Date: ${DateFormat('dd/MM/yyyy').format(_order!.dispatchDate!)}',
                          ),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Outlet Details:',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                        pw.SizedBox(height: 5),
                        pw.Text(_order!.outlet?.outletName ?? ''),
                        pw.Text(_getOutletAddress()),
                        if (_order!.outlet?.gstNumber?.isNotEmpty == true)
                          pw.Text('GST: ${_order!.outlet!.gstNumber}'),
                      ],
                    ),
                  ],
                ),
                
                pw.SizedBox(height: 30),
                
                // Table Header
                pw.Container(
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey),
                    color: PdfColors.grey100,
                  ),
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Row(
                    children: [
                      pw.Expanded(flex: 3, child: pw.Text('Product', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      pw.Expanded(flex: 1, child: pw.Text('UOM', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      pw.Expanded(flex: 1, child: pw.Text('Qty', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      pw.Expanded(flex: 1, child: pw.Text('Price', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      pw.Expanded(flex: 1, child: pw.Text('CGST', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      pw.Expanded(flex: 1, child: pw.Text('SGST', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      pw.Expanded(flex: 1, child: pw.Text('Total', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                    ],
                  ),
                ),
                
                // Table Rows
                ..._order!.items.map((item) => pw.Container(
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey),
                  ),
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Row(
                    children: [
                      pw.Expanded(flex: 3, child: pw.Text(item.productName)),
                      pw.Expanded(flex: 1, child: pw.Text(item.uom)),
                      pw.Expanded(flex: 1, child: pw.Text(item.qtyOrdered.toStringAsFixed(3))),
                      pw.Expanded(flex: 1, child: pw.Text('₹${item.unitPrice.toStringAsFixed(2)}')),
                      pw.Expanded(flex: 1, child: pw.Text('₹${item.cgstAmount.toStringAsFixed(2)}')),
                      pw.Expanded(flex: 1, child: pw.Text('₹${item.sgstAmount.toStringAsFixed(2)}')),
                      pw.Expanded(flex: 1, child: pw.Text('₹${item.lineTotal.toStringAsFixed(2)}')),
                    ],
                  ),
                )).toList(),
                
                pw.SizedBox(height: 20),
                
                // Summary
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.end,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text('Subtotal: ₹${_order!.subtotal.toStringAsFixed(2)}'),
                        pw.Text('CGST: ₹${_order!.cgstAmount.toStringAsFixed(2)}'),
                        pw.Text('SGST: ₹${_order!.sgstAmount.toStringAsFixed(2)}'),
                        pw.SizedBox(height: 5),
                        pw.Text(
                          'Grand Total: ₹${_order!.grandTotal.toStringAsFixed(2)}',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                  ],
                ),
                
                pw.SizedBox(height: 30),
                
                // Payment Information
                pw.Container(
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey),
                    color: PdfColors.grey50,
                  ),
                  padding: const pw.EdgeInsets.all(15),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Payment Information',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14),
                      ),
                      pw.SizedBox(height: 5),
                      pw.Text('Payment Method: ${_order!.paymentMethod.toUpperCase()}'),
                      pw.Text('Payment Status: ${_order!.paymentStatus.toUpperCase()}'),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      );

      final bytes = await pdf.save();
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/invoice_${_order!.orderNumber}.pdf');
      await file.writeAsBytes(bytes);

      await Share.shareXFiles([XFile(file.path)], text: 'Invoice for Order ${_order!.orderNumber}');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isSharing = false);
    }
  }

  Future<void> _downloadPdf() async {
    if (_order == null) return;

    setState(() => _isDownloading = true);

    try {
      final pdf = pw.Document();
      
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(20),
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'ZAFAR',
                      style: pw.TextStyle(
                        fontSize: 28,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.orange600,
                      ),
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          'INVOICE',
                          style: pw.TextStyle(
                            fontSize: 24,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.Text(
                          'Invoice Copy - ${_order!.orderNumber}',
                          style: const pw.TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
                
                pw.SizedBox(height: 30),
                
                // Order Details Row
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Order No: ${_order!.orderNumber}',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                        pw.SizedBox(height: 5),
                        pw.Text(
                          'Order Date: ${DateFormat('dd/MM/yyyy').format(_order!.createdAt)}',
                        ),
                        if (_order!.dispatchDate != null)
                          pw.Text(
                            'Dispatch Date: ${DateFormat('dd/MM/yyyy').format(_order!.dispatchDate!)}',
                          ),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Outlet Details:',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                        pw.SizedBox(height: 5),
                        pw.Text(_order!.outlet?.outletName ?? ''),
                        pw.Text(_getOutletAddress()),
                        if (_order!.outlet?.gstNumber?.isNotEmpty == true)
                          pw.Text('GST: ${_order!.outlet!.gstNumber}'),
                      ],
                    ),
                  ],
                ),
                
                pw.SizedBox(height: 30),
                
                // Table Header
                pw.Container(
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey),
                    color: PdfColors.grey100,
                  ),
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Row(
                    children: [
                      pw.Expanded(flex: 3, child: pw.Text('Product', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      pw.Expanded(flex: 1, child: pw.Text('UOM', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      pw.Expanded(flex: 1, child: pw.Text('Qty', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      pw.Expanded(flex: 1, child: pw.Text('Price', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      pw.Expanded(flex: 1, child: pw.Text('CGST', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      pw.Expanded(flex: 1, child: pw.Text('SGST', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      pw.Expanded(flex: 1, child: pw.Text('Total', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                    ],
                  ),
                ),
                
                // Table Rows
                ..._order!.items.map((item) => pw.Container(
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey),
                  ),
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Row(
                    children: [
                      pw.Expanded(flex: 3, child: pw.Text(item.productName)),
                      pw.Expanded(flex: 1, child: pw.Text(item.uom)),
                      pw.Expanded(flex: 1, child: pw.Text(item.qtyOrdered.toStringAsFixed(3))),
                      pw.Expanded(flex: 1, child: pw.Text('₹${item.unitPrice.toStringAsFixed(2)}')),
                      pw.Expanded(flex: 1, child: pw.Text('₹${item.cgstAmount.toStringAsFixed(2)}')),
                      pw.Expanded(flex: 1, child: pw.Text('₹${item.sgstAmount.toStringAsFixed(2)}')),
                      pw.Expanded(flex: 1, child: pw.Text('₹${item.lineTotal.toStringAsFixed(2)}')),
                    ],
                  ),
                )).toList(),
                
                pw.SizedBox(height: 20),
                
                // Summary
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.end,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text('Subtotal: ₹${_order!.subtotal.toStringAsFixed(2)}'),
                        pw.Text('CGST: ₹${_order!.cgstAmount.toStringAsFixed(2)}'),
                        pw.Text('SGST: ₹${_order!.sgstAmount.toStringAsFixed(2)}'),
                        pw.SizedBox(height: 5),
                        pw.Text(
                          'Grand Total: ₹${_order!.grandTotal.toStringAsFixed(2)}',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                  ],
                ),
                
                pw.SizedBox(height: 30),
                
                // Payment Information
                pw.Container(
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey),
                    color: PdfColors.grey50,
                  ),
                  padding: const pw.EdgeInsets.all(15),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Payment Information',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14),
                      ),
                      pw.SizedBox(height: 5),
                      pw.Text('Payment Method: ${_order!.paymentMethod.toUpperCase()}'),
                      pw.Text('Payment Status: ${_order!.paymentStatus.toUpperCase()}'),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      );

      final bytes = await pdf.save();
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/invoice_${_order!.orderNumber}.pdf');
      await file.writeAsBytes(bytes);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF downloaded to Downloads folder: invoice_${_order!.orderNumber}.pdf'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error downloading PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isDownloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blueGrey[600],
          foregroundColor: Colors.white,
          title: const Text('Invoice'),
          elevation: 0,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_order == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blueGrey[600],
          foregroundColor: Colors.white,
          title: const Text('Invoice'),
          elevation: 0,
        ),
        body: const Center(
          child: Text(
            'Order not found',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.blueGrey[600],
        foregroundColor: Colors.white,
        title: const Text('Invoice'),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _isDownloading || _isSharing ? null : _downloadPdf,
            icon: _isDownloading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.download),
            tooltip: 'Download PDF',
          ),
          IconButton(
            onPressed: _isDownloading || _isSharing ? null : _generateAndSharePdf,
            icon: _isSharing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.share),
            tooltip: 'Share PDF',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'ZAFAR',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange[600],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'INVOICE',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Order No.',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        '${_order!.orderNumber}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 30),
              
              // Order Details Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order Details',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Order Date: ${DateFormat('dd/MM/yyyy').format(_order!.createdAt)}',
                          style: const TextStyle(fontSize: 14),
                        ),
                        if (_order!.dispatchDate != null) ...[
                          const SizedBox(height: 5),
                          Text(
                            'Dispatch Date: ${DateFormat('dd/MM/yyyy').format(_order!.dispatchDate!)}',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Outlet Details:',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _order!.outlet?.outletName ?? '',
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          _getOutletAddress(),
                          style: const TextStyle(fontSize: 14),
                        ),
                        if (_order!.outlet?.gstNumber?.isNotEmpty == true) ...[
                          const SizedBox(height: 5),
                          Text(
                            'GST: ${_order!.outlet!.gstNumber}',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 30),
              
              // Table
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    // Table Header
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Expanded(flex: 3, child: Text('Product', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10))),
                          const Expanded(flex: 1, child: Text('UOM', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10))),
                          const Expanded(flex: 1, child: Text('Qty', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10), textAlign: TextAlign.center)),
                          const Expanded(flex: 2, child: Text('Price', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10), textAlign: TextAlign.right)),
                          const Expanded(flex: 2, child: Text('CGST', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10), textAlign: TextAlign.right)),
                          const Expanded(flex: 2, child: Text('SGST', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10), textAlign: TextAlign.right)),
                          const Expanded(flex: 2, child: Text('Total', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10), textAlign: TextAlign.right)),
                        ],
                      ),
                    ),
                    
                    // Table Rows
                    ..._order!.items.asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;
                      final isLast = index == _order!.items.length - 1;
                      
                      return Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: isLast ? BorderSide.none : BorderSide(color: Colors.grey[300]!),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3, 
                              child: Text(
                                item.productName,
                                style: const TextStyle(fontSize: 9),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Expanded(
                              flex: 1, 
                              child: Text(
                                item.uom,
                                style: const TextStyle(fontSize: 9),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Expanded(
                              flex: 1, 
                              child: Text(
                                item.qtyOrdered.toStringAsFixed(0),
                                style: const TextStyle(fontSize: 9),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Expanded(
                              flex: 2, 
                              child: Text(
                                '₹${item.unitPrice.toStringAsFixed(0)}',
                                style: const TextStyle(fontSize: 9),
                                textAlign: TextAlign.right,
                              ),
                            ),
                            Expanded(
                              flex: 2, 
                              child: Text(
                                '₹${item.cgstAmount.toStringAsFixed(0)}',
                                style: const TextStyle(fontSize: 9),
                                textAlign: TextAlign.right,
                              ),
                            ),
                            Expanded(
                              flex: 2, 
                              child: Text(
                                '₹${item.sgstAmount.toStringAsFixed(0)}',
                                style: const TextStyle(fontSize: 9),
                                textAlign: TextAlign.right,
                              ),
                            ),
                            Expanded(
                              flex: 2, 
                              child: Text(
                                '₹${item.lineTotal.toStringAsFixed(0)}',
                                style: const TextStyle(fontSize: 9),
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Summary
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Subtotal:',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                        Text(
                          '₹${_order!.subtotal.toStringAsFixed(0)}',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'CGST:',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                        Text(
                          '₹${_order!.cgstAmount.toStringAsFixed(0)}',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'SGST:',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                        Text(
                          '₹${_order!.sgstAmount.toStringAsFixed(0)}',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Divider(thickness: 1),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Grand Total:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange[700],
                          ),
                        ),
                        Text(
                          '₹${_order!.grandTotal.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange[700],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Payment Information
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Payment Information',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Payment Method: ${_order!.paymentMethod.toUpperCase()}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Payment Status: ${_order!.paymentStatus.toUpperCase()}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}