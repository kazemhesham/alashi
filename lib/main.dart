import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'tabs/home_tab.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]).then((_) => runApp(const ProviderScope(child: MyApp())));
  runApp(const ProviderScope(child: MyApp()));
}

var colorforall =
    ColorScheme.fromSeed(seedColor: const Color.fromARGB(232, 15, 105, 231));

var darkcolorforall =
    ColorScheme.fromSeed(seedColor: const Color.fromARGB(232, 15, 105, 231));

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ar'), // arbic
      ],
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 6, 113, 214),
        ),
        iconTheme: const IconThemeData()
            .copyWith(color: darkcolorforall.primaryContainer),
        textTheme: ThemeData().textTheme.copyWith(
            titleMedium:
                TextStyle(color: darkcolorforall.tertiary, fontSize: 26),
            titleLarge: TextStyle(
                fontWeight: FontWeight.w600,
                color: darkcolorforall.secondary,
                fontSize: 22),
            titleSmall: TextStyle(
              color: darkcolorforall.primary,
            )),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      darkTheme: ThemeData.dark().copyWith(
        colorScheme: colorforall,
        appBarTheme: const AppBarTheme().copyWith(
          backgroundColor: darkcolorforall.onPrimaryContainer,
          foregroundColor: darkcolorforall.primaryContainer,
        ),
        cardTheme: const CardTheme().copyWith(
            color: darkcolorforall.primaryContainer,
            margin: const EdgeInsets.symmetric(horizontal: 7, vertical: 5)),
        elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
          backgroundColor: darkcolorforall.tertiaryContainer,
          textStyle: TextStyle(color: darkcolorforall.tertiary),
        )),
        outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
          backgroundColor: darkcolorforall.primary,
          foregroundColor: darkcolorforall.onPrimary,
        )),
        textTheme: ThemeData().textTheme.copyWith(
            titleMedium:
                TextStyle(color: darkcolorforall.onTertiary, fontSize: 26),
            titleLarge: TextStyle(
                fontWeight: FontWeight.w600,
                color: darkcolorforall.secondary,
                fontSize: 22),
            titleSmall: TextStyle(
              color: darkcolorforall.onPrimary,
            )),
        bottomSheetTheme: const BottomSheetThemeData().copyWith(
          backgroundColor: darkcolorforall.onSecondaryContainer,
        ),
        iconTheme:
            const IconThemeData().copyWith(color: darkcolorforall.onSecondary),
      ),
      home: const HomeTab(),
    );
  }
}
