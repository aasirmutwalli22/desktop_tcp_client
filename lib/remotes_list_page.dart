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
  var connected = false;
  var selectedIndex = 0;

  final hostController = TextEditingController();
  final portController = TextEditingController();
  final outputController = TextEditingController();
  final inputController = TextEditingController();

  var remotes = <RemoteServer>[
    const RemoteServer(host: '192.168.1.100', port: 3333),
    const RemoteServer(host: '192.168.2.100', port: 3333),
    const RemoteServer(host: '192.168.3.100', port: 3333),
  ];

  @override
  Widget build(context) {
    return Row(
      children: [
        // AnimatedContainer(
        //   color: connected ? Colors.green : Colors.red,
        //   duration: const Duration(seconds: 1),
        //   width: 360,
        //   child: leftPanel(),
        // ),
        SizedBox(
          width: 360,
          child: leftPanel(),
        ),
        // if(connected)
          const VerticalDivider(color: Colors.grey,),
        // if(connected)
          Expanded(
          child: rightPanel(),
        ),
      ],
    );
  }

  Widget leftPanel(){
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          title: const Text('Saved remotes'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.grey.shade900,
          elevation: 0,
          shape: const Border(
            bottom: BorderSide(color: Colors.grey,),
          ),
          actions : [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: (){
                ScaffoldMessenger.of(context).showMaterialBanner(
                    MaterialBanner(
                      actions: [
                        TextButton(
                          child: const Text('Close'),
                          onPressed : () {
                            ScaffoldMessenger.of(context).clearMaterialBanners();
                          },
                        )
                      ],
                      content: const Text('banner'),
                ));

              },
            )
          ],
      ),
      body: ListView.builder(
        itemCount: remotes.length,
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.only(right: 4.0, top: 4.0, bottom: 4.0),
          child: ListTile(
            // title: Text(remotes[index].name),
            title: Text('${remotes[index].host}:${remotes[index].port}'),
            shape:  const RoundedRectangleBorder(
              borderRadius: BorderRadius.horizontal(right: Radius.circular(4.0)),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => setState(() => remotes.removeAt(index)),
            ),
            onTap: (){
              setState(() {
                connected = true;
                selectedIndex = index;
              });
            },
            tileColor: index == selectedIndex ? Colors.indigo.shade100 : Colors.grey.shade200,
          ),
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

  Widget rightPanel(){
    return Scaffold(
      appBar: AppBar(
        title: Text(remotes.isNotEmpty ? '${remotes[selectedIndex].host}:${remotes[selectedIndex].port}' : ''),
        backgroundColor: Colors.white,
        foregroundColor: Colors.grey.shade900,
        elevation: 0,
        shape: const Border(
          bottom: BorderSide(color: Colors.grey,),
        ),
        actions : [
          const Padding(
            padding: EdgeInsets.all(4.0),
            child: Center(child: Text('Connected',),),
          ),
          TextButton.icon(
            icon: const Icon(Icons.close),
            label: const Text('CLOSE'),
            onPressed: (){
              setState(() {
                connected = false;
              });
            },
            style : TextButton.styleFrom(
              shape: shape,
            ),
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: TextField(
              controller: inputController,
              maxLines: null,
              expands: true,
              readOnly: true,
              decoration: InputDecoration.collapsed(
                hintText: '',
                fillColor: Colors.grey.shade300,
                filled: true,
              ),
            ),
          ),
          Card(
            shape: const ContinuousRectangleBorder(),
            elevation: 0,
            child: TextField(
              controller: outputController,
              maxLines: 4,
              minLines: 1,
              keyboardType: TextInputType.multiline,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Message',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4.0),
                  borderSide: BorderSide(
                    color: Colors.grey.shade800,
                    width: 2,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4.0),
                  borderSide: BorderSide(
                    color: Colors.grey.shade800,
                    width: 2,
                  ),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send,),
                  onPressed: (){
                    setState((){
                      inputController.text += outputController.text;
                    });
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  showAddRemoteServerDialog(){
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        titlePadding: const EdgeInsets.all(8.0),
        contentPadding: const EdgeInsets.all(8.0),
        title: const Text('Add remote', textAlign: TextAlign.center,),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Divider(),
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
          ],
        ),
        actions: [
          OutlinedButton.icon(
            onPressed: ()=> Navigator.of(context).pop(),
            icon: const Icon(Icons.cancel),
            label: const Text('Cancel'),
            style: OutlinedButton.styleFrom(
              primary: Colors.grey.shade900,
            ),
          ),
          OutlinedButton.icon(
            onPressed: ()=> Navigator.of(context).pop(RemoteServer(host: hostController.text, port: int.tryParse(portController.text) ?? 0)),
            icon: const Icon(Icons.add),
            label: const Text('Add'),
            style: OutlinedButton.styleFrom(
              primary: Colors.grey.shade900,
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