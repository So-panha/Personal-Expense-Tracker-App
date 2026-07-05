import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/network/api_client.dart';
import 'core/theme/app_theme.dart';
import 'repositories/auth_repository.dart';
import 'repositories/category_repository.dart';
import 'repositories/budget_repository.dart';
import 'repositories/goal_repository.dart';
import 'repositories/transaction_repository.dart';
import 'repositories/analytics_repository.dart';

import 'providers/auth_provider.dart';
import 'providers/category_provider.dart';
import 'providers/budget_provider.dart';
import 'providers/goal_provider.dart';
import 'providers/transaction_provider.dart';
import 'providers/analytics_provider.dart';

import 'views/auth/login_screen.dart';
import 'views/dashboard/dashboard_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final apiClient = ApiClient();

  final authRepo = AuthRepository(apiClient);
  final categoryRepo = CategoryRepository(apiClient);
  final budgetRepo = BudgetRepository(apiClient);
  final goalRepo = GoalRepository(apiClient);
  final transactionRepo = TransactionRepository(apiClient);
  final analyticsRepo = AnalyticsRepository(apiClient);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(authRepo)),
        ChangeNotifierProvider(create: (_) => CategoryProvider(categoryRepo)),
        ChangeNotifierProvider(create: (_) => BudgetProvider(budgetRepo)),
        ChangeNotifierProvider(create: (_) => GoalProvider(goalRepo)),
        ChangeNotifierProvider(create: (_) => TransactionProvider(transactionRepo)),
        ChangeNotifierProvider(create: (_) => AnalyticsProvider(analyticsRepo)),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Personal Expense Tracker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AuthProvider>(context, listen: false).checkAuthStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    if (authProvider.isLoading && authProvider.currentUser == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (authProvider.isAuthenticated) {
      return const DashboardScreen();
    }

    return const LoginScreen();
  }
}
