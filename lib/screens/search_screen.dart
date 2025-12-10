import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:notes/providers/note_provider.dart';
import 'package:notes/widget/note_card.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';

class SearchScreen extends StatefulWidget{
  SearchScreen({super.key});

  @override
  State<StatefulWidget> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: (){
              Navigator.pop(context);
              Provider.of<NoteProvider>(context, listen: false).clearSearch();
            },
            icon: Icon(Icons.arrow_back),
        ),
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Search notes...',
            border: InputBorder.none,
          ),
          onChanged: (query) {
            Provider.of<NoteProvider>(context, listen: false).setSearchQuery(query);
          },
        ),
        actions: [
          if(_searchController.text.isNotEmpty)
            IconButton(
                onPressed: (){
                  _searchController.clear();
                  Provider.of<NoteProvider>(context, listen: false).clearSearch();
                },
                icon: Icon(Icons.clear),
            ),
        ],
      ),

      body: Consumer<NoteProvider>(
        builder: (context, noteProvider, _){
          final notes = noteProvider.notes;

          if(_searchController.text.isEmpty){
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search, size: 80, color: Colors.grey,),
                  SizedBox(height: 16,),
                  Text(
                    'Search your notes',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          if (notes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 20, color:Colors.grey,),
                  SizedBox(height: 16,),
                  Text(
                    'No data found',
                    style: TextStyle(
                      fontSize: 18, color: Colors.grey
                    ),
                  )
                ],
              ),
            );
          }
          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: notes.length,
            itemBuilder: (context, index){
              return Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: NoteCard(note: notes[index]),
              );
            },
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}