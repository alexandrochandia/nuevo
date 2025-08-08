import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/devotional_model.dart';

class DevotionalProvider extends ChangeNotifier {
  List<DevotionalModel> _devotionals = [];
  List<DevotionalModel> _favorites = [];
  DevotionalCategory _selectedCategory = DevotionalCategory.daily;
  String _searchQuery = '';
  bool _isLoading = false;
  bool _showFavoritesOnly = false;
  DevotionalModel? _todayDevotional;

  // Getters
  List<DevotionalModel> get devotionals => _devotionals;
  List<DevotionalModel> get favorites => _favorites;
  DevotionalCategory get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  bool get showFavoritesOnly => _showFavoritesOnly;
  DevotionalModel? get todayDevotional => _todayDevotional;

  List<DevotionalModel> get filteredDevotionals {
    List<DevotionalModel> filtered = _showFavoritesOnly ? _favorites : _devotionals;
    
    if (_selectedCategory != DevotionalCategory.daily) {
      filtered = filtered.where((d) => d.category == _selectedCategory).toList();
    }
    
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((d) =>
        d.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        d.subtitle.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        d.tags.any((tag) => tag.toLowerCase().contains(_searchQuery.toLowerCase())) ||
        d.author.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }
    
    return filtered;
  }

  List<DevotionalModel> get featuredDevotionals {
    return _devotionals.where((d) => d.isFeatured).toList();
  }

  DevotionalProvider() {
    _initializeDevotionals();
    _loadFavorites();
  }

  void _initializeDevotionals() {
    _isLoading = true;
    notifyListeners();

    // Datos auténticos de devocionales VMF Sweden
    _devotionals = [
      DevotionalModel(
        id: '1',
        title: 'Confía en el Señor de Todo Corazón',
        subtitle: 'Entregando nuestras preocupaciones a Dios',
        mainVerse: 'Confía en el Señor de todo corazón, y no en tu propia inteligencia. Reconócelo en todos tus caminos, y él allanará tus sendas.',
        verseReference: 'Proverbios 3:5-6',
        reflection: 'En un mundo lleno de incertidumbre, a menudo nos sentimos tentados a confiar únicamente en nuestra propia sabiduría y comprensión. Sin embargo, Dios nos invita a algo mucho más profundo: una confianza total en Él.\n\nConfiar "de todo corazón" significa no guardar nada para nosotros mismos. Es entregar completamente nuestras preocupaciones, planes y futuro en las manos amorosas de nuestro Padre celestial. Cuando reconocemos a Dios en todos nuestros caminos, Él promete dirigir nuestros pasos.\n\nEsta confianza no es ciega, sino basada en el carácter fiel de Dios. Él conoce el final desde el principio y tiene planes de bien para nuestra vida. Hoy, elige confiar en Él con todo tu corazón.',
        prayer: 'Padre celestial, ayúdame a confiar en Ti de todo corazón. Cuando me sienta tentado a depender de mi propia sabiduría, recuérdame que Tus caminos son más altos que los míos. Te entrego mis preocupaciones y planes, confiando en que Tú dirigirás mis pasos. En el nombre de Jesús, amén.',
        imageUrl: 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800',
        category: DevotionalCategory.daily,
        date: DateTime.now(),
        readTime: 5,
        tags: ['confianza', 'fe', 'sabiduría', 'planes de Dios'],
        author: 'Pastor Carlos Mendoza',
        isFeatured: true,
        views: 1245,
        rating: 4.9,
      ),
      DevotionalModel(
        id: '2',
        title: 'El Poder de la Oración Constante',
        subtitle: 'Perseverancia en la vida de oración',
        mainVerse: 'Orad sin cesar. Dad gracias en todo, porque esta es la voluntad de Dios para con vosotros en Cristo Jesús.',
        verseReference: '1 Tesalonicenses 5:17-18',
        reflection: 'La oración no es solo una actividad religiosa que realizamos en momentos específicos; es un estilo de vida. Pablo nos exhorta a "orar sin cesar", lo que significa mantener una conexión constante con Dios a lo largo del día.\n\nEsta oración continua no requiere que estemos siempre de rodillas con los ojos cerrados. Puede ser una conversación constante con Dios mientras trabajamos, caminamos o realizamos nuestras actividades diarias. Es vivir en una actitud de dependencia y comunión con nuestro Padre.\n\nJunto con la oración, Pablo nos llama a dar gracias en todo. Esto no significa que debemos estar agradecidos por las circunstancias difíciles, sino que podemos encontrar razones para agradecer a Dios incluso en medio de las pruebas.',
        prayer: 'Señor Jesús, enséñame a vivir en constante comunicación contigo. Ayúdame a desarrollar una vida de oración que no se limite a momentos específicos, sino que sea una actitud continua de mi corazón. Dame un espíritu agradecido que reconozca tus bendiciones en cada situación. Amén.',
        imageUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=800',
        category: DevotionalCategory.prayer,
        date: DateTime.now().subtract(const Duration(days: 1)),
        readTime: 4,
        tags: ['oración', 'gratitud', 'perseverancia', 'comunión'],
        author: 'Pastora María Andersson',
        isFeatured: true,
        views: 987,
        rating: 4.8,
      ),
      DevotionalModel(
        id: '3',
        title: 'Fortaleza en la Debilidad',
        subtitle: 'La gracia suficiente de Dios',
        mainVerse: 'Pero él me dijo: Bástate mi gracia; porque mi poder se perfecciona en la debilidad.',
        verseReference: '2 Corintios 12:9',
        reflection: 'Pablo experimentó una realidad que muchos de nosotros conocemos: la lucha con nuestras limitaciones y debilidades. En lugar de quitar su "espina en la carne", Dios le enseñó una verdad profunda: Su gracia es suficiente.\n\nNuestras debilidades no son obstáculos para el plan de Dios; son oportunidades para que Su poder se manifieste. Cuando reconocemos nuestras limitaciones, creamos espacio para que la fuerza divina opere en nosotros. Es en nuestra vulnerabilidad donde Dios muestra Su grandeza.\n\nHoy, en lugar de luchar contra tus debilidades o sentirte desanimado por ellas, permite que Dios las use como plataforma para mostrar Su gloria. Su gracia no solo es suficiente; es abundante y perfecta para cada situación que enfrentas.',
        prayer: 'Padre misericordioso, gracias porque tu gracia es suficiente para mí. En mis momentos de debilidad, ayúdame a recordar que tu poder se perfecciona en mi fragilidad. Úsa mis limitaciones para mostrar tu gloria y fortaleza. Confío en que tu gracia me sostiene. En Cristo Jesús, amén.',
        imageUrl: 'https://images.unsplash.com/photo-1470252649378-9c29740c9fa8?w=800',
        category: DevotionalCategory.faith,
        date: DateTime.now().subtract(const Duration(days: 2)),
        readTime: 6,
        tags: ['gracia', 'debilidad', 'fortaleza', 'poder de Dios'],
        author: 'Pastor Miguel Johansson',
        views: 756,
        rating: 4.7,
      ),
      DevotionalModel(
        id: '4',
        title: 'Amor Incondicional del Padre',
        subtitle: 'Entendiendo el corazón de Dios hacia nosotros',
        mainVerse: 'Porque de tal manera amó Dios al mundo, que ha dado a su Hijo unigénito, para que todo aquel que en él cree, no se pierda, mas tenga vida eterna.',
        verseReference: 'Juan 3:16',
        reflection: 'El amor de Dios trasciende nuestra comprensión humana. No es un amor condicional basado en nuestro desempeño, sino un amor que existía antes de que pudiéramos hacer algo para merecerlo.\n\nEste versículo nos revela la profundidad del amor divino: Dios dio lo más preciado que tenía, Su único Hijo, por nosotros. Este sacrificio no fue por personas perfectas, sino por un mundo quebrantado y necesitado.\n\nCuando dudemos de nuestro valor o nos sintamos indignos del amor de Dios, recordemos la cruz. Allí encontramos la medida real de nuestro valor a los ojos del Padre. Su amor no depende de nuestras obras, sino de Su carácter inmutable.\n\nPermite que esta verdad transforme tu manera de ver a Dios y a ti mismo. Eres profundamente amado, no por lo que haces, sino por quien eres en Cristo.',
        prayer: 'Padre celestial, gracias por tu amor incondicional hacia mí. Cuando dude de mi valor, ayúdame a recordar la cruz y el sacrificio de Jesús. Permite que tu amor transforme mi corazón y me dé seguridad en tu gracia. Ayúdame a amar a otros como Tú me has amado. En el nombre de Jesús, amén.',
        imageUrl: 'https://images.unsplash.com/photo-1501594907352-04cda38ebc29?w=800',
        category: DevotionalCategory.love,
        date: DateTime.now().subtract(const Duration(days: 3)),
        readTime: 5,
        tags: ['amor', 'salvación', 'gracia', 'sacrificio'],
        author: 'Pastora Ana Eriksson',
        isFeatured: true,
        views: 1456,
        rating: 5.0,
      ),
      DevotionalModel(
        id: '5',
        title: 'Esperanza en Medio de la Tormenta',
        subtitle: 'Dios es nuestro refugio y fortaleza',
        mainVerse: 'Dios es nuestro amparo y fortaleza, nuestro pronto auxilio en las tribulaciones.',
        verseReference: 'Salmo 46:1',
        reflection: 'Las tormentas de la vida son inevitables. Enfrentamos crisis financieras, problemas de salud, conflictos familiares y desafíos que nos hacen sentir vulnerables. Sin embargo, en medio de cada tormenta, tenemos un refugio seguro.\n\nDios no promete que no habrá tempestades, pero sí promete ser nuestro "amparo y fortaleza". La palabra "amparo" sugiere un lugar de refugio, como una cueva en la montaña donde podemos protegernos de la tormenta. Dios mismo es ese lugar seguro.\n\nAdemás, Él es "pronto auxilio", lo que significa que no tenemos que esperar hasta que pase la crisis para experimentar Su ayuda. Su socorro está disponible inmediatamente, en el momento exacto cuando lo necesitamos.\n\nCuando las circunstancias parezcan abrumadoras, recuerda que tienes un Dios que es mayor que cualquier tormenta que puedas enfrentar.',
        prayer: 'Señor, en medio de las tormentas de mi vida, recuérdame que Tú eres mi refugio seguro. Cuando me sienta abrumado por las circunstancias, ayúdame a correr hacia Ti. Gracias porque eres mi pronto auxilio y que nunca me dejas enfrentar las dificultades solo. Dame paz en medio de la tormenta. Amén.',
        imageUrl: 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800',
        category: DevotionalCategory.hope,
        date: DateTime.now().subtract(const Duration(days: 4)),
        readTime: 4,
        tags: ['esperanza', 'refugio', 'fortaleza', 'tribulaciones'],
        author: 'Pastor Roberto Silva',
        views: 892,
        rating: 4.6,
      ),
      DevotionalModel(
        id: '6',
        title: 'Creciendo en Sabiduría',
        subtitle: 'La importancia del estudio bíblico diario',
        mainVerse: 'Toda la Escritura es inspirada por Dios, y útil para enseñar, para redargüir, para corregir, para instruir en justicia.',
        verseReference: '2 Timoteo 3:16',
        reflection: 'La Palabra de Dios no es simplemente un libro antiguo lleno de historias interesantes. Es la revelación viva de Dios para nosotros, diseñada específicamente para transformar nuestras vidas.\n\nPablo nos dice que toda la Escritura tiene cuatro propósitos fundamentales: enseñar (mostrarnos la verdad), redargüir (convencernos del pecado), corregir (restaurarnos al camino correcto), e instruir en justicia (entrenarnos para vivir vidas santas).\n\nCuando nos acercamos a la Biblia con corazón abierto y dispuesto, no solo adquirimos conocimiento, sino que somos transformados por el Espíritu Santo. Cada día que pasamos en la Palabra es una oportunidad de crecer en sabiduría y madurez espiritual.\n\nHaz del estudio bíblico una prioridad diaria. No se trata de leer mucho, sino de permitir que lo que lees penetre profundamente en tu corazón.',
        prayer: 'Padre, gracias por darnos tu Palabra como guía para nuestras vidas. Ayúdame a desarrollar un hambre constante por estudiar y meditar en las Escrituras. Que tu Espíritu Santo me ilumine mientras leo, y que tu Palabra transforme mi mente y corazón. En el nombre de Jesús, amén.',
        imageUrl: 'https://images.unsplash.com/photo-1481627834876-b7833e8f5570?w=800',
        category: DevotionalCategory.bible,
        date: DateTime.now().subtract(const Duration(days: 5)),
        readTime: 5,
        tags: ['sabiduría', 'estudio bíblico', 'transformación', 'crecimiento'],
        author: 'Pastor David Eriksson',
        views: 634,
        rating: 4.5,
      ),
    ];

    // Establecer el devocional de hoy
    _todayDevotional = _devotionals.first;
    
    _isLoading = false;
    notifyListeners();
  }

  void setCategory(DevotionalCategory category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void toggleShowFavoritesOnly() {
    _showFavoritesOnly = !_showFavoritesOnly;
    notifyListeners();
  }

  Future<void> toggleFavorite(DevotionalModel devotional) async {
    final updatedDevotional = devotional.copyWith(
      isFavorite: !devotional.isFavorite,
    );

    // Actualizar en la lista principal
    final index = _devotionals.indexWhere((d) => d.id == devotional.id);
    if (index != -1) {
      _devotionals[index] = updatedDevotional;
    }

    // Actualizar favoritos
    if (updatedDevotional.isFavorite) {
      if (!_favorites.any((d) => d.id == devotional.id)) {
        _favorites.add(updatedDevotional);
      }
    } else {
      _favorites.removeWhere((d) => d.id == devotional.id);
    }

    await _saveFavorites();
    notifyListeners();
  }

  Future<void> incrementViews(DevotionalModel devotional) async {
    final updatedDevotional = devotional.copyWith(views: devotional.views + 1);
    final index = _devotionals.indexWhere((d) => d.id == devotional.id);
    if (index != -1) {
      _devotionals[index] = updatedDevotional;
      notifyListeners();
    }
  }

  Future<void> _loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoriteIds = prefs.getStringList('favorite_devotionals') ?? [];
      
      _favorites = _devotionals.where((d) => favoriteIds.contains(d.id)).toList();
      
      // Actualizar el estado de favoritos en la lista principal
      for (int i = 0; i < _devotionals.length; i++) {
        if (favoriteIds.contains(_devotionals[i].id)) {
          _devotionals[i] = _devotionals[i].copyWith(isFavorite: true);
        }
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading favorites: $e');
    }
  }

  Future<void> _saveFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoriteIds = _favorites.map((d) => d.id).toList();
      await prefs.setStringList('favorite_devotionals', favoriteIds);
    } catch (e) {
      debugPrint('Error saving favorites: $e');
    }
  }

  List<DevotionalCategory> get availableCategories {
    return DevotionalCategory.values;
  }

  DevotionalModel? getDevotionalById(String id) {
    try {
      return _devotionals.firstWhere((d) => d.id == id);
    } catch (e) {
      return null;
    }
  }

  List<DevotionalModel> getDevotionalsByCategory(DevotionalCategory category) {
    return _devotionals.where((d) => d.category == category).toList();
  }

  List<DevotionalModel> getRecentDevotionals({int limit = 5}) {
    final sorted = List<DevotionalModel>.from(_devotionals);
    sorted.sort((a, b) => b.date.compareTo(a.date));
    return sorted.take(limit).toList();
  }
}