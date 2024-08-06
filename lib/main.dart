import 'package:e_commerce_admin/firebase_options.dart';
import 'package:e_commerce_admin/screens/dashboard_screen.dart';
import 'package:e_commerce_admin/screens/inner_screens/orders/edit_upload_product_form.dart';
import 'package:e_commerce_admin/screens/search_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'consts/theme_data.dart';
import 'providers/product_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/inner_screens/orders/orders_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const E_Commerce_Admin());
}

class E_Commerce_Admin extends StatelessWidget {
  const E_Commerce_Admin({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FutureBuilder(
        future: Firebase.initializeApp(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          } else if (snapshot.hasError) {
            return Scaffold(
              body: Center(
                child: SelectableText(
                    "An error has been occured ${snapshot.error}"),
              ),
            );
          }
          return MultiProvider(
            providers: [
              ChangeNotifierProvider(
                create: (_) => ThemeProvider(),
              ),
              ChangeNotifierProvider(
                create: (_) => ProductProvider(),
              ),
            ],
            child: Consumer<ThemeProvider>(builder: (
              context,
              themeProvider,
              child,
            ) {
              return MaterialApp(
                debugShowCheckedModeBanner: false,
                title: 'Shop Smart ADMIN AR',
                theme: Styles.themeData(
                    isDarkTheme: themeProvider.getIsDarkTheme,
                    context: context),
                home: const DashboardScreen(),
                routes: {
                  OrdersScreenFree.routeName: (context) => OrdersScreenFree(),
                  SearchScreen.routeName: (context) => const SearchScreen(),
                  EditUploadProductForm.routeName: (context) =>
                      EditUploadProductForm(),
                },
              );
            }),
          );
        },
      ),
    );
  }
}
