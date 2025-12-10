import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:notes/models/note_model.dart';
import 'package:notes/providers/note_provider.dart';
import 'package:notes/theme/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../widget/color_picker.dart';

class NoteEditorScreen extends StatefulWidget{
  final NoteModel? note;

  NoteEditorScreen({super.key, this.note});

  @override
  State<StatefulWidget> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late int _selectedColorIndex;
  late bool _isFavorite;
  String? _selectedFolderId;
  List<String> _tags =[];
  List<String> _attachments = [];
  final _tagsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController = TextEditingController(text: widget.note?.content ?? '');
    _selectedColorIndex = widget.note?.colorIndex ?? 0;
    _isFavorite = widget.note?.isFavourite ?? false;
    _selectedFolderId = widget.note?.folderId;
    _tags = List.from(widget.note?.tags ?? []);
    _attachments = List.from(widget.note?.attachments ?? []);
  }

  @override
  void dispose(){
    _titleController.dispose();
    _contentController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _saveNote() async {
    final noteProvider = Provider.of<NoteProvider>(context, listen: false);

    if(_titleController.text.isNotEmpty || _contentController.text.isNotEmpty || _attachments.isNotEmpty) {
      final note = NoteModel(
        id: widget.note?.id ?? Uuid().v4(),
        title: _titleController.text,
        content: _contentController.text,
        folderId: _selectedFolderId,
        colorIndex: _selectedColorIndex,
        tags: _tags,
        attachments: _attachments,
        isPinned: widget.note?.isPinned ?? false,
        isFavourite: _isFavorite,
        createdAt: widget.note?.createdAt ?? DateTime.now(),
        modifiedAt: DateTime.now()
      );

      if(widget.note == null) {
        await noteProvider.createNote(note);
      } else{
        await noteProvider.updateNote(note);
      }

      if(mounted) {
        Navigator.pop(context);
      }
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);

    if(image != null){
      setState(() {
        _attachments.add(image.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final noteColor = isDark ? AppColors.noteColorsDark[_selectedColorIndex] : AppColors.noteColors[_selectedColorIndex];
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
              onPressed: () async{
                await _saveNote();
              },
              icon: Icon(Icons.arrow_back),
          ),
          actions: [
            GestureDetector(
              onTap: _showColorPicker,
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: noteColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
                    width: 2,
                  ),
                ),
              ),
            ),
            IconButton(
                onPressed: () {
                  setState(() {
                    _isFavorite = !_isFavorite;
                  });
                },
                icon: Icon(_isFavorite ? Icons.favorite : Icons.favorite_border, color: _isFavorite ? Colors.red : null,),
            ),
            IconButton(
                onPressed: _pickImage,
                icon: Icon(Icons.image_outlined),
            ),
            IconButton(
                onPressed: (){
                  _showOptionsMenu();
                },
                icon: Icon(Icons.more_vert),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(16),
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      TextField(
      controller: _titleController,
      style: Theme.of(context).textTheme.headlineMedium,
    decoration: InputDecoration(
        hintText: 'Title',
        border: InputBorder.none,
    ),
    textCapitalization: TextCapitalization.sentences,
      ),
    SizedBox(height: 16,),
      if(_tags.isNotEmpty) ...[
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _tags.map((tag){
          return Chip(
              label: Text(tag),
          deleteIcon: Icon(Icons.close, size: 18,),
            onDeleted: (){
                setState(() {
                  _tags.remove(tag);
                });
            },
          );
        }).toList(),
      ),
      SizedBox(height: 16,),
    ],
      if(_attachments.isNotEmpty) ...[
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _attachments.length,
            itemBuilder: (context, index) {
              return Padding(
                  padding: EdgeInsets.only(right: 8),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(_attachments[index]),
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: InkWell(
                        onTap: (){
                          setState(() {
                            _attachments.removeAt(index);
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.close,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              );
            },
          ),
        ),
        SizedBox(height: 16,),
      ],
      TextField(
        controller: _contentController,
        style: Theme.of(context).textTheme.bodyLarge,
        decoration: InputDecoration(
          hintText: 'Start Writing...',
          border: InputBorder.none,
        ),
        maxLines: null,
        textCapitalization: TextCapitalization.sentences,
      )
    ],
    ),
        ),
    );
  }
  void _showColorPicker(){
    showModalBottomSheet(
        context: context,
        builder: (context) => ColorPickerWidget(
          selectedColorIndex: _selectedColorIndex,
          onColorSelected: (index) {
            setState(() {
              _selectedColorIndex =index;
            });
            Navigator.pop(context);
          },
        ),
    );
  }

  void _showOptionsMenu() {
    showModalBottomSheet(
        context: context,
        builder: (context) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.label_outline),
                title: Text('Add Tag'),
                onTap: () {
                  Navigator.pop(context);
                  _showAddTagDialog();
                },
              ),
              ListTile(
                leading: Icon(Icons.folder_outlined),
                title: Text('Move to Folder'),
                onTap: () {
                  Navigator.pop(context);
                  _showFolderSelector();
                },
              ),
            ],
          ),
        )
    );
  }

  void _showAddTagDialog() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Add Tag'),
          content: TextField(
            controller: _tagsController,
            decoration: InputDecoration(
              hintText: 'Enter Tag Name',
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
            ),
            TextButton(
                onPressed: () {
                  if (_tagsController.text.isNotEmpty) {
                    setState(() {
                      _tags.add(_tagsController.text);
                    });
                    _tagsController.clear();
                  }
                  Navigator.pop(context);
                },
                child: Text('Add'),
            ),
          ],
        ),
    );
  }

  void _showFolderSelector() {
    final noteProvider = Provider.of<NoteProvider>(context,listen: false);
    final folders = noteProvider.folders;

    showModalBottomSheet(
        context: context,
        builder: (context) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                    padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Select Folder',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.note_outlined),
                  title: Text('No Folder'),
                  trailing: _selectedFolderId == null
                    ? Icon(Icons.check, color: Colors.blue,)
                      :null,
                  onTap: (){
                    setState(() {
                      _selectedFolderId = null;
                    });
                    Navigator.pop(context);
                  },
                ),
                Divider(),
                ...folders.map((folders){
                  return ListTile(
                    leading: Icon(Icons.folder),
                    title: Text(folders.name),
                    trailing: _selectedFolderId == folders.id
                      ? Icon(Icons.check, color: Colors.blue,)
                        :null,
                    onTap: () {
                      setState(() {
                        _selectedFolderId = folders.id;
                      });
                      Navigator.pop(context);
                    },
                  );
                })
              ],
            ),
        ),
    );
  }
}