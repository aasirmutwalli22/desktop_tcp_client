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
  Remote? remoteToDelete;

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
            onPressed: ()=> setState(() {
              formOpen = !formOpen;
              remoteToDelete = null;
            }),
            tooltip: 'Add remote',
          ),
        ],
      ),
      body: Column(
        children: [
          addRemote(),
          deleteRemote(),
          ListTile(
            title: Text('Saved remotes',
              style: Theme.of(context).textTheme.button!.copyWith(
                color: Colors.indigo.shade400,),
            ),
            dense: true,
          ),
          Expanded(
            child: ListView.builder(
              itemCount: DbHandler.remotes.length,
              itemBuilder: (BuildContext context, int index) => Padding(
                padding: const EdgeInsets.only(left: 8.0, top: 2.0, bottom: 2.0),
                child: ListTile(
                  title: Text('${DbHandler.remotes[index].host}:${DbHandler.remotes[index].port}'),
                  onTap: () => openChat(DbHandler.remotes[index]),
                  onLongPress: (){
                    Clipboard.setData(ClipboardData(text: DbHandler.remotes[index].host));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('host copied to clipboard'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.horizontal(left: Radius.circular(16)),
                  ),
                  tileColor: Colors.grey.shade200,
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => setState(() {
                      remoteToDelete = DbHandler.remotes[index];
                      formOpen = false;
                    }),
                    // onPressed: () => delete(DbHandler.remotes[index]),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget addRemote(){
    return AnimatedSize(
        duration: const Duration(milliseconds: 300),
        reverseDuration: const Duration(milliseconds: 500),
        child: SizedBox(
          height: remoteToDelete == null && formOpen ? null : 0,
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
                      title: Text(
                        'Add',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.button!.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      onTap: add,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
  }

  Widget deleteRemote(){
    return
      AnimatedSize(
        duration: const Duration(milliseconds: 300),
        reverseDuration: const Duration(milliseconds: 500),
        child: SizedBox(
          height: remoteToDelete != null ? null : 0,
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
                  const ListTile(
                    title: Text('Deleting remote will delete chats as well'),
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
                      title: Text(
                        'Delete',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.button!.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      onTap: () => delete(remoteToDelete!),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: ListTile(
                      dense: true,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      title: Text(
                        'Cancel',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.button,
                      ),
                      onTap: () => setState(() => remoteToDelete = null),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
  }

  void sync() {
    DbHandler.syncRemotes().then((_) => setState((){}));
    FocusScope.of(context).unfocus();
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

  void delete(Remote remote){
    // ScaffoldMessenger.of(context).showMaterialBanner(
    //   MaterialBanner(
    //     content: const Text('Deleting Remote will delete chats as well'),
    //     actions: [
    //       TextButton(
    //         child: const Text('Delete'),
    //         onPressed: ()=> DbHandler
    //             .deleteChats(remote)!
    //             .then((value) => DbHandler.deleteRemote(remote)!
    //             .then((value) {
    //               ScaffoldMessenger.of(context).clearMaterialBanners();
    //               sync();
    //             },),
    //         ),
    //       ),
    //       TextButton(
    //         child: const Text('Cancel'),
    //         onPressed: ()=> ScaffoldMessenger.of(context).clearMaterialBanners(),
    //       ),
    //     ],
    //   ),
    // );
    DbHandler
        .deleteChats(remote)!
        .then((value) => DbHandler.deleteRemote(remote)!
        .then((value) {
          remoteToDelete = null;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Remote deleted successfully'),
              duration: Duration(seconds: 1),
            ),
          );
          sync();
    },),);
  }

  void openChat(Remote remote){
    Navigator
        .of(context)
        .push(MaterialPageRoute(builder: (_) => ClientPage(remote: remote,),),);
  }
}
