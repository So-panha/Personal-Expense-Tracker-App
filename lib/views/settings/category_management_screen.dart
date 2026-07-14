import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/category_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../models/app_models.dart';

class CategoryManagementScreen extends StatefulWidget {
  const CategoryManagementScreen({super.key});

  @override
  State<CategoryManagementScreen> createState() => _CategoryManagementScreenState();
}

class _CategoryManagementScreenState extends State<CategoryManagementScreen> {
  final _nameController = TextEditingController();
  CategoryType _selectedType = CategoryType.EXPENSE;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CategoryProvider>(context, listen: false).fetchCategories();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _openCategoryForm(CategoryModel? initialCategory) {
    final isAdmin = Provider.of<AuthProvider>(context, listen: false).currentUser?.role == 'admin';
    
    // If attempting to edit system category and not admin, reject
    if (initialCategory != null && initialCategory.isSystem && !isAdmin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('System default categories cannot be modified by standard users'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    _nameController.text = initialCategory?.name ?? '';
    _selectedType = initialCategory?.type ?? CategoryType.EXPENSE;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 24,
                right: 24,
                top: 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      initialCategory == null ? 'Create Category' : 'Edit Category',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        hintText: 'Category Name',
                        prefixIcon: Icon(Icons.label_outline),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              setModalState(() {
                                _selectedType = CategoryType.EXPENSE;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: _selectedType == CategoryType.EXPENSE ? AppColors.expense.withOpacity(0.12) : Colors.transparent,
                                border: Border.all(
                                  color: _selectedType == CategoryType.EXPENSE
                                      ? AppColors.expense
                                      : (Theme.of(context).brightness == Brightness.dark ? Colors.white24 : Colors.black26),
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.arrow_upward,
                                    size: 16,
                                    color: _selectedType == CategoryType.EXPENSE
                                        ? AppColors.expense
                                        : (Theme.of(context).textTheme.bodyMedium?.color ?? AppColors.textSecondary),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Expense',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: _selectedType == CategoryType.EXPENSE
                                          ? AppColors.expense
                                          : (Theme.of(context).textTheme.bodyMedium?.color ?? AppColors.textSecondary),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              setModalState(() {
                                _selectedType = CategoryType.INCOME;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: _selectedType == CategoryType.INCOME ? AppColors.income.withOpacity(0.12) : Colors.transparent,
                                border: Border.all(
                                  color: _selectedType == CategoryType.INCOME
                                      ? AppColors.income
                                      : (Theme.of(context).brightness == Brightness.dark ? Colors.white24 : Colors.black26),
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.arrow_downward,
                                    size: 16,
                                    color: _selectedType == CategoryType.INCOME
                                        ? AppColors.income
                                        : (Theme.of(context).textTheme.bodyMedium?.color ?? AppColors.textSecondary),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Income',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: _selectedType == CategoryType.INCOME
                                          ? AppColors.income
                                          : (Theme.of(context).textTheme.bodyMedium?.color ?? AppColors.textSecondary),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () async {
                        final name = _nameController.text.trim();
                        if (name.isEmpty) return;

                        Navigator.of(context).pop();
                        final catProvider = Provider.of<CategoryProvider>(context, listen: false);

                        bool success;
                        if (initialCategory == null) {
                          success = await catProvider.addCategory(name, _selectedType);
                        } else {
                          success = await catProvider.updateCategory(initialCategory.id, name);
                        }

                        if (mounted) {
                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Category saved successfully'), backgroundColor: AppColors.income),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(catProvider.error ?? 'Failed to save category'), backgroundColor: AppColors.expense),
                            );
                          }
                        }
                      },
                      child: const Text('Save Category'),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _confirmDelete(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: const Text('Delete Category?'),
        content: const Text('This will delete this category. Any transactions linked to it may be uncategorized.'),
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
              final catProvider = Provider.of<CategoryProvider>(context, listen: false);
              final success = await catProvider.deleteCategory(id);
              if (mounted) {
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Category deleted successfully'), backgroundColor: AppColors.income),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(catProvider.error ?? 'Failed to delete category'), backgroundColor: AppColors.expense),
                  );
                }
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final catProvider = Provider.of<CategoryProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final isAdmin = authProvider.currentUser?.role == 'admin';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Category Management'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).textTheme.bodyLarge?.color ?? AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: catProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: catProvider.categories.length,
                      padding: const EdgeInsets.all(16),
                      itemBuilder: (context, index) {
                        final cat = catProvider.categories[index];
                        final isExpense = cat.type == CategoryType.EXPENSE;
                        
                        // Locks delete/edit for system default categories unless user is an admin
                        final isLocked = cat.isSystem && !isAdmin;

                        return Card(
                          color: Theme.of(context).cardColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: (isExpense ? AppColors.expense : AppColors.income).withOpacity(0.12),
                              child: Icon(
                                isExpense ? Icons.arrow_upward : Icons.arrow_downward,
                                size: 18,
                                color: isExpense ? AppColors.expense : AppColors.income,
                              ),
                            ),
                            title: Text(
                              cat.name,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              cat.isSystem ? 'System Default' : 'Custom User Category',
                              style: TextStyle(
                                color: Theme.of(context).textTheme.bodyMedium?.color ?? AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                            trailing: isLocked
                                ? const Icon(Icons.lock_outline, size: 20, color: AppColors.textMuted)
                                : Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: Icon(
                                          Icons.edit_outlined,
                                          size: 20,
                                          color: Theme.of(context).textTheme.bodyMedium?.color ?? AppColors.textSecondary,
                                        ),
                                        onPressed: () => _openCategoryForm(cat),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.expense),
                                        onPressed: () => _confirmDelete(cat.id),
                                      ),
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
                      onPressed: () => _openCategoryForm(null),
                      child: const Text('Add Custom Category'),
                    ),
                  )
                ],
              ),
      ),
    );
  }
}
