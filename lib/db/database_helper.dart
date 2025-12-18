import 'package:notes/models/folder_model.dart';
import 'package:notes/models/note_model.dart';
import 'package:notes/models/tag_model.dart';
import 'package:notes/utils/constants.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  
  DatabaseHelper._init();
  
  Future<Database> get database async{
    if (_database != null) return _database!;
    _database = await _initDB(AppConstants.databaseName);
    return _database!;
  }
  
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    
    return await openDatabase(path, version: AppConstants.databaseVersion, onCreate: _createDB);
  }
  
  Future<void> _createDB(Database db, int version) async{
    await db.execute('''
    CREATE TABLE ${AppConstants.tableNotes}(
      id TEXT PRIMARY KEY,
      title TEXT NOT NULL,
      content TEXT NOT NULL,
      folder_id TEXT,
      tags TEXT,
      color_index INTEGER DEFAULT 0,
      is_pinned INTEGER DEFAULT 0,
      is_favourite INTEGER DEFAULT 0,
      created_at TEXT NOT NULL,
      modified_at TEXT NOT NULL,
      attachments TEXT,
      content_json TEXT,
      FOREIGN KEY (folder_id) REFERENCES ${AppConstants.tableFolders} (id) ON DELETE SET NULL
    ) 
    ''');

    await db.execute('''
      CREATE TABLE ${AppConstants.tableFolders} (
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL UNIQUE,
      color_index INTEGER DEFAULT 0,
      created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE ${AppConstants.tableTags}(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL UNIQUE,
        color_index INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_notes_modified_at ON ${AppConstants.tableNotes}(modified_at DESC)
    ''');

    await db.execute('''
      CREATE INDEX idx_notes_pinned_at ON ${AppConstants.tableNotes}(is_pinned DESC)
    ''');

    await db.execute('''
      CREATE INDEX idx_notes_folder ON ${AppConstants.tableNotes}(folder_id)
    ''');
  }

  Future<String> insertNote(NoteModel note) async {

    final db = await database;
    await db.insert(AppConstants.tableNotes, note.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    return note.id!;
  }

  Future<List<NoteModel>> getALLNotes() async {

    final db = await database;
    final result = await db.query(AppConstants.tableNotes, orderBy: 'is_pinned DESC, modified_at DESC');
    return result.map((map) => NoteModel.fromMap(map)).toList();
  }
  
  Future<NoteModel?> getNote(String id) async {
    final db = await database;
    final result = await db.query(AppConstants.tableNotes, where: 'id = ?', whereArgs: [id]);
    
    if (result.isNotEmpty) {
      return NoteModel.fromMap(result.first);
    }

    return null;
  }

  Future<int> updateNote(NoteModel note) async {
    final db = await database;
    return await db.update(AppConstants.tableNotes, note.toMap(), where: 'id = ?', whereArgs: [note.id]);
  }

  Future<int> deleteNote(String id) async {
    final db = await database;
    return await db.delete(AppConstants.tableNotes, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<NoteModel>> searchNotes(String query) async {
    final db = await database;
    final result = await db.query(AppConstants.tableNotes, where: 'title LIKE ? OR content LIKE ?', whereArgs: ['%$query', '%$query'], orderBy: 'is_pinned DESC, modified_at DESC');
    return result.map((map) => NoteModel.fromMap(map)).toList();
  }

  Future<List<NoteModel>> getNotesByFolder(String folderId) async {
    final db  = await database;
    final result = await db.query(AppConstants.tableNotes, where: 'folder_id = ?', whereArgs: [folderId], orderBy: 'is_pinned DESC, modified_at DESC');
    return result.map((map) => NoteModel.fromMap(map)).toList();
  }

  Future<List<NoteModel>> getFavouriteNotes() async {
    final db = await database;
    final result = await db.query(AppConstants.tableNotes, where: 'is_Favourite = ?', whereArgs: [1], orderBy: 'modified_at DESC');
    return result.map((map) => NoteModel.fromMap(map)).toList();
  }

  Future<String> insertFolder(FolderModel folder) async{
    final db = await database;
    await db.insert(AppConstants.tableFolders, folder.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    return folder.id!;
  }

  Future<List<FolderModel>> getAllFolders() async{
    final db = await database;
    final result = await db.query(AppConstants.tableFolders, orderBy: 'created_at DESC');
    return result.map((map) => FolderModel.fromMap(map)).toList();
  }

  Future<int> updateFolder (FolderModel folder) async {
    final db = await database;
    return await db.update(AppConstants.tableFolders, folder.toMap(), where: 'id = ?', whereArgs: [folder.id]);
  }

  Future<int> deleteFolder(String id) async {
    final db = await database;
    await db.update(AppConstants.tableNotes, {'folder_id': null}, where: 'folder_id = ?', whereArgs: [id]);
    return await db.delete(AppConstants.tableFolders, where: 'id = ?', whereArgs: [id]);
  }

  Future<String> insertTag(TagModel tag) async{
    final db = await database;
    await db.insert(AppConstants.tableTags, tag.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    return tag.id!;
  }

  Future<List<TagModel>> getAlltags() async{
    final db = await database;
    final result = await db.query(AppConstants.tableTags);
    return result.map((map) => TagModel.fromMap(map)).toList();
  }

  Future<int> deleteTag(String id) async {
    final db = await database;
    return await db.delete(AppConstants.tableTags, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}