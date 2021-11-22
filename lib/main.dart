import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
      home: const HomePage(),
    );
  }
}
class HomePage extends StatefulWidget{
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var connected = false;
  var chats = <Chat>[];
  final hostController = TextEditingController();
  final portController = TextEditingController();
  final inputController = TextEditingController();
  final outputController = TextEditingController();

  Socket? socket;

  @override
  Widget build(context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.grey.shade800,
        shape: const Border(
          bottom: BorderSide(
            color: Colors.grey,
            width: 1,
          ),
        ),
        title: const Text('Tcp client'),
        actions: [
          if(connected) TextButton.icon(
            icon: const Icon(Icons.close),
            label: const Text('Disconnect'),
            onPressed: disconnect,
            style: TextButton.styleFrom(
              primary: Colors.red.shade400,
              textStyle: Theme.of(context).textTheme.bodyText1!.copyWith(
                fontSize: 18,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: connected ? tcpConnectedPage() : tcpDisconnectedPage(),
    );
  }

  Widget tcpConnectedPage(){
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) => Padding(
              padding: chats[index].direction == Direction.outgoing ? const EdgeInsets.only(
                top: 4, bottom: 4, right: 4, left: 16,
              ) : const EdgeInsets.only(
                top: 4, bottom: 4, right: 16, left: 4,
              ),
              child: ListTile(
                title: Text(chats[index].message),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: chats[index].direction == Direction.outgoing ? const Radius.circular(16) : const Radius.circular(0),
                    topRight: const Radius.circular(16),
                    bottomLeft: const Radius.circular(16),
                    bottomRight: chats[index].direction == Direction.outgoing ? const Radius.circular(0) : const Radius.circular(16),
                  )
                ),
                tileColor: chats[index].direction == Direction.outgoing ? Colors.indigo.shade50 : Colors.red.shade50,
              ),
            ),
          ),
        ),
        // Expanded(
        //   child: TextField(
        //     controller: inputController,
        //     maxLines: null,
        //     expands: true,
        //     readOnly: true,
        //     decoration: InputDecoration.collapsed(
        //       hintText: '',
        //       fillColor: Colors.grey.shade300,
        //       filled: true,
        //     ),
        //   ),
        // ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: outputController,
            autofocus: true,
            keyboardType: TextInputType.multiline,
            maxLines: 4,
            minLines: 1,
            decoration: InputDecoration(
              hintText: 'Message',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4.0),
                borderSide: BorderSide(
                  color: Colors.grey.shade800,
                  width: 2,
                ),
              ),
              suffixIcon: IconButton(
                icon: const Icon(Icons.send,),
                onPressed: (){
                  if(connected) {
                    socket!.write(outputController.text);
                    setState(() => chats.add(Chat(outputController.text, Direction.outgoing)));
                    outputController.clear();
                  }
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget tcpDisconnectedPage(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: hostController,
            decoration: InputDecoration(
              isDense: true,
              hintText: 'Host',
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
              isDense: true,
              hintText: 'Port',
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
            onPressed: connect,
            child: const Text('Connect'),
          ),
        ),
      ],
    );
  }

  void connect(){
    Socket.connect(hostController.text, int.tryParse(portController.text) ?? 80).then((value) {
      setState(() {
        inputController.clear();
        chats.clear();
        connected = true;
        socket = value;
      });
      value.listen((event) {
        // inputController.text += ascii.decode(event);
        setState(() => chats.add(Chat(ascii.decode(event), Direction.incoming)));
      },
        onDone: () => setState(() {
          connected = false;
          socket = null;
        }),
        onError: (_, __,)=> ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_))),
      ).onError((_, __,)=> ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_))));
    });
  }
  void disconnect(){
    if(socket != null) socket!.close();
  }
}

class Chat{
  final String message;
  final int direction;
  Chat(this.message, this.direction);
}

class Direction{
  static const int incoming = 0;
  static const int outgoing = 1;
}