class TagModel {

  final String? id;
  final String name;
  final int colorIndex;

  TagModel({
    this.id,
    required this.name,
    this.colorIndex = 0,
});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'colorIndex': colorIndex,
    };
  }

  factory TagModel.fromMap(Map<String, dynamic> map){
    return TagModel(
      id: map['id'],
      name: map['name'],
      colorIndex: map['colorIndex'] ?? 0,
    );
  }

  TagModel copyWith({
    String? id,
    String? name,
    int? colorIndex,
}){
    return TagModel(
      id: id ?? this.id,
      name: name ?? this.name,
      colorIndex: colorIndex ?? this.colorIndex,
    );
  }

  Map<String, dynamic> toJson() {
    return{
      'id': id,
      'name': name,
      'colorIndex': colorIndex,
    };
  }

  factory TagModel.fromJson(Map<String, dynamic> json) {
    return TagModel(
      id: json['id'],
      name: json['name'],
      colorIndex: json['colorIndex'] ?? 0,
    );
  }

}