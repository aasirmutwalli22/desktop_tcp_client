import 'package:flutter/material.dart';

import 'remotes_list_page.dart';

RoundedRectangleBorder shape = RoundedRectangleBorder(
  borderRadius: BorderRadius.circular(10),
);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData.light(),
      home: const RemotesListPage(),
    );
  }
}
