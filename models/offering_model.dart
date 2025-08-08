import 'package:flutter/material.dart';

enum OfferingType {
  diezmo,
  ofrenda,
  donacion,
  mision,
  construccion,
  especial
}

enum TransactionStatus {
  pendiente,
  completada,
  fallida,
  cancelada,
  reembolsada
}

enum PaymentMethod {
  tarjeta,
  swish,
  bankgiro,
  paypal,
  crypto
}

class OfferingModel {
  final String id;
  final String userId;
  final OfferingType type;
  final double amount;
  final String currency;
  final String description;
  final DateTime createdAt;
  final TransactionStatus status;
  final PaymentMethod paymentMethod;
  final String? dedicatedTo;
  final String? message;
  final bool isAnonymous;
  final String? transactionReference;
  final Map<String, dynamic>? metadata;

  OfferingModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.amount,
    this.currency = 'SEK',
    required this.description,
    required this.createdAt,
    required this.status,
    required this.paymentMethod,
    this.dedicatedTo,
    this.message,
    this.isAnonymous = false,
    this.transactionReference,
    this.metadata,
  });

  factory OfferingModel.fromJson(Map<String, dynamic> json) {
    return OfferingModel(
      id: json['id'],
      userId: json['user_id'],
      type: OfferingType.values[json['type']],
      amount: json['amount'].toDouble(),
      currency: json['currency'] ?? 'SEK',
      description: json['description'],
      createdAt: DateTime.parse(json['created_at']),
      status: TransactionStatus.values[json['status']],
      paymentMethod: PaymentMethod.values[json['payment_method']],
      dedicatedTo: json['dedicated_to'],
      message: json['message'],
      isAnonymous: json['is_anonymous'] ?? false,
      transactionReference: json['transaction_reference'],
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'type': type.index,
      'amount': amount,
      'currency': currency,
      'description': description,
      'created_at': createdAt.toIso8601String(),
      'status': status.index,
      'payment_method': paymentMethod.index,
      'dedicated_to': dedicatedTo,
      'message': message,
      'is_anonymous': isAnonymous,
      'transaction_reference': transactionReference,
      'metadata': metadata,
    };
  }
}

class WalletModel {
  final String id;
  final String userId;
  final double balance;
  final String currency;
  final DateTime lastUpdated;
  final List<OfferingModel> recentTransactions;
  final double totalDonated;
  final double monthlyGoal;
  final Map<OfferingType, double> donationsByType;

  WalletModel({
    required this.id,
    required this.userId,
    required this.balance,
    this.currency = 'SEK',
    required this.lastUpdated,
    this.recentTransactions = const [],
    this.totalDonated = 0.0,
    this.monthlyGoal = 0.0,
    this.donationsByType = const {},
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      id: json['id'],
      userId: json['user_id'],
      balance: json['balance'].toDouble(),
      currency: json['currency'] ?? 'SEK',
      lastUpdated: DateTime.parse(json['last_updated']),
      recentTransactions: (json['recent_transactions'] as List?)
          ?.map((t) => OfferingModel.fromJson(t))
          .toList() ?? [],
      totalDonated: json['total_donated']?.toDouble() ?? 0.0,
      monthlyGoal: json['monthly_goal']?.toDouble() ?? 0.0,
      donationsByType: Map<OfferingType, double>.from(
        json['donations_by_type']?.map((k, v) => 
          MapEntry(OfferingType.values[int.parse(k)], v.toDouble())) ?? {}
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'balance': balance,
      'currency': currency,
      'last_updated': lastUpdated.toIso8601String(),
      'recent_transactions': recentTransactions.map((t) => t.toJson()).toList(),
      'total_donated': totalDonated,
      'monthly_goal': monthlyGoal,
      'donations_by_type': donationsByType.map((k, v) => 
        MapEntry(k.index.toString(), v)),
    };
  }
}

extension OfferingTypeExtension on OfferingType {
  String get displayName {
    switch (this) {
      case OfferingType.diezmo:
        return 'Diezmo';
      case OfferingType.ofrenda:
        return 'Ofrenda';
      case OfferingType.donacion:
        return 'Donación';
      case OfferingType.mision:
        return 'Misiones';
      case OfferingType.construccion:
        return 'Construcción';
      case OfferingType.especial:
        return 'Especial';
    }
  }

  String get description {
    switch (this) {
      case OfferingType.diezmo:
        return 'Diezmo mensual del 10%';
      case OfferingType.ofrenda:
        return 'Ofrenda voluntaria';
      case OfferingType.donacion:
        return 'Donación especial';
      case OfferingType.mision:
        return 'Apoyo a misiones';
      case OfferingType.construccion:
        return 'Construcción del templo';
      case OfferingType.especial:
        return 'Ofrenda especial';
    }
  }

  IconData get icon {
    switch (this) {
      case OfferingType.diezmo:
        return Icons.account_balance;
      case OfferingType.ofrenda:
        return Icons.volunteer_activism;
      case OfferingType.donacion:
        return Icons.favorite;
      case OfferingType.mision:
        return Icons.flight_takeoff;
      case OfferingType.construccion:
        return Icons.construction;
      case OfferingType.especial:
        return Icons.star;
    }
  }

  Color get color {
    switch (this) {
      case OfferingType.diezmo:
        return const Color(0xFF2ecc71);
      case OfferingType.ofrenda:
        return const Color(0xFF3498db);
      case OfferingType.donacion:
        return const Color(0xFFe74c3c);
      case OfferingType.mision:
        return const Color(0xFF9b59b6);
      case OfferingType.construccion:
        return const Color(0xFFf39c12);
      case OfferingType.especial:
        return const Color(0xFFf1c40f);
    }
  }
}

extension TransactionStatusExtension on TransactionStatus {
  String get displayName {
    switch (this) {
      case TransactionStatus.pendiente:
        return 'Pendiente';
      case TransactionStatus.completada:
        return 'Completada';
      case TransactionStatus.fallida:
        return 'Fallida';
      case TransactionStatus.cancelada:
        return 'Cancelada';
      case TransactionStatus.reembolsada:
        return 'Reembolsada';
    }
  }

  Color get color {
    switch (this) {
      case TransactionStatus.pendiente:
        return const Color(0xFFf39c12);
      case TransactionStatus.completada:
        return const Color(0xFF2ecc71);
      case TransactionStatus.fallida:
        return const Color(0xFFe74c3c);
      case TransactionStatus.cancelada:
        return const Color(0xFF95a5a6);
      case TransactionStatus.reembolsada:
        return const Color(0xFF9b59b6);
    }
  }

  IconData get icon {
    switch (this) {
      case TransactionStatus.pendiente:
        return Icons.schedule;
      case TransactionStatus.completada:
        return Icons.check_circle;
      case TransactionStatus.fallida:
        return Icons.error;
      case TransactionStatus.cancelada:
        return Icons.cancel;
      case TransactionStatus.reembolsada:
        return Icons.replay;
    }
  }
}

extension PaymentMethodExtension on PaymentMethod {
  String get displayName {
    switch (this) {
      case PaymentMethod.tarjeta:
        return 'Tarjeta';
      case PaymentMethod.swish:
        return 'Swish';
      case PaymentMethod.bankgiro:
        return 'Bankgiro';
      case PaymentMethod.paypal:
        return 'PayPal';
      case PaymentMethod.crypto:
        return 'Crypto';
    }
  }

  IconData get icon {
    switch (this) {
      case PaymentMethod.tarjeta:
        return Icons.credit_card;
      case PaymentMethod.swish:
        return Icons.phone_android;
      case PaymentMethod.bankgiro:
        return Icons.account_balance;
      case PaymentMethod.paypal:
        return Icons.payment;
      case PaymentMethod.crypto:
        return Icons.currency_bitcoin;
    }
  }

  Color get color {
    switch (this) {
      case PaymentMethod.tarjeta:
        return const Color(0xFF3498db);
      case PaymentMethod.swish:
        return const Color(0xFF2ecc71);
      case PaymentMethod.bankgiro:
        return const Color(0xFF34495e);
      case PaymentMethod.paypal:
        return const Color(0xFF0070ba);
      case PaymentMethod.crypto:
        return const Color(0xFFf39c12);
    }
  }
}