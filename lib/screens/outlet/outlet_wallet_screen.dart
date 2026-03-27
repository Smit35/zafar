import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/wallet_transaction.dart';
import '../../services/api_service.dart';
import 'outlet_notification_screen.dart';

class OutletWalletScreen extends StatefulWidget {
  const OutletWalletScreen({super.key});

  @override
  State<OutletWalletScreen> createState() => _OutletWalletScreenState();
}

class _OutletWalletScreenState extends State<OutletWalletScreen> {
  final ApiService _apiService = ApiService();
  
  List<WalletTransaction> _transactions = [];
  bool _isLoading = false;
  DateTime? _fromDate;
  DateTime? _toDate;
  String? _selectedType;
  
  // API data for balance
  double _walletBalance = 0.00;
  double _totalCredited = 0.00;
  double _totalDebited = 0.00;
  
  @override
  void initState() {
    super.initState();
    _initializeDates();
    _loadTransactions();
  }
  
  void _initializeDates() {
    final now = DateTime.now();
    _fromDate = DateTime(now.year, now.month, 1); // First day of current month
    _toDate = now; // Today
  }
  
  Future<void> _loadTransactions() async {
    setState(() => _isLoading = true);
    
    try {
      final dateFrom = _fromDate?.toIso8601String().split('T')[0];
      final dateTo = _toDate?.toIso8601String().split('T')[0];
      
      final response = await _apiService.getWalletTransactions(
        type: _selectedType,
        dateFrom: dateFrom,
        dateTo: dateTo,
      );
      
      if (response['success'] && mounted) {
        setState(() {
          _transactions = response['transactions'] ?? [];
          
          // Update balance data from API response
          if (response['balance'] != null) {
            final balance = response['balance'];
            _walletBalance = double.parse(balance['balance']?.toString() ?? '0');
            _totalCredited = double.parse(balance['total_credited']?.toString() ?? '0');
            _totalDebited = double.parse(balance['total_debited']?.toString() ?? '0');
          }
        });
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Failed to load transactions'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Wallet Stats Cards
            _buildWalletStatsCards(),
            
            // Filters
            _buildFilters(),
            
            // Transaction Table
            _buildTransactionTable(),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletStatsCards() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Wallet Balance',
              '₹${_walletBalance.toStringAsFixed(2)}',
              Icons.account_balance_wallet,
              Colors.blueGrey[600]!,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Total Credited',
              '₹${_totalCredited.toStringAsFixed(2)}',
              Icons.trending_up,
              Colors.green[600]!,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Total Debited',
              '₹${_totalDebited.toStringAsFixed(2)}',
              Icons.trending_down,
              Colors.red[600]!,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String amount, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row(
          //   children: [
          //     Icon(icon, color: color, size: 20),
          //     const SizedBox(width: 8),
          //     IconButton(
          //       onPressed: () {
          //         Navigator.push(
          //           context,
          //           MaterialPageRoute(
          //             builder: (context) => const OutletNotificationScreen(),
          //           ),
          //         );
          //       },
          //       icon: const Icon(
          //         Icons.notifications_outlined,
          //         color: Colors.grey,
          //         size: 18,
          //       ),
          //     ),
          //   ],
          // ),
          // const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            amount,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filters',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Column(
            children: [
              // Date Row
              Row(
                children: [
                  // From Date
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'From Date',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () => _selectFromDate(),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.date_range, size: 20, color: Colors.grey[600]),
                                const SizedBox(width: 8),
                                Text(
                                  _fromDate != null 
                                      ? DateFormat('dd/MM/yyyy').format(_fromDate!)
                                      : 'Select Date',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: _fromDate != null ? Colors.black87 : Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // To Date
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'To Date',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () => _selectToDate(),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.date_range, size: 20, color: Colors.grey[600]),
                                const SizedBox(width: 8),
                                Text(
                                  _toDate != null 
                                      ? DateFormat('dd/MM/yyyy').format(_toDate!)
                                      : 'Select Date',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: _toDate != null ? Colors.black87 : Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Type Dropdown Row
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Transaction Type',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedType,
                        hint: Text(
                          'Select Type',
                          style: TextStyle(color: Colors.grey[600], fontSize: 14),
                        ),
                        isExpanded: true,
                        items: [
                          const DropdownMenuItem(value: null, child: Text('All Transactions')),
                          const DropdownMenuItem(value: 'credit', child: Text('Credit Only')),
                          const DropdownMenuItem(value: 'debit', child: Text('Debit Only')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedType = value;
                          });
                          _loadTransactions();
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _selectFromDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fromDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _fromDate = picked;
      });
      _loadTransactions();
    }
  }

  Future<void> _selectToDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _toDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _toDate = picked;
      });
      _loadTransactions();
    }
  }

  Widget _buildTransactionTable() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Recent Transactions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_transactions.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'No transactions found',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ),
            )
          else
            Container(
              constraints: const BoxConstraints(minHeight: 300, maxHeight: 500),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  child: DataTable(
                    columnSpacing: 20,
                    headingRowColor: WidgetStateProperty.all(Colors.grey[50]),
                    headingRowHeight: 40,
                    dataRowMinHeight: 40,
                    dataRowMaxHeight: 50,
                    columns: const [
                      DataColumn(
                        label: Text(
                          'Date',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Type',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Source',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Amount',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Balance',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Remarks',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                    ],
                    rows: _transactions.map((transaction) {
                      return DataRow(
                        cells: [
                          DataCell(
                            Text(
                              DateFormat('dd/MM/yyyy').format(transaction.createdAt),
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: transaction.isCredit ? Colors.green[50] : Colors.red[50],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                transaction.type.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: transaction.isCredit ? Colors.green[700] : Colors.red[700],
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                            Container(
                              constraints: const BoxConstraints(maxWidth: 100),
                              child: Text(
                                transaction.source.replaceAll('_', ' ').toUpperCase(),
                                style: const TextStyle(fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              '${transaction.isDebit ? '-' : ''}₹${transaction.amount.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: transaction.isCredit ? Colors.green[700] : Colors.red[700],
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              '₹${transaction.balanceAfter.toStringAsFixed(2)}',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                          DataCell(
                            Container(
                              constraints: const BoxConstraints(maxWidth: 100),
                              child: Text(
                                transaction.remarks ?? '-',
                                style: const TextStyle(fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
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

  /*Widget _buildQuickActions() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  'Withdraw Money',
                  Icons.account_balance,
                  Colors.blue,
                  () => _showWithdrawDialog(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  'View Reports',
                  Icons.analytics_outlined,
                  Colors.green,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const OutletReportScreen(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  'Payment Settings',
                  Icons.settings,
                  Colors.purple,
                  () => _showPaymentSettings(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }*/

  Widget _buildActionButton(String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionHistory() {
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
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Text(
                  'Transactions History',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    // Navigate to all transactions
                  },
                  child: Text(
                    'View All',
                    style: TextStyle(
                      color: Colors.blueGrey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ...List.generate(5, (index) => _buildTransactionItem(index)),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(int index) {
    final transactions = [
      {
        'type': 'payment',
        'title': 'Order Payment',
        'orderId': '#12348',
        'amount': 420.0,
        'time': '2 mins ago',
        'status': 'completed',
      },
      {
        'type': 'withdrawal',
        'title': 'Bank Withdrawal',
        'orderId': 'WD001',
        'amount': -5000.0,
        'time': '2 hours ago',
        'status': 'processing',
      },
      {
        'type': 'payment',
        'title': 'Order Payment',
        'orderId': '#12347',
        'amount': 280.0,
        'time': '3 hours ago',
        'status': 'completed',
      },
      {
        'type': 'commission',
        'title': 'Commission Deduction',
        'orderId': '#12346',
        'amount': -45.0,
        'time': '5 hours ago',
        'status': 'completed',
      },
      {
        'type': 'payment',
        'title': 'Order Payment',
        'orderId': '#12345',
        'amount': 650.0,
        'time': '1 day ago',
        'status': 'completed',
      },
    ];

    final transaction = transactions[index];
    final amount = transaction['amount'] as double;
    final isPositive = amount > 0;
    final type = transaction['type'] as String;
    final status = transaction['status'] as String;

    IconData icon;
    Color iconColor;
    
    switch (type) {
      case 'payment':
        icon = Icons.payment;
        iconColor = Colors.green;
        break;
      case 'withdrawal':
        icon = Icons.account_balance;
        iconColor = Colors.blue;
        break;
      case 'commission':
        icon = Icons.percent;
        iconColor = Colors.blueGrey[600]!;
        break;
      default:
        icon = Icons.account_balance_wallet;
        iconColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction['title'] as String,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      transaction['orderId'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: status == 'completed' 
                            ? Colors.green.withOpacity(0.1)
                            : Colors.blueGrey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        status.toUpperCase(),
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w600,
                          color: status == 'completed' ? Colors.green : Colors.blueGrey[600]!,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  transaction['time'] as String,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isPositive ? '+' : ''}₹${amount.abs().toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isPositive ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /*Widget _buildFinancialSummary() {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Financial Summary (This Month)',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          _buildSummaryRow('Total Revenue', '₹45,230', Colors.green),
          _buildSummaryRow('Commission Paid', '₹2,261.50', Colors.orange),
          _buildSummaryRow('Total Withdrawals', '₹40,000', Colors.blue),
          const Divider(height: 24),
          _buildSummaryRow('Net Earnings', '₹2,968.50', Colors.black87, isBold: true),
        ],
      ),
    );
  }*/

  Widget _buildSummaryRow(String label, String amount, Color color, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isBold ? Colors.black87 : Colors.grey[700],
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _showWithdrawDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Withdraw Money'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Available Balance: ₹25,480.50'),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Withdrawal Amount',
                border: OutlineInputBorder(),
                prefixText: '₹',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Bank Account',
                border: OutlineInputBorder(),
                suffixText: '****1234',
              ),
              enabled: false,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueGrey[600],
            ),
            child: const Text('Withdraw', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showPaymentSettings() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Payment Settings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.account_balance),
              title: const Text('Bank Account'),
              subtitle: const Text('HDFC Bank - ****1234'),
              trailing: const Icon(Icons.edit),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.schedule),
              title: const Text('Auto Withdrawal'),
              subtitle: const Text('Weekly - Every Monday'),
              trailing: Switch(
                value: true,
                onChanged: (value) {},
              ),
            ),
            ListTile(
              leading: const Icon(Icons.security),
              title: const Text('Transaction PIN'),
              subtitle: const Text('Change your transaction PIN'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.receipt_long),
              title: const Text('Tax Information'),
              subtitle: const Text('GST & PAN details'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}