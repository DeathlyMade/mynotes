import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mynotes/services/cloud/cloud_note.dart';
import 'package:mynotes/services/cloud/cloud_storage_constants.dart';
import 'package:mynotes/services/cloud/cloud_storage_exceptions.dart';

class FirebaseCloudStorage{
  final notes = FirebaseFirestore.instance.collection('notes');

  Future<void> deleteNote({required String documentId}) async {
    try{
      await notes.doc(documentId).delete();
    }catch(e){
      throw CouldNotDeleteNoteException();
    }
  }
  
  Future<void> updateNote({required String documentId, required String text}) async {
    try{
      await notes.doc(documentId).update({
        textFieldName: text,
      });
    }catch(e){
      throw CouldNotUpdateNoteException();
    }
  }
  
  Stream <Iterable<CloudNote>> allNotes({required String ownerUserId}){
    return notes.where(ownerUserFieldName, isEqualTo: ownerUserId).snapshots().map((event) => event.docs.map((doc) => CloudNote.fromSnapshot(doc)));
  }

  Future<CloudNote> createNewNote({required String ownerUserId}) async {
    try{
      final document = await notes.add({
      ownerUserFieldName: ownerUserId,
      textFieldName: '',
    });
      final fetchedNote = await document.get();
      return CloudNote(documentId: fetchedNote.id, ownerUserId: ownerUserId, text: '');
    }catch(e){
      throw CouldNotCreateNoteException();
    }
  }
}