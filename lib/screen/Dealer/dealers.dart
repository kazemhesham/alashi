import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../model/dealer_model.dart';
import '../../provider/dealer_provider.dart';
import 'add_Dealer.dart';
import 'edit_Dealer.dart';

class DealersScreen extends StatefulWidget {
  const DealersScreen({super.key});

  @override
  _DealersScreenState createState() => _DealersScreenState();
}

class _DealersScreenState extends State<DealersScreen> {
  int currentPage = 1; // الصفحة الحالية
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  bool isLoadingMore = false;
  String searchQuery = '';
  bool selectAll = false;
  final List<int> selectedDealers = [];

  @override
  void initState() {
    // عند النزول للاسفل يجلب المزيد من البيانات
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent &&
          !isLoadingMore) {
        loadMoreProducts();
      }
    });

    // تفعيل خاصية البحث
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
    setState(() {
      isLoadingMore = true;
    });

    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      currentPage++;
      isLoadingMore = false;
    });
  }

  List<Dealer1> searchDealers(List<Dealer1> deal) {
    if (searchQuery.isEmpty) return deal;

    return deal.where((dealer) {
      final dealerNumber = dealer.dealerNumber.toLowerCase();
      final dealerName = dealer.name.toLowerCase();

      return dealerNumber.contains(searchQuery.toLowerCase()) ||
          dealerName.contains(searchQuery.toLowerCase());
    }).toList();
  }

  void toggleSelectAll(List<Dealer1> dealerss) {
    setState(() {
      selectAll = !selectAll;
      selectedDealers.clear();
      if (selectAll) {
        selectedDealers.addAll(dealerss.map((vend) => vend.id));
      }
    });
  }

  void toggleSelection(int dealerId) {
    setState(() {
      if (selectedDealers.contains(dealerId)) {
        selectedDealers.remove(dealerId);
      } else {
        selectedDealers.add(dealerId);
      }
    });
  }

  void deleteSelectedDealers(WidgetRef ref) async {
    for (var dealerId in selectedDealers) {
      await ref.read(dealerProvider.notifier).deletDealer(dealerId);
    }
    ref.refresh(dealersListProvider);
    setState(() {
      selectedDealers.clear();
      selectAll = false;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('تم حذف التاجر بنجاح')));
  }

  // دالة لعرض مربع الحوار لإدخال الرسالة
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
                  await sendMessageToDealers(message);
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
  Future<void> sendMessageToDealers(String message) async {
    final url = Uri.parse(
      'https://alashi.online/backendapi/public/api/multiplemessagedealer',
    );
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      'message': message,
      'allSelected': false, // تحديد يدوي
      'selectedDealerIds': selectedDealers,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('تم إرسال الرسالة بنجاح')));
        log("Dealers send message successfully: ${jsonDecode(response.body)}");
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
        final dealerList = ref.watch(dealersListProvider);
        return Scaffold(
          appBar: AppBar(
            title: const Text('التجار'),
            actions: [
              if (selectedDealers.isNotEmpty)
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
                                deleteSelectedDealers(ref);
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
              if (selectedDealers.isNotEmpty)
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
                    return AddDealerPage();
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
                    Checkbox(value: selectAll, onChanged: (value) {}),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'بحث بكود التاجر أو اسم التاجر',
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
                child: dealerList.when(
                  data: (pro) {
                    if (pro.dealers.isEmpty) {
                      return const Center(child: Text('لا يوجد تجار'));
                    }

                    // تفعيل البحث
                    final searchedProducts = searchDealers(pro.dealers);

                    // تحديد التجار المعروضة في الصفحة الحالية
                    final displayedDealers =
                        searchedProducts.take(currentPage * 30).toList();

                    return ListView.builder(
                      controller: _scrollController,
                      itemCount:
                          displayedDealers.length + (isLoadingMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == displayedDealers.length) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        final dealerss = displayedDealers[index];
                        final isSelected = selectedDealers.contains(
                          dealerss.id,
                        );

                        return Dismissible(
                          key: ValueKey(dealerss.id),
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
                              // فتح صفحة التعديل عند السحب لليمين
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) =>
                                          EditDealer(dealerId: dealerss.id),
                                ),
                              );
                              ref.refresh(dealersListProvider);
                            } else if (direction ==
                                DismissDirection.endToStart) {
                              // حذف المورد
                              await ref
                                  .read(dealerProvider.notifier)
                                  .deletDealer(dealerss.id);

                              ref.refresh(dealersListProvider);
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
                            // onLongPress: () {
                            //   toggleSelection(dealerss.id);
                            // },
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
                                title: Text('التاجر: ${dealerss.name}'),
                                subtitle: Text(
                                  'كود التاجر: ${dealerss.dealerNumber}',
                                ),
                                trailing: Text(
                                  'الشحنات: ${dealerss.productCount}',
                                ),
                                onTap: () {
                                  toggleSelection(dealerss.id);
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
