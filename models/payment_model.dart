
import 'package:flutter/material.dart';

enum PaymentProvider {
  swish,
  stripe,
  paypal,
  klarna,
  bankgiro,
  crypto,
  applePay,
  googlePay
}

enum PaymentStatus {
  pending,
  processing,
  completed,
  failed,
  cancelled,
  refunded,
  expired
}

enum TransactionType {
  offering,
  tithe,
  donation,
  merchandise,
  event_ticket,
  subscription,
  gift
}

class PaymentMethod {
  final String id;
  final PaymentProvider provider;
  final String displayName;
  final String? maskedAccount;
  final IconData icon;
  final Color brandColor;
  final bool isDefault;
  final bool isActive;
  final Map<String, dynamic>? metadata;

  PaymentMethod({
    required this.id,
    required this.provider,
    required this.displayName,
    this.maskedAccount,
    required this.icon,
    required this.brandColor,
    this.isDefault = false,
    this.isActive = true,
    this.metadata,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['id'],
      provider: PaymentProvider.values[json['provider']],
      displayName: json['display_name'],
      maskedAccount: json['masked_account'],
      icon: _getIconFromProvider(PaymentProvider.values[json['provider']]),
      brandColor: Color(json['brand_color']),
      isDefault: json['is_default'] ?? false,
      isActive: json['is_active'] ?? true,
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'provider': provider.index,
      'display_name': displayName,
      'masked_account': maskedAccount,
      'brand_color': brandColor.value,
      'is_default': isDefault,
      'is_active': isActive,
      'metadata': metadata,
    };
  }

  static IconData _getIconFromProvider(PaymentProvider provider) {
    switch (provider) {
      case PaymentProvider.swish:
        return Icons.phone_android;
      case PaymentProvider.stripe:
        return Icons.credit_card;
      case PaymentProvider.paypal:
        return Icons.payment;
      case PaymentProvider.klarna:
        return Icons.shopping_bag;
      case PaymentProvider.bankgiro:
        return Icons.account_balance;
      case PaymentProvider.crypto:
        return Icons.currency_bitcoin;
      case PaymentProvider.applePay:
        return Icons.apple;
      case PaymentProvider.googlePay:
        return Icons.payment;
    }
  }
}

class DigitalTransaction {
  final String id;
  final String userId;
  final TransactionType type;
  final double amount;
  final String currency;
  final PaymentProvider paymentProvider;
  final PaymentStatus status;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? description;
  final String? dedicatedTo;
  final String? message;
  final bool isRecurring;
  final String? recurringInterval;
  final String? transactionReference;
  final String? externalTransactionId;
  final double? fee;
  final double? netAmount;
  final Map<String, dynamic>? metadata;
  final String? failureReason;
  final int? retryCount;

  DigitalTransaction({
    required this.id,
    required this.userId,
    required this.type,
    required this.amount,
    this.currency = 'SEK',
    required this.paymentProvider,
    required this.status,
    required this.createdAt,
    this.completedAt,
    this.description,
    this.dedicatedTo,
    this.message,
    this.isRecurring = false,
    this.recurringInterval,
    this.transactionReference,
    this.externalTransactionId,
    this.fee,
    this.netAmount,
    this.metadata,
    this.failureReason,
    this.retryCount,
  });

  factory DigitalTransaction.fromJson(Map<String, dynamic> json) {
    return DigitalTransaction(
      id: json['id'],
      userId: json['user_id'],
      type: TransactionType.values[json['type']],
      amount: json['amount'].toDouble(),
      currency: json['currency'] ?? 'SEK',
      paymentProvider: PaymentProvider.values[json['payment_provider']],
      status: PaymentStatus.values[json['status']],
      createdAt: DateTime.parse(json['created_at']),
      completedAt: json['completed_at'] != null 
          ? DateTime.parse(json['completed_at']) 
          : null,
      description: json['description'],
      dedicatedTo: json['dedicated_to'],
      message: json['message'],
      isRecurring: json['is_recurring'] ?? false,
      recurringInterval: json['recurring_interval'],
      transactionReference: json['transaction_reference'],
      externalTransactionId: json['external_transaction_id'],
      fee: json['fee']?.toDouble(),
      netAmount: json['net_amount']?.toDouble(),
      metadata: json['metadata'],
      failureReason: json['failure_reason'],
      retryCount: json['retry_count'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'type': type.index,
      'amount': amount,
      'currency': currency,
      'payment_provider': paymentProvider.index,
      'status': status.index,
      'created_at': createdAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'description': description,
      'dedicated_to': dedicatedTo,
      'message': message,
      'is_recurring': isRecurring,
      'recurring_interval': recurringInterval,
      'transaction_reference': transactionReference,
      'external_transaction_id': externalTransactionId,
      'fee': fee,
      'net_amount': netAmount,
      'metadata': metadata,
      'failure_reason': failureReason,
      'retry_count': retryCount,
    };
  }
}

class RecurringPayment {
  final String id;
  final String userId;
  final TransactionType type;
  final double amount;
  final String currency;
  final PaymentProvider paymentProvider;
  final String interval; // 'weekly', 'monthly', 'quarterly', 'yearly'
  final DateTime startDate;
  final DateTime? endDate;
  final bool isActive;
  final DateTime nextPaymentDate;
  final int totalExecutions;
  final int? maxExecutions;
  final String? description;
  final List<DigitalTransaction> transactions;

  RecurringPayment({
    required this.id,
    required this.userId,
    required this.type,
    required this.amount,
    this.currency = 'SEK',
    required this.paymentProvider,
    required this.interval,
    required this.startDate,
    this.endDate,
    this.isActive = true,
    required this.nextPaymentDate,
    this.totalExecutions = 0,
    this.maxExecutions,
    this.description,
    this.transactions = const [],
  });

  factory RecurringPayment.fromJson(Map<String, dynamic> json) {
    return RecurringPayment(
      id: json['id'],
      userId: json['user_id'],
      type: TransactionType.values[json['type']],
      amount: json['amount'].toDouble(),
      currency: json['currency'] ?? 'SEK',
      paymentProvider: PaymentProvider.values[json['payment_provider']],
      interval: json['interval'],
      startDate: DateTime.parse(json['start_date']),
      endDate: json['end_date'] != null 
          ? DateTime.parse(json['end_date']) 
          : null,
      isActive: json['is_active'] ?? true,
      nextPaymentDate: DateTime.parse(json['next_payment_date']),
      totalExecutions: json['total_executions'] ?? 0,
      maxExecutions: json['max_executions'],
      description: json['description'],
      transactions: (json['transactions'] as List?)
          ?.map((t) => DigitalTransaction.fromJson(t))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'type': type.index,
      'amount': amount,
      'currency': currency,
      'payment_provider': paymentProvider.index,
      'interval': interval,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'is_active': isActive,
      'next_payment_date': nextPaymentDate.toIso8601String(),
      'total_executions': totalExecutions,
      'max_executions': maxExecutions,
      'description': description,
      'transactions': transactions.map((t) => t.toJson()).toList(),
    };
  }
}

extension PaymentProviderExtension on PaymentProvider {
  String get displayName {
    switch (this) {
      case PaymentProvider.swish:
        return 'Swish';
      case PaymentProvider.stripe:
        return 'Tarjeta de Crédito';
      case PaymentProvider.paypal:
        return 'PayPal';
      case PaymentProvider.klarna:
        return 'Klarna';
      case PaymentProvider.bankgiro:
        return 'Bankgiro';
      case PaymentProvider.crypto:
        return 'Criptomoneda';
      case PaymentProvider.applePay:
        return 'Apple Pay';
      case PaymentProvider.googlePay:
        return 'Google Pay';
    }
  }

  Color get brandColor {
    switch (this) {
      case PaymentProvider.swish:
        return const Color(0xFF67C3CC);
      case PaymentProvider.stripe:
        return const Color(0xFF635BFF);
      case PaymentProvider.paypal:
        return const Color(0xFF0070BA);
      case PaymentProvider.klarna:
        return const Color(0xFFFFB3C7);
      case PaymentProvider.bankgiro:
        return const Color(0xFF003366);
      case PaymentProvider.crypto:
        return const Color(0xFFF7931A);
      case PaymentProvider.applePay:
        return const Color(0xFF000000);
      case PaymentProvider.googlePay:
        return const Color(0xFF4285F4);
    }
  }

  bool get isAvailableInSweden {
    switch (this) {
      case PaymentProvider.swish:
      case PaymentProvider.stripe:
      case PaymentProvider.klarna:
      case PaymentProvider.bankgiro:
        return true;
      case PaymentProvider.paypal:
      case PaymentProvider.crypto:
      case PaymentProvider.applePay:
      case PaymentProvider.googlePay:
        return true; // Available but may have restrictions
    }
  }
}

extension PaymentStatusExtension on PaymentStatus {
  String get displayName {
    switch (this) {
      case PaymentStatus.pending:
        return 'Pendiente';
      case PaymentStatus.processing:
        return 'Procesando';
      case PaymentStatus.completed:
        return 'Completado';
      case PaymentStatus.failed:
        return 'Fallido';
      case PaymentStatus.cancelled:
        return 'Cancelado';
      case PaymentStatus.refunded:
        return 'Reembolsado';
      case PaymentStatus.expired:
        return 'Expirado';
    }
  }

  Color get statusColor {
    switch (this) {
      case PaymentStatus.pending:
        return const Color(0xFFFFA726);
      case PaymentStatus.processing:
        return const Color(0xFF42A5F5);
      case PaymentStatus.completed:
        return const Color(0xFF66BB6A);
      case PaymentStatus.failed:
        return const Color(0xFFEF5350);
      case PaymentStatus.cancelled:
        return const Color(0xFF78909C);
      case PaymentStatus.refunded:
        return const Color(0xFFAB47BC);
      case PaymentStatus.expired:
        return const Color(0xFF8D6E63);
    }
  }

  IconData get statusIcon {
    switch (this) {
      case PaymentStatus.pending:
        return Icons.schedule;
      case PaymentStatus.processing:
        return Icons.refresh;
      case PaymentStatus.completed:
        return Icons.check_circle;
      case PaymentStatus.failed:
        return Icons.error;
      case PaymentStatus.cancelled:
        return Icons.cancel;
      case PaymentStatus.refunded:
        return Icons.replay;
      case PaymentStatus.expired:
        return Icons.access_time_filled;
    }
  }
}
