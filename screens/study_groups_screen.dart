
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/study_group_model.dart';
import '../providers/study_groups_provider.dart';
import '../widgets/study_group_card.dart';
import '../widgets/glow_container.dart';

class StudyGroupsScreen extends StatefulWidget {
  const StudyGroupsScreen({Key? key}) : super(key: key);

  @override
  State<StudyGroupsScreen> createState() => _StudyGroupsScreenState();
}

class _StudyGroupsScreenState extends State<StudyGroupsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedCategory = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StudyGroupsProvider>().loadGroups();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildTabs(),
              _buildCategoryFilter(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildGroupsList(),
                    _buildMyGroups(),
                    _buildCreateGroup(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildCreateGroupFAB(),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Grupos de Estudio',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Únete a la comunidad de fe',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              // Implementar búsqueda
            },
            icon: const Icon(
              Icons.search,
              color: Colors.white,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(25),
      ),
      child: TabBar(
        controller: _tabController,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(25),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
        tabs: const [
          Tab(text: 'Explorar'),
          Tab(text: 'Mis Grupos'),
          Tab(text: 'Crear'),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    final categories = [
      {'key': 'all', 'name': 'Todos', 'icon': Icons.grid_view},
      {'key': 'bible_study', 'name': 'Biblia', 'icon': Icons.book},
      {'key': 'prayer', 'name': 'Oración', 'icon': Icons.favorite},
      {'key': 'youth', 'name': 'Jóvenes', 'icon': Icons.groups},
      {'key': 'men', 'name': 'Hombres', 'icon': Icons.man},
      {'key': 'women', 'name': 'Mujeres', 'icon': Icons.woman},
    ];

    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = _selectedCategory == category['key'];
          
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategory = category['key'] as String;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                        colors: [Colors.blue, Colors.purple],
                      )
                    : null,
                color: isSelected ? null : Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    category['icon'] as IconData,
                    color: Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    category['name'] as String,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGroupsList() {
    return Consumer<StudyGroupsProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.blue),
          );
        }

        if (provider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 64,
                ),
                const SizedBox(height: 16),
                Text(
                  provider.error!,
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => provider.loadGroups(),
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          );
        }

        final filteredGroups = provider.groups.where((group) {
          if (_selectedCategory == 'all') return true;
          return group.category == _selectedCategory;
        }).toList();

        if (filteredGroups.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.group_off,
                  color: Colors.white54,
                  size: 64,
                ),
                SizedBox(height: 16),
                Text(
                  'No hay grupos disponibles',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: filteredGroups.length,
          itemBuilder: (context, index) {
            return StudyGroupCard(
              group: filteredGroups[index],
              onTap: () => _openGroupDetail(filteredGroups[index]),
            );
          },
        );
      },
    );
  }

  Widget _buildMyGroups() {
    return Consumer<StudyGroupsProvider>(
      builder: (context, provider, child) {
        final myGroups = provider.groups; // Filtrar por grupos del usuario
        
        if (myGroups.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.group_add,
                  color: Colors.white54,
                  size: 64,
                ),
                SizedBox(height: 16),
                Text(
                  'No te has unido a ningún grupo',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 18,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Explora y únete a grupos de estudio',
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: myGroups.length,
          itemBuilder: (context, index) {
            return StudyGroupCard(
              group: myGroups[index],
              onTap: () => _openGroupDetail(myGroups[index]),
              showProgress: true,
            );
          },
        );
      },
    );
  }

  Widget _buildCreateGroup() {
    return const Center(
      child: Text(
        'Formulario para crear grupo',
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _buildCreateGroupFAB() {
    return GlowContainer(
      glowColor: Colors.blue,
      borderRadius: BorderRadius.circular(28),
      child: FloatingActionButton(
        onPressed: () {
          _tabController.animateTo(2);
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _openGroupDetail(StudyGroup group) {
    // Navegar a detalle del grupo
    Navigator.pushNamed(context, '/study-group-detail', arguments: group);
  }
}
