
import 'package:flutter/material.dart';
import 'package:mint_flow/utils/app_theme.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/category_provider.dart';
import '../models/transaction.dart';
import 'add_transaction_screen.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<TransactionProvider, CategoryProvider>(
      builder: (context, transactionProvider, categoryProvider, child) {
        final transactions = transactionProvider.transactions;

        if (transactions.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No transactions yet', style: TextStyle(fontSize: 18)),
                SizedBox(height: 8),
                Text('Add your first transaction to get started!'),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: transactions.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final transaction = transactions[index];
            final category = categoryProvider.getCategoryById(transaction.categoryId);
            
            return Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Color(category?.color ?? Colors.grey.value).withOpacity(0.1),
                  child: Text(category?.icon ?? '📋', style: const TextStyle(fontSize: 20)),
                ),
                title: Text(transaction.description, style: const TextStyle(fontWeight: FontWeight.w500)),
                subtitle: Text('${category?.name ?? 'Unknown'} • ${AppHelpers.formatDate(transaction.date)}'),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${transaction.type == TransactionType.expense ? '-' : '+'}${AppHelpers.formatCurrency(transaction.amount)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: transaction.type == TransactionType.expense ? Colors.red : Colors.green,
                      ),
                    ),
                    Text(AppHelpers.getTimeAgo(transaction.date), style: const TextStyle(fontSize: 10, color: Colors.grey)),
                  ],
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => AddTransactionScreen(transaction: transaction),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}