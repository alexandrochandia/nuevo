
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/aura_provider.dart';
import '../utils/glow_styles.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../widgets/glow_avatar_widget.dart';
import 'aura_customization_screen.dart';
import 'change_language_screen.dart';
import 'video_calling_screen.dart';
import 'galeria_screen.dart';
import 'testimonios_avanzados_screen.dart';
import 'vmf_stories_screen.dart';
import 'livestream_screen.dart';
import 'coin_wallet_screen.dart';
import 'feed_screen.dart';
import 'notification_screen.dart';
import 'profile_screen.dart';
import 'search_screen.dart';
import 'prayer_request_screen.dart';
import 'ministry_screen.dart';
import 'visit_tracker_screen.dart';
import 'qr_code_screen.dart';
import 'spiritual_music_screen.dart';
import 'events_screen.dart';
import 'media_unified_screen.dart';
import '../modules/casas_iglesias/casas_iglesias_screen.dart';
import '../modules/devocional/devocional_screen.dart';
import 'store/vmf_store_screen.dart';
import 'store/vmf_store_onboarding_screen.dart';

class PersonalMenuScreen extends StatefulWidget {
  const PersonalMenuScreen({super.key});

  @override
  State<PersonalMenuScreen> createState() => _PersonalMenuScreenState();
}

class _PersonalMenuScreenState extends State<PersonalMenuScreen>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  Map<String, dynamic>? userProfile;
  int visitorCount = 0;
  bool isLoading = true;

  final List<Map<String, dynamic>> menuOptions = [
    {
      'emoji': '📱',
      'title': 'Historias VMF',
      'subtitle': 'Testimonios cortos y momentos espirituales',
      'color': const Color(0xFFFFD700),
      'action': 'vmf_stories',
    },
    {
      'emoji': '🧪',
      'title': 'Testimonios',
      'subtitle': 'Compartir tu testimonio de fe',
      'color': const Color(0xFF4ecdc4),
      'route': '/testimonios',
    },
    {
      'emoji': '🎥',
      'title': 'Videos en Vivo',
      'subtitle': 'Servicios y transmisiones en vivo',
      'color': const Color(0xFFf093fb),
      'route': '/live_videos',
    },
    {
      'emoji': '📅',
      'title': 'Eventos VMF',
      'subtitle': 'Cultos, conferencias y actividades',
      'color': const Color(0xFFE91E63),
      'action': 'events',
    },
    {
      'emoji': '🎵',
      'title': 'Multimedia VMF',
      'subtitle': 'Alabanza, sermones y contenido espiritual',
      'color': const Color(0xFFFFD700),
      'action': 'multimedia',
    },
    {
      'emoji': '⛪',
      'title': 'Casas Iglesias',
      'subtitle': 'Localiza iglesias VMF cercanas',
      'color': const Color(0xFF9C27B0),
      'action': 'casas_iglesias',
    },
    {
      'emoji': '💰',
      'title': 'Ofrendas VMF',
      'subtitle': 'Diezmos y donaciones digitales',
      'color': const Color(0xFFf39c12),
      'action': 'offerings',
    },
    {
      'emoji': '📰',
      'title': 'Feed Espiritual VMF',
      'subtitle': 'Noticias, reflexiones y anuncios',
      'color': const Color(0xFF3498db),
      'action': 'feed',
    },
    {
      'emoji': '🔔',
      'title': 'Notificaciones VMF',
      'subtitle': 'Recordatorios de oración y eventos',
      'color': const Color(0xFFe74c3c),
      'action': 'notifications',
    },
    {
      'emoji': '👤',
      'title': 'Perfil Espiritual',
      'subtitle': 'Mi información completa y testimonio',
      'color': const Color(0xFF9b59b6),
      'action': 'spiritual_profile',
    },
    {
      'emoji': '🔍',
      'title': 'Búsqueda VMF',
      'subtitle': 'Buscar hermanos, eventos y contenido',
      'color': const Color(0xFF34495e),
      'action': 'search',
    },
    {
      'emoji': '🙏',
      'title': 'Peticiones de Oración',
      'subtitle': 'Compartir y orar por las necesidades',
      'color': const Color(0xFFe91e63),
      'action': 'prayer_requests',
    },
    {
      'emoji': '⛪',
      'title': 'Ministerios VMF',
      'subtitle': 'Únete y sirve en los ministerios',
      'color': const Color(0xFF8e44ad),
      'action': 'ministries',
    },
    {
      'emoji': '📊',
      'title': 'Gestión de Visitas',
      'subtitle': 'Seguimiento pastoral de visitantes',
      'color': const Color(0xFF27ae60),
      'action': 'visits',
    },
    {
      'emoji': '🔳',
      'title': 'QR Codes VMF',
      'subtitle': 'Generar y escanear códigos QR',
      'color': const Color(0xFF3498db),
      'action': 'qr_codes',
    },
    {
      'emoji': '🎵',
      'title': 'Música Espiritual VMF',
      'subtitle': 'Biblioteca musical para testimonios y predicación',
      'color': const Color(0xFF9b59b6),
      'action': 'spiritual_music',
    },
    {
      'emoji': '🛒',
      'title': 'Tienda VMF Premium',
      'subtitle': 'Recursos espirituales y productos VMF',
      'color': const Color(0xFFff6b6b),
      'action': 'store',
    },
    {
      'emoji': '📸',
      'title': 'Galería',
      'subtitle': 'Fotos de eventos VMF',
      'color': const Color(0xFF764ba2),
      'route': '/gallery',
    },
    {
      'emoji': '🙏',
      'title': 'Devocionales',
      'subtitle': 'Lecturas y reflexiones diarias',
      'color': const Color(0xFF43e97b),
      'route': '/devotionals',
    },
    {
      'emoji': '📖',
      'title': 'Biblia Favorita',
      'subtitle': 'Versículos y pasajes guardados',
      'color': const Color(0xFF38ef7d),
      'route': '/bible',
    },
    {
      'emoji': '📺',
      'title': 'Cultos en Vivo',
      'subtitle': 'Transmisiones y eventos',
      'color': const Color(0xFFe74c3c),
      'action': 'livestream',
    },
    {
      'emoji': '💬',
      'title': 'Chat Espiritual VMF',
      'subtitle': 'Oración, pastoral y grupos',
      'color': const Color(0xFF4CAF50),
      'action': 'vmf_chat',
    },
    {
      'emoji': '📖',
      'title': 'Devocional Diario VMF',
      'subtitle': 'Fortalece tu fe cada día',
      'color': const Color(0xFF9b59b6),
      'action': 'devocional',
    },
    {
      'emoji': '⛪',
      'title': 'Casas Iglesias VMF',
      'subtitle': 'Encuentra tu familia espiritual',
      'color': const Color(0xFFD4AF37),
      'action': 'casas_iglesias',
    },
    {
      'emoji': '📞',
      'title': 'Videollamadas VMF',
      'subtitle': 'Llamadas entre hermanos',
      'color': const Color(0xFF4facfe),
      'action': 'video_calls',
    },
    {
      'emoji': '👀',
      'title': 'Visitantes recientes',
      'subtitle': 'Ver quién visitó tu perfil',
      'color': const Color(0xFF00b894),
      'route': '/visitors',
    },
    {
      'emoji': '🎨',
      'title': 'Personaliza tu aura VMF',
      'subtitle': 'Cambiar color del glow',
      'color': const Color(0xFFD4AF37),
      'action': 'aura_customization',
    },
    {
      'emoji': '🌐',
      'title': 'Cambiar Idioma',
      'subtitle': 'Español, English, Svenska',
      'color': const Color(0xFF4ecdc4),
      'action': 'change_language',
    },
    {
      'emoji': '🔒',
      'title': 'Privacidad',
      'subtitle': 'Control de datos personales',
      'color': const Color(0xFF38ef7d),
      'route': '/privacy',
    },
    {
      'emoji': '📄',
      'title': 'Términos y condiciones',
      'subtitle': 'Políticas VMF Sweden',
      'color': const Color(0xFF6c5ce7),
      'route': '/terms',
    },
    {
      'emoji': '🚪',
      'title': 'Cerrar Sesión',
      'subtitle': 'Salir de la aplicación',
      'color': const Color(0xFFff6b6b),
      'action': 'logout',
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
    ));
    
    _loadUserData();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      const String defaultUserId = 'demo-user-id';
      final profile = await UserService.getUserProfile(defaultUserId);
      final visitors = await UserService.getVisitorCount(profile?['id'] ?? defaultUserId);
      
      setState(() {
        userProfile = profile;
        visitorCount = visitors;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        userProfile = {
          'name': 'Usuario VMF',
          'profile_photo_url': null,
        };
        visitorCount = 12;
        isLoading = false;
      });
      print('Error loading user data: $e');
    }
  }

  Future<void> _changeProfilePhoto() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          height: 200,
          decoration: const BoxDecoration(
            color: Color(0xFF1a1a2e),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            border: Border(
              top: BorderSide(color: Colors.white12, width: 1),
            ),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  '📷 Cambiar Foto de Perfil',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildPhotoOption(
                        icon: Icons.camera_alt,
                        title: 'Cámara',
                        onTap: () => _pickImage(ImageSource.camera),
                      ),
                      _buildPhotoOption(
                        icon: Icons.photo_library,
                        title: 'Galería',
                        onTap: () => _pickImage(ImageSource.gallery),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPhotoOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: const Color(0xFFFFD700),
              size: 30,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    Navigator.pop(context);
    
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );
      
      if (image != null) {
        // Para el demo, simulamos guardar la imagen localmente
        setState(() {
          userProfile = {
            ...?userProfile,
            'profile_photo_url': image.path,
          };
        });
        
        // Mostrar mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green),
                const SizedBox(width: 8),
                const Text('Foto de perfil actualizada'),
              ],
            ),
            backgroundColor: const Color(0xFF1a1a2e),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.red),
              const SizedBox(width: 8),
              const Text('Error al seleccionar imagen'),
            ],
          ),
          backgroundColor: const Color(0xFF1a1a2e),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  Future<void> _handleLogout() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1a1a2e),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            '¿Cerrar Sesión?',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            '¿Estás seguro de que quieres cerrar sesión?',
            style: TextStyle(
              color: Colors.white70,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Colors.white70),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await AuthService.signOut();
                if (mounted) {
                  Navigator.of(context).pushReplacementNamed('/intro');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFff6b6b),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Cerrar Sesión',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _handleMenuTap(int index) {
    final option = menuOptions[index];
    
    if (option['action'] == 'logout') {
      _handleLogout();
      return;
    }
    
    if (option['action'] == 'aura_customization') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const AuraCustomizationScreen(),
        ),
      );
      return;
    }
    
    if (option['action'] == 'change_language') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const ChangeLanguageScreen(),
        ),
      );
      return;
    }
    
    if (option['action'] == 'video_calls') {
      _showVideoCallOptions();
      return;
    }
    
    if (option['action'] == 'events') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const EventsScreen(),
        ),
      );
      return;
    }
    
    if (option['action'] == 'multimedia') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const MediaUnifiedScreen(),
        ),
      );
      return;
    }
    
    if (option['action'] == 'devocional') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const DevocionalScreen(),
        ),
      );
      return;
    }
    
    if (option['action'] == 'casas_iglesias') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const CasasIglesiasScreen(),
        ),
      );
      return;
    }
    
    if (option['action'] == 'vmf_stories') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const VMFStoriesScreen(),
        ),
      );
      return;
    }
    
    if (option['action'] == 'vmf_chat') {
      _showComingSoonDialog('Chat VMF');
      return;
    }
    
    if (option['action'] == 'livestream') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const LiveStreamScreen(),
        ),
      );
      return;
    }
    
    if (option['action'] == 'offerings') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const CoinWalletScreen(),
        ),
      );
      return;
    }
    
    if (option['action'] == 'feed') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const FeedScreen(),
        ),
      );
      return;
    }
    
    if (option['action'] == 'notifications') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const NotificationScreen(),
        ),
      );
      return;
    }
    
    if (option['action'] == 'spiritual_profile') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const ProfileScreen(),
        ),
      );
      return;
    }
    
    if (option['action'] == 'search') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const SearchScreen(),
        ),
      );
      return;
    }
    
    if (option['action'] == 'prayer_requests') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const PrayerRequestScreen(),
        ),
      );
      return;
    }
    
    if (option['action'] == 'ministries') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const MinistryScreen(),
        ),
      );
      return;
    }
    
    if (option['action'] == 'visits') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const VisitTrackerScreen(),
        ),
      );
      return;
    }
    
    if (option['action'] == 'qr_codes') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const QRCodeScreen(),
        ),
      );
      return;
    }
    
    if (option['action'] == 'spiritual_music') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const SpiritualMusicScreen(),
        ),
      );
      return;
    }
    
    if (option['action'] == 'store') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const VMFStoreOnboardingScreen(),
        ),
      );
      return;
    }

    // Navegación específica para galería
    if (option['route'] == '/gallery') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const GaleriaScreen(),
        ),
      );
      return;
    }
    
    // Navegación específica para testimonios
    if (option['route'] == '/testimonios') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const TestimoniosAvanzadosScreen(),
        ),
      );
      return;
    }
    
    // Mostrar funcionalidad próximamente pero con animación
    _showComingSoonDialog(option['title'] as String);
  }

  void _showVideoCallOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          height: 300,
          decoration: const BoxDecoration(
            color: Color(0xFF1a1a2e),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            border: Border(
              top: BorderSide(color: Colors.white12, width: 1),
            ),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              const Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  '📞 Videollamadas VMF',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      _buildVideoCallOption(
                        icon: '👥',
                        title: 'Llamada de prueba',
                        subtitle: 'Probar videollamada simulada',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const VideoCallingScreen(
                                contactName: 'Hermano de Prueba',
                                contactId: 'test_user',
                                isIncomingCall: false,
                              ),
                            ),
                          );
                        },
                      ),
                      
                      const SizedBox(height: 15),
                      
                      _buildVideoCallOption(
                        icon: '📱',
                        title: 'Llamada entrante simulada',
                        subtitle: 'Ver interfaz de llamada entrante',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const VideoCallingScreen(
                                contactName: 'Pastor VMF',
                                contactId: 'pastor_vmf',
                                isIncomingCall: true,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildVideoCallOption({
    required String icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF16213e).withOpacity(0.8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFF4facfe).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  icon,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
            
            const SizedBox(width: 16),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white54,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _showComingSoonDialog(String feature) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1a1a2e),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                  ),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: const Icon(
                  Icons.rocket_launch,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                '¡Próximamente!',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '$feature estará disponible muy pronto.\n¡Estate atento a las actualizaciones!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF667eea),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                child: const Text(
                  'Entendido',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topCenter,
            radius: 1.5,
            colors: [
              Color(0xFF1a1a2e),
              Color(0xFF16213e),
              Color(0xFF0f3460),
              Color(0xFF000814),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header con botón de regreso
              _buildHeader(),
              
              // Contenido principal
              Expanded(
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: _buildContent(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          // Botón de regreso
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF667eea).withOpacity(0.3),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Título
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '👤 VMF Sweden',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Text(
                  'Menú Personal',
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Perfil del usuario
          _buildUserProfile(),
          
          const SizedBox(height: 30),
          
          // Opciones del menú
          _buildMenuOptions(),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildUserProfile() {
    return Consumer<AuraProvider>(
      builder: (context, auraProvider, child) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1a1a2e).withOpacity(0.9),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 2,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              // Foto de perfil con aura
              GlowAvatarWidget(
                size: 70,
                imageUrl: userProfile?['profile_photo_url'],
                name: _getDisplayName(),
                onTap: _changeProfilePhoto,
              ),
              
              const SizedBox(width: 16),
              
              // Información del usuario
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nombre del usuario
                    Text(
                      _getDisplayName(),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // Botón editar perfil
                    GestureDetector(
                      onTap: () => _showComingSoonDialog('Editar Perfil'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              auraProvider.selectedAuraColor.withOpacity(0.3),
                              auraProvider.selectedAuraColor.withOpacity(0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: auraProvider.selectedAuraColor.withOpacity(0.5),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.edit,
                              color: auraProvider.selectedAuraColor,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Editar Perfil',
                              style: TextStyle(
                                fontSize: 12,
                                color: auraProvider.selectedAuraColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Contador de visitantes (como en la imagen)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '$visitorCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Visitors',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getDisplayName() {
    if (userProfile?['name'] != null && userProfile!['name'].isNotEmpty) {
      final fullName = userProfile!['name'] as String;
      if (fullName.length > 12) {
        return '${fullName.substring(0, 12)}...';
      }
      return fullName;
    }
    
    final email = AuthService.currentUser?.email ?? 'Usuario VMF';
    if (email.contains('@')) {
      final username = email.split('@').first;
      if (username.length > 12) {
        return '${username.substring(0, 12)}...';
      }
      return username;
    }
    
    return 'Usuario VMF';
  }

  Widget _buildDefaultAvatar() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF4ecdc4), Color(0xFF44a08d)],
        ),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.person,
        size: 35,
        color: Colors.white,
      ),
    );
  }

  Widget _buildMenuOptions() {
    return Column(
      children: menuOptions.asMap().entries.map((entry) {
        final index = entry.key;
        final option = entry.value;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: GestureDetector(
            onTap: () => _handleMenuTap(index),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1a1a2e).withOpacity(0.8),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    spreadRadius: 1,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Emoji
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          option['color'] as Color,
                          (option['color'] as Color).withOpacity(0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: (option['color'] as Color).withOpacity(0.3),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        option['emoji'] as String,
                        style: const TextStyle(
                          fontSize: 24,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Textos
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          option['title'] as String,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          option['subtitle'] as String,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Flecha
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white.withOpacity(0.5),
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
