import 'package:flutter/material.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/services/crud/notes_service.dart';

class NewNoteView extends StatefulWidget {
  const NewNoteView({super.key});

  @override
  State<NewNoteView> createState() => _NewNoteViewState();
}

class _NewNoteViewState extends State<NewNoteView> {

  DatabaseNote? _note;
  late final NotesService _notesService;
  late final TextEditingController _textEditingController;

  @override
  void initState() {
    _notesService = NotesService();
    _textEditingController = TextEditingController();
    super.initState();
  }

  Future<DatabaseNote> createNewNote() async {
    final existingNote = _note;
    if(existingNote != null){
      return existingNote;
    }
    final currentUser = AuthService.firebase().currentUser!;
    final email = currentUser.email!;
    final owner = await _notesService.getUser(email: email);
    return await _notesService.createNote(owner: owner);
  }

  void _deleteNoteIfTextIsEmpty() {
    final note = _note;
    if(_textEditingController.text.isEmpty && note != null){
      _notesService.deleteNote(id: note.id);
    }
  }

  void _saveNoteIfTextNotEmpty() async {
    final note = _note;
    if(_textEditingController.text.isNotEmpty && note != null){
      await _notesService.updateNote(note: note, text: _textEditingController.text);
    }
  }

  void _textCintrollerListener() async {
    final note = _note;
    if(note == null){
      return;
    }
    final text = _textEditingController.text;
    await _notesService.updateNote(note: note, text: text);
  }

  void _setupTextControllerListener() {
    _textEditingController.removeListener(_textCintrollerListener);
    _textEditingController.addListener(_textCintrollerListener);
  }



  @override
  void dispose() {
    _deleteNoteIfTextIsEmpty();
    _saveNoteIfTextNotEmpty();
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Note'),
      ),
      body: FutureBuilder(
        future: createNewNote(),
        builder: (context, snapshot) {
          switch(snapshot.connectionState){
            case ConnectionState.done:
              _note = snapshot.data as DatabaseNote;
              _setupTextControllerListener();
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _textEditingController,
                  keyboardType: TextInputType.multiline,
                  decoration: const InputDecoration(
                    hintText: 'Enter your note here',
                    border: OutlineInputBorder()
                  ),
                  maxLines: null,
                ),
              );
            default:
              return const Center(
                child: CircularProgressIndicator(),
              );
          }
        },
      )
      );
  }
}