import 'package:flutter/material.dart';

enum ProductType {
  book,
  music,
  study,
  devotional,
  children,
  youth,
  clothing,
  accessory,
  digital,
  course
}

enum ProductCategory {
  devocionales,
  musica,
  estudio_biblico,
  literatura_cristiana,
  ninos,
  juventud,
  matrimonio,
  liderazgo,
  oracion,
  ministerio,
  ropa_vmf,
  accesorios,
  cursos_digitales,
  recursos_pastorales
}

class VMFProduct {
  final String id;
  final String name;
  final String description;
  final String shortDescription;
  final double price;
  final double? regularPrice;
  final double? salePrice;
  final String currency;
  final List<String> images;
  final String? featuredImage;
  final ProductType type;
  final ProductCategory category;
  final bool inStock;
  final int stockQuantity;
  final bool isDigital;
  final bool isFeatured;
  final bool onSale;
  final double rating;
  final int reviewCount;
  final int salesCount;
  final String? author;
  final String? artist;
  final String? publisher;
  final DateTime? releaseDate;
  final List<String> tags;
  final Map<String, dynamic> metadata;
  final String? downloadUrl;
  final List<VMFProductVariation>? variations;
  final DateTime createdAt;
  final DateTime updatedAt;

  VMFProduct({
    required this.id,
    required this.name,
    required this.description,
    required this.shortDescription,
    required this.price,
    this.regularPrice,
    this.salePrice,
    this.currency = 'SEK',
    this.images = const [],
    this.featuredImage,
    required this.type,
    required this.category,
    this.inStock = true,
    this.stockQuantity = 0,
    this.isDigital = false,
    this.isFeatured = false,
    this.onSale = false,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.salesCount = 0,
    this.author,
    this.artist,
    this.publisher,
    this.releaseDate,
    this.tags = const [],
    this.metadata = const {},
    this.downloadUrl,
    this.variations,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  // Getters de conveniencia
  bool get hasDiscount => onSale && salePrice != null && salePrice! < price;
  double get finalPrice => onSale && salePrice != null ? salePrice! : price;
  String get formattedPrice => '${finalPrice.toStringAsFixed(0)} SEK';
  String get formattedRegularPrice => regularPrice != null ? '${regularPrice!.toStringAsFixed(0)} SEK' : formattedPrice;
  bool get isBook => type == ProductType.book;
  bool get isMusic => type == ProductType.music;
  bool get isCourse => type == ProductType.course || type == ProductType.digital;

  // Iconos por categoría
  IconData get categoryIcon {
    switch (category) {
      case ProductCategory.devocionales:
        return Icons.auto_stories;
      case ProductCategory.musica:
        return Icons.music_note;
      case ProductCategory.estudio_biblico:
        return Icons.menu_book;
      case ProductCategory.literatura_cristiana:
        return Icons.library_books;
      case ProductCategory.ninos:
        return Icons.child_care;
      case ProductCategory.juventud:
        return Icons.people;
      case ProductCategory.matrimonio:
        return Icons.favorite;
      case ProductCategory.liderazgo:
        return Icons.group_work;
      case ProductCategory.oracion:
        return Icons.handshake;
      case ProductCategory.ministerio:
        return Icons.church;
      case ProductCategory.ropa_vmf:
        return Icons.checkroom;
      case ProductCategory.accesorios:
        return Icons.style;
      case ProductCategory.cursos_digitales:
        return Icons.play_circle;
      case ProductCategory.recursos_pastorales:
        return Icons.school;
    }
  }

  // Colores por categoría
  Color get categoryColor {
    switch (category) {
      case ProductCategory.devocionales:
        return const Color(0xFF6366F1);
      case ProductCategory.musica:
        return const Color(0xFFFFD700);
      case ProductCategory.estudio_biblico:
        return const Color(0xFF10B981);
      case ProductCategory.literatura_cristiana:
        return const Color(0xFF8B5CF6);
      case ProductCategory.ninos:
        return const Color(0xFFF59E0B);
      case ProductCategory.juventud:
        return const Color(0xFFEF4444);
      case ProductCategory.matrimonio:
        return const Color(0xFFEC4899);
      case ProductCategory.liderazgo:
        return const Color(0xFF0EA5E9);
      case ProductCategory.oracion:
        return const Color(0xFF84CC16);
      case ProductCategory.ministerio:
        return const Color(0xFF9333EA);
      case ProductCategory.ropa_vmf:
        return const Color(0xFF06B6D4);
      case ProductCategory.accesorios:
        return const Color(0xFFF97316);
      case ProductCategory.cursos_digitales:
        return const Color(0xFF3B82F6);
      case ProductCategory.recursos_pastorales:
        return const Color(0xFF059669);
    }
  }

  // Método para verificar disponibilidad
  bool get isAvailable {
    if (isDigital) return true;
    return inStock && stockQuantity > 0;
  }

  // Método para obtener badge de estado
  String? get statusBadge {
    if (!isAvailable) return 'Agotado';
    if (isFeatured) return 'Destacado';
    if (onSale) return 'Oferta';
    if (isDigital) return 'Digital';
    return null;
  }

  // Conversión desde JSON
  factory VMFProduct.fromJson(Map<String, dynamic> json) {
    return VMFProduct(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      shortDescription: json['short_description'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      regularPrice: json['regular_price']?.toDouble(),
      salePrice: json['sale_price']?.toDouble(),
      currency: json['currency'] ?? 'SEK',
      images: List<String>.from(json['images'] ?? []),
      featuredImage: json['featured_image'],
      type: ProductType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => ProductType.book,
      ),
      category: ProductCategory.values.firstWhere(
        (e) => e.toString().split('.').last == json['category'],
        orElse: () => ProductCategory.devocionales,
      ),
      inStock: json['in_stock'] ?? true,
      stockQuantity: json['stock_quantity'] ?? 0,
      isDigital: json['is_digital'] ?? false,
      isFeatured: json['is_featured'] ?? false,
      onSale: json['on_sale'] ?? false,
      rating: (json['rating'] ?? 0.0).toDouble(),
      reviewCount: json['review_count'] ?? 0,
      salesCount: json['sales_count'] ?? 0,
      author: json['author'],
      artist: json['artist'],
      publisher: json['publisher'],
      releaseDate: json['release_date'] != null 
        ? DateTime.parse(json['release_date']) 
        : null,
      tags: List<String>.from(json['tags'] ?? []),
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      downloadUrl: json['download_url'],
      variations: json['variations'] != null
        ? (json['variations'] as List)
            .map((v) => VMFProductVariation.fromJson(v))
            .toList()
        : null,
      createdAt: json['created_at'] != null 
        ? DateTime.parse(json['created_at']) 
        : DateTime.now(),
      updatedAt: json['updated_at'] != null 
        ? DateTime.parse(json['updated_at']) 
        : DateTime.now(),
    );
  }

  // Conversión a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'short_description': shortDescription,
      'price': price,
      'regular_price': regularPrice,
      'sale_price': salePrice,
      'currency': currency,
      'images': images,
      'featured_image': featuredImage,
      'type': type.toString().split('.').last,
      'category': category.toString().split('.').last,
      'in_stock': inStock,
      'stock_quantity': stockQuantity,
      'is_digital': isDigital,
      'is_featured': isFeatured,
      'on_sale': onSale,
      'rating': rating,
      'review_count': reviewCount,
      'sales_count': salesCount,
      'author': author,
      'artist': artist,
      'publisher': publisher,
      'release_date': releaseDate?.toIso8601String(),
      'tags': tags,
      'metadata': metadata,
      'download_url': downloadUrl,
      'variations': variations?.map((v) => v.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Método de copia con cambios
  VMFProduct copyWith({
    String? id,
    String? name,
    String? description,
    String? shortDescription,
    double? price,
    double? regularPrice,
    double? salePrice,
    String? currency,
    List<String>? images,
    String? featuredImage,
    ProductType? type,
    ProductCategory? category,
    bool? inStock,
    int? stockQuantity,
    bool? isDigital,
    bool? isFeatured,
    bool? onSale,
    double? rating,
    int? reviewCount,
    int? salesCount,
    String? author,
    String? artist,
    String? publisher,
    DateTime? releaseDate,
    List<String>? tags,
    Map<String, dynamic>? metadata,
    String? downloadUrl,
    List<VMFProductVariation>? variations,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return VMFProduct(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      shortDescription: shortDescription ?? this.shortDescription,
      price: price ?? this.price,
      regularPrice: regularPrice ?? this.regularPrice,
      salePrice: salePrice ?? this.salePrice,
      currency: currency ?? this.currency,
      images: images ?? this.images,
      featuredImage: featuredImage ?? this.featuredImage,
      type: type ?? this.type,
      category: category ?? this.category,
      inStock: inStock ?? this.inStock,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      isDigital: isDigital ?? this.isDigital,
      isFeatured: isFeatured ?? this.isFeatured,
      onSale: onSale ?? this.onSale,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      salesCount: salesCount ?? this.salesCount,
      author: author ?? this.author,
      artist: artist ?? this.artist,
      publisher: publisher ?? this.publisher,
      releaseDate: releaseDate ?? this.releaseDate,
      tags: tags ?? this.tags,
      metadata: metadata ?? this.metadata,
      downloadUrl: downloadUrl ?? this.downloadUrl,
      variations: variations ?? this.variations,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class VMFProductVariation {
  final String id;
  final String productId;
  final String name;
  final double price;
  final String? sku;
  final Map<String, String> attributes;
  final bool inStock;
  final int stockQuantity;
  final String? image;

  VMFProductVariation({
    required this.id,
    required this.productId,
    required this.name,
    required this.price,
    this.sku,
    this.attributes = const {},
    this.inStock = true,
    this.stockQuantity = 0,
    this.image,
  });

  factory VMFProductVariation.fromJson(Map<String, dynamic> json) {
    return VMFProductVariation(
      id: json['id'] ?? '',
      productId: json['product_id'] ?? '',
      name: json['name'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      sku: json['sku'],
      attributes: Map<String, String>.from(json['attributes'] ?? {}),
      inStock: json['in_stock'] ?? true,
      stockQuantity: json['stock_quantity'] ?? 0,
      image: json['image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'name': name,
      'price': price,
      'sku': sku,
      'attributes': attributes,
      'in_stock': inStock,
      'stock_quantity': stockQuantity,
      'image': image,
    };
  }
}