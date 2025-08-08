
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/study_group_model.dart';
import '../providers/study_groups_provider.dart';
import '../widgets/glow_container.dart';

class StudyGroupDetailScreen extends StatefulWidget {
  final StudyGroup group;

  const StudyGroupDetailScreen({
    Key? key,
    required this.group,
  }) : super(key: key);

  @override
  State<StudyGroupDetailScreen> createState() => _StudyGroupDetailScreenState();
}

class _StudyGroupDetailScreenState extends State<StudyGroupDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<StudyGroupMember> _members = [];
  bool _isLoadingMembers = false;
  bool _isJoined = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadMembers();
    _checkMembershipStatus();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadMembers() async {
    setState(() => _isLoadingMembers = true);
    try {
      final provider = context.read<StudyGroupsProvider>();
      final members = await provider.getGroupMembers(widget.group.id);
      setState(() => _members = members);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading members: $e')),
      );
    } finally {
      setState(() => _isLoadingMembers = false);
    }
  }

  void _checkMembershipStatus() {
    final provider = context.read<StudyGroupsProvider>();
    _isJoined = provider.joinedGroups.any((g) => g.id == widget.group.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1a1a2e),
              Color(0xFF16213e),
              Color(0xFF0f3460),
            ],
          ),
        ),
        child: Column(
          children: [
            _buildHeader(),
            _buildTabs(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildOverview(),
                  _buildMembers(),
                  _buildMeetings(),
                  _buildProgress(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildActionButton(),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 300,
      child: Stack(
        children: [
          // Background Image
          Container(
            decoration: BoxDecoration(
              image: widget.group.coverImage.isNotEmpty
                  ? DecorationImage(
                      image: CachedNetworkImageProvider(widget.group.coverImage),
                      fit: BoxFit.cover,
                    )
                  : null,
              gradient: widget.group.coverImage.isEmpty
                  ? LinearGradient(
                      colors: [_getCategoryColor(), _getCategoryColor().withOpacity(0.7)],
                    )
                  : null,
            ),
          ),
          // Gradient Overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.3),
                  Colors.black.withOpacity(0.8),
                ],
              ),
            ),
          ),
          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                      const Spacer(),
                      _buildCategoryBadge(),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    widget.group.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundImage: widget.group.leaderAvatar.isNotEmpty
                            ? CachedNetworkImageProvider(widget.group.leaderAvatar)
                            : null,
                        backgroundColor: Colors.white.withOpacity(0.2),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Liderado por ${widget.group.leaderName}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildStatChip(Icons.group, '${widget.group.membersCount} miembros'),
                      const SizedBox(width: 12),
                      if (widget.group.nextMeeting != null)
                        _buildStatChip(Icons.schedule, _formatNextMeeting()),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getCategoryColor(),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Text(
        widget.group.categoryDisplayName,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(25),
      ),
      child: TabBar(
        controller: _tabController,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          color: _getCategoryColor(),
          borderRadius: BorderRadius.circular(25),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
        labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        tabs: const [
          Tab(text: 'Info'),
          Tab(text: 'Miembros'),
          Tab(text: 'Reuniones'),
          Tab(text: 'Progreso'),
        ],
      ),
    );
  }

  Widget _buildOverview() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard(
            'Descripción',
            Icons.description,
            widget.group.description,
          ),
          const SizedBox(height: 16),
          if (widget.group.currentStudy != null) ...[
            _buildInfoCard(
              'Estudio Actual',
              Icons.menu_book,
              widget.group.currentStudy!,
            ),
            const SizedBox(height: 16),
          ],
          if (widget.group.meetingLocation != null) ...[
            _buildInfoCard(
              'Ubicación de Reuniones',
              Icons.location_on,
              widget.group.meetingLocation!,
            ),
            const SizedBox(height: 16),
          ],
          if (widget.group.tags.isNotEmpty) ...[
            _buildTagsSection(),
            const SizedBox(height: 16),
          ],
          _buildGroupSettings(),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, IconData icon, String content) {
    return GlowContainer(
      glowColor: _getCategoryColor().withOpacity(0.3),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: _getCategoryColor(), size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              content,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTagsSection() {
    return GlowContainer(
      glowColor: _getCategoryColor().withOpacity(0.3),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.local_offer, color: _getCategoryColor(), size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Temas',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.group.tags.map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getCategoryColor().withOpacity(0.3),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: _getCategoryColor().withOpacity(0.5)),
                  ),
                  child: Text(
                    tag,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
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

  Widget _buildGroupSettings() {
    return GlowContainer(
      glowColor: _getCategoryColor().withOpacity(0.3),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.settings, color: _getCategoryColor(), size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Configuración del Grupo',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildSettingRow(
              Icons.lock, 
              'Grupo Privado', 
              widget.group.isPrivate ? 'Sí' : 'No',
            ),
            _buildSettingRow(
              Icons.admin_panel_settings, 
              'Requiere Aprobación', 
              widget.group.requiresApproval ? 'Sí' : 'No',
            ),
            _buildSettingRow(
              Icons.people, 
              'Máximo de Miembros', 
              '${widget.group.maxMembers}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 16),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMembers() {
    if (_isLoadingMembers) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.blue),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _members.length,
      itemBuilder: (context, index) {
        final member = _members[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundImage: member.userAvatar.isNotEmpty
                    ? CachedNetworkImageProvider(member.userAvatar)
                    : null,
                backgroundColor: Colors.white.withOpacity(0.2),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          member.userName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (member.isVerified) ...[
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.verified,
                            color: Colors.blue,
                            size: 16,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getRoleDisplayName(member.role),
                      style: TextStyle(
                        color: _getRoleColor(member.role),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                _formatJoinDate(member.joinedAt),
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMeetings() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.group.nextMeeting != null) ...[
            _buildNextMeetingCard(),
            const SizedBox(height: 20),
          ],
          _buildMeetingHistory(),
        ],
      ),
    );
  }

  Widget _buildNextMeetingCard() {
    return GlowContainer(
      glowColor: Colors.green.withOpacity(0.3),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.green.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.event, color: Colors.green, size: 24),
                const SizedBox(width: 12),
                const Text(
                  'Próxima Reunión',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              _formatMeetingDate(widget.group.nextMeeting!),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (widget.group.meetingLocation != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.white70, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.group.meetingLocation!,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            if (widget.group.meetingLink != null) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Open meeting link
                  },
                  icon: const Icon(Icons.video_call),
                  label: const Text('Unirse a la Reunión'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMeetingHistory() {
    return GlowContainer(
      glowColor: _getCategoryColor().withOpacity(0.3),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.history, color: _getCategoryColor(), size: 24),
                const SizedBox(width: 12),
                const Text(
                  'Historial de Reuniones',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Center(
              child: Text(
                'No hay reuniones anteriores registradas',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgress() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProgressCard(),
          const SizedBox(height: 20),
          _buildLessonsCard(),
        ],
      ),
    );
  }

  Widget _buildProgressCard() {
    return GlowContainer(
      glowColor: _getCategoryColor().withOpacity(0.3),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, color: _getCategoryColor(), size: 24),
                const SizedBox(width: 12),
                const Text(
                  'Progreso del Estudio',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${(widget.group.progress * 100).toInt()}% Completado',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${widget.group.lessonsCompleted} de ${widget.group.totalLessons} lecciones',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 80,
                    width: 80,
                    child: CircularProgressIndicator(
                      value: widget.group.progress,
                      strokeWidth: 8,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(_getCategoryColor()),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            LinearProgressIndicator(
              value: widget.group.progress,
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(_getCategoryColor()),
              minHeight: 6,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLessonsCard() {
    return GlowContainer(
      glowColor: _getCategoryColor().withOpacity(0.3),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.list_alt, color: _getCategoryColor(), size: 24),
                const SizedBox(width: 12),
                const Text(
                  'Lecciones',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...List.generate(widget.group.totalLessons, (index) {
              final isCompleted = index < widget.group.lessonsCompleted;
              final isCurrent = index == widget.group.lessonsCompleted;
              
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isCompleted 
                      ? _getCategoryColor().withOpacity(0.2)
                      : isCurrent
                          ? Colors.orange.withOpacity(0.2)
                          : Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isCompleted 
                        ? _getCategoryColor()
                        : isCurrent
                            ? Colors.orange
                            : Colors.white.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isCompleted 
                          ? Icons.check_circle
                          : isCurrent
                              ? Icons.play_circle
                              : Icons.circle_outlined,
                      color: isCompleted 
                          ? _getCategoryColor()
                          : isCurrent
                              ? Colors.orange
                              : Colors.white54,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Lección ${index + 1}',
                      style: TextStyle(
                        color: isCompleted || isCurrent 
                            ? Colors.white 
                            : Colors.white54,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton() {
    if (_isJoined) {
      return GlowContainer(
        glowColor: Colors.red,
        borderRadius: BorderRadius.circular(28),
        child: FloatingActionButton.extended(
          onPressed: _leaveGroup,
          backgroundColor: Colors.red,
          icon: const Icon(Icons.exit_to_app, color: Colors.white),
          label: const Text(
            'Salir',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      );
    } else {
      return GlowContainer(
        glowColor: _getCategoryColor(),
        borderRadius: BorderRadius.circular(28),
        child: FloatingActionButton.extended(
          onPressed: widget.group.isFull ? null : _joinGroup,
          backgroundColor: widget.group.isFull ? Colors.grey : _getCategoryColor(),
          icon: Icon(
            widget.group.isFull ? Icons.block : Icons.add,
            color: Colors.white,
          ),
          label: Text(
            widget.group.isFull ? 'Lleno' : 'Unirse',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }
  }

  Future<void> _joinGroup() async {
    try {
      await context.read<StudyGroupsProvider>().joinGroup(widget.group.id);
      setState(() => _isJoined = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Te has unido al grupo exitosamente')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al unirse al grupo: $e')),
      );
    }
  }

  Future<void> _leaveGroup() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a2e),
        title: const Text('Salir del Grupo', style: TextStyle(color: Colors.white)),
        content: const Text(
          '¿Estás seguro de que quieres salir de este grupo?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Salir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await context.read<StudyGroupsProvider>().leaveGroup(widget.group.id);
        setState(() => _isJoined = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Has salido del grupo')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al salir del grupo: $e')),
        );
      }
    }
  }

  Color _getCategoryColor() {
    switch (widget.group.category) {
      case 'bible_study':
        return Colors.blue;
      case 'prayer':
        return Colors.purple;
      case 'youth':
        return Colors.green;
      case 'men':
        return Colors.indigo;
      case 'women':
        return Colors.pink;
      default:
        return Colors.teal;
    }
  }

  String _formatNextMeeting() {
    if (widget.group.nextMeeting == null) return '';
    
    final now = DateTime.now();
    final meeting = widget.group.nextMeeting!;
    final difference = meeting.difference(now);
    
    if (difference.inDays > 0) {
      return 'En ${difference.inDays} días';
    } else if (difference.inHours > 0) {
      return 'En ${difference.inHours} horas';
    } else if (difference.inMinutes > 0) {
      return 'En ${difference.inMinutes} minutos';
    } else {
      return 'Ahora';
    }
  }

  String _formatMeetingDate(DateTime date) {
    final days = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    final months = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 
                   'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
    
    return '${days[date.weekday - 1]}, ${date.day} ${months[date.month - 1]} - ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _getRoleDisplayName(String role) {
    switch (role) {
      case 'leader':
        return 'Líder';
      case 'co_leader':
        return 'Co-líder';
      case 'member':
        return 'Miembro';
      default:
        return 'Miembro';
    }
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'leader':
        return Colors.orange;
      case 'co_leader':
        return Colors.yellow;
      case 'member':
        return Colors.white70;
      default:
        return Colors.white70;
    }
  }

  String _formatJoinDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}m';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else {
      return 'Hoy';
    }
  }
}
