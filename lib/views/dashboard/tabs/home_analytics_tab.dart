import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/analytics_provider.dart';
import '../../../models/app_models.dart';

class HomeAnalyticsTab extends StatefulWidget {
  const HomeAnalyticsTab({super.key});

  @override
  State<HomeAnalyticsTab> createState() => _HomeAnalyticsTabState();
}

class _HomeAnalyticsTabState extends State<HomeAnalyticsTab> {
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshData();
    });
  }

  void _refreshData() {
    final analyticsProvider = Provider.of<AnalyticsProvider>(context, listen: false);
    analyticsProvider.fetchDashboardSummary();
    analyticsProvider.fetchCategoryBreakdown(_selectedMonth, _selectedYear);
    analyticsProvider.fetchTrends();
  }

  Future<void> _exportData() async {
    final analyticsProvider = Provider.of<AnalyticsProvider>(context, listen: false);
    final csvContent = await analyticsProvider.exportCsv();
    
    if (csvContent != null && mounted) {
      try {
        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/expense_report_${DateTime.now().millisecondsSinceEpoch}.csv');
        await file.writeAsString(csvContent);
        
        await Share.shareXFiles(
          [XFile(file.path)],
          text: 'My Financial Report Export',
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to export CSV: $e'),
            backgroundColor: AppColors.expense,
          ),
        );
      }
    }
  }

  String _formatCurrency(int cents) {
    // Stored in cents, so we parse to double (dividing by 100)
    final format = NumberFormat.simpleCurrency(decimalDigits: 2);
    return format.format(cents / 100);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final analyticsProvider = Provider.of<AnalyticsProvider>(context);
    final summary = analyticsProvider.summary;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            _refreshData();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Greeting and User profile
                _buildHeader(authProvider),
                const SizedBox(height: 24),
                
                // Net balance summary main display card
                _buildBalanceCard(summary),
                const SizedBox(height: 24),

                // Mini summary info (Income vs Expense cards)
                Row(
                  children: [
                    Expanded(
                      child: _buildMiniStatCard(
                        title: 'Total Income',
                        value: _formatCurrency(summary?.totalIncome ?? 0),
                        icon: Icons.arrow_downward,
                        gradient: AppGradients.incomeGradient,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildMiniStatCard(
                        title: 'Total Expenses',
                        value: _formatCurrency(summary?.totalExpenses ?? 0),
                        icon: Icons.arrow_upward,
                        gradient: AppGradients.expenseGradient,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Category distribution PieChart section
                _buildCategoryBreakdownCard(analyticsProvider),
                const SizedBox(height: 32),

                // 6 months Spending trends LineChart section
                _buildTrendsCard(analyticsProvider),
                const SizedBox(height: 32),

                // CSV Export CTA Button
                ElevatedButton.icon(
                  onPressed: analyticsProvider.isLoading ? null : _exportData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    side: const BorderSide(color: AppColors.primary, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(Icons.file_download_outlined, color: AppColors.primary),
                  label: const Text(
                    'Export Financial Report (CSV)',
                    style: TextStyle(color: AppColors.primary),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AuthProvider authProvider) {
    final avatar = authProvider.currentUser?.avatar;
    final fullName = authProvider.currentUser?.fullName ?? 'Standard User';
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Good day,',
              style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color ?? AppColors.textSecondary, fontSize: 14),
            ),
            Text(
              fullName,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color ?? AppColors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        CircleAvatar(
          radius: 26,
          backgroundColor: AppColors.primary.withOpacity(0.2),
          backgroundImage: avatar != null && avatar.isNotEmpty
              ? NetworkImage(avatar)
              : null,
          child: avatar == null || avatar.isEmpty
              ? const Icon(Icons.person, color: AppColors.primary)
              : null,
        ),
      ],
    );
  }

  Widget _buildBalanceCard(DashboardSummaryModel? summary) {
    final balance = summary?.netBalance ?? 0;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppGradients.primaryGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'NET BALANCE',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'This Month',
                  style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
                ),
              )
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _formatCurrency(balance),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStatCard({
    required String title,
    required String value,
    required IconData icon,
    required LinearGradient gradient,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0x0DFFFFFF)
              : const Color(0x0D000000),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color ?? AppColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                height: 26,
                width: 26,
                decoration: BoxDecoration(
                  gradient: gradient,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 14, color: Colors.white),
              )
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge?.color ?? AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCategoryBreakdownCard(AnalyticsProvider provider) {
    final breakdown = provider.breakdown;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0x0DFFFFFF)
              : const Color(0x0D000000),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Spending Distribution',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color ?? AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              _buildMonthPicker(),
            ],
          ),
          const SizedBox(height: 24),
          if (provider.isLoading)
            const SizedBox(
              height: 180,
              child: Center(child: CircularProgressIndicator()),
            )
          else if (breakdown.isEmpty)
            const SizedBox(
              height: 180,
              child: Center(
                child: Text(
                  'No transactions recorded for this period',
                  style: TextStyle(color: AppColors.textMuted),
                ),
              ),
            )
          else ...[
            SizedBox(
              height: 180,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 4,
                  centerSpaceRadius: 50,
                  sections: breakdown.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    
                    // Curated colors for breakdown items
                    final colors = [
                      AppColors.primary,
                      AppColors.secPrimary,
                      AppColors.income,
                      AppColors.warning,
                      AppColors.primaryAccent,
                      Colors.pinkAccent,
                      Colors.amberAccent,
                    ];
                    final color = colors[index % colors.length];

                    return PieChartSectionData(
                      color: color,
                      value: item.totalAmount.toDouble(),
                      title: '${item.percentage.toStringAsFixed(0)}%',
                      radius: 24,
                      titleStyle: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Legends
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: breakdown.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final colors = [
                  AppColors.primary,
                  AppColors.secPrimary,
                  AppColors.income,
                  AppColors.warning,
                  AppColors.primaryAccent,
                  Colors.pinkAccent,
                  Colors.amberAccent,
                ];
                final color = colors[index % colors.length];

                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(height: 10, width: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                    const SizedBox(width: 4),
                    Text(
                      '${item.categoryName} (${_formatCurrency(item.totalAmount)})',
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyMedium?.color ?? AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    )
                  ],
                );
              }).toList(),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildMonthPicker() {
    return InkWell(
      onTap: () async {
        final monthStr = await showModalBottomSheet<String>(
          context: context,
          backgroundColor: Theme.of(context).cardColor,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (context) {
            return ListView.builder(
              itemCount: 12,
              itemBuilder: (context, index) {
                final m = index + 1;
                return ListTile(
                  title: Text(
                    DateFormat('MMMM').format(DateTime(2026, m)),
                    textAlign: TextAlign.center,
                  ),
                  onTap: () => Navigator.of(context).pop('$m'),
                );
              },
            );
          },
        );
        if (monthStr != null) {
          setState(() {
            _selectedMonth = int.parse(monthStr);
          });
          _refreshData();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0x0DFFFFFF)
              : const Color(0x0D000000),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              DateFormat('MMMM').format(DateTime(2026, _selectedMonth)),
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color ?? AppColors.textPrimary,
                fontSize: 12,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down,
              color: Theme.of(context).textTheme.bodyMedium?.color ?? AppColors.textSecondary,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendsCard(AnalyticsProvider provider) {
    final trends = provider.trends;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0x0DFFFFFF)
              : const Color(0x0D000000),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Spending Trends (6 months)',
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge?.color ?? AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          if (provider.isLoading)
            const SizedBox(
              height: 180,
              child: Center(child: CircularProgressIndicator()),
            )
          else if (trends.isEmpty)
            const SizedBox(
              height: 180,
              child: Center(
                child: Text(
                  'Insufficient historical data tracking trends',
                  style: TextStyle(color: AppColors.textMuted),
                ),
              ),
            )
          else ...[
            SizedBox(
              height: 180,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          int idx = value.toInt();
                          if (idx >= 0 && idx < trends.length) {
                            String mName = trends[idx].month;
                            // Extract just the month part if format is YYYY-MM
                            if (mName.contains('-')) {
                              final parts = mName.split('-');
                              final mNum = int.tryParse(parts[1]) ?? 1;
                              mName = DateFormat('MMM').format(DateTime(2026, mNum));
                            }
                            return SideTitleWidget(
                              meta: meta,
                              child: Text(
                                mName,
                                style: TextStyle(
                                  color: Theme.of(context).textTheme.bodyMedium?.color ?? AppColors.textSecondary,
                                  fontSize: 9,
                                ),
                              ),
                            );
                          }
                          return const SizedBox();
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    // Expense Line
                    LineChartBarData(
                      spots: trends.asMap().entries.map((e) {
                        return FlSpot(e.key.toDouble(), e.value.expense.toDouble() / 100);
                      }).toList(),
                      isCurved: true,
                      color: AppColors.expense,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppColors.expense.withOpacity(0.15),
                      ),
                    ),
                    // Income Line
                    LineChartBarData(
                      spots: trends.asMap().entries.map((e) {
                        return FlSpot(e.key.toDouble(), e.value.income.toDouble() / 100);
                      }).toList(),
                      isCurved: true,
                      color: AppColors.income,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppColors.income.withOpacity(0.15),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLineIndicator('Income', AppColors.income),
                const SizedBox(width: 24),
                _buildLineIndicator('Expense', AppColors.expense),
              ],
            )
          ]
        ],
      ),
    );
  }

  Widget _buildLineIndicator(String label, Color color) {
    return Row(
      children: [
        Container(
          height: 3,
          width: 20,
          color: color,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyMedium?.color ?? AppColors.textSecondary,
            fontSize: 11,
          ),
        )
      ],
    );
  }
}
