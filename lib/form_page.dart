
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'client_page.dart';

class FormPage extends StatefulWidget{

  const FormPage({Key? key}) : super(key: key);

  @override
  State<FormPage> createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  final hostController = TextEditingController(text: "rx.unmineable.com");
  final portController = TextEditingController();

  @override
  Widget build(context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tcp client'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: hostController,
              decoration: InputDecoration(
                hintText: 'Host',
                filled: false,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4.0),
                  borderSide: BorderSide(
                    color: Colors.grey.shade800,
                    width: 2,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: portController,
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
              ],
              decoration: InputDecoration(
                hintText: 'Port',
                filled: false,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4.0),
                  borderSide: BorderSide(
                    color: Colors.grey.shade800,
                    width: 2,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: OutlinedButton(
              onPressed: () {
                hostController.text.isNotEmpty ?
                Navigator
                    .of(context)
                    .push(MaterialPageRoute(builder:
                    (_) => ClientPage(host: hostController.text, port: int.tryParse(portController.text) ?? 80,),),)
                    .then((_) => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Server disconnected")))) :
                ScaffoldMessenger
                    .of(context)
                    .showSnackBar(const SnackBar(content: Text('Host not provided'),));
              },
              child: const Text('Connect'),
            ),
          ),
        ],
      ),
    );
  }
}
