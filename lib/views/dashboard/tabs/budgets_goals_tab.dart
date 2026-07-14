import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/budget_provider.dart';
import '../../../providers/goal_provider.dart';
import '../../../providers/category_provider.dart';
import '../../../models/app_models.dart';

class BudgetsGoalsTab extends StatefulWidget {
  const BudgetsGoalsTab({super.key});

  @override
  State<BudgetsGoalsTab> createState() => _BudgetsGoalsTabState();
}

class _BudgetsGoalsTabState extends State<BudgetsGoalsTab> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshData();
    });
  }

  void _refreshData() {
    Provider.of<BudgetProvider>(context, listen: false).fetchBudgets();
    Provider.of<GoalProvider>(context, listen: false).fetchGoals();
    Provider.of<CategoryProvider>(context, listen: false).fetchCategories();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _formatCurrency(int cents) {
    return NumberFormat.simpleCurrency().format(cents / 100);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Targets & Budgets'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: Theme.of(context).textTheme.bodyLarge?.color ?? AppColors.textPrimary,
          unselectedLabelColor: AppColors.textMuted,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: 'Categories Budgets'),
            Tab(text: 'Savings Goals'),
          ],
        ),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildBudgetsView(),
            _buildGoalsView(),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetsView() {
    final budgetProvider = Provider.of<BudgetProvider>(context);

    return RefreshIndicator(
      onRefresh: () async {
        _refreshData();
      },
      child: Column(
        children: [
          Expanded(
            child: budgetProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : budgetProvider.budgets.isEmpty
                    ? ListView(
                        children: const [
                          SizedBox(height: 100),
                          Center(
                            child: Text(
                              'No budget configurations found.\nTap below to set up a monthly budget limit!',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: AppColors.textMuted),
                            ),
                          ),
                        ],
                      )
                    : ListView.builder(
                        itemCount: budgetProvider.budgets.length,
                        padding: const EdgeInsets.all(16),
                        itemBuilder: (context, index) {
                          final budget = budgetProvider.budgets[index];
                          final percent = budget.limitAmount > 0
                              ? budget.spentAmount / budget.limitAmount
                              : 0.0;
                          
                          // Alert color flags: warning at 80%, critical error at 100%
                          Color progressColor = AppColors.primary;
                          String? warningText;
                          
                          if (percent >= 1.0) {
                            progressColor = AppColors.expense;
                            warningText = 'EXCEEDED';
                          } else if (percent >= 0.8) {
                            progressColor = AppColors.warning;
                            warningText = 'WARNING (80%+)';
                          }

                          return Card(
                            color: Theme.of(context).cardColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            margin: const EdgeInsets.only(bottom: 16),
                            child: Padding(
                              padding: const EdgeInsets.all(18),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        budget.category?.name ?? 'Category Limit',
                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                      if (warningText != null)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: progressColor.withOpacity(0.15),
                                            borderRadius: BorderRadius.circular(6),
                                            border: Border.all(color: progressColor, width: 0.5),
                                          ),
                                          child: Text(
                                            warningText,
                                            style: TextStyle(color: progressColor, fontSize: 9, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Period: ${DateFormat('MMMM').format(DateTime(2026, budget.month))} ${budget.year}',
                                    style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                                  ),
                                  const SizedBox(height: 16),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: percent.clamp(0.0, 1.0),
                                      minHeight: 8,
                                      backgroundColor: Theme.of(context).brightness == Brightness.dark
                                          ? Colors.white10
                                          : Colors.black12,
                                      valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Used: ${_formatCurrency(budget.spentAmount)}',
                                        style: TextStyle(
                                          color: Theme.of(context).textTheme.bodyMedium?.color ?? AppColors.textSecondary,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        'Limit: ${_formatCurrency(budget.limitAmount)}',
                                        style: TextStyle(
                                          color: Theme.of(context).textTheme.bodyMedium?.color ?? AppColors.textSecondary,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      TextButton(
                                        onPressed: () => _confirmDeleteBudget(budget.id),
                                        child: const Text('Remove', style: TextStyle(color: AppColors.expense, fontSize: 13)),
                                      ),
                                      const SizedBox(width: 8),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                          backgroundColor: Colors.white10,
                                        ),
                                        onPressed: () => _openBudgetForm(budget),
                                        child: const Text('Edit Limit', style: TextStyle(fontSize: 12)),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () => _openBudgetForm(null),
              child: const Text('Create Category Budget'),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildGoalsView() {
    final goalProvider = Provider.of<GoalProvider>(context);

    return RefreshIndicator(
      onRefresh: () async {
        _refreshData();
      },
      child: Column(
        children: [
          Expanded(
            child: goalProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : goalProvider.goals.isEmpty
                    ? ListView(
                        children: const [
                          SizedBox(height: 100),
                          Center(
                            child: Text(
                              'No savings targets created yet.\nTrack progress toward savings targets!',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: AppColors.textMuted),
                            ),
                          ),
                        ],
                      )
                    : ListView.builder(
                        itemCount: goalProvider.goals.length,
                        padding: const EdgeInsets.all(16),
                        itemBuilder: (context, index) {
                          final goal = goalProvider.goals[index];
                          final percent = goal.targetAmount > 0
                              ? goal.currentAmount / goal.targetAmount
                              : 0.0;

                          return Card(
                            color: Theme.of(context).cardColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            margin: const EdgeInsets.only(bottom: 16),
                            child: Padding(
                              padding: const EdgeInsets.all(18),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        goal.name,
                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        'Deadline: ${goal.deadline}',
                                        style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: percent.clamp(0.0, 1.0),
                                      minHeight: 8,
                                      backgroundColor: Theme.of(context).brightness == Brightness.dark
                                          ? Colors.white10
                                          : Colors.black12,
                                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.income),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Saved: ${_formatCurrency(goal.currentAmount)}',
                                        style: const TextStyle(color: AppColors.income, fontSize: 13, fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        'Target: ${_formatCurrency(goal.targetAmount)} (${(percent*100).toStringAsFixed(0)}%)',
                                        style: TextStyle(
                                          color: Theme.of(context).textTheme.bodyMedium?.color ?? AppColors.textSecondary,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      TextButton(
                                        onPressed: () => _confirmDeleteGoal(goal.id),
                                        child: const Text('Delete', style: TextStyle(color: AppColors.expense, fontSize: 13)),
                                      ),
                                      const SizedBox(width: 8),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                          backgroundColor: Colors.white10,
                                        ),
                                        onPressed: () => _openGoalForm(goal),
                                        child: const Text('Edit', style: TextStyle(fontSize: 12)),
                                      ),
                                      const SizedBox(width: 8),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                          backgroundColor: AppColors.income,
                                        ),
                                        onPressed: () => _openAddProgressDialog(goal),
                                        child: const Text('Add Savings', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () => _openGoalForm(null),
              child: const Text('Create Savings Goal'),
            ),
          )
        ],
      ),
    );
  }

  void _confirmDeleteBudget(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: const Text('Remove Budget?'),
        content: const Text('Are you sure you want to delete this category-specific budget limit?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color ?? AppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.expense),
            onPressed: () async {
              Navigator.of(context).pop();
              final success = await Provider.of<BudgetProvider>(context, listen: false).deleteBudget(id);
              if (mounted && !success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Failed to delete budget limit'), backgroundColor: AppColors.expense),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteGoal(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: const Text('Remove Goal?'),
        content: const Text('Are you sure you want to delete this target goal?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color ?? AppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.expense),
            onPressed: () async {
              Navigator.of(context).pop();
              final success = await Provider.of<GoalProvider>(context, listen: false).deleteGoal(id);
              if (mounted && !success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Failed to delete goal'), backgroundColor: AppColors.expense),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _openBudgetForm(BudgetModel? budget) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return _BudgetForm(budget: budget, onSaved: _refreshData);
      },
    );
  }

  void _openGoalForm(GoalModel? goal) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return _GoalForm(goal: goal, onSaved: _refreshData);
      },
    );
  }

  void _openAddProgressDialog(GoalModel goal) {
    final progressController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: Text('Add Savings to ${goal.name}'),
        content: TextField(
          controller: progressController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            hintText: 'Amount (e.g. 50.00)',
            prefixIcon: Icon(Icons.attach_money, color: AppColors.textMuted),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color ?? AppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.income),
            onPressed: () async {
              final valStr = progressController.text.trim();
              if (valStr.isNotEmpty && double.tryParse(valStr) != null) {
                Navigator.of(context).pop();
                final amtCents = (double.parse(valStr) * 100).round();
                final success = await Provider.of<GoalProvider>(context, listen: false).addGoalProgress(goal.id, amtCents);
                if (mounted) {
                  if (success) {
                    _refreshData();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Failed to update goal progress'), backgroundColor: AppColors.expense),
                    );
                  }
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

// Budget Form view overlay
class _BudgetForm extends StatefulWidget {
  final BudgetModel? budget;
  final VoidCallback onSaved;

  const _BudgetForm({this.budget, required this.onSaved});

  @override
  State<_BudgetForm> createState() => _BudgetFormState();
}

class _BudgetFormState extends State<_BudgetForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _limitController;
  
  String? _selectedCategoryId;
  late int _selectedMonth;
  late int _selectedYear;

  @override
  void initState() {
    super.initState();
    _limitController = TextEditingController(
      text: widget.budget != null ? (widget.budget!.limitAmount / 100).toStringAsFixed(2) : '',
    );
    _selectedCategoryId = widget.budget?.categoryId;
    _selectedMonth = widget.budget?.month ?? DateTime.now().month;
    _selectedYear = widget.budget?.year ?? DateTime.now().year;
  }

  @override
  void dispose() {
    _limitController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) return;

    final limitDouble = double.parse(_limitController.text);
    final limitCents = (limitDouble * 100).round();

    final budgetProvider = Provider.of<BudgetProvider>(context, listen: false);

    bool success;
    if (widget.budget == null) {
      success = await budgetProvider.createBudget(
        categoryId: _selectedCategoryId!,
        limitAmount: limitCents,
        month: _selectedMonth,
        year: _selectedYear,
      );
    } else {
      success = await budgetProvider.updateBudget(
        id: widget.budget!.id,
        categoryId: _selectedCategoryId!,
        limitAmount: limitCents,
        month: _selectedMonth,
        year: _selectedYear,
      );
    }

    if (mounted) {
      if (success) {
        widget.onSaved();
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(budgetProvider.error ?? 'Failed to configurations budget limit'),
            backgroundColor: AppColors.expense,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = Provider.of<CategoryProvider>(context).expenseCategories;
    final isEdit = widget.budget != null;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                isEdit ? 'Modify Budget Limit' : 'Configure New Budget',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color ?? AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 24),

              // Limit amount Input
              TextFormField(
                controller: _limitController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'Enter monthly limit amount';
                  if (double.tryParse(value) == null || double.parse(value) <= 0) {
                    return 'Please enter valid numeric limit';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  hintText: r'Limit Amount ($0.00)',
                  prefixIcon: Icon(Icons.attach_money, color: AppColors.textMuted),
                ),
              ),
              const SizedBox(height: 16),

              // Category selector dropdown
              DropdownButtonFormField<String>(
                value: categories.any((cat) => cat.id == _selectedCategoryId)
                    ? _selectedCategoryId
                    : null,
                dropdownColor: Theme.of(context).cardColor,
                decoration: const InputDecoration(
                  hintText: 'Choose Category',
                  prefixIcon: Icon(Icons.category_outlined, color: AppColors.textMuted),
                ),
                items: () {
                  final list = [...categories];
                  if (widget.budget?.category != null &&
                      !list.any((c) => c.id == widget.budget!.categoryId)) {
                    list.add(widget.budget!.category!);
                  }
                  return list.map((cat) {
                    return DropdownMenuItem<String>(
                      value: cat.id,
                      child: Text(cat.name),
                    );
                  }).toList();
                }(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategoryId = value;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Month Selector row dropdown
              DropdownButtonFormField<int>(
                value: _selectedMonth,
                dropdownColor: Theme.of(context).cardColor,
                decoration: const InputDecoration(
                  hintText: 'Month',
                  prefixIcon: Icon(Icons.calendar_month, color: AppColors.textMuted),
                ),
                items: List.generate(12, (index) {
                  final m = index + 1;
                  return DropdownMenuItem<int>(
                    value: m,
                    child: Text(DateFormat('MMMM').format(DateTime(2026, m))),
                  );
                }),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedMonth = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: _submit,
                child: const Text('Save Budget Limit'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// Goal Form view overlay
class _GoalForm extends StatefulWidget {
  final GoalModel? goal;
  final VoidCallback onSaved;

  const _GoalForm({this.goal, required this.onSaved});

  @override
  State<_GoalForm> createState() => _GoalFormState();
}

class _GoalFormState extends State<_GoalForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _targetController;
  
  late DateTime _selectedDeadline;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.goal?.name ?? '');
    _targetController = TextEditingController(
      text: widget.goal != null ? (widget.goal!.targetAmount / 100).toStringAsFixed(2) : '',
    );
    _selectedDeadline = widget.goal != null
        ? DateTime.parse(widget.goal!.deadline)
        : DateTime.now().add(const Duration(days: 30));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final targetDouble = double.parse(_targetController.text);
    final targetCents = (targetDouble * 100).round();
    final formattedDeadline = DateFormat('yyyy-MM-dd').format(_selectedDeadline);

    final goalProvider = Provider.of<GoalProvider>(context, listen: false);

    bool success;
    if (widget.goal == null) {
      success = await goalProvider.createGoal(
        name: _nameController.text.trim(),
        targetAmount: targetCents,
        deadline: formattedDeadline,
      );
    } else {
      success = await goalProvider.updateGoal(
        id: widget.goal!.id,
        name: _nameController.text.trim(),
        targetAmount: targetCents,
        deadline: formattedDeadline,
      );
    }

    if (mounted) {
      if (success) {
        widget.onSaved();
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(goalProvider.error ?? 'Failed to save savings goal'),
            backgroundColor: AppColors.expense,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.goal != null;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                isEdit ? 'Modify Goal Configs' : 'New Savings Target',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color ?? AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 24),

              // Goal name input
              TextFormField(
                controller: _nameController,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'Enter goal target name';
                  return null;
                },
                decoration: const InputDecoration(
                  hintText: 'Goal Name (e.g. Dream Vacation)',
                  prefixIcon: Icon(Icons.track_changes_outlined, color: AppColors.textMuted),
                ),
              ),
              const SizedBox(height: 16),

              // Goal Target Amount
              TextFormField(
                controller: _targetController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'Enter target amount';
                  if (double.tryParse(value) == null || double.parse(value) <= 0) {
                    return 'Please enter valid numeric limit';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  hintText: r'Target Amount ($0.00)',
                  prefixIcon: Icon(Icons.attach_money, color: AppColors.textMuted),
                ),
              ),
              const SizedBox(height: 16),

              // Deadline picker
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDeadline,
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setState(() {
                      _selectedDeadline = picked;
                    });
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    border: Border.all(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white24
                          : Colors.black26,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, color: AppColors.textMuted),
                      const SizedBox(width: 12),
                      Text(
                        'Target Deadline: ${DateFormat('yyyy-MM-dd').format(_selectedDeadline)}',
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyLarge?.color ?? AppColors.textPrimary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: _submit,
                child: const Text('Save Savings Goal'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
