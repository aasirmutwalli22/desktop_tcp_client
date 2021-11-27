import 'package:desktop_tcp_client/db_handler.dart';
import 'package:flutter/material.dart';

import 'form_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DbHandler.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData.light().copyWith(
        appBarTheme: ThemeData.light().appBarTheme.copyWith(
          titleTextStyle: TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 16,
            color: Colors.grey.shade900,
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          foregroundColor: Colors.grey.shade900,
          shape: Border(
            bottom: BorderSide(
              color: Colors.grey.shade200,
              width: 1,
            ),
          ),
        ),
        colorScheme: const ColorScheme.light().copyWith(
          secondary: Colors.indigo,
          primary: Colors.indigo,
        ),
        scaffoldBackgroundColor: Colors.white,
        inputDecorationTheme: InputDecorationTheme(
          focusColor: Colors.indigo,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: BorderSide.none,
          ),
          isDense: true,
          fillColor: Colors.indigo.shade50,
          filled: true,
        ),
        textSelectionTheme: ThemeData.light().textSelectionTheme.copyWith(
          cursorColor: Colors.grey.shade800,
        ),
        snackBarTheme: ThemeData.light().snackBarTheme.copyWith(
          behavior: SnackBarBehavior.floating,
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      home: const FormPage(),
    );
  }
}