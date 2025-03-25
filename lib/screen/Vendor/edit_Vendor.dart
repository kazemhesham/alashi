import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../model/vendors_model.dart';
import '../../provider/vendors_provider.dart';

class EditVendor extends ConsumerStatefulWidget {
  final int vendorId; // إضافة معرف التاجر

  const EditVendor({
    super.key,
    required this.vendorId,
  }); // التمرير من الشاشة السابقة

  @override
  ConsumerState createState() => _EditVendorState();
}

class _EditVendorState extends ConsumerState<EditVendor> {
  final _formKey = GlobalKey<FormState>();
  late Future<Vendor1> _vendorFuter;

  // Controllers for form fields
  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController emailController;
  late TextEditingController addressController;
  VendorLang? selectedLang;

  @override
  void initState() {
    super.initState();

    // TODO: implement initState
    nameController = TextEditingController();
    phoneController = TextEditingController();
    emailController = TextEditingController();
    addressController = TextEditingController();
    _vendorFuter = ref
        .read(vendorProvider.notifier)
        .getEditVendor(widget.vendorId);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تعديل مورد')),
      body: FutureBuilder<Vendor1>(
        future: _vendorFuter,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('حدث خطأ: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('لا يوجد بيانات للتاجر'));
          }

          final vendorss = snapshot.data!;
          if (nameController.text.isEmpty) {
            nameController.text = vendorss.name;
            phoneController.text = vendorss.phone;
            emailController.text = vendorss.email;
            addressController.text = vendorss.adress;
            selectedLang = vendorss.vendorLang;
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
                      labelText: 'اسم المورد',
                      labelStyle: Theme.of(context).textTheme.titleSmall,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'الرجاء إدخال اسم المورد';
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
                      } else if (!value.startsWith('+')) {
                        return 'الرجاء إدخال رقم هاتف صحيح (يبدأ بـ +)';
                      } else if (value.length != 13) {
                        return 'يرجى التحقق من الرقم ';
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
                  DropdownButtonFormField<VendorLang>(
                    value: selectedLang,
                    decoration: InputDecoration(
                      labelText: 'لغة المورد',
                      labelStyle: Theme.of(context).textTheme.titleSmall,
                    ),
                    items:
                        VendorLang.values.map((VendorLang lang) {
                          return DropdownMenuItem<VendorLang>(
                            value: lang,
                            child: Text(
                              {
                                VendorLang.AR: "العربية",
                                VendorLang.EN: "الإنجليزية",
                                VendorLang.TR: "التركية",
                                VendorLang.HE: "العبرية",
                              }[lang]!,
                            ),
                          );
                        }).toList(),
                    onChanged: (VendorLang? newValue) {
                      setState(() {
                        selectedLang = newValue;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'الرجاء اختيار لغة المورد';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        final name = nameController.text.trim();
                        final phone = phoneController.text.trim();
                        final email = emailController.text.trim();
                        final address = addressController.text.trim();

                        await ref
                            .read(vendorProvider.notifier)
                            .editVendor(
                              widget.vendorId,
                              name,
                              phone,
                              email,
                              address,
                              selectedLang!,
                            );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('تم تعديل بيانات المورد بنجاح'),
                          ),
                        );
                        Navigator.pop(context, true);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('فشلت عملية التعديل')),
                        );
                      }
                    },
                    child: const Text('تعديل المورد '),
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
// import '../../model/vendors_model.dart';
// import '../../provider/vendors_provider.dart';

// class EditVendor extends ConsumerStatefulWidget {
//   final int vendorId; // إضافة معرف التاجر
//   final String name;
//   final String phone;
//   final String email;
//   final String address;
//   const EditVendor(
//       {super.key, required this.name,
//       required this.phone,
//       required this.email,
//       required this.address,
//       required this.vendorId}); // التمرير من الشاشة السابقة

//   @override
//   ConsumerState createState() => _EditVendorState();
// }

// class _EditVendorState extends ConsumerState<EditVendor> {
//   final _formKey = GlobalKey<FormState>();

//   // Controllers for form fields
//   TextEditingController nameController = TextEditingController();
//   TextEditingController phoneController = TextEditingController();
//   TextEditingController emailController = TextEditingController();
//   TextEditingController addressController = TextEditingController();
//   VendorLang? selectedLang;

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
//   void dispose() {
//     // TODO: implement dispose
//     nameController.dispose();
//     phoneController.dispose();
//     emailController.dispose();
//     addressController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('تعديل مورد'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: ListView(
//             children: [
//               TextFormField(
//                 controller: nameController,
//                 decoration: InputDecoration(
//                     labelText: 'اسم المورد',
//                     labelStyle: Theme.of(context).textTheme.titleSmall),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'الرجاء إدخال اسم المورد';
//                   }
//                   return null;
//                 },
//                 style: Theme.of(context).textTheme.titleSmall,
//               ),
//               TextFormField(
//                 controller: phoneController,
//                 decoration: InputDecoration(
//                     labelText: 'رقم الهاتف',
//                     labelStyle: Theme.of(context).textTheme.titleSmall),
//                 keyboardType: TextInputType.phone,
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'الرجاء إدخال رقم الهاتف';
//                   } else if (!value.startsWith('+')) {
//                     return 'الرجاء إدخال رقم هاتف صحيح (يبدأ بـ +)';
//                   } else if (value.length != 13) {
//                     return 'يرجى التحقق من الرقم ';
//                   }
//                   return null;
//                 },
//                 style: Theme.of(context).textTheme.titleSmall,
//               ),
//               TextFormField(
//                 controller: emailController,
//                 decoration: InputDecoration(
//                     labelText: 'البريد الالكتروني',
//                     labelStyle: Theme.of(context).textTheme.titleSmall),
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
//                     labelText: 'العنوان',
//                     labelStyle: Theme.of(context).textTheme.titleSmall),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'الرجاء ادخال العنوان';
//                   }
//                   return null;
//                 },
//                 style: Theme.of(context).textTheme.titleSmall,
//               ),
//               DropdownButtonFormField<VendorLang>(
//                 value: selectedLang,
//                 decoration: InputDecoration(
//                     labelText: 'لغة المورد',
//                     labelStyle: Theme.of(context).textTheme.titleSmall),
//                 items: VendorLang.values.map((VendorLang lang) {
//                   return DropdownMenuItem<VendorLang>(
//                     value: lang,
//                     child: Text(
//                       {
//                         VendorLang.AR: "العربية",
//                         VendorLang.EN: "الإنجليزية",
//                         VendorLang.TR: "التركية",
//                         VendorLang.HE: "العبرية",
//                       }[lang]!,
//                     ),
//                   );
//                 }).toList(),
//                 onChanged: (VendorLang? newValue) {
//                   setState(() {
//                     selectedLang = newValue;
//                   });
//                 },
//                 validator: (value) {
//                   if (value == null) {
//                     return 'الرجاء اختيار لغة المورد';
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

//                     await ref.read(vendorProvider.notifier).editVendor(
//                         widget.vendorId,
//                         name,
//                         phone,
//                         email,
//                         address,
//                         selectedLang!);
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(
//                           content: Text('تم تعديل بيانات المورد بنجاح')),
//                     );
//                     Navigator.pop(context, true);
//                   } else {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(content: Text('فشلت عملية التعديل')),
//                     );
//                   }
//                 },
//                 child: const Text('تعديل المورد '),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
