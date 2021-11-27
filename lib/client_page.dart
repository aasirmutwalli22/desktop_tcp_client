import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'chat.dart';
import 'chat_tile.dart';
import 'db_handler.dart';
import 'remote.dart';

enum ConnectionStatus{
  disconnected,
  connected,
  connecting,
}

class ClientPage extends StatefulWidget{
  final Remote remote;
  const ClientPage({Key? key, required this.remote}) : super(key: key);
  @override State<ClientPage> createState() => _ClientPageState();
}


class _ClientPageState extends State<ClientPage> {
  var sendEnter = false;
  ConnectionStatus connectionStatus = ConnectionStatus.disconnected;
  var chats = <Chat>[];
  final outputController = TextEditingController();
  final chatListViewController = ScrollController();
  Socket? socket;

  @override
  void initState() {
    super.initState();
    sync();
    // connect();
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
        actions: [

          IconButton(
            icon: const Icon(Icons.link),
            color: Colors.indigo.shade400,
            onPressed: connectionStatus == ConnectionStatus.connected ? disconnect : connect,
            tooltip: connectionStatus == ConnectionStatus.connected ? 'Disconnect' : 'Connect',
          ),
        ],
      ),
      body: Column(
        children: [
          if(connectionStatus == ConnectionStatus.connecting ) const LinearProgressIndicator(),
          Expanded(
            child: ListView.builder(
              controller: chatListViewController,
              itemCount: chats.length,
              itemBuilder: (context, index) =>
              chats[index].direction == Direction.incoming ?
              ChatTile.incoming(chats[index].message, onLongPress: () => copyMessageToClipboard(chats[index]),) :
              chats[index].direction == Direction.outgoing ?
              ChatTile.outgoing(chats[index].message, onLongPress: () => copyMessageToClipboard(chats[index]),) :
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
                    autofocus: false,
                    enabled: connectionStatus == ConnectionStatus.connected,
                    controller: outputController,
                    keyboardType: TextInputType.multiline,
                    maxLines: 4,
                    minLines: 1,
                    decoration: InputDecoration(
                      hintText: 'Message',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.send,),
                        onPressed: (){
                          if(connectionStatus == ConnectionStatus.connected) {
                            socket!.write(outputController.text + (sendEnter ? '\n' : ''));
                            setState(() => chats.add(Chat.fromRemote(
                              message: outputController.text,
                              direction: Direction.outgoing,
                              remote: widget.remote,
                            )));
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
    setState(() => connectionStatus = ConnectionStatus.connecting);
    Socket.connect(widget.remote.host, widget.remote.port).then((value) {
      setState(() {
        connectionStatus = ConnectionStatus.connected;
        socket = value;
        addChat(Chat.fromRemote(
          message: "remote connected",
          direction: Direction.system,
          remote: widget.remote,
        ));
      });
      value.listen((event) {
        addChat(Chat.fromRemote(
          message: ascii.decode(event),
          direction: Direction.incoming,
          remote: widget.remote,
        ));
        chatListViewController.jumpTo(chatListViewController.position.maxScrollExtent);
      },
        onDone: () {
          // if(socket != null) setState(() {
          //   connected = false;
          //   socket = null;
          // });// TODO: implement initState
          // if(socket != null) Navigator.of(context).pop();
          try {
            addChat(Chat.fromRemote(
              message: "remote disconnected",
              direction: Direction.system,
              remote: widget.remote,
            ));
            setState(() => connectionStatus = ConnectionStatus.disconnected);
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

  void addChat(Chat chat){
    setState(() {
      chats.add(chat);
      DbHandler.addChat(chat);
    });
  }

  void sync(){
    DbHandler.chats(widget.remote)!.then((value) => setState(() => chats = value));
  }
  void copyMessageToClipboard(Chat chat){
    Clipboard.setData(ClipboardData(text: chat.message));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied to clipboard'),
        duration: Duration(seconds: 1,),),
    );
  }
}


