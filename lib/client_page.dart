import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';

const outgoingMessageAlignment = Alignment.centerRight;
const incomingMessageAlignment = Alignment.centerLeft;
final outgoingMessageColor = Colors.indigo.shade100;
final incomingMessageColor = Colors.red.shade100;
const outgoingMessagePadding = EdgeInsets.only( top: 4, bottom: 4, right: 8, left: 32,);
const incomingMessagePadding = EdgeInsets.only( top: 4, bottom: 4, right: 32, left: 8,);
const outgoingMessageBorderRadius = BorderRadius.only(
  topLeft: Radius.circular(16),
  topRight: Radius.circular(16),
  bottomLeft: Radius.circular(16),
  bottomRight: Radius.circular(0),
) ;
const incomingMessageBorderRadius = BorderRadius.only(
  topLeft: Radius.circular(0),
  topRight: Radius.circular(16),
  bottomLeft: Radius.circular(16),
  bottomRight: Radius.circular(16),
);

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
        title: Text('${widget.host}:${widget.port}'),
      ),
      body: socket == null ? const LinearProgressIndicator() : Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: chatListViewController,
              itemCount: chats.length,
              itemBuilder: (context, index) => Align(
                alignment: chats[index].direction == Direction.outgoing
                    ? outgoingMessageAlignment
                    : incomingMessageAlignment,
                child: Container(
                  margin: chats[index].direction == Direction.outgoing
                      ? outgoingMessagePadding
                      : incomingMessagePadding,
                  padding: const EdgeInsets.all(16),
                  child: Text(chats[index].message),
                  decoration : BoxDecoration(
                    color: chats[index].direction == Direction.outgoing
                        ? outgoingMessageColor
                        : incomingMessageColor,
                    borderRadius: chats[index].direction == Direction.outgoing
                        ? outgoingMessageBorderRadius
                        : incomingMessageBorderRadius,
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
      // bottomNavigationBar: Container(
      //   padding: const EdgeInsets.all(8.0),
      //   child: Row(
      //     children: [
      //       IconButton(
      //         icon: const Icon(Icons.keyboard_return),
      //         onPressed: ()=> setState(() => sendEnter = !sendEnter),
      //         color: sendEnter ? Colors.indigo.shade400 : Colors.grey.shade700,
      //         tooltip: 'Send enter on end',
      //       ),
      //       Expanded(
      //         child: TextField(
      //           controller: outputController,
      //           keyboardType: TextInputType.multiline,
      //           maxLines: 4,
      //           minLines: 1,
      //           decoration: InputDecoration(
      //             hintText: 'Message',
      //             suffixIcon: IconButton(
      //               icon: const Icon(Icons.send,),
      //               onPressed: (){
      //                 if(connected) {
      //                   socket!.write(outputController.text + (sendEnter ? '\n' : ''));
      //                   setState(() => chats.add(Chat(outputController.text, Direction.outgoing)));
      //                   outputController.clear();
      //                 }
      //               },
      //             ),
      //           ),
      //         ),
      //       ),
      //     ],
      //   ),
      // ),
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
        chatListViewController.jumpTo(chatListViewController.position.maxScrollExtent);
        setState(() => chats.add(Chat(ascii.decode(event), Direction.incoming)));
      },
        onDone: () {
          // if(socket != null) setState(() {
          //   connected = false;
          //   socket = null;
          // });// TODO: implement initState
          // if(socket != null) Navigator.of(context).pop();
          try {
            if(socket != null) Navigator.of(context).pop();
          } catch (e) {
            print(e);
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

class Chat{
  final String message;
  final int direction;
  Chat(this.message, this.direction);
}

class Direction{
  static const int incoming = 0;
  static const int outgoing = 1;
}