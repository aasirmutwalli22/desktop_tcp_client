import 'dart:convert';
import 'dart:io';
import 'package:desktop_tcp_client/chat_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'chat.dart';
import 'remote.dart';

class ClientPage extends StatefulWidget{
  final Remote remote;
  const ClientPage({Key? key, required this.remote}) : super(key: key);
  @override State<ClientPage> createState() => _ClientPageState();
}

class _ClientPageState extends State<ClientPage> {
  var sendEnter = false;
  // var messageNotEmpty = false;
  var connected = false;
  var chats = <Chat>[];
  final outputController = TextEditingController();
  final chatListViewController = ScrollController();
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
        title: Text('${widget.remote.host}:${widget.remote.port}'),
      ),
      body: socket == null ? const LinearProgressIndicator() : Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: chatListViewController,
              itemCount: chats.length,
              itemBuilder: (context, index) =>
              chats[index].direction == Direction.incoming ?
              ChatTile.incoming(chats[index].message) :
              chats[index].direction == Direction.outgoing ?
              ChatTile.outgoing(chats[index].message) :
              ChatTile.system(chats[index].message),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Tooltip(
                  message: 'Send enter at end',
                  child: TextButton(
                    onPressed: ()=> setState(() => sendEnter = !sendEnter),
                    child: const Icon(Icons.keyboard_return,),
                    style: TextButton.styleFrom(
                      shape: const CircleBorder(),
                      fixedSize: const Size.fromRadius(20),
                      backgroundColor: sendEnter ? Colors.indigo.shade100 : Colors.grey.shade300,
                      primary: sendEnter ? Colors.indigo.shade400 : Colors.grey.shade400,
                    ),
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: outputController,
                    keyboardType: TextInputType.multiline,
                    maxLines: 4,
                    minLines: 1,
                    decoration: InputDecoration(
                      hintText: 'Message',
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
    Socket.connect(widget.remote.host, widget.remote.port).then((value) {
      setState(() {
        chats.clear();
        connected = true;
        socket = value;
        setState(() => chats.add(Chat("remote connected", Direction.system)));
      });
      value.listen((event) {
        // inputController.text += ascii.decode(event);
        setState(() => chats.add(Chat(ascii.decode(event), Direction.incoming)));
        chatListViewController.jumpTo(chatListViewController.position.maxScrollExtent);
      },
        onDone: () {
          // if(socket != null) setState(() {
          //   connected = false;
          //   socket = null;
          // });// TODO: implement initState
          // if(socket != null) Navigator.of(context).pop();
          chats.add(Chat("remote connected", Direction.system));
          try {
            if(socket != null) Navigator.of(context).pop();
          } catch (e) {
            // print(e);
          }
        },
        onError: (_, __,)=> ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_))),
      ).onError((_, __,)=> ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_))));
    });
  }

  void disconnect(){
    if(socket != null) socket!.destroy();
  }
}


