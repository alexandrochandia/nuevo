class ChurchModel {
  final String id;
  final String name;
  final String description;
  final String address;
  final String city;
  final String country;
  final double latitude;
  final double longitude;
  final String imageUrl;
  final String pastor;
  final List<String> services;
  final String phone;
  final String email;
  final String website;
  final bool isActive;
  final DateTime createdAt;
  final int membersCount;
  final String language;

  ChurchModel({
    required this.id,
    required this.name,
    required this.description,
    required this.address,
    required this.city,
    required this.country,
    required this.latitude,
    required this.longitude,
    required this.imageUrl,
    required this.pastor,
    required this.services,
    required this.phone,
    required this.email,
    required this.website,
    required this.isActive,
    required this.createdAt,
    required this.membersCount,
    required this.language,
  });

  factory ChurchModel.fromJson(Map<String, dynamic> json) {
    return ChurchModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      country: json['country'] ?? '',
      latitude: json['latitude']?.toDouble() ?? 0.0,
      longitude: json['longitude']?.toDouble() ?? 0.0,
      imageUrl: json['image_url'] ?? '',
      pastor: json['pastor'] ?? '',
      services: List<String>.from(json['services'] ?? []),
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      website: json['website'] ?? '',
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      membersCount: json['members_count'] ?? 0,
      language: json['language'] ?? 'sv',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'address': address,
      'city': city,
      'country': country,
      'latitude': latitude,
      'longitude': longitude,
      'image_url': imageUrl,
      'pastor': pastor,
      'services': services,
      'phone': phone,
      'email': email,
      'website': website,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'members_count': membersCount,
      'language': language,
    };
  }

  // Datos de prueba para iglesias VMF en Suecia
  static List<ChurchModel> getMockChurches() {
    return [
      ChurchModel(
        id: '1',
        name: 'VMF Stockholm Central',
        description: 'Iglesia central de VMF en el corazón de Estocolmo. Servicios en español y sueco.',
        address: 'Drottninggatan 95, 111 60 Stockholm',
        city: 'Stockholm',
        country: 'Sweden',
        latitude: 59.3293,
        longitude: 18.0686,
        imageUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=800',
        pastor: 'Pastor Carlos Mendoza',
        services: ['Domingo 10:00', 'Domingo 18:00', 'Miércoles 19:00'],
        phone: '+46 8 123 456 78',
        email: 'stockholm@vmfsweden.org',
        website: 'https://stockholm.vmfsweden.org',
        isActive: true,
        createdAt: DateTime.parse('2020-01-15'),
        membersCount: 250,
        language: 'es',
      ),
      ChurchModel(
        id: '2',
        name: 'VMF Göteborg',
        description: 'Comunidad vibrante en Göteborg con ministerios para todas las edades.',
        address: 'Kungsgatan 12, 411 19 Göteborg',
        city: 'Göteborg',
        country: 'Sweden',
        latitude: 57.7089,
        longitude: 11.9746,
        imageUrl: 'https://images.unsplash.com/photo-1519491050282-cf00c82424b4?w=800',
        pastor: 'Pastor María Andersson',
        services: ['Domingo 11:00', 'Jueves 19:30'],
        phone: '+46 31 234 567 89',
        email: 'goteborg@vmfsweden.org',
        website: 'https://goteborg.vmfsweden.org',
        isActive: true,
        createdAt: DateTime.parse('2019-03-20'),
        membersCount: 180,
        language: 'sv',
      ),
      ChurchModel(
        id: '3',
        name: 'VMF Malmö',
        description: 'Iglesia multicultural en el sur de Suecia, conectando comunidades.',
        address: 'Södergatan 24, 211 34 Malmö',
        city: 'Malmö',
        country: 'Sweden',
        latitude: 55.6059,
        longitude: 13.0007,
        imageUrl: 'https://images.unsplash.com/photo-1520637836862-4d197d17c35a?w=800',
        pastor: 'Pastor Diego Fernández',
        services: ['Domingo 10:30', 'Martes 19:00'],
        phone: '+46 40 345 678 90',
        email: 'malmo@vmfsweden.org',
        website: 'https://malmo.vmfsweden.org',
        isActive: true,
        createdAt: DateTime.parse('2021-06-10'),
        membersCount: 120,
        language: 'es',
      ),
      ChurchModel(
        id: '4',
        name: 'VMF Uppsala',
        description: 'Iglesia universitaria que alcanza estudiantes y familias jóvenes.',
        address: 'Sankt Eriks Gränd 7, 753 10 Uppsala',
        city: 'Uppsala',
        country: 'Sweden',
        latitude: 59.8586,
        longitude: 17.6389,
        imageUrl: 'https://images.unsplash.com/photo-1515542622106-78bda8ba0e5b?w=800',
        pastor: 'Pastor Anna Lindqvist',
        services: ['Domingo 14:00', 'Viernes 18:00'],
        phone: '+46 18 456 789 01',
        email: 'uppsala@vmfsweden.org',
        website: 'https://uppsala.vmfsweden.org',
        isActive: true,
        createdAt: DateTime.parse('2022-01-25'),
        membersCount: 95,
        language: 'sv',
      ),
      ChurchModel(
        id: '5',
        name: 'VMF Västerås',
        description: 'Comunidad acogedora enfocada en la familia y el crecimiento espiritual.',
        address: 'Kopparbergsvägen 8, 722 13 Västerås',
        city: 'Västerås',
        country: 'Sweden',
        latitude: 59.6162,
        longitude: 16.5528,
        imageUrl: 'https://images.unsplash.com/photo-1438232992991-995b7058bbb3?w=800',
        pastor: 'Pastor Roberto Silva',
        services: ['Domingo 11:30', 'Miércoles 18:30'],
        phone: '+46 21 567 890 12',
        email: 'vasteras@vmfsweden.org',
        website: 'https://vasteras.vmfsweden.org',
        isActive: true,
        createdAt: DateTime.parse('2020-09-05'),
        membersCount: 140,
        language: 'es',
      ),
    ];
  }
}