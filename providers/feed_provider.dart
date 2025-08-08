import 'package:flutter/material.dart';
import '../models/feed_post_model.dart';

class FeedProvider extends ChangeNotifier {
  List<FeedPost> _posts = [];
  List<FeedComment> _comments = [];
  bool _isLoading = false;
  String _searchQuery = '';
  FeedPostCategory? _selectedCategory;
  FeedPostType? _selectedType;

  List<FeedPost> get posts => _posts;
  List<FeedComment> get comments => _comments;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  FeedPostCategory? get selectedCategory => _selectedCategory;
  FeedPostType? get selectedType => _selectedType;

  List<FeedPost> get filteredPosts {
    List<FeedPost> filtered = List.from(_posts);

    // Filtrar por búsqueda
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((post) =>
          post.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          post.content.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          post.authorName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          post.tags.any((tag) => tag.toLowerCase().contains(_searchQuery.toLowerCase()))
      ).toList();
    }

    // Filtrar por categoría
    if (_selectedCategory != null) {
      filtered = filtered.where((post) => post.category == _selectedCategory).toList();
    }

    // Filtrar por tipo
    if (_selectedType != null) {
      filtered = filtered.where((post) => post.type == _selectedType).toList();
    }

    // Ordenar: posts fijados primero, luego por fecha
    filtered.sort((a, b) {
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;
      return b.createdAt.compareTo(a.createdAt);
    });

    return filtered;
  }

  List<FeedPost> get highlightedPosts {
    return _posts.where((post) => post.isHighlighted).toList();
  }

  FeedProvider() {
    _loadSampleData();
  }

  void _loadSampleData() {
    _isLoading = true;
    notifyListeners();

    // Simulamos carga de datos
    Future.delayed(const Duration(milliseconds: 800), () {
      _posts = _getSamplePosts();
      _comments = _getSampleComments();
      _isLoading = false;
      notifyListeners();
    });
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSelectedCategory(FeedPostCategory? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSelectedType(FeedPostType? type) {
    _selectedType = type;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedCategory = null;
    _selectedType = null;
    notifyListeners();
  }

  void toggleLike(String postId) {
    final index = _posts.indexWhere((post) => post.id == postId);
    if (index != -1) {
      final post = _posts[index];
      _posts[index] = post.copyWith(
        isLiked: !post.isLiked,
        likesCount: post.isLiked ? post.likesCount - 1 : post.likesCount + 1,
      );
      notifyListeners();
    }
  }

  void toggleCommentLike(String commentId) {
    final index = _comments.indexWhere((comment) => comment.id == commentId);
    if (index != -1) {
      final comment = _comments[index];
      _comments[index] = comment.copyWith(
        isLiked: !comment.isLiked,
        likesCount: comment.isLiked ? comment.likesCount - 1 : comment.likesCount + 1,
      );
      notifyListeners();
    }
  }

  void addComment(String postId, String content, String authorName, String authorImage) {
    final newComment = FeedComment(
      id: 'comment_${DateTime.now().millisecondsSinceEpoch}',
      postId: postId,
      content: content,
      authorName: authorName,
      authorImage: authorImage,
      createdAt: DateTime.now(),
    );

    _comments.add(newComment);

    // Incrementar contador de comentarios del post
    final postIndex = _posts.indexWhere((post) => post.id == postId);
    if (postIndex != -1) {
      _posts[postIndex] = _posts[postIndex].copyWith(
        commentsCount: _posts[postIndex].commentsCount + 1,
      );
    }

    notifyListeners();
  }

  List<FeedComment> getCommentsForPost(String postId) {
    return _comments.where((comment) => comment.postId == postId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  void sharePost(String postId) {
    final index = _posts.indexWhere((post) => post.id == postId);
    if (index != -1) {
      _posts[index] = _posts[index].copyWith(
        sharesCount: _posts[index].sharesCount + 1,
      );
      notifyListeners();
    }
  }

  List<FeedPost> _getSamplePosts() {
    return [
      FeedPost(
        id: 'post_1',
        title: 'Bienvenidos al Año Nuevo 2025 - Nuevos Comienzos en Cristo',
        content: 'Querida familia VMF Sweden, mientras iniciamos este nuevo año 2025, recordemos que en Cristo todas las cosas son hechas nuevas. Dios tiene planes de bien para cada uno de nosotros. Este año caminaremos juntos en fe, esperanza y amor. ¡Que la bendición del Señor esté sobre cada familia de nuestra comunidad!',
        authorName: 'Pastor Erik Lindström',
        authorRole: 'Pastor Principal VMF Sweden',
        authorImage: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&h=150&fit=crop&crop=face',
        imageUrl: 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=600&h=400&fit=crop',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        type: FeedPostType.announcement,
        category: FeedPostCategory.general,
        likesCount: 47,
        commentsCount: 12,
        sharesCount: 8,
        isPinned: true,
        isHighlighted: true,
        tags: ['año nuevo', 'bendición', 'nuevos comienzos'],
      ),
      FeedPost(
        id: 'post_2',
        title: 'Reflexión Diaria: "Dios es nuestro refugio y fortaleza"',
        content: 'Salmos 46:1 - "Dios es nuestro refugio y fortaleza, nuestro pronto auxilio en las tribulaciones." En los momentos difíciles, recordemos que no estamos solos. El Señor es nuestro refugio seguro y nuestra fortaleza inquebrantable. Hoy, descansa en Su presencia y permite que Su paz llene tu corazón.',
        authorName: 'Pastora Maria Andersson',
        authorRole: 'Pastora de Oración VMF',
        authorImage: 'https://images.unsplash.com/photo-1494790108755-2616b612b217?w=150&h=150&fit=crop&crop=face',
        imageUrl: 'https://images.unsplash.com/photo-1516450360452-9312f5e86fc7?w=600&h=400&fit=crop',
        createdAt: DateTime.now().subtract(const Duration(hours: 6)),
        type: FeedPostType.reflection,
        category: FeedPostCategory.prayer,
        likesCount: 32,
        commentsCount: 8,
        sharesCount: 15,
        tags: ['reflexión', 'salmos', 'fortaleza'],
      ),
      FeedPost(
        id: 'post_3',
        title: 'Campaña de Oración por Suecia - Unidos en Fe',
        content: 'Iniciamos una campaña especial de oración por nuestra nación Suecia. Durante los próximos 21 días, oraremos juntos por nuestros líderes, por avivamiento espiritual y por que la luz de Cristo brille en cada ciudad sueca. Únete cada día a las 19:00 en nuestra aplicación para orar juntos como familia VMF.',
        authorName: 'Pastor Daniel Johansson',
        authorRole: 'Coordinador de Intercesión',
        authorImage: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150&h=150&fit=crop&crop=face',
        imageUrl: 'https://images.unsplash.com/photo-1477281765962-ef34e8bb0967?w=600&h=400&fit=crop',
        createdAt: DateTime.now().subtract(const Duration(hours: 12)),
        type: FeedPostType.prayer,
        category: FeedPostCategory.prayer,
        likesCount: 38,
        commentsCount: 6,
        sharesCount: 22,
        isPinned: true,
        tags: ['oración', 'suecia', 'campaña', 'intercesión'],
      ),
      FeedPost(
        id: 'post_4',
        title: 'Testimonio Poderoso: De las Drogas a la Libertad en Cristo',
        content: 'Hermanos, quiero compartir el testimonio de nuestro hermano Marcus, quien fue liberado del mundo de las drogas hace 3 años. Hoy es líder de jóvenes y su vida es un testimonio vivo del poder transformador de Jesús. Su historia nos recuerda que no hay adicción que Dios no pueda romper. ¡Gloria a Dios por Su misericordia!',
        authorName: 'Pastor Andreas Nilsson',
        authorRole: 'Pastor de Jóvenes VMF',
        authorImage: 'https://images.unsplash.com/photo-1560250097-0b93528c311a?w=150&h=150&fit=crop&crop=face',
        imageUrl: 'https://images.unsplash.com/photo-1469571486292-0ba58a3f068b?w=600&h=400&fit=crop',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        type: FeedPostType.testimony,
        category: FeedPostCategory.youth,
        likesCount: 89,
        commentsCount: 23,
        sharesCount: 31,
        isHighlighted: true,
        tags: ['testimonio', 'liberación', 'jóvenes', 'transformación'],
      ),
      FeedPost(
        id: 'post_5',
        title: 'Conferencia VMF 2025: "Avivamiento en el Norte" - Estocolmo',
        content: 'Anunciamos oficialmente la Conferencia VMF 2025 "Avivamiento en el Norte" que se realizará del 15-17 de marzo en Estocolmo. Tendremos invitados internacionales, talleres de liderazgo, adoración poderosa y momentos especiales para familias. Las inscripciones tempranas ya están abiertas con descuento especial.',
        authorName: 'Equipo VMF Sweden',
        authorRole: 'Administración VMF',
        authorImage: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=150&h=150&fit=crop&crop=face',
        imageUrl: 'https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=600&h=400&fit=crop',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        type: FeedPostType.event,
        category: FeedPostCategory.community,
        likesCount: 156,
        commentsCount: 45,
        sharesCount: 73,
        isPinned: true,
        isHighlighted: true,
        tags: ['conferencia', 'avivamiento', 'estocolmo', '2025'],
      ),
      FeedPost(
        id: 'post_6',
        title: 'Versículo del Día: Jeremías 29:11',
        content: '"Porque yo sé los pensamientos que tengo acerca de vosotros, dice Jehová, pensamientos de paz, y no de mal, para daros el fin que esperáis." - Jeremías 29:11. Dios tiene un plan perfecto para tu vida. Confía en Su tiempo y en Sus propósitos. Él está preparando algo hermoso para ti.',
        authorName: 'Ministerio de Enseñanza VMF',
        authorRole: 'Equipo Devocional',
        authorImage: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=150&h=150&fit=crop&crop=face',
        imageUrl: 'https://images.unsplash.com/photo-1544027993-37dbfe43562a?w=600&h=400&fit=crop',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        type: FeedPostType.verse,
        category: FeedPostCategory.study,
        likesCount: 67,
        commentsCount: 14,
        sharesCount: 28,
        tags: ['versículo', 'jeremías', 'propósito', 'esperanza'],
      ),
      FeedPost(
        id: 'post_7',
        title: 'Misión Kenia 2025: Llevando Esperanza al África Oriental',
        content: 'Nuestro equipo misionero VMF se prepara para viajar a Kenia en abril 2025. Construiremos una escuela cristiana y llevaremos el evangelio a comunidades rurales. Necesitamos sus oraciones y apoyo financiero. Cada donación marca la diferencia en vidas que nunca han escuchado de Jesús. ¡Seamos parte de esta gran comisión!',
        authorName: 'Pastor Thomas Eriksson',
        authorRole: 'Director de Misiones VMF',
        authorImage: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150&h=150&fit=crop&crop=face',
        imageUrl: 'https://images.unsplash.com/photo-1516026672322-bc52d61a55d5?w=600&h=400&fit=crop',
        createdAt: DateTime.now().subtract(const Duration(days: 4)),
        type: FeedPostType.news,
        category: FeedPostCategory.missions,
        likesCount: 94,
        commentsCount: 19,
        sharesCount: 41,
        tags: ['misión', 'kenia', 'áfrica', 'evangelismo'],
      ),
      FeedPost(
        id: 'post_8',
        title: 'Nuevo Álbum de Adoración VMF Sweden: "Cielos Abiertos"',
        content: 'Con gran alegría anunciamos el lanzamiento de nuestro nuevo álbum "Cielos Abiertos" grabado en vivo durante nuestros cultos de adoración. 12 canciones originales en español y sueco que declaran la gloria de Dios. Disponible en todas las plataformas digitales. ¡Que estas canciones bendigan su tiempo de intimidad con Dios!',
        authorName: 'Ministerio de Adoración VMF',
        authorRole: 'Equipo Musical',
        authorImage: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&h=150&fit=crop&crop=face',
        imageUrl: 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=600&h=400&fit=crop',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        type: FeedPostType.announcement,
        category: FeedPostCategory.worship,
        likesCount: 203,
        commentsCount: 67,
        sharesCount: 89,
        isHighlighted: true,
        tags: ['álbum', 'adoración', 'música', 'cielos abiertos'],
      ),
    ];
  }

  List<FeedComment> _getSampleComments() {
    return [
      FeedComment(
        id: 'comment_1',
        postId: 'post_1',
        content: '¡Amén Pastor Erik! Esperando con ansias lo que Dios tiene preparado este año. Bendiciones para toda la familia VMF.',
        authorName: 'Sofia Petersson',
        authorImage: 'https://images.unsplash.com/photo-1494790108755-2616b612b217?w=150&h=150&fit=crop&crop=face',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        likesCount: 12,
      ),
      FeedComment(
        id: 'comment_2',
        postId: 'post_1',
        content: 'Gracias por este mensaje de esperanza. Dios siempre es fiel en Sus promesas.',
        authorName: 'Carlos Hernández',
        authorImage: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150&h=150&fit=crop&crop=face',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        likesCount: 8,
      ),
      FeedComment(
        id: 'comment_3',
        postId: 'post_4',
        content: 'Qué testimonio tan poderoso. Gloria a Dios por la vida de Marcus. Esto me da esperanza para mi hermano.',
        authorName: 'Ana Lindqvist',
        authorImage: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=150&h=150&fit=crop&crop=face',
        createdAt: DateTime.now().subtract(const Duration(hours: 6)),
        likesCount: 15,
      ),
      FeedComment(
        id: 'comment_4',
        postId: 'post_5',
        content: '¡Ya me inscribí! No puedo esperar a esta conferencia. Va a ser un tiempo poderoso de Dios.',
        authorName: 'Miguel Santos',
        authorImage: 'https://images.unsplash.com/photo-1560250097-0b93528c311a?w=150&h=150&fit=crop&crop=face',
        createdAt: DateTime.now().subtract(const Duration(hours: 8)),
        likesCount: 6,
      ),
    ];
  }
}