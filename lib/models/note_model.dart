import 'dart:convert';

class NoteModel {
  final String? id;
  final String title;
  final String content;
  final String? folderId;
  final List<String> tags;
  final int colorIndex;
  final bool isPinned;
  final bool isFavourite;
  final DateTime createdAt;
  final DateTime modifiedAt;
  final List<String> attachments;
  final String? contentJson;

  NoteModel({
    this.id,
    required this.title,
    required this.content,
    this.folderId,
    this.tags = const[],
    this.colorIndex = 0,
    this.isPinned =false,
    this.isFavourite = false,
    DateTime? createdAt,
    DateTime? modifiedAt,
    this.attachments = const [],
    this.contentJson,
}) : createdAt = createdAt ?? DateTime.now(),
  modifiedAt = modifiedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id' : id,
      'title': title,
      'content': content,
      'folder_id': folderId,
      'tags': jsonEncode(tags),
      'color_index': colorIndex,
      'is_pinned': isPinned ? 1: 0,
      'is_favourite': isFavourite ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'modified_at': modifiedAt.toIso8601String(),
      'attachments': jsonEncode(attachments),
      'content_json': contentJson,
    };
  }

  factory NoteModel.fromMap(Map<String, dynamic> map) {
    return NoteModel(
      id: map['id'],
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      folderId: map['folder_id'],
      tags: map['tags'] != null ? List<String>.from(jsonDecode(map['tags'])) : [],
      colorIndex: map['color_index'] ?? 0,
      isPinned: map['is_pinned'] == 1,
      isFavourite: map['is_favourite'] == 1,
      createdAt: DateTime.parse(map['created_at']),
      modifiedAt: DateTime.parse(map['modified_at']),
      attachments: map['attachments'] != null ? List<String>.from(jsonDecode(map['attachments'])) : [],
      contentJson: map['content_json'],
    );
  }

  NoteModel copyWith({
    String? id,
    String? title,
    String? content,
    String? folderId,
    List<String>? tags,
    int? colorIndex,
    bool? isPinned,
    bool? isFavourite,
    DateTime? createdAt,
    DateTime? modifiedAt,
    List<String>? attachments,
    String? contentJson,

}){
    return NoteModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      folderId: folderId ?? this.folderId,
      tags: tags ?? this.tags,
      colorIndex: colorIndex ?? this.colorIndex,
      isPinned: isPinned ?? this.isPinned,
      isFavourite: isFavourite ?? this.isFavourite,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
      attachments: attachments ?? this.attachments,
      contentJson: contentJson ?? this.contentJson,
    );
  }

  Map<String, dynamic> toJson(){
    return {
      'id': id,
      'title': title,
      'content': content,
      'folder_id': folderId,
      'tags': tags,
      'color_index': colorIndex,
      'is_pinned': isPinned,
      'is_favourite': isFavourite,
      'created_at': createdAt,
      'modified_at': modifiedAt,
      'attachments': attachments,
      'content_Json': contentJson,
    };
  }

  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      folderId: json['folder_id'],
      tags: List<String>.from(json['tags'] ?? []),
      colorIndex: json['color_index'] ?? 0,
      isPinned: json['is_pinned'] ?? false,
      isFavourite: json['is_favourite'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      modifiedAt: DateTime.parse(json['modified_at']),
      attachments: List<String>.from(json['attachments'] ?? []),
      contentJson: json['content_json'],

    );
  }
}