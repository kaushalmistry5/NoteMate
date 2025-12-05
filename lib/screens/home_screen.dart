import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:notes/models/folder_model.dart';
import 'package:notes/providers/note_provider.dart';
import 'package:notes/providers/settings_provider.dart';
import 'package:provider/provider.dart';

import '../widget/note_card.dart';

class HomeScreen extends StatefulWidget{
  HomeScreen({super.key});

  @override
  State<StatefulWidget> createState() => _HomeScreenState();

}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Consumer<NoteProvider>(
      builder: (context, noteProvider, _) {
        String title = 'NoteMate';
        if (noteProvider.selectedFolderId != null){
          final folder = noteProvider.folders.firstWhere((f) => f.id == noteProvider.selectedFolderId,
          orElse: () => noteProvider.folders.first
          );
          title = folder.name;
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(title),
            leading: noteProvider.selectedFolderId != null ? IconButton(onPressed: () {
              noteProvider.setSelectedFolder(null);
            }, icon: Icon(Icons.arrow_back)) : null,
            actions: [
              IconButton(onPressed: () {
                //Navigator.push(context, MaterialPageRoute(builder: (_) => SearchScreen()));
              },
          icon: Icon(Icons.search),
              ),
              Consumer<SettingsProvider>(
                builder: (context, settings, _) {
                  return IconButton(
                    onPressed: (){
                    settings.setViewMode(!settings.isGridView);
                  },
                  icon: Icon(settings.isGridView ? Icons.view_list : Icons.grid_view),
                  );
                },
              ),
              IconButton(
                  onPressed: () {
                    //Navigator.push(context, MaterialPageRoute(builder: (_) => SettingsScreen)));
                  },
                icon: Icon(Icons.settings_outlined),
              ),
                ],
              ),
          body: _buildBody(),
          );
      },
    );
  }

  Widget _buildBody() {
    if (_selectedIndex == 2) {
      return _buildFolderList();
    }

    return Consumer2<NoteProvider, SettingsProvider>(
      builder: (context, noteProvider, settings, _){
        if(noteProvider.isLoading) {
          return Center(child: CircularProgressIndicator(),);
        }
        var notes = noteProvider.notes;

        if(_selectedIndex == 1){
          notes = notes.where((note) => note.isFavourite).toList();
        } else if(_selectedIndex == 3){
          notes.sort((a,b) => b.modifiedAt.compareTo(a.modifiedAt));
          notes = notes.take(20).toList();
        }

        if(notes.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.note_add_outlined, size: 100, color: Colors.grey[400],),
                SizedBox(height: 16,),
                Text(
                  'No notes yet',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 8,),
                Text(
                  'Tap the + button to create your first note',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[500],
                  ),
                )
              ],
            ),
          );
        }
        return settings.isGridView ? _buildGridView(notes) : _buildListView(notes);
      },
    );
  }
  Widget _buildGridView(List notes) {
    return AnimationLimiter(
        child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.85,
            ),
            padding: EdgeInsets.all(16),
            itemCount: notes.length,
            itemBuilder: (context, index){
              return AnimationConfiguration.staggeredGrid(
                  position: index,
                  duration: Duration(microseconds: 375),
                columnCount: 2,
                child: ScaleAnimation(
                    child: FadeInAnimation(
                        child: NoteCard(note: notes[index]),
                    ),
                ),
              );
            },
        ),

    );
  }

  Widget _buildListView(List notes){
    return AnimationLimiter(
        child: ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: notes.length,
          itemBuilder: (context, index){
            return AnimationConfiguration.staggeredList(
                position: index,
              duration: Duration(milliseconds: 375),
              child: SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(
                    child: Padding(
                        padding: EdgeInsets.only(bottom: 12),
                        child: NoteCard(note: notes[index]),
                    )
                ),
              ),

            );
          },
        ),
    );
  }

  Widget _buildFolderList(){
    return Consumer<NoteProvider>(
      builder: (context, noteProvider, _){
        final folders = noteProvider.folders;

        if(folders.isEmpty){
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.folder_outlined,
                  size: 100,
                  color: Colors.grey[400],
                ),

                SizedBox(height: 16,),
                Text(
                  'No Folders Created Yet',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 8,),
                Text(
                  'Click on the + button to create new folder',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[500],
                  ),
                )
              ],
            ),
          );
        }
        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: folders.length,
          itemBuilder: (context, index){
            final folder = folders[index];
            final noteCount = noteProvider.notes.where((note) => note.folderId == folder.id).length;
            
            return Card(
              margin: EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: Icon(Icons.folder, size: 32,),
                title: Text(folder.name),
                subtitle: Text('$noteCount notes'),
                trailing: PopupMenuButton(
                  itemBuilder: (context) =>[
                    PopupMenuItem(
                      value: 'rename',
                      child: Row(
                        children: [
                          Icon(Icons.edit),
                          SizedBox(width: 12,),
                          Text('Rename'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red,),
                          SizedBox(width: 12,),
                          Text('Delete'),
                        ],
                      ),
                    ),
                  ],

                  onSelected: (value) {
                    if (value == 'rename') {
                      _showRenameFolderDialog(noteProvider, folder);
                    }
                    else if (value == 'delete') {
                      _showDeleteFolderDialog(noteProvider, folder);
                    }
                  },
                ),

                  onTap:(){
                  noteProvider.setSelectedFolder(folder.id);
                  setState(() {
                  _selectedIndex = 0;
                      });
                    },
                ),
             );
          },
        );
      },
    );
  }

  void _showRenameFolderDialog(NoteProvider provider, FolderModel folder){
    final controller = TextEditingController(text: folder.name);

    showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Rename Folder'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'Folder Name',
            ),
            autofocus: true,
          ),
          
          actions: [
            TextButton(
                onPressed: (){
                  Navigator.pop(context);
                },
                child: Text('Cancel'),
            ),
            TextButton(
                onPressed: () {
                  if(controller.text.isNotEmpty) {
                    provider.updateFolder(folder.copyWith(name: controller.text));
                  }
                  Navigator.of(context);
                },
                child: Text('Rename'),
            ),
          ],
        )
    );
  }

  void _showDeleteFolderDialog(NoteProvider provider, FolderModel folder){
     showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Delete Folder'),
          content: Text('Are you sure to delete this folder? Notes inside this folder won\'t be deleted'),

          actions: [
            TextButton(
              onPressed: (){
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                provider.deleteFolder(folder.id!);
                Navigator.of(context);
              },
              child: Text('Delete', style: TextStyle(color: Colors.red),),
            ),
          ],
        ),
    );
  }
}