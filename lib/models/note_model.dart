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
      'colorIndex': colorIndex,
      'isPinned': isPinned ? 1: 0,
      'isFavourite': isFavourite ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'modifiedAt': modifiedAt.toIso8601String(),
      'attachments': jsonEncode(attachments),
      'contentJson': contentJson,
    };
  }

  factory NoteModel.fromMap(Map<String, dynamic> map) {
    return NoteModel(
      id: map['id'],
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      folderId: map['folder_id'],
      tags: map['tags'] != null ? List<String>.from(jsonDecode(map['tags'])) : [],
      colorIndex: map['colorIndex'] ?? 0,
      isPinned: map['isPinned'] == 1,
      isFavourite: map['is_favourite'] == 1,
      createdAt: DateTime.parse(map['createdAt']),
      modifiedAt: DateTime.parse(map['modifiedAt']),
      attachments: map['attachments'] != null ? List<String>.from(jsonDecode(map['attachments'])) : [],
      contentJson: map['contentJson'],
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
      'folderId': folderId,
      'tags': tags,
      'colorIndex': colorIndex,
      'isPinned': isPinned,
      'isFavourite': isFavourite,
      'createdAt': createdAt,
      'modifiedAt': modifiedAt,
      'attachments': attachments,
      'contentJson': contentJson,
    };
  }

  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      folderId: json['folderId'],
      tags: List<String>.from(json['tags'] ?? []),
      colorIndex: json['colorIndex'] ?? 0,
      isPinned: json['isPinned'] ?? false,
      isFavourite: json['is_favourite'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      modifiedAt: DateTime.parse(json['modifiedAt']),
      attachments: List<String>.from(json['attachments'] ?? []),
      contentJson: json['contentJson'],

    );
  }
}