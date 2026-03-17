import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../models/menu_item.dart';
import '../../models/outlet.dart';
import '../../models/user.dart';
import '../../providers/cart_provider.dart';
import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';
import 'cart_screen.dart';

class OutletHomeScreen extends StatefulWidget {
  const OutletHomeScreen({super.key});

  @override
  State<OutletHomeScreen> createState() => _OutletHomeScreenState();
}

class _OutletHomeScreenState extends State<OutletHomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Outlet? _outlet;
  User? _user;
  bool _isLoading = true;

  final List<MenuItem> _menuItems = [
    MenuItem(
      id: '1',
      name: 'Chicken Biryani',
      description: 'Aromatic basmati rice with tender chicken pieces',
      price: 299.0,
      image: '🍛',
      category: 'Main Course',
    ),
    MenuItem(
      id: '2',
      name: 'Paneer Butter Masala',
      description: 'Creamy tomato curry with cottage cheese',
      price: 249.0,
      image: '🍛',
      category: 'Main Course',
    ),
    MenuItem(
      id: '3',
      name: 'Chicken Tikka',
      description: 'Grilled chicken marinated in spices',
      price: 199.0,
      image: '🍗',
      category: 'Starter',
    ),
    MenuItem(
      id: '4',
      name: 'Dal Makhani',
      description: 'Rich and creamy black lentil curry',
      price: 179.0,
      image: '🍲',
      category: 'Main Course',
    ),
    MenuItem(
      id: '5',
      name: 'Naan',
      description: 'Fresh baked Indian bread',
      price: 49.0,
      image: '🫓',
      category: 'Bread',
    ),
    MenuItem(
      id: '6',
      name: 'Gulab Jamun',
      description: 'Sweet milk dumplings in sugar syrup',
      price: 99.0,
      image: '🧆',
      category: 'Dessert',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadOutletData();
  }

  Future<void> _loadOutletData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final outletJson = prefs.getString('outlet_data');
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      if (outletJson != null) {
        final outletData = jsonDecode(outletJson);
        _outlet = Outlet.fromJson(outletData);
      }

      _user = authProvider.user;
    } catch (e) {
      print('Error loading outlet data: $e');
    }

    setState(() {
      _isLoading = false;
    });
  }

  List<MenuItem> get filteredItems {
    if (_searchQuery.isEmpty) {
      return _menuItems;
    }
    return _menuItems
        .where(
          (item) =>
              item.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              item.category.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.orange[600],
        foregroundColor: Colors.white,
        title: Text(_outlet?.outletName ?? _user?.name ?? 'Outlet Dashboard'),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () {
                  Navigator.of(
                    context,
                  ).push(MaterialPageRoute(builder: (_) => const CartScreen()));
                },
              ),
              Consumer<CartProvider>(
                builder: (context, cart, child) {
                  if (cart.itemCount == 0) return const SizedBox.shrink();
                  return Positioned(
                    right: 6,
                    top: 6,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        cart.itemCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await Provider.of<AuthProvider>(context, listen: false).logout();
              if (mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (_outlet != null) _buildOutletInfoCard(),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search menu items...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredItems.length,
              itemBuilder: (context, index) {
                final item = filteredItems[index];
                return _buildMenuItemCard(item);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItemCard(MenuItem item) {
    return Consumer<CartProvider>(
      builder: (context, cart, child) {
        final quantity = cart.getItemQuantity(item.id);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      item.image,
                      style: const TextStyle(fontSize: 30),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.description,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            '₹${item.price.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange[600],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              item.category,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.orange[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                if (quantity == 0)
                  ElevatedButton(
                    onPressed: () => cart.addItem(item),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange[600],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Add'),
                  )
                else
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => cart.removeItem(item.id),
                        icon: const Icon(Icons.remove_circle_outline),
                        color: Colors.orange[600],
                      ),
                      Text(
                        quantity.toString(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: () => cart.addItem(item),
                        icon: const Icon(Icons.add_circle_outline),
                        color: Colors.orange[600],
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOutletInfoCard() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[100],
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.store, color: Colors.orange[600], size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _outlet!.outletName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Owner: ${_outlet!.ownerName}',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    Text(
                      '${_outlet!.city}, ${_outlet!.state}',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _outlet!.status ? Colors.green[100] : Colors.red[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _outlet!.status ? 'Active' : 'Inactive',
                  style: TextStyle(
                    fontSize: 12,
                    color: _outlet!.status
                        ? Colors.green[700]
                        : Colors.red[700],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (_outlet!.walletBalance != null ||
              _outlet!.activeOrdersCount != null)
            const SizedBox(height: 16),
          if (_outlet!.walletBalance != null ||
              _outlet!.activeOrdersCount != null)
            Row(
              children: [
                if (_outlet!.walletBalance != null)
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Wallet Balance',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '₹${_outlet!.walletBalance}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (_outlet!.walletBalance != null &&
                    _outlet!.activeOrdersCount != null)
                  const SizedBox(width: 12),
                if (_outlet!.activeOrdersCount != null)
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Active Orders',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${_outlet!.activeOrdersCount}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
