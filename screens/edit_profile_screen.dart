import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/spiritual_profile_provider.dart';
import '../providers/aura_provider.dart';
import '../models/spiritual_profile_model.dart';
import '../widgets/glow_container.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bioController = TextEditingController();
  final _testimonyController = TextEditingController();
  final _currentChurchController = TextEditingController();
  final _pastorNameController = TextEditingController();
  final _baptismLocationController = TextEditingController();

  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _homePhoneController = TextEditingController();
  final _workPhoneController = TextEditingController();

  DateTime? _birthDate;
  DateTime? _conversionDate;
  DateTime? _baptismDate;
  BaptismStatus _baptismStatus = BaptismStatus.notBaptized;
  SpiritualMaturity _maturityLevel = SpiritualMaturity.newBeliever;

  List<String> _ministries = [];
  List<String> _spiritualGifts = [];
  List<String> _favoriteVerses = [];

  PreferenceSettings _preferences = PreferenceSettings();

  bool _isLoading = false;

  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _loadCurrentProfile();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _glowController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    _testimonyController.dispose();
    _currentChurchController.dispose();
    _pastorNameController.dispose();
    _baptismLocationController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _homePhoneController.dispose();
    _workPhoneController.dispose();
    super.dispose();
  }

  void _loadCurrentProfile() {
    final provider = context.read<SpiritualProfileProvider>();
    final profile = provider.currentProfile;
    
    if (profile != null) {
      _fullNameController.text = profile.fullName;
      _emailController.text = profile.email;
      _phoneController.text = profile.phoneNumber ?? '';
      _bioController.text = profile.spiritualBio;
      _testimonyController.text = profile.testimony;
      _currentChurchController.text = profile.currentChurch;
      _pastorNameController.text = profile.pastorName ?? '';
      _baptismLocationController.text = profile.baptismLocation ?? '';
      
      _addressController.text = profile.contactInfo.address ?? '';
      _cityController.text = profile.contactInfo.city ?? '';
      _homePhoneController.text = profile.contactInfo.homePhone ?? '';
      _workPhoneController.text = profile.contactInfo.workPhone ?? '';

      _birthDate = profile.birthDate;
      _conversionDate = profile.conversionDate;
      _baptismDate = profile.baptismDate;
      _baptismStatus = profile.baptismStatus;
      _maturityLevel = profile.maturityLevel;
      
      _ministries = List.from(profile.ministries);
      _spiritualGifts = List.from(profile.spiritualGifts);
      _favoriteVerses = List.from(profile.favoriteVerses);
      
      _preferences = profile.preferences;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<SpiritualProfileProvider, AuraProvider>(
      builder: (context, profileProvider, auraProvider, child) {
        final auraColor = auraProvider.currentAuraColor;
        final profile = profileProvider.currentProfile;

        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios, color: auraColor),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Editar Perfil',
              style: TextStyle(
                color: auraColor,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              if (_isLoading)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(auraColor),
                    ),
                  ),
                )
              else
                TextButton(
                  onPressed: _saveProfile,
                  child: Text(
                    'Guardar',
                    style: TextStyle(
                      color: auraColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          body: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildTabBar(auraColor),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildBasicInfoTab(profile, auraColor),
                      _buildSpiritualInfoTab(auraColor),
                      _buildContactTab(auraColor),
                      _buildPreferencesTab(auraColor),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTabBar(Color auraColor) {
    return Container(
      color: Colors.black,
      child: TabBar(
        controller: _tabController,
        indicatorColor: auraColor,
        indicatorWeight: 3,
        labelColor: auraColor,
        unselectedLabelColor: Colors.grey[400],
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        isScrollable: true,
        tabs: const [
          Tab(text: 'Básico'),
          Tab(text: 'Espiritual'),
          Tab(text: 'Contacto'),
          Tab(text: 'Privacidad'),
        ],
      ),
    );
  }

  Widget _buildBasicInfoTab(SpiritualProfile? profile, Color auraColor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Profile Image
          _buildProfileImageSection(profile, auraColor),
          
          const SizedBox(height: 24),
          
          // Cover Image
          _buildCoverImageSection(profile, auraColor),
          
          const SizedBox(height: 24),
          
          // Nombre completo
          _buildTextField(
            controller: _fullNameController,
            label: 'Nombre Completo',
            icon: Icons.person,
            auraColor: auraColor,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'El nombre es requerido';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 16),
          
          // Email
          _buildTextField(
            controller: _emailController,
            label: 'Correo Electrónico',
            icon: Icons.email,
            auraColor: auraColor,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'El email es requerido';
              }
              if (!value.contains('@')) {
                return 'Ingresa un email válido';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 16),
          
          // Teléfono
          _buildTextField(
            controller: _phoneController,
            label: 'Teléfono',
            icon: Icons.phone,
            auraColor: auraColor,
            keyboardType: TextInputType.phone,
          ),
          
          const SizedBox(height: 16),
          
          // Fecha de nacimiento
          _buildDateField(
            label: 'Fecha de Nacimiento',
            value: _birthDate,
            icon: Icons.cake,
            auraColor: auraColor,
            onTap: () => _selectDate(context, _birthDate, (date) {
              setState(() {
                _birthDate = date;
              });
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSpiritualInfoTab(Color auraColor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Biografía espiritual
          _buildTextField(
            controller: _bioController,
            label: 'Biografía Espiritual',
            icon: Icons.person_outline,
            auraColor: auraColor,
            maxLines: 3,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'La biografía es requerida';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 16),
          
          // Testimonio
          _buildTextField(
            controller: _testimonyController,
            label: 'Mi Testimonio',
            icon: Icons.auto_stories,
            auraColor: auraColor,
            maxLines: 5,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'El testimonio es requerido';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 16),
          
          // Fecha de conversión
          _buildDateField(
            label: 'Fecha de Conversión',
            value: _conversionDate,
            icon: Icons.favorite,
            auraColor: auraColor,
            onTap: () => _selectDate(context, _conversionDate, (date) {
              setState(() {
                _conversionDate = date;
              });
            }),
            isRequired: true,
          ),
          
          const SizedBox(height: 16),
          
          // Estado de bautismo
          _buildDropdownField(
            label: 'Estado de Bautismo',
            value: _baptismStatus,
            icon: Icons.water_drop,
            auraColor: auraColor,
            items: BaptismStatus.values.map((status) {
              return DropdownMenuItem(
                value: status,
                child: Text(status.displayName),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _baptismStatus = value!;
              });
            },
          ),
          
          const SizedBox(height: 16),
          
          // Fecha de bautismo (si está bautizado)
          if (_baptismStatus == BaptismStatus.baptized || _baptismStatus == BaptismStatus.scheduled)
            _buildDateField(
              label: 'Fecha de Bautismo',
              value: _baptismDate,
              icon: Icons.water,
              auraColor: auraColor,
              onTap: () => _selectDate(context, _baptismDate, (date) {
                setState(() {
                  _baptismDate = date;
                });
              }),
            ),
          
          const SizedBox(height: 16),
          
          // Lugar de bautismo
          if (_baptismStatus == BaptismStatus.baptized || _baptismStatus == BaptismStatus.scheduled)
            _buildTextField(
              controller: _baptismLocationController,
              label: 'Lugar de Bautismo',
              icon: Icons.location_on,
              auraColor: auraColor,
            ),
          
          const SizedBox(height: 16),
          
          // Iglesia actual
          _buildTextField(
            controller: _currentChurchController,
            label: 'Iglesia Actual',
            icon: Icons.church,
            auraColor: auraColor,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'La iglesia es requerida';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 16),
          
          // Pastor
          _buildTextField(
            controller: _pastorNameController,
            label: 'Pastor Principal',
            icon: Icons.person_pin,
            auraColor: auraColor,
          ),
          
          const SizedBox(height: 16),
          
          // Nivel de madurez espiritual
          _buildDropdownField(
            label: 'Madurez Espiritual',
            value: _maturityLevel,
            icon: Icons.trending_up,
            auraColor: auraColor,
            items: SpiritualMaturity.values.map((maturity) {
              return DropdownMenuItem(
                value: maturity,
                child: Text(maturity.displayName),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _maturityLevel = value!;
              });
            },
          ),
          
          const SizedBox(height: 20),
          
          // Ministerios
          _buildChipSection(
            title: 'Ministerios',
            items: _ministries,
            icon: Icons.volunteer_activism,
            auraColor: auraColor,
            suggestions: [
              'Pastoral', 'Predicación', 'Música', 'Adoración', 'Ministerio Juvenil',
              'Ministerio Infantil', 'Ministerio Femenino', 'Evangelismo', 'Oración',
              'Células', 'Hospitalidad', 'Consejería', 'Diácono', 'Anciano'
            ],
            onAdd: (item) {
              setState(() {
                _ministries.add(item);
              });
            },
            onRemove: (item) {
              setState(() {
                _ministries.remove(item);
              });
            },
          ),
          
          const SizedBox(height: 20),
          
          // Dones espirituales
          _buildChipSection(
            title: 'Dones Espirituales',
            items: _spiritualGifts,
            icon: Icons.card_giftcard,
            auraColor: auraColor,
            suggestions: [
              'Enseñanza', 'Liderazgo', 'Intercesión', 'Palabra de sabiduría',
              'Palabra de ciencia', 'Fe', 'Sanidades', 'Milagros', 'Profecía',
              'Discernimiento', 'Lenguas', 'Interpretación', 'Servicio',
              'Hospitalidad', 'Exhortación', 'Repartir', 'Presidir', 'Misericordia'
            ],
            onAdd: (item) {
              setState(() {
                _spiritualGifts.add(item);
              });
            },
            onRemove: (item) {
              setState(() {
                _spiritualGifts.remove(item);
              });
            },
          ),
          
          const SizedBox(height: 20),
          
          // Versículos favoritos
          _buildVerseSection(auraColor),
        ],
      ),
    );
  }

  Widget _buildContactTab(Color auraColor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Dirección
          _buildTextField(
            controller: _addressController,
            label: 'Dirección',
            icon: Icons.home,
            auraColor: auraColor,
          ),
          
          const SizedBox(height: 16),
          
          // Ciudad
          _buildTextField(
            controller: _cityController,
            label: 'Ciudad',
            icon: Icons.location_city,
            auraColor: auraColor,
          ),
          
          const SizedBox(height: 16),
          
          // Teléfono de casa
          _buildTextField(
            controller: _homePhoneController,
            label: 'Teléfono de Casa',
            icon: Icons.home_outlined,
            auraColor: auraColor,
            keyboardType: TextInputType.phone,
          ),
          
          const SizedBox(height: 16),
          
          // Teléfono de trabajo
          _buildTextField(
            controller: _workPhoneController,
            label: 'Teléfono de Trabajo',
            icon: Icons.work_outline,
            auraColor: auraColor,
            keyboardType: TextInputType.phone,
          ),
        ],
      ),
    );
  }

  Widget _buildPreferencesTab(Color auraColor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          GlowContainer(
            glowColor: auraColor,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1a1a1a),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: auraColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Configuración de Privacidad',
                    style: TextStyle(
                      color: auraColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  _buildSwitchTile(
                    title: 'Permitir visualización del perfil',
                    subtitle: 'Otros miembros pueden ver tu perfil',
                    value: _preferences.allowProfileViews,
                    auraColor: auraColor,
                    onChanged: (value) {
                      setState(() {
                        _preferences = PreferenceSettings(
                          allowProfileViews: value,
                          allowDirectMessages: _preferences.allowDirectMessages,
                          showParticipationStats: _preferences.showParticipationStats,
                          showAchievements: _preferences.showAchievements,
                          receiveEventNotifications: _preferences.receiveEventNotifications,
                          receivePrayerNotifications: _preferences.receivePrayerNotifications,
                          preferredLanguage: _preferences.preferredLanguage,
                          timezone: _preferences.timezone,
                        );
                      });
                    },
                  ),
                  
                  _buildSwitchTile(
                    title: 'Permitir mensajes directos',
                    subtitle: 'Otros miembros pueden enviarte mensajes',
                    value: _preferences.allowDirectMessages,
                    auraColor: auraColor,
                    onChanged: (value) {
                      setState(() {
                        _preferences = PreferenceSettings(
                          allowProfileViews: _preferences.allowProfileViews,
                          allowDirectMessages: value,
                          showParticipationStats: _preferences.showParticipationStats,
                          showAchievements: _preferences.showAchievements,
                          receiveEventNotifications: _preferences.receiveEventNotifications,
                          receivePrayerNotifications: _preferences.receivePrayerNotifications,
                          preferredLanguage: _preferences.preferredLanguage,
                          timezone: _preferences.timezone,
                        );
                      });
                    },
                  ),
                  
                  _buildSwitchTile(
                    title: 'Mostrar estadísticas de participación',
                    subtitle: 'Visible en tu perfil público',
                    value: _preferences.showParticipationStats,
                    auraColor: auraColor,
                    onChanged: (value) {
                      setState(() {
                        _preferences = PreferenceSettings(
                          allowProfileViews: _preferences.allowProfileViews,
                          allowDirectMessages: _preferences.allowDirectMessages,
                          showParticipationStats: value,
                          showAchievements: _preferences.showAchievements,
                          receiveEventNotifications: _preferences.receiveEventNotifications,
                          receivePrayerNotifications: _preferences.receivePrayerNotifications,
                          preferredLanguage: _preferences.preferredLanguage,
                          timezone: _preferences.timezone,
                        );
                      });
                    },
                  ),
                  
                  _buildSwitchTile(
                    title: 'Mostrar logros',
                    subtitle: 'Visible en tu perfil público',
                    value: _preferences.showAchievements,
                    auraColor: auraColor,
                    onChanged: (value) {
                      setState(() {
                        _preferences = PreferenceSettings(
                          allowProfileViews: _preferences.allowProfileViews,
                          allowDirectMessages: _preferences.allowDirectMessages,
                          showParticipationStats: _preferences.showParticipationStats,
                          showAchievements: value,
                          receiveEventNotifications: _preferences.receiveEventNotifications,
                          receivePrayerNotifications: _preferences.receivePrayerNotifications,
                          preferredLanguage: _preferences.preferredLanguage,
                          timezone: _preferences.timezone,
                        );
                      });
                    },
                  ),
                  
                  _buildSwitchTile(
                    title: 'Notificaciones de eventos',
                    subtitle: 'Recibir recordatorios de eventos',
                    value: _preferences.receiveEventNotifications,
                    auraColor: auraColor,
                    onChanged: (value) {
                      setState(() {
                        _preferences = PreferenceSettings(
                          allowProfileViews: _preferences.allowProfileViews,
                          allowDirectMessages: _preferences.allowDirectMessages,
                          showParticipationStats: _preferences.showParticipationStats,
                          showAchievements: _preferences.showAchievements,
                          receiveEventNotifications: value,
                          receivePrayerNotifications: _preferences.receivePrayerNotifications,
                          preferredLanguage: _preferences.preferredLanguage,
                          timezone: _preferences.timezone,
                        );
                      });
                    },
                  ),
                  
                  _buildSwitchTile(
                    title: 'Notificaciones de oración',
                    subtitle: 'Recibir recordatorios de oración',
                    value: _preferences.receivePrayerNotifications,
                    auraColor: auraColor,
                    onChanged: (value) {
                      setState(() {
                        _preferences = PreferenceSettings(
                          allowProfileViews: _preferences.allowProfileViews,
                          allowDirectMessages: _preferences.allowDirectMessages,
                          showParticipationStats: _preferences.showParticipationStats,
                          showAchievements: _preferences.showAchievements,
                          receiveEventNotifications: _preferences.receiveEventNotifications,
                          receivePrayerNotifications: value,
                          preferredLanguage: _preferences.preferredLanguage,
                          timezone: _preferences.timezone,
                        );
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImageSection(SpiritualProfile? profile, Color auraColor) {
    return GlowContainer(
      glowColor: auraColor,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1a1a1a),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: auraColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Text(
              'Foto de Perfil',
              style: TextStyle(
                color: auraColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Stack(
              children: [
                AnimatedBuilder(
                  animation: _glowAnimation,
                  builder: (context, child) {
                    return Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: auraColor.withOpacity(_glowAnimation.value * 0.8),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: auraColor.withOpacity(0.2),
                        backgroundImage: profile?.profileImageUrl != null
                            ? NetworkImage(profile!.profileImageUrl!)
                            : null,
                        child: profile?.profileImageUrl == null
                            ? Icon(
                                Icons.person,
                                size: 60,
                                color: auraColor,
                              )
                            : null,
                      ),
                    );
                  },
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () => _selectProfileImage(),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: auraColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: auraColor.withOpacity(0.5),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.black,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Toca el icono para cambiar la foto',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoverImageSection(SpiritualProfile? profile, Color auraColor) {
    return GlowContainer(
      glowColor: auraColor,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        height: 120,
        decoration: BoxDecoration(
          color: const Color(0xFF1a1a1a),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: auraColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Stack(
          children: [
            if (profile?.coverImageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.network(
                  profile!.coverImageUrl!,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      gradient: LinearGradient(
                        colors: [
                          auraColor.withOpacity(0.3),
                          auraColor.withOpacity(0.1),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            else
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  gradient: LinearGradient(
                    colors: [
                      auraColor.withOpacity(0.3),
                      auraColor.withOpacity(0.1),
                    ],
                  ),
                ),
              ),
            
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.5),
                  ],
                ),
              ),
            ),
            
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => _selectCoverImage(),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: auraColor.withOpacity(0.2),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: auraColor.withOpacity(0.5),
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        Icons.add_a_photo,
                        color: auraColor,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Imagen de Portada',
                    style: TextStyle(
                      color: auraColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Color auraColor,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: auraColor.withOpacity(0.8)),
        prefixIcon: Icon(icon, color: auraColor),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: auraColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: auraColor,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Colors.red,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Colors.red,
            width: 2,
          ),
        ),
        filled: true,
        fillColor: const Color(0xFF1a1a1a),
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? value,
    required IconData icon,
    required Color auraColor,
    required VoidCallback onTap,
    bool isRequired = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1a1a1a),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: auraColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: auraColor),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label + (isRequired ? ' *' : ''),
                    style: TextStyle(
                      color: auraColor.withOpacity(0.8),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value != null 
                        ? '${value.day}/${value.month}/${value.year}'
                        : 'Seleccionar fecha',
                    style: TextStyle(
                      color: value != null ? Colors.white : Colors.grey[400],
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.calendar_today,
              color: auraColor.withOpacity(0.6),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownField<T>({
    required String label,
    required T value,
    required IconData icon,
    required Color auraColor,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a1a),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: auraColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: auraColor),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonFormField<T>(
              value: value,
              onChanged: onChanged,
              decoration: InputDecoration(
                labelText: label,
                labelStyle: TextStyle(color: auraColor.withOpacity(0.8)),
                border: InputBorder.none,
              ),
              style: const TextStyle(color: Colors.white),
              dropdownColor: const Color(0xFF1a1a1a),
              items: items,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChipSection({
    required String title,
    required List<String> items,
    required IconData icon,
    required Color auraColor,
    required List<String> suggestions,
    required Function(String) onAdd,
    required Function(String) onRemove,
  }) {
    return GlowContainer(
      glowColor: auraColor,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1a1a1a),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: auraColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: auraColor, size: 20),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    color: auraColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Items actuales
            if (items.isNotEmpty) ...[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: items.map((item) {
                  return Chip(
                    label: Text(
                      item,
                      style: TextStyle(color: auraColor, fontSize: 12),
                    ),
                    backgroundColor: auraColor.withOpacity(0.2),
                    deleteIconColor: auraColor,
                    side: BorderSide(color: auraColor.withOpacity(0.5)),
                    onDeleted: () => onRemove(item),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],
            
            // Sugerencias
            Text(
              'Sugerencias:',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: suggestions.where((suggestion) => !items.contains(suggestion)).map((suggestion) {
                return GestureDetector(
                  onTap: () => onAdd(suggestion),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.grey[600]!,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add, color: Colors.grey[300], size: 16),
                        const SizedBox(width: 4),
                        Text(
                          suggestion,
                          style: TextStyle(
                            color: Colors.grey[300],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerseSection(Color auraColor) {
    final TextEditingController verseController = TextEditingController();
    
    return GlowContainer(
      glowColor: auraColor,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1a1a1a),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: auraColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.menu_book, color: auraColor, size: 20),
                const SizedBox(width: 12),
                Text(
                  'Versículos Favoritos',
                  style: TextStyle(
                    color: auraColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Versículos actuales
            if (_favoriteVerses.isNotEmpty) ...[
              ..._favoriteVerses.map((verse) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.format_quote,
                        color: auraColor.withOpacity(0.7),
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          verse,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red[400], size: 16),
                        onPressed: () {
                          setState(() {
                            _favoriteVerses.remove(verse);
                          });
                        },
                      ),
                    ],
                  ),
                );
              }).toList(),
              const SizedBox(height: 16),
            ],
            
            // Agregar nuevo versículo
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: verseController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Ej: Juan 3:16',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: auraColor.withOpacity(0.3)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: auraColor.withOpacity(0.3)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: auraColor),
                      ),
                      filled: true,
                      fillColor: Colors.grey[900],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    if (verseController.text.trim().isNotEmpty) {
                      setState(() {
                        _favoriteVerses.add(verseController.text.trim());
                        verseController.clear();
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: auraColor,
                    foregroundColor: Colors.black,
                  ),
                  child: const Text('Agregar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required Color auraColor,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: auraColor,
            activeTrackColor: auraColor.withOpacity(0.3),
            inactiveThumbColor: Colors.grey[400],
            inactiveTrackColor: Colors.grey[800],
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, DateTime? currentDate, Function(DateTime) onDateSelected) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: currentDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: context.read<AuraProvider>().currentAuraColor,
              surface: const Color(0xFF1a1a1a),
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      onDateSelected(picked);
    }
  }

  Future<void> _selectProfileImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 500,
        maxHeight: 500,
        imageQuality: 80,
      );
      
      if (image != null) {
        // En un entorno real, subirías la imagen a un servidor
        // Por ahora simulamos la URL
        final imageUrl = 'https://images.unsplash.com/photo-${DateTime.now().millisecondsSinceEpoch}?w=500';
        
        await context.read<SpiritualProfileProvider>().updateProfileImage(imageUrl);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Foto de perfil actualizada'),
            backgroundColor: context.read<AuraProvider>().currentAuraColor,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al seleccionar la imagen'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _selectCoverImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 600,
        imageQuality: 90,
      );
      
      if (image != null) {
        // En un entorno real, subirías la imagen a un servidor
        // Por ahora simulamos la URL
        final imageUrl = 'https://images.unsplash.com/photo-${DateTime.now().millisecondsSinceEpoch}?w=1200';
        
        await context.read<SpiritualProfileProvider>().updateCoverImage(imageUrl);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Imagen de portada actualizada'),
            backgroundColor: context.read<AuraProvider>().currentAuraColor,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al seleccionar la imagen'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor completa todos los campos requeridos'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_conversionDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La fecha de conversión es requerida'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final provider = context.read<SpiritualProfileProvider>();
      final currentProfile = provider.currentProfile;
      
      if (currentProfile != null) {
        final updatedProfile = currentProfile.copyWith(
          fullName: _fullNameController.text.trim(),
          email: _emailController.text.trim(),
          phoneNumber: _phoneController.text.trim().isNotEmpty ? _phoneController.text.trim() : null,
          birthDate: _birthDate,
          spiritualBio: _bioController.text.trim(),
          testimony: _testimonyController.text.trim(),
          conversionDate: _conversionDate!,
          baptismStatus: _baptismStatus,
          baptismDate: _baptismDate,
          baptismLocation: _baptismLocationController.text.trim().isNotEmpty ? _baptismLocationController.text.trim() : null,
          currentChurch: _currentChurchController.text.trim(),
          pastorName: _pastorNameController.text.trim().isNotEmpty ? _pastorNameController.text.trim() : null,
          maturityLevel: _maturityLevel,
          ministries: _ministries,
          spiritualGifts: _spiritualGifts,
          favoriteVerses: _favoriteVerses,
          preferences: _preferences,
          contactInfo: ContactInfo(
            address: _addressController.text.trim().isNotEmpty ? _addressController.text.trim() : null,
            city: _cityController.text.trim().isNotEmpty ? _cityController.text.trim() : null,
            country: currentProfile.contactInfo.country,
            homePhone: _homePhoneController.text.trim().isNotEmpty ? _homePhoneController.text.trim() : null,
            workPhone: _workPhoneController.text.trim().isNotEmpty ? _workPhoneController.text.trim() : null,
            socialMedia: currentProfile.contactInfo.socialMedia,
          ),
        );

        await provider.updateProfile(updatedProfile);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Perfil actualizado exitosamente'),
            backgroundColor: context.read<AuraProvider>().currentAuraColor,
          ),
        );

        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar el perfil: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}