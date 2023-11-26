class Fact {
  final String title;
  final String image;
  final List<dynamic> paragraphs;

  Fact({
    required this.title,
    required this.image,
    required this.paragraphs,
  });

  factory Fact.fromJson(Map<String, dynamic> json) {
    return Fact(
      title: json['title'],
      image: json['image'],
      paragraphs: List<dynamic>.from(json['paragraphs'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'image': image,
      'paragraphs': paragraphs,
    };
  }
}
