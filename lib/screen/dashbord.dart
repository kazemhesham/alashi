import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/main_drawer.dart';
import '../provider/user_provider.dart';
import '../tabs/home_tab.dart';
import 'billof/billof.dart';
import 'Containrs/containr.dart';
import 'Dealer/dealers.dart';
import 'prodact/products.dart';
import 'Vendor/vendors.dart';

class DashbordPage extends ConsumerWidget {
  const DashbordPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة التحكم'),
        actions: [
          IconButton(
              onPressed: () async {
                await ref.read(userProvider.notifier).logoutUser();

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeTab()),
                );
              },
              icon: Icon(Icons.logout_outlined))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 10,
                childAspectRatio: 3 / 2),
            children: [
              maindach(context, 'البضائع', Icons.add_shopping_cart_outlined,
                  const ProductsScreen()),
              maindach(context, 'الحاويات', Icons.airplanemode_active_outlined,
                  const ContainrsScreen()),
              maindach(context, 'التجار', Icons.person_2_outlined,
                  const DealersScreen()),
              maindach(
                  context,
                  'الموردين',
                  Icons.transfer_within_a_station_outlined,
                  const VendorsScreen()),
              maindach(context, 'اعضاء الشركة', Icons.contacts_outlined,
                  const ProductsScreen()),
                  maindach(context, 'بوليصة الشحن', Icons.contacts_outlined,
                  const BillofScreen()),
            ]),
      ),
      drawer: const MainDrawer(),
    );
  }

  InkWell maindach(
      BuildContext context, String page, IconData icon, Widget screen) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => screen),
        );
      },
      child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              gradient: LinearGradient(colors: [
                Theme.of(context).colorScheme.secondary,
                Theme.of(context).colorScheme.onPrimaryContainer
              ], begin: Alignment.bottomLeft, end: Alignment.topRight)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 35,
              ),
              Text(page,
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary)),
              //   user != null
              //       ? '${user.name}' // عرض اسم المستخدم
              //       : 'Welcome to the dashboard',
              //   style: const TextStyle(
              //       fontSize: 20, fontWeight: FontWeight.bold),
              // ),
            ],
          )),
    );
  }
}
