import 'package:flutter/material.dart';

class AppConstants {
  // App Information
  static const String appName = 'Expense Tracker PWA';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'A modern, production-quality Expense Tracker Progressive Web App';

  // Database
  static const String databaseName = 'expense_tracker.db';
  static const int databaseVersion = 1;

  // Currency
  static const String defaultCurrency = 'INR';
  static const String currencySymbol = '₹';
  static const List<String> supportedCurrencies = [
    'INR', 'USD', 'EUR', 'GBP', 'JPY', 'AUD', 'CAD', 'CHF', 'CNY', 'BRL'
  ];

  // Date Formats
  static const String dateFormat = 'yyyy-MM-dd';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'yyyy-MM-dd HH:mm';

  // Payment Methods
  static const List<String> paymentMethods = [
    'Cash',
    'Credit Card',
    'Debit Card',
    'Bank Transfer',
    'Mobile Payment',
    'Check',
    'Other'
  ];

  // Budget Periods
  static const List<String> budgetPeriods = [
    'weekly',
    'monthly',
    'yearly'
  ];

  // Recurring Patterns
  static const List<String> recurringPatterns = [
    'daily',
    'weekly',
    'monthly',
    'yearly'
  ];

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // Padding and Margins
  static const double smallPadding = 8.0;
  static const double mediumPadding = 16.0;
  static const double largePadding = 24.0;
  static const double extraLargePadding = 32.0;

  // Border Radius
  static const double smallRadius = 8.0;
  static const double mediumRadius = 12.0;
  static const double largeRadius = 16.0;
  static const double extraLargeRadius = 24.0;

  // Icon Sizes
  static const double smallIcon = 16.0;
  static const double mediumIcon = 24.0;
  static const double largeIcon = 32.0;
  static const double extraLargeIcon = 48.0;

  // Chart Colors
  static const List<Color> chartColors = [
    Color(0xFF6366F1), // Indigo
    Color(0xFF8B5CF6), // Purple
    Color(0xFFEC4899), // Pink
    Color(0xFFF43F5E), // Rose
    Color(0xFFF97316), // Orange
    Color(0xFFEAB308), // Yellow
    Color(0xFF84CC16), // Lime
    Color(0xFF22C55E), // Green
    Color(0xFF14B8A6), // Teal
    Color(0xFF06B6D4), // Cyan
    Color(0xFF0EA5E9), // Sky
    Color(0xFF3B82F6), // Blue
  ];

  // Category Colors
  static const Map<String, Color> categoryColors = {
    'Food & Dining': Color(0xFFFF6B6B),
    'Transportation': Color(0xFF4ECDC4),
    'Shopping': Color(0xFF45B7D1),
    'Bills & Utilities': Color(0xFF96CEB4),
    'Entertainment': Color(0xFFFFEAA7),
    'Health & Fitness': Color(0xFFDDA0DD),
    'Education': Color(0xFF98D8C8),
    'Travel': Color(0xFFFFB6C1),
    'Personal Care': Color(0xFF87CEEB),
    'Gifts & Donations': Color(0xFFF0E68C),
    'Salary': Color(0xFF2ECC71),
    'Freelance': Color(0xFF3498DB),
    'Investments': Color(0xFF9B59B6),
    'Business': Color(0xFFE67E22),
    'Other Income': Color(0xFF1ABC9C),
  };

  // Notification Settings
  static const Duration notificationDelay = Duration(seconds: 2);
  static const Duration autoHideDuration = Duration(seconds: 4);

  // File Size Limits
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const int maxBackupFileSize = 10 * 1024 * 1024; // 10MB

  // Security
  static const int maxPinAttempts = 3;
  static const Duration autoLockTimeout = Duration(minutes: 5);

  // Performance
  static const int itemsPerPage = 20;
  static const int searchDebounceMs = 300;

  // PWA Settings
  static const String pwaName = 'Expense Tracker';
  static const String pwaShortName = 'ExpTrack';
  static const String pwaDescription = 'Track your expenses on the go';
  static const String pwaStartUrl = '/';
  static const String pwaDisplay = 'standalone';
  static const String pwaOrientation = 'portrait';
  static const String pwaBackgroundColor = '#ffffff';
  static const String pwaThemeColor = '#6366F1';

  // App Store Links (for future implementation)
  static const String appStoreUrl = '';
  static const String playStoreUrl = '';

  // Support
  static const String supportEmail = 'support@expensetracker.app';
  static const String privacyPolicyUrl = '/privacy';
  static const String termsOfServiceUrl = '/terms';

  // Analytics Events
  static const String eventExpenseAdded = 'expense_added';
  static const String eventExpenseUpdated = 'expense_updated';
  static const String eventExpenseDeleted = 'expense_deleted';
  static const String eventBudgetCreated = 'budget_created';
  static const String eventBudgetExceeded = 'budget_exceeded';
  static const String eventCategoryCreated = 'category_created';
  static const String eventAppOpened = 'app_opened';
  static const String eventBackupCreated = 'backup_created';
  static const String eventBackupRestored = 'backup_restored';
}

class AppRoutes {
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String home = '/home';
  static const String dashboard = '/dashboard';
  static const String addExpense = '/add-expense';
  static const String editExpense = '/edit-expense';
  static const String transactions = '/transactions';
  static const String analytics = '/analytics';
  static const String budgets = '/budgets';
  static const String categories = '/categories';
  static const String goals = '/goals';
  static const String recurring = '/recurring';
  static const String reports = '/reports';
  static const String settings = '/settings';
  static const String backup = '/backup';
  static const String about = '/about';
}

class AppStrings {
  // General
  static const String appName = 'Expense Tracker';
  static const String add = 'Add';
  static const String edit = 'Edit';
  static const String delete = 'Delete';
  static const String save = 'Save';
  static const String cancel = 'Cancel';
  static const String confirm = 'Confirm';
  static const String search = 'Search';
  static const String filter = 'Filter';
  static const String clear = 'Clear';
  static const String loading = 'Loading...';
  static const String error = 'Error';
  static const String success = 'Success';
  static const String warning = 'Warning';
  static const String info = 'Info';

  // Navigation
  static const String dashboard = 'Dashboard';
  static const String transactions = 'Transactions';
  static const String analytics = 'Analytics';
  static const String budgets = 'Budgets';
  static const String categories = 'Categories';
  static const String settings = 'Settings';

  // Expense
  static const String expense = 'Expense';
  static const String income = 'Income';
  static const String amount = 'Amount';
  static const String title = 'Title';
  static const String category = 'Category';
  static const String date = 'Date';
  static const String time = 'Time';
  static const String paymentMethod = 'Payment Method';
  static const String notes = 'Notes';
  static const String tags = 'Tags';
  static const String location = 'Location';
  static const String receipt = 'Receipt';
  static const String recurring = 'Recurring';

  // Budget
  static const String budget = 'Budget';
  static const String budgetLimit = 'Budget Limit';
  static const String spent = 'Spent';
  static const String remaining = 'Remaining';
  static const String overBudget = 'Over Budget';
  static const String nearLimit = 'Near Limit';

  // Messages
  static const String expenseAdded = 'Expense added successfully';
  static const String expenseUpdated = 'Expense updated successfully';
  static const String expenseDeleted = 'Expense deleted successfully';
  static const String budgetAdded = 'Budget added successfully';
  static const String budgetUpdated = 'Budget updated successfully';
  static const String budgetDeleted = 'Budget deleted successfully';
  static const String categoryAdded = 'Category added successfully';
  static const String categoryUpdated = 'Category updated successfully';
  static const String categoryDeleted = 'Category deleted successfully';

  // Empty States
  static const String noExpenses = 'No expenses yet';
  static const String noBudgets = 'No budgets set';
  static const String noCategories = 'No categories found';
  static const String noData = 'No data available';

  // Validation
  static const String required = 'This field is required';
  static const String invalidAmount = 'Please enter a valid amount';
  static const String invalidDate = 'Please select a valid date';
  static const String invalidEmail = 'Please enter a valid email';
}
