import 'dart:math';
import 'dart:ui';

class RandomFact {
  final String factName;
  final Color color;

  RandomFact({required this.factName, required this.color});

  Map<String, dynamic> toJson() {
    return {
      'factName': factName,
      'color': color.value, // Convert Color to int for JSON
    };
  }

  factory RandomFact.fromJson(Map<String, dynamic> json) {
    return RandomFact(
      factName: json['factName'],
      color: Color(json['color']),
    );
  }

  static Color generateRandomColor() {
    return Color((0xFF000000) | Random().nextInt(0xFFFFFF));
  }
}
