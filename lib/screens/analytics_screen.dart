
import 'package:flutter/material.dart';
import 'package:mint_flow/utils/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/transaction_provider.dart';
import '../providers/category_provider.dart';
import '../models/transaction.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildExpenseChart(context),
          const SizedBox(height: 24),
          _buildCategoryBreakdown(context),
        ],
      ),
    );
  }

  Widget _buildExpenseChart(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Monthly Overview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Consumer<TransactionProvider>(
              builder: (context, provider, child) {
                final transactions = provider.transactions;
                if (transactions.isEmpty) {
                  return const SizedBox(
                    height: 200,
                    child: Center(child: Text('No data available')),
                  );
                }
                
                return SizedBox(
                  height: 200,
                  child: LineChart(
                    LineChartData(
                      gridData: const FlGridData(show: false),
                      titlesData: const FlTitlesData(show: false),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: _generateChartSpots(transactions),
                          isCurved: true,
                          color: Theme.of(context).primaryColor,
                          barWidth: 3,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            color: Theme.of(context).primaryColor.withOpacity(0.1),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  List<FlSpot> _generateChartSpots(List<Transaction> transactions) {
    // Simple implementation - you can enhance this
    final spots = <FlSpot>[];
    for (int i = 0; i < 7 && i < transactions.length; i++) {
      spots.add(FlSpot(i.toDouble(), transactions[i].amount));
    }
    return spots;
  }

  Widget _buildCategoryBreakdown(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Expense Categories', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Consumer2<TransactionProvider, CategoryProvider>(
              builder: (context, transactionProvider, categoryProvider, child) {
                final expenses = transactionProvider.expenses;
                final categories = categoryProvider.expenseCategories;
                
                if (expenses.isEmpty) {
                  return const Center(child: Text('No expense data available'));
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    final categoryExpenses = expenses.where((e) => e.categoryId == category.id).toList();
                    final totalAmount = categoryExpenses.fold(0.0, (sum, e) => sum + e.amount);
                    
                    if (totalAmount == 0) return const SizedBox.shrink();

                    return ListTile(
                      leading: Text(category.icon, style: const TextStyle(fontSize: 24)),
                      title: Text(category.name),
                      trailing: Text(
                        AppHelpers.formatCurrency(totalAmount),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}