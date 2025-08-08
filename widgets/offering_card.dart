import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/offering_model.dart';

class OfferingCard extends StatelessWidget {
  final OfferingModel offering;
  final Color auraColor;

  const OfferingCard({
    super.key,
    required this.offering,
    required this.auraColor,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'sv_SE', symbol: 'kr');
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: offering.type.color.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: offering.type.color.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: offering.type.color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  offering.type.icon,
                  color: offering.type.color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      offering.type.displayName,
                      style: TextStyle(
                        color: offering.type.color,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      offering.description,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    currencyFormat.format(offering.amount),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: offering.status.color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          offering.status.icon,
                          color: offering.status.color,
                          size: 12,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          offering.status.displayName,
                          style: TextStyle(
                            color: offering.status.color,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                offering.paymentMethod.icon,
                color: offering.paymentMethod.color,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                offering.paymentMethod.displayName,
                style: TextStyle(
                  color: offering.paymentMethod.color,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Text(
                dateFormat.format(offering.createdAt),
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 12,
                ),
              ),
            ],
          ),
          if (offering.dedicatedTo != null || offering.message != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (offering.dedicatedTo != null) ...[
                    Row(
                      children: [
                        Icon(
                          Icons.favorite,
                          color: auraColor,
                          size: 14,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Dedicado a:',
                          style: TextStyle(
                            color: auraColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      offering.dedicatedTo!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ],
                  if (offering.message != null) ...[
                    if (offering.dedicatedTo != null) const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.message,
                          color: auraColor,
                          size: 14,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Mensaje:',
                          style: TextStyle(
                            color: auraColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      offering.message!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
          if (offering.transactionReference != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.receipt,
                  color: Colors.grey[400],
                  size: 12,
                ),
                const SizedBox(width: 6),
                Text(
                  'Ref: ${offering.transactionReference}',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}