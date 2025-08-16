import 'package:flutter/material.dart';

import '../../../../core/services/user_profile_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/expenses_item.dart';


class EnhancedAddExpenseDialog extends StatefulWidget {
  final ExpensesItem? expenseToEdit;
  final Function(ExpensesItem) onSave;

  const EnhancedAddExpenseDialog({
    super.key,
    this.expenseToEdit,
    required this.onSave,
  });

  @override
  State<EnhancedAddExpenseDialog> createState() => _EnhancedAddExpenseDialogState();
}

class _EnhancedAddExpenseDialogState extends State<EnhancedAddExpenseDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final _tagController = TextEditingController();
  
  ExpenseCategory _selectedCategory = ExpenseCategory.other;
  List<String> _tags = [];
  bool _isRecurring = false;
  String _recurringPeriod = 'monthly';
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.expenseToEdit != null) {
      _nameController.text = widget.expenseToEdit!.name;
      _amountController.text = widget.expenseToEdit!.amount.toString();
      _noteController.text = widget.expenseToEdit!.note ?? '';
      _selectedCategory = widget.expenseToEdit!.category;
      _tags = List.from(widget.expenseToEdit!.tags);
      _isRecurring = widget.expenseToEdit!.isRecurring;
      _recurringPeriod = widget.expenseToEdit!.recurringPeriod ?? 'monthly';
      _selectedDate = widget.expenseToEdit!.dateTime;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  void _addTag() {
    if (_tagController.text.isNotEmpty && !_tags.contains(_tagController.text)) {
      setState(() {
        _tags.add(_tagController.text);
        _tagController.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  String _getCurrencySymbol() {
    final userProfileService = UserProfileService();
    final profile = userProfileService.currentProfile;
    return profile?.currencySymbol ?? '\$';
  }

  void _saveExpense() {
    if (_formKey.currentState!.validate()) {
      final expense = ExpensesItem(
        id: widget.expenseToEdit?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        amount: double.parse(_amountController.text),
        dateTime: _selectedDate,
        category: _selectedCategory,
        tags: _tags,
        note: _noteController.text.isEmpty ? null : _noteController.text,
        isRecurring: _isRecurring,
        recurringPeriod: _isRecurring ? _recurringPeriod : null,
      );
      
      widget.onSave(expense);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    widget.expenseToEdit != null ? Icons.edit : Icons.add,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    widget.expenseToEdit != null ? 'Edit Expense' : 'Add New Expense',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            
            // Form
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name Field
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Expense Name',
                          hintText: 'What did you spend on?',
                          prefixIcon: Icon(Icons.label),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an expense name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Amount Field
                      TextFormField(
                        controller: _amountController,
                        decoration: InputDecoration(
                          labelText: 'Amount',
                          hintText: '0.00',
                          prefixIcon: const Icon(Icons.attach_money),
                          suffixText: _getCurrencySymbol(),
                        ),
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an amount';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please enter a valid amount';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Category Selection
                      Text(
                        'Category',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: ExpenseCategory.values.map((category) {
                          final isSelected = _selectedCategory == category;
                          return FilterChip(
                            label: Text(category.name.toUpperCase()),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                _selectedCategory = category;
                              });
                            },
                            backgroundColor: isSelected 
                                ? AppTheme.getCategoryColor(category.name)
                                : Colors.grey.shade200,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                      
                      // Date Selection
                      Row(
                        children: [
                          Icon(Icons.calendar_today, color: Colors.grey.shade600),
                          const SizedBox(width: 8),
                          Text(
                            'Date: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: _selectedDate,
                                firstDate: DateTime(2020),
                                lastDate: DateTime.now().add(const Duration(days: 365)),
                              );
                              if (date != null) {
                                setState(() {
                                  _selectedDate = date;
                                });
                              }
                            },
                            child: const Text('Change'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Tags
                      Text(
                        'Tags',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _tagController,
                              decoration: const InputDecoration(
                                hintText: 'Add a tag',
                                prefixIcon: Icon(Icons.tag),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: _addTag,
                            child: const Text('Add'),
                          ),
                        ],
                      ),
                      if (_tags.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: _tags.map((tag) => Chip(
                            label: Text(tag),
                            deleteIcon: const Icon(Icons.close, size: 18),
                            onDeleted: () => _removeTag(tag),
                          )).toList(),
                        ),
                      ],
                      const SizedBox(height: 16),
                      
                      // Note Field
                      TextFormField(
                        controller: _noteController,
                        decoration: const InputDecoration(
                          labelText: 'Note (Optional)',
                          hintText: 'Add any additional details...',
                          prefixIcon: Icon(Icons.note),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      
                      // Recurring Expense
                      Row(
                        children: [
                          Checkbox(
                            value: _isRecurring,
                            onChanged: (value) {
                              setState(() {
                                _isRecurring = value ?? false;
                              });
                            },
                          ),
                          const Text('Recurring Expense'),
                        ],
                      ),
                      if (_isRecurring) ...[
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          initialValue: _recurringPeriod,
                          decoration: const InputDecoration(
                            labelText: 'Recurring Period',
                            prefixIcon: Icon(Icons.repeat),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'daily', child: Text('Daily')),
                            DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
                            DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
                            DropdownMenuItem(value: 'yearly', child: Text('Yearly')),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _recurringPeriod = value!;
                            });
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            
            // Actions
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _saveExpense,
                    child: Text(widget.expenseToEdit != null ? 'Update' : 'Save'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
