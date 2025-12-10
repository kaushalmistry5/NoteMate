import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:notes/models/note_model.dart';
import 'package:notes/providers/note_provider.dart';
import 'package:notes/theme/app_colors.dart';
import 'package:provider/provider.dart';

import '../screens/note_editor_screen.dart';

class NoteCard extends StatelessWidget{
  final NoteModel note;

  const NoteCard({super.key, required this.note});

  @override
  Widget build (BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final noteColor = isDark ? AppColors.noteColorsDark[note.colorIndex] : AppColors.noteColors[note.colorIndex];
    
    return Card(
      color: noteColor,
      child: InkWell(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => NoteEditorScreen(note: note))).then((_)
          {
            Provider.of<NoteProvider>(context, listen: false).loadNotes();
          });
        },

        onLongPress: (){
          _showBottomSheet(context);
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(
                      note.title.isNotEmpty ? "Untitled" : note.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    )),
                    if(note.isPinned)
                      Icon(Icons.push_pin, size: 20, color: Colors.grey,),
                    if(note.isFavourite)
                      Icon(Icons.favorite, size: 20, color: Colors.red,),
                  ],
                ),
                if (note.content.isNotEmpty) ...[
                  SizedBox(height: 8,),
                  Text(
                    note.content,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 5,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if(note.tags.isNotEmpty) ...[
                  SizedBox(height: 12,),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: note.tags.take(3)
                        .map((tag) => Chip(
                      label: Text(tag, style: TextStyle(fontSize: 11),),
                    )).toList(),
                  )
                ],
                SizedBox(height: 12,),
                Text(
                  DateFormat('MM DD, YYYY" hh:mm a').format(note.modifiedAt),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: _getTextColorForBackground(noteColor),
                  ),
                )
              ],
            ),
        ),
      ),
    );
  }

  Color _getTextColorForBackground(Color backgroundColor){
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black54 : Colors.white70;
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (context){
          return SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: Icon(note.isPinned ? Icons.push_pin_outlined : Icons.push_pin),
                    title: Text(note.isPinned ? 'Unpin' : 'Pin'),
                    onTap: () {
                      Provider.of<NoteProvider>(context, listen: false).togglePinNote(note.id!);
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    leading: Icon(note.isFavourite ? Icons.favorite : Icons.favorite_border),
                    title: Text(note.isPinned ? 'Remove from favourite' : 'Add to favourite'),
                    onTap: () {
                      Provider.of<NoteProvider>(context, listen: false).toggleFavouriteNote(note.id!);
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.delete, color: Colors.red,),
                    onTap: () {
                      Navigator.pop(context);
                      _showBottomSheet(context);
                    },
                  )
                ],
              ));
        }
    );
  }
  
  void _showDeleteDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Delete Note?'),
          content: Text('Are you sure to delete this note?'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context), child: Text('Cancel')),
            TextButton(
                onPressed: (){
                  Provider.of<NoteProvider>(context, listen: false).deleteNote(note.id!);
                  Navigator.pop(context);
                },
              child: Text('Delete', style: TextStyle(color: Colors.red),),
            )
          ],
        )
    );
  }
}