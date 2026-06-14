import 'dart:convert';


class Boss {
  final String id;
  final String name;
  final String image;
  final String description;
  final String location;
  final List<String> drops;
  final String healthPoints;

  Boss({
    required this.id,
    required this.name,
    required this.image,
    required this.description,
    required this.location,
    required this.drops,
    required this.healthPoints,
  });

  factory Boss.fromJson(Map<String, dynamic> json) {
    return Boss(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Nieznany Boss',
      image: json['image']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      location: json['location']?.toString() ?? 'Nieznana lokacja',
      drops: (json['drops'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ??
          [],
      healthPoints: json['healthPoints']?.toString() ?? '???',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'description': description,
      'location': location,
      'drops': jsonEncode(drops),
      'healthPoints': healthPoints,
    };
  }

  factory Boss.fromMap(Map<String, dynamic> map) {
    return Boss(
      id: map['id'] as String,
      name: map['name'] as String,
      image: map['image'] as String,
      description: map['description'] as String,
      location: map['location'] as String,
      drops: (jsonDecode(map['drops'] as String) as List<dynamic>)
          .map((e) => e.toString())
          .toList(),
      healthPoints: map['healthPoints'] as String,
    );
  }
}