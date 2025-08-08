import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/spiritual_profile_model.dart';

class SpiritualProfileProvider with ChangeNotifier {
  SpiritualProfile? _currentProfile;
  List<SpiritualProfile> _publicProfiles = [];
  bool _isLoading = false;
  String _error = '';

  SpiritualProfile? get currentProfile => _currentProfile;
  List<SpiritualProfile> get publicProfiles => _publicProfiles;
  bool get isLoading => _isLoading;
  String get error => _error;

  SpiritualProfileProvider() {
    _loadCurrentProfile();
    _loadPublicProfiles();
  }

  // Carga el perfil del usuario actual
  Future<void> _loadCurrentProfile() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final profileJson = prefs.getString('spiritual_profile');
      
      if (profileJson != null) {
        _currentProfile = SpiritualProfile.fromJson(jsonDecode(profileJson));
      } else {
        // Crear perfil por defecto si no existe
        _currentProfile = _createDefaultProfile();
        await _saveCurrentProfile();
      }
    } catch (e) {
      _error = 'Error al cargar el perfil: $e';
      _currentProfile = _createDefaultProfile();
    }

    _isLoading = false;
    notifyListeners();
  }

  // Carga perfiles públicos de otros miembros
  Future<void> _loadPublicProfiles() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final profilesJson = prefs.getStringList('public_profiles') ?? [];
      
      if (profilesJson.isEmpty) {
        _publicProfiles = _generateMockPublicProfiles();
        await _savePublicProfiles();
      } else {
        _publicProfiles = profilesJson
            .map((json) => SpiritualProfile.fromJson(jsonDecode(json)))
            .toList();
      }
    } catch (e) {
      _error = 'Error al cargar perfiles públicos: $e';
      _publicProfiles = _generateMockPublicProfiles();
    }
    notifyListeners();
  }

  // Guarda el perfil actual
  Future<void> _saveCurrentProfile() async {
    if (_currentProfile == null) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final profileJson = jsonEncode(_currentProfile!.toJson());
      await prefs.setString('spiritual_profile', profileJson);
    } catch (e) {
      _error = 'Error al guardar el perfil: $e';
      notifyListeners();
    }
  }

  // Guarda perfiles públicos
  Future<void> _savePublicProfiles() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final profilesJson = _publicProfiles
          .map((profile) => jsonEncode(profile.toJson()))
          .toList();
      await prefs.setStringList('public_profiles', profilesJson);
    } catch (e) {
      _error = 'Error al guardar perfiles públicos: $e';
      notifyListeners();
    }
  }

  // Actualiza el perfil actual
  Future<void> updateProfile(SpiritualProfile updatedProfile) async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentProfile = updatedProfile.copyWith(
        updatedAt: DateTime.now(),
      );
      await _saveCurrentProfile();
      _error = '';
    } catch (e) {
      _error = 'Error al actualizar el perfil: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  // Actualiza la imagen de perfil
  Future<void> updateProfileImage(String imageUrl) async {
    if (_currentProfile == null) return;

    await updateProfile(_currentProfile!.copyWith(
      profileImageUrl: imageUrl,
    ));
  }

  // Actualiza la imagen de portada
  Future<void> updateCoverImage(String imageUrl) async {
    if (_currentProfile == null) return;

    await updateProfile(_currentProfile!.copyWith(
      coverImageUrl: imageUrl,
    ));
  }

  // Agrega un registro de participación
  Future<void> addParticipationRecord(ParticipationRecord record) async {
    if (_currentProfile == null) return;

    final updatedHistory = List<ParticipationRecord>.from(_currentProfile!.participationHistory);
    updatedHistory.insert(0, record);

    // Actualizar estadísticas
    final updatedStats = Map<String, int>.from(_currentProfile!.participationStats);
    updatedStats[record.activityType] = (updatedStats[record.activityType] ?? 0) + 1;

    await updateProfile(_currentProfile!.copyWith(
      participationHistory: updatedHistory,
      participationStats: updatedStats,
    ));

    // Verificar logros
    _checkAchievements();
  }

  // Agrega una solicitud de oración
  Future<void> addPrayerRequest(PrayerRequest request) async {
    if (_currentProfile == null) return;

    final updatedRequests = List<PrayerRequest>.from(_currentProfile!.prayerRequests);
    updatedRequests.insert(0, request);

    await updateProfile(_currentProfile!.copyWith(
      prayerRequests: updatedRequests,
    ));
  }

  // Marca una solicitud de oración como respondida
  Future<void> markPrayerRequestAnswered(String requestId, String answer) async {
    if (_currentProfile == null) return;

    final updatedRequests = _currentProfile!.prayerRequests.map((request) {
      if (request.id == requestId) {
        return PrayerRequest(
          id: request.id,
          title: request.title,
          description: request.description,
          category: request.category,
          status: PrayerStatus.answered,
          isPublic: request.isPublic,
          createdAt: request.createdAt,
          answeredAt: DateTime.now(),
          answerDescription: answer,
        );
      }
      return request;
    }).toList();

    await updateProfile(_currentProfile!.copyWith(
      prayerRequests: updatedRequests,
    ));
  }

  // Actualiza configuraciones de privacidad
  Future<void> updatePreferences(PreferenceSettings preferences) async {
    if (_currentProfile == null) return;

    await updateProfile(_currentProfile!.copyWith(
      preferences: preferences,
    ));
  }

  // Verifica y otorga logros
  void _checkAchievements() {
    if (_currentProfile == null) return;

    final achievements = List<Achievement>.from(_currentProfile!.achievements);
    final stats = _currentProfile!.participationStats;
    final now = DateTime.now();

    // Logro: Primera participación
    if (stats.isNotEmpty && !achievements.any((a) => a.id == 'first_participation')) {
      achievements.add(Achievement(
        id: 'first_participation',
        title: 'Primera Participación',
        description: 'Has participado en tu primera actividad de la iglesia',
        icon: '🎉',
        color: const Color(0xFF28a745),
        earnedDate: now,
        category: 'Participación',
        points: 10,
      ));
    }

    // Logro: Participación regular (10 actividades)
    final totalParticipation = stats.values.fold(0, (sum, count) => sum + count);
    if (totalParticipation >= 10 && !achievements.any((a) => a.id == 'regular_participant')) {
      achievements.add(Achievement(
        id: 'regular_participant',
        title: 'Participante Regular',
        description: 'Has participado en 10 actividades de la iglesia',
        icon: '⭐',
        color: const Color(0xFF17a2b8),
        earnedDate: now,
        category: 'Participación',
        points: 50,
      ));
    }

    // Logro: Dedicado (50 actividades)
    if (totalParticipation >= 50 && !achievements.any((a) => a.id == 'dedicated_member')) {
      achievements.add(Achievement(
        id: 'dedicated_member',
        title: 'Miembro Dedicado',
        description: 'Has participado en 50 actividades de la iglesia',
        icon: '🏆',
        color: const Color(0xFFffd700),
        earnedDate: now,
        category: 'Participación',
        points: 100,
      ));
    }

    // Logro: Testimonio compartido
    if (_currentProfile!.testimony.isNotEmpty && 
        !achievements.any((a) => a.id == 'testimony_shared')) {
      achievements.add(Achievement(
        id: 'testimony_shared',
        title: 'Testimonio Compartido',
        description: 'Has compartido tu testimonio de fe',
        icon: '💬',
        color: const Color(0xFF9b59b6),
        earnedDate: now,
        category: 'Testimonio',
        points: 25,
      ));
    }

    // Logro: Oración activa (5 peticiones)
    if (_currentProfile!.prayerRequests.length >= 5 && 
        !achievements.any((a) => a.id == 'prayer_warrior')) {
      achievements.add(Achievement(
        id: 'prayer_warrior',
        title: 'Guerrero de Oración',
        description: 'Has creado 5 peticiones de oración',
        icon: '🙏',
        color: const Color(0xFFe91e63),
        earnedDate: now,
        category: 'Oración',
        points: 30,
      ));
    }

    if (achievements.length != _currentProfile!.achievements.length) {
      updateProfile(_currentProfile!.copyWith(achievements: achievements));
    }
  }

  // Obtiene estadísticas de participación
  Map<String, dynamic> getParticipationStatistics() {
    if (_currentProfile == null) return {};

    final stats = _currentProfile!.participationStats;
    final total = stats.values.fold(0, (sum, count) => sum + count);
    final history = _currentProfile!.participationHistory;
    
    // Actividades en los últimos 30 días
    final recent = history.where((record) => 
      DateTime.now().difference(record.date).inDays <= 30).length;

    // Promedio mensual
    final memberDays = DateTime.now().difference(_currentProfile!.memberSince).inDays;
    final averageMonthly = memberDays > 30 ? (total / (memberDays / 30)).round() : total;

    return {
      'total': total,
      'recent30Days': recent,
      'averageMonthly': averageMonthly,
      'byType': stats,
      'achievements': _currentProfile!.achievements.length,
      'prayerRequests': _currentProfile!.prayerRequests.length,
    };
  }

  // Busca perfiles públicos
  List<SpiritualProfile> searchProfiles(String query) {
    if (query.isEmpty) return _publicProfiles;

    return _publicProfiles.where((profile) {
      final searchText = query.toLowerCase();
      return profile.fullName.toLowerCase().contains(searchText) ||
             profile.currentChurch.toLowerCase().contains(searchText) ||
             profile.ministries.any((ministry) => 
               ministry.toLowerCase().contains(searchText)) ||
             profile.spiritualGifts.any((gift) => 
               gift.toLowerCase().contains(searchText));
    }).toList();
  }

  // Filtra perfiles por ministerio
  List<SpiritualProfile> getProfilesByMinistry(String ministry) {
    return _publicProfiles.where((profile) =>
      profile.ministries.contains(ministry)).toList();
  }

  // Filtra perfiles por iglesia
  List<SpiritualProfile> getProfilesByChurch(String church) {
    return _publicProfiles.where((profile) =>
      profile.currentChurch == church).toList();
  }

  // Obtiene perfiles recientes
  List<SpiritualProfile> getRecentProfiles({int limit = 5}) {
    final sorted = List<SpiritualProfile>.from(_publicProfiles);
    sorted.sort((a, b) => b.lastActive.compareTo(a.lastActive));
    return sorted.take(limit).toList();
  }

  // Actualiza la última actividad
  Future<void> updateLastActivity() async {
    if (_currentProfile == null) return;

    await updateProfile(_currentProfile!.copyWith(
      lastActive: DateTime.now(),
    ));
  }

  // Refresca los datos
  Future<void> refresh() async {
    await _loadCurrentProfile();
    await _loadPublicProfiles();
  }

  // Crea un perfil por defecto
  SpiritualProfile _createDefaultProfile() {
    final now = DateTime.now();
    return SpiritualProfile(
      id: 'profile_${now.millisecondsSinceEpoch}',
      userId: 'user_current',
      fullName: 'Mi Nombre',
      email: 'mi.email@vmfsweden.org',
      spiritualBio: 'Comparte un poco sobre tu vida espiritual y tu relación con Dios...',
      testimony: 'Comparte tu testimonio de cómo conociste a Jesús...',
      conversionDate: now.subtract(const Duration(days: 365)),
      memberSince: now.subtract(const Duration(days: 180)),
      baptismStatus: BaptismStatus.notBaptized,
      currentChurch: 'VMF Sweden - Estocolmo',
      maturityLevel: SpiritualMaturity.newBeliever,
      participationHistory: [],
      participationStats: {},
      achievements: [],
      prayerRequests: [],
      preferences: PreferenceSettings(),
      contactInfo: ContactInfo(
        city: 'Estocolmo',
        country: 'Suecia',
      ),
      lastActive: now,
      updatedAt: now,
    );
  }

  // Genera perfiles públicos de prueba
  List<SpiritualProfile> _generateMockPublicProfiles() {
    final now = DateTime.now();
    
    return [
      SpiritualProfile(
        id: 'profile_1',
        userId: 'user_1',
        fullName: 'Anders Eriksson',
        email: 'anders.eriksson@vmfsweden.org',
        profileImageUrl: 'https://images.unsplash.com/photo-1560250097-0b93528c311a?w=200',
        spiritualBio: 'Pastor principal de VMF Sweden. Amo servir a Dios y ayudar a las familias a crecer en la fe.',
        testimony: 'Conocí a Jesús hace 25 años en una conferencia juvenil. Desde entonces mi vida ha sido transformada completamente.',
        conversionDate: DateTime(1999, 5, 15),
        memberSince: DateTime(2005, 1, 10),
        baptismStatus: BaptismStatus.baptized,
        baptismDate: DateTime(1999, 8, 20),
        baptismLocation: 'Iglesia Central de Gotemburgo',
        ministries: ['Pastoral', 'Predicación', 'Consejería'],
        spiritualGifts: ['Enseñanza', 'Liderazgo', 'Palabra de sabiduría'],
        favoriteVerses: [
          'Jeremías 29:11',
          'Filipenses 4:13',
          'Romanos 8:28'
        ],
        currentChurch: 'VMF Sweden - Estocolmo',
        pastorName: 'Autoliderazgo',
        maturityLevel: SpiritualMaturity.elder,
        participationHistory: _generateParticipationHistory(50),
        participationStats: {
          'Culto': 200,
          'Estudio Bíblico': 150,
          'Oración': 180,
          'Evangelismo': 45,
          'Conferencia': 30,
        },
        achievements: _generateAchievements(),
        prayerRequests: [],
        preferences: PreferenceSettings(),
        contactInfo: ContactInfo(
          city: 'Estocolmo',
          country: 'Suecia',
          homePhone: '+46 8 123 456',
        ),
        lastActive: now.subtract(const Duration(hours: 2)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
      
      SpiritualProfile(
        id: 'profile_2',
        userId: 'user_2',
        fullName: 'Margareta Lindström',
        email: 'margareta.lindstrom@vmfsweden.org',
        profileImageUrl: 'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=200',
        spiritualBio: 'Pastora asociada y líder del ministerio de mujeres. Apasionada por el discipulado y la oración.',
        testimony: 'Dios me llamó al ministerio después de una experiencia profunda en oración. He visto Su fidelidad una y otra vez.',
        conversionDate: DateTime(2003, 3, 12),
        memberSince: DateTime(2008, 9, 15),
        baptismStatus: BaptismStatus.baptized,
        baptismDate: DateTime(2003, 7, 8),
        baptismLocation: 'VMF Sweden - Gotemburgo',
        ministries: ['Pastoral', 'Ministerio Femenino', 'Oración'],
        spiritualGifts: ['Intercesión', 'Enseñanza', 'Discernimiento'],
        favoriteVerses: [
          'Salmo 46:10',
          '1 Pedro 5:7',
          'Isaías 40:31'
        ],
        currentChurch: 'VMF Sweden - Estocolmo',
        pastorName: 'Anders Eriksson',
        maturityLevel: SpiritualMaturity.leader,
        participationHistory: _generateParticipationHistory(35),
        participationStats: {
          'Culto': 150,
          'Oración': 200,
          'Estudio Bíblico': 120,
          'Ministerio Femenino': 80,
          'Conferencia': 25,
        },
        achievements: _generateAchievements().take(4).toList(),
        prayerRequests: _generatePrayerRequests(),
        preferences: PreferenceSettings(),
        contactInfo: ContactInfo(
          city: 'Estocolmo',
          country: 'Suecia',
        ),
        lastActive: now.subtract(const Duration(hours: 5)),
        updatedAt: now.subtract(const Duration(days: 2)),
      ),

      SpiritualProfile(
        id: 'profile_3',
        userId: 'user_3',
        fullName: 'Erik Johansson',
        email: 'erik.johansson@vmfsweden.org',
        profileImageUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200',
        spiritualBio: 'Líder de jóvenes con corazón para la nueva generación. Músico y adorador apasionado.',
        testimony: 'Era rebelde en mi juventud, pero Dios me alcanzó a través de la música cristiana y transformó mi vida.',
        conversionDate: DateTime(2015, 11, 22),
        memberSince: DateTime(2016, 6, 10),
        baptismStatus: BaptismStatus.baptized,
        baptismDate: DateTime(2016, 1, 15),
        baptismLocation: 'VMF Sweden - Estocolmo',
        ministries: ['Ministerio Juvenil', 'Música', 'Adoración'],
        spiritualGifts: ['Música', 'Evangelismo', 'Liderazgo'],
        favoriteVerses: [
          'Salmo 150:6',
          'Mateo 28:19',
          '2 Timoteo 1:7'
        ],
        currentChurch: 'VMF Sweden - Estocolmo',
        pastorName: 'Anders Eriksson',
        maturityLevel: SpiritualMaturity.growing,
        participationHistory: _generateParticipationHistory(25),
        participationStats: {
          'Culto': 100,
          'Ministerio Juvenil': 90,
          'Música': 120,
          'Estudio Bíblico': 60,
          'Evangelismo': 35,
        },
        achievements: _generateAchievements().take(3).toList(),
        prayerRequests: [],
        preferences: PreferenceSettings(),
        contactInfo: ContactInfo(
          city: 'Estocolmo',
          country: 'Suecia',
        ),
        lastActive: now.subtract(const Duration(hours: 1)),
        updatedAt: now.subtract(const Duration(hours: 12)),
      ),

      SpiritualProfile(
        id: 'profile_4',
        userId: 'user_4',
        fullName: 'Sofia Andersson',
        email: 'sofia.andersson@vmfsweden.org',
        profileImageUrl: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=200',
        spiritualBio: 'Madre de familia y líder de célula. Me encanta enseñar a los niños sobre el amor de Jesús.',
        testimony: 'Dios me dio una segunda oportunidad cuando más lo necesitaba. Ahora vivo para servirle a Él y a mi familia.',
        conversionDate: DateTime(2018, 4, 7),
        memberSince: DateTime(2019, 1, 20),
        baptismStatus: BaptismStatus.baptized,
        baptismDate: DateTime(2018, 9, 16),
        baptismLocation: 'VMF Sweden - Malmö',
        ministries: ['Ministerio Infantil', 'Células', 'Hospitalidad'],
        spiritualGifts: ['Enseñanza', 'Hospitalidad', 'Servicio'],
        favoriteVerses: [
          'Mateo 19:14',
          'Proverbios 31:25',
          'Gálatas 5:22-23'
        ],
        currentChurch: 'VMF Sweden - Malmö',
        pastorName: 'Lars Andersson',
        maturityLevel: SpiritualMaturity.mature,
        participationHistory: _generateParticipationHistory(20),
        participationStats: {
          'Culto': 80,
          'Ministerio Infantil': 75,
          'Células': 60,
          'Estudio Bíblico': 45,
          'Conferencia': 15,
        },
        achievements: _generateAchievements().take(2).toList(),
        prayerRequests: _generatePrayerRequests().take(2).toList(),
        preferences: PreferenceSettings(),
        contactInfo: ContactInfo(
          city: 'Malmö',
          country: 'Suecia',
        ),
        lastActive: now.subtract(const Duration(days: 1)),
        updatedAt: now.subtract(const Duration(days: 3)),
      ),
    ];
  }

  // Genera historial de participación de prueba
  List<ParticipationRecord> _generateParticipationHistory(int count) {
    final records = <ParticipationRecord>[];
    final activities = [
      'Culto Dominical',
      'Estudio Bíblico',
      'Reunión de Oración',
      'Conferencia',
      'Retiro Espiritual',
      'Evangelismo',
      'Ministerio Juvenil',
      'Ministerio Infantil',
    ];
    
    final locations = [
      'VMF Sweden - Estocolmo',
      'VMF Sweden - Gotemburgo',
      'VMF Sweden - Malmö',
      'Centro de Conferencias',
      'Casa de Familia',
    ];

    for (int i = 0; i < count; i++) {
      final activity = activities[i % activities.length];
      records.add(ParticipationRecord(
        id: 'record_$i',
        activityType: activity.split(' ').first,
        activityName: activity,
        date: DateTime.now().subtract(Duration(days: i * 7)),
        location: locations[i % locations.length],
        attended: i % 10 != 0, // 90% asistencia
        role: i % 5 == 0 ? 'Líder' : 'Participante',
        notes: i % 3 == 0 ? 'Experiencia transformadora' : null,
      ));
    }

    return records;
  }

  // Genera logros de prueba
  List<Achievement> _generateAchievements() {
    return [
      Achievement(
        id: 'first_participation',
        title: 'Primera Participación',
        description: 'Has participado en tu primera actividad',
        icon: '🎉',
        color: const Color(0xFF28a745),
        earnedDate: DateTime.now().subtract(const Duration(days: 100)),
        category: 'Participación',
        points: 10,
      ),
      Achievement(
        id: 'regular_participant',
        title: 'Participante Regular',
        description: 'Has participado en 10 actividades',
        icon: '⭐',
        color: const Color(0xFF17a2b8),
        earnedDate: DateTime.now().subtract(const Duration(days: 50)),
        category: 'Participación',
        points: 50,
      ),
      Achievement(
        id: 'testimony_shared',
        title: 'Testimonio Compartido',
        description: 'Has compartido tu testimonio de fe',
        icon: '💬',
        color: const Color(0xFF9b59b6),
        earnedDate: DateTime.now().subtract(const Duration(days: 30)),
        category: 'Testimonio',
        points: 25,
      ),
      Achievement(
        id: 'prayer_warrior',
        title: 'Guerrero de Oración',
        description: 'Has creado 5 peticiones de oración',
        icon: '🙏',
        color: const Color(0xFFe91e63),
        earnedDate: DateTime.now().subtract(const Duration(days: 20)),
        category: 'Oración',
        points: 30,
      ),
      Achievement(
        id: 'dedicated_member',
        title: 'Miembro Dedicado',
        description: 'Has participado en 50 actividades',
        icon: '🏆',
        color: const Color(0xFFffd700),
        earnedDate: DateTime.now().subtract(const Duration(days: 10)),
        category: 'Participación',
        points: 100,
      ),
    ];
  }

  // Genera peticiones de oración de prueba
  List<PrayerRequest> _generatePrayerRequests() {
    return [
      PrayerRequest(
        id: 'prayer_1',
        title: 'Por mi familia',
        description: 'Oro para que mis familiares no creyentes conozcan a Jesús',
        category: PrayerCategory.family,
        status: PrayerStatus.active,
        isPublic: true,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
      PrayerRequest(
        id: 'prayer_2',
        title: 'Sabiduría en el ministerio',
        description: 'Necesito dirección de Dios para las decisiones importantes',
        category: PrayerCategory.ministry,
        status: PrayerStatus.ongoing,
        isPublic: true,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      PrayerRequest(
        id: 'prayer_3',
        title: 'Salud y fortaleza',
        description: 'Agradezco a Dios por la sanidad recibida',
        category: PrayerCategory.thanksgiving,
        status: PrayerStatus.answered,
        isPublic: true,
        createdAt: DateTime.now().subtract(const Duration(days: 45)),
        answeredAt: DateTime.now().subtract(const Duration(days: 10)),
        answerDescription: 'Dios me ha dado completa sanidad. ¡Aleluya!',
      ),
    ];
  }
}