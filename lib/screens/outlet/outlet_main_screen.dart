import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'outlet_home_tab.dart';
import 'outlet_catalog_screen.dart';
import 'outlet_orders_tab.dart';
import 'outlet_stock_management_screen.dart';
import 'outlet_stock_screen.dart';
import 'outlet_wallet_screen.dart';
import 'outlet_profile_screen.dart';

class OutletMainScreen extends StatefulWidget {
  const OutletMainScreen({super.key});

  @override
  State<OutletMainScreen> createState() => _OutletMainScreenState();
}

class _OutletMainScreenState extends State<OutletMainScreen> {
  int _selectedIndex = 0;
  String _outletName = 'Outlet 1';
  String _ownerName = 'Owner';

  final List<Widget> _screens = [
    const OutletHomeTab(),
    const OutletCatalogScreen(),
    const OutletOrdersTab(),
    const OutletStockManagementScreen(),
    const OutletReturnScreen(),
    const OutletWalletScreen(),
  ];

  final List<String> _titles = [
    'Home',
    'Catalog',
    'Orders',
    'Stock',
    'Return',
    'Wallet',
  ];

  @override
  void initState() {
    super.initState();
    _loadOutletData();
  }

  Future<void> _loadOutletData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final outletData = prefs.getString('outlet_data');
      if (outletData != null) {
        final data = jsonDecode(outletData);
        if (mounted) {
          setState(() {
            _outletName = data['outlet_name'] ?? 'Outlet 1';
            _ownerName = data['owner_name'] ?? 'Owner';
          });
        }
      }
    } catch (e) {
      // Error loading outlet data - using default values
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(
          _titles[_selectedIndex],
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.notifications_outlined,
                color: Colors.black54,
                size: 20,
              ),
            ),
            onPressed: () {
              // Navigate to notifications
            },
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const OutletProfileScreen(),
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: Colors.blueGrey[100],
                child: Icon(
                  Icons.person,
                  color: Colors.blueGrey[600]!,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: Colors.blueGrey[600],
          unselectedItemColor: Colors.grey[600],
          selectedLabelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.normal,
          ),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.restaurant_menu_outlined),
              activeIcon: Icon(Icons.restaurant_menu),
              label: 'Catalog',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.assignment_outlined),
              activeIcon: Icon(Icons.assignment),
              label: 'Orders',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.warehouse_outlined),
              activeIcon: Icon(Icons.warehouse),
              label: 'Stock',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.inventory_outlined),
              activeIcon: Icon(Icons.inventory),
              label: 'Return',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet_outlined),
              activeIcon: Icon(Icons.account_balance_wallet),
              label: 'Wallet',
            ),
          ],
        ),
      ),
    );
  }

}