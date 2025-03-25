import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';

import '../../model/prodact_model.dart';
import '../../provider/prodact_provider.dart';
import 'add_prodact.dart';
import 'edit_product.dart';
import 'prodacts_detail.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  _ProductsScreenState createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  int currentPage = 1;
  bool isLoadingMore = false;
  String searchQuery = '';
  bool selectAll = false;
  final List<int> selectedProducts = [];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent &&
          !isLoadingMore) {
        loadMoreProducts();
      }
    });
    _searchController.addListener(() {
      setState(() {
        searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> loadMoreProducts() async {
    setState(() {
      isLoadingMore = true;
    });
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      currentPage++;
      isLoadingMore = false;
    });
  }

  List<Product> searchProducts(List<Product> products) {
    if (searchQuery.isEmpty) return products;
    return products.where((product) {
      final deliveryNumber = product.deliverynumber.toLowerCase();
      final dealerName = product.dealer.name.toLowerCase();
      final vendorName = product.vendor.name.toLowerCase();
      return deliveryNumber.contains(searchQuery.toLowerCase()) ||
          dealerName.contains(searchQuery.toLowerCase()) ||
          vendorName.contains(searchQuery.toLowerCase());
    }).toList();
  }

  void toggleSelectAll(List<Product> products) {
    setState(() {
      selectAll = !selectAll;
      selectedProducts.clear();
      if (selectAll) {
        selectedProducts.addAll(products.map((product) => product.id));
      }
    });
  }

  void toggleSelection(int productId) {
    setState(() {
      if (selectedProducts.contains(productId)) {
        selectedProducts.remove(productId);
      } else {
        selectedProducts.add(productId);
      }
    });
  }

  void deleteSelectedProducts(WidgetRef ref) async {
    for (var productId in selectedProducts) {
      await ref.read(prodactNotifierProvider.notifier).deleteProduct(productId);
    }
    ref.refresh(prodactListProvider);
    setState(() {
      selectedProducts.clear();
      selectAll = false;
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('تم حذف الشحنات بنجاح')));
  }

  Future<void> printSelectedProducts(List<int> selectedProducts) async {
    if (selectedProducts.isEmpty) return;

    // تحويل قائمة الـ IDs إلى سلسلة نصية مفصولة بفواصل
    String productIds = selectedProducts.join(',');

    // إنشاء رابط الـ API
    String url =
        'https://alashi.online/backendapi/public/api/printmultiple?product_ids=$productIds';

    try {
      // تنزيل ملف PDF
      var response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        // حفظ الملف المؤقت
        final directory = await getTemporaryDirectory();
        final file = File('${directory.path}/selected_products.pdf');
        await file.writeAsBytes(response.bodyBytes);

        // طباعة الملف
        await Printing.layoutPdf(
          onLayout: (format) async => file.readAsBytes(),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('فشل في تحميل الملف للطباعة')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('خطأ أثناء الطباعة: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final proList = ref.watch(prodactListProvider);
        return Scaffold(
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 40.0),
            child: FloatingActionButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  useSafeArea: true,
                  isScrollControlled: true,
                  builder: (context) {
                    return const AddProdactPage();
                  },
                );
              },
              child: const Icon(Icons.add_shopping_cart_outlined),
            ),
          ),
          appBar: AppBar(
            title: const Text('البضائع'),
            actions: [
              if (selectedProducts.isNotEmpty)
                IconButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('تأكيد الحذف'),
                          content: const Text('هل أنت متأكد من حذف هذه الشحنة'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(false);
                              },
                              child: const Text('لا'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(true);
                                deleteSelectedProducts(ref);
                              },
                              child: const Text('نعم'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  icon: const Icon(Icons.delete_forever_outlined),
                ),
              if (selectedProducts.isNotEmpty)
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.message_outlined),
                ),
              if (selectedProducts.isNotEmpty)
                IconButton(
                  onPressed: () async {
                    try {
                      await printSelectedProducts(selectedProducts);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('فشل في الطباعة: $e')),
                      );
                    }
                  },
                  icon: const Icon(Icons.print_outlined),
                ),
            ],
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Checkbox(
                      value: selectAll,
                      onChanged: (value) {
                        if (proList is AsyncData<Product>) {
                          toggleSelectAll(proList.value?.products ?? []);
                        }
                      },
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'بحث بكود الشحنة أو اسم التاجر أو المورد',
                          hintStyle: Theme.of(context).textTheme.titleSmall,
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: proList.when(
                  data: (newPrdact) {
                    if (newPrdact.products.isEmpty) {
                      return const Center(child: Text('لا يوجد شحنات'));
                    }
                    final searchedProducts = searchProducts(newPrdact.products);
                    final displayedProducts =
                        searchedProducts.take(currentPage * 30).toList();
                    return ListView.builder(
                      controller: _scrollController,
                      itemCount:
                          displayedProducts.length + (isLoadingMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == displayedProducts.length) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        final product = displayedProducts[index];
                        final isSelected = selectedProducts.contains(
                          product.id,
                        );
                        return Dismissible(
                          key: ValueKey(product.id),
                          direction: DismissDirection.horizontal,
                          secondaryBackground: Container(
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            margin: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 18),
                            alignment: Alignment.centerLeft,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                const Icon(
                                  Icons.delete_forever,
                                  color: Colors.white,
                                  size: 30,
                                ),
                                Text(
                                  'حذف',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleSmall!.copyWith(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          background: Container(
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            margin: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 18),
                            alignment: Alignment.centerRight,
                            child: Row(
                              children: [
                                Text(
                                  'تعديل',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleSmall!.copyWith(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                  size: 30,
                                ),
                              ],
                            ),
                          ),
                          onDismissed: (direction) async {
                            if (direction == DismissDirection.startToEnd) {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => EditProduct(id: product.id),
                                ),
                              );

                              ref.refresh(prodactListProvider);
                            } else if (direction ==
                                DismissDirection.endToStart) {
                              await ref
                                  .read(prodactNotifierProvider.notifier)
                                  .deleteProduct(product.id);
                              ref.refresh(prodactListProvider);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('تم حذف الشحنة بنجاح'),
                                ),
                              );
                            }
                          },
                          confirmDismiss: (direction) {
                            if (direction == DismissDirection.endToStart) {
                              return showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text('تأكيد الحذف'),
                                    content: const Text(
                                      'هل أنت متأكد من حذف هذه الشحنة',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop(false);
                                        },
                                        child: const Text('لا'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop(true);
                                        },
                                        child: const Text('نعم'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            } else if (direction ==
                                DismissDirection.startToEnd) {
                              return showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text('تأكيد التعديل'),
                                    content: const Text(
                                      'هل أنت متأكد من تعديل هذه الشحنة',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop(false);
                                        },
                                        child: const Text('لا'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop(true);
                                        },
                                        child: const Text('نعم'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            }
                            return Future.value(true);
                          },
                          child: GestureDetector(
                            onLongPress: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) =>
                                          ProdactsDetail(product: product),
                                ),
                              );
                            },
                            child: Card(
                              color:
                                  isSelected
                                      ? Theme.of(context)
                                          .colorScheme
                                          .secondaryContainer
                                          .withOpacity(0.5)
                                      : Theme.of(
                                        context,
                                      ).colorScheme.secondaryContainer,
                              child: ListTile(
                                leading: CircleAvatar(
                                  radius: 25,
                                  backgroundColor:
                                      Theme.of(
                                        context,
                                      ).colorScheme.primaryContainer,
                                  child: Text(
                                    '${index + 1}',
                                    style:
                                        Theme.of(context).textTheme.titleSmall,
                                  ),
                                ),
                                title: Text(
                                  'رقم الشحنة: ${product.deliverynumber}',
                                ),
                                subtitle: Text('نوع الشحنة: ${product.type}'),
                                trailing: Text('CBM: ${product.cmp}'),
                                onTap: () {
                                  toggleSelection(product.id);
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                  error: (error, stack) => Center(child: Text('Error: $error')),
                  loading:
                      () => const Center(child: CircularProgressIndicator()),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// import '../../model/prodact_model.dart';
// import '../../provider/prodact_provider.dart';
// import 'add_prodact.dart';
// import 'edit_product.dart';
// import 'prodacts_detail.dart';

// class ProductsScreen extends StatefulWidget {
//   const ProductsScreen({super.key});

//   @override
//   _ProductsScreenState createState() => _ProductsScreenState();
// }

// class _ProductsScreenState extends State<ProductsScreen> {
//   final ScrollController _scrollController = ScrollController();
//   final TextEditingController _searchController = TextEditingController();
//   int currentPage = 1;
//   bool isLoadingMore = false;
//   String searchQuery = '';
//   bool selectAll = false;
//   final List<int> selectedProducts = [];

//   @override
//   void initState() {
//     super.initState();
//     _scrollController.addListener(() {
//       if (_scrollController.position.pixels >=
//               _scrollController.position.maxScrollExtent &&
//           !isLoadingMore) {
//         loadMoreProducts();
//       }
//     });
//     _searchController.addListener(() {
//       setState(() {
//         searchQuery = _searchController.text;
//       });
//     });
//   }

//   @override
//   void dispose() {
//     _scrollController.dispose();
//     _searchController.dispose();
//     super.dispose();
//   }

//   Future<void> loadMoreProducts() async {
//     setState(() {
//       isLoadingMore = true;
//     });
//     await Future.delayed(const Duration(seconds: 1));
//     setState(() {
//       currentPage++;
//       isLoadingMore = false;
//     });
//   }

//   List<Product> searchProducts(List<Product> products) {
//     if (searchQuery.isEmpty) return products;
//     return products.where((product) {
//       final deliveryNumber = product.deliverynumber.toLowerCase();
//       final dealerName = product.dealer.name.toLowerCase();
//       final vendorName = product.vendor.name.toLowerCase();
//       return deliveryNumber.contains(searchQuery.toLowerCase()) ||
//           dealerName.contains(searchQuery.toLowerCase()) ||
//           vendorName.contains(searchQuery.toLowerCase());
//     }).toList();
//   }

//   void toggleSelectAll(List<Product> products) {
//     setState(() {
//       selectAll = !selectAll;
//       selectedProducts.clear();
//       if (selectAll) {
//         selectedProducts.addAll(products.map((product) => product.id));
//       }
//     });
//   }

//   void toggleSelection(int productId) {
//     setState(() {
//       if (selectedProducts.contains(productId)) {
//         selectedProducts.remove(productId);
//       } else {
//         selectedProducts.add(productId);
//       }
//     });
//   }

//   void deleteSelectedProducts(WidgetRef ref) async {
//     for (var productId in selectedProducts) {
//       await ref.read(prodactNotifierProvider.notifier).deleteProduct(productId);
//     }
//     ref.refresh(prodactListProvider);
//     setState(() {
//       selectedProducts.clear();
//       selectAll = false;
//     });
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('تم حذف الشحنات بنجاح')),
//     );
//   }

//   Future<void> _downloadPdf(int productId) async {
//     String url = 'https://alashi.online/backendapi/public/api/productdetails/$productId';
//     String fileName = 'product_$productId';

//     String? filePath = await _pdfService.downloadAndSavePdf(url, fileName);
//     if (filePath != null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('تم حفظ الملف في: $filePath')),
//       );
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('فشل في تحميل الملف')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Consumer(
//       builder: (context, ref, child) {
//         final proList = ref.watch(prodactListProvider);
//         return Scaffold(
//           floatingActionButton: Padding(
//             padding: const EdgeInsets.only(bottom: 40.0),
//             child: FloatingActionButton(
//               onPressed: () {
//                 showModalBottomSheet(
//                   context: context,
//                   useSafeArea: true,
//                   isScrollControlled: true,
//                   builder: (context) {
//                     return const AddProdactPage();
//                   },
//                 );
//               },
//               child: const Icon(Icons.add_shopping_cart_outlined),
//             ),
//           ),
//           appBar: AppBar(
//             title: const Text('البضائع'),
//             actions: [
//               if (selectedProducts.isNotEmpty)
//                 IconButton(
//                   onPressed: () {
//                     showDialog(
//                       context: context,
//                       builder: (context) {
//                         return AlertDialog(
//                           title: const Text('تأكيد الحذف'),
//                           content: const Text('هل أنت متأكد من حذف هذه الشحنة'),
//                           actions: [
//                             TextButton(
//                               onPressed: () {
//                                 Navigator.of(context).pop(false);
//                               },
//                               child: const Text('لا'),
//                             ),
//                             TextButton(
//                               onPressed: () {
//                                 Navigator.of(context).pop(true);
//                                 deleteSelectedProducts(ref);
//                               },
//                               child: const Text('نعم'),
//                             ),
//                           ],
//                         );
//                       },
//                     );
//                   },
//                   icon: const Icon(Icons.delete_forever_outlined),
//                 ),
//               if (selectedProducts.isNotEmpty)
//                 IconButton(
//                   onPressed: () {},
//                   icon: const Icon(Icons.message_outlined),
//                 ),
//               if (selectedProducts.isNotEmpty)
//                 IconButton(
//                   onPressed: () {
//                     },
//                   icon: const Icon(Icons.print_outlined),
//                 ),
//             ],
//           ),
//           body: Column(
//             children: [
//               Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Row(
//                   children: [
//                     Checkbox(
//                       value: selectAll,
//                       onChanged: (value) {
//                         if (proList is AsyncData<Product>) {
//                           toggleSelectAll(proList.value?.products ?? []);
//                         }
//                       },
//                     ),
//                     const SizedBox(width: 16),
//                     Expanded(
//                       child: TextFormField(
//                         controller: _searchController,
//                         decoration: InputDecoration(
//                           hintText: 'بحث بكود الشحنة أو اسم التاجر أو المورد',
//                           hintStyle: Theme.of(context).textTheme.titleSmall,
//                           prefixIcon: const Icon(Icons.search),
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12.0),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               Expanded(
//                 child: proList.when(
//                   data: (newPrdact) {
//                     if (newPrdact.products.isEmpty) {
//                       return const Center(child: Text('لا يوجد شحنات'));
//                     }
//                     final searchedProducts = searchProducts(newPrdact.products);
//                     final displayedProducts =
//                         searchedProducts.take(currentPage * 30).toList();
//                     return ListView.builder(
//                       controller: _scrollController,
//                       itemCount:
//                           displayedProducts.length + (isLoadingMore ? 1 : 0),
//                       itemBuilder: (context, index) {
//                         if (index == displayedProducts.length) {
//                           return const Center(
//                               child: CircularProgressIndicator());
//                         }
//                         final product = displayedProducts[index];
//                         final isSelected =
//                             selectedProducts.contains(product.id);
//                         return Dismissible(
//                           key: ValueKey(product.id),
//                           direction: DismissDirection.horizontal,
//                           secondaryBackground: Container(
//                             decoration: BoxDecoration(
//                               color: Colors.red,
//                               borderRadius: BorderRadius.circular(10),
//                             ),
//                             margin: const EdgeInsets.symmetric(
//                                 horizontal: 10, vertical: 8),
//                             padding: const EdgeInsets.symmetric(horizontal: 18),
//                             alignment: Alignment.centerLeft,
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.end,
//                               children: [
//                                 const Icon(
//                                   Icons.delete_forever,
//                                   color: Colors.white,
//                                   size: 30,
//                                 ),
//                                 Text('حذف',
//                                     style: Theme.of(context)
//                                         .textTheme
//                                         .titleSmall!
//                                         .copyWith(
//                                             color: Colors.white,
//                                             fontSize: 20,
//                                             fontWeight: FontWeight.bold)),
//                               ],
//                             ),
//                           ),
//                           background: Container(
//                             decoration: BoxDecoration(
//                               color: Colors.green,
//                               borderRadius: BorderRadius.circular(10),
//                             ),
//                             margin: const EdgeInsets.symmetric(
//                                 horizontal: 10, vertical: 8),
//                             padding: const EdgeInsets.symmetric(horizontal: 18),
//                             alignment: Alignment.centerRight,
//                             child: Row(
//                               children: [
//                                 Text('تعديل',
//                                     style: Theme.of(context)
//                                         .textTheme
//                                         .titleSmall!
//                                         .copyWith(
//                                             color: Colors.white,
//                                             fontSize: 20,
//                                             fontWeight: FontWeight.bold)),
//                                 const Icon(
//                                   Icons.edit,
//                                   color: Colors.white,
//                                   size: 30,
//                                 ),
//                               ],
//                             ),
//                           ),
//                           onDismissed: (direction) async {
//                             if (direction == DismissDirection.startToEnd) {
//                               final result = await Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) => EditProduct(
//                                     id: product.id,
//                                     dealerName: product.dealer.id.toString(),
//                                     quantity: product.quantity,
//                                     fiQuantity: product.fiQuantity,
//                                     type: product.type,
//                                     receivingDate: product.receivingDate,
//                                     paidamount: product.paidamount.toString(),
//                                     invoiceValue:
//                                         product.invoiceValue.toString(),
//                                     remainingaamount:
//                                         product.remainingaamount.toString(),
//                                     deliveryaddress:
//                                         product.deliveryaddress.isNotEmpty
//                                             ? product.deliveryaddress
//                                             : "غير متوفر",
//                                     vendorname: product.vendor.name,
//                                     cmp: product.cmp.isNotEmpty
//                                         ? product.cmp
//                                         : "0",
//                                     remarks: product.remarks,
//                                   ),
//                                 ),
//                               );

//                               // تحديث القائمة بعد العودة من صفحة التعديل فقط إذا تم التحديث
//                               if (result == true) {
//                                 ref.refresh(prodactListProvider);
//                               }
//                             } else if (direction ==
//                                 DismissDirection.endToStart) {
//                               await ref
//                                   .read(prodactNotifierProvider.notifier)
//                                   .deleteProduct(product.id);
//                               ref.refresh(prodactListProvider);
//                               ScaffoldMessenger.of(context).showSnackBar(
//                                 const SnackBar(
//                                     content: Text('تم حذف الشحنة بنجاح')),
//                               );
//                             }
//                           },
//                           confirmDismiss: (direction) {
//                             if (direction == DismissDirection.endToStart) {
//                               return showDialog(
//                                 context: context,
//                                 builder: (context) {
//                                   return AlertDialog(
//                                     title: const Text('تأكيد الحذف'),
//                                     content: const Text(
//                                         'هل أنت متأكد من حذف هذه الشحنة'),
//                                     actions: [
//                                       TextButton(
//                                         onPressed: () {
//                                           Navigator.of(context).pop(false);
//                                         },
//                                         child: const Text('لا'),
//                                       ),
//                                       TextButton(
//                                         onPressed: () {
//                                           Navigator.of(context).pop(true);
//                                         },
//                                         child: const Text('نعم'),
//                                       ),
//                                     ],
//                                   );
//                                 },
//                               );
//                             } else if (direction ==
//                                 DismissDirection.startToEnd) {
//                               return showDialog(
//                                 context: context,
//                                 builder: (context) {
//                                   return AlertDialog(
//                                     title: const Text('تأكيد التعديل'),
//                                     content: const Text(
//                                         'هل أنت متأكد من تعديل هذه الشحنة'),
//                                     actions: [
//                                       TextButton(
//                                         onPressed: () {
//                                           Navigator.of(context).pop(false);
//                                         },
//                                         child: const Text('لا'),
//                                       ),
//                                       TextButton(
//                                         onPressed: () {
//                                           Navigator.of(context).pop(true);
//                                         },
//                                         child: const Text('نعم'),
//                                       ),
//                                     ],
//                                   );
//                                 },
//                               );
//                             }
//                             return Future.value(true);
//                           },
//                           child: GestureDetector(
//                             onLongPress: () {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) =>
//                                       ProdactsDetail(product: product),
//                                 ),
//                               );
//                             },
//                             child: Card(
//                               color: isSelected
//                                   ? Theme.of(context)
//                                       .colorScheme
//                                       .secondaryContainer
//                                       .withOpacity(0.5)
//                                   : Theme.of(context)
//                                       .colorScheme
//                                       .secondaryContainer,
//                               child: ListTile(
//                                 leading: CircleAvatar(
//                                   radius: 25,
//                                   backgroundColor: Theme.of(context)
//                                       .colorScheme
//                                       .primaryContainer,
//                                   child: Text('${index + 1}',
//                                       style: Theme.of(context)
//                                           .textTheme
//                                           .titleSmall),
//                                 ),
//                                 title: Text(
//                                     'رقم الشحنة: ${product.deliverynumber}'),
//                                 subtitle: Text('نوع الشحنة: ${product.type}'),
//                                 trailing: Text('CBM: ${product.cmp}'),
//                                 onTap: () {
//                                   toggleSelection(product.id);
//                                 },
//                               ),
//                             ),
//                           ),
//                         );
//                       },
//                     );
//                   },
//                   error: (error, stack) => Center(child: Text('Error: $error')),
//                   loading: () =>
//                       const Center(child: CircularProgressIndicator()),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }
