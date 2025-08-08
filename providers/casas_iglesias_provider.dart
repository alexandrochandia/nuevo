import 'package:flutter/material.dart';
import '../models/iglesia_model.dart';
import '../config/supabase_config.dart';

class CasasIglesiasProvider extends ChangeNotifier {
  List<IglesiaModel> _iglesias = [];
  List<IglesiaModel> _iglesiasFiltradas = [];
  List<IglesiaModel> _favoritas = [];
  bool _isLoading = false;
  String _filtroTipo = 'todas'; // 'todas', 'presencial', 'virtual', 'hibrida'
  String _filtroIdioma = 'todos'; // 'todos', 'español', 'sueco', 'ingles'
  String _filtroPais = 'todos'; // 'todos', 'Suecia', 'España', etc.
  String _busqueda = '';
  bool _vistaLista = true; // true para lista, false para mapa

  // Getters
  List<IglesiaModel> get iglesias => _iglesiasFiltradas;
  List<IglesiaModel> get favoritas => _favoritas;
  bool get isLoading => _isLoading;
  String get filtroTipo => _filtroTipo;
  String get filtroIdioma => _filtroIdioma;
  String get filtroPais => _filtroPais;
  String get busqueda => _busqueda;
  bool get vistaLista => _vistaLista;

  List<String> get tiposReunion => ['todas', 'presencial', 'virtual', 'hibrida'];
  List<String> get idiomas => ['todos', 'español', 'sueco', 'ingles'];
  List<String> get paises => ['todos', 'Suecia', 'España', 'Noruega', 'Dinamarca'];

  CasasIglesiasProvider() {
    cargarIglesias();
  }

  Future<void> cargarIglesias() async {
    _isLoading = true;
    notifyListeners();

    try {
      if (SupabaseConfig.client != null) {
        final response = await SupabaseConfig.client!
            .from('casas_iglesias')
            .select('*')
            .eq('es_activa', true)
            .order('nombre');
        
        _iglesias = response.map<IglesiaModel>((json) => IglesiaModel.fromJson(json)).toList();
      } else {
        // Datos de prueba con iglesias VMF reales
        _iglesias = _obtenerDatosPrueba();
      }
      
      _iglesiasFiltradas = List.from(_iglesias);
      _favoritas = _iglesias.where((iglesia) => iglesia.esFavorita).toList();
      
    } catch (e) {
      print('Error cargando iglesias: $e');
      _iglesias = _obtenerDatosPrueba();
      _iglesiasFiltradas = List.from(_iglesias);
    }

    _isLoading = false;
    notifyListeners();
  }

  void aplicarFiltros() {
    _iglesiasFiltradas = _iglesias.where((iglesia) {
      // Filtro por tipo de reunión
      bool cumpleTipo = _filtroTipo == 'todas' || iglesia.tipoReunion == _filtroTipo;
      
      // Filtro por idioma
      bool cumpleIdioma = _filtroIdioma == 'todos' || iglesia.idioma == _filtroIdioma;
      
      // Filtro por país
      bool cumplePais = _filtroPais == 'todos' || iglesia.pais == _filtroPais;
      
      // Filtro por búsqueda
      bool cumpleBusqueda = _busqueda.isEmpty ||
          iglesia.nombre.toLowerCase().contains(_busqueda.toLowerCase()) ||
          iglesia.ciudad.toLowerCase().contains(_busqueda.toLowerCase()) ||
          iglesia.direccion.toLowerCase().contains(_busqueda.toLowerCase()) ||
          iglesia.liderNombre.toLowerCase().contains(_busqueda.toLowerCase());
      
      return cumpleTipo && cumpleIdioma && cumplePais && cumpleBusqueda;
    }).toList();
    
    notifyListeners();
  }

  void cambiarFiltroTipo(String tipo) {
    _filtroTipo = tipo;
    aplicarFiltros();
  }

  void cambiarFiltroIdioma(String idioma) {
    _filtroIdioma = idioma;
    aplicarFiltros();
  }

  void cambiarFiltroPais(String pais) {
    _filtroPais = pais;
    aplicarFiltros();
  }

  void buscar(String termino) {
    _busqueda = termino;
    aplicarFiltros();
  }

  void cambiarVista() {
    _vistaLista = !_vistaLista;
    notifyListeners();
  }

  Future<void> toggleFavorita(String iglesiaId) async {
    final index = _iglesias.indexWhere((iglesia) => iglesia.id == iglesiaId);
    if (index != -1) {
      final iglesia = _iglesias[index];
      final nuevaIglesia = iglesia.copyWith(esFavorita: !iglesia.esFavorita);
      _iglesias[index] = nuevaIglesia;
      
      if (nuevaIglesia.esFavorita) {
        _favoritas.add(nuevaIglesia);
      } else {
        _favoritas.removeWhere((fav) => fav.id == iglesiaId);
      }
      
      // Actualizar en Supabase
      try {
        if (SupabaseConfig.client != null) {
          await SupabaseConfig.client!
              .from('casas_iglesias')
              .update({'es_favorita': nuevaIglesia.esFavorita})
              .eq('id', iglesiaId);
        }
      } catch (e) {
        print('Error actualizando favorita: $e');
      }
      
      aplicarFiltros();
    }
  }

  List<IglesiaModel> _obtenerDatosPrueba() {
    return [
      IglesiaModel(
        id: '1',
        nombre: 'VMF Estocolmo Centro',
        ciudad: 'Stockholm',
        pais: 'Suecia',
        direccion: 'Drottninggatan 45',
        descripcion: 'Casa iglesia principal de VMF en el centro de Estocolmo. Una familia espiritual diversa que se reúne para adorar, estudiar la Palabra y crecer juntos en fe. Somos una comunidad multicultural donde todos son bienvenidos.',
        liderNombre: 'Pastor Carlos Mendoza',
        liderEmail: 'carlos.mendoza@vmfsweden.org',
        liderTelefono: '+46 70 123 4567',
        liderWhatsapp: '+46 70 123 4567',
        horarioReunion: '11:00 AM',
        diaReunion: 'Domingos',
        tipoReunion: 'hibrida',
        idioma: 'español',
        imagenUrl: 'https://images.unsplash.com/photo-1438032005730-c779502df39b?w=400',
        cantidadMiembros: 85,
        latitud: 59.3293,
        longitud: 18.0686,
        enlaceZoom: 'https://zoom.us/j/123456789',
        sitioWeb: 'https://vmfsweden.org/estocolmo',
        servicios: ['culto', 'oracion', 'estudio', 'jovenes', 'niños'],
        testimonios: [
          'Esta iglesia cambió mi vida. Encontré una familia espiritual aquí.',
          'El amor de Cristo se siente en cada reunión.',
          'Los líderes son un ejemplo de servicio y humildad.'
        ],
        fechaCreacion: DateTime.now().subtract(const Duration(days: 1095)),
        ultimaReunion: DateTime.now().subtract(const Duration(days: 3)),
      ),
      IglesiaModel(
        id: '2',
        nombre: 'VMF Göteborg Casa de Oración',
        ciudad: 'Göteborg',
        pais: 'Suecia',
        direccion: 'Avenyn 23',
        descripcion: 'Centro de oración y adoración en Göteborg. Nos enfocamos en la intercesión, el avivamiento y la presencia de Dios. Reuniones poderosas llenas del Espíritu Santo donde experimentamos milagros y sanidades.',
        liderNombre: 'Pastora María Andersson',
        liderEmail: 'maria.andersson@vmfsweden.org',
        liderTelefono: '+46 70 234 5678',
        liderWhatsapp: '+46 70 234 5678',
        horarioReunion: '7:00 PM',
        diaReunion: 'Miércoles',
        tipoReunion: 'presencial',
        idioma: 'sueco',
        imagenUrl: 'https://images.unsplash.com/photo-1507692049790-de58290a4334?w=400',
        cantidadMiembros: 42,
        latitud: 57.7089,
        longitud: 11.9746,
        sitioWeb: 'https://vmfsweden.org/goteborg',
        servicios: ['oracion', 'adoracion', 'intercesion', 'sanidad'],
        testimonios: [
          'Dios me sanó completamente en una de las reuniones de oración.',
          'La presencia de Dios es tangible en este lugar.',
          'Mi vida de oración se transformó aquí.'
        ],
        fechaCreacion: DateTime.now().subtract(const Duration(days: 800)),
        ultimaReunion: DateTime.now().subtract(const Duration(days: 1)),
      ),
      IglesiaModel(
        id: '3',
        nombre: 'VMF Malmö Comunidad',
        ciudad: 'Malmö',
        pais: 'Suecia',
        direccion: 'Södergatan 12',
        descripcion: 'Comunidad joven y vibrante en Malmö. Enfocados en alcanzar a la nueva generación con el evangelio. Música contemporánea, enseñanza relevante y un ambiente familiar donde los jóvenes pueden crecer en su fe.',
        liderNombre: 'Pastor Miguel Johansson',
        liderEmail: 'miguel.johansson@vmfsweden.org',
        liderTelefono: '+46 70 345 6789',
        liderWhatsapp: '+46 70 345 6789',
        horarioReunion: '6:30 PM',
        diaReunion: 'Viernes',
        tipoReunion: 'presencial',
        idioma: 'español',
        imagenUrl: 'https://images.unsplash.com/photo-1511632765486-a01980e01a18?w=400',
        cantidadMiembros: 38,
        latitud: 55.6050,
        longitud: 13.0038,
        servicios: ['culto', 'jovenes', 'musica', 'evangelismo'],
        testimonios: [
          'Como joven, encontré mi propósito en esta comunidad.',
          'La música y adoración aquí son increíbles.',
          'Crecí espiritualmente rodeado de amigos que me apoyan.'
        ],
        fechaCreacion: DateTime.now().subtract(const Duration(days: 600)),
        ultimaReunion: DateTime.now().subtract(const Duration(days: 2)),
      ),
      IglesiaModel(
        id: '4',
        nombre: 'VMF Uppsala Casa de Bendición',
        ciudad: 'Uppsala',
        pais: 'Suecia',
        direccion: 'Kungsgatan 8',
        descripcion: 'Casa iglesia familiar en Uppsala. Un lugar donde las familias crecen juntas en la fe. Ministerio fuerte para niños, matrimonios y parejas. Ambiente acogedor donde cada familia encuentra su lugar en el cuerpo de Cristo.',
        liderNombre: 'Pastores Ana y David Eriksson',
        liderEmail: 'pastores@vmfuppsala.org',
        liderTelefono: '+46 70 456 7890',
        liderWhatsapp: '+46 70 456 7890',
        horarioReunion: '5:00 PM',
        diaReunion: 'Sábados',
        tipoReunion: 'hibrida',
        idioma: 'español',
        imagenUrl: 'https://images.unsplash.com/photo-1488521787991-ed7bbaae773c?w=400',
        cantidadMiembros: 56,
        latitud: 59.8586,
        longitud: 17.6389,
        enlaceZoom: 'https://zoom.us/j/987654321',
        servicios: ['culto', 'niños', 'matrimonios', 'familias'],
        testimonios: [
          'Nuestro matrimonio se fortaleció gracias al ministerio de esta iglesia.',
          'Mis hijos aman venir y aprender de Jesús.',
          'Encontramos una familia espiritual que nos ama.'
        ],
        fechaCreacion: DateTime.now().subtract(const Duration(days: 900)),
        ultimaReunion: DateTime.now().subtract(const Duration(days: 1)),
      ),
      IglesiaModel(
        id: '5',
        nombre: 'VMF Online Internacional',
        ciudad: 'Virtual',
        pais: 'Global',
        direccion: 'Conexión Online',
        descripcion: 'Iglesia virtual que conecta a miembros de VMF alrededor del mundo. Servicios en múltiples idiomas, conferencias internacionales y una comunidad global unida por la fe. Perfecta para quienes no pueden asistir presencialmente.',
        liderNombre: 'Pastor Internacional Roberto Silva',
        liderEmail: 'roberto.silva@vmfglobal.org',
        liderTelefono: '+46 70 567 8901',
        liderWhatsapp: '+46 70 567 8901',
        horarioReunion: '8:00 PM',
        diaReunion: 'Domingos',
        tipoReunion: 'virtual',
        idioma: 'español',
        imagenUrl: 'https://images.unsplash.com/photo-1588196749597-9ff075ee6b5b?w=400',
        cantidadMiembros: 120,
        latitud: 0.0,
        longitud: 0.0,
        enlaceZoom: 'https://zoom.us/j/vmfonline',
        sitioWeb: 'https://vmfglobal.org/online',
        servicios: ['culto', 'conferencias', 'estudio', 'oracion', 'internacional'],
        testimonios: [
          'Desde España puedo participar de los servicios VMF.',
          'La comunidad online es tan real como la presencial.',
          'Conocí hermanos de todo el mundo a través de esta iglesia.'
        ],
        fechaCreacion: DateTime.now().subtract(const Duration(days: 365)),
        ultimaReunion: DateTime.now().subtract(const Duration(days: 0)),
      ),
    ];
  }

  IglesiaModel? obtenerIglesiaPorId(String id) {
    try {
      return _iglesias.firstWhere((iglesia) => iglesia.id == id);
    } catch (e) {
      return null;
    }
  }

  void limpiarFiltros() {
    _filtroTipo = 'todas';
    _filtroIdioma = 'todos';
    _filtroPais = 'todos';
    _busqueda = '';
    aplicarFiltros();
  }
}