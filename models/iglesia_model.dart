class IglesiaModel {
  final String id;
  final String nombre;
  final String ciudad;
  final String pais;
  final String direccion;
  final String descripcion;
  final String liderNombre;
  final String liderEmail;
  final String liderTelefono;
  final String liderWhatsapp;
  final String horarioReunion;
  final String diaReunion;
  final String tipoReunion; // 'presencial', 'virtual', 'hibrida'
  final String idioma; // 'español', 'sueco', 'ingles'
  final String imagenUrl;
  final int cantidadMiembros;
  final double latitud;
  final double longitud;
  final String? enlaceZoom;
  final String? sitioWeb;
  final List<String> servicios; // ['culto', 'oracion', 'estudio', 'jovenes']
  final List<String> testimonios;
  final bool esActiva;
  final bool esFavorita;
  final DateTime fechaCreacion;
  final DateTime ultimaReunion;

  IglesiaModel({
    required this.id,
    required this.nombre,
    required this.ciudad,
    required this.pais,
    required this.direccion,
    required this.descripcion,
    required this.liderNombre,
    required this.liderEmail,
    required this.liderTelefono,
    required this.liderWhatsapp,
    required this.horarioReunion,
    required this.diaReunion,
    required this.tipoReunion,
    required this.idioma,
    required this.imagenUrl,
    required this.cantidadMiembros,
    required this.latitud,
    required this.longitud,
    this.enlaceZoom,
    this.sitioWeb,
    required this.servicios,
    required this.testimonios,
    this.esActiva = true,
    this.esFavorita = false,
    required this.fechaCreacion,
    required this.ultimaReunion,
  });

  factory IglesiaModel.fromJson(Map<String, dynamic> json) {
    return IglesiaModel(
      id: json['id'] ?? '',
      nombre: json['nombre'] ?? '',
      ciudad: json['ciudad'] ?? '',
      pais: json['pais'] ?? '',
      direccion: json['direccion'] ?? '',
      descripcion: json['descripcion'] ?? '',
      liderNombre: json['lider_nombre'] ?? '',
      liderEmail: json['lider_email'] ?? '',
      liderTelefono: json['lider_telefono'] ?? '',
      liderWhatsapp: json['lider_whatsapp'] ?? '',
      horarioReunion: json['horario_reunion'] ?? '',
      diaReunion: json['dia_reunion'] ?? '',
      tipoReunion: json['tipo_reunion'] ?? 'presencial',
      idioma: json['idioma'] ?? 'español',
      imagenUrl: json['imagen_url'] ?? '',
      cantidadMiembros: json['cantidad_miembros'] ?? 0,
      latitud: (json['latitud'] ?? 0.0).toDouble(),
      longitud: (json['longitud'] ?? 0.0).toDouble(),
      enlaceZoom: json['enlace_zoom'],
      sitioWeb: json['sitio_web'],
      servicios: List<String>.from(json['servicios'] ?? []),
      testimonios: List<String>.from(json['testimonios'] ?? []),
      esActiva: json['es_activa'] ?? true,
      esFavorita: json['es_favorita'] ?? false,
      fechaCreacion: DateTime.parse(json['fecha_creacion'] ?? DateTime.now().toIso8601String()),
      ultimaReunion: DateTime.parse(json['ultima_reunion'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'ciudad': ciudad,
      'pais': pais,
      'direccion': direccion,
      'descripcion': descripcion,
      'lider_nombre': liderNombre,
      'lider_email': liderEmail,
      'lider_telefono': liderTelefono,
      'lider_whatsapp': liderWhatsapp,
      'horario_reunion': horarioReunion,
      'dia_reunion': diaReunion,
      'tipo_reunion': tipoReunion,
      'idioma': idioma,
      'imagen_url': imagenUrl,
      'cantidad_miembros': cantidadMiembros,
      'latitud': latitud,
      'longitud': longitud,
      'enlace_zoom': enlaceZoom,
      'sitio_web': sitioWeb,
      'servicios': servicios,
      'testimonios': testimonios,
      'es_activa': esActiva,
      'es_favorita': esFavorita,
      'fecha_creacion': fechaCreacion.toIso8601String(),
      'ultima_reunion': ultimaReunion.toIso8601String(),
    };
  }

  IglesiaModel copyWith({
    String? id,
    String? nombre,
    String? ciudad,
    String? pais,
    String? direccion,
    String? descripcion,
    String? liderNombre,
    String? liderEmail,
    String? liderTelefono,
    String? liderWhatsapp,
    String? horarioReunion,
    String? diaReunion,
    String? tipoReunion,
    String? idioma,
    String? imagenUrl,
    int? cantidadMiembros,
    double? latitud,
    double? longitud,
    String? enlaceZoom,
    String? sitioWeb,
    List<String>? servicios,
    List<String>? testimonios,
    bool? esActiva,
    bool? esFavorita,
    DateTime? fechaCreacion,
    DateTime? ultimaReunion,
  }) {
    return IglesiaModel(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      ciudad: ciudad ?? this.ciudad,
      pais: pais ?? this.pais,
      direccion: direccion ?? this.direccion,
      descripcion: descripcion ?? this.descripcion,
      liderNombre: liderNombre ?? this.liderNombre,
      liderEmail: liderEmail ?? this.liderEmail,
      liderTelefono: liderTelefono ?? this.liderTelefono,
      liderWhatsapp: liderWhatsapp ?? this.liderWhatsapp,
      horarioReunion: horarioReunion ?? this.horarioReunion,
      diaReunion: diaReunion ?? this.diaReunion,
      tipoReunion: tipoReunion ?? this.tipoReunion,
      idioma: idioma ?? this.idioma,
      imagenUrl: imagenUrl ?? this.imagenUrl,
      cantidadMiembros: cantidadMiembros ?? this.cantidadMiembros,
      latitud: latitud ?? this.latitud,
      longitud: longitud ?? this.longitud,
      enlaceZoom: enlaceZoom ?? this.enlaceZoom,
      sitioWeb: sitioWeb ?? this.sitioWeb,
      servicios: servicios ?? this.servicios,
      testimonios: testimonios ?? this.testimonios,
      esActiva: esActiva ?? this.esActiva,
      esFavorita: esFavorita ?? this.esFavorita,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      ultimaReunion: ultimaReunion ?? this.ultimaReunion,
    );
  }

  String get direccionCompleta => '$direccion, $ciudad, $pais';
  
  String get horarioCompleto => '$diaReunion, $horarioReunion';
  
  bool get esVirtual => tipoReunion == 'virtual' || tipoReunion == 'hibrida';
  
  bool get esPresencial => tipoReunion == 'presencial' || tipoReunion == 'hibrida';
  
  String get tipoReunionDisplay {
    switch (tipoReunion) {
      case 'virtual':
        return '💻 Virtual';
      case 'presencial':
        return '🏠 Presencial';
      case 'hibrida':
        return '🔄 Híbrida';
      default:
        return '🏠 Presencial';
    }
  }
  
  String get idiomaDisplay {
    switch (idioma) {
      case 'español':
        return '🇪🇸 Español';
      case 'sueco':
        return '🇸🇪 Svenska';
      case 'ingles':
        return '🇬🇧 English';
      default:
        return '🇪🇸 Español';
    }
  }
}