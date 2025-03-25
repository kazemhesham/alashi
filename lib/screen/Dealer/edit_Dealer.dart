import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../model/dealer_model.dart';
import '../../provider/dealer_provider.dart';

class EditDealer extends ConsumerStatefulWidget {
  final int dealerId;

  const EditDealer({super.key, required this.dealerId});

  @override
  ConsumerState<EditDealer> createState() => _EditDealerState();
}

class _EditDealerState extends ConsumerState<EditDealer> {
  final _formKey = GlobalKey<FormState>();
  late Future<Dealer1> _dealerFuture;

  // Controllers for form fields
  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController emailController;
  late TextEditingController addressController;
  DealerLang? selectedLang;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    phoneController = TextEditingController();
    emailController = TextEditingController();
    addressController = TextEditingController();

    _dealerFuture = ref
        .read(dealerProvider.notifier)
        .getEditDealer(widget.dealerId);
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تعديل تاجر')),
      body: FutureBuilder<Dealer1>(
        future: _dealerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('حدث خطأ: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('لا يوجد بيانات للتاجر'));
          }

          final dealer = snapshot.data!;

          // تعبئة الحقول إذا لم تكن معبأة مسبقاً
          if (nameController.text.isEmpty) {
            nameController.text = dealer.name;
            phoneController.text = dealer.phone;
            emailController.text = dealer.email;
            addressController.text = dealer.adress;
            selectedLang = dealer.dealerLang;
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'اسم التاجر',
                      labelStyle: Theme.of(context).textTheme.titleSmall,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'الرجاء إدخال اسم التاجر';
                      }
                      return null;
                    },
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  TextFormField(
                    controller: phoneController,
                    decoration: InputDecoration(
                      labelText: 'رقم الهاتف',
                      labelStyle: Theme.of(context).textTheme.titleSmall,
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'الرجاء إدخال رقم الهاتف';
                      } else if (!value.startsWith('+') || value.length != 13) {
                        return 'الرجاء إدخال رقم هاتف صحيح (يبدأ بـ +)';
                      }
                      return null;
                    },
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  TextFormField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'البريد الالكتروني',
                      labelStyle: Theme.of(context).textTheme.titleSmall,
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'الرجاء إدخال البريد الإلكتروني';
                      } else if (!value.contains('@') || !value.contains('.')) {
                        return 'الرجاء إدخال بريد الكتروني صحيح';
                      }
                      return null;
                    },
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  TextFormField(
                    controller: addressController,
                    decoration: InputDecoration(
                      labelText: 'العنوان',
                      labelStyle: Theme.of(context).textTheme.titleSmall,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'الرجاء ادخال العنوان';
                      }
                      return null;
                    },
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  DropdownButtonFormField<DealerLang>(
                    value: selectedLang,
                    decoration: InputDecoration(
                      labelText: 'لغة التاجر',
                      labelStyle: Theme.of(context).textTheme.titleSmall,
                    ),
                    items:
                        DealerLang.values.map((DealerLang lang) {
                          return DropdownMenuItem<DealerLang>(
                            value: lang,
                            child: Text(
                              {
                                DealerLang.AR: "العربية",
                                DealerLang.EN: "الإنجليزية",
                                DealerLang.TR: "التركية",
                                DealerLang.HE: "العبرية",
                              }[lang]!,
                            ),
                          );
                        }).toList(),
                    onChanged: (DealerLang? newValue) {
                      setState(() {
                        selectedLang = newValue;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'الرجاء اختيار لغة التاجر';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate() &&
                          selectedLang != null) {
                        try {
                          await ref
                              .read(dealerProvider.notifier)
                              .editDealer(
                                widget.dealerId,
                                nameController.text.trim(),
                                phoneController.text.trim(),
                                emailController.text.trim(),
                                addressController.text.trim(),
                                selectedLang!,
                              );

                          ref.refresh(dealersListProvider);

                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('تم تعديل بيانات التاجر بنجاح'),
                              ),
                            );
                            Navigator.pop(context, true);
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('فشل التعديل: $e')),
                            );
                          }
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('الرجاء تعبئة جميع الحقول بشكل صحيح'),
                          ),
                        );
                      }
                    },
                    child: const Text('حفظ التعديلات'),
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

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../../model/dealer_model.dart';
// import '../../provider/dealer_provider.dart';

// class EditDealer extends ConsumerStatefulWidget {
//   final int dealerId; // إضافة معرف التاجر
//   final String name;
//   final String phone;
//   final String email;
//   final String address;
//   const EditDealer({
//     super.key,
//     required this.name,
//     required this.phone,
//     required this.email,
//     required this.address,
//     required this.dealerId,
//   }); // التمرير من الشاشة السابقة

//   @override
//   ConsumerState createState() => _EditDealerState();
// }

// class _EditDealerState extends ConsumerState<EditDealer> {
//   final _formKey = GlobalKey<FormState>();

//   // Controllers for form fields
//   TextEditingController nameController = TextEditingController();
//   TextEditingController phoneController = TextEditingController();
//   TextEditingController emailController = TextEditingController();
//   TextEditingController addressController = TextEditingController();
//   DealerLang? selectedLang;

//   @override
//   void dispose() {
//     // TODO: implement dispose
//     nameController.dispose();
//     phoneController.dispose();
//     emailController.dispose();
//     addressController.dispose();
//     super.dispose();
//   }

//   @override
//   void initState() {
//     // TODO: implement initState
//     nameController.text = widget.name;
//     phoneController.text = widget.phone;
//     emailController.text = widget.email;
//     addressController.text = widget.address;
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('تعديل تاجر')),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: ListView(
//             children: [
//               TextFormField(
//                 controller: nameController,
//                 decoration: InputDecoration(
//                   labelText: 'اسم التاجر',
//                   labelStyle: Theme.of(context).textTheme.titleSmall,
//                 ),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'الرجاء إدخال اسم التاجر';
//                   }
//                   return null;
//                 },
//                 style: Theme.of(context).textTheme.titleSmall,
//               ),
//               TextFormField(
//                 controller: phoneController,
//                 decoration: InputDecoration(
//                   labelText: 'رقم الهاتف',
//                   labelStyle: Theme.of(context).textTheme.titleSmall,
//                 ),
//                 keyboardType: TextInputType.phone,
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'الرجاء إدخال رقم الهاتف';
//                   } else if (!value.startsWith('+') || value.length != 13) {
//                     return 'الرجاء إدخال رقم هاتف صحيح (يبدأ بـ +)';
//                   }
//                   return null;
//                 },
//                 style: Theme.of(context).textTheme.titleSmall,
//               ),
//               TextFormField(
//                 controller: emailController,
//                 decoration: InputDecoration(
//                   labelText: 'البريد الالكتروني',
//                   labelStyle: Theme.of(context).textTheme.titleSmall,
//                 ),
//                 keyboardType: TextInputType.emailAddress,
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'الرجاء إدخال البريد الإلكتروني';
//                   } else if (!value.contains('@') || !value.contains('.')) {
//                     return 'الرجاء إدخال بريد الكتروني صحيح';
//                   }
//                   return null;
//                 },
//                 style: Theme.of(context).textTheme.titleSmall,
//               ),
//               TextFormField(
//                 controller: addressController,
//                 decoration: InputDecoration(
//                   labelText: 'العنوان',
//                   labelStyle: Theme.of(context).textTheme.titleSmall,
//                 ),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'الرجاء ادخال العنوان';
//                   }
//                   return null;
//                 },
//                 style: Theme.of(context).textTheme.titleSmall,
//               ),
//               DropdownButtonFormField<DealerLang>(
//                 value: selectedLang,
//                 decoration: InputDecoration(
//                   labelText: 'لغة التاجر',
//                   labelStyle: Theme.of(context).textTheme.titleSmall,
//                 ),
//                 items:
//                     DealerLang.values.map((DealerLang lang) {
//                       return DropdownMenuItem<DealerLang>(
//                         value: lang,
//                         child: Text(
//                           {
//                             DealerLang.AR: "العربية",
//                             DealerLang.EN: "الإنجليزية",
//                             DealerLang.TR: "التركية",
//                             DealerLang.HE: "العبرية",
//                           }[lang]!,
//                         ),
//                       );
//                     }).toList(),
//                 onChanged: (DealerLang? newValue) {
//                   setState(() {
//                     selectedLang = newValue;
//                   });
//                 },
//                 validator: (value) {
//                   if (value == null) {
//                     return 'الرجاء اختيار لغة التاجر';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: () async {
//                   if (_formKey.currentState!.validate()) {
//                     final name = nameController.text.trim();
//                     final phone = phoneController.text.trim();
//                     final email = emailController.text.trim();
//                     final address = addressController.text.trim();

//                     await ref
//                         .read(dealerProvider.notifier)
//                         .editDealer(
//                           widget.dealerId,
//                           name,
//                           phone,
//                           email,
//                           address,
//                           selectedLang!,
//                         );
//                     ref.refresh(dealersListProvider);

//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(
//                         content: Text('تم تعديل بيانات التاجر بنجاح'),
//                       ),
//                     );
//                     Navigator.pop(context, true);
//                   } else {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(content: Text('فشلت عملية التعديل')),
//                     );
//                   }
//                 },
//                 child: const Text('تعديل التاجر '),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
