import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/category.dart';
import '../models/transaction_provider.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  // final _formKey = GlobalKey<FormState>();
  // final _nameController = TextEditingController();
  // String _selectedIcon = '📝';

  // final List<String> _availableIcons = [
  //   '💰',
  //   '💻',
  //   '🎁',
  //   '📈',
  //   '🏠',
  //   '⚡',
  //   '📱',
  //   '🎯',
  //   '🍽️',
  //   '🚗',
  //   '🛒',
  //   '🎬',
  //   '🏥',
  //   '📚',
  //   '📄',
  //   '✈️',
  //   '👕',
  //   '🎵',
  //   '☕',
  //   '🍔',
  //   '🚌',
  //   '⛽',
  //   '🏋️',
  //   '💄',
  //   '🎮',
  //   '📺',
  //   '🎪',
  //   '🎨',
  //   '📷',
  //   '🎸',
  //   '⚽',
  //   '🏊',
  // ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Load categories when page is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TransactionProvider>(context, listen: false).loadCategories();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    // _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kategori'),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Pemasukan'),
            Tab(text: 'Pengeluaran'),
          ],
        ),
      ),
      body: Consumer<TransactionProvider>(
        builder: (context, provider, child) {
          return TabBarView(
            controller: _tabController,
            children: [
              _buildCategoryList(provider.incomeCategories, 'income'),
              _buildCategoryList(provider.expenseCategories, 'expense'),
            ],
          );
        },
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     Navigator.push(
      //       context,
      //       MaterialPageRoute(
      //         builder: (context) => AddCategoryPage(
      //           initialType: _tabController.index == 0 ? 'income' : 'expense',
      //         ),
      //       ),
      //     );
      //   },
      //   backgroundColor: Colors.blue.shade600,
      //   child: const Icon(Icons.add, color: Colors.white),
      // ),
    );
  }

  Widget _buildCategoryList(List<Category> categories, String type) {
    return categories.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.category_outlined,
                  size: 80,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'Belum ada kategori',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tambah kategori baru dengan menekan tombol +',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: type == 'income'
                        ? Colors.green.shade100
                        : Colors.red.shade100,
                    child: Text(
                      category.icon,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                  title: Text(
                    category.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _showDeleteDialog(category),
                  ),
                ),
              );
            },
          );
  }

  // void _showAddCategoryDialog() {
  //   _nameController.clear();
  //   _selectedIcon = '📝';

  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: const Text('Tambah Kategori'),
  //         content: StatefulBuilder(
  //           builder: (BuildContext context, StateSetter setState) {
  //             return SingleChildScrollView(
  //               child: Form(
  //                 key: _formKey,
  //                 child: Column(
  //                   mainAxisSize: MainAxisSize.min,
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     const Text(
  //                       'Pilih Icon:',
  //                       style: TextStyle(fontWeight: FontWeight.bold),
  //                     ),
  //                     const SizedBox(height: 8),
  //                     Container(
  //                       height: 150,
  //                       decoration: BoxDecoration(
  //                         border: Border.all(color: Colors.grey.shade300),
  //                         borderRadius: BorderRadius.circular(8),
  //                       ),
  //                       child: GridView.builder(
  //                         padding: const EdgeInsets.all(8),
  //                         gridDelegate:
  //                             const SliverGridDelegateWithFixedCrossAxisCount(
  //                           crossAxisCount: 6,
  //                           mainAxisSpacing: 8,
  //                           crossAxisSpacing: 8,
  //                         ),
  //                         itemCount: _availableIcons.length,
  //                         itemBuilder: (context, index) {
  //                           final icon = _availableIcons[index];
  //                           final isSelected = icon == _selectedIcon;
  //                           return GestureDetector(
  //                             onTap: () {
  //                               setState(() {
  //                                 _selectedIcon = icon;
  //                               });
  //                             },
  //                             child: Container(
  //                               decoration: BoxDecoration(
  //                                 color:
  //                                     isSelected ? Colors.blue.shade100 : null,
  //                                 borderRadius: BorderRadius.circular(4),
  //                                 border: isSelected
  //                                     ? Border.all(color: Colors.blue)
  //                                     : Border.all(color: Colors.grey.shade300),
  //                               ),
  //                               child: Center(
  //                                 child: Text(
  //                                   icon,
  //                                   style: const TextStyle(fontSize: 24),
  //                                 ),
  //                               ),
  //                             ),
  //                           );
  //                         },
  //                       ),
  //                     ),
  //                     const SizedBox(height: 16),
  //                     TextFormField(
  //                       controller: _nameController,
  //                       decoration: const InputDecoration(
  //                         labelText: 'Nama Kategori',
  //                         border: OutlineInputBorder(),
  //                       ),
  //                       validator: (value) {
  //                         if (value == null || value.isEmpty) {
  //                           return 'Nama kategori tidak boleh kosong';
  //                         }
  //                         return null;
  //                       },
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             );
  //           },
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () => Navigator.pop(context),
  //             child: const Text('Batal'),
  //           ),
  //           ElevatedButton(
  //             onPressed: () {
  //               if (_formKey.currentState!.validate()) {
  //                 final category = Category(
  //                   name: _nameController.text,
  //                   icon: _selectedIcon,
  //                   type: _tabController.index == 0 ? 'income' : 'expense',
  //                 );

  //                 Provider.of<TransactionProvider>(context, listen: false)
  //                     .addCategory(category);

  //                 Navigator.pop(context);

  //                 ScaffoldMessenger.of(context).showSnackBar(
  //                   const SnackBar(
  //                       content: Text('Kategori berhasil ditambahkan')),
  //                 );
  //               }
  //             },
  //             style: ElevatedButton.styleFrom(
  //               backgroundColor: Colors.blue.shade600,
  //               foregroundColor: Colors.white,
  //             ),
  //             child: const Text('Simpan'),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  void _showDeleteDialog(Category category) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Hapus Kategori'),
          content: Text(
              'Apakah Anda yakin ingin menghapus kategori "${category.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                if (category.id != null) {
                  Provider.of<TransactionProvider>(context, listen: false)
                      .deleteCategory(category.id!);
                }
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Kategori berhasil dihapus')),
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
