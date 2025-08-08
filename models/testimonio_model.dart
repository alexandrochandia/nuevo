class TestimonioModel {
  String? id;
  String? usuarioNombre;
  String? titulo;
  String? contenido;
  String? imagenUrl;
  String? videoUrl;
  DateTime? fechaCreacion;
  int? vistas;
  int? likes;
  bool? esFavorito;
  TestimonioTipo? tipo;
  String? ubicacion;
  String? ministerio;

  TestimonioModel({
    this.id,
    this.usuarioNombre,
    this.titulo,
    this.contenido,
    this.imagenUrl,
    this.videoUrl,
    this.fechaCreacion,
    this.vistas = 0,
    this.likes = 0,
    this.esFavorito = false,
    this.tipo = TestimonioTipo.texto,
    this.ubicacion,
    this.ministerio,
  });

  factory TestimonioModel.fromJson(Map<String, dynamic> json) {
    return TestimonioModel(
      id: json['id'],
      usuarioNombre: json['usuario_nombre'],
      titulo: json['titulo'],
      contenido: json['contenido'],
      imagenUrl: json['imagen_url'],
      videoUrl: json['video_url'],
      fechaCreacion: json['fecha_creacion'] != null 
          ? DateTime.parse(json['fecha_creacion']) 
          : null,
      vistas: json['vistas'] ?? 0,
      likes: json['likes'] ?? 0,
      esFavorito: json['es_favorito'] ?? false,
      tipo: TestimonioTipo.values.firstWhere(
        (e) => e.toString().split('.').last == json['tipo'],
        orElse: () => TestimonioTipo.texto,
      ),
      ubicacion: json['ubicacion'],
      ministerio: json['ministerio'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'usuario_nombre': usuarioNombre,
      'titulo': titulo,
      'contenido': contenido,
      'imagen_url': imagenUrl,
      'video_url': videoUrl,
      'fecha_creacion': fechaCreacion?.toIso8601String(),
      'vistas': vistas,
      'likes': likes,
      'es_favorito': esFavorito,
      'tipo': tipo?.toString().split('.').last,
      'ubicacion': ubicacion,
      'ministerio': ministerio,
    };
  }
}

enum TestimonioTipo {
  texto,
  imagen,
  video,
  audio,
}

// Datos de ejemplo para testimonios VMF
class TestimoniosData {
  static List<TestimonioModel> testimoniosMuestra = [
    TestimonioModel(
      id: '1',
      usuarioNombre: 'María Andersson',
      titulo: 'Sanidad en mi corazón',
      contenido: 'Dios me sanó de años de depresión y ansiedad. Su amor y la comunidad VMF Sweden me devolvieron la esperanza y la alegría de vivir. ¡Gloria a Dios!',
      tipo: TestimonioTipo.texto,
      fechaCreacion: DateTime.now().subtract(const Duration(days: 2)),
      vistas: 156,
      likes: 42,
      ubicacion: 'Estocolmo, Suecia',
      ministerio: 'Ministerio de Sanidad',
    ),
    TestimonioModel(
      id: '2',
      usuarioNombre: 'Erik Larsson',
      titulo: 'Liberación de adicciones',
      contenido: 'Después de 10 años luchando contra las drogas, Jesús me libertó completamente. VMF Sweden me recibió con amor y hoy soy un hombre libre.',
      imagenUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
      tipo: TestimonioTipo.imagen,
      fechaCreacion: DateTime.now().subtract(const Duration(days: 5)),
      vistas: 289,
      likes: 78,
      ubicacion: 'Gotemburgo, Suecia',
      ministerio: 'Ministerio de Liberación',
    ),
    TestimonioModel(
      id: '3',
      usuarioNombre: 'Ingrid Johansson',
      titulo: 'Milagro financiero',
      contenido: 'Cuando perdí mi trabajo, creí que era el fin. Pero Dios proveyó de manera sobrenatural. VMF me enseñó sobre la prosperidad bíblica.',
      videoUrl: 'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_1mb.mp4',
      tipo: TestimonioTipo.video,
      fechaCreacion: DateTime.now().subtract(const Duration(days: 7)),
      vistas: 432,
      likes: 125,
      ubicacion: 'Malmö, Suecia',
      ministerio: 'Ministerio de Prosperidad',
    ),
    TestimonioModel(
      id: '4',
      usuarioNombre: 'Andreas Berg',
      titulo: 'Restauración familiar',
      contenido: 'Mi matrimonio estaba destruido. A través de la oración y el consejo pastoral en VMF, Dios restauró nuestra familia completamente.',
      tipo: TestimonioTipo.texto,
      fechaCreacion: DateTime.now().subtract(const Duration(days: 10)),
      vistas: 198,
      likes: 67,
      ubicacion: 'Uppsala, Suecia',
      ministerio: 'Ministerio Familiar',
    ),
    TestimonioModel(
      id: '5',
      usuarioNombre: 'Astrid Svensson',
      titulo: 'Llamado misionero',
      contenido: 'En VMF descubrí mi propósito. Dios me llamó a las misiones y ahora sirvo llevando el evangelio a naciones no alcanzadas.',
      imagenUrl: 'https://images.unsplash.com/photo-1494790108755-2616c163aa60?w=400',
      tipo: TestimonioTipo.imagen,
      fechaCreacion: DateTime.now().subtract(const Duration(days: 12)),
      vistas: 267,
      likes: 89,
      ubicacion: 'Västerås, Suecia',
      ministerio: 'Ministerio Misionero',
    ),
  ];
}