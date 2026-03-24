import 'package:flutter/material.dart';
import '../../models/return.dart';
import '../../services/api_service.dart';

class OutletStockScreen extends StatefulWidget {
  const OutletStockScreen({super.key});

  @override
  State<OutletStockScreen> createState() => _OutletStockScreenState();
}

class _OutletStockScreenState extends State<OutletStockScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedStatus = 'All';
  DateTime? _fromDate;
  DateTime? _toDate;
  
  List<ReturnItem> _returns = [];
  ReturnStats? _stats;
  bool _isLoading = true;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _initializeDates();
    _loadReturns();
  }

  void _initializeDates() {
    final now = DateTime.now();
    _fromDate = DateTime(now.year, now.month, 1); // First day of current month
    _toDate = now; // Today
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: RefreshIndicator(
        onRefresh: _refreshReturns,
        child: Column(
          children: [
            _buildStatsCard(),
            _buildFilterSection(),
            Expanded(
              child: _buildReturnsTable(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Text(
                'Returns Dashboard',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              if (_isRefreshing)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildOverviewCard(
                  'Total Returns',
                  _stats?.totalReturns.toString() ?? '0',
                  Colors.blue,
                  Icons.assignment_return,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildOverviewCard(
                  'Pending',
                  _stats?.pendingCount.toString() ?? '0',
                  Colors.orange,
                  Icons.pending_actions,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildOverviewCard(
                  'Approved',
                  _stats?.approvedCount.toString() ?? '0',
                  Colors.green,
                  Icons.check_circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildOverviewCard(
                  'Total Credits',
                  '₹${_stats?.totalCreditAmount.toStringAsFixed(0) ?? '0'}',
                  Colors.purple,
                  Icons.account_balance_wallet,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewCard(String title, String count, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            count,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Container(
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
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search returns...',
                hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
                prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
              ),
              onChanged: (value) => _filterReturns(),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedStatus,
                      isExpanded: true,
                      items: ['All', 'Pending', 'Approved', 'Rejected']
                          .map((status) => DropdownMenuItem(
                                value: status,
                                child: Text(status, style: const TextStyle(fontSize: 14)),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedStatus = value!;
                        });
                        _filterReturns();
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _selectDate(true),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 8),
                        Text(
                          _fromDate != null
                              ? '${_fromDate!.day}/${_fromDate!.month}/${_fromDate!.year}'
                              : 'From Date',
                          style: TextStyle(
                            color: _fromDate != null ? Colors.black : Colors.grey[500],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: () => _selectDate(false),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 8),
                        Text(
                          _toDate != null
                              ? '${_toDate!.day}/${_toDate!.month}/${_toDate!.year}'
                              : 'To Date',
                          style: TextStyle(
                            color: _toDate != null ? Colors.black : Colors.grey[500],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReturnsTable() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_returns.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_return, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No returns found',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Text(
                  'Recent Returns',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '${_returns.length} returns',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Return ID', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Order No.', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Product', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Qty', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Date', style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                  rows: _returns.map((returnItem) {
                    return DataRow(
                      cells: [
                        DataCell(Text('#${returnItem.id}')),
                        DataCell(Text(returnItem.order?.orderNumber ?? 'N/A')),
                        DataCell(Text(returnItem.orderItem?.productName ?? 'N/A')),
                        DataCell(Text('${returnItem.returnedQty} ${returnItem.orderItem?.uom ?? ''}')),
                        DataCell(_buildStatusChip(returnItem.status)),
                        DataCell(Text('${returnItem.createdAt.day}/${returnItem.createdAt.month}/${returnItem.createdAt.year}')),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String text;
    
    switch (status.toLowerCase()) {
      case 'pending':
        color = Colors.orange;
        text = 'PENDING';
        break;
      case 'approved':
        color = Colors.green;
        text = 'APPROVED';
        break;
      case 'rejected':
        color = Colors.red;
        text = 'REJECTED';
        break;
      default:
        color = Colors.grey;
        text = status.toUpperCase();
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }

  Future<void> _loadReturns() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await ApiService().getOutletReturns(
        search: _searchController.text.isEmpty ? null : _searchController.text,
        status: _selectedStatus == 'All' ? null : _selectedStatus.toLowerCase(),
        dateFrom: _fromDate?.toIso8601String().split('T')[0],
        dateTo: _toDate?.toIso8601String().split('T')[0],
      );
      
      setState(() {
        _returns = result['returns'] ?? [];
        _stats = result['stats'];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading returns: $e')),
        );
      }
    }
  }

  Future<void> _refreshReturns() async {
    setState(() {
      _isRefreshing = true;
    });
    
    await _loadReturns();
    
    setState(() {
      _isRefreshing = false;
    });
  }

  void _filterReturns() {
    _loadReturns();
  }

  Future<void> _selectDate(bool isFromDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    
    if (picked != null) {
      setState(() {
        if (isFromDate) {
          _fromDate = picked;
        } else {
          _toDate = picked;
        }
      });
      _filterReturns();
    }
  }

}