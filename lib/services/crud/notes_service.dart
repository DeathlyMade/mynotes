import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:mynotes/services/crud/crud_exceptions.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class NotesService{
  Database? _db;

  List<DatabaseNote> _notes = [];
  final _notesStreamController = StreamController<List<DatabaseNote>>.broadcast();
  Stream<List<DatabaseNote>> get allNotes => _notesStreamController.stream;

  static final NotesService _shared = NotesService._sharedInstance();
  NotesService._sharedInstance();
  factory NotesService() => _shared;
  
  Future<void> _cacheNotes() async {

    final notes = await getAllNotes();
    _notes = notes.toList();
    _notesStreamController.add(_notes);
  }

  Future<DatabaseNote> updateNote({required DatabaseNote note, required String text}) async {
    await _ensureDBisOpen();
    final db = _getDatabaseOrThrow();
    await getNote(id: note.id); // Ensure note exists (throws if it doesn't)

    final updateCount = await db.update(noteTable, {textcolumn: text, isSyncedWithCloudcolumn: 0}, where: '$idcolumn = ?', whereArgs: [note.id]);
    if(updateCount == 0){
      throw FailedToUpdateNoteException();
    }
    final updatedNote = await getNote(id: note.id);
    _notes.removeWhere((note) => note.id == updatedNote.id);
    _notes.add(updatedNote);
    _notesStreamController.add(_notes);
    return updatedNote;
  }
  
  Future<Iterable<DatabaseNote>> getAllNotes() async {
    await _ensureDBisOpen();
    final db = _getDatabaseOrThrow();
    final notes = await db.query(noteTable);
    return notes.map((row) => DatabaseNote.fromRow(row));
  }

  Future<DatabaseNote> getNote({required int id}) async {
    await _ensureDBisOpen();
    final db = _getDatabaseOrThrow();
    final results = await db.query(noteTable, limit: 1, where: '$idcolumn = ?', whereArgs: [id]);
    if(results.isEmpty){
      throw NoteDoesNotExistException();
    }
    final note = DatabaseNote.fromRow(results.first);
    _notes.removeWhere((note) => note.id == id);
    _notes.add(note);
    _notesStreamController.add(_notes);
    return note;
  }
  
  Future<int> deleteAllNotes() async {
    await _ensureDBisOpen();
    final db = _getDatabaseOrThrow();
    final numberOfDeletions = await db.delete(noteTable);
    _notes=[];
    _notesStreamController.add(_notes);
    return numberOfDeletions;
  }
  
  Future<void> deleteNote({required int id}) async {
    await _ensureDBisOpen();
    final db = _getDatabaseOrThrow();
    final deleteCount = await db.delete(noteTable, where: '$idcolumn = ?', whereArgs: [id]);
    if(deleteCount == 0){
      throw FailedToDeleteNoteException();
    }else{
      _notes.removeWhere((note) => note.id == id);
      _notesStreamController.add(_notes);
      }
  }

  Future<DatabaseNote> createNote({required DatabaseUser owner}) async {
    await _ensureDBisOpen();
    final db = _getDatabaseOrThrow();

    final dbUser = await getUser(email: owner.email);
    if(dbUser != owner){
      throw UserDoesNotExistException();
    }
    const text='';

    final id = await db.insert(noteTable, {userIdcolumn: owner.id, textcolumn: text, isSyncedWithCloudcolumn: 1});
    final note = DatabaseNote(id: id, userId: owner.id, text: text, isSyncedWithCloud: true);

    _notes.add(note);
    _notesStreamController.add(_notes);
    
    return note;
  }

  Future<DatabaseUser> getOrCreateUser({required String email}) async {
    await _ensureDBisOpen();
    try{
      final user = await getUser(email: email);
      return user;
    }on UserDoesNotExistException{
      return await createUser(email: email);
    }catch(e){
      rethrow;
    }
  }
  
  Future<DatabaseUser> getUser({required String email}) async {
    await _ensureDBisOpen();
    final db = _getDatabaseOrThrow();
    final results = await db.query(userTable, limit: 1, where: '$emailcolumn = ?', whereArgs: [email.toLowerCase()]);
    if(results.isEmpty){
      throw UserDoesNotExistException();
    }
    return DatabaseUser.fromRow(results.first);
  }

  Future<DatabaseUser> createUser({required String email}) async {
    await _ensureDBisOpen();
    final db = _getDatabaseOrThrow();
    final results = await db.query(userTable, limit: 1, where: '$emailcolumn = ?', whereArgs: [email.toLowerCase()]);
    if(results.isNotEmpty){
      throw UserAlreadyExistsException();
    }
    final id = await db.insert(userTable, {emailcolumn: email.toLowerCase()});
    return DatabaseUser(id: id, email: email);
  }

  Future<void> deleteUser({required String email}) async {
    await _ensureDBisOpen();
    final db = _getDatabaseOrThrow();
    final deleteCount = await db.delete(userTable, where: '$emailcolumn = ?', whereArgs: [email.toLowerCase()]);
    if(deleteCount == 0){
      throw FailedToDeleteUserException();
    }
  }
  
  Database _getDatabaseOrThrow() {
    final db = _db;
    if(db == null){
      throw DatabaseNotOpenException();
    }
    return db;
  }

  Future<void> close() async {
    final db=_db;
    if(db == null){
      throw DatabaseNotOpenException();
    }
    await db.close();
    _db = null;
  }

  Future<void> _ensureDBisOpen() async {
    try{
      await open();
    }on DatabaseAlreadyOpenException{
      // Do nothing
    }
  }
  
  Future<void> open() async {
    if(_db !=null){
    throw DatabaseAlreadyOpenException();
    }
    try{
      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docsPath.path, dbName);
      final db = await openDatabase(dbPath);
      _db=db;

      await db.execute(createUserTable);
      await db.execute(createNoteTable);
      await _cacheNotes();

    }on MissingPlatformDirectoryException{
      throw UnableToGetDocumentsDirectoryException();
    }
  }
}






@immutable
class DatabaseUser{
  final int id;
  final String email;

  const DatabaseUser({required this.id, required this.email});

  DatabaseUser.fromRow(Map<String, Object?> map):
      id = map[idcolumn] as int,
      email = map[emailcolumn] as String;

  @override
  String toString() => 'DatabaseUser(id: $id, email: $email)';

  @override
  bool operator ==(covariant DatabaseUser other) => id==other.id;
  
  @override
  int get hashCode => id.hashCode;
}

class DatabaseNote{
  final int id;
  final int userId;
  final String text;
  final bool isSyncedWithCloud;

  DatabaseNote({required this.id, required this.userId, required this.text, required this.isSyncedWithCloud});

  DatabaseNote.fromRow(Map<String, Object?> map):
      id = map[idcolumn] as int,
      userId = map[userIdcolumn] as int,
      text = map[textcolumn] as String,
      isSyncedWithCloud = (map[isSyncedWithCloudcolumn] as int) == 1 ? true : false;

  @override
  String toString() => 'DatabaseNote(id: $id, userId: $userId, isSyncedWithCloud: $isSyncedWithCloud), text: $text';

  @override
  bool operator ==(covariant DatabaseNote other) => id==other.id;

  @override
  int get hashCode => id.hashCode;
}

const dbName = 'notes.db';
const userTable = 'users';
const noteTable = 'notes';
const idcolumn = 'id';
const emailcolumn = 'email';
const userIdcolumn = 'userId';
const textcolumn = 'text';
const isSyncedWithCloudcolumn = 'isSyncedWithCloud';
const createUserTable = '''
      CREATE TABLE IF NOT EXISTS $userTable(
        $idcolumn INTEGER NOT NULL,
        $emailcolumn TEXT NOT NULL UNIQUE,
        PRIMARY KEY($idcolumn AUTOINCREMENT)
      );''';
const createNoteTable = '''
      CREATE TABLE IF NOT EXISTS $noteTable(
        $idcolumn INTEGER NOT NULL,
        $userIdcolumn INTEGER NOT NULL,
        $textcolumn TEXT,
        $isSyncedWithCloudcolumn INTEGER NOT NULL DEFAULT 0,
        PRIMARY KEY($idcolumn AUTOINCREMENT),
        FOREIGN KEY($userIdcolumn) REFERENCES $userTable($idcolumn)
      );''';
