import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../provider/user_provider.dart';
import '../screen/prodact/products.dart';
import '../tabs/welcome.dart';

class MainDrawer extends ConsumerWidget {
  const MainDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider); // مراقبة حالة المستخدم

    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                Theme.of(context).colorScheme.primaryContainer,
                Theme.of(context).colorScheme.primary,
              ])),
              child: Row(children: [
                Icon(
                  Icons.manage_accounts,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                const SizedBox(
                  width: 15,
                ),
                Text(
                  '${user!.user.name} مرحبا ',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge!
                      .copyWith(color: Theme.of(context).colorScheme.secondary),
                )
              ])),
          ListTile(
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProductsScreen()),
              );
            },
            leading: Icon(
              Icons.shopping_bag,
              color: Theme.of(context).colorScheme.secondary,
            ),
            title: Text('الشحن الجزئي',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge!
                    .copyWith(color: Theme.of(context).colorScheme.secondary)),
          ),
          ListTile(
            onTap: () {
              // onselectScreen('meals');
            },
            leading: Icon(
              Icons.shopping_cart,
              color: Theme.of(context).colorScheme.secondary,
            ),
            title: Text('الشحن الكلي',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge!
                    .copyWith(color: Theme.of(context).colorScheme.secondary)),
          ),
          ListTile(
            onTap: () {},
            leading: Icon(
              Icons.supervisor_account_rounded,
              color: Theme.of(context).colorScheme.secondary,
            ),
            title: Text('اعضاء الشركة',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge!
                    .copyWith(color: Theme.of(context).colorScheme.secondary)),
          ),
          ListTile(
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProductsScreen()),
              );
            },
            leading: Icon(
              Icons.switch_account,
              color: Theme.of(context).colorScheme.secondary,
            ),
            title: Text('التجار',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge!
                    .copyWith(color: Theme.of(context).colorScheme.secondary)),
          ),
          ListTile(
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProductsScreen()),
              );
            },
            leading: Icon(
              Icons.account_box_rounded,
              color: Theme.of(context).colorScheme.secondary,
            ),
            title: Text('الموردين',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge!
                    .copyWith(color: Theme.of(context).colorScheme.secondary)),
          ),
          ListTile(
            onTap: () {},
            leading: Icon(
              Icons.holiday_village,
              color: Theme.of(context).colorScheme.secondary,
            ),
            title: Text('الحاويات',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge!
                    .copyWith(color: Theme.of(context).colorScheme.secondary)),
          ),
          ListTile(
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const WelcomeScreen()),
              );
            },
            leading: Icon(
              Icons.home_filled,
              color: Theme.of(context).colorScheme.secondary,
            ),
            title: Text('صفحة الاستقبال',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge!
                    .copyWith(color: Theme.of(context).colorScheme.secondary)),
          ),
        ],
      ),
    );
  }
}
