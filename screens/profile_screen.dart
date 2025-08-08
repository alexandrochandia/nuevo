import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/spiritual_profile_provider.dart';
import '../providers/aura_provider.dart';
import '../models/spiritual_profile_model.dart';
import '../widgets/glow_container.dart';
import 'edit_profile_screen.dart';
import '../utils/glow_styles.dart';

class ProfileScreen extends StatefulWidget {
  final String? profileId;
  
  const ProfileScreen({super.key, this.profileId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<SpiritualProfileProvider, AuraProvider>(
      builder: (context, profileProvider, auraProvider, child) {
        final auraColor = auraProvider.currentAuraColor;
        
        // Determinar si es perfil propio o de otro usuario
        final isOwnProfile = widget.profileId == null;
        final profile = isOwnProfile 
            ? profileProvider.currentProfile
            : profileProvider.publicProfiles
                .where((p) => p.id == widget.profileId)
                .firstOrNull;

        if (profile == null) {
          return Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(
              backgroundColor: Colors.black,
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios, color: GlowStyles.neonBlue),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.person_off,
                    size: 80,
                    color: auraColor.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Perfil no encontrado',
                    style: TextStyle(
                      color: auraColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: Colors.black,
          body: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                _buildSliverAppBar(profile, auraColor, isOwnProfile),
              ];
            },
            body: Column(
              children: [
                _buildTabBar(auraColor),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildOverviewTab(profile, auraColor),
                      _buildTestimonyTab(profile, auraColor),
                      _buildParticipationTab(profile, auraColor),
                      _buildAchievementsTab(profile, auraColor),
                      _buildPrayerTab(profile, auraColor),
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

  Widget _buildSliverAppBar(SpiritualProfile profile, Color auraColor, bool isOwnProfile) {
    return SliverAppBar(
      expandedHeight: 300,
      floating: false,
      pinned: true,
      backgroundColor: Colors.black,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios, color: auraColor),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        if (isOwnProfile)
          IconButton(
            icon: Icon(Icons.edit, color: auraColor),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const EditProfileScreen(),
              ),
            ),
          ),
        PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: auraColor),
          color: const Color(0xFF1a1a1a),
          onSelected: (value) {
            switch (value) {
              case 'share':
                _shareProfile(profile);
                break;
              case 'message':
                _sendMessage(profile);
                break;
              case 'report':
                _reportProfile(profile);
                break;
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'share',
              child: Row(
                children: [
                  Icon(Icons.share, color: auraColor, size: 20),
                  const SizedBox(width: 12),
                  const Text('Compartir', style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
            if (!isOwnProfile && profile.allowDirectMessages)
              PopupMenuItem(
                value: 'message',
                child: Row(
                  children: [
                    Icon(Icons.message, color: auraColor, size: 20),
                    const SizedBox(width: 12),
                    const Text('Mensaje', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            if (!isOwnProfile)
              PopupMenuItem(
                value: 'report',
                child: Row(
                  children: [
                    Icon(Icons.report, color: Colors.red[400], size: 20),
                    const SizedBox(width: 12),
                    Text('Reportar', style: TextStyle(color: Colors.red[400])),
                  ],
                ),
              ),
          ],
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Cover Image
            if (profile.coverImageUrl != null)
              Image.network(
                profile.coverImageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        auraColor.withOpacity(0.3),
                        Colors.black.withOpacity(0.8),
                      ],
                    ),
                  ),
                ),
              )
            else
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      auraColor.withOpacity(0.3),
                      Colors.black.withOpacity(0.8),
                    ],
                  ),
                ),
              ),
            
            // Gradient Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
            
            // Profile Content
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Row(
                children: [
                  // Profile Image
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
                          radius: 50,
                          backgroundColor: auraColor.withOpacity(0.2),
                          backgroundImage: profile.profileImageUrl != null
                              ? NetworkImage(profile.profileImageUrl!)
                              : null,
                          child: profile.profileImageUrl == null
                              ? Icon(
                                  Icons.person,
                                  size: 50,
                                  color: auraColor,
                                )
                              : null,
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(width: 20),
                  
                  // Profile Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profile.fullName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        
                        const SizedBox(height: 4),
                        
                        Row(
                          children: [
                            Icon(
                              profile.maturityLevel.icon,
                              color: profile.maturityLevel.color,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              profile.maturityLevel.displayName,
                              style: TextStyle(
                                color: profile.maturityLevel.color,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 4),
                        
                        Text(
                          profile.currentChurch,
                          style: TextStyle(
                            color: auraColor,
                            fontSize: 14,
                          ),
                        ),
                        
                        const SizedBox(height: 8),
                        
                        Row(
                          children: [
                            _buildStatChip('${profile.participationStats.values.fold(0, (sum, count) => sum + count)}', 'Participaciones', auraColor),
                            const SizedBox(width: 12),
                            _buildStatChip('${profile.achievements.length}', 'Logros', auraColor),
                          ],
                        ),
                      ],
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

  Widget _buildStatChip(String value, String label, Color auraColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: auraColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: auraColor.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: auraColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: auraColor.withOpacity(0.8),
              fontSize: 10,
            ),
          ),
        ],
      ),
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
          Tab(text: 'Resumen'),
          Tab(text: 'Testimonio'),
          Tab(text: 'Participación'),
          Tab(text: 'Logros'),
          Tab(text: 'Oración'),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(SpiritualProfile profile, Color auraColor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bio Espiritual
          _buildSection(
            'Biografía Espiritual',
            profile.spiritualBio,
            Icons.person,
            auraColor,
          ),
          
          const SizedBox(height: 20),
          
          // Información de Bautismo
          _buildBaptismInfo(profile, auraColor),
          
          const SizedBox(height: 20),
          
          // Ministerios
          _buildMinistries(profile, auraColor),
          
          const SizedBox(height: 20),
          
          // Dones Espirituales
          _buildSpiritualGifts(profile, auraColor),
          
          const SizedBox(height: 20),
          
          // Versículos Favoritos
          _buildFavoriteVerses(profile, auraColor),
          
          const SizedBox(height: 20),
          
          // Información de Contacto (solo perfil propio)
          if (widget.profileId == null)
            _buildContactInfo(profile, auraColor),
        ],
      ),
    );
  }

  Widget _buildTestimonyTab(SpiritualProfile profile, Color auraColor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                  Row(
                    children: [
                      Icon(Icons.auto_stories, color: auraColor, size: 24),
                      const SizedBox(width: 12),
                      Text(
                        'Mi Testimonio',
                        style: TextStyle(
                          color: auraColor,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Icon(Icons.calendar_today, color: auraColor.withOpacity(0.7), size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'Conversión: ${_formatDate(profile.conversionDate)}',
                        style: TextStyle(
                          color: auraColor.withOpacity(0.7),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  Text(
                    profile.testimony,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParticipationTab(SpiritualProfile profile, Color auraColor) {
    final stats = context.read<SpiritualProfileProvider>().getParticipationStatistics();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Estadísticas Generales
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total',
                  '${stats['total'] ?? 0}',
                  'Actividades',
                  auraColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Último Mes',
                  '${stats['recent30Days'] ?? 0}',
                  'Participaciones',
                  auraColor,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Estadísticas por Tipo
          _buildParticipationByType(profile, auraColor),
          
          const SizedBox(height: 20),
          
          // Historial Reciente
          _buildRecentParticipation(profile, auraColor),
        ],
      ),
    );
  }

  Widget _buildAchievementsTab(SpiritualProfile profile, Color auraColor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: profile.achievements.isEmpty
            ? [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.emoji_events,
                        size: 80,
                        color: auraColor.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Sin logros aún',
                        style: TextStyle(
                          color: auraColor,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Participa en actividades para ganar logros',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ]
            : profile.achievements.map((achievement) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildAchievementCard(achievement, auraColor),
                );
              }).toList(),
      ),
    );
  }

  Widget _buildPrayerTab(SpiritualProfile profile, Color auraColor) {
    final publicRequests = profile.prayerRequests.where((r) => r.isPublic).toList();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: publicRequests.isEmpty
            ? [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.church,
                        size: 80,
                        color: auraColor.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Sin peticiones públicas',
                        style: TextStyle(
                          color: auraColor,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Las peticiones de oración aparecerán aquí',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ]
            : publicRequests.map((request) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildPrayerRequestCard(request, auraColor),
                );
              }).toList(),
      ),
    );
  }

  Widget _buildSection(String title, String content, IconData icon, Color auraColor) {
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
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              content,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBaptismInfo(SpiritualProfile profile, Color auraColor) {
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
                Icon(Icons.water_drop, color: auraColor, size: 20),
                const SizedBox(width: 12),
                Text(
                  'Información de Bautismo',
                  style: TextStyle(
                    color: auraColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: profile.baptismStatus.color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: profile.baptismStatus.color.withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    profile.baptismStatus.displayName,
                    style: TextStyle(
                      color: profile.baptismStatus.color,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            if (profile.baptismDate != null) ...[
              const SizedBox(height: 12),
              Text(
                'Fecha: ${_formatDate(profile.baptismDate!)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
            ],
            if (profile.baptismLocation != null) ...[
              const SizedBox(height: 8),
              Text(
                'Lugar: ${profile.baptismLocation}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMinistries(SpiritualProfile profile, Color auraColor) {
    if (profile.ministries.isEmpty) return const SizedBox.shrink();
    
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
                Icon(Icons.volunteer_activism, color: auraColor, size: 20),
                const SizedBox(width: 12),
                Text(
                  'Ministerios',
                  style: TextStyle(
                    color: auraColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: profile.ministries.map((ministry) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: auraColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: auraColor.withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    ministry,
                    style: TextStyle(
                      color: auraColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
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

  Widget _buildSpiritualGifts(SpiritualProfile profile, Color auraColor) {
    if (profile.spiritualGifts.isEmpty) return const SizedBox.shrink();
    
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
                Icon(Icons.card_giftcard, color: auraColor, size: 20),
                const SizedBox(width: 12),
                Text(
                  'Dones Espirituales',
                  style: TextStyle(
                    color: auraColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: profile.spiritualGifts.map((gift) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: auraColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: auraColor.withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    gift,
                    style: TextStyle(
                      color: auraColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
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

  Widget _buildFavoriteVerses(SpiritualProfile profile, Color auraColor) {
    if (profile.favoriteVerses.isEmpty) return const SizedBox.shrink();
    
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
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...profile.favoriteVerses.map((verse) {
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
                          fontSize: 15,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildContactInfo(SpiritualProfile profile, Color auraColor) {
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
                Icon(Icons.contact_mail, color: auraColor, size: 20),
                const SizedBox(width: 12),
                Text(
                  'Información de Contacto',
                  style: TextStyle(
                    color: auraColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (profile.contactInfo.city != null) ...[
              Row(
                children: [
                  Icon(Icons.location_city, color: auraColor.withOpacity(0.7), size: 16),
                  const SizedBox(width: 8),
                  Text(
                    '${profile.contactInfo.city}, ${profile.contactInfo.country ?? 'Suecia'}',
                    style: const TextStyle(color: Colors.white, fontSize: 15),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            Row(
              children: [
                Icon(Icons.email, color: auraColor.withOpacity(0.7), size: 16),
                const SizedBox(width: 8),
                Text(
                  profile.email,
                  style: const TextStyle(color: Colors.white, fontSize: 15),
                ),
              ],
            ),
            if (profile.phoneNumber != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.phone, color: auraColor.withOpacity(0.7), size: 16),
                  const SizedBox(width: 8),
                  Text(
                    profile.phoneNumber!,
                    style: const TextStyle(color: Colors.white, fontSize: 15),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, String subtitle, Color auraColor) {
    return GlowContainer(
      glowColor: auraColor,
      borderRadius: BorderRadius.circular(12),
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
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                color: auraColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              subtitle,
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

  Widget _buildParticipationByType(SpiritualProfile profile, Color auraColor) {
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
            Text(
              'Participación por Tipo',
              style: TextStyle(
                color: auraColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...profile.participationStats.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      entry.key,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: auraColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        entry.value.toString(),
                        style: TextStyle(
                          color: auraColor,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentParticipation(SpiritualProfile profile, Color auraColor) {
    final recentRecords = profile.participationHistory.take(5).toList();
    
    if (recentRecords.isEmpty) {
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
          child: Center(
            child: Text(
              'Sin participaciones registradas',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
              ),
            ),
          ),
        ),
      );
    }
    
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
            Text(
              'Participación Reciente',
              style: TextStyle(
                color: auraColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...recentRecords.map((record) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Icon(
                      record.attended ? Icons.check_circle : Icons.cancel,
                      color: record.attended ? Colors.green : Colors.red,
                      size: 16,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            record.activityName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            _formatDate(record.date),
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (record.role != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: auraColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          record.role!,
                          style: TextStyle(
                            color: auraColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementCard(Achievement achievement, Color auraColor) {
    return GlowContainer(
      glowColor: achievement.color,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1a1a1a),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: achievement.color.withOpacity(0.5),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: achievement.color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                achievement.icon,
                style: const TextStyle(fontSize: 24),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    achievement.title,
                    style: TextStyle(
                      color: achievement.color,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    achievement.description,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: achievement.color.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${achievement.points} puntos',
                          style: TextStyle(
                            color: achievement.color,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _formatDate(achievement.earnedDate),
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrayerRequestCard(PrayerRequest request, Color auraColor) {
    return GlowContainer(
      glowColor: request.status.color,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1a1a1a),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: request.status.color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(request.category.icon, color: auraColor, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    request.title,
                    style: TextStyle(
                      color: auraColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: request.status.color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    request.status.displayName,
                    style: TextStyle(
                      color: request.status.color,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              request.description,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            if (request.status == PrayerStatus.answered && request.answerDescription != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.green.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'Respuesta de Dios:',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      request.answerDescription!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            Row(
              children: [
                Icon(Icons.calendar_today, color: Colors.grey[400], size: 14),
                const SizedBox(width: 6),
                Text(
                  _formatDate(request.createdAt),
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: auraColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    request.category.displayName,
                    style: TextStyle(
                      color: auraColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _shareProfile(SpiritualProfile profile) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Compartiendo perfil de ${profile.fullName}'),
        backgroundColor: context.read<AuraProvider>().currentAuraColor,
      ),
    );
  }

  void _sendMessage(SpiritualProfile profile) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Enviando mensaje a ${profile.fullName}'),
        backgroundColor: context.read<AuraProvider>().currentAuraColor,
      ),
    );
  }

  void _reportProfile(SpiritualProfile profile) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a1a),
        title: const Text('Reportar Perfil', style: TextStyle(color: Colors.white)),
        content: const Text(
          '¿Estás seguro de que quieres reportar este perfil?',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Perfil reportado. Gracias por tu feedback.'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text('Reportar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}