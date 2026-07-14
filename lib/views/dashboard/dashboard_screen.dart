import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';
import 'tabs/home_analytics_tab.dart';
import 'tabs/transactions_tab.dart';
import 'tabs/budgets_goals_tab.dart';
import 'tabs/settings_profile_tab.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  final List<Widget> _tabs = [
    const HomeAnalyticsTab(),
    const TransactionsTab(),
    const BudgetsGoalsTab(),
    const SettingsProfileTab(),
  ];

  @override
  void initState() {
    super.initState();
    // Validate session on load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AuthProvider>(context, listen: false).checkAuthStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    // If session expired or is unauthenticated during check (loading state handles checks)
    if (!authProvider.isAuthenticated && !authProvider.isLoading) {
      return const LoginScreen();
    }

    return Scaffold(
      body: authProvider.isLoading && authProvider.currentUser == null
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : IndexedStack(
              index: _currentIndex,
              children: _tabs,
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Theme.of(context).cardColor,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textMuted,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics_outlined),
            activeIcon: Icon(Icons.analytics),
            label: 'Overview',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long),
            label: 'Transactions',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.track_changes_outlined),
            activeIcon: Icon(Icons.track_changes),
            label: 'Targets & Budgets',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
