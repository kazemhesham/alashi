import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:dropdown_search/dropdown_search.dart';

import '../../model/dealer_model.dart';
import '../../model/vendors_model.dart';
import '../../provider/dealer_provider.dart';
import '../../provider/prodact_provider.dart';
import '../../provider/vendors_provider.dart';

class AddProdactPage extends ConsumerStatefulWidget {
  const AddProdactPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AddProdactPageState();
}

class _AddProdactPageState extends ConsumerState<AddProdactPage> {
  final _formKey = GlobalKey<FormState>();
  int skipNotifications = 0;

  // Controllers for form fields
  int delarid = 0;
  int vendorid = 0;
  String vendorname = '';
  TextEditingController quantityController = TextEditingController();
  TextEditingController fiQuantityController = TextEditingController();
  TextEditingController typeController = TextEditingController();
  DateTime? receivingDateController;
  TextEditingController paidamountController = TextEditingController();
  TextEditingController invoiceValueController = TextEditingController();
  TextEditingController remainingaamountController = TextEditingController();
  TextEditingController totalamountController = TextEditingController();
  TextEditingController deliveryaddressController = TextEditingController();
  TextEditingController cmpController = TextEditingController();
  TextEditingController remarksController = TextEditingController();
  @override
  void dispose() {
    quantityController.dispose();
    fiQuantityController.dispose();
    typeController.dispose();
    paidamountController.dispose();
    remainingaamountController.dispose();
    totalamountController.dispose();
    deliveryaddressController.dispose();
    cmpController.dispose();
    remarksController.dispose();
    invoiceValueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final delarList = ref.watch(dealersListProvider);
    final vendorList = ref.watch(vendorsListProvider);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            Center(
              child: Text(
                'إضافة شحنة جديدة',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            delarList.when(
              data: (dealers) {
                return DropdownSearch<Dealer1>(
                  popupProps: PopupProps.menu(
                    showSearchBox: true,
                    searchFieldProps: TextFieldProps(
                      decoration: InputDecoration(
                        labelText: 'بحث',
                        hintText: 'ابحث عن اسم التاجر',
                        hintStyle: Theme.of(context).textTheme.titleSmall,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    showSelectedItems: true,
                  ),
                  items: (String? filter, dynamic infiniteScrollProps) {
                    return dealers.dealers
                        .where((dealer) => dealer.name.contains(filter ?? ''))
                        .toList(); // هذه هي الطريقة الصحيحة لتمرير دالة للفلترة
                  },
                  itemAsString: (Dealer1 dealer) => dealer.name,
      compareFn: (Dealer1 a, Dealer1 b) => a.id == b.id, // تم تعديل دالة المقارنة

                  onChanged: (Dealer1? dealer) {
                    if (dealer != null) {
                      delarid = dealer.id;
                    }
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'الرجاء إدخال اسم التاجر';
                    }
                    return null;
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: quantityController,
                    decoration: InputDecoration(
                      labelText: 'الكمية قبل التغليف',
                      labelStyle: Theme.of(context).textTheme.titleSmall,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'الرجاء إدخال الكمية قبل التغليف';
                      }
                      return null;
                    },
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: fiQuantityController,
                    decoration: InputDecoration(
                      labelText: 'الكمية بعد التغليف',
                      labelStyle: Theme.of(context).textTheme.titleSmall,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'الرجاء إدخال الكمية بعد التغليف';
                      }
                      return null;
                    },
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
              ],
            ),
            TextFormField(
              controller: typeController,
              decoration: InputDecoration(
                labelText: 'النوع',
                labelStyle: Theme.of(context).textTheme.titleSmall,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء إدخال النوع';
                }
                return null;
              },
              style: Theme.of(context).textTheme.titleSmall,
            ),
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    receivingDateController == null
                        ? Icons.calendar_today_outlined
                        : Icons.calendar_month,
                  ),
                  onPressed: () async {
                    final now = DateTime.now();
                    final DateTime? selectedDate = await showDatePicker(
                      context: context,
                      firstDate: DateTime(2000),
                      lastDate: now,
                      initialDate: now,
                    );
                    if (selectedDate != null) {
                      setState(() => receivingDateController = selectedDate);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('الرجاء إدخال التاريخ أولًا'),
                        ),
                      );
                    }
                  },
                ),
                Text(
                  receivingDateController == null
                      ? 'تاريخ الاستلام'
                      : DateFormat.yMd().format(receivingDateController!),
                ),
                const SizedBox(width: 42),
                Expanded(
                  child: TextFormField(
                    controller: invoiceValueController,
                    decoration: InputDecoration(
                      labelText: 'قيمة المشتريات',
                      labelStyle: Theme.of(context).textTheme.titleSmall,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'الرجاء إدخال قيمة المشتريات';
                      } else if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                        return 'يرجى إدخال أرقام فقط';
                      }
                      return null;
                    },
                    style: Theme.of(context).textTheme.titleSmall,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: paidamountController,
                    decoration: InputDecoration(
                      labelText: 'المبلغ المدفوع',
                      labelStyle: Theme.of(context).textTheme.titleSmall,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'الرجاء إدخال المبلغ المدفوع';
                      } else if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                        return 'يرجى إدخال أرقام فقط';
                      }
                      return null;
                    },
                    style: Theme.of(context).textTheme.titleSmall,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: remainingaamountController,
                    decoration: InputDecoration(
                      labelText: 'المبلغ المتبقي',
                      labelStyle: Theme.of(context).textTheme.titleSmall,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'الرجاء إدخال المبلغ المتبقي';
                      } else if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                        return 'يرجى إدخال أرقام فقط';
                      }
                      return null;
                    },
                    style: Theme.of(context).textTheme.titleSmall,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            TextFormField(
              controller: deliveryaddressController,
              decoration: InputDecoration(
                labelText: 'عنوان التوصيل',
                labelStyle: Theme.of(context).textTheme.titleSmall,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء إدخال عنوان التوصيل';
                }
                return null;
              },
              style: Theme.of(context).textTheme.titleSmall,
            ),
           vendorList.when(
  data: (vendors) {
    return DropdownSearch<Vendor1>(
      popupProps: PopupProps.menu(
        showSearchBox: true,
        showSelectedItems: true, // مفعل ولكن مع compareFn
        searchFieldProps: TextFieldProps(
          decoration: InputDecoration(
            labelText: 'بحث',
            hintText: 'ابحث عن اسم المورد',
            hintStyle: Theme.of(context).textTheme.titleSmall,
            border: const OutlineInputBorder(),
          ),
        ),
      ),
      items: (String? filter, dynamic infiniteScrollProps) {
        return vendors.vendors
            .where((dealer) => dealer.name.contains(filter ?? ''))
            .toList();
      },
      itemAsString: (Vendor1 v) => v.name,
      compareFn: (Vendor1 a, Vendor1 b) => a.id == b.id, // تم تعديل دالة المقارنة

      onChanged: (Vendor1? vendor) {
        if (vendor != null) {
          vendorid = vendor.id;
          vendorname = vendor.name.toString();
        }
      },
      validator: (value) {
        if (value == null) {
          return 'الرجاء اختيار المورد';
        }
        return null;
      },
    );
  },
  loading: () => const Center(child: CircularProgressIndicator()),
  error: (err, stack) => Center(child: Text('Error: $err')),
),

            TextFormField(
              controller: cmpController,
              decoration: InputDecoration(
                labelText: 'CMP',
                labelStyle: Theme.of(context).textTheme.titleSmall,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء إدخال CMP';
                }
                return null;
              },
              style: Theme.of(context).textTheme.titleSmall,
            ),
            TextFormField(
              controller: remarksController,
              decoration: InputDecoration(
                labelText: 'ملاحظات',
                labelStyle: Theme.of(context).textTheme.titleSmall,
              ),
              style: Theme.of(context).textTheme.titleSmall,
            ),
            Row(
              children: [
                Checkbox(
                  value: skipNotifications == 1, // القيمة تعتمد على المتغير
                  onChanged: (value) {
                    setState(() {
                      skipNotifications =
                          value! ? 1 : 0; // تحديث المتغير حسب الحالة
                      // log("🚀 قيمة skipNotifications بعد التغيير: $skipNotifications");
                    });
                  },
                ),
                const Text('عدم إرسال إشعارات للتاجر والمورد'),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate() &&
                    receivingDateController != null) {
                  final totalAmountText = totalamountController.text.trim();
                  final totalAmount =
                      totalAmountText.isNotEmpty
                          ? int.parse(totalAmountText)
                          : 0;

                  await ref
                      .read(prodactNotifierProvider.notifier)
                      .addProduct(
                        delarid,
                        quantityController.text.trim(),
                        fiQuantityController.text.trim(),
                        typeController.text.trim(),
                        receivingDateController!,
                        int.parse(paidamountController.text.trim()),
                        int.parse(remainingaamountController.text.trim()),
                        totalAmount,
                        int.parse(invoiceValueController.text.trim()),
                        deliveryaddressController.text.trim(),
                        vendorid
                            .toString(), // تصحيح استخدام vendorid بدلاً من الاسم
                        remarksController.text.trim(),
                        cmpController.text.trim(),
                        vendorid,
                        skipNotifications,
                      );

                  ref.refresh(prodactListProvider);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تمت إضافة الشحنة بنجاح')),
                  );
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('يرجى تصحيح الأخطاء لإتمام العملية'),
                    ),
                  );
                }
              },
              child: const Text('إضافة شحنة جديدة'),
            ),
          ],
        ),
      ),
    );
  }
}
