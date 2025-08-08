import 'package:flutter/material.dart';
import '../../utils/error_handler.dart';

/// Controlador centralizado para manejar todo el flujo de registro
class RegistrationController extends ChangeNotifier {
  // Estado del registro
  Map<String, dynamic> _registrationData = {};
  int _currentStep = 0;
  bool _isLoading = false;
  String? _error;

  // Total de pasos en el registro
  static const int totalSteps = 7;

  // Lista de pasos del registro
  final List<RegistrationStep> _steps = [
    RegistrationStep(
      id: 'welcome',
      title: 'Bienvenido a VMF Sweden',
      subtitle: 'Tu nueva comunidad espiritual te espera',
      route: '/register-welcome',
      isCompleted: false,
    ),
    RegistrationStep(
      id: 'gender',
      title: '¿Cuál es tu género?',
      subtitle: 'Ayúdanos a personalizar tu experiencia',
      route: '/register-gender',
      isCompleted: false,
    ),
    RegistrationStep(
      id: 'name',
      title: 'Escribe tu nombre',
      subtitle: 'Comparte tu identidad con la comunidad',
      route: '/register-name',
      isCompleted: false,
    ),
    RegistrationStep(
      id: 'birthday',
      title: '¿Cuál es tu fecha de nacimiento?',
      subtitle: 'Esto nos ayuda a crear conexiones apropiadas',
      route: '/register-birthday',
      isCompleted: false,
    ),
    RegistrationStep(
      id: 'notifications',
      title: 'Mantente conectado',
      subtitle: 'Configura tus preferencias de notificaciones',
      route: '/register-notifications',
      isCompleted: false,
    ),
    RegistrationStep(
      id: 'photos',
      title: 'Muestra tu mejor versión',
      subtitle: 'Comparte fotos que reflejen tu personalidad',
      route: '/register-photos',
      isCompleted: false,
    ),
    RegistrationStep(
      id: 'verification',
      title: 'Verificación final',
      subtitle: 'Solo un paso más para unirte a la comunidad',
      route: '/register-final',
      isCompleted: false,
    ),
  ];

  // Getters
  Map<String, dynamic> get registrationData => Map.from(_registrationData);
  int get currentStep => _currentStep;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<RegistrationStep> get steps => List.from(_steps);
  double get progress => (_currentStep + 1) / totalSteps;
  RegistrationStep get currentStepInfo => _steps[_currentStep];
  bool get canGoNext => _steps[_currentStep].isCompleted;
  bool get canGoBack => _currentStep > 0;

  /// Actualiza los datos de registro para un campo específico
  Future<void> updateData(String key, dynamic value) async {
    _registrationData[key] = value;
    
    // Validar el paso inmediatamente después de actualizar
    _validateCurrentStep();
    
    // Simular un pequeño delay para operaciones que podrían requerir persistencia
    await Future.delayed(const Duration(milliseconds: 100));
    
    notifyListeners();
  }

  /// Obtiene un valor específico de los datos de registro
  T? getData<T>(String key) {
    return _registrationData[key] as T?;
  }

  /// Valida el paso actual basado en los datos
  void _validateCurrentStep() {
    if (_currentStep >= _steps.length) return;
    
    final stepId = _steps[_currentStep].id;
    bool isValid = false;

    switch (stepId) {
      case 'welcome':
        isValid = true; // El welcome siempre es válido
        break;
      case 'gender':
        final gender = _registrationData['gender'] as String?;
        isValid = gender != null && gender.isNotEmpty;
        break;
      case 'name':
        final name = _registrationData['name'] as String?;
        isValid = name != null && 
                 name.trim().isNotEmpty && 
                 name.trim().length >= 2 && 
                 name.trim().length <= 50;
        break;
      case 'birthday':
        final birthday = _registrationData['birthday'] as DateTime?;
        if (birthday != null) {
          final age = calculateAge(birthday);
          isValid = age >= 18 && age <= 100;
        } else {
          isValid = false;
        }
        break;
      case 'notifications':
        final notificationSettings = _registrationData['notification_settings'] as Map<String, bool>?;
        // Las notificaciones son válidas si existe la configuración (incluso si todas están deshabilitadas)
        isValid = notificationSettings != null;
        break;
      case 'photos':
        final photos = _registrationData['photos'] as List?;
        isValid = photos != null && photos.isNotEmpty;
        break;
      case 'verification':
        isValid = true; // La verificación siempre es válida una vez completada
        break;
    }

    _steps[_currentStep] = _steps[_currentStep].copyWith(isCompleted: isValid);
  }

  /// Avanza al siguiente paso si es posible
  Future<bool> nextStep() async {
    if (_currentStep >= totalSteps - 1) return false;

    setLoading(true);
    clearError();

    try {
      // Validar el paso actual antes de avanzar
      _validateCurrentStep();
      
      if (!_steps[_currentStep].isCompleted) {
        setError('Completa la información requerida antes de continuar');
        return false;
      }

      // Simular guardado de datos
      await Future.delayed(const Duration(milliseconds: 500));

      _currentStep++;
      
      // Validar el nuevo paso actual
      if (_currentStep < _steps.length) {
        _validateCurrentStep();
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      setError('Error al avanzar al siguiente paso: ${e.toString()}');
      return false;
    } finally {
      setLoading(false);
    }
  }

  /// Retrocede al paso anterior si es posible
  bool previousStep() {
    if (!canGoBack) return false;

    _currentStep--;
    notifyListeners();
    return true;
  }

  /// Va a un paso específico
  bool goToStep(int stepIndex) {
    if (stepIndex < 0 || stepIndex >= totalSteps) return false;
    if (stepIndex > _currentStep && !canGoNext) return false;

    _currentStep = stepIndex;
    notifyListeners();
    return true;
  }

  /// Establece el estado de carga
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Establece un error
  void setError(String? error) {
    _error = error;
    notifyListeners();
  }

  /// Limpia el error actual
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Reinicia todo el flujo de registro
  void reset() {
    _registrationData.clear();
    _currentStep = 0;
    _isLoading = false;
    _error = null;

    for (int i = 0; i < _steps.length; i++) {
      _steps[i] = _steps[i].copyWith(isCompleted: false);
    }

    notifyListeners();
  }

  /// Completa el registro
  Future<bool> completeRegistration() async {
    setLoading(true);
    clearError();

    try {
      // Aquí iría la lógica real para completar el registro
      await Future.delayed(const Duration(seconds: 2));

      // Simular posible error
      if (_registrationData.isEmpty) {
        throw Exception('Datos de registro incompletos');
      }

      return true;
    } catch (e) {
      setError('Error al completar el registro: ${e.toString()}');
      return false;
    } finally {
      setLoading(false);
    }
  }

  /// Valida un email
  bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  /// Valida un nombre
  bool isValidName(String name) {
    return name.trim().length >= 2 && name.trim().length <= 50;
  }

  /// Valida la edad basada en fecha de nacimiento
  bool isValidAge(DateTime birthday) {
    final age = DateTime.now().difference(birthday).inDays / 365.25;
    return age >= 18 && age <= 100;
  }

  /// Calcula la edad desde fecha de nacimiento
  int calculateAge(DateTime birthday) {
    final now = DateTime.now();
    int age = now.year - birthday.year;
    if (now.month < birthday.month ||
        (now.month == birthday.month && now.day < birthday.day)) {
      age--;
    }
    return age;
  }

  /// Obtiene las estadísticas del progreso
  Map<String, dynamic> getProgressStats() {
    final completedSteps = _steps.where((step) => step.isCompleted).length;
    return {
      'current_step': _currentStep + 1,
      'total_steps': totalSteps,
      'completed_steps': completedSteps,
      'progress_percentage': (completedSteps / totalSteps * 100).round(),
      'remaining_steps': totalSteps - completedSteps,
    };
  }

  /// Obtiene los datos de registro formateados para envío
  Map<String, dynamic> getFormattedData() {
    final formatted = Map<String, dynamic>.from(_registrationData);

    // Formatear fecha de nacimiento
    if (formatted['birthday'] is DateTime) {
      formatted['birthday'] = (formatted['birthday'] as DateTime).toIso8601String();
    }

    // Formatear fotos si existen
    if (formatted['photos'] is List) {
      // Aquí se podría convertir las fotos a base64 o URLs
      formatted['photos_count'] = (formatted['photos'] as List).length;
    }

    // Agregar metadata del registro
    formatted['registration_completed_at'] = DateTime.now().toIso8601String();
    formatted['app_version'] = '1.0.0';
    formatted['platform'] = 'mobile';

    return formatted;
  }

  // Update methods
  void updateName(String name) {
    _registrationData['name'] = name;
    notifyListeners();
  }

  void updateGender(String gender) {
    _registrationData['gender'] = gender;
    notifyListeners();
  }

  void updateBirthday(DateTime birthday) {
    print('Actualizando cumpleaños: $birthday'); // Debug
    _registrationData['birthday'] = birthday;
    
    // Calcular y guardar la edad también
    final age = calculateAge(birthday);
    _registrationData['age'] = age;
    
    print('Datos después de actualizar: $_registrationData'); // Debug
    
    // Validar inmediatamente
    _validateCurrentStep();
    
    print('Step validado: ${_steps[_currentStep].isCompleted}'); // Debug
    
    notifyListeners();
  }

  // Navigation methods
  void goToNext(BuildContext context) {
    if (canGoNext) {
      _currentStep++;
      notifyListeners();
    }
  }

  void goToPrevious(BuildContext context) {
    if (_currentStep > 0) {
      _currentStep--;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    // Limpiar recursos si es necesario
    super.dispose();
  }
}

/// Modelo para representar un paso del registro
class RegistrationStep {
  final String id;
  final String title;
  final String subtitle;
  final String route;
  final bool isCompleted;
  final IconData? icon;
  final Color? color;

  const RegistrationStep({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.route,
    required this.isCompleted,
    this.icon,
    this.color,
  });

  RegistrationStep copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? route,
    bool? isCompleted,
    IconData? icon,
    Color? color,
  }) {
    return RegistrationStep(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      route: route ?? this.route,
      isCompleted: isCompleted ?? this.isCompleted,
      icon: icon ?? this.icon,
      color: color ?? this.color,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RegistrationStep &&
        other.id == id &&
        other.title == title &&
        other.subtitle == subtitle &&
        other.route == route &&
        other.isCompleted == isCompleted;
  }

  @override
  int get hashCode {
    return id.hashCode ^
    title.hashCode ^
    subtitle.hashCode ^
    route.hashCode ^
    isCompleted.hashCode;
  }
}