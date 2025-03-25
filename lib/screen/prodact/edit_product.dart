import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../model/dealer_model.dart';
import '../../model/prodact_model.dart';
import '../../model/vendors_model.dart';
import '../../provider/dealer_provider.dart';
import '../../provider/prodact_provider.dart';
import '../../provider/vendors_provider.dart';

class EditProduct extends ConsumerStatefulWidget {
  final int id;

  const EditProduct({required this.id, super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _EditProductState();
}

class _EditProductState extends ConsumerState<EditProduct> {
  final _formKey = GlobalKey<FormState>();
  late Future<Product> _futureProduct;
  int delarid = 0;
  int vendorid = 0;

  late TextEditingController quantityController;
  late TextEditingController fiQuantityController;
  late TextEditingController typeController;
  late DateTime? receivingDateController;
  late TextEditingController invoiceValueController;

  late TextEditingController paidamountController;
  late TextEditingController remainingaamountController;
  late TextEditingController deliveryaddressController;
  late TextEditingController cmpController;
  late TextEditingController remarksController;
  @override
  void initState() {
    super.initState();

    // TODO: implement initState
    quantityController = TextEditingController();
    fiQuantityController = TextEditingController();
    typeController = TextEditingController();
    receivingDateController = DateTime.now();
    paidamountController = TextEditingController();
    remainingaamountController = TextEditingController();
    deliveryaddressController = TextEditingController();
    cmpController = TextEditingController();
    remarksController = TextEditingController();
    invoiceValueController = TextEditingController();
    _futureProduct = ref
        .read(prodactNotifierProvider.notifier)
        .getEditProduct(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    final delarList = ref.watch(dealersListProvider);
    final vendorList = ref.watch(vendorsListProvider);
    return Scaffold(
      appBar: AppBar(title: Text('تعديل شحنة ')),
      body: FutureBuilder(
        future: _futureProduct,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('حدث خطأ: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('لا يوجد بيانات للشحنة'));
          }

          final productss = snapshot.data!;
          if (typeController.text.isEmpty) {
            quantityController.text = productss.quantity;
            fiQuantityController.text = productss.fiQuantity;
            typeController.text = productss.type;
            receivingDateController = productss.receivingDate;
            paidamountController.text = productss.paidamount.toString();
            remainingaamountController.text =
                productss.remainingaamount.toString();
            deliveryaddressController.text = productss.deliveryaddress;
            cmpController.text = productss.cmp;
            remarksController.text = productss.remarks;
            invoiceValueController.text = productss.invoiceValue.toString();
            vendorid = productss.vendor.id;
            delarid = productss.dealer.id;
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  delarList.when(
                    data: (dealers) {
                          final currentDealer = dealers.dealers.firstWhere(
      (d) => d.id == delarid,
      orElse: () => dealers.dealers.first,
    );

                      return DropdownSearch<Dealer1>(
                        popupProps: PopupProps.menu(
                          showSearchBox: true,
                          showSelectedItems: true, // مفعل ولكن مع compareFn
                          searchFieldProps: TextFieldProps(
                            decoration: InputDecoration(
                              labelText: 'بحث',
                              hintText: 'ابحث عن اسم التاجر',
                              hintStyle: Theme.of(context).textTheme.titleSmall,
                              border: const OutlineInputBorder(),
                            ),
                          ),
                        ),
                        items: (String? filter, dynamic infiniteScrollProps) {
                          return dealers.dealers
                              .where(
                                (dealer) => dealer.name.contains(filter ?? ''),
                              )
                              .toList();
                        },

                        itemAsString: (Dealer1 d) => d.name,
                        compareFn:
                            (Dealer1 a, Dealer1 b) =>
                                a.id == b.id, // دالة مقارنة مخصصة
                        selectedItem: currentDealer,
                        onChanged: (Dealer1? dealer) {
                          if (dealer != null) {
                            delarid = dealer.id;
                          }
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'الرجاء اختيار تاجر';
                          }
                          return null;
                        },
                      );
                    },
                    loading:
                        () => const Center(child: CircularProgressIndicator()),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              receivingDateController == null
                                  ? Icons.calendar_today_outlined
                                  : Icons.calendar_month,
                            ),
                            onPressed: () async {
                              final now = DateTime.now();
                              final first = DateTime(
                                now.year - 1,
                                now.month,
                                now.day,
                              );
                              final DateTime? datapic = await showDatePicker(
                                context: context,
                                firstDate: first,
                                lastDate: now,
                                initialDate: now,
                              );
                              if (datapic != null) {
                                setState(() {
                                  receivingDateController = datapic;
                                });
                              } else {
                                // يمكنك تنفيذ إجراء آخر عند عدم اختيار تاريخ إذا أردت
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('الرجاء إدخال التاريخ أولاً'),
                                  ),
                                );
                              }
                            },
                          ),
                          Text(
                            receivingDateController == null
                                ? 'تاريخ الاستلام'
                                : DateFormat.yMd().format(
                                  receivingDateController!,
                                ),
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                        ],
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
                    data: (allProducts) {
                      final currentVendor = allProducts.vendors.firstWhere(
      (v) => v.id == vendorid,
      orElse: () => allProducts.vendors.first,
    );
                      return DropdownSearch<Vendor1>(
                        popupProps: PopupProps.menu(
                          showSearchBox: true,
                          showSelectedItems: true,
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
                          return allProducts.vendors
                              .where(
                                (dealer) => dealer.name.contains(filter ?? ''),
                              )
                              .toList(); // هذه هي الطريقة الصحيحة لتمرير دالة للفلترة
                        },
                        itemAsString: (Vendor1 v) => v.name,
                        compareFn: (Vendor1 a, Vendor1 b) => a.id == b.id,
                        selectedItem: currentVendor,
                        onChanged: (Vendor1? vendor) {
                          if (vendor != null) {
                            setState(() {
                              vendorid = vendor.id;
                            });
                          }
                        },
                        validator:
                            (value) =>
                                value == null ? 'الرجاء اختيار مورد' : null,
                      );
                    },
                    loading:
                        () => const Center(child: CircularProgressIndicator()),
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
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate() &&
                          receivingDateController != null) {
                        await ref
                            .read(prodactNotifierProvider.notifier)
                            .editProduct(
                              widget.id,
                              delarid,
                              quantityController.text.trim(),
                              fiQuantityController.text.trim().isNotEmpty
                                  ? fiQuantityController.text.trim()
                                  : "غير محدد",
                              typeController.text.trim(),
                              receivingDateController ?? DateTime.now(),
                              int.tryParse(paidamountController.text.trim()) ??
                                  0,
                              int.tryParse(
                                    remainingaamountController.text.trim(),
                                  ) ??
                                  0,
                              int.tryParse(
                                    invoiceValueController.text.trim(),
                                  ) ??
                                  0,
                              deliveryaddressController.text.trim().isNotEmpty
                                  ? deliveryaddressController.text.trim()
                                  : "غير متوفر",
                              remarksController.text.trim().isNotEmpty
                                  ? remarksController.text.trim()
                                  : "لا يوجد",
                              cmpController.text.trim().isNotEmpty
                                  ? cmpController.text.trim()
                                  : "0",
                              vendorid,
                            );

                        // إعادة تحميل البيانات
                        ref.refresh(prodactListProvider);

                        // إظهار رسالة نجاح
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('تمت تعديل الشحنة بنجاح'),
                          ),
                        );

                        // العودة إلى الشاشة السابقة
                        Navigator.pop(
                          context,
                          true,
                        ); // إرجاع true للإشارة إلى نجاح التعديل
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('يرجى تصحيح الأخطاء لإتمام العملية'),
                          ),
                        );
                      }
                    },
                    child: const Text('تعديل الشحنة'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}


// import 'package:dropdown_search/dropdown_search.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:intl/intl.dart';

// import '../../model/dealer_model.dart';
// import '../../model/vendors_model.dart';
// import '../../provider/dealer_provider.dart';
// import '../../provider/prodact_provider.dart';
// import '../../provider/vendors_provider.dart';

// class EditProduct extends ConsumerStatefulWidget {
//   final int id;
//   final String dealerName;
//   final String quantity;
//   final String fiQuantity;
//   final String type;
//   final DateTime receivingDate;
//   final String paidamount;
//   final String invoiceValue;

//   final String remainingaamount;
//   final String deliveryaddress;
//   final String vendorname;
//   final String cmp;
//   final String remarks;

//   const EditProduct({
//     required this.id,
//     required this.dealerName,
//     required this.quantity,
//     required this.fiQuantity,
//     required this.type,
//     required this.receivingDate,
//     required this.paidamount,
//     required this.invoiceValue,

//     required this.remainingaamount,
//     required this.deliveryaddress,
//     required this.vendorname,
//     required this.cmp,
//     required this.remarks,
//     super.key,
//   });

//   @override
//   ConsumerState<ConsumerStatefulWidget> createState() => _EditProductState();
// }

// class _EditProductState extends ConsumerState<EditProduct> {
//   final _formKey = GlobalKey<FormState>();

//   String delarn = '';
//   String vendorn = '';
//   int delarid = 0;
//   int vendorid = 0;
//   String vendorname = '';

//   TextEditingController quantityController = TextEditingController();
//   TextEditingController fiQuantityController = TextEditingController();
//   TextEditingController typeController = TextEditingController();
//   DateTime? receivingDateController;
//   TextEditingController invoiceValueController = TextEditingController();

//   TextEditingController paidamountController = TextEditingController();
//   TextEditingController remainingaamountController = TextEditingController();
//   TextEditingController totalamountController = TextEditingController();
//   TextEditingController deliveryaddressController = TextEditingController();
//   TextEditingController cmpController = TextEditingController();
//   TextEditingController remarksController = TextEditingController();
//   @override
//   void initState() {
//     // TODO: implement initState
//     delarn = widget.dealerName;
//     vendorn = widget.vendorname;
//     quantityController.text = widget.quantity;
//     fiQuantityController.text = widget.fiQuantity;
//     typeController.text = widget.type;
//     receivingDateController = widget.receivingDate;
//     paidamountController.text = widget.paidamount;
//     remainingaamountController.text = widget.remainingaamount;
//     deliveryaddressController.text = widget.deliveryaddress;
//     cmpController.text = widget.cmp;
//     remarksController.text = widget.remarks;
//     invoiceValueController.text = widget.invoiceValue;
//     super.initState();
//   }

//   @override
//   void dispose() {
//     // TODO: implement dispose
//     super.dispose();
//     quantityController.dispose();
//     fiQuantityController.dispose();
//     typeController.dispose();
//     paidamountController.dispose();
//     remainingaamountController.dispose();
//     totalamountController.dispose();
//     deliveryaddressController.dispose();
//     cmpController.dispose();
//     remarksController.dispose();
//     invoiceValueController.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final delarList = ref.watch(dealersListProvider);
//     final vendorList = ref.watch(vendorsListProvider);
//     return Scaffold(
//       appBar: AppBar(title: Text('تعديل شحنة ')),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Form(
//           key: _formKey,
//           child: ListView(
//             children: [
//               delarList.when(
//                 data: (dealers) {
//                   return DropdownSearch<Dealer>(
//                     popupProps: PopupProps.menu(
//                       showSearchBox: true,
//                       showSelectedItems: true, // مفعل ولكن مع compareFn
//                       searchFieldProps: TextFieldProps(
//                         decoration: InputDecoration(
//                           labelText: 'بحث',
//                           hintText: 'ابحث عن اسم التاجر',
//                           hintStyle: Theme.of(context).textTheme.titleSmall,
//                           border: const OutlineInputBorder(),
//                         ),
//                       ),
//                     ),
//                     items: (String? filter, dynamic infiniteScrollProps) {
//                       return dealers.dealers
//                           .where((dealer) => dealer.name.contains(filter ?? ''))
//                           .toList();
//                     },
//                     itemAsString: (Dealer d) => d.name,
//                     compareFn:
//                         (Dealer a, Dealer b) =>
//                             a.id == b.id, // دالة مقارنة مخصصة
//                     // selectedItem: dealers.dealers.firstWhere(
//                     //     (d) => d.name == widget.dealerName,
//                     //     orElse: () => dealers.dealers.first),
//                     onChanged: (Dealer? dealer) {
//                       if (dealer != null) {
//                         delarid = dealer.id;
//                       }
//                     },
//                     validator: (value) {
//                       if (value == null) {
//                         return 'الرجاء اختيار تاجر';
//                       }
//                       return null;
//                     },
//                   );
//                 },
//                 loading: () => const Center(child: CircularProgressIndicator()),
//                 error: (err, stack) => Center(child: Text('Error: $err')),
//               ),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Expanded(
//                     child: TextFormField(
//                       controller: quantityController,
//                       decoration: InputDecoration(
//                         labelText: 'الكمية قبل التغليف',
//                         labelStyle: Theme.of(context).textTheme.titleSmall,
//                       ),
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return 'الرجاء إدخال الكمية قبل التغليف';
//                         }
//                         return null;
//                       },
//                       style: Theme.of(context).textTheme.titleSmall,
//                     ),
//                   ),
//                   const SizedBox(width: 8),
//                   Expanded(
//                     child: TextFormField(
//                       controller: fiQuantityController,
//                       decoration: InputDecoration(
//                         labelText: 'الكمية بعد التغليف',
//                         labelStyle: Theme.of(context).textTheme.titleSmall,
//                       ),
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return 'الرجاء إدخال الكمية بعد التغليف';
//                         }
//                         return null;
//                       },
//                       style: Theme.of(context).textTheme.titleSmall,
//                     ),
//                   ),
//                 ],
//               ),
//               TextFormField(
//                 controller: typeController,
//                 decoration: InputDecoration(
//                   labelText: 'النوع',
//                   labelStyle: Theme.of(context).textTheme.titleSmall,
//                 ),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'الرجاء إدخال النوع';
//                   }
//                   return null;
//                 },
//                 style: Theme.of(context).textTheme.titleSmall,
//               ),
//               Row(
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       IconButton(
//                         icon: Icon(
//                           receivingDateController == null
//                               ? Icons.calendar_today_outlined
//                               : Icons.calendar_month,
//                         ),
//                         onPressed: () async {
//                           final now = DateTime.now();
//                           final first = DateTime(
//                             now.year - 1,
//                             now.month,
//                             now.day,
//                           );
//                           final DateTime? datapic = await showDatePicker(
//                             context: context,
//                             firstDate: first,
//                             lastDate: now,
//                             initialDate: now,
//                           );
//                           if (datapic != null) {
//                             setState(() {
//                               receivingDateController = datapic;
//                             });
//                           } else {
//                             // يمكنك تنفيذ إجراء آخر عند عدم اختيار تاريخ إذا أردت
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               const SnackBar(
//                                 content: Text('الرجاء إدخال التاريخ أولاً'),
//                               ),
//                             );
//                           }
//                         },
//                       ),
//                       Text(
//                         receivingDateController == null
//                             ? 'تاريخ الاستلام'
//                             : DateFormat.yMd().format(receivingDateController!),
//                         style: Theme.of(context).textTheme.titleSmall,
//                       ),
//                     ],
//                   ),
//                   const SizedBox(width: 42),
//                   Expanded(
//                     child: TextFormField(
//                       controller: invoiceValueController,
//                       decoration: InputDecoration(
//                         labelText: 'قيمة المشتريات',
//                         labelStyle: Theme.of(context).textTheme.titleSmall,
//                       ),
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return 'الرجاء إدخال قيمة المشتريات';
//                         } else if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
//                           return 'يرجى إدخال أرقام فقط';
//                         }
//                         return null;
//                       },
//                       style: Theme.of(context).textTheme.titleSmall,
//                       keyboardType: TextInputType.number,
//                     ),
//                   ),
//                 ],
//               ),
//               Row(
//                 children: [
//                   Expanded(
//                     child: TextFormField(
//                       controller: paidamountController,
//                       decoration: InputDecoration(
//                         labelText: 'المبلغ المدفوع',
//                         labelStyle: Theme.of(context).textTheme.titleSmall,
//                       ),
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return 'الرجاء إدخال المبلغ المدفوع';
//                         } else if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
//                           return 'يرجى إدخال أرقام فقط';
//                         }
//                         return null;
//                       },
//                       style: Theme.of(context).textTheme.titleSmall,
//                       keyboardType: TextInputType.number,
//                     ),
//                   ),
//                   const SizedBox(width: 8),
//                   Expanded(
//                     child: TextFormField(
//                       controller: remainingaamountController,
//                       decoration: InputDecoration(
//                         labelText: 'المبلغ المتبقي',
//                         labelStyle: Theme.of(context).textTheme.titleSmall,
//                       ),
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return 'الرجاء إدخال المبلغ المتبقي';
//                         } else if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
//                           return 'يرجى إدخال أرقام فقط';
//                         }
//                         return null;
//                       },
//                       style: Theme.of(context).textTheme.titleSmall,
//                       keyboardType: TextInputType.number,
//                     ),
//                   ),
//                 ],
//               ),
//               TextFormField(
//                 controller: deliveryaddressController,
//                 decoration: InputDecoration(
//                   labelText: 'عنوان التوصيل',
//                   labelStyle: Theme.of(context).textTheme.titleSmall,
//                 ),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'الرجاء إدخال عنوان التوصيل';
//                   }
//                   return null;
//                 },
//                 style: Theme.of(context).textTheme.titleSmall,
//               ),
//               vendorList.when(
//                 data: (vendors) {
//                   return DropdownSearch<Vendor>(
//                     popupProps: PopupProps.menu(
//                       showSearchBox: true,
//                       showSelectedItems: true, // مفعل ولكن مع compareFn

//                       searchFieldProps: TextFieldProps(
//                         decoration: InputDecoration(
//                           labelText: 'بحث',
//                           hintText: 'ابحث عن اسم المورد',
//                           hintStyle: Theme.of(context).textTheme.titleSmall,
//                           border: const OutlineInputBorder(),
//                         ),
//                       ),
//                     ),
//                     items: (String? filter, dynamic infiniteScrollProps) {
//                       return vendors.vendors
//                           .where((dealer) => dealer.name.contains(filter ?? ''))
//                           .toList(); // هذه هي الطريقة الصحيحة لتمرير دالة للفلترة
//                     }, // استخدم قائمة الموردين ككائنات Vendor
//                     itemAsString: (Vendor v) => v.name, // عرض الاسم فقط
//                     compareFn:
//                         (Vendor a, Vendor b) =>
//                             a.id == b.id, // دالة مقارنة مخصصة
//                     // selectedItem: vendors.vendors.firstWhere(
//                     //     (v) => v.name == widget.vendorname,
//                     //     orElse: () => vendors.vendors.first),
//                     onChanged: (Vendor? vendor) {
//                       if (vendor != null) {
//                         vendorid = vendor.id;
//                         vendorname =
//                             vendor.name.toString(); // حفظ ID المورد بدل الاسم
//                       }
//                     },
//                     validator: (value) {
//                       if (value == null) {
//                         return 'الرجاء اختيار المورد';
//                       }
//                       return null;
//                     },
//                   );
//                 },
//                 loading: () => const Center(child: CircularProgressIndicator()),
//                 error: (err, stack) => Center(child: Text('Error: $err')),
//               ),
//               TextFormField(
//                 controller: cmpController,
//                 decoration: InputDecoration(
//                   labelText: 'CMP',
//                   labelStyle: Theme.of(context).textTheme.titleSmall,
//                 ),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'الرجاء إدخال CMP';
//                   }
//                   return null;
//                 },
//                 style: Theme.of(context).textTheme.titleSmall,
//               ),
//               TextFormField(
//                 controller: remarksController,
//                 decoration: InputDecoration(
//                   labelText: 'ملاحظات',
//                   labelStyle: Theme.of(context).textTheme.titleSmall,
//                 ),
//                 style: Theme.of(context).textTheme.titleSmall,
//               ),
//               const SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: () async {
//                   if (_formKey.currentState!.validate() &&
//                       receivingDateController != null) {
                        
//                     await ref
//                         .read(prodactNotifierProvider.notifier)
//                         .editProduct(
//                           widget.id,
//                           delarid,
//                           quantityController.text.trim(),
//                           fiQuantityController.text.trim().isNotEmpty
//                               ? fiQuantityController.text.trim()
//                               : "غير محدد",
//                           typeController.text.trim(),
//                           receivingDateController ?? DateTime.now(),
//                           int.tryParse(paidamountController.text.trim()) ?? 0,
//                           int.tryParse(
//                                 remainingaamountController.text.trim(),
//                               ) ??
//                               0,
//                           int.tryParse(totalamountController.text.trim()) ?? 0,
//                           int.tryParse(invoiceValueController.text.trim()) ?? 0,
//                           deliveryaddressController.text.trim().isNotEmpty
//                               ? deliveryaddressController.text.trim()
//                               : "غير متوفر",
//                           vendorn.isNotEmpty ? vendorn : "غير محدد",
//                           remarksController.text.trim().isNotEmpty
//                               ? remarksController.text.trim()
//                               : "لا يوجد",
//                           cmpController.text.trim().isNotEmpty
//                               ? cmpController.text.trim()
//                               : "0",
//                           vendorid,
//                         );

//                     // إعادة تحميل البيانات
//                     ref.refresh(prodactListProvider);

//                     // إظهار رسالة نجاح
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(content: Text('تمت تعديل الشحنة بنجاح')),
//                     );

//                     // العودة إلى الشاشة السابقة
//                     Navigator.pop(
//                       context,
//                       true,
//                     ); // إرجاع true للإشارة إلى نجاح التعديل
//                   } else {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(
//                         content: Text('يرجى تصحيح الأخطاء لإتمام العملية'),
//                       ),
//                     );
//                   }
//                 },
//                 child: const Text('تعديل الشحنة'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
