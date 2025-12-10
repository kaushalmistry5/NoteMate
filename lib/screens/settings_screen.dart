import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:notes/models/note_model.dart';
import 'package:notes/providers/note_provider.dart';
import 'package:notes/providers/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class SettingsScreen extends StatelessWidget{
  SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: ListView(
        children: [
          _SectionHeader(title: 'Appearance'),
          Consumer<ThemeProvider> (
            builder: (context, themeProvider, _){
              return ListTile(
                leading: Icon(Icons.brightness_6),
                title: Text('Theme'),
                subtitle: Text(_getThemeModeText(themeProvider.themeMode)),
                onTap: () => _showThemeDialog(context, themeProvider),
              );
            },
          ),
          Divider(),
          _SectionHeader(title: 'Data'),
          ListTile(
            leading: Icon(Icons.file_upload),
            title: Text('Export Notes'),
            subtitle: Text('Export all notes as JSON file'),
            onTap: () => _exportNotes(context),
          ),
          ListTile(
            leading: Icon(Icons.file_download),
            title: Text('Import Notes'),
            subtitle: Text('Import notes from JSON file'),
            onTap: () => _importNotes(context),
          ),
          Divider(),
          _SectionHeader(title: 'About'),
          ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Version'),
            subtitle: Text('1.0.0'),
          ),
        ],
      ),
    );
  }

  String _getThemeModeText(ThemeMode mode){
    switch (mode) {
      case ThemeMode.light:
      return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }

  void _showThemeDialog(BuildContext context, ThemeProvider provider) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Choose Theme'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<ThemeMode>(
                title: Text('Light'),
                value: ThemeMode.light,
                groupValue: provider.themeMode,
                onChanged: (value){
                  provider.setThemeMode(value!);
                  Navigator.pop(context);
                },
              ),
              RadioListTile<ThemeMode>(
                title: Text('Dark'),
                value: ThemeMode.dark,
                groupValue: provider.themeMode,
                onChanged: (value){
                  provider.setThemeMode(value!);
                  Navigator.pop(context);
                },
              ),
              RadioListTile<ThemeMode>(
                title: Text('System'),
                value: ThemeMode.system,
                groupValue: provider.themeMode,
                onChanged: (value){
                  provider.setThemeMode(value!);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        )
    );
  }

  Future<void> _exportNotes(BuildContext context) async{
    final noteProvider = Provider.of<NoteProvider> (context, listen: false);
    final notes = noteProvider.notes;

    if(notes.isEmpty){
      if(context.mounted) {
        showDialog(
            context: context,
            builder: (context) {
              final isDark = Theme.of(context).brightness == Brightness.dark;
              return AlertDialog(
                backgroundColor: isDark ? Color(0xFF1E1E1E) : Color(0xFFF5F5F5),
                icon: Icon(Icons.info_outline, size: 48,),
                content: Text('You don\'t have any notes to export.'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Ok'),
                  ),
                ],
              );
            }
        );
      }
      return;
    }
    if(context.mounted) {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context){
            final isDark = Theme.of(context).brightness == Brightness.dark;
            return AlertDialog(
              backgroundColor: isDark ? Color(0xFF1E1E1E) : Color(0xFFF5F5F5),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16,),
                  Text('Exporting ${notes.length} notes${notes.length > 1 ? 's' : ''}...'),
                ],
              ),
            );
          }
      );
    }


    try{
      final jsonData = jsonEncode({
        'notes': notes.map((notes) => notes.toJson()).toList(),
        'exportDate' : DateTime.now().toIso8601String(),
      });

      final file = File('${Directory.systemTemp.path}/notes_export_${DateTime.now().millisecondsSinceEpoch}.json');
      await file.writeAsString(jsonData);

      if(context.mounted) {
        Navigator.pop(context);
      }

      await Share.shareXFiles([XFile(file.path)], subject: 'Notes Export');

      if(context.mounted){
        showDialog(
            context: context,
            builder: (context){
              final isDark = Theme.of(context).brightness == Brightness.dark;

              return AlertDialog(
                backgroundColor: isDark ? Color(0xFF1E1E1E) : Color(0xFFF5F5F5),
                icon: Icon(Icons.check_circle_outline, color: Colors.green, size: 48,),
                title: Text('Notes Exported Successfully!'),
                content: Text('${notes.length} note${notes.length > 1 ? 's' : ''} exported successfully!'),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context), child: Text('OK')),
                ],
              );
            }
        );
      }
    }catch(e){
      if (context.mounted){
        Navigator.pop(context);
        showDialog(
            context: context,
            builder: (context) {
              final isDark = Theme.of(context).brightness == Brightness.dark;
              return AlertDialog(
                backgroundColor: isDark ? Color(0xFF1E1E1E) : Color(0xFFF5F5F5),
                icon: Icon(Icons.error_outline, color: Colors.red, size: 48,),
                title: Text('Export Failed'),
                content: Text('Failed to export notes: $e'),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context), child: Text('OK')),
                ],
              );
            }
        );
      }
    }
  }

  Future<void> _importNotes(BuildContext context) async{
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json']
    );

    if(result == null){
      return;
    }

    if(context.mounted) {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            return AlertDialog(
              backgroundColor: isDark ? Color(0xFF1E1E1E) : Color(0xFFF5F5F5),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16,),
                  Text('Importing notes...'),
                ],
              ),
            );
          }
      );
    }
    try{
      final file = File(result.files.single.path!);
      final jsonData = await file.readAsString();
      final data = jsonDecode(jsonData);
      
      final noteProvider = Provider.of<NoteProvider>(context, listen: false);
      int importedCount = 0;
      
      if(data['notes'] != null){
        for(var noteJson in data['notes']) {
          final note = NoteModel.fromJson(noteJson);
          await noteProvider.createNote(note);
          importedCount++;
        }
        
        if(context.mounted){
          Navigator.pop(context);
          showDialog(
              context: context,
              builder: (context){
                final isDark = Theme.of(context).brightness == Brightness.dark;
                
                return AlertDialog(
                  backgroundColor: isDark ? Color(0xFF1E1E1E) : Color(0xFFF5F5F5),
                  icon: Icon(Icons.check_circle_outline, color: Colors.green, size: 48,),
                  content: Text('${importedCount} notes${importedCount > 1 ? 's' : ''} imported successfully!'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: Text('Ok')),
                  ],
                );
              }
          );
        }
      }else {
       if(context.mounted) {
         Navigator.pop(context);
         showDialog(
             context: context,
             builder: (context){
               final isDark = Theme.of(context).brightness == Brightness.dark;
               return AlertDialog(
                 backgroundColor: isDark ? Color(0xFF1E1E1E) : Color(0xFFF5F5F5),
                 icon: Icon(Icons.warning_outlined, color: Colors.orange, size: 48,),
                 title: Text('Invalid File'),
                 content: Text('The selected file does not contain any notes.'),
                 actions: [
                   TextButton(onPressed: () => Navigator.pop(context), child: Text('Ok')),
                 ],
               );
             }
         );
       }
      }
    }catch(e) {
      if(!context.mounted){
        return;
      }
      showDialog(
          context: context,
          builder: (context){
            final isDark = Theme.of(context).brightness == Brightness.dark;
            return AlertDialog(
              backgroundColor: isDark ? Color(0xFF1E1E1E) : Color(0xFFF5F5F5),
              icon: Icon(Icons.error_outline, color: Colors.red, size: 48,),
              title: Text('Import Failed'),
              content: Text('Failed to import notes: $e'),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: Text('Ok')),
              ],
            );
          }
      );
    }
  }
}

class _SectionHeader extends StatelessWidget{
  final String title;

  _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}