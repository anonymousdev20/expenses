import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

import '../constants/app_constants.dart';
import '../constants/app_theme.dart';
import '../providers/expense_provider.dart';
import '../providers/category_provider.dart';
import '../widgets/analytics_chart_card.dart';
import '../widgets/analytics_summary_card.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedPeriod = 'monthly';
  DateTimeRange? _dateRange;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final expenseProvider = Provider.of<ExpenseProvider>(context, listen: false);
    final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
    
    await Future.wait([
      expenseProvider.refresh(),
      categoryProvider.refresh(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      body: Column(
        children: [
          // Header matching dashboard style
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: AppTheme.headerGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Analytics',
                            style: AppTheme.titleStyle.copyWith(
                                color: Colors.white, fontSize: 20)),
                        IconButton(
                          icon: const Icon(Icons.date_range, color: Colors.white),
                          onPressed: _selectDateRange,
                        ),
                      ],
                    ),
                  ),
                  TabBar(
                    controller: _tabController,
                    indicatorColor: Colors.white,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white60,
                    tabs: const [
                      Tab(text: 'Overview'),
                      Tab(text: 'Categories'),
                      Tab(text: 'Trends'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Tab content
          Expanded(
            child: Consumer2<ExpenseProvider, CategoryProvider>(
              builder: (context, expenseProvider, categoryProvider, child) {
                if (expenseProvider.isLoading || categoryProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                return TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOverviewTab(expenseProvider, categoryProvider),
                    _buildCategoriesTab(expenseProvider, categoryProvider),
                    _buildTrendsTab(expenseProvider, categoryProvider),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(ExpenseProvider expenseProvider, CategoryProvider categoryProvider) {
    final (startDate, endDate) = _getDateRange();
    final totalIncome = expenseProvider.getTotalIncome(startDate: startDate, endDate: endDate);
    final totalExpenses = expenseProvider.getTotalExpenses(startDate: startDate, endDate: endDate);
    final balance = totalIncome - totalExpenses;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Period Selector
          _buildPeriodSelector(),
          
          const SizedBox(height: 24),
          
          // Summary Cards
          Row(
            children: [
              Expanded(
                child: AnalyticsSummaryCard(
                  title: 'Total Income',
                  amount: totalIncome,
                  icon: Icons.arrow_downward,
                  color: AppTheme.success,
                  subtitle: _getPeriodText(),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AnalyticsSummaryCard(
                  title: 'Total Expenses',
                  amount: totalExpenses,
                  icon: Icons.arrow_upward,
                  color: AppTheme.lightError,
                  subtitle: _getPeriodText(),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          AnalyticsSummaryCard(
            title: 'Net Balance',
            amount: balance,
            icon: Icons.account_balance_wallet,
            color: balance >= 0 ? AppTheme.success : AppTheme.lightError,
            subtitle: _getPeriodText(),
          ),
          
          const SizedBox(height: 24),
          
          // Income vs Expenses Chart
          AnalyticsChartCard(
            title: 'Income vs Expenses',
            child: _buildIncomeVsExpensesChart(totalIncome, totalExpenses),
          ),
          
          const SizedBox(height: 16),
          
          // Daily Spending Trend
          AnalyticsChartCard(
            title: 'Daily Spending Trend',
            child: _buildDailySpendingChart(expenseProvider),
          ),
          
          const SizedBox(height: 24),
          
          // Top Categories
          Text(
            'Top Spending Categories',
            style: AppTheme.titleStyle.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildTopCategoriesChart(expenseProvider, categoryProvider),
        ],
      ),
    );
  }

  Widget _buildCategoriesTab(ExpenseProvider expenseProvider, CategoryProvider categoryProvider) {
    final (startDate, endDate) = _getDateRange();
    final expensesByCategory = expenseProvider.getExpensesByCategory(startDate: startDate, endDate: endDate);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Period Selector
          _buildPeriodSelector(),
          
          const SizedBox(height: 24),
          
          // Category Breakdown Pie Chart
          AnalyticsChartCard(
            title: 'Category Breakdown',
            child: _buildCategoryPieChart(expensesByCategory, categoryProvider),
          ),
          
          const SizedBox(height: 16),
          
          // Category Comparison Bar Chart
          AnalyticsChartCard(
            title: 'Category Comparison',
            child: _buildCategoryBarChart(expensesByCategory, categoryProvider),
          ),
          
          const SizedBox(height: 24),
          
          // Category Details List
          Text(
            'Category Details',
            style: AppTheme.titleStyle.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          
          ...expensesByCategory.entries.map((entry) {
            final category = categoryProvider.getCategoryByName(entry.key);
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  // Category Icon
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.getCategoryColor(entry.key).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _getCategoryIcon(entry.key),
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // Category Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.key,
                          style: AppTheme.subtitleStyle.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${AppConstants.currencySymbol}${entry.value.toStringAsFixed(2)} (${_getPercentage(entry.value, expensesByCategory.values.fold(0.0, (sum, val) => sum + val)).toStringAsFixed(1)}%)',
                          style: AppTheme.bodyStyle.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Progress Bar
                  SizedBox(
                    width: 100,
                    child: LinearProgressIndicator(
                      value: _getPercentage(entry.value, expensesByCategory.values.fold(0.0, (sum, val) => sum + val)) / 100,
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppTheme.getCategoryColor(entry.key),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTrendsTab(ExpenseProvider expenseProvider, CategoryProvider categoryProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Period Selector
          _buildPeriodSelector(),
          
          const SizedBox(height: 24),
          
          // Monthly Trend
          AnalyticsChartCard(
            title: 'Monthly Trend',
            child: _buildMonthlyTrendChart(expenseProvider),
          ),
          
          const SizedBox(height: 16),
          
          // Year-over-Year Comparison
          AnalyticsChartCard(
            title: 'Year-over-Year Comparison',
            child: _buildYearOverYearChart(expenseProvider),
          ),
          
          const SizedBox(height: 24),
          
          // Trend Summary
          Text(
            'Trend Summary',
            style: AppTheme.titleStyle.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildTrendSummary(expenseProvider),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: ['weekly', 'monthly', 'quarterly', 'yearly'].map((period) {
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedPeriod = period;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _selectedPeriod == period ? Theme.of(context).colorScheme.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  period.capitalize(),
                  textAlign: TextAlign.center,
                  style: AppTheme.subtitleStyle.copyWith(
                    color: _selectedPeriod == period 
                        ? Theme.of(context).colorScheme.onPrimary 
                        : Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildIncomeVsExpensesChart(double income, double expenses) {
    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: income > expenses ? income * 1.2 : expenses * 1.2,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => Theme.of(context).colorScheme.inverseSurface,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final value = rod.toY.round();
                final label = group.x.toInt() == 0 ? 'Income' : 'Expenses';
                return BarTooltipItem(
                  '$label: ${AppConstants.currencySymbol}${value.toString()}',
                  TextStyle(
                    color: Theme.of(context).colorScheme.onInverseSurface,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt() == 0 ? 'Income' : 'Expenses',
                    style: AppTheme.captionStyle.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '${AppConstants.currencySymbol}${value.toInt()}',
                    style: AppTheme.captionStyle.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  );
                },
              ),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          barGroups: [
            BarChartGroupData(
              x: 0,
              barRods: [
                BarChartRodData(
                  toY: income,
                  color: AppTheme.success,
                  width: 20,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                ),
              ],
            ),
            BarChartGroupData(
              x: 1,
              barRods: [
                BarChartRodData(
                  toY: expenses,
                  color: AppTheme.lightError,
                  width: 20,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailySpendingChart(ExpenseProvider expenseProvider) {
    final (startDate, endDate) = _getDateRange();
    final dailyData = _getDailySpendingData(expenseProvider, startDate, endDate);
    
    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          lineTouchData: LineTouchData(
            enabled: true,
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= 0 && value.toInt() < dailyData.length) {
                    return Text(
                      DateFormat('MMM dd').format(dailyData[value.toInt()]['date']),
                      style: AppTheme.captionStyle.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '${AppConstants.currencySymbol}${value.toInt()}',
                    style: AppTheme.captionStyle.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  );
                },
              ),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: dailyData.asMap().entries.map((entry) {
                return FlSpot(entry.key.toDouble(), entry.value['amount']);
              }).toList(),
              isCurved: true,
              color: Theme.of(context).colorScheme.primary,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 4,
                    color: Theme.of(context).colorScheme.primary,
                    strokeWidth: 2,
                    strokeColor: Theme.of(context).colorScheme.surface,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryPieChart(Map<String, double> expensesByCategory, CategoryProvider categoryProvider) {
    final totalExpenses = expensesByCategory.values.fold(0.0, (sum, val) => sum + val);
    
    return SizedBox(
      height: 250,
      child: PieChart(
        PieChartData(
          pieTouchData: PieTouchData(
            enabled: true,
          ),
          sectionsSpace: 2,
          centerSpaceRadius: 60,
          sections: expensesByCategory.entries.map((entry) {
            final color = AppTheme.getCategoryColor(entry.key);
            return PieChartSectionData(
              color: color,
              value: entry.value,
              title: '${(entry.value / totalExpenses * 100).toStringAsFixed(0)}%',
              radius: 50,
              titleStyle: AppTheme.captionStyle.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildCategoryBarChart(Map<String, double> expensesByCategory, CategoryProvider categoryProvider) {
    return SizedBox(
      height: 250,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: expensesByCategory.values.isNotEmpty 
              ? expensesByCategory.values.reduce((a, b) => a > b ? a : b) * 1.2
              : 100,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => Theme.of(context).colorScheme.inverseSurface,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final category = expensesByCategory.keys.elementAt(group.x.toInt());
                final amount = expensesByCategory[category]!;
                return BarTooltipItem(
                  '$category\n${AppConstants.currencySymbol}${amount.toStringAsFixed(2)}',
                  TextStyle(
                    color: Theme.of(context).colorScheme.onInverseSurface,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= 0 && value.toInt() < expensesByCategory.keys.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        expensesByCategory.keys.elementAt(value.toInt()),
                        style: AppTheme.captionStyle.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '${AppConstants.currencySymbol}${value.toInt()}',
                    style: AppTheme.captionStyle.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  );
                },
              ),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          barGroups: expensesByCategory.entries.map((entry) {
            return BarChartGroupData(
              x: expensesByCategory.keys.toList().indexOf(entry.key),
              barRods: [
                BarChartRodData(
                  toY: entry.value,
                  color: AppTheme.getCategoryColor(entry.key),
                  width: 20,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildTopCategoriesChart(ExpenseProvider expenseProvider, CategoryProvider categoryProvider) {
    final (startDate, endDate) = _getDateRange();
    final expensesByCategory = expenseProvider.getExpensesByCategory(startDate: startDate, endDate: endDate);
    final sortedCategories = expensesByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topCategories = sortedCategories.take(5).toList();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: topCategories.asMap().entries.map((entry) {
          final index = entry.key;
          final categoryData = entry.value;
          final category = categoryProvider.getCategoryByName(categoryData.key);
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                // Rank
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: AppTheme.captionStyle.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // Category Icon
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppTheme.getCategoryColor(categoryData.key).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _getCategoryIcon(categoryData.key),
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // Category Name and Amount
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        categoryData.key,
                        style: AppTheme.subtitleStyle.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${AppConstants.currencySymbol}${categoryData.value.toStringAsFixed(2)}',
                        style: AppTheme.bodyStyle.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMonthlyTrendChart(ExpenseProvider expenseProvider) {
    final monthlyData = _getMonthlyTrendData(expenseProvider);
    
    return SizedBox(
      height: 250,
      child: LineChart(
        LineChartData(
          lineTouchData: LineTouchData(
            enabled: true,
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= 0 && value.toInt() < monthlyData.length) {
                    return Text(
                      DateFormat('MMM').format(monthlyData[value.toInt()]['month']),
                      style: AppTheme.captionStyle.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '${AppConstants.currencySymbol}${value.toInt()}',
                    style: AppTheme.captionStyle.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  );
                },
              ),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: monthlyData.asMap().entries.map((entry) {
                return FlSpot(entry.key.toDouble(), entry.value['amount']);
              }).toList(),
              isCurved: true,
              color: Theme.of(context).colorScheme.primary,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 4,
                    color: Theme.of(context).colorScheme.primary,
                    strokeWidth: 2,
                    strokeColor: Theme.of(context).colorScheme.surface,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildYearOverYearChart(ExpenseProvider expenseProvider) {
    final yearlyData = _getYearlyTrendData(expenseProvider);
    
    return SizedBox(
      height: 250,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: yearlyData.isNotEmpty 
              ? yearlyData.map((data) => data['amount']).reduce((a, b) => a > b ? a : b) * 1.2
              : 100,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => Theme.of(context).colorScheme.inverseSurface,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final year = yearlyData[group.x.toInt()]['year'];
                final amount = yearlyData[group.x.toInt()]['amount'];
                return BarTooltipItem(
                  '$year\n${AppConstants.currencySymbol}${amount.toStringAsFixed(2)}',
                  TextStyle(
                    color: Theme.of(context).colorScheme.onInverseSurface,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= 0 && value.toInt() < yearlyData.length) {
                    return Text(
                      yearlyData[value.toInt()]['year'].toString(),
                      style: AppTheme.captionStyle.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '${AppConstants.currencySymbol}${value.toInt()}',
                    style: AppTheme.captionStyle.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  );
                },
              ),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          barGroups: yearlyData.asMap().entries.map((entry) {
            return BarChartGroupData(
              x: entry.key,
              barRods: [
                BarChartRodData(
                  toY: entry.value['amount'],
                  color: Theme.of(context).colorScheme.primary,
                  width: 20,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildTrendSummary(ExpenseProvider expenseProvider) {
    final monthlyData = _getMonthlyTrendData(expenseProvider);
    if (monthlyData.length < 2) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'Insufficient data for trend analysis',
          style: AppTheme.bodyStyle.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      );
    }

    final lastMonth = monthlyData.last['amount'];
    final previousMonth = monthlyData[monthlyData.length - 2]['amount'];
    final change = lastMonth - previousMonth;
    final changePercentage = previousMonth != 0 ? (change / previousMonth * 100) : 0;
    
    final averageMonthlySpending = monthlyData.map((data) => data['amount']).reduce((a, b) => a + b) / monthlyData.length;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.trending_up,
                color: change >= 0 ? AppTheme.lightError : AppTheme.success,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Monthly Change',
                style: AppTheme.subtitleStyle.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                '${change >= 0 ? '+' : ''}${AppConstants.currencySymbol}${change.abs().toStringAsFixed(2)}',
                style: AppTheme.titleStyle.copyWith(
                  color: change >= 0 ? AppTheme.lightError : AppTheme.success,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '(${changePercentage >= 0 ? '+' : ''}${changePercentage.toStringAsFixed(1)}%)',
                style: AppTheme.bodyStyle.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Icon(
                Icons.calculate,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Average Monthly',
                style: AppTheme.subtitleStyle.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${AppConstants.currencySymbol}${averageMonthlySpending.toStringAsFixed(2)}',
            style: AppTheme.titleStyle.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _dateRange,
    );
    
    if (picked != null) {
      setState(() {
        _dateRange = picked;
      });
    }
  }

  (DateTime, DateTime) _getDateRange() {
    if (_dateRange != null) {
      return (_dateRange!.start, _dateRange!.end);
    }
    
    final now = DateTime.now();
    switch (_selectedPeriod) {
      case 'weekly':
        final start = now.subtract(Duration(days: now.weekday));
        final end = start.add(const Duration(days: 6));
        return (start, end);
      case 'monthly':
        final start = DateTime(now.year, now.month, 1);
        final end = DateTime(now.year, now.month + 1, 0);
        return (start, end);
      case 'quarterly':
        final quarter = ((now.month - 1) ~/ 3) + 1;
        final start = DateTime(now.year, (quarter - 1) * 3 + 1, 1);
        final end = DateTime(now.year, quarter * 3 + 1, 0);
        return (start, end);
      case 'yearly':
        final start = DateTime(now.year, 1, 1);
        final end = DateTime(now.year, 12, 31);
        return (start, end);
      default:
        final start = DateTime(now.year, now.month, 1);
        final end = DateTime(now.year, now.month + 1, 0);
        return (start, end);
    }
  }

  List<Map<String, dynamic>> _getDailySpendingData(ExpenseProvider expenseProvider, DateTime startDate, DateTime endDate) {
    final expenses = expenseProvider.expenses.where((expense) {
      return !expense.isIncome && 
             expense.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
             expense.date.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
    
    final Map<String, double> dailyExpenses = {};
    for (final expense in expenses) {
      final dateKey = DateFormat('yyyy-MM-dd').format(expense.date);
      dailyExpenses[dateKey] = (dailyExpenses[dateKey] ?? 0) + expense.amount;
    }
    
    final dailyData = <Map<String, dynamic>>[];
    var current = startDate;
    while (current.isBefore(endDate.add(const Duration(days: 1)))) {
      final dateKey = DateFormat('yyyy-MM-dd').format(current);
      dailyData.add({
        'date': current,
        'amount': dailyExpenses[dateKey] ?? 0.0,
      });
      current = current.add(const Duration(days: 1));
    }
    
    return dailyData;
  }

  List<Map<String, dynamic>> _getMonthlyTrendData(ExpenseProvider expenseProvider) {
    final expenses = expenseProvider.expenses.where((expense) => !expense.isIncome).toList();
    final Map<String, double> monthlyExpenses = {};
    
    for (final expense in expenses) {
      final monthKey = DateFormat('yyyy-MM').format(expense.date);
      monthlyExpenses[monthKey] = (monthlyExpenses[monthKey] ?? 0) + expense.amount;
    }
    
    final sortedMonths = monthlyExpenses.keys.toList()..sort();
    final monthlyData = <Map<String, dynamic>>[];
    
    for (final monthKey in sortedMonths) {
      monthlyData.add({
        'month': DateFormat('yyyy-MM').parse(monthKey),
        'amount': monthlyExpenses[monthKey]!,
      });
    }
    
    return monthlyData;
  }

  List<Map<String, dynamic>> _getYearlyTrendData(ExpenseProvider expenseProvider) {
    final expenses = expenseProvider.expenses.where((expense) => !expense.isIncome).toList();
    final Map<int, double> yearlyExpenses = {};
    
    for (final expense in expenses) {
      final year = expense.date.year;
      yearlyExpenses[year] = (yearlyExpenses[year] ?? 0) + expense.amount;
    }
    
    final sortedYears = yearlyExpenses.keys.toList()..sort();
    final yearlyData = <Map<String, dynamic>>[];
    
    for (final year in sortedYears) {
      yearlyData.add({
        'year': year,
        'amount': yearlyExpenses[year]!,
      });
    }
    
    return yearlyData;
  }

  double _getPercentage(double value, double total) {
    if (total == 0) return 0;
    return (value / total) * 100;
  }

  String _getPeriodText() {
    if (_dateRange != null) {
      return '${DateFormat('MMM dd').format(_dateRange!.start)} - ${DateFormat('MMM dd').format(_dateRange!.end)}';
    }
    
    switch (_selectedPeriod) {
      case 'weekly':
        return 'This week';
      case 'monthly':
        return 'This month';
      case 'quarterly':
        return 'This quarter';
      case 'yearly':
        return 'This year';
      default:
        return 'This month';
    }
  }

  String _getCategoryIcon(String categoryName) {
    final icons = {
      'Food & Dining': '🍔',
      'Transportation': '🚗',
      'Shopping': '🛍️',
      'Bills & Utilities': '📄',
      'Entertainment': '🎮',
      'Health & Fitness': '🏃',
      'Education': '📚',
      'Travel': '✈️',
      'Personal Care': '💄',
      'Gifts & Donations': '🎁',
    };
    return icons[categoryName] ?? '💳';
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
