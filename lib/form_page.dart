import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'client_page.dart';
import 'db_handler.dart';
import 'remote.dart';

class FormPage extends StatefulWidget{

  const FormPage({Key? key}) : super(key: key);

  @override
  State<FormPage> createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  final hostController = TextEditingController();
  final portController = TextEditingController();
  var formOpen = true;
  var remotes = <Remote>[];

  @override
  void initState() {
    super.initState();
    sync();
  }


  @override
  Widget build(context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tcp client'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            color: Colors.indigo.shade400,
            onPressed: sync,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: Icon(formOpen ? Icons.close : Icons.add),
            color: Colors.indigo.shade400,
            onPressed: ()=> setState(() => formOpen = !formOpen),
            tooltip: 'Add remote',
          ),
        ],
      ),
      body: Column(
        children: [
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            reverseDuration: const Duration(milliseconds: 500),
            child: SizedBox(
              height: formOpen ? null : 0,
              child: Card(
                margin: const EdgeInsets.all(8),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: const BorderSide(
                    color: Colors.grey,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: TextField(
                          controller: hostController,
                          autofocus: false,
                          decoration: InputDecoration(
                            labelText: 'Host',
                            filled: false,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: TextField(
                          autofocus: false,
                          controller: portController,
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                          ],
                          decoration: InputDecoration(
                            labelText: 'Port',
                            filled: false,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                          ),
                        ),
                      ),
                      const Divider(),
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: ListTile(
                          dense: true,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                          tileColor: Colors.indigo.shade300,
                          title: Text('Add', textAlign: TextAlign.center, style: Theme.of(context).textTheme.button!.copyWith(
                            color: Colors.white,
                          ),),
                          onTap: add,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // const Divider(),
          ListTile(
            title: Text('Saved remotes', style: Theme.of(context).textTheme.button!.copyWith(
              color: Colors.indigo.shade400,
            ),),
            dense: true,
          ),
          Expanded(
            child: ListView.builder(
              itemCount: remotes.length,
              itemBuilder: (BuildContext context, int index) => Padding(
                padding: const EdgeInsets.only(left: 8.0, top: 2.0, bottom: 2.0),
                child: ListTile(
                  title: Text('${remotes[index].host}:${remotes[index].port}'),
                  onTap: () => openChat(remotes[index]),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.horizontal(left: Radius.circular(16)),
                  ),
                  tileColor: Colors.grey.shade200,
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => deleteRemote(remotes[index]),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void sync() {
    DbHandler.remotes()!.then((value) => setState(() => remotes = value));
  }

  void add(){
      if(hostController.text.isNotEmpty) {
        Remote remote = Remote(hostController.text, int.tryParse(portController.text) ?? 80,);
        DbHandler.isAvailable(remote)!.then((available){
          if(available){
            ScaffoldMessenger
                .of(context)
                .showSnackBar(const SnackBar(content: Text('Remote already exist'),),);
          } else {
            setState(() => formOpen = false);
            hostController.clear();
            portController.clear();
            DbHandler.addRemote(remote)!.then((value) => sync());
          }
        });
      } else {
        ScaffoldMessenger
            .of(context)
            .showSnackBar(const SnackBar(content: Text('Host not provided'),),);
      }
  }
  void deleteRemote(Remote remote){
    DbHandler.deleteChats(remote)!.then((value) => DbHandler.deleteRemote(remote)!.then((value) => sync()));
  }
  void openChat(Remote remote){
    Navigator
        .of(context)
        .push(MaterialPageRoute(builder:
        (_) => ClientPage(remote: remote,),),);
  }
}
