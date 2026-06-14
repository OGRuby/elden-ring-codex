import 'dart:convert';


class StatEntry {
  final String name;
  final String value;

  StatEntry({required this.name, required this.value});

  factory StatEntry.fromJson(Map<String, dynamic> json) {
    final dynamic rawValue = json['amount'] ?? json['scaling'] ?? '-';
    return StatEntry(
      name: json['name']?.toString() ?? '',
      value: rawValue.toString(),
    );
  }

  Map<String, dynamic> toJson() => {'name': name, 'value': value};

  factory StatEntry.fromMap(Map<String, dynamic> map) => StatEntry(
    name: map['name']?.toString() ?? '',
    value: map['value']?.toString() ?? '',
  );
}


List<StatEntry> _statListFromJson(dynamic raw) {
  if (raw == null) return [];
  return (raw as List<dynamic>)
      .map((e) => StatEntry.fromJson(e as Map<String, dynamic>))
      .toList();
}

List<StatEntry> _statListFromEncoded(String encoded) {
  final decoded = jsonDecode(encoded) as List<dynamic>;
  return decoded
      .map((e) => StatEntry.fromMap(e as Map<String, dynamic>))
      .toList();
}

String _statListToEncoded(List<StatEntry> stats) {
  return jsonEncode(stats.map((e) => e.toJson()).toList());
}


class Weapon {
  final String id;
  final String name;
  final String image;
  final String description;
  final String category;
  final double weight;
  final List<StatEntry> attack;
  final List<StatEntry> defence;
  final List<StatEntry> requiredAttributes;
  final List<StatEntry> scalesWith;

  Weapon({
    required this.id,
    required this.name,
    required this.image,
    required this.description,
    required this.category,
    required this.weight,
    required this.attack,
    required this.defence,
    required this.requiredAttributes,
    required this.scalesWith,
  });


  factory Weapon.fromJson(Map<String, dynamic> json) {
    return Weapon(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Nieznana broń',
      image: json['image']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      category: json['category']?.toString() ?? 'Inna',
      weight: (json['weight'] is num)
          ? (json['weight'] as num).toDouble()
          : double.tryParse(json['weight']?.toString() ?? '0') ?? 0.0,
      attack: _statListFromJson(json['attack']),
      defence: _statListFromJson(json['defence']),
      requiredAttributes: _statListFromJson(json['requiredAttributes']),
      scalesWith: _statListFromJson(json['scalesWith']),
    );
  }


  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'description': description,
      'category': category,
      'weight': weight,
      'attack': _statListToEncoded(attack),
      'defence': _statListToEncoded(defence),
      'requiredAttributes': _statListToEncoded(requiredAttributes),
      'scalesWith': _statListToEncoded(scalesWith),
    };
  }


  factory Weapon.fromMap(Map<String, dynamic> map) {
    return Weapon(
      id: map['id'] as String,
      name: map['name'] as String,
      image: map['image'] as String,
      description: map['description'] as String,
      category: map['category'] as String,
      weight: (map['weight'] as num).toDouble(),
      attack: _statListFromEncoded(map['attack'] as String),
      defence: _statListFromEncoded(map['defence'] as String),
      requiredAttributes:
      _statListFromEncoded(map['requiredAttributes'] as String),
      scalesWith: _statListFromEncoded(map['scalesWith'] as String),
    );
  }
}