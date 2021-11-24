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
      ),
      home: const FormPage(),
    );
  }
}
class HomePage extends StatefulWidget{
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var sendEnter = false;
  var messageNotEmpty = false;
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
        foregroundColor: Colors.grey.shade900,
        shape: Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
        title: const Text('Tcp client'),
        titleTextStyle: Theme.of(context).textTheme.headline6!.copyWith(
          fontWeight: FontWeight.normal,
          fontSize: 16,
        ),
        actions: [
          if(connected) IconButton(onPressed: disconnect, icon: const Icon(Icons.close,),),
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
            itemBuilder: (context, index) => Align(
              alignment: chats[index].direction == Direction.outgoing ? Alignment.centerRight: Alignment.centerLeft,
              child: Container(
                margin: chats[index].direction == Direction.outgoing ? const EdgeInsets.only(
                  top: 4, bottom: 4, right: 8, left: 32,
                ) : const EdgeInsets.only(
                  top: 4, bottom: 4, right: 32, left: 8,
                ),
                padding: const EdgeInsets.all(16),
                child: Text(chats[index].message),
                decoration : BoxDecoration(
                  color: chats[index].direction == Direction.outgoing ? Colors.indigo.shade50 : Colors.red.shade50,
                  borderRadius: chats[index].direction == Direction.outgoing
                      ? const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(0),
                  ) : const BorderRadius.only(
                    topLeft: Radius.circular(0),
                    topRight: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
              ),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.keyboard_return),
                onPressed: ()=> setState(() => sendEnter = !sendEnter),
                color: sendEnter ? Colors.indigo.shade400 : Colors.grey.shade700,
                tooltip: 'Send enter',
              ),
              Expanded(
                child: TextField(
                  controller: outputController,
                  autofocus: true,
                  keyboardType: TextInputType.multiline,
                  maxLines: 4,
                  cursorColor: Colors.grey.shade800,
                  minLines: 1,
                  onChanged: (value)=> setState(() => messageNotEmpty = value.isNotEmpty),
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: 'Message',
                    filled: true,
                    fillColor: Colors.indigo.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: messageNotEmpty ? IconButton(
                      icon: const Icon(Icons.send,),
                      onPressed: (){
                        if(connected) {
                          socket!.write(outputController.text);
                          setState(() => chats.add(Chat(outputController.text, Direction.outgoing)));
                          outputController.clear();
                        }
                      },
                    ) : null,
                  ),
                ),
              ),
            ],
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
              isDense: true,
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
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: hostController,
              decoration: InputDecoration(
                isDense: true,
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
                isDense: true,
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
                if(hostController.text.isNotEmpty) {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) =>
                    ClientPage(host: hostController.text, port: int.tryParse(portController.text) ?? 80)));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Host not provided'),));
                }
              },
              child: const Text('Connect'),
            ),
          ),
        ],
      ),
    );
  }
}

class ClientPage extends StatefulWidget{
  final String host;
  final int port;
  const ClientPage({Key? key, required this.host, required this.port}) : super(key: key);
  @override State<ClientPage> createState() => _ClientPageState();
}

class _ClientPageState extends State<ClientPage> {
  var sendEnter = false;
  // var messageNotEmpty = false;
  var connected = false;
  var chats = <Chat>[];
  final outputController = TextEditingController();
  Socket? socket;

  @override
  void initState() {
    super.initState();
    connect();
  }

  @override
  void dispose() {
    disconnect();
    super.dispose();
  }

  @override
  Widget build(context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.host}:${widget.port}'),
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          if(socket == null) const LinearProgressIndicator(),
          Expanded(
            child: ListView.builder(
              itemCount: chats.length,
              itemBuilder: (context, index) => Align(
                alignment: chats[index].direction == Direction.outgoing ? Alignment.centerRight: Alignment.centerLeft,
                child: Container(
                  margin: chats[index].direction == Direction.outgoing ? const EdgeInsets.only(
                    top: 4, bottom: 4, right: 8, left: 32,
                  ) : const EdgeInsets.only(
                    top: 4, bottom: 4, right: 32, left: 8,
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Text(chats[index].message),
                  decoration : BoxDecoration(
                    color: chats[index].direction == Direction.outgoing ? Colors.indigo.shade50 : Colors.red.shade50,
                    borderRadius: chats[index].direction == Direction.outgoing ?
                    const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(0),
                    ) :
                    const BorderRadius.only(
                      topLeft: Radius.circular(0),
                      topRight: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.keyboard_return),
                  onPressed: ()=> setState(() => sendEnter = !sendEnter),
                  color: sendEnter ? Colors.indigo.shade400 : Colors.grey.shade700,
                  tooltip: 'Send enter on end',
                ),
                Expanded(
                  child: TextField(
                    controller: outputController,
                    autofocus: true,
                    keyboardType: TextInputType.multiline,
                    maxLines: 4,
                    cursorColor: Colors.grey.shade800,
                    minLines: 1,
                    // onChanged: (value)=> setState(() => messageNotEmpty = value.isNotEmpty),
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: 'Message',
                      filled: true,
                      fillColor: Colors.indigo.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide.none,
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.send,),
                        onPressed: (){
                          if(connected) {
                            socket!.write(outputController.text + (sendEnter ? '\n' : ''));
                            setState(() => chats.add(Chat(outputController.text, Direction.outgoing)));
                            outputController.clear();
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void connect(){
    Socket.connect(widget.host, widget.port).then((value) {
      setState(() {
        chats.clear();
        connected = true;
        socket = value;
      });
      value.listen((event) {
        // inputController.text += ascii.decode(event);
        setState(() => chats.add(Chat(ascii.decode(event), Direction.incoming)));
      },
        onDone: () {
        // if(socket != null) setState(() {
        //   connected = false;
        //   socket = null;
        // });// TODO: implement initState
          if(socket != null) Navigator.of(context).pop();
        },
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