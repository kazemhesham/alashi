import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../provider/billof_provider.dart';

class AddBillofladingPage extends ConsumerStatefulWidget {
  const AddBillofladingPage({super.key});

  @override
  ConsumerState createState() => _AddDealerPageState();
}

class _AddDealerPageState extends ConsumerState<AddBillofladingPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for form fields
  TextEditingController billOfNumberController = TextEditingController();
  TextEditingController outgoingController = TextEditingController();
  TextEditingController incomingController = TextEditingController();
  TextEditingController bRemarksController = TextEditingController();
    TextEditingController shippingTypeController = TextEditingController();
  TextEditingController navigationCompany = TextEditingController();


  @override
  void dispose() {
    billOfNumberController.dispose();
    outgoingController.dispose();
    incomingController.dispose();
    bRemarksController.dispose();
    shippingTypeController.dispose();
    navigationCompany.dispose();
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
                'إضافة بوليصة شحن',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            TextFormField(
              controller: billOfNumberController,
              decoration: InputDecoration(
                  labelText: 'رقم البوليصة',
                  labelStyle: Theme.of(context).textTheme.titleSmall),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء إدخال رقم البوليصة';
                }
                return null;
              },
              style: Theme.of(context).textTheme.titleSmall,
            ),
            TextFormField(
              controller: outgoingController,
              decoration: InputDecoration(
                  labelText: 'جهة التخليص الصادر',
                  labelStyle: Theme.of(context).textTheme.titleSmall),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء إدخال جهة التخليص الصادر';
                } 
                return null;
              },
              style: Theme.of(context).textTheme.titleSmall,
            ),
            TextFormField(
              controller: incomingController,
              decoration: InputDecoration(
                  labelText: 'جهة التخليص الوارد',
                  labelStyle: Theme.of(context).textTheme.titleSmall),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء إدخال جهة التخليص الوارد';
                } 
                return null;
              },
              style: Theme.of(context).textTheme.titleSmall,
            ),
            TextFormField(
              controller: bRemarksController,
              decoration: InputDecoration(
                  labelText: 'الملاحظات ',
                  labelStyle: Theme.of(context).textTheme.titleSmall),
              style: Theme.of(context).textTheme.titleSmall,
            ),
            TextFormField(
              controller: shippingTypeController,
              decoration: InputDecoration(
                  labelText: 'نوع الشحن',
                  labelStyle: Theme.of(context).textTheme.titleSmall),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء إدخال نوع الشحن';
                } 
                return null;
              },
              style: Theme.of(context).textTheme.titleSmall,
            ),
            TextFormField(
              controller: navigationCompany,
              decoration: InputDecoration(
                  labelText: 'شركة الملاحة',
                  labelStyle: Theme.of(context).textTheme.titleSmall),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء إدخال شركة الملاحة';
                } 
                return null;
              },
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  final billOfNumbe = billOfNumberController.text.trim();
                  final outgoing = outgoingController.text.trim();
                  final incoming = incomingController.text.trim();
                  final bRemarks = bRemarksController.text.trim();
                  final shippingType = shippingTypeController.text.trim();
                  final navigation = navigationCompany.text.trim();

                  await ref
                      .read(billofladingNotifierProvider.notifier)
                      .addBilloflading(billOfNumbe, outgoing, incoming, bRemarks,shippingType,navigation);
                  ref.refresh(billofListProvider);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تمت اضافة الحاوية بنجاح')),
                  );

                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('يرجى تصحيح الأخطاء لإتمام العملية')),
                  );
                }
              },
              child: const Text('اضافة حاوية جديدة'),
            ),
          ],
        ),
      ),
    );
  }
}
