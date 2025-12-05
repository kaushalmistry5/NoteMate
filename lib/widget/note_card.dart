import 'package:flutter/material.dart';
import 'package:notes/models/note_model.dart';
import 'package:notes/providers/note_provider.dart';
import 'package:notes/theme/app_colors.dart';
import 'package:provider/provider.dart';

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
        // onTap: () {
        //   Navigator.push(context, MaterialPageRoute(builder: (_) => NoteEditorScreen(note: note))).then((_)
        //   {
        //     Provider.of<NoteProvider>(context, listen: false).loadNotes();
        //
        //   });
        // },

        // onLongPress: (){
        //   _showBottomSheet(context);
        // },
        borderRadius: BorderRadius.circular(16),
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

          ],
        ),
      ),
    );
  }
}