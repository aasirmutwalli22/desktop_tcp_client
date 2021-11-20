import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'main.dart';
import 'remote_server.dart';

class RemotesListPage extends StatefulWidget{
  const RemotesListPage({Key? key}) : super(key: key);

  @override
  State<RemotesListPage> createState() => _RemotesListPageState();
}

class _RemotesListPageState extends State<RemotesListPage> {

  final nameController = TextEditingController();
  final hostController = TextEditingController();
  final portController = TextEditingController();

  var remotes = <RemoteServer>[
    const RemoteServer(name: 'rx', host: '192.168.1.100', port: 3333),
    const RemoteServer(name: 'kp', host: '192.168.2.100', port: 3333),
    const RemoteServer(name: 'et', host: '192.168.3.100', port: 3333),
  ];

  @override
  Widget build(context) {
    return  Scaffold(
      appBar: AppBar(
        title: const Text('Saved remotes'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.grey.shade900,
        elevation: 0,
        shape: const Border(
          bottom: BorderSide(color: Colors.grey,),
        ),
      ),
      backgroundColor: Colors.white,
      body: Row(
        children: [
          SizedBox(
            width: 300,
            child: drawerScreen(),
          ),
          const VerticalDivider(color: Colors.grey,),
          Expanded(
            child: Column(
              children: [
                const Expanded(
                  child: TextField(),
                ),
                Row(
                  children: [
                    const Expanded(
                      child: TextField(),
                    ),
                    IconButton(onPressed: (){}, icon: const Icon(Icons.send,),),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget drawerScreen(){
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView.builder(
        itemCount: remotes.length,
        itemBuilder: (context, index) => ListTile(
          title: Text(remotes[index].name),
          subtitle: Text('${remotes[index].host}:${remotes[index].port}'),
          shape: shape,
          trailing: IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => setState(() => remotes.removeAt(index)),
          ),
          onTap: (){},
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        label: const Text('Add'),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.grey.shade900,
        foregroundColor: Colors.white,
        shape: shape,
        onPressed: () {
          showAddRemoteServerDialog();
          // setState(() => remotes.add(const RemoteServer(name: 'new', host: '192.168.1.100', port: 3000,)));
        },
      ),
    );
  }
  showAddRemoteServerDialog(){
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        titlePadding: const EdgeInsets.all(8.0),
        contentPadding: const EdgeInsets.all(8.0),
        title: const Text('Add remote', textAlign: TextAlign.center),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'name',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: TextField(
              controller: hostController,
              decoration: const InputDecoration(
                labelText: 'host',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: TextField(
              controller: portController,
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
              ],
              decoration: const InputDecoration(
                labelText: 'port',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: OutlinedButton.icon(
              onPressed: ()=> Navigator.of(context)
                  .pop(RemoteServer(name: nameController.text, host: hostController.text, port: int.tryParse(portController.text) ?? 0)),
              icon: const Icon(Icons.add),
              label: const Text('Add'),
              style: OutlinedButton.styleFrom(
                primary: Colors.grey.shade900,
                shape: shape,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: OutlinedButton.icon(
              onPressed: ()=> Navigator.of(context).pop(),
              icon: const Icon(Icons.cancel),
              label: const Text('Cancel'),
              style: OutlinedButton.styleFrom(
                primary: Colors.grey.shade900,
                shape: shape,
              ),
            ),
          ),
        ],
      ),
    ).then((value) {
      if(value != null && value.runtimeType == RemoteServer){
        setState(() => remotes.add(value));
      }
    });
  }
}