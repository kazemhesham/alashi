import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../model/containrs_model.dart';
import '../../provider/containrs_provider.dart';
import 'add_Containrs.dart';
import 'edit_Containrs.dart';

class ContainrsScreen extends StatefulWidget {
  const ContainrsScreen({super.key});

  @override
  _ContainrsScreenState createState() => _ContainrsScreenState();
}

class _ContainrsScreenState extends State<ContainrsScreen> {
  int currentPage = 1; // الصفحة الحالية
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  bool isLoadingMore = false;
  String searchQuery = '';
  bool selectAll = false;
  final List<int> selectedContainrs = [];

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

  List<Containrs> searchContainers(List<Containrs> cont) {
    if (searchQuery.isEmpty) return cont;

    return cont.where((contain) {
      final containrNumber = contain.contNumber.toLowerCase();

      return containrNumber.contains(searchQuery.toLowerCase());
    }).toList();
  }

  void toggleSelectAll(List<Containrs> containss) {
    setState(() {
      selectAll = !selectAll;
      selectedContainrs.clear();
      if (selectAll) {
        selectedContainrs.addAll(containss.map((vend) => vend.id));
      }
    });
  }

  void toggleSelection(int containssId) {
    setState(() {
      if (selectedContainrs.contains(containssId)) {
        selectedContainrs.remove(containssId);
      } else {
        selectedContainrs.add(containssId);
      }
    });
  }

  void deleteSelectedDealers(WidgetRef ref) async {
    for (var containId in selectedContainrs) {
      await ref
          .read(containrNotifierProvider.notifier)
          .deleteContainrs(containId);
    }
    ref.refresh(containrsListProvider);
    setState(() {
      selectedContainrs.clear();
      selectAll = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم حذف التاجر بنجاح')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final containersList = ref.watch(containrsListProvider);
        return Scaffold(
            appBar: AppBar(
              title: const Text('الحاويات'),
              actions: [
                if (selectedContainrs.isNotEmpty)
                IconButton(
                    onPressed: () {}, icon: const Icon(Icons.message_outlined)),
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
                      return AddContainrsPage();
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
                        onChanged: (value) {},
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'بحث برقم الحاوية',
                            prefixIcon: const Icon(Icons.search),
                            hintStyle: Theme.of(context).textTheme.titleSmall,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: containersList.when(
                    data: (pro) {
                      if (pro.containers.isEmpty) {
                        return const Center(child: Text('لا يوجد تجار'));
                      }

                      // تفعيل البحث
                      final searchedContainers =
                          searchContainers(pro.containers);

                      // تحديد التجار المعروضة في الصفحة الحالية
                      final displayedContainers =
                          searchedContainers.take(currentPage * 30).toList();

                      return ListView.builder(
                        controller: _scrollController,
                        itemCount: displayedContainers.length +
                            (isLoadingMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == displayedContainers.length) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                          final containrss = displayedContainers[index];
                          final isSelected =
                              selectedContainrs.contains(containrss.id);

                          return Dismissible(
                            key: ValueKey(containrss.id),
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
                                // فتح صفحة التعديل عند السحب لليمين
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditContainrsPage(
                                      contid: containrss.id,
                                      contNumbe: containrss.contNumber,
                                      contWeigh: containrss.contWeight,
                                      contParcelsCoun: containrss.contParcelsCount,
                                      contRemark: containrss.contRemarks,
                                    ),
                                  ),
                                );
                                ref.refresh(containrsListProvider);
                              } else if (direction ==
                                  DismissDirection.endToStart) {
                                // حذف الحاوية
                                await ref
                                    .read(containrNotifierProvider.notifier)
                                    .deleteContainrs(containrss.id);

                                ref.refresh(containrsListProvider);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('تم حذف الحاوية بنجاح')),
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
                                          'هل أنت متأكد من حذف هذه الحاوية'),
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
                                          'هل أنت متأكد من تعديل هذه الحاوية'),
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
                                      'رقم الحاوية: ${containrss.contNumber}'),
                                  subtitle: Text(
                                      'وزن الحاوية: ${containrss.contWeight}'),
                                  trailing: Text(
                                      'عدد الطرود: ${containrss.contParcelsCount}'),
                                  onTap: () {
                                    toggleSelection(containrss.id);
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
