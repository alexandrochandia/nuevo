import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/advanced_events_provider.dart';
import '../theme/app_theme.dart';

class EventFiltersModal extends StatefulWidget {
  const EventFiltersModal({Key? key}) : super(key: key);

  @override
  State<EventFiltersModal> createState() => _EventFiltersModalState();
}

class _EventFiltersModalState extends State<EventFiltersModal>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  String _selectedCategory = 'Todos';
  String _selectedStatus = 'Todos';
  String _selectedSort = 'fecha';
  RangeValues _priceRange = const RangeValues(0, 1000);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();

    // Obtener valores actuales del provider
    final provider = Provider.of<AdvancedEventsProvider>(context, listen: false);
    _selectedCategory = provider.selectedCategory;
    _selectedStatus = provider.selectedStatus;
    _selectedSort = provider.sortBy;
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.8,
          transform: Matrix4.translationValues(
            0,
            MediaQuery.of(context).size.height * _slideAnimation.value,
            0,
          ),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildCategoryFilter(),
                          const SizedBox(height: 24),
                          _buildStatusFilter(),
                          const SizedBox(height: 24),
                          _buildPriceFilter(),
                          const SizedBox(height: 24),
                          _buildSortFilter(),
                          const SizedBox(height: 32),
                          _buildActionButtons(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(
                Icons.filter_list,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 12),
              const Text(
                'Filtros de Eventos',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Consumer<AdvancedEventsProvider>(
      builder: (context, provider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Categoría', Icons.category),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: provider.categories.map((category) {
                final isSelected = _selectedCategory == category;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategory = category;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected 
                        ? AppTheme.primaryColor 
                        : Colors.grey[100],
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: isSelected 
                          ? AppTheme.primaryColor 
                          : Colors.grey[300]!,
                      ),
                    ),
                    child: Text(
                      category,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        fontSize: 14,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatusFilter() {
    return Consumer<AdvancedEventsProvider>(
      builder: (context, provider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Estado', Icons.schedule),
            const SizedBox(height: 12),
            Column(
              children: provider.statuses.map((status) {
                final isSelected = _selectedStatus == status;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedStatus = status;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected 
                        ? AppTheme.primaryColor.withValues(alpha: 0.1)
                        : Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected 
                          ? AppTheme.primaryColor 
                          : Colors.grey[200]!,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _getStatusIcon(status),
                          color: isSelected 
                            ? AppTheme.primaryColor 
                            : Colors.grey[600],
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          status,
                          style: TextStyle(
                            color: isSelected 
                              ? AppTheme.primaryColor 
                              : Colors.black87,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            fontSize: 16,
                          ),
                        ),
                        const Spacer(),
                        if (isSelected)
                          Icon(
                            Icons.check_circle,
                            color: AppTheme.primaryColor,
                            size: 20,
                          ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPriceFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Rango de Precio (SEK)', Icons.attach_money),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_priceRange.start.round()} SEK',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  Text(
                    '${_priceRange.end.round()} SEK',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              RangeSlider(
                values: _priceRange,
                min: 0,
                max: 1000,
                divisions: 20,
                activeColor: AppTheme.primaryColor,
                inactiveColor: Colors.grey[300],
                onChanged: (values) {
                  setState(() {
                    _priceRange = values;
                  });
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSortFilter() {
    return Consumer<AdvancedEventsProvider>(
      builder: (context, provider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Ordenar por', Icons.sort),
            const SizedBox(height: 12),
            Column(
              children: provider.sortOptions.map((option) {
                final isSelected = _selectedSort == option;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedSort = option;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected 
                        ? AppTheme.primaryColor.withValues(alpha: 0.1)
                        : Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected 
                          ? AppTheme.primaryColor 
                          : Colors.grey[200]!,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _getSortIcon(option),
                          color: isSelected 
                            ? AppTheme.primaryColor 
                            : Colors.grey[600],
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _getSortLabel(option),
                          style: TextStyle(
                            color: isSelected 
                              ? AppTheme.primaryColor 
                              : Colors.black87,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            fontSize: 16,
                          ),
                        ),
                        const Spacer(),
                        if (isSelected)
                          Icon(
                            Icons.check_circle,
                            color: AppTheme.primaryColor,
                            size: 20,
                          ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          color: AppTheme.primaryColor,
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _clearFilters,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: AppTheme.primaryColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Limpiar filtros',
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: _applyFilters,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Aplicar filtros',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Los filtros se aplicarán inmediatamente',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Próximos':
        return Icons.schedule;
      case 'En curso':
        return Icons.play_circle;
      case 'Finalizados':
        return Icons.check_circle;
      case 'Cancelados':
        return Icons.cancel;
      default:
        return Icons.event;
    }
  }

  IconData _getSortIcon(String option) {
    switch (option) {
      case 'fecha':
        return Icons.calendar_today;
      case 'nombre':
        return Icons.sort_by_alpha;
      case 'popularidad':
        return Icons.trending_up;
      case 'precio':
        return Icons.attach_money;
      default:
        return Icons.sort;
    }
  }

  String _getSortLabel(String option) {
    switch (option) {
      case 'fecha':
        return 'Fecha';
      case 'nombre':
        return 'Nombre';
      case 'popularidad':
        return 'Popularidad';
      case 'precio':
        return 'Precio';
      default:
        return option;
    }
  }

  void _clearFilters() {
    setState(() {
      _selectedCategory = 'Todos';
      _selectedStatus = 'Todos';
      _selectedSort = 'fecha';
      _priceRange = const RangeValues(0, 1000);
    });

    final provider = Provider.of<AdvancedEventsProvider>(context, listen: false);
    provider.clearFilters();

    Navigator.pop(context);
  }

  void _applyFilters() {
    final provider = Provider.of<AdvancedEventsProvider>(context, listen: false);
    
    provider.filterByCategory(_selectedCategory);
    provider.filterByStatus(_selectedStatus);
    provider.sortEvents(_selectedSort);

    Navigator.pop(context);
  }
}
