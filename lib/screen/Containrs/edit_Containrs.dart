import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../provider/containrs_provider.dart';

class EditContainrsPage extends ConsumerStatefulWidget {
  final int contid; // إضافة معرف التاجر
  final String contNumbe;
  final String contWeigh;
  final String contParcelsCoun;
  final String contRemark;
  const EditContainrsPage(
      {super.key, required this.contid,
      required this.contNumbe,
      required this.contWeigh,
      required this.contParcelsCoun,
      required this.contRemark});

  @override
  ConsumerState createState() => _AddDealerPageState();
}

class _AddDealerPageState extends ConsumerState<EditContainrsPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for form fields
  TextEditingController contNumberController = TextEditingController();
  TextEditingController contWeightController = TextEditingController();
  TextEditingController contParcelsCountController = TextEditingController();
  TextEditingController contRemarksController = TextEditingController();

  @override
  void dispose() {
    contNumberController.dispose();
    contWeightController.dispose();
    contParcelsCountController.dispose();
    contRemarksController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    contNumberController.text = widget.contNumbe;
    contWeightController.text = widget.contWeigh;
    contParcelsCountController.text = widget.contParcelsCoun;
    contRemarksController.text = widget.contRemark;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تعديل الحاوية'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Center(
                child: Text(
                  'تعديل الحاوية',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              TextFormField(
                controller: contNumberController,
                decoration: InputDecoration(
                    labelText: 'رقم الحاوية',
                    labelStyle: Theme.of(context).textTheme.titleSmall),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال رقم الحاوية';
                  }
                  return null;
                },
                style: Theme.of(context).textTheme.titleSmall,
              ),
              TextFormField(
                controller: contWeightController,
                decoration: InputDecoration(
                    labelText: 'وزن الحاوية',
                    labelStyle: Theme.of(context).textTheme.titleSmall),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال وزن الحاوية';
                  }
                  return null;
                },
                style: Theme.of(context).textTheme.titleSmall,
              ),
              TextFormField(
                controller: contParcelsCountController,
                decoration: InputDecoration(
                    labelText: 'عدد الطرود',
                    labelStyle: Theme.of(context).textTheme.titleSmall),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال عدد الطرود';
                  }
                  return null;
                },
                style: Theme.of(context).textTheme.titleSmall,
              ),
              TextFormField(
                controller: contRemarksController,
                decoration: InputDecoration(
                    labelText: 'الملاحظات ',
                    labelStyle: Theme.of(context).textTheme.titleSmall),
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final contNumber = contNumberController.text.trim();
                    final contWeight = contWeightController.text.trim();
                    final contParcelsCount =
                        contParcelsCountController.text.trim();
                    final contRemarks = contRemarksController.text.trim();

                    await ref
                        .read(containrNotifierProvider.notifier)
                        .editContainrs(widget.contid, contNumber, contWeight,
                            contParcelsCount, contRemarks);
                    ref.refresh(containrsListProvider);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تمت تعديل الحاوية بنجاح')),
                    );

                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('يرجى تصحيح الأخطاء لإتمام العملية')),
                    );
                  }
                },
                child: const Text('تعديل الحاوية'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
