import 'dart:convert';
import 'dart:ui';

class RandomFact {
  final String factName;
  final Color color;
  final int factNumber;

  RandomFact({
    required this.factName,
    required this.color,
    required this.factNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      'factName': factName,
      'color': color.value,
      'factNumber': factNumber,
    };
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }

  factory RandomFact.fromJson(Map<String, dynamic> json) {
    return RandomFact(
      factName: json['factName'],
      color: Color(json['color']),
      factNumber: json['factNumber'],
    );
  }

  factory RandomFact.fromJsonString(String jsonString) {
    Map<String, dynamic> json = jsonDecode(jsonString);
    return RandomFact.fromJson(json);
  }
}
