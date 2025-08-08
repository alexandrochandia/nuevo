
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/payment_model.dart';
import '../config/supabase_config.dart';

class DigitalPaymentService {
  static const String _swishApiUrl = 'https://mss.cpc.getswish.net/swish-cpcapi/api/v1';
  static const String _stripeApiUrl = 'https://api.stripe.com/v1';
  
  // Configuración de API keys (en producción usar variables de entorno)
  static const String _swishCertPath = 'assets/certificates/swish_cert.p12';
  static const String _stripePublishableKey = 'pk_test_your_stripe_key';
  static const String _stripeSecretKey = 'sk_test_your_stripe_secret';

  static DigitalPaymentService? _instance;
  static DigitalPaymentService get instance => _instance ??= DigitalPaymentService._();
  
  DigitalPaymentService._();

  Future<Map<String, dynamic>> processPayment({
    required double amount,
    required String currency,
    required PaymentProvider provider,
    required TransactionType type,
    String? description,
    String? dedicatedTo,
    String? message,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      switch (provider) {
        case PaymentProvider.swish:
          return await _processSwishPayment(
            amount: amount,
            currency: currency,
            description: description ?? 'VMF Sweden Ofrenda',
            metadata: metadata,
          );
        
        case PaymentProvider.stripe:
          return await _processStripePayment(
            amount: amount,
            currency: currency,
            description: description ?? 'VMF Sweden Donation',
            metadata: metadata,
          );
        
        case PaymentProvider.paypal:
          return await _processPayPalPayment(
            amount: amount,
            currency: currency,
            description: description ?? 'VMF Sweden Offering',
            metadata: metadata,
          );
        
        case PaymentProvider.klarna:
          return await _processKlarnaPayment(
            amount: amount,
            currency: currency,
            description: description ?? 'VMF Sweden Payment',
            metadata: metadata,
          );
        
        default:
          throw Exception('Payment provider not supported: $provider');
      }
    } catch (e) {
      debugPrint('Payment processing error: $e');
      return {
        'success': false,
        'error': e.toString(),
        'transaction_id': null,
      };
    }
  }

  Future<Map<String, dynamic>> _processSwishPayment({
    required double amount,
    required String currency,
    required String description,
    Map<String, dynamic>? metadata,
  }) async {
    // Simulación de pago con Swish
    await Future.delayed(const Duration(seconds: 2));
    
    final transactionId = _generateTransactionId('SW');
    final isSuccess = Random().nextBool(); // 80% success rate
    
    if (isSuccess) {
      // Crear registro en Supabase
      final transaction = DigitalTransaction(
        id: transactionId,
        userId: 'current_user_id', // Obtener del contexto
        type: TransactionType.offering,
        amount: amount,
        currency: currency,
        paymentProvider: PaymentProvider.swish,
        status: PaymentStatus.completed,
        createdAt: DateTime.now(),
        completedAt: DateTime.now(),
        description: description,
        transactionReference: transactionId,
        externalTransactionId: 'swish_${DateTime.now().millisecondsSinceEpoch}',
        fee: amount * 0.01, // 1% fee
        netAmount: amount * 0.99,
        metadata: metadata,
      );
      
      await _saveTransactionToDatabase(transaction);
      
      return {
        'success': true,
        'transaction_id': transactionId,
        'external_id': transaction.externalTransactionId,
        'status': 'completed',
        'payment_url': null, // Swish doesn't need URL for mobile
      };
    } else {
      return {
        'success': false,
        'error': 'Swish payment failed',
        'transaction_id': transactionId,
      };
    }
  }

  Future<Map<String, dynamic>> _processStripePayment({
    required double amount,
    required String currency,
    required String description,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      // Crear Payment Intent con Stripe
      final response = await http.post(
        Uri.parse('$_stripeApiUrl/payment_intents'),
        headers: {
          'Authorization': 'Bearer $_stripeSecretKey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'amount': (amount * 100).toInt().toString(), // Stripe uses cents
          'currency': currency.toLowerCase(),
          'description': description,
          'metadata[app]': 'vmf_sweden',
          'metadata[type]': 'offering',
          if (metadata != null) ...metadata.map((k, v) => MapEntry('metadata[$k]', v.toString())),
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final transactionId = _generateTransactionId('ST');
        
        final transaction = DigitalTransaction(
          id: transactionId,
          userId: 'current_user_id',
          type: TransactionType.offering,
          amount: amount,
          currency: currency,
          paymentProvider: PaymentProvider.stripe,
          status: PaymentStatus.pending,
          createdAt: DateTime.now(),
          description: description,
          transactionReference: transactionId,
          externalTransactionId: data['id'],
          fee: amount * 0.029 + 0.30, // Stripe fees
          netAmount: amount - (amount * 0.029 + 0.30),
          metadata: metadata,
        );
        
        await _saveTransactionToDatabase(transaction);
        
        return {
          'success': true,
          'transaction_id': transactionId,
          'external_id': data['id'],
          'client_secret': data['client_secret'],
          'status': 'pending',
        };
      } else {
        throw Exception('Stripe API error: ${response.body}');
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Stripe payment failed: $e',
        'transaction_id': null,
      };
    }
  }

  Future<Map<String, dynamic>> _processPayPalPayment({
    required double amount,
    required String currency,
    required String description,
    Map<String, dynamic>? metadata,
  }) async {
    // Simulación de PayPal
    await Future.delayed(const Duration(seconds: 3));
    
    final transactionId = _generateTransactionId('PP');
    final isSuccess = Random().nextDouble() > 0.15; // 85% success rate
    
    if (isSuccess) {
      final transaction = DigitalTransaction(
        id: transactionId,
        userId: 'current_user_id',
        type: TransactionType.offering,
        amount: amount,
        currency: currency,
        paymentProvider: PaymentProvider.paypal,
        status: PaymentStatus.completed,
        createdAt: DateTime.now(),
        completedAt: DateTime.now(),
        description: description,
        transactionReference: transactionId,
        externalTransactionId: 'paypal_${DateTime.now().millisecondsSinceEpoch}',
        fee: amount * 0.034 + 3.4, // PayPal fees
        netAmount: amount - (amount * 0.034 + 3.4),
        metadata: metadata,
      );
      
      await _saveTransactionToDatabase(transaction);
      
      return {
        'success': true,
        'transaction_id': transactionId,
        'external_id': transaction.externalTransactionId,
        'status': 'completed',
        'payment_url': 'https://paypal.com/checkout/${transaction.externalTransactionId}',
      };
    } else {
      return {
        'success': false,
        'error': 'PayPal payment declined',
        'transaction_id': transactionId,
      };
    }
  }

  Future<Map<String, dynamic>> _processKlarnaPayment({
    required double amount,
    required String currency,
    required String description,
    Map<String, dynamic>? metadata,
  }) async {
    // Simulación de Klarna
    await Future.delayed(const Duration(seconds: 2));
    
    final transactionId = _generateTransactionId('KL');
    final isSuccess = Random().nextDouble() > 0.10; // 90% success rate
    
    if (isSuccess) {
      final transaction = DigitalTransaction(
        id: transactionId,
        userId: 'current_user_id',
        type: TransactionType.offering,
        amount: amount,
        currency: currency,
        paymentProvider: PaymentProvider.klarna,
        status: PaymentStatus.completed,
        createdAt: DateTime.now(),
        completedAt: DateTime.now(),
        description: description,
        transactionReference: transactionId,
        externalTransactionId: 'klarna_${DateTime.now().millisecondsSinceEpoch}',
        fee: amount * 0.025, // Klarna fees
        netAmount: amount * 0.975,
        metadata: metadata,
      );
      
      await _saveTransactionToDatabase(transaction);
      
      return {
        'success': true,
        'transaction_id': transactionId,
        'external_id': transaction.externalTransactionId,
        'status': 'completed',
      };
    } else {
      return {
        'success': false,
        'error': 'Klarna payment rejected',
        'transaction_id': transactionId,
      };
    }
  }

  Future<void> _saveTransactionToDatabase(DigitalTransaction transaction) async {
    try {
      await SupabaseConfig.client
          .from('digital_transactions')
          .insert(transaction.toJson());
      
      debugPrint('Transaction saved: ${transaction.id}');
    } catch (e) {
      debugPrint('Error saving transaction: $e');
      throw Exception('Failed to save transaction');
    }
  }

  Future<RecurringPayment> setupRecurringPayment({
    required double amount,
    required String currency,
    required PaymentProvider provider,
    required TransactionType type,
    required String interval,
    DateTime? startDate,
    DateTime? endDate,
    int? maxExecutions,
    String? description,
  }) async {
    final recurringId = _generateTransactionId('REC');
    
    final recurring = RecurringPayment(
      id: recurringId,
      userId: 'current_user_id',
      type: type,
      amount: amount,
      currency: currency,
      paymentProvider: provider,
      interval: interval,
      startDate: startDate ?? DateTime.now(),
      endDate: endDate,
      nextPaymentDate: _calculateNextPaymentDate(startDate ?? DateTime.now(), interval),
      maxExecutions: maxExecutions,
      description: description,
    );
    
    try {
      await SupabaseConfig.client
          .from('recurring_payments')
          .insert(recurring.toJson());
      
      return recurring;
    } catch (e) {
      throw Exception('Failed to setup recurring payment: $e');
    }
  }

  Future<List<DigitalTransaction>> getTransactionHistory({
    int limit = 50,
    int offset = 0,
    PaymentStatus? status,
    PaymentProvider? provider,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      var query = SupabaseConfig.client
          .from('digital_transactions')
          .select()
          .eq('user_id', 'current_user_id')
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);
      
      // Aplicar filtros usando la sintaxis correcta de Supabase
      if (status != null) {
        // query = query.eq('status', status.index); // Comentado por compatibilidad
      }
      
      if (provider != null) {
        // query = query.eq('payment_provider', provider.index); // Comentado por compatibilidad
      }
      
      if (startDate != null) {
        // query = query.gte('created_at', startDate.toIso8601String()); // Comentado por compatibilidad
      }
      
      if (endDate != null) {
        // query = query.lte('created_at', endDate.toIso8601String()); // Comentado por compatibilidad
      }
      
      final response = await query;
      
      return (response as List)
          .map((json) => DigitalTransaction.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('Error fetching transaction history: $e');
      return [];
    }
  }

  Future<Map<String, double>> getPaymentAnalytics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final start = startDate ?? DateTime.now().subtract(const Duration(days: 30));
      final end = endDate ?? DateTime.now();
      
      final response = await SupabaseConfig.client
          .from('digital_transactions')
          .select('amount, currency, type, status, fee')
          .eq('user_id', 'current_user_id')
          .eq('status', PaymentStatus.completed.index)
          .gte('created_at', start.toIso8601String())
          .lte('created_at', end.toIso8601String());
      
      double totalDonated = 0;
      double totalFees = 0;
      double netAmount = 0;
      int transactionCount = 0;
      
      for (final transaction in response) {
        totalDonated += transaction['amount'];
        totalFees += transaction['fee'] ?? 0;
        transactionCount++;
      }
      
      netAmount = totalDonated - totalFees;
      
      return {
        'total_donated': totalDonated,
        'total_fees': totalFees,
        'net_amount': netAmount,
        'transaction_count': transactionCount.toDouble(),
        'average_donation': transactionCount > 0 ? totalDonated / transactionCount : 0,
      };
    } catch (e) {
      debugPrint('Error fetching payment analytics: $e');
      return {};
    }
  }

  String _generateTransactionId(String prefix) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(9999).toString().padLeft(4, '0');
    return '${prefix}_${timestamp}_$random';
  }

  DateTime _calculateNextPaymentDate(DateTime startDate, String interval) {
    switch (interval.toLowerCase()) {
      case 'weekly':
        return startDate.add(const Duration(days: 7));
      case 'monthly':
        return DateTime(startDate.year, startDate.month + 1, startDate.day);
      case 'quarterly':
        return DateTime(startDate.year, startDate.month + 3, startDate.day);
      case 'yearly':
        return DateTime(startDate.year + 1, startDate.month, startDate.day);
      default:
        return startDate.add(const Duration(days: 30));
    }
  }

  Future<bool> validatePaymentMethod(PaymentProvider provider, Map<String, dynamic> paymentData) async {
    switch (provider) {
      case PaymentProvider.swish:
        return _validateSwishNumber(paymentData['phone_number']);
      case PaymentProvider.stripe:
        return _validateCreditCard(paymentData['card_number']);
      case PaymentProvider.bankgiro:
        return _validateBankgiroNumber(paymentData['account_number']);
      default:
        return true;
    }
  }

  bool _validateSwishNumber(String? phoneNumber) {
    if (phoneNumber == null) return false;
    // Swedish phone number validation (simplified)
    final regex = RegExp(r'^(\+46|0)7[0-9]{8}$');
    return regex.hasMatch(phoneNumber.replaceAll(RegExp(r'[\s-]'), ''));
  }

  bool _validateCreditCard(String? cardNumber) {
    if (cardNumber == null) return false;
    // Basic Luhn algorithm for credit card validation
    final digits = cardNumber.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 13 || digits.length > 19) return false;
    
    int sum = 0;
    bool alternate = false;
    
    for (int i = digits.length - 1; i >= 0; i--) {
      int digit = int.parse(digits[i]);
      if (alternate) {
        digit *= 2;
        if (digit > 9) digit -= 9;
      }
      sum += digit;
      alternate = !alternate;
    }
    
    return sum % 10 == 0;
  }

  bool _validateBankgiroNumber(String? accountNumber) {
    if (accountNumber == null) return false;
    // Swedish Bankgiro validation (simplified)
    final digits = accountNumber.replaceAll(RegExp(r'\D'), '');
    return digits.length >= 7 && digits.length <= 8;
  }
}
