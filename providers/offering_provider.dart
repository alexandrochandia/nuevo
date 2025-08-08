import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/offering_model.dart';

class OfferingProvider with ChangeNotifier {
  WalletModel? _wallet;
  List<OfferingModel> _offerings = [];
  List<OfferingModel> _recentTransactions = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  WalletModel? get wallet => _wallet;
  List<OfferingModel> get offerings => _offerings;
  List<OfferingModel> get recentTransactions => _recentTransactions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Statistics
  double get totalDonatedThisMonth {
    final now = DateTime.now();
    final thisMonth = _offerings.where((o) => 
      o.createdAt.year == now.year && 
      o.createdAt.month == now.month &&
      o.status == TransactionStatus.completada
    );
    return thisMonth.fold(0.0, (sum, o) => sum + o.amount);
  }

  double get totalDonatedThisYear {
    final now = DateTime.now();
    final thisYear = _offerings.where((o) => 
      o.createdAt.year == now.year &&
      o.status == TransactionStatus.completada
    );
    return thisYear.fold(0.0, (sum, o) => sum + o.amount);
  }

  Map<OfferingType, double> get donationsByType {
    final Map<OfferingType, double> result = {};
    for (final offering in _offerings.where((o) => o.status == TransactionStatus.completada)) {
      result[offering.type] = (result[offering.type] ?? 0.0) + offering.amount;
    }
    return result;
  }

  List<OfferingModel> get completedOfferings => 
    _offerings.where((o) => o.status == TransactionStatus.completada).toList();

  List<OfferingModel> get pendingOfferings => 
    _offerings.where((o) => o.status == TransactionStatus.pendiente).toList();

  OfferingProvider() {
    _initializeData();
  }

  Future<void> _initializeData() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _loadWallet();
      await _loadOfferings();
      _error = null;
    } catch (e) {
      _error = 'Error al cargar datos: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadWallet() async {
    // Simular carga de billetera desde base de datos
    await Future.delayed(const Duration(milliseconds: 500));
    
    _wallet = WalletModel(
      id: 'wallet_001',
      userId: 'user_001',
      balance: 2500.0,
      currency: 'SEK',
      lastUpdated: DateTime.now(),
      totalDonated: 15750.0,
      monthlyGoal: 1000.0,
      donationsByType: {
        OfferingType.diezmo: 8500.0,
        OfferingType.ofrenda: 4200.0,
        OfferingType.mision: 2050.0,
        OfferingType.construccion: 1000.0,
      },
    );
  }

  Future<void> _loadOfferings() async {
    // Simular carga de ofrendas desde base de datos
    await Future.delayed(const Duration(milliseconds: 300));
    
    _offerings = [
      OfferingModel(
        id: 'off_001',
        userId: 'user_001',
        type: OfferingType.diezmo,
        amount: 850.0,
        description: 'Diezmo Diciembre 2024',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        status: TransactionStatus.completada,
        paymentMethod: PaymentMethod.swish,
        transactionReference: 'SW123456789',
      ),
      OfferingModel(
        id: 'off_002',
        userId: 'user_001',
        type: OfferingType.ofrenda,
        amount: 500.0,
        description: 'Ofrenda dominical',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        status: TransactionStatus.completada,
        paymentMethod: PaymentMethod.tarjeta,
        dedicatedTo: 'En memoria de María González',
        message: 'Con amor y bendiciones para la familia',
      ),
      OfferingModel(
        id: 'off_003',
        userId: 'user_001',
        type: OfferingType.mision,
        amount: 750.0,
        description: 'Apoyo misiones África',
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
        status: TransactionStatus.completada,
        paymentMethod: PaymentMethod.bankgiro,
        dedicatedTo: 'Misión Kenia 2025',
      ),
      OfferingModel(
        id: 'off_004',
        userId: 'user_001',
        type: OfferingType.construccion,
        amount: 1000.0,
        description: 'Construcción nuevo templo',
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        status: TransactionStatus.completada,
        paymentMethod: PaymentMethod.swish,
      ),
      OfferingModel(
        id: 'off_005',
        userId: 'user_001',
        type: OfferingType.especial,
        amount: 300.0,
        description: 'Ofrenda Navidad 2024',
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        status: TransactionStatus.pendiente,
        paymentMethod: PaymentMethod.tarjeta,
      ),
      OfferingModel(
        id: 'off_006',
        userId: 'user_001',
        type: OfferingType.diezmo,
        amount: 850.0,
        description: 'Diezmo Noviembre 2024',
        createdAt: DateTime.now().subtract(const Duration(days: 35)),
        status: TransactionStatus.completada,
        paymentMethod: PaymentMethod.swish,
      ),
    ];

    _recentTransactions = _offerings.take(5).toList();
  }

  Future<bool> makeOffering({
    required OfferingType type,
    required double amount,
    required String description,
    required PaymentMethod paymentMethod,
    String? dedicatedTo,
    String? message,
    bool isAnonymous = false,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simular procesamiento de pago
      await Future.delayed(const Duration(seconds: 2));

      final offering = OfferingModel(
        id: 'off_${DateTime.now().millisecondsSinceEpoch}',
        userId: 'user_001',
        type: type,
        amount: amount,
        description: description,
        createdAt: DateTime.now(),
        status: TransactionStatus.completada, // En producción sería pendiente
        paymentMethod: paymentMethod,
        dedicatedTo: dedicatedTo,
        message: message,
        isAnonymous: isAnonymous,
        transactionReference: 'TXN${DateTime.now().millisecondsSinceEpoch}',
      );

      _offerings.insert(0, offering);
      _recentTransactions = _offerings.take(5).toList();

      // Actualizar billetera
      if (_wallet != null) {
        final newDonationsByType = Map<OfferingType, double>.from(_wallet!.donationsByType);
        newDonationsByType[type] = (newDonationsByType[type] ?? 0.0) + amount;

        _wallet = WalletModel(
          id: _wallet!.id,
          userId: _wallet!.userId,
          balance: _wallet!.balance,
          currency: _wallet!.currency,
          lastUpdated: DateTime.now(),
          recentTransactions: _recentTransactions,
          totalDonated: _wallet!.totalDonated + amount,
          monthlyGoal: _wallet!.monthlyGoal,
          donationsByType: newDonationsByType,
        );
      }

      await _saveToPreferences();
      _error = null;
      
      _isLoading = false;
      notifyListeners();
      return true;

    } catch (e) {
      _error = 'Error al procesar ofrenda: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> updateMonthlyGoal(double newGoal) async {
    if (_wallet != null) {
      _wallet = WalletModel(
        id: _wallet!.id,
        userId: _wallet!.userId,
        balance: _wallet!.balance,
        currency: _wallet!.currency,
        lastUpdated: DateTime.now(),
        recentTransactions: _wallet!.recentTransactions,
        totalDonated: _wallet!.totalDonated,
        monthlyGoal: newGoal,
        donationsByType: _wallet!.donationsByType,
      );
      
      await _saveToPreferences();
      notifyListeners();
    }
  }

  Future<List<OfferingModel>> getOfferingsByType(OfferingType type) async {
    return _offerings.where((o) => o.type == type).toList();
  }

  Future<List<OfferingModel>> getOfferingsByDateRange(DateTime start, DateTime end) async {
    return _offerings.where((o) => 
      o.createdAt.isAfter(start) && o.createdAt.isBefore(end)
    ).toList();
  }

  Future<void> _saveToPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      if (_wallet != null) {
        final walletJson = _wallet!.toJson();
        await prefs.setString('wallet_data', walletJson.toString());
      }
      
      await prefs.setDouble('monthly_goal', _wallet?.monthlyGoal ?? 0.0);
      await prefs.setDouble('total_donated', _wallet?.totalDonated ?? 0.0);
      
    } catch (e) {
      print('Error saving to preferences: $e');
    }
  }

  Future<void> refreshData() async {
    await _initializeData();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Simulación de métodos adicionales para funcionalidades avanzadas
  Future<bool> requestWithdrawal(double amount, String bankAccount) async {
    // En una implementación real, esto se conectaría con un sistema de pagos
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }

  Future<Map<String, double>> getMonthlyStatistics() async {
    final now = DateTime.now();
    final stats = <String, double>{};
    
    for (int i = 0; i < 12; i++) {
      final month = DateTime(now.year, now.month - i, 1);
      final monthlyTotal = _offerings.where((o) => 
        o.createdAt.year == month.year && 
        o.createdAt.month == month.month &&
        o.status == TransactionStatus.completada
      ).fold(0.0, (sum, o) => sum + o.amount);
      
      stats['${month.year}-${month.month.toString().padLeft(2, '0')}'] = monthlyTotal;
    }
    
    return stats;
  }

  double getProgressTowardsGoal() {
    if (_wallet?.monthlyGoal == null || _wallet!.monthlyGoal == 0) return 0.0;
    final monthlyTotal = totalDonatedThisMonth;
    return (monthlyTotal / _wallet!.monthlyGoal).clamp(0.0, 1.0);
  }
}