import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/transaction_provider.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  String _filterType = 'all';
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();
  bool _filterByDate = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Transaksi'),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
      ),
      body: Consumer<TransactionProvider>(
        builder: (context, provider, child) {
          final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ');
          
          var filteredTransactions = provider.transactions;
          
          // Filter by type
          if (_filterType != 'all') {
            filteredTransactions = filteredTransactions
                .where((t) => t.type == _filterType)
                .toList();
          }
          
          // Filter by search
          if (_searchController.text.isNotEmpty) {
            filteredTransactions = filteredTransactions
                .where((t) => 
                    t.category.toLowerCase().contains(_searchController.text.toLowerCase()) ||
                    (t.note?.toLowerCase().contains(_searchController.text.toLowerCase()) ?? false))
                .toList();
          }

          // Filter by date if enabled
          if (_filterByDate) {
            filteredTransactions = filteredTransactions.where((t) {
              return t.date.isAfter(_startDate.subtract(Duration(days: 1))) && 
                     t.date.isBefore(_endDate.add(Duration(days: 1)));
            }).toList();
          }

          return Column(
            children: [
              // Search and Filter
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Search Bar
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Cari transaksi...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                      ),
                      onChanged: (value) {
                        setState(() {});
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Filter Buttons
                    Row(
                      children: [
                        Expanded(
                          child: _buildFilterButton('Semua', 'all'),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildFilterButton('Pemasukan', 'income'),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildFilterButton('Pengeluaran', 'expense'),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Date Filter Section
                    Row(
                      children: [
                        Checkbox(
                          value: _filterByDate,
                          onChanged: (value) {
                            setState(() {
                              _filterByDate = value ?? false;
                            });
                          },
                        ),
                        const Text('Filter berdasarkan tanggal'),
                      ],
                    ),
                    
                    if (_filterByDate) ...[
                      const SizedBox(height: 8),
                      // Start Date Picker
                      InkWell(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _startDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (date != null) {
                            setState(() {
                              _startDate = date;
                            });
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today),
                              const SizedBox(width: 8),
                              Text(DateFormat('dd/MM/yyyy').format(_startDate)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // End Date Picker
                      InkWell(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _endDate,
                            firstDate: _startDate,
                            lastDate: DateTime.now(),
                          );
                          if (date != null) {
                            setState(() {
                              _endDate = date;
                            });
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today),
                              const SizedBox(width: 8),
                              Text(DateFormat('dd/MM/yyyy').format(_endDate)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              // Transaction List
              Expanded(
                child: filteredTransactions.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inbox,
                              size: 80,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Tidak ada transaksi',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filteredTransactions.length,
                        itemBuilder: (context, index) {
                          final transaction = filteredTransactions[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: transaction.type == 'income'
                                    ? Colors.green.shade100
                                    : Colors.red.shade100,
                                child: Icon(
                                  transaction.type == 'income'
                                      ? Icons.trending_up
                                      : Icons.trending_down,
                                  color: transaction.type == 'income'
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                              title: Text(
                                transaction.category,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (transaction.note != null)
                                    Text(transaction.note!),
                                  Text(
                                    DateFormat('dd MMM yyyy, HH:mm').format(transaction.date),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '${transaction.type == 'income' ? '+' : '-'}${formatter.format(transaction.amount)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: transaction.type == 'income'
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () {
                                      _showDeleteDialog(context, provider, transaction.id!);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterButton(String title, String type) {
    final isSelected = _filterType == type;
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _filterType = type;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.blue.shade600 : Colors.grey.shade200,
        foregroundColor: isSelected ? Colors.white : Colors.black,
        padding: const EdgeInsets.symmetric(vertical: 8),
      ),
      child: Text(title, style: const TextStyle(fontSize: 12)),
    );
  }

  void _showDeleteDialog(BuildContext context, TransactionProvider provider, int transactionId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Hapus Transaksi'),
          content: const Text('Apakah Anda yakin ingin menghapus transaksi ini?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                provider.deleteTransaction(transactionId);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Transaksi berhasil dihapus')),
                );
              },
              child: const Text('Hapus', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}