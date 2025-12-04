class FolderModel {
  final String? id;
  final String name;
  final int colorIndex;
  final DateTime createdate;

  FolderModel({
    this.id,
    required this.name,
    this.colorIndex = 0,
    DateTime? createdate,
}) : createdate = createdate ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id' : id,
      'name' : name,
      'color_index' : colorIndex,
      'created_at' : createdate.toIso8601String(),
    };
  }

  factory FolderModel.fromMap(Map<String, dynamic> map) {
    return FolderModel(
      id: map['id'],
      name: map['name'],
      colorIndex: map['color_index'] ?? 0,
      createdate: DateTime.parse(map['created_at']),
    );
  }

  FolderModel copyWith({
    String?id,
    String?name,
    int? colorIndex,
    DateTime? createdate,
}){
    return FolderModel(
      id: id ?? this.id,
      name: name ?? this.name,
      colorIndex: colorIndex ?? this.colorIndex,
      createdate: createdate ?? this.createdate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id' : id,
      'name' : name,
      'colorIndex' : colorIndex,
      'createdate' : createdate.toIso8601String(),
    };
  }

  factory FolderModel.fromJson(Map<String, dynamic>json) {
    return FolderModel(
      id: json['id'],
      name: json['name'],
      colorIndex: json['colorIndex'] ?? 0,
      createdate: DateTime.parse(json['createdate']),
    );
  }

}