import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/transaction_provider.dart';
import '../../../providers/category_provider.dart';
import '../../../models/app_models.dart';

class TransactionsTab extends StatefulWidget {
  const TransactionsTab({super.key});

  @override
  State<TransactionsTab> createState() => _TransactionsTabState();
}

class _TransactionsTabState extends State<TransactionsTab> {
  final _searchController = TextEditingController();
  String _sortBy = 'id';
  String _sortDir = 'desc';
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
    });
  }

  void _fetchData() {
    Provider.of<TransactionProvider>(context, listen: false).fetchTransactions(
      search: _searchController.text.trim(),
      sortBy: _sortBy,
      sortDir: _sortDir,
    );
    Provider.of<CategoryProvider>(context, listen: false).fetchCategories();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatCurrency(int cents) {
    return NumberFormat.simpleCurrency().format(cents / 100);
  }

  @override
  Widget build(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Transactions'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: _showSortDialog,
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextFormField(
                controller: _searchController,
                onFieldSubmitted: (_) => _fetchData(),
                decoration: InputDecoration(
                  hintText: 'Search notes...',
                  prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear, color: AppColors.textMuted),
                    onPressed: () {
                      _searchController.clear();
                      _fetchData();
                    },
                  ),
                ),
              ),
            ),
            
            // Transactions List
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  _fetchData();
                },
                child: transactionProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : transactionProvider.transactions.isEmpty
                        ? ListView(
                            children: const [
                              SizedBox(height: 100),
                              Center(
                                child: Text(
                                  'No transactions found.\nTap + to add one!',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: AppColors.textMuted),
                                ),
                              ),
                            ],
                          )
                        : ListView.builder(
                            itemCount: transactionProvider.transactions.length,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            itemBuilder: (context, index) {
                              final tx = transactionProvider.transactions[index];
                              final isExpense = tx.category?.type == CategoryType.EXPENSE || tx.category == null;

                              return Card(
                                color: Theme.of(context).cardColor,
                                margin: const EdgeInsets.only(bottom: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                child: ListTile(
                                  onTap: () => _showTransactionDetails(tx),
                                  leading: CircleAvatar(
                                    backgroundColor: (isExpense ? AppColors.expense : AppColors.income).withOpacity(0.12),
                                    child: Icon(
                                      isExpense ? Icons.arrow_upward : Icons.arrow_downward,
                                      color: isExpense ? AppColors.expense : AppColors.income,
                                    ),
                                  ),
                                  title: Text(
                                    tx.notes.isNotEmpty ? tx.notes : (tx.category?.name ?? 'Uncategorized'),
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Text(
                                    '${tx.category?.name ?? "General"} • ${tx.transactionDate}',
                                    style: TextStyle(
                                      color: Theme.of(context).textTheme.bodyMedium?.color ?? AppColors.textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                  trailing: Text(
                                    '${isExpense ? "-" : "+"}${_formatCurrency(tx.amount)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: isExpense ? AppColors.expense : AppColors.income,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => _openTransactionForm(null),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showSortDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          title: const Text('Sort Transactions'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Newest First'),
                trailing: _sortBy == 'id' && _sortDir == 'desc' ? const Icon(Icons.check, color: AppColors.primary) : null,
                onTap: () {
                  setState(() {
                    _sortBy = 'id';
                    _sortDir = 'desc';
                  });
                  Navigator.of(context).pop();
                  _fetchData();
                },
              ),
              ListTile(
                title: const Text('Oldest First'),
                trailing: _sortBy == 'id' && _sortDir == 'asc' ? const Icon(Icons.check, color: AppColors.primary) : null,
                onTap: () {
                  setState(() {
                    _sortBy = 'id';
                    _sortDir = 'asc';
                  });
                  Navigator.of(context).pop();
                  _fetchData();
                },
              ),
              ListTile(
                title: const Text('Highest Amount'),
                trailing: _sortBy == 'amount' && _sortDir == 'desc' ? const Icon(Icons.check, color: AppColors.primary) : null,
                onTap: () {
                  setState(() {
                    _sortBy = 'amount';
                    _sortDir = 'desc';
                  });
                  Navigator.of(context).pop();
                  _fetchData();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showTransactionDetails(TransactionModel tx) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        final isExpense = tx.category?.type == CategoryType.EXPENSE;
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    tx.category?.name ?? 'General',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color ?? AppColors.textSecondary,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    tx.transactionDate,
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                tx.notes.isNotEmpty ? tx.notes : 'No description provided',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color ?? AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${isExpense ? "-" : "+"}${_formatCurrency(tx.amount)}',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: isExpense ? AppColors.expense : AppColors.income,
                ),
              ),
              const SizedBox(height: 24),
              // Receipt Image if any
              if (tx.fileUrl != null && tx.fileUrl!.isNotEmpty) ...[
                Text(
                  'Receipt Attachment:',
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyMedium?.color ?? AppColors.textSecondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    tx.fileUrl!,
                    height: 120,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Center(
                      child: Text('Attachment not available offline', style: TextStyle(color: AppColors.textMuted)),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
              
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.expense),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () => _confirmDelete(tx.id),
                      icon: const Icon(Icons.delete_outline, color: AppColors.expense),
                      label: const Text('Delete', style: TextStyle(color: AppColors.expense)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        _openTransactionForm(tx);
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit'),
                    ),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  void _confirmDelete(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: const Text('Delete Transaction?'),
        content: const Text('Are you sure you want to permanently delete this logger entry?'),
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
              Navigator.of(context).pop(); // dialog
              Navigator.of(context).pop(); // bottomsheet
              final success = await Provider.of<TransactionProvider>(context, listen: false).deleteTransaction(id);
              if (mounted && !success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Failed to delete transaction'), backgroundColor: AppColors.expense),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _openTransactionForm(TransactionModel? initialTx) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return _TransactionForm(initialTx: initialTx, onSaved: _fetchData);
      },
    );
  }
}

class _TransactionForm extends StatefulWidget {
  final TransactionModel? initialTx;
  final VoidCallback onSaved;

  const _TransactionForm({this.initialTx, required this.onSaved});

  @override
  State<_TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends State<_TransactionForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late final TextEditingController _notesController;
  
  String? _selectedCategoryId;
  late DateTime _selectedDate;
  String? _imagePath;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.initialTx != null ? (widget.initialTx!.amount / 100).toStringAsFixed(2) : '',
    );
    _notesController = TextEditingController(text: widget.initialTx?.notes ?? '');
    
    _selectedCategoryId = widget.initialTx?.categoryId;
    _selectedDate = widget.initialTx != null 
        ? DateTime.parse(widget.initialTx!.transactionDate) 
        : DateTime.now();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _imagePath = image.path;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category'), backgroundColor: AppColors.expense),
      );
      return;
    }

    final amountDouble = double.parse(_amountController.text);
    // Multiply by 100 to get the integer cents format expected by API
    final amountCents = (amountDouble * 100).round();
    final formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);

    final txProvider = Provider.of<TransactionProvider>(context, listen: false);

    bool success;
    if (widget.initialTx == null) {
      success = await txProvider.addTransaction(
        amount: amountCents,
        transactionDate: formattedDate,
        notes: _notesController.text.trim(),
        categoryId: _selectedCategoryId!,
        filePath: _imagePath,
      );
    } else {
      success = await txProvider.updateTransaction(
        id: widget.initialTx!.id,
        amount: amountCents,
        transactionDate: formattedDate,
        notes: _notesController.text.trim(),
        categoryId: _selectedCategoryId!,
        filePath: _imagePath,
      );
    }

    if (mounted) {
      if (success) {
        widget.onSaved();
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(txProvider.error ?? 'Failed to save transaction'),
            backgroundColor: AppColors.expense,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = Provider.of<CategoryProvider>(context).categories;
    final isEdit = widget.initialTx != null;

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
                isEdit ? 'Edit Transaction' : 'Add Transaction',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color ?? AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 24),

              // Amount Input
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'Enter an amount';
                  if (double.tryParse(value) == null || double.parse(value) <= 0) {
                    return 'Please enter a valid numeric format';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  hintText: '0.00',
                  prefixIcon: Icon(Icons.attach_money, color: AppColors.textMuted),
                ),
              ),
              const SizedBox(height: 16),

              // Category dropdown
              DropdownButtonFormField<String>(
                value: categories.any((cat) => cat.id == _selectedCategoryId)
                    ? _selectedCategoryId
                    : null,
                dropdownColor: Theme.of(context).cardColor,
                decoration: const InputDecoration(
                  hintText: 'Select Category',
                  prefixIcon: Icon(Icons.category_outlined, color: AppColors.textMuted),
                ),
                items: () {
                  final list = [...categories];
                  if (widget.initialTx?.category != null &&
                      !list.any((c) => c.id == widget.initialTx!.categoryId)) {
                    list.add(widget.initialTx!.category!);
                  }
                  return list.map((cat) {
                    return DropdownMenuItem<String>(
                      value: cat.id,
                      child: Text('${cat.name} (${cat.type == CategoryType.INCOME ? "Income" : "Expense"})'),
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

              // Date Picker Button
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setState(() {
                      _selectedDate = picked;
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
                        DateFormat('yyyy-MM-dd').format(_selectedDate),
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyLarge?.color ?? AppColors.textPrimary,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Notes Input
              TextFormField(
                controller: _notesController,
                maxLines: 2,
                decoration: const InputDecoration(
                  hintText: 'Notes / description...',
                  prefixIcon: Icon(Icons.edit_note, color: AppColors.textMuted),
                ),
              ),
              const SizedBox(height: 16),

              // Attachment Preview / Choose Button
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _imagePath != null
                          ? 'Image selected!'
                          : (isEdit && widget.initialTx?.fileUrl != null ? 'Has online receipt' : 'Add invoice image receipt?'),
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyMedium?.color ?? AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      backgroundColor: Colors.white10,
                    ),
                    onPressed: _pickImage,
                    icon: const Icon(Icons.image, size: 14),
                    label: const Text('Pick Image', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
              if (_imagePath != null) ...[
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(_imagePath!),
                    height: 80,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
              const SizedBox(height: 32),

              // Save Button
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Save Transaction'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
