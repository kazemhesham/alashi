import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../model/dealer_model.dart';
import '../../provider/dealer_provider.dart';

class AddDealerPage extends ConsumerStatefulWidget {
  const AddDealerPage({super.key});

  @override
  ConsumerState createState() => _AddDealerPageState();
}

class _AddDealerPageState extends ConsumerState<AddDealerPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for form fields
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController addressController = TextEditingController();

  // Language selection
  DealerLang? selectedLang;

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
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            Center(
              child: Text(
                'إضافة تاجر جديد',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            TextFormField(
              controller: nameController,
              decoration: InputDecoration(
                  labelText: 'اسم التاجر',
                  labelStyle: Theme.of(context).textTheme.titleSmall),
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
                  labelStyle: Theme.of(context).textTheme.titleSmall),
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
                  labelStyle: Theme.of(context).textTheme.titleSmall),
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
                  labelStyle: Theme.of(context).textTheme.titleSmall),
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
                  labelStyle: Theme.of(context).textTheme.titleSmall),
              items: DealerLang.values.map((DealerLang lang) {
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
                if (_formKey.currentState!.validate()) {
                  final namee = nameController.text.trim();
                  final phonee = phoneController.text.trim();
                  final emaile = emailController.text.trim();
                  final addresse = addressController.text.trim();
                  if (selectedLang == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('الرجاء اختيار لغة التاجر')),
                    );
                    return;
                  }
                  final lang = selectedLang!;

                  await ref
                      .read(dealerProvider.notifier)
                      .addDealer(namee, phonee, emaile, addresse, lang);
                  ref.refresh(dealersListProvider);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تمت اضافة التاجر بنجاح')),
                  );

                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('يرجى تصحيح الأخطاء لإتمام العملية')),
                  );
                }
              },
              child: const Text('اضافة تاجر جديد'),
            ),
          ],
        ),
      ),
    );
  }
}
