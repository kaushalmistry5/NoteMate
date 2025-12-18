import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:notes/models/folder_model.dart';
import 'package:notes/providers/note_provider.dart';
import 'package:notes/providers/settings_provider.dart';
import 'package:notes/screens/search_screen.dart';
import 'package:notes/screens/settings_screen.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../widget/note_card.dart';
import 'note_editor_screen.dart';

class HomeScreen extends StatefulWidget{
  HomeScreen({super.key});

  @override
  State<StatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  //selected folder is 7fd1489b-e0e8-42b2-9e1d-1e501d4966b2
  @override
  Widget build(BuildContext context) {
    return Consumer<NoteProvider>(
      builder: (context, noteProvider, _) {
        String title = 'NoteMate';
        if (noteProvider.selectedFolderId != null) {
          print("my folder id is ${noteProvider.selectedFolderId}");
          final folder = noteProvider.folders.firstWhere((f) =>
          f.id == noteProvider.selectedFolderId,
              orElse: () => noteProvider.folders.first
          );
          title = folder.name;
          print("my folder name is ${folder.name}  ${folder.id}");
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(title),
            leading: noteProvider.selectedFolderId != null ? IconButton(
                onPressed: () {
                  noteProvider.setSelectedFolder(null);
                }, icon: Icon(Icons.arrow_back)) : null,
            actions: [
              IconButton(onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => SearchScreen()));
              },
                icon: Icon(Icons.search),
              ),
              Consumer<SettingsProvider>(
                builder: (context, settings, _) {
                  return IconButton(
                    onPressed: () {
                      settings.setViewMode(!settings.isGridView);
                    },
                    icon: Icon(settings.isGridView ? Icons.view_list : Icons
                        .grid_view),
                  );
                },
              ),
              IconButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => SettingsScreen()));
                },
                icon: Icon(Icons.settings_outlined),
              ),
            ],
          ),

          body: _buildBody(),

          floatingActionButton: _selectedIndex == 1 || _selectedIndex == 3 ? null : FloatingActionButton(
            onPressed: () {
              if (_selectedIndex == 2) {
                _showCreateFolderDialog();
              } else {
                Navigator.push(context, MaterialPageRoute(builder: (_) => NoteEditorScreen())).then((_)
                {
                  Provider.of<NoteProvider>(context, listen: false).loadNotes();
                });
              }
            },
            elevation: 0,
            backgroundColor: Theme
                .of(context)
                .brightness == Brightness.dark ? Colors.white : Colors.black87,
            foregroundColor: Theme
                .of(context)
                .brightness == Brightness.dark ? Colors.black87 : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.add, size: 28,),
          ),

          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: Theme
                  .of(context)
                  .scaffoldBackgroundColor,
              border: Border(
                top: BorderSide(
                  color: Theme
                      .of(context)
                      .dividerColor
                      .withValues(alpha: 0.1), width: 1,
                ),
              ),
            ),
            child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildNavItem(
                        icon: Icons.note_rounded,
                        selectedIcon: Icons.note,
                        label: 'Notes',
                        index: 0,
                      ),
                      _buildNavItem(
                        icon: Icons.favorite_border,
                        selectedIcon: Icons.favorite,
                        label: 'Favourites',
                        index: 1,
                      ),
                      _buildNavItem(
                        icon: Icons.folder_outlined,
                        selectedIcon: Icons.folder,
                        label: 'Folders',
                        index: 2,
                      ),
                      _buildNavItem(
                        icon: Icons.schedule_outlined,
                        selectedIcon: Icons.schedule,
                        label: 'Recent',
                        index: 3,
                      ),
                    ],
                  ),
                )),
          ),
        );
      },
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    required int index,
  }) {
    final isSelected = _selectedIndex == index;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
        onTap: () {
          setState(() {
          _selectedIndex = index;
        });
    final noteProvider = Provider.of<NoteProvider>(context, listen: false);
    if (index == 0) {
      noteProvider.setSelectedFolder(null);
    }
  },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              padding: EdgeInsets.all(6),
              child: Icon(
                isSelected ? selectedIcon : icon,
                color: isSelected ? (isDark ? Colors.white : Colors.black87) : (isDark ? Colors.grey[600] : Colors.grey[400]),
                size: 26,
              ),
            ),
            SizedBox(height: 2,),
            AnimatedDefaultTextStyle(
              duration: Duration(milliseconds: 300),
              style: TextStyle(
                color: isSelected ? (isDark ? Colors.white : Colors.black87) : (isDark ? Colors.grey[600] : Colors.grey[400]),
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                letterSpacing: 0.5,
              ),
              child: Text(label),
            ),
            SizedBox(height: 4,),
             AnimatedContainer(
               duration: Duration(milliseconds: 300),
               curve: Curves.easeInOut,
               height: 3,
               width: isSelected ? 24 :0,
               decoration: BoxDecoration(
                 color: isDark ? Colors.white : Colors.black87,
                 borderRadius: BorderRadius.circular(2),
               ),
             )
          ],
        ),
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
        }
        else if(_selectedIndex == 3){
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

  void _showCreateFolderDialog() {
    final controller = TextEditingController();

    showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('New Folder'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'Folder Name',
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
            TextButton(onPressed: () {
              if(controller.text.isNotEmpty){
                print("we are here");

                final folder = FolderModel(
                  id: Uuid().v4(),
                  name: controller.text,
                );
                Provider.of<NoteProvider>(context, listen: false).createFolder(folder);
                Navigator.pop(context);
                //Provider.of<NoteProvider>(context).createFolder(folder);
              }
            },
              child: Text('Create'),
            ),

          ],
        ),
    );
  }
}