import 'package:flutter/material.dart';
import '../models/pastor_model.dart';

class PastorProvider extends ChangeNotifier {
  List<PastorModel> _pastors = [];
  bool _isLoading = false;

  List<PastorModel> get pastors => _pastors;
  List<PastorModel> get activePastors => _pastors.where((p) => p.isActive).toList();
  bool get isLoading => _isLoading;

  // Datos de pastores VMF Sweden
  final List<Map<String, dynamic>> _mockPastorData = [
    {
      'id': '1',
      'name': 'Pastor Miguel Hernández',
      'title': 'Pastor Principal',
      'imageUrl': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=500',
      'phone': '+46 70 123 4567',
      'email': 'pastor.miguel@vmfsweden.com',
      'specialty': 'Liderazgo y Evangelismo',
      'description': 'Pastor principal de VMF Sweden con más de 15 años de experiencia ministerial. Líder visionario comprometido con el crecimiento espiritual de la comunidad.',
      'languages': ['Español', 'Sueco', 'Inglés'],
      'isActive': true,
    },
    {
      'id': '2',
      'name': 'Pastora Ana Rodríguez',
      'title': 'Pastora de Familias',
      'imageUrl': 'https://images.unsplash.com/photo-1494790108755-2616c044bc8c?w=500',
      'phone': '+46 70 234 5678',
      'email': 'pastora.ana@vmfsweden.com',
      'specialty': 'Ministerio Familiar y Consejería',
      'description': 'Pastora especializada en ministerio familiar y consejería matrimonial. Líder del departamento de damas y ministerio infantil.',
      'languages': ['Español', 'Sueco'],
      'isActive': true,
    },
    {
      'id': '3',
      'name': 'Pastor Carlos Mendoza',
      'title': 'Pastor de Jóvenes',
      'imageUrl': 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=500',
      'phone': '+46 70 345 6789',
      'email': 'pastor.carlos@vmfsweden.com',
      'specialty': 'Ministerio Juvenil y Música',
      'description': 'Pastor joven dinámico, líder del ministerio juvenil y director de alabanza. Especializado en alcanzar la nueva generación.',
      'languages': ['Español', 'Inglés', 'Sueco'],
      'isActive': true,
    },
    {
      'id': '4',
      'name': 'Pastor David Sánchez',
      'title': 'Pastor de Misiones',
      'imageUrl': 'https://images.unsplash.com/photo-1560250097-0b93528c311a?w=500',
      'phone': '+46 70 456 7890',
      'email': 'pastor.david@vmfsweden.com',
      'specialty': 'Misiones y Evangelismo',
      'description': 'Pastor misionero con experiencia internacional. Líder del departamento de misiones y evangelismo de VMF Sweden.',
      'languages': ['Español', 'Inglés', 'Sueco', 'Francés'],
      'isActive': true,
    },
  ];

  PastorProvider() {
    loadPastors();
  }

  Future<void> loadPastors() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulando carga de datos
      await Future.delayed(const Duration(milliseconds: 800));
      
      _pastors = _mockPastorData.map((data) => PastorModel.fromJson(data)).toList();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshPastors() async {
    await loadPastors();
  }

  PastorModel? getPastorById(String id) {
    try {
      return _pastors.firstWhere((pastor) => pastor.id == id);
    } catch (e) {
      return null;
    }
  }

  List<PastorModel> getPastorsBySpecialty(String specialty) {
    return _pastors.where((pastor) => pastor.specialty.contains(specialty)).toList();
  }
}