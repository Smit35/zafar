import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/order.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/order_card.dart';
import '../auth/login_screen.dart';
import 'enhanced_order_details.dart';

class NewDriverDashboard extends StatefulWidget {
  const NewDriverDashboard({super.key});

  @override
  State<NewDriverDashboard> createState() => _NewDriverDashboardState();
}

class _NewDriverDashboardState extends State<NewDriverDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _selectedIndex == 0 ? _buildOrdersTab() : _selectedIndex == 1 ? _buildEarningsTab() : _buildProfileTab(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textLight,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.attach_money),
            label: 'Earnings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersTab() {
    return Consumer<OrderProvider>(
      builder: (context, orderProvider, child) {
        return NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                title: const Text(AppStrings.dashboard),
                pinned: true,
                expandedHeight: 120,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColors.primary, AppColors.primaryLight],
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 80, left: 16, right: 16),
                      child: Row(
                        children: [
                          Consumer<AuthProvider>(
                            builder: (context, auth, _) => Expanded(
                              child: Text(
                                'Hello, ${auth.user?.name ?? "Driver"}!',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.refresh, color: Colors.white),
                            onPressed: () => orderProvider.refreshOrders(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                bottom: TabBar(
                  controller: _tabController,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white70,
                  indicatorColor: Colors.white,
                  tabs: const [
                    Tab(text: 'New Orders'),
                    Tab(text: 'Active'),
                    Tab(text: 'Completed'),
                  ],
                ),
              ),
            ];
          },
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildNewOrdersList(orderProvider),
              _buildActiveOrdersList(orderProvider),
              _buildCompletedOrdersList(orderProvider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNewOrdersList(OrderProvider orderProvider) {
    final newOrders = orderProvider.activeOrders
        .where((order) => order.status == OrderStatus.assigned)
        .toList();

    if (orderProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (newOrders.isEmpty) {
      return _buildEmptyState(
        icon: Icons.assignment_outlined,
        title: 'No new orders',
        subtitle: 'New orders will appear here',
      );
    }

    return RefreshIndicator(
      onRefresh: orderProvider.refreshOrders,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        itemCount: newOrders.length,
        itemBuilder: (context, index) {
          final order = newOrders[index];
          return OrderCard(
            order: order,
            onTap: () => _navigateToOrderDetails(order),
            onAccept: () => _acceptOrder(order),
          );
        },
      ),
    );
  }

  Widget _buildActiveOrdersList(OrderProvider orderProvider) {
    final activeOrders = orderProvider.activeOrders
        .where((order) => order.status == OrderStatus.active)
        .toList();

    if (orderProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (activeOrders.isEmpty) {
      return _buildEmptyState(
        icon: Icons.local_shipping_outlined,
        title: 'No active orders',
        subtitle: 'Accepted orders will appear here',
      );
    }

    return RefreshIndicator(
      onRefresh: orderProvider.refreshOrders,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        itemCount: activeOrders.length,
        itemBuilder: (context, index) {
          final order = activeOrders[index];
          return OrderCard(
            order: order,
            onTap: () => _navigateToOrderDetails(order),
          );
        },
      ),
    );
  }

  Widget _buildCompletedOrdersList(OrderProvider orderProvider) {
    if (orderProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (orderProvider.completedOrders.isEmpty) {
      return _buildEmptyState(
        icon: Icons.check_circle_outlined,
        title: 'No completed orders',
        subtitle: 'Completed orders will appear here',
      );
    }

    return RefreshIndicator(
      onRefresh: orderProvider.refreshOrders,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        itemCount: orderProvider.completedOrders.length,
        itemBuilder: (context, index) {
          final order = orderProvider.completedOrders[index];
          return OrderCard(
            order: order,
            onTap: () => _navigateToOrderDetails(order),
          );
        },
      ),
    );
  }

  Widget _buildEarningsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          const Text(
            'Earnings Overview',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSizes.paddingLarge),
          _buildEarningsCard(),
          const SizedBox(height: AppSizes.paddingLarge),
          _buildStatsGrid(),
        ],
      ),
    );
  }

  Widget _buildEarningsCard() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingLarge),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Today\'s Earnings',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
              Icon(
                Icons.trending_up,
                color: Colors.white70,
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingSmall),
          const Text(
            '₹340.00',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSizes.paddingSmall),
          Text(
            'From 4 completed orders',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: AppSizes.paddingMedium,
      mainAxisSpacing: AppSizes.paddingMedium,
      children: [
        _buildStatCard('Total Earnings', '₹2,450', Icons.account_balance_wallet),
        _buildStatCard('Completed Orders', '23', Icons.check_circle),
        _buildStatCard('Distance Covered', '145.5 km', Icons.route),
        _buildStatCard('Average Rating', '4.7 ⭐', Icons.star),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
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
          Icon(
            icon,
            color: AppColors.primary,
            size: 24,
          ),
          const SizedBox(height: AppSizes.paddingSmall),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileTab() {
    return Consumer<AuthProvider>(
      builder: (context, auth, child) {
        final user = auth.user;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.paddingMedium),
          child: Column(
            children: [
              const SizedBox(height: 40),
              CircleAvatar(
                radius: 50,
                backgroundColor: AppColors.primary,
                child: Text(
                  user?.name.substring(0, 1).toUpperCase() ?? 'D',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.paddingMedium),
              Text(
                user?.name ?? 'Driver Name',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                user?.email ?? 'driver@zafar.com',
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSizes.paddingLarge),
              _buildProfileOption(
                icon: Icons.edit,
                title: 'Edit Profile',
                onTap: () {},
              ),
              _buildProfileOption(
                icon: Icons.history,
                title: 'Order History',
                onTap: () {},
              ),
              _buildProfileOption(
                icon: Icons.help,
                title: 'Help & Support',
                onTap: () {},
              ),
              _buildProfileOption(
                icon: Icons.logout,
                title: 'Logout',
                onTap: () => _logout(),
                isDestructive: true,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.paddingSmall),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isDestructive ? AppColors.error : AppColors.primary,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isDestructive ? AppColors.error : AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: AppColors.textLight,
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: AppColors.textLight,
          ),
          const SizedBox(height: AppSizes.paddingMedium),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSizes.paddingSmall),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textLight,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToOrderDetails(Order order) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EnhancedOrderDetails(
          order: order,
          onStatusUpdate: (updatedOrder) {
            Provider.of<OrderProvider>(context, listen: false)
                .updateOrderStatus(updatedOrder.id, updatedOrder.status);
          },
        ),
      ),
    );
  }

  void _acceptOrder(Order order) async {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    final success = await orderProvider.acceptOrder(order.id);
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Order accepted successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to accept order. Please try again.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _logout() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.logout();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }
}