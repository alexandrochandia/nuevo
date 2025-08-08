import 'package:flutter/material.dart';
import '../providers/spiritual_music_provider.dart';
import '../models/spiritual_music_model.dart';

class MusicFilterModal extends StatefulWidget {
  final SpiritualMusicProvider provider;
  final Color auraColor;

  const MusicFilterModal({
    Key? key,
    required this.provider,
    required this.auraColor,
  }) : super(key: key);

  @override
  State<MusicFilterModal> createState() => _MusicFilterModalState();
}

class _MusicFilterModalState extends State<MusicFilterModal> {
  MusicCategory? selectedCategory;
  MusicPurpose? selectedPurpose;
  MusicMood? selectedMood;
  bool showOnlyFavorites = false;
  bool showOnlyInstrumental = false;

  @override
  void initState() {
    super.initState();
    selectedCategory = widget.provider.selectedCategory;
    selectedPurpose = widget.provider.selectedPurpose;
    selectedMood = widget.provider.selectedMood;
    showOnlyFavorites = widget.provider.showOnlyFavorites;
    showOnlyInstrumental = widget.provider.showOnlyInstrumental;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[600],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          
          // Título
          Row(
            children: [
              Icon(Icons.filter_list, color: widget.auraColor),
              const SizedBox(width: 12),
              const Text(
                'Filtros de Música',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: _clearFilters,
                child: Text(
                  'Limpiar',
                  style: TextStyle(color: widget.auraColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Filtros
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Categoría
                  _buildFilterSection(
                    'Categoría',
                    Icons.category,
                    _buildCategoryFilter(),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Propósito
                  _buildFilterSection(
                    'Propósito',
                    Icons.flag,
                    _buildPurposeFilter(),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Estado de ánimo
                  _buildFilterSection(
                    'Estado de Ánimo',
                    Icons.mood,
                    _buildMoodFilter(),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Opciones adicionales
                  _buildFilterSection(
                    'Opciones',
                    Icons.tune,
                    _buildAdditionalOptions(),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Botones
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _applyFilters,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.auraColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Aplicar Filtros',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: widget.auraColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Cancelar',
                    style: TextStyle(color: widget.auraColor),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(String title, IconData icon, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: widget.auraColor, size: 16),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: widget.auraColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        content,
      ],
    );
  }

  Widget _buildCategoryFilter() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: MusicCategory.values.map((category) {
        final isSelected = selectedCategory == category;
        return FilterChip(
          label: Text(
            category.displayName,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey[400],
              fontSize: 12,
            ),
          ),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              selectedCategory = selected ? category : null;
            });
          },
          backgroundColor: Colors.grey[800],
          selectedColor: widget.auraColor,
          side: BorderSide(
            color: isSelected ? widget.auraColor : Colors.grey[600]!,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPurposeFilter() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: MusicPurpose.values.map((purpose) {
        final isSelected = selectedPurpose == purpose;
        return FilterChip(
          label: Text(
            purpose.displayName,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey[400],
              fontSize: 12,
            ),
          ),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              selectedPurpose = selected ? purpose : null;
            });
          },
          backgroundColor: Colors.grey[800],
          selectedColor: widget.auraColor,
          side: BorderSide(
            color: isSelected ? widget.auraColor : Colors.grey[600]!,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMoodFilter() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: MusicMood.values.map((mood) {
        final isSelected = selectedMood == mood;
        return FilterChip(
          label: Text(
            mood.displayName,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey[400],
              fontSize: 12,
            ),
          ),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              selectedMood = selected ? mood : null;
            });
          },
          backgroundColor: Colors.grey[800],
          selectedColor: widget.auraColor,
          side: BorderSide(
            color: isSelected ? widget.auraColor : Colors.grey[600]!,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAdditionalOptions() {
    return Column(
      children: [
        SwitchListTile(
          title: const Text(
            'Solo Favoritos',
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
          value: showOnlyFavorites,
          onChanged: (value) {
            setState(() {
              showOnlyFavorites = value;
            });
          },
          activeColor: widget.auraColor,
          contentPadding: EdgeInsets.zero,
        ),
        SwitchListTile(
          title: const Text(
            'Solo Instrumental',
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
          value: showOnlyInstrumental,
          onChanged: (value) {
            setState(() {
              showOnlyInstrumental = value;
            });
          },
          activeColor: widget.auraColor,
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }

  void _clearFilters() {
    setState(() {
      selectedCategory = null;
      selectedPurpose = null;
      selectedMood = null;
      showOnlyFavorites = false;
      showOnlyInstrumental = false;
    });
  }

  void _applyFilters() {
    widget.provider.applyFilters(
      category: selectedCategory,
      purpose: selectedPurpose,
      mood: selectedMood,
      showOnlyFavorites: showOnlyFavorites,
      showOnlyInstrumental: showOnlyInstrumental,
    );
    Navigator.pop(context);
  }
}