import 'package:flutter/material.dart';
import 'package:notes/models/folder_model.dart';
import 'package:notes/models/note_model.dart';
import 'package:notes/models/tag_model.dart';
import 'package:notes/repository/note_repository.dart';

class NoteProvider extends ChangeNotifier{
  final NoteRepository repository;

  List<NoteModel> _notes = [];
  List<FolderModel> _folders = [];
  List<TagModel> _tags = [];
  String _searchQuery = '';
  String? _selectedFolderId;
  bool _isLoading = false;

  List<NoteModel> get notes {
    List<NoteModel> filteredNotes = _notes;

    if(_selectedFolderId != null) {
      filteredNotes = filteredNotes.where((note) => note.folderId == _selectedFolderId
      ).toList();
    }

    if(_searchQuery.isNotEmpty){
      filteredNotes = filteredNotes.where((note){
        return note.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        note.content.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    return filteredNotes;
  }

  List<FolderModel> get folders => _folders;
  List<TagModel> get tags => _tags;
  String get searchQuery => _searchQuery;
  String? get selectedFolderId => _selectedFolderId;
  bool get isLoading => _isLoading;

  NoteProvider({required this.repository}) {
    loadNotes();
    loadFolders();
    loadTags();
  }

  Future<void> loadNotes() async{
    _isLoading = true;
    notifyListeners();

    _notes = await repository.getAllNotes();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadFolders() async {
    _folders = await repository.getAllFolders();
    notifyListeners();
  }

  Future<void> loadTags() async{
    _tags = await repository.getAllTags();
    notifyListeners();
  }

  Future<void> createNote(NoteModel note) async{
    await repository.createNote(note);
    await loadNotes();
  }

  Future<void> updateNote(NoteModel note) async{
    await repository.updateNote(note);
    await loadNotes();
  }

  Future<void> deleteNote(String id) async{
    await repository.deleteNote(id);
    await loadNotes();
  }

  Future<void> togglePinNote(String id) async{
    await repository.togglePinNote(id);
    await loadNotes();
  }

  Future<void> toggleFavouriteNote(String id) async{
    await repository.toggleFavouriteNote(id);
    await loadNotes();
  }

  Future<void> createFolder(FolderModel folder) async{
    await repository.createFolder(folder);
    await loadFolders();
  }

  Future<void> updateFolder(FolderModel folder) async{
    await repository.updateFolder(folder);
    await loadFolders();
  }

  Future<void> deleteFolder(String id) async{
    await repository.deleteFolder(id);
    await loadFolders();
    await loadNotes();
  }

  Future<void> createTag(TagModel tag) async{
    await repository.createTag(tag);
    await loadTags();
  }

  Future<void> deleteTag(String id) async{
    await repository.deleteTag(id);
    await loadTags();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSelectedFolder(String? folderId){
    _selectedFolderId = folderId;
    notifyListeners();
  }

  void clearSearch(){
    _searchQuery = '';
    notifyListeners();
  }

  Future<List<NoteModel>> getFavouriteNotes() async{
    return await repository.getFavouriteNotes();
  }
}