import 'package:notes/db/database_helper.dart';
import 'package:notes/models/folder_model.dart';
import 'package:notes/models/note_model.dart';
import 'package:notes/models/tag_model.dart';
import 'package:uuid/uuid.dart';

class NoteRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final Uuid _uuid = const Uuid();

  Future<String> createNote(NoteModel note) async {
    final noteWithId = note.copyWith(
      id: note.id ?? _uuid.v4(),
      modifiedAt: DateTime.now()
    );
    return await _dbHelper.insertNote(noteWithId);
  }

  Future<List<NoteModel>> getAllNotes() async {
    return await _dbHelper.getALLNotes();
  }

  Future<NoteModel?> getNote(String id) async{
    return await _dbHelper.getNote(id);
  }

  Future<void> updateNote(NoteModel note) async{
    final updateNote = note.copyWith(modifiedAt: DateTime.now());
    await _dbHelper.updateNote(updateNote);
  }

  Future<void> deleteNote(String id) async{
    await _dbHelper.deleteNote(id);
  }

  Future<List<NoteModel>> searchNotes(String query) async{
    return await _dbHelper.searchNotes(query);
  }

  Future<List<NoteModel>> getNotesByFolder(String folderId) async{
    return await _dbHelper.getNotesByFolder(folderId);
  }

  Future<List<NoteModel>> getFavouriteNotes() async{
    return await _dbHelper.getFavouriteNotes();
  }

  Future<void> togglePinNote(String id) async{
    final note = await getNote(id);
    if(note != null) {
      await updateNote(note.copyWith(isPinned: !note.isPinned));
    }
  }

  Future<void> toggleFavouriteNote(String id) async {
    final note = await getNote(id);
    if (note != null){
      await updateNote(note.copyWith(isFavourite: !note.isFavourite));
    }
  }

  Future<String> createFolder(FolderModel folder) async {
    final folderWithId = folder.copyWith(id: folder.id ?? _uuid.v4());
    return await _dbHelper.insertFolder(folderWithId);
  }

  Future<List<FolderModel>> getAllFolders() async {
    return await _dbHelper.getAllFolders();
  }

  Future<void> updateFolder(FolderModel folder) async{
    await _dbHelper.updateFolder(folder);
  }

  Future<void> deleteFolder(String id) async {
    await _dbHelper.deleteFolder(id);
  }

  Future<String> createTag(TagModel tag) async {
    final tagWithId = tag.copyWith(id: tag.id ?? _uuid.v4());
    return await _dbHelper.insertTag(tagWithId);
  }

  Future<List<TagModel>> getAllTags() async{
    return await _dbHelper.getAlltags();
  }

  Future<void> deleteTag(String id) async{
    await _dbHelper.deleteTag(id);
  }
}