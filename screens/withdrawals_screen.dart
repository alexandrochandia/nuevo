import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/offering_provider.dart';
import '../providers/aura_provider.dart';

class WithdrawalsScreen extends StatefulWidget {
  const WithdrawalsScreen({super.key});

  @override
  State<WithdrawalsScreen> createState() => _WithdrawalsScreenState();
}

class _WithdrawalsScreenState extends State<WithdrawalsScreen>
    with TickerProviderStateMixin {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _bankAccountController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();
  bool _isProcessing = false;

  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

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
    _bankAccountController.dispose();
    _reasonController.dispose();
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
              'Solicitar Retiro',
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
                _buildBalanceCard(offeringProvider, auraProvider),
                const SizedBox(height: 24),
                _buildWithdrawalForm(auraProvider),
                const SizedBox(height: 24),
                _buildImportantNotice(auraProvider),
                const SizedBox(height: 32),
                _buildSubmitButton(offeringProvider, auraProvider),
                const SizedBox(height: 24),
                _buildWithdrawalHistory(auraProvider),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBalanceCard(OfferingProvider provider, AuraProvider auraProvider) {
    final wallet = provider.wallet;
    if (wallet == null) return const SizedBox();

    final currencyFormat = NumberFormat.currency(locale: 'sv_SE', symbol: 'kr');

    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.grey[900]!,
                Colors.grey[800]!,
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: auraProvider.currentAuraColor.withOpacity(0.3),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: auraProvider.currentAuraColor.withOpacity(_glowAnimation.value * 0.3),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(
                Icons.account_balance,
                color: auraProvider.currentAuraColor,
                size: 48,
              ),
              const SizedBox(height: 12),
              Text(
                'Balance Disponible',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                currencyFormat.format(wallet.balance),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Fondos disponibles para retiro',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWithdrawalForm(AuraProvider auraProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Información del Retiro',
          style: TextStyle(
            color: auraProvider.currentAuraColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        // Cantidad a retirar
        TextField(
          controller: _amountController,
          keyboardType: TextInputType.number,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          decoration: InputDecoration(
            labelText: 'Cantidad a retirar (SEK)',
            labelStyle: TextStyle(color: auraProvider.currentAuraColor),
            hintText: '0.00',
            hintStyle: TextStyle(color: Colors.grey[600]),
            prefixIcon: Icon(
              Icons.monetization_on,
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
        
        // Cuenta bancaria
        TextField(
          controller: _bankAccountController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Número de cuenta bancaria',
            labelStyle: TextStyle(color: auraProvider.currentAuraColor),
            hintText: 'XXXX-XXXX-XXXX-XXXX',
            hintStyle: TextStyle(color: Colors.grey[600]),
            prefixIcon: Icon(
              Icons.account_balance,
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
        
        // Razón del retiro
        TextField(
          controller: _reasonController,
          maxLines: 3,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Razón del retiro (opcional)',
            labelStyle: TextStyle(color: auraProvider.currentAuraColor),
            hintText: 'Explica brevemente por qué solicitas este retiro...',
            hintStyle: TextStyle(color: Colors.grey[600]),
            prefixIcon: Icon(
              Icons.description,
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

  Widget _buildImportantNotice(AuraProvider auraProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.orange.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info,
                color: Colors.orange,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Información Importante',
                style: TextStyle(
                  color: Colors.orange,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '• Los retiros son procesados en 3-5 días laborables\n'
            '• Se aplicará una comisión del 2% sobre el monto\n'
            '• Monto mínimo de retiro: 100 SEK\n'
            '• Todas las solicitudes son revisadas por el equipo financiero VMF\n'
            '• Los fondos solo pueden ser retirados a cuentas verificadas',
            style: TextStyle(
              color: Colors.grey[300],
              fontSize: 12,
              height: 1.5,
            ),
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
                color: Colors.orange.withOpacity(_glowAnimation.value * 0.4),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: _isProcessing ? null : () => _processWithdrawal(provider),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
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
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    'Solicitar Retiro',
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

  Widget _buildWithdrawalHistory(AuraProvider auraProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Historial de Retiros',
          style: TextStyle(
            color: auraProvider.currentAuraColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildHistoryItem(
          'Retiro aprobado',
          '1,500 SEK',
          'Hace 2 semanas',
          Icons.check_circle,
          Colors.green,
          'Transferido a cuenta ****1234',
        ),
        _buildHistoryItem(
          'Retiro pendiente',
          '800 SEK',
          'Hace 3 días',
          Icons.schedule,
          Colors.orange,
          'En revisión por el equipo financiero',
        ),
        _buildHistoryItem(
          'Retiro rechazado',
          '2,000 SEK',
          'Hace 1 mes',
          Icons.cancel,
          Colors.red,
          'Monto excede el límite mensual',
        ),
      ],
    );
  }

  Widget _buildHistoryItem(
    String title,
    String amount,
    String date,
    IconData icon,
    Color color,
    String description,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: color,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      amount,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _processWithdrawal(OfferingProvider provider) async {
    if (_amountController.text.isEmpty) {
      _showError('Por favor ingresa una cantidad');
      return;
    }

    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      _showError('Por favor ingresa una cantidad válida');
      return;
    }

    if (amount < 100) {
      _showError('El monto mínimo de retiro es 100 SEK');
      return;
    }

    if (provider.wallet != null && amount > provider.wallet!.balance) {
      _showError('No tienes suficiente balance disponible');
      return;
    }

    if (_bankAccountController.text.isEmpty) {
      _showError('Por favor ingresa tu número de cuenta bancaria');
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    final success = await provider.requestWithdrawal(
      amount,
      _bankAccountController.text,
    );

    setState(() {
      _isProcessing = false;
    });

    if (success) {
      _showSuccessDialog(amount);
    } else {
      _showError('Error al procesar la solicitud de retiro');
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

  void _showSuccessDialog(double amount) {
    final currencyFormat = NumberFormat.currency(locale: 'sv_SE', symbol: 'kr');
    
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
              '¡Solicitud Enviada!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tu solicitud de retiro por ${currencyFormat.format(amount)} ha sido enviada para revisión.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Recibirás una notificación cuando sea procesada (3-5 días laborables).',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
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