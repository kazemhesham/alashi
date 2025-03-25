// import '../../model/vendors_model.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// import '../../provider/vendors_provider.dart';
// import 'add_Vendor.dart';
// import 'edit_Vendor.dart';

// class VendorsScreen extends StatefulWidget {
//   const VendorsScreen({super.key});

//   @override
//   _VendorsScreenState createState() => _VendorsScreenState();
// }

// class _VendorsScreenState extends State<VendorsScreen> {
//   int currentPage = 1; // الصفحة الحالية
//   final ScrollController _scrollController = ScrollController();
//   final TextEditingController _searchController = TextEditingController();
//   bool isLoadingMore = false;
//   String searchQuery = '';
//   bool selectAll = false;
//   final List<int> selectedVendors = [];

//   @override
//   void initState() {
//     // عند النزول للاسفل يجلب المزيد من البيانات
//     _scrollController.addListener(() {
//       if (_scrollController.position.pixels >=
//               _scrollController.position.maxScrollExtent &&
//           !isLoadingMore) {
//         loadMoreProducts();
//       }
//     });

//     // تفعيل خاصية البحث
//     _searchController.addListener(() {
//       setState(() {
//         searchQuery = _searchController.text;
//       });
//     });
//     super.initState();
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

//   List<Vendor> searchVendors(List<Vendor> deal) {
//     if (searchQuery.isEmpty) return deal;

//     return deal.where((vendor) {
//       final vendorNumber = vendor.vendorNumber.toLowerCase();
//       final vendorName = vendor.name.toLowerCase();

//       return vendorNumber.contains(searchQuery.toLowerCase()) ||
//           vendorName.contains(searchQuery.toLowerCase());
//     }).toList();
//   }

//   void toggleSelectAll(List<Vendor> products) {
//     setState(() {
//       selectAll = !selectAll;
//       selectedVendors.clear();
//       if (selectAll) {
//         selectedVendors.addAll(products.map((vend) => vend.id));
//       }
//     });
//   }

//   void toggleSelection(int vendorId) {
//     setState(() {
//       if (selectedVendors.contains(vendorId)) {
//         selectedVendors.remove(vendorId);
//       } else {
//         selectedVendors.add(vendorId);
//       }
//     });
//   }

//   void deleteSelectedProducts(WidgetRef ref) async {
//     for (var productId in selectedVendors) {
//       await ref.read(vendorProvider.notifier).deletVendor(productId);
//     }
//     ref.refresh(vendorsListProvider);
//     setState(() {
//       selectedVendors.clear();
//       selectAll = false;
//     });

//     ScaffoldMessenger.of(
//       context,
//     ).showSnackBar(const SnackBar(content: Text('تم حذف الشحنات بنجاح')));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Consumer(
//       builder: (context, ref, child) {
//         final proList = ref.watch(vendorsListProvider);
//         return Scaffold(
//           appBar: AppBar(
//             title: const Text('الموردين'),
//             actions: [
//               if (selectedVendors.isNotEmpty)
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
//               if (selectedVendors.isNotEmpty)
//                 IconButton(
//                   onPressed: () {
//                     showMessageDialog(context, ref);
//                   },
//                   icon: const Icon(Icons.message_outlined),
//                 ),
//             ],
//           ),
//           floatingActionButton: Padding(
//             padding: const EdgeInsets.only(bottom: 40.0),
//             child: FloatingActionButton(
//               onPressed: () {
//                 showModalBottomSheet(
//                   context: context,
//                   useSafeArea: true,
//                   isScrollControlled: true,
//                   builder: (context) {
//                     return AddVendorPage();
//                   },
//                 );
//               },
//               child: const Icon(Icons.person_add_alt_outlined),
//             ),
//           ),
//           body: Column(
//             children: [
//               Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Row(
//                   children: [
//                     Checkbox(value: selectAll, onChanged: (value) {}),
//                     const SizedBox(width: 16),
//                     Expanded(
//                       child: TextFormField(
//                         controller: _searchController,
//                         decoration: InputDecoration(
//                           hintText: 'بحث بكود المورد أو اسم المورد',
//                           prefixIcon: const Icon(Icons.search),
//                           hintStyle: Theme.of(context).textTheme.titleSmall,
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
//                   data: (pro) {
//                     if (pro.vendors.isEmpty) {
//                       return const Center(child: Text('لا يوجد موردين'));
//                     }

//                     // تفعيل البحث
//                     final searchedProducts = searchVendors(pro.vendors);

//                     // تحديد المنتجات المعروضة في الصفحة الحالية
//                     final displayedVendors =
//                         searchedProducts.take(currentPage * 30).toList();

//                     return ListView.builder(
//                       controller: _scrollController,
//                       itemCount:
//                           displayedVendors.length + (isLoadingMore ? 1 : 0),
//                       itemBuilder: (context, index) {
//                         if (index == displayedVendors.length) {
//                           return const Center(
//                             child: CircularProgressIndicator(),
//                           );
//                         }
//                         final vendors = displayedVendors[index];
//                         final isSelected = selectedVendors.contains(vendors.id);

//                         return Dismissible(
//                           key: ValueKey(vendors.id),
//                           direction: DismissDirection.horizontal,
//                           secondaryBackground: Container(
//                             decoration: BoxDecoration(
//                               color: Colors.red,
//                               borderRadius: BorderRadius.circular(10),
//                             ),
//                             margin: const EdgeInsets.symmetric(
//                               horizontal: 10,
//                               vertical: 8,
//                             ),
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
//                                 Text(
//                                   'حذف',
//                                   style: Theme.of(
//                                     context,
//                                   ).textTheme.titleSmall!.copyWith(
//                                     color: Colors.white,
//                                     fontSize: 20,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           background: Container(
//                             decoration: BoxDecoration(
//                               color: Colors.green,
//                               borderRadius: BorderRadius.circular(10),
//                             ),
//                             margin: const EdgeInsets.symmetric(
//                               horizontal: 10,
//                               vertical: 8,
//                             ),
//                             padding: const EdgeInsets.symmetric(horizontal: 18),
//                             alignment: Alignment.centerRight,
//                             child: Row(
//                               children: [
//                                 Text(
//                                   'تعديل',
//                                   style: Theme.of(
//                                     context,
//                                   ).textTheme.titleSmall!.copyWith(
//                                     color: Colors.white,
//                                     fontSize: 20,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
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
//                               // فتح صفحة التعديل عند السحب لليمين
//                               await Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder:
//                                       (context) => EditVendor(
//                                         vendorId: vendors.id,
//                                         name: vendors.name,
//                                         phone: vendors.phone,
//                                         email: vendors.email,
//                                         address: vendors.adress,
//                                       ),
//                                 ),
//                               );
//                               ref.refresh(vendorsListProvider);
//                             } else if (direction ==
//                                 DismissDirection.endToStart) {
//                               // حذف المورد
//                               await ref
//                                   .read(vendorProvider.notifier)
//                                   .deletVendor(vendors.id);

//                               ref.refresh(vendorsListProvider);
//                               ScaffoldMessenger.of(context).showSnackBar(
//                                 const SnackBar(
//                                   content: Text('تم حذف المورد بنجاح'),
//                                 ),
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
//                                       'هل أنت متأكد من حذف هذا المورد؟',
//                                     ),
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
//                                       'هل أنت متأكد من تعديل هذا المورد؟',
//                                     ),
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
//                             // onLongPress: () {
//                             //   toggleSelection(vendors.id);
//                             // },
//                             child: Card(
//                               color:
//                                   isSelected
//                                       ? Theme.of(context)
//                                           .colorScheme
//                                           .secondaryContainer
//                                           .withOpacity(0.5)
//                                       : Theme.of(
//                                         context,
//                                       ).colorScheme.secondaryContainer,
//                               child: ListTile(
//                                 leading: CircleAvatar(
//                                   radius: 25,
//                                   backgroundColor:
//                                       Theme.of(
//                                         context,
//                                       ).colorScheme.primaryContainer,
//                                   child: Text(
//                                     '${index + 1}',
//                                     style:
//                                         Theme.of(context).textTheme.titleSmall,
//                                   ),
//                                 ),
//                                 title: Text('المورد: ${vendors.name}'),
//                                 subtitle: Text(
//                                   'كود المورد: ${vendors.vendorNumber}',
//                                 ),
//                                 trailing: Text(
//                                   'الشحنات: ${vendors.productCount}',
//                                 ),
//                                 onTap: () {
//                                   toggleSelection(vendors.id);
//                                 },
//                               ),
//                             ),
//                           ),
//                         );
//                       },
//                     );
//                   },
//                   error: (error, stack) => Center(child: Text('Error: $error')),
//                   loading:
//                       () => const Center(child: CircularProgressIndicator()),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../model/vendors_model.dart';
import '../../provider/vendors_provider.dart';
import 'add_Vendor.dart';
import 'edit_Vendor.dart';

class VendorsScreen extends StatefulWidget {
  const VendorsScreen({super.key});

  @override
  _VendorsScreenState createState() => _VendorsScreenState();
}

class _VendorsScreenState extends State<VendorsScreen> {
  int currentPage = 1;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  bool isLoadingMore = false;
  String searchQuery = '';
  bool selectAll = false;
  final List<int> selectedVendors = [];

  @override
  void initState() {
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
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> loadMoreProducts() async {
    if (!isLoadingMore) {
      setState(() {
        isLoadingMore = true;
      });

      await Future.delayed(const Duration(seconds: 1));
      setState(() {
        currentPage++;
        isLoadingMore = false;
      });
    }
  }

  List<Vendor1> searchVendors(List<Vendor1> vendors) {
    if (searchQuery.isEmpty) return vendors;

    return vendors.where((vendor) {
      final vendorNumber = vendor.vendorNumber.toLowerCase();
      final vendorName = vendor.name.toLowerCase();
      final query = searchQuery.toLowerCase();

      return vendorNumber.contains(query) || vendorName.contains(query);
    }).toList();
  }

  void toggleSelectAll(List<Vendor1> vendors) {
    setState(() {
      selectAll = !selectAll;
      if (selectAll) {
        selectedVendors.addAll(vendors.map((vendor) => vendor.id));
      } else {
        selectedVendors.clear();
      }
    });
  }

  void toggleSelection(int vendorId) {
    setState(() {
      if (selectedVendors.contains(vendorId)) {
        selectedVendors.remove(vendorId);
      } else {
        selectedVendors.add(vendorId);
      }
    });
  }

  void deleteSelectedProducts(WidgetRef ref) async {
    for (var vendorId in selectedVendors) {
      await ref.read(vendorProvider.notifier).deletVendor(vendorId);
    }
    ref.refresh(vendorsListProvider);
    setState(() {
      selectedVendors.clear();
      selectAll = false;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('تم حذف الشحنات بنجاح')));
  }

  Future<void> showMessageDialog(BuildContext context) async {
    final TextEditingController messageController = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('إرسال رسالة'),
          content: TextField(
            controller: messageController,
            decoration: const InputDecoration(hintText: 'أدخل الرسالة هنا'),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () async {
                final message = messageController.text.trim();
                if (message.isNotEmpty) {
                  Navigator.of(context).pop();
                  await sendMessageToVendors(message);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('الرجاء إدخال رسالة')),
                  );
                }
              },
              child: const Text('إرسال'),
            ),
          ],
        );
      },
    );
  }

  // دالة لإرسال الرسالة إلى الـ API
  Future<void> sendMessageToVendors(String message) async {
    final url = Uri.parse(
      'https://alashi.online/backendapi/public/api/multiplemessagevendor',
    );
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      'message': message,
      'allSelected': false, // تحديد يدوي
      'selectedVendorIds': selectedVendors,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('تم إرسال الرسالة بنجاح')));
        log("Vendor send message successfully: ${jsonDecode(response.body)}");
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل إرسال الرسالة: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('خطأ أثناء الإرسال: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final proList = ref.watch(vendorsListProvider);
        return Scaffold(
          appBar: AppBar(
            title: const Text('الموردين'),
            actions: [
              if (selectedVendors.isNotEmpty)
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
              if (selectedVendors.isNotEmpty)
                IconButton(
                  onPressed: () {
                    showMessageDialog(context);
                  },
                  icon: const Icon(Icons.message_outlined),
                ),
            ],
          ),
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 40.0),
            child: FloatingActionButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  useSafeArea: true,
                  isScrollControlled: true,
                  builder: (context) {
                    return AddVendorPage();
                  },
                );
              },
              child: const Icon(Icons.person_add_alt_outlined),
            ),
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
                        if (proList is AsyncData<Vendor1>) {
                          toggleSelectAll(proList.value?.vendors ?? []);
                        }
                      },
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'بحث بكود المورد أو اسم المورد',
                          prefixIcon: const Icon(Icons.search),
                          hintStyle: Theme.of(context).textTheme.titleSmall,
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
                  data: (pro) {
                    if (pro.vendors.isEmpty) {
                      return const Center(child: Text('لا يوجد موردين'));
                    }

                    final searchedProducts = searchVendors(pro.vendors);
                    final displayedVendors =
                        searchedProducts.take(currentPage * 30).toList();

                    return ListView.builder(
                      controller: _scrollController,
                      itemCount:
                          displayedVendors.length + (isLoadingMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == displayedVendors.length) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        final vendors = displayedVendors[index];
                        final isSelected = selectedVendors.contains(vendors.id);

                        return Dismissible(
                          key: ValueKey(vendors.id),
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
                                      (context) =>
                                          EditVendor(vendorId: vendors.id),
                                ),
                              );
                              ref.refresh(vendorsListProvider);
                            } else if (direction ==
                                DismissDirection.endToStart) {
                              await ref
                                  .read(vendorProvider.notifier)
                                  .deletVendor(vendors.id);

                              ref.refresh(vendorsListProvider);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('تم حذف المورد بنجاح'),
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
                                      'هل أنت متأكد من حذف هذا المورد؟',
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
                                      'هل أنت متأكد من تعديل هذا المورد؟',
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
                                title: Text('المورد: ${vendors.name}'),
                                subtitle: Text(
                                  'كود المورد: ${vendors.vendorNumber}',
                                ),
                                trailing: Text(
                                  'الشحنات: ${vendors.productCount}',
                                ),
                                onTap: () {
                                  toggleSelection(vendors.id);
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
