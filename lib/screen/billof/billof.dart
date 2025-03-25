import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../model/billof_model.dart';
import '../../provider/billof_provider.dart';
import 'add_Billof.dart';

class BillofScreen extends StatefulWidget {
  const BillofScreen({super.key});

  @override
  _BillofScreenState createState() => _BillofScreenState();
}

class _BillofScreenState extends State<BillofScreen> {
  int currentPage = 1; // الصفحة الحالية
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  bool isLoadingMore = false;
  String searchQuery = '';
  final List<int> selectedBillof = [];

  @override
  void initState() {
    // عند النزول للاسفل يجلب المزيد من البيانات
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent &&
          !isLoadingMore) {
        loadMoreContainers();
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

  Future<void> loadMoreContainers() async {
    setState(() {
      isLoadingMore = true;
    });

    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      currentPage++;
      isLoadingMore = false;
    });
  }

  List<Billoflading> searchContainers(List<Billoflading> cont) {
    if (searchQuery.isEmpty) return cont;

    return cont.where((contain) {
      final billofNumber = contain.billOfLadingNumber.toLowerCase();

      return billofNumber.contains(searchQuery.toLowerCase());
    }).toList();
  }





  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final containersList = ref.watch(billofListProvider);
        return Scaffold(
            appBar: AppBar(
              title: const Text('بوليصة الشحن'),
             
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
                      return AddBillofladingPage();
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
                  child: TextFormField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'بحث برقم البوليصة',
                            prefixIcon: const Icon(Icons.search),
                            hintStyle: Theme.of(context).textTheme.titleSmall,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
                        ),
                      ),
                    
                  
                
                Expanded(
                  child: containersList.when(
                    data: (pro) {
                      if (pro.billoflading.isEmpty) {
                        return const Center(child: Text('لا يوجد تجار'));
                      }

                      // تفعيل البحث
                      final searchedBilloflading =
                          searchContainers(pro.billoflading);

                      // تحديد التجار المعروضة في الصفحة الحالية
                      final displayedBilloflading =
                          searchedBilloflading.take(currentPage * 30).toList();

                      return ListView.builder(
                        controller: _scrollController,
                        itemCount: displayedBilloflading.length +
                            (isLoadingMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == displayedBilloflading.length) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                          final billofla = displayedBilloflading[index];
                          final isSelected =
                              selectedBillof.contains(billofla.id);

                          return Dismissible(
                            key: ValueKey(billofla.id),
                            direction: DismissDirection.horizontal,
                            secondaryBackground: Container(
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 8),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 18),
                              alignment: Alignment.centerLeft,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  const Icon(
                                    Icons.delete_forever,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                  Text('حذف',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall!
                                          .copyWith(
                                              color: Colors.white,
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold))
                                ],
                              ),
                            ),
                            background: Container(
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 8),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 18),
                              alignment: Alignment.centerRight,
                              child: Row(
                                children: [
                                  Text('تعديل',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall!
                                          .copyWith(
                                              color: Colors.white,
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold)),
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
                              //   // فتح صفحة التعديل عند السحب لليمين
                              //   await Navigator.push(
                              //     context,
                              //     MaterialPageRoute(
                              //       builder: (context) => EditContainrsPage(
                              //         contid: billofla.id,
                              //         contNumbe: billofla.contNumber,
                              //         contWeigh: billofla.contWeight,
                              //         contParcelsCoun: billofla.contParcelsCount,
                              //         contRemark: billofla.contRemarks,
                              //       ),
                              //     ),
                              //   );
                              //   ref.refresh(containrsListProvider);
                              } else if (direction ==
                                  DismissDirection.endToStart) {
                                // حذف البوليصة
                                await ref
                                    .read(billofladingNotifierProvider.notifier)
                                    .deleteBilloflading(billofla.id);

                                ref.refresh(billofListProvider);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('تم حذف البوليصة بنجاح')),
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
                                          'هل أنت متأكد من حذف هذه البوليصة'),
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
                                          'هل أنت متأكد من تعديل هذه البوليصة'),
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
                                color: isSelected
                                    ? Theme.of(context)
                                        .colorScheme
                                        .secondaryContainer
                                        .withOpacity(0.5)
                                    : Theme.of(context)
                                        .colorScheme
                                        .secondaryContainer,
                                child: ListTile(
                                  leading: CircleAvatar(
                                    radius: 25,
                                    backgroundColor: Theme.of(context)
                                        .colorScheme
                                        .primaryContainer,
                                    child: Text('${index + 1}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall),
                                  ),
                                  title: Text(
                                      'رقم البوليصة: ${billofla.billOfLadingNumber}'),
                                  subtitle: Text(
                                      'نوع الشحن: ${billofla.shippingType}'),
                                  trailing: Text(
                                      'عدد الحاويات: ${billofla.containerNum}'),
                                  onTap: () {
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                    error: (error, stack) =>
                        Center(child: Text('Error: $error')),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                  ),
                ),
              ],
            ));
      },
    );
  }
}
