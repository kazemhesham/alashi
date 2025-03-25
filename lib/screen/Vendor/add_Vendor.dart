import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../model/vendors_model.dart';
import '../../provider/vendors_provider.dart';

class AddVendorPage extends ConsumerStatefulWidget {
  const AddVendorPage({super.key});

  @override
  ConsumerState createState() => _AddVendorPageState();
}

class _AddVendorPageState extends ConsumerState<AddVendorPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for form fields
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController addressController = TextEditingController();

  VendorLang? selectedLang;

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
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            Center(
              child: Text(
                'إضافة مورد جديد',
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    // color: Theme.of(context).colorScheme.secondaryContainer,
                    ),
              ),
            ),
            TextFormField(
              controller: nameController,
              decoration: InputDecoration(
                  labelText: 'اسم المورد',
                  labelStyle: Theme.of(context).textTheme.titleSmall),
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
            DropdownButtonFormField<VendorLang>(
              value: selectedLang,
              decoration: InputDecoration(
                  labelText: 'لغة التاجر',
                  labelStyle: Theme.of(context).textTheme.titleSmall),
              items: VendorLang.values.map((VendorLang lang) {
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
                  return 'الرجاء اختيار لغة التاجر';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                // تحقق من صحة النموذج
                if (_formKey.currentState!.validate()) {
                  final namee = nameController.text.trim();
                  final phonee = phoneController.text.trim();
                  final emaile = emailController.text.trim();
                  final addresse = addressController.text.trim();
                  if (selectedLang == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('الرجاء اختيار لغة المورد')),
                    );
                    return;
                  }
                  final lang = selectedLang!;
                  await ref
                      .read(vendorProvider.notifier)
                      .addVendor(namee, phonee, emaile, addresse, lang);
                  ref.refresh(vendorsListProvider);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تمت اضافة المورد بنجاح')),
                  );
                  Navigator.pop(context);
                } else {
                  // عرض رسالة إذا كان النموذج غير صالح
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('يرجى تصحيح الأخطاء لإتمام العملية')),
                  );
                }
              },
              child: const Text('اضافة مورد جديد'),
            ),
          ],
        ),
      ),
    );
  }
}
