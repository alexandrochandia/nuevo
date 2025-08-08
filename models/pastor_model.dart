class PastorModel {
  final String id;
  final String name;
  final String title;
  final String imageUrl;
  final String phone;
  final String email;
  final String specialty;
  final String description;
  final List<String> languages;
  final bool isActive;

  PastorModel({
    required this.id,
    required this.name,
    required this.title,
    required this.imageUrl,
    required this.phone,
    required this.email,
    required this.specialty,
    required this.description,
    required this.languages,
    this.isActive = true,
  });

  factory PastorModel.fromJson(Map<String, dynamic> json) {
    return PastorModel(
      id: json['id'],
      name: json['name'],
      title: json['title'],
      imageUrl: json['imageUrl'],
      phone: json['phone'],
      email: json['email'],
      specialty: json['specialty'],
      description: json['description'],
      languages: List<String>.from(json['languages']),
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'title': title,
      'imageUrl': imageUrl,
      'phone': phone,
      'email': email,
      'specialty': specialty,
      'description': description,
      'languages': languages,
      'isActive': isActive,
    };
  }
}