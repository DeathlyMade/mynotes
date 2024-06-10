import 'package:flutter/material.dart';
import 'package:mynotes/contants/routes.dart';
import 'package:mynotes/enums/menu_actions.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/services/cloud/cloud_note.dart';
import 'package:mynotes/services/cloud/firebase_cloud_storage.dart';
import 'package:mynotes/utilities/dialogs/logout_dialog.dart';
import 'package:mynotes/views/notes/notes_list_view.dart';


class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {

  late final FirebaseCloudStorage _notesService;
  String get userId => AuthService.firebase().currentUser!.id;

  @override
  void initState() {
    _notesService = FirebaseCloudStorage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
        //backgroundColor: Colors.blue,
        //titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(createUpdateNoteRoute);
            },
            icon: const Icon(Icons.add),
          ),
          PopupMenuButton<MenuAction>(onSelected: (value) async {
            switch (value) {
              case MenuAction.logout:
                await showLogoutDialog(context).then((value) {
                  if (value) {
                    AuthService.firebase().logOut();
                    Navigator.of(context).pushNamedAndRemoveUntil(loginroute, (route) => false);
                  }
                });
                break;
            }
          }, itemBuilder: (context) {
            return const [
              PopupMenuItem<MenuAction>(
                value: MenuAction.logout,
                child: Text('Logout'),
              )
            ];
          },)
        ],
      ),
      body: StreamBuilder(
        stream: _notesService.allNotes(ownerUserId: userId),
        builder: (context, snapshot) {
          switch(snapshot.connectionState){
            case ConnectionState.waiting:
            case ConnectionState.active:
              if(snapshot.hasData){
                final notes = snapshot.data as Iterable<CloudNote>;
                return NotesListView(
                  notes: notes,
                    onDeleteNote: (note) async {
                    await _notesService.deleteNote(documentId: note.documentId);
                    },
                    onTap: (note) {
                      Navigator.of(context).pushNamed(createUpdateNoteRoute, arguments: note);
                    },
                  );
                } else{
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
            default:
              return const Center(
                child: CircularProgressIndicator(),
              );
          }
        }
      ),
    );
  }
}