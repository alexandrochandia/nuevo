import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/offering_provider.dart';
import '../providers/aura_provider.dart';
import '../models/offering_model.dart';

class GiftWalletScreen extends StatefulWidget {
  const GiftWalletScreen({super.key});

  @override
  State<GiftWalletScreen> createState() => _GiftWalletScreenState();
}

class _GiftWalletScreenState extends State<GiftWalletScreen>
    with TickerProviderStateMixin {
  OfferingType _selectedType = OfferingType.ofrenda;
  PaymentMethod _selectedPaymentMethod = PaymentMethod.swish;
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _dedicatedToController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  bool _isAnonymous = false;
  bool _isProcessing = false;

  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  final List<double> _quickAmounts = [100, 250, 500, 850, 1000, 2000];

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _glowAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));
    _glowController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    _dedicatedToController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<OfferingProvider, AuraProvider>(
      builder: (context, offeringProvider, auraProvider, child) {
        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: auraProvider.currentAuraColor,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Nueva Ofrenda',
              style: TextStyle(
                color: auraProvider.currentAuraColor,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTypeSelector(auraProvider),
                const SizedBox(height: 24),
                _buildAmountSection(auraProvider),
                const SizedBox(height: 24),
                _buildPaymentMethodSelector(auraProvider),
                const SizedBox(height: 24),
                _buildDescriptionSection(auraProvider),
                const SizedBox(height: 24),
                _buildDedicationSection(auraProvider),
                const SizedBox(height: 24),
                _buildAnonymousOption(auraProvider),
                const SizedBox(height: 32),
                _buildSubmitButton(offeringProvider, auraProvider),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTypeSelector(AuraProvider auraProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tipo de Ofrenda',
          style: TextStyle(
            color: auraProvider.currentAuraColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: OfferingType.values.map((type) {
            final isSelected = _selectedType == type;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedType = type;
                  if (type == OfferingType.diezmo) {
                    _descriptionController.text = 'Diezmo ${DateFormat('MMMM yyyy', 'es').format(DateTime.now())}';
                  }
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? type.color.withOpacity(0.2) : Colors.grey[900],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? type.color : Colors.grey[700]!,
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: type.color.withOpacity(0.3),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      type.icon,
                      color: isSelected ? type.color : Colors.grey[400],
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      type.displayName,
                      style: TextStyle(
                        color: isSelected ? type.color : Colors.grey[400],
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        Text(
          _selectedType.description,
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildAmountSection(AuraProvider auraProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cantidad (SEK)',
          style: TextStyle(
            color: auraProvider.currentAuraColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _amountController,
          keyboardType: TextInputType.number,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          decoration: InputDecoration(
            hintText: '0.00',
            hintStyle: TextStyle(color: Colors.grey[600]),
            prefixIcon: Icon(
              Icons.attach_money,
              color: auraProvider.currentAuraColor,
            ),
            filled: true,
            fillColor: Colors.grey[900],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: auraProvider.currentAuraColor,
                width: 2,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Cantidades Sugeridas',
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _quickAmounts.map((amount) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  _amountController.text = amount.toInt().toString();
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: auraProvider.currentAuraColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  '${amount.toInt()} kr',
                  style: TextStyle(
                    color: auraProvider.currentAuraColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodSelector(AuraProvider auraProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Método de Pago',
          style: TextStyle(
            color: auraProvider.currentAuraColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...PaymentMethod.values.map((method) {
          final isSelected = _selectedPaymentMethod == method;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: isSelected ? method.color.withOpacity(0.1) : Colors.grey[900],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? method.color : Colors.grey[700]!,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: RadioListTile<PaymentMethod>(
              value: method,
              groupValue: _selectedPaymentMethod,
              onChanged: (value) {
                setState(() {
                  _selectedPaymentMethod = value!;
                });
              },
              title: Row(
                children: [
                  Icon(
                    method.icon,
                    color: method.color,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    method.displayName,
                    style: TextStyle(
                      color: isSelected ? method.color : Colors.white,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
              activeColor: method.color,
              fillColor: WidgetStateProperty.all(method.color),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildDescriptionSection(AuraProvider auraProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Descripción',
          style: TextStyle(
            color: auraProvider.currentAuraColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _descriptionController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Descripción de la ofrenda...',
            hintStyle: TextStyle(color: Colors.grey[600]),
            filled: true,
            fillColor: Colors.grey[900],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: auraProvider.currentAuraColor,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDedicationSection(AuraProvider auraProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dedicación (Opcional)',
          style: TextStyle(
            color: auraProvider.currentAuraColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _dedicatedToController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Dedicado a...',
            hintStyle: TextStyle(color: Colors.grey[600]),
            prefixIcon: Icon(
              Icons.favorite,
              color: auraProvider.currentAuraColor,
            ),
            filled: true,
            fillColor: Colors.grey[900],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: auraProvider.currentAuraColor,
                width: 2,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _messageController,
          maxLines: 3,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Mensaje personal...',
            hintStyle: TextStyle(color: Colors.grey[600]),
            prefixIcon: Icon(
              Icons.message,
              color: auraProvider.currentAuraColor,
            ),
            filled: true,
            fillColor: Colors.grey[900],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: auraProvider.currentAuraColor,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnonymousOption(AuraProvider auraProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: auraProvider.currentAuraColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.visibility_off,
            color: auraProvider.currentAuraColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Donación Anónima',
                  style: TextStyle(
                    color: auraProvider.currentAuraColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tu nombre no aparecerá en los registros públicos',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _isAnonymous,
            onChanged: (value) {
              setState(() {
                _isAnonymous = value;
              });
            },
            activeColor: auraProvider.currentAuraColor,
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(OfferingProvider provider, AuraProvider auraProvider) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: auraProvider.currentAuraColor.withOpacity(_glowAnimation.value * 0.4),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: _isProcessing ? null : () => _processOffering(provider),
            style: ElevatedButton.styleFrom(
              backgroundColor: auraProvider.currentAuraColor,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: _isProcessing
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.black,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    'Procesar Ofrenda',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        );
      },
    );
  }

  Future<void> _processOffering(OfferingProvider provider) async {
    if (_amountController.text.isEmpty) {
      _showError('Por favor ingresa una cantidad');
      return;
    }

    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      _showError('Por favor ingresa una cantidad válida');
      return;
    }

    if (_descriptionController.text.isEmpty) {
      _showError('Por favor ingresa una descripción');
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    final success = await provider.makeOffering(
      type: _selectedType,
      amount: amount,
      description: _descriptionController.text,
      paymentMethod: _selectedPaymentMethod,
      dedicatedTo: _dedicatedToController.text.isNotEmpty ? _dedicatedToController.text : null,
      message: _messageController.text.isNotEmpty ? _messageController.text : null,
      isAnonymous: _isAnonymous,
    );

    setState(() {
      _isProcessing = false;
    });

    if (success) {
      _showSuccessDialog();
    } else {
      _showError(provider.error ?? 'Error al procesar la ofrenda');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 64,
            ),
            const SizedBox(height: 16),
            const Text(
              '¡Ofrenda Procesada!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tu ofrenda ha sido procesada exitosamente. ¡Dios te bendiga!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Cerrar diálogo
                Navigator.pop(context); // Volver a billetera
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text('Continuar'),
            ),
          ],
        ),
      ),
    );
  }
}