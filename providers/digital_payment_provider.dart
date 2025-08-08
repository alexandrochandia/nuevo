
import 'package:flutter/material.dart';
import '../models/payment_model.dart';
import '../services/digital_payment_service.dart';

class DigitalPaymentProvider with ChangeNotifier {
  final DigitalPaymentService _paymentService = DigitalPaymentService.instance;
  
  List<PaymentMethod> _paymentMethods = [];
  List<DigitalTransaction> _transactions = [];
  List<RecurringPayment> _recurringPayments = [];
  Map<String, double> _analytics = {};
  
  bool _isLoading = false;
  bool _isProcessingPayment = false;
  String? _error;
  DigitalTransaction? _currentTransaction;

  // Getters
  List<PaymentMethod> get paymentMethods => _paymentMethods;
  List<DigitalTransaction> get transactions => _transactions;
  List<RecurringPayment> get recurringPayments => _recurringPayments;
  Map<String, double> get analytics => _analytics;
  bool get isLoading => _isLoading;
  bool get isProcessingPayment => _isProcessingPayment;
  String? get error => _error;
  DigitalTransaction? get currentTransaction => _currentTransaction;

  // Filtered lists
  List<DigitalTransaction> get completedTransactions => 
      _transactions.where((t) => t.status == PaymentStatus.completed).toList();
  
  List<DigitalTransaction> get pendingTransactions => 
      _transactions.where((t) => t.status == PaymentStatus.pending).toList();
  
  List<RecurringPayment> get activeRecurringPayments => 
      _recurringPayments.where((r) => r.isActive).toList();

  // Analytics computed properties
  double get totalDonatedThisMonth {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);
    
    return _transactions
        .where((t) => 
            t.status == PaymentStatus.completed &&
            t.completedAt != null &&
            t.completedAt!.isAfter(startOfMonth) &&
            t.completedAt!.isBefore(endOfMonth))
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get totalFeesThisMonth {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);
    
    return _transactions
        .where((t) => 
            t.status == PaymentStatus.completed &&
            t.completedAt != null &&
            t.completedAt!.isAfter(startOfMonth) &&
            t.completedAt!.isBefore(endOfMonth))
        .fold(0.0, (sum, t) => sum + (t.fee ?? 0.0));
  }

  Map<PaymentProvider, double> get donationsByProvider {
    final Map<PaymentProvider, double> result = {};
    for (final transaction in completedTransactions) {
      result[transaction.paymentProvider] = 
          (result[transaction.paymentProvider] ?? 0.0) + transaction.amount;
    }
    return result;
  }

  Map<TransactionType, double> get donationsByType {
    final Map<TransactionType, double> result = {};
    for (final transaction in completedTransactions) {
      result[transaction.type] = 
          (result[transaction.type] ?? 0.0) + transaction.amount;
    }
    return result;
  }

  DigitalPaymentProvider() {
    _initializePaymentMethods();
    loadTransactionHistory();
    loadAnalytics();
  }

  void _initializePaymentMethods() {
    _paymentMethods = [
      PaymentMethod(
        id: 'swish_1',
        provider: PaymentProvider.swish,
        displayName: 'Swish - +46 70 123 45 67',
        maskedAccount: '+46 70 *** ** 67',
        icon: Icons.phone_android,
        brandColor: const Color(0xFF67C3CC),
        isDefault: true,
      ),
      PaymentMethod(
        id: 'stripe_1',
        provider: PaymentProvider.stripe,
        displayName: 'Visa **** 1234',
        maskedAccount: '**** **** **** 1234',
        icon: Icons.credit_card,
        brandColor: const Color(0xFF635BFF),
      ),
      PaymentMethod(
        id: 'paypal_1',
        provider: PaymentProvider.paypal,
        displayName: 'PayPal - user@example.com',
        maskedAccount: 'u***@example.com',
        icon: Icons.payment,
        brandColor: const Color(0xFF0070BA),
      ),
      PaymentMethod(
        id: 'klarna_1',
        provider: PaymentProvider.klarna,
        displayName: 'Klarna - Pay Later',
        icon: Icons.shopping_bag,
        brandColor: const Color(0xFFFFB3C7),
      ),
    ];
  }

  Future<bool> processPayment({
    required double amount,
    required PaymentProvider provider,
    TransactionType type = TransactionType.offering,
    String? description,
    String? dedicatedTo,
    String? message,
    Map<String, dynamic>? metadata,
  }) async {
    _isProcessingPayment = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _paymentService.processPayment(
        amount: amount,
        currency: 'SEK',
        provider: provider,
        type: type,
        description: description,
        dedicatedTo: dedicatedTo,
        message: message,
        metadata: metadata,
      );

      if (result['success'] == true) {
        // Refresh transaction history
        await loadTransactionHistory();
        await loadAnalytics();
        
        _isProcessingPayment = false;
        notifyListeners();
        return true;
      } else {
        _error = result['error'] ?? 'Payment failed';
        _isProcessingPayment = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error processing payment: $e';
      _isProcessingPayment = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> loadTransactionHistory({
    int limit = 50,
    PaymentStatus? status,
    PaymentProvider? provider,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      _transactions = await _paymentService.getTransactionHistory(
        limit: limit,
        status: status,
        provider: provider,
      );
      _error = null;
    } catch (e) {
      _error = 'Error loading transactions: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadAnalytics({DateTime? startDate, DateTime? endDate}) async {
    try {
      _analytics = await _paymentService.getPaymentAnalytics(
        startDate: startDate,
        endDate: endDate,
      );
      notifyListeners();
    } catch (e) {
      _error = 'Error loading analytics: $e';
      notifyListeners();
    }
  }

  Future<bool> setupRecurringPayment({
    required double amount,
    required PaymentProvider provider,
    required String interval,
    TransactionType type = TransactionType.offering,
    DateTime? startDate,
    DateTime? endDate,
    int? maxExecutions,
    String? description,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final recurring = await _paymentService.setupRecurringPayment(
        amount: amount,
        currency: 'SEK',
        provider: provider,
        type: type,
        interval: interval,
        startDate: startDate,
        endDate: endDate,
        maxExecutions: maxExecutions,
        description: description,
      );

      _recurringPayments.add(recurring);
      _error = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error setting up recurring payment: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> validatePaymentMethod(
      PaymentProvider provider, 
      Map<String, dynamic> paymentData) async {
    return await _paymentService.validatePaymentMethod(provider, paymentData);
  }

  void addPaymentMethod(PaymentMethod method) {
    _paymentMethods.add(method);
    notifyListeners();
  }

  void removePaymentMethod(String methodId) {
    _paymentMethods.removeWhere((m) => m.id == methodId);
    notifyListeners();
  }

  void setDefaultPaymentMethod(String methodId) {
    for (int i = 0; i < _paymentMethods.length; i++) {
      _paymentMethods[i] = PaymentMethod(
        id: _paymentMethods[i].id,
        provider: _paymentMethods[i].provider,
        displayName: _paymentMethods[i].displayName,
        maskedAccount: _paymentMethods[i].maskedAccount,
        icon: _paymentMethods[i].icon,
        brandColor: _paymentMethods[i].brandColor,
        isDefault: _paymentMethods[i].id == methodId,
        isActive: _paymentMethods[i].isActive,
        metadata: _paymentMethods[i].metadata,
      );
    }
    notifyListeners();
  }

  PaymentMethod? getDefaultPaymentMethod() {
    try {
      return _paymentMethods.firstWhere((m) => m.isDefault);
    } catch (e) {
      return _paymentMethods.isNotEmpty ? _paymentMethods.first : null;
    }
  }

  List<DigitalTransaction> getTransactionsByDateRange(
      DateTime startDate, DateTime endDate) {
    return _transactions.where((t) =>
        t.createdAt.isAfter(startDate) && 
        t.createdAt.isBefore(endDate)).toList();
  }

  double getTotalAmountByProvider(PaymentProvider provider) {
    return completedTransactions
        .where((t) => t.paymentProvider == provider)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void refreshData() {
    loadTransactionHistory();
    loadAnalytics();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
