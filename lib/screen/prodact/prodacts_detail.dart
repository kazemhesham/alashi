import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';

import '../../model/prodact_model.dart';

class ProdactsDetail extends StatefulWidget {
  final dynamic product;

  const ProdactsDetail({super.key, required this.product});

  @override
  State<ProdactsDetail> createState() => _ProdactsDetailState();
}

class _ProdactsDetailState extends State<ProdactsDetail> {
  Future<void> _printPdf(int productId) async {
    String url =
        'https://alashi.online/backendapi/public/api/productdetails/$productId';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        await Printing.layoutPdf(
          onLayout: (format) async => response.bodyBytes,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('فشل في تحميل الملف للطباعة')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('خطأ أثناء الطباعة: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalamount =
        widget.product.remainingaamount + widget.product.paidamount;

    return Scaffold(
      appBar: AppBar(
        title: Text('تفاصيل الشحنة: ${widget.product.deliverynumber}'),
        actions: [
          IconButton(
            onPressed: () {
              _printPdf(widget.product.id); // طباعة أول منتج محدد
            },
            icon: const Icon(Icons.print_outlined),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(2.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              detalisPro(
                context,
                Icons.shopping_bag_outlined,
                widget.product.deliverynumber,
                'رقم الشحنة',
              ),
              const SizedBox(height: 10),
              detalisPro(
                context,
                Icons.shopping_bag_outlined,
                DateFormat.yMd().format(widget.product.receivingDate),
                'تاريخ الاستلام',
              ),
              const SizedBox(height: 10),
              detalisPro(
                context,
                Icons.shopping_bag_outlined,
                shipmentlocationValues.reverse[widget.product.shipmentlocation]
                    .toString(),
                'اين الشحنة الان',
              ),
              const SizedBox(height: 10),
              detalisPro(
                context,
                Icons.shopping_bag_outlined,
                widget.product.quantity.toString(),
                'الكمية قبل التغليف',
              ),
              const SizedBox(height: 10),
              detalisPro(
                context,
                Icons.shopping_bag_outlined,
                widget.product.fiQuantity.toString(),
                'الكمية بعد التغليف',
              ),
              const SizedBox(height: 10),
              detalisPro(
                context,
                Icons.shopping_bag_outlined,
                widget.product.type.toString(),
                'النوع',
              ),
              const SizedBox(height: 10),
              detalisPro(
                context,
                Icons.shopping_bag_outlined,
                widget.product.cmp.toString(),
                'CBM',
              ),
              const SizedBox(height: 10),
              detalisPro(
                context,
                Icons.shopping_bag_outlined,
                widget.product.dealer.name.toString(),
                'التاجر',
              ),
              const SizedBox(height: 10),
              detalisPro(
                context,
                Icons.shopping_bag_outlined,
                widget.product.vendor.name.toString(),
                'اسم المورد',
              ),
              const SizedBox(height: 10),
              detalisPro(
                context,
                Icons.shopping_bag_outlined,
                widget.product.invoiceValue.toString(),
                'قيمة المشتريات',
              ),
              const SizedBox(height: 10),
              detalisPro(
                context,
                Icons.shopping_bag_outlined,
                widget.product.paidamount.toString(),
                'المبلغ المدفوع',
              ),
              const SizedBox(height: 10),
              detalisPro(
                context,
                Icons.shopping_bag_outlined,
                widget.product.remainingaamount.toString(),
                'المبلغ المتبقي',
              ),
              const SizedBox(height: 10),
              detalisPro(
                context,
                Icons.shopping_bag_outlined,
                totalamount.toString(),
                'المبلغ الكلي',
              ),
              const SizedBox(height: 10),
              detalisPro(
                context,
                Icons.shopping_bag_outlined,
                widget.product.deliveryaddress.toString(),
                'عنوان التوصيل',
              ),
              const SizedBox(height: 10),
              detalisPro(
                context,
                Icons.shopping_bag_outlined,
                widget.product.remarks.toString(),
                'الملاحظات',
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Row detalisPro(
    BuildContext context,
    IconData icon,
    String title,
    String type,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Icon(icon, size: 50, color: Theme.of(context).colorScheme.tertiary),
        const SizedBox(width: 10),
        Text('$type: $title', style: Theme.of(context).textTheme.titleSmall),
      ],
    );
  }
}


// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../model/prodact_model.dart';
// import '../provider/prodact_provider.dart';

// class ProductDetailsPage extends ConsumerWidget {
//   final int productId;

//   const ProductDetailsPage({Key? key, required this.productId}) : super(key: key);

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final productAsync = ref.watch(prodactListProvider);

//     return Scaffold(
//       appBar: AppBar(title: Text("تفاصيل المنتج")),
//       body: productAsync.when(
//         data: (allProducts) {
//           final product = allProducts.products.firstWhere((p) => p.id == productId, orElse: () => Product(
//             id: 0,
//             dealerId: 0,
//             deliverynumber: "غير متوفر",
//             quantity: "0",
//             fiQuantity: null,
//             type: "غير متوفر",
//             receivingDate: DateTime.now(),
//             shipmentDepartureDate: null,
//             shipmentlocation: Shipmentlocation.EMPTY,
//             paidamount: 0,
//             remainingaamount: 0,
//             totalamount: 0,
//             invoiceValue: 0,
//             deliveryaddress: "غير متوفر",
//             recipient: null,
//             remarks: "غير متوفر",
//             cmp: "غير متوفر",
//             createdAt: DateTime.now(),
//             updatedAt: DateTime.now(),
//             vendorId: 0,
//             dealer: Dealer(
//               id: 0,
//               name: "غير متوفر",
//               dealerNumber: "-",
//               phone: "-",
//               email: "-",
//               adress: "-",
//               productCount: 0,
//               dealerLang: RLang.AR,
//               createdAt: DateTime.now(),
//               updatedAt: DateTime.now(),
//               paidamount: 0,
//             ),
//             vendor: null,
//           ));

//           return Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: ListView(
//               children: [
//                 ListTile(title: Text("رقم التسليم"), subtitle: Text(product.deliverynumber)),
//                 ListTile(title: Text("الكمية"), subtitle: Text(product.quantity)),
//                 ListTile(title: Text("النوع"), subtitle: Text(product.type)),
//                 ListTile(title: Text("تاريخ الاستلام"), subtitle: Text(product.receivingDate.toString())),
//                 ListTile(title: Text("العنوان"), subtitle: Text(product.deliveryaddress)),
//                 ListTile(title: Text("القيمة الإجمالية"), subtitle: Text("${product.totalamount} ريال")),
//                 ListTile(title: Text("المبلغ المدفوع"), subtitle: Text("${product.paidamount} ريال")),
//                 ListTile(title: Text("المبلغ المتبقي"), subtitle: Text("${product.remainingaamount} ريال")),
//                 ListTile(title: Text("المورد"), subtitle: Text(product.vendor?.name ?? "غير متوفر")),
//                 ListTile(title: Text("ملاحظات"), subtitle: Text(product.remarks)),
//               ],
//             ),
//           );
//         },
//         loading: () => const Center(child: CircularProgressIndicator()),
//         error: (err, stack) => Center(child: Text("خطأ في تحميل البيانات: $err")),
//       ),
//     );
//   }

//   Row detalisPro(BuildContext context,IconData icon,String title,String type) {
//     return Row(
//               mainAxisAlignment: MainAxisAlignment.start,
//               children: [
//                 Icon(
//                   icon,
//                   size: 50,
//                   color: Theme.of(context).colorScheme.tertiary,
//                 ),
//                 const SizedBox(width: 10),
//                 Text(
//                   '$type: ${title}',
//                   style: Theme.of(context).textTheme.titleSmall,
//                 ),
//               ],
//             );
//   }
// }