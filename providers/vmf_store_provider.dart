import 'package:flutter/foundation.dart';
import '../models/store/vmf_product_model.dart';
import '../models/store/vmf_cart_model.dart';

class VMFStoreProvider extends ChangeNotifier {
  List<VMFProduct> _products = [];
  List<VMFProduct> _featuredProducts = [];
  List<VMFProduct> _filteredProducts = [];
  Map<ProductCategory, List<VMFProduct>> _productsByCategory = {};
  
  // Estados de carga
  bool _isLoading = false;
  bool _isLoadingFeatured = false;
  String? _error;
  
  // Filtros actuales
  ProductCategory? _selectedCategory;
  ProductType? _selectedType;
  String _searchQuery = '';
  double _minPrice = 0;
  double _maxPrice = 10000;
  String _sortBy = 'name'; // name, price, rating, sales
  bool _sortAscending = true;
  bool _onlyInStock = false;
  bool _onlyOnSale = false;

  // Getters
  List<VMFProduct> get products => _filteredProducts;
  List<VMFProduct> get allProducts => List.unmodifiable(_products);
  List<VMFProduct> get featuredProducts => List.unmodifiable(_featuredProducts);
  Map<ProductCategory, List<VMFProduct>> get productsByCategory => Map.unmodifiable(_productsByCategory);
  
  bool get isLoading => _isLoading;
  bool get isLoadingFeatured => _isLoadingFeatured;
  String? get error => _error;
  
  ProductCategory? get selectedCategory => _selectedCategory;
  ProductType? get selectedType => _selectedType;
  String get searchQuery => _searchQuery;
  double get minPrice => _minPrice;
  double get maxPrice => _maxPrice;
  String get sortBy => _sortBy;
  bool get sortAscending => _sortAscending;
  bool get onlyInStock => _onlyInStock;
  bool get onlyOnSale => _onlyOnSale;

  // Estadísticas
  int get totalProducts => _products.length;
  int get featuredCount => _featuredProducts.length;
  int get inStockCount => _products.where((p) => p.isAvailable).length;
  int get onSaleCount => _products.where((p) => p.onSale).length;

  VMFStoreProvider() {
    _loadInitialData();
  }

  // Cargar datos iniciales
  Future<void> _loadInitialData() async {
    await loadProducts();
    await loadFeaturedProducts();
  }

  // Cargar todos los productos
  Future<void> loadProducts() async {
    _setLoading(true);
    _clearError();

    try {
      // Simular datos de productos VMF
      _products = _generateMockProducts();
      _organizeProductsByCategory();
      _applyFilters();
      
      notifyListeners();
    } catch (e) {
      _setError('Error al cargar productos: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Cargar productos destacados
  Future<void> loadFeaturedProducts() async {
    _isLoadingFeatured = true;
    notifyListeners();

    try {
      _featuredProducts = _products.where((p) => p.isFeatured).take(6).toList();
    } catch (e) {
      _setError('Error al cargar productos destacados: $e');
    } finally {
      _isLoadingFeatured = false;
      notifyListeners();
    }
  }

  // Buscar productos
  Future<void> searchProducts(String query) async {
    _searchQuery = query.toLowerCase();
    _applyFilters();
    notifyListeners();
  }

  // Filtrar por categoría
  void filterByCategory(ProductCategory? category) {
    _selectedCategory = category;
    _applyFilters();
    notifyListeners();
  }

  // Filtrar por tipo
  void filterByType(ProductType? type) {
    _selectedType = type;
    _applyFilters();
    notifyListeners();
  }

  // Establecer rango de precios
  void setPriceRange(double min, double max) {
    _minPrice = min;
    _maxPrice = max;
    _applyFilters();
    notifyListeners();
  }

  // Cambiar ordenación
  void setSorting(String sortBy, {bool? ascending}) {
    _sortBy = sortBy;
    if (ascending != null) _sortAscending = ascending;
    _applyFilters();
    notifyListeners();
  }

  // Toggle filtros booleanos
  void toggleInStockFilter() {
    _onlyInStock = !_onlyInStock;
    _applyFilters();
    notifyListeners();
  }

  void toggleOnSaleFilter() {
    _onlyOnSale = !_onlyOnSale;
    _applyFilters();
    notifyListeners();
  }

  // Limpiar todos los filtros
  void clearFilters() {
    _selectedCategory = null;
    _selectedType = null;
    _searchQuery = '';
    _minPrice = 0;
    _maxPrice = 10000;
    _sortBy = 'name';
    _sortAscending = true;
    _onlyInStock = false;
    _onlyOnSale = false;
    _applyFilters();
    notifyListeners();
  }

  // Obtener productos por categoría específica
  List<VMFProduct> getProductsByCategory(ProductCategory category) {
    return _productsByCategory[category] ?? [];
  }

  // Obtener producto por ID
  VMFProduct? getProductById(String productId) {
    try {
      return _products.firstWhere((p) => p.id == productId);
    } catch (e) {
      return null;
    }
  }

  // Obtener productos relacionados
  List<VMFProduct> getRelatedProducts(VMFProduct product, {int limit = 4}) {
    return _products
        .where((p) => 
          p.id != product.id && 
          p.category == product.category &&
          p.isAvailable
        )
        .take(limit)
        .toList();
  }

  // Métodos privados
  void _setLoading(bool loading) {
    _isLoading = loading;
    if (loading) notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  void _organizeProductsByCategory() {
    _productsByCategory.clear();
    for (final category in ProductCategory.values) {
      _productsByCategory[category] = _products
          .where((p) => p.category == category)
          .toList();
    }
  }

  void _applyFilters() {
    var filtered = List<VMFProduct>.from(_products);

    // Filtro por búsqueda
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((p) =>
          p.name.toLowerCase().contains(_searchQuery) ||
          p.description.toLowerCase().contains(_searchQuery) ||
          p.author?.toLowerCase().contains(_searchQuery) == true ||
          p.tags.any((tag) => tag.toLowerCase().contains(_searchQuery))
      ).toList();
    }

    // Filtro por categoría
    if (_selectedCategory != null) {
      filtered = filtered.where((p) => p.category == _selectedCategory).toList();
    }

    // Filtro por tipo
    if (_selectedType != null) {
      filtered = filtered.where((p) => p.type == _selectedType).toList();
    }

    // Filtro por precio
    filtered = filtered.where((p) => 
        p.finalPrice >= _minPrice && p.finalPrice <= _maxPrice
    ).toList();

    // Filtro por disponibilidad
    if (_onlyInStock) {
      filtered = filtered.where((p) => p.isAvailable).toList();
    }

    // Filtro por ofertas
    if (_onlyOnSale) {
      filtered = filtered.where((p) => p.onSale).toList();
    }

    // Ordenación
    filtered.sort((a, b) {
      int comparison = 0;
      switch (_sortBy) {
        case 'price':
          comparison = a.finalPrice.compareTo(b.finalPrice);
          break;
        case 'rating':
          comparison = a.rating.compareTo(b.rating);
          break;
        case 'sales':
          comparison = a.salesCount.compareTo(b.salesCount);
          break;
        case 'date':
          comparison = a.createdAt.compareTo(b.createdAt);
          break;
        default: // name
          comparison = a.name.compareTo(b.name);
      }
      return _sortAscending ? comparison : -comparison;
    });

    _filteredProducts = filtered;
  }

  // Generar productos de prueba
  List<VMFProduct> _generateMockProducts() {
    return [
      // Devocionales
      VMFProduct(
        id: 'dev001',
        name: 'Jesús te Llama: 365 Devocionales',
        description: 'Un devocional diario que te acerca al corazón de Jesús con mensajes de esperanza, paz y amor incondicional. Cada día encontrarás una palabra de aliento directamente de nuestro Salvador.',
        shortDescription: 'Devocional diario con 365 mensajes de esperanza y amor',
        price: 299,
        regularPrice: 349,
        salePrice: 299,
        images: [
          'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=400',
          'https://images.unsplash.com/photo-1481627834876-b7833e8f5570?w=400'
        ],
        featuredImage: 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=400',
        type: ProductType.book,
        category: ProductCategory.devocionales,
        inStock: true,
        stockQuantity: 25,
        isFeatured: true,
        onSale: true,
        rating: 4.8,
        reviewCount: 156,
        salesCount: 89,
        author: 'Sarah Young',
        publisher: 'Grupo Nelson',
        releaseDate: DateTime(2023, 1, 15),
        tags: ['devocional', 'diario', 'jesús', 'esperanza', 'fe'],
      ),

      // Música
      VMFProduct(
        id: 'mus001',
        name: 'Hillsong United - Zion (CD)',
        description: 'El álbum más inspirador de Hillsong United con canciones que elevan el alma y conectan con lo divino. Incluye los éxitos "Oceans" y "Touch the Sky".',
        shortDescription: 'Álbum de adoración con los grandes éxitos de Hillsong United',
        price: 199,
        images: [
          'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=400',
          'https://images.unsplash.com/photo-1514320291840-2e0a9bf2a9ae?w=400'
        ],
        featuredImage: 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=400',
        type: ProductType.music,
        category: ProductCategory.musica,
        inStock: true,
        stockQuantity: 40,
        isFeatured: true,
        rating: 4.9,
        reviewCount: 234,
        salesCount: 156,
        artist: 'Hillsong United',
        publisher: 'Hillsong Music',
        releaseDate: DateTime(2022, 8, 12),
        tags: ['adoración', 'hillsong', 'united', 'música cristiana', 'alabanza'],
      ),

      // Estudio Bíblico
      VMFProduct(
        id: 'est001',
        name: 'Biblia de Estudio Reina Valera 1960',
        description: 'La Biblia de estudio más completa en español con notas explicativas, mapas, concordancia y herramientas de estudio. Ideal para el crecimiento espiritual profundo.',
        shortDescription: 'Biblia de estudio completa con notas y herramientas',
        price: 599,
        regularPrice: 699,
        salePrice: 599,
        images: [
          'https://images.unsplash.com/photo-1504052434569-70ad5836ab65?w=400',
          'https://images.unsplash.com/photo-1481627834876-b7833e8f5570?w=400'
        ],
        featuredImage: 'https://images.unsplash.com/photo-1504052434569-70ad5836ab65?w=400',
        type: ProductType.book,
        category: ProductCategory.estudio_biblico,
        inStock: true,
        stockQuantity: 15,
        isFeatured: true,
        onSale: true,
        rating: 4.7,
        reviewCount: 89,
        salesCount: 67,
        publisher: 'Vida Publishers',
        releaseDate: DateTime(2023, 3, 10),
        tags: ['biblia', 'estudio', 'reina valera', 'notas', 'concordancia'],
      ),

      // Literatura Cristiana
      VMFProduct(
        id: 'lit001',
        name: 'El Propósito de la Vida Dirigida por Dios',
        description: 'Un libro transformador que te ayudará a descubrir el plan de Dios para tu vida. Rick Warren comparte principios bíblicos para vivir con propósito y significado.',
        shortDescription: 'Descubre el propósito de Dios para tu vida',
        price: 249,
        images: [
          'https://images.unsplash.com/photo-1543002588-bfa74002ed7e?w=400',
          'https://images.unsplash.com/photo-1481627834876-b7833e8f5570?w=400'
        ],
        featuredImage: 'https://images.unsplash.com/photo-1543002588-bfa74002ed7e?w=400',
        type: ProductType.book,
        category: ProductCategory.literatura_cristiana,
        inStock: true,
        stockQuantity: 30,
        rating: 4.6,
        reviewCount: 145,
        salesCount: 203,
        author: 'Rick Warren',
        publisher: 'Vida Publishers',
        releaseDate: DateTime(2022, 11, 5),
        tags: ['propósito', 'vida cristiana', 'rick warren', 'crecimiento', 'fe'],
      ),

      // Niños
      VMFProduct(
        id: 'nin001',
        name: 'Biblia Ilustrada para Niños',
        description: 'Una biblia especialmente diseñada para niños con hermosas ilustraciones, historias adaptadas y actividades que hacen que aprender sobre Dios sea divertido.',
        shortDescription: 'Biblia con ilustraciones y actividades para niños',
        price: 299,
        images: [
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
          'https://images.unsplash.com/photo-1481627834876-b7833e8f5570?w=400'
        ],
        featuredImage: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
        type: ProductType.book,
        category: ProductCategory.ninos,
        inStock: true,
        stockQuantity: 20,
        isFeatured: true,
        rating: 4.8,
        reviewCount: 67,
        salesCount: 112,
        publisher: 'Editorial Patmos',
        releaseDate: DateTime(2023, 2, 14),
        tags: ['niños', 'biblia', 'ilustraciones', 'educación cristiana', 'familia'],
      ),

      // Juventud
      VMFProduct(
        id: 'juv001',
        name: 'Generación que Cambia el Mundo',
        description: 'Un libro inspirador para jóvenes que quieren hacer la diferencia. Descubre cómo Dios puede usar tu generación para transformar el mundo a través de la fe y la acción.',
        shortDescription: 'Inspiración para jóvenes que quieren cambiar el mundo',
        price: 199,
        images: [
          'https://images.unsplash.com/photo-1522202176988-66273c2fd55f?w=400',
          'https://images.unsplash.com/photo-1481627834876-b7833e8f5570?w=400'
        ],
        featuredImage: 'https://images.unsplash.com/photo-1522202176988-66273c2fd55f?w=400',
        type: ProductType.book,
        category: ProductCategory.juventud,
        inStock: true,
        stockQuantity: 35,
        rating: 4.5,
        reviewCount: 98,
        salesCount: 78,
        author: 'Marcos Vidal',
        publisher: 'Peniel',
        releaseDate: DateTime(2023, 4, 20),
        tags: ['juventud', 'propósito', 'cambio', 'fe', 'acción'],
      ),

      // Matrimonio
      VMFProduct(
        id: 'mat001',
        name: 'Matrimonio a Prueba de Divorcios',
        description: 'Herramientas prácticas y principios bíblicos para construir un matrimonio sólido y duradero. Basado en años de consejería matrimonial y experiencia pastoral.',
        shortDescription: 'Guía práctica para un matrimonio sólido y duradero',
        price: 279,
        images: [
          'https://images.unsplash.com/photo-1511895426328-dc8714191300?w=400',
          'https://images.unsplash.com/photo-1481627834876-b7833e8f5570?w=400'
        ],
        featuredImage: 'https://images.unsplash.com/photo-1511895426328-dc8714191300?w=400',
        type: ProductType.book,
        category: ProductCategory.matrimonio,
        inStock: true,
        stockQuantity: 18,
        rating: 4.7,
        reviewCount: 134,
        salesCount: 89,
        author: 'Dr. Emerson Eggerichs',
        publisher: 'Casa Creación',
        releaseDate: DateTime(2022, 12, 8),
        tags: ['matrimonio', 'familia', 'relaciones', 'amor', 'compromiso'],
      ),

      // Ropa VMF
      VMFProduct(
        id: 'rop001',
        name: 'Camiseta VMF Sweden - Fe en Acción',
        description: 'Camiseta oficial de VMF Sweden con diseño exclusivo. Material de alta calidad, 100% algodón orgánico. Lleva tu fe contigo todos los días.',
        shortDescription: 'Camiseta oficial VMF Sweden de alta calidad',
        price: 299,
        regularPrice: 349,
        salePrice: 299,
        images: [
          'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=400',
          'https://images.unsplash.com/photo-1503341504253-dff4815485f1?w=400'
        ],
        featuredImage: 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=400',
        type: ProductType.clothing,
        category: ProductCategory.ropa_vmf,
        inStock: true,
        stockQuantity: 50,
        onSale: true,
        rating: 4.4,
        reviewCount: 45,
        salesCount: 156,
        publisher: 'VMF Sweden',
        releaseDate: DateTime(2023, 5, 1),
        tags: ['camiseta', 'vmf', 'ropa', 'fe', 'algodón orgánico'],
        variations: [
          VMFProductVariation(
            id: 'rop001_s',
            productId: 'rop001',
            name: 'Talla S',
            price: 299,
            attributes: {'talla': 'S', 'color': 'Negro'},
            stockQuantity: 12,
          ),
          VMFProductVariation(
            id: 'rop001_m',
            productId: 'rop001',
            name: 'Talla M',
            price: 299,
            attributes: {'talla': 'M', 'color': 'Negro'},
            stockQuantity: 20,
          ),
          VMFProductVariation(
            id: 'rop001_l',
            productId: 'rop001',
            name: 'Talla L',
            price: 299,
            attributes: {'talla': 'L', 'color': 'Negro'},
            stockQuantity: 18,
          ),
        ],
      ),

      // Curso Digital
      VMFProduct(
        id: 'cur001',
        name: 'Curso: Liderazgo Cristiano Efectivo',
        description: 'Curso digital completo sobre liderazgo cristiano con 12 módulos, videos HD, material descargable y certificado. Aprende a liderar como Jesús.',
        shortDescription: 'Curso digital de liderazgo cristiano con certificado',
        price: 799,
        regularPrice: 999,
        salePrice: 799,
        images: [
          'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=400',
          'https://images.unsplash.com/photo-1481627834876-b7833e8f5570?w=400'
        ],
        featuredImage: 'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=400',
        type: ProductType.course,
        category: ProductCategory.liderazgo,
        inStock: true,
        stockQuantity: 999, // Digital - ilimitado
        isDigital: true,
        isFeatured: true,
        onSale: true,
        rating: 4.9,
        reviewCount: 89,
        salesCount: 67,
        author: 'Pastor Carlos Mendez',
        publisher: 'VMF Academy',
        releaseDate: DateTime(2023, 6, 15),
        tags: ['curso', 'liderazgo', 'digital', 'certificado', 'formación'],
        downloadUrl: 'https://academy.vmf.com/courses/liderazgo-cristiano',
      ),

      // Recursos Pastorales
      VMFProduct(
        id: 'pas001',
        name: 'Manual del Pastor: Herramientas Prácticas',
        description: 'Manual completo para pastores con herramientas prácticas para el ministerio: predicación, consejería, administración y cuidado pastoral.',
        shortDescription: 'Manual práctico con herramientas para el ministerio pastoral',
        price: 449,
        images: [
          'https://images.unsplash.com/photo-1481627834876-b7833e8f5570?w=400',
          'https://images.unsplash.com/photo-1504052434569-70ad5836ab65?w=400'
        ],
        featuredImage: 'https://images.unsplash.com/photo-1481627834876-b7833e8f5570?w=400',
        type: ProductType.book,
        category: ProductCategory.recursos_pastorales,
        inStock: true,
        stockQuantity: 12,
        rating: 4.8,
        reviewCount: 34,
        salesCount: 45,
        author: 'Dr. John MacArthur',
        publisher: 'Editorial Portavoz',
        releaseDate: DateTime(2023, 1, 30),
        tags: ['pastoral', 'ministerio', 'herramientas', 'liderazgo', 'iglesia'],
      ),
    ];
  }
}