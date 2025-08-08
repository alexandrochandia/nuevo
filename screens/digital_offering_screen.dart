
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/digital_payment_provider.dart';
import '../providers/aura_provider.dart';
import '../models/payment_model.dart';
import '../utils/glow_styles.dart';

class DigitalOfferingScreen extends StatefulWidget {
  const DigitalOfferingScreen({super.key});

  @override
  State<DigitalOfferingScreen> createState() => _DigitalOfferingScreenState();
}

class _DigitalOfferingScreenState extends State<DigitalOfferingScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _dedicatedToController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  TransactionType _selectedType = TransactionType.offering;
  PaymentProvider? _selectedProvider;
  bool _isRecurring = false;
  String _recurringInterval = 'monthly';
  
  final NumberFormat _currencyFormat = NumberFormat.currency(locale: 'sv_SE', symbol: 'kr');
  final List<double> _quickAmounts = [50, 100, 250, 500, 1000, 2000, 5000];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _glowAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
    _glowController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _glowController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    _dedicatedToController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<DigitalPaymentProvider, AuraProvider>(
      builder: (context, paymentProvider, auraProvider, child) {
        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: auraProvider.currentAuraColor),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Ofrendas Digitales',
              style: GlowStyles.boldNeonText.copyWith(fontSize: 24),
            ),
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Nueva Ofrenda', icon: Icon(Icons.add_circle_outline)),
                Tab(text: 'Historial', icon: Icon(Icons.history)),
                Tab(text: 'Análisis', icon: Icon(Icons.analytics)),
              ],
              labelColor: auraProvider.currentAuraColor,
              unselectedLabelColor: Colors.grey,
              indicatorColor: auraProvider.currentAuraColor,
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildNewOfferingTab(paymentProvider, auraProvider),
              _buildHistoryTab(paymentProvider, auraProvider),
              _buildAnalyticsTab(paymentProvider, auraProvider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNewOfferingTab(DigitalPaymentProvider provider, AuraProvider auraProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTypeSelector(auraProvider),
          const SizedBox(height: 24),
          _buildAmountSection(auraProvider),
          const SizedBox(height: 24),
          _buildPaymentMethodSelector(provider, auraProvider),
          const SizedBox(height: 24),
          _buildRecurringOption(auraProvider),
          const SizedBox(height: 24),
          _buildDescriptionSection(auraProvider),
          const SizedBox(height: 24),
          _buildDedicationSection(auraProvider),
          const SizedBox(height: 32),
          _buildSubmitButton(provider, auraProvider),
        ],
      ),
    );
  }

  Widget _buildTypeSelector(AuraProvider auraProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tipo de Contribución',
          style: GlowStyles.boldNeonText.copyWith(fontSize: 18),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: TransactionType.values.map((type) {
            final isSelected = _selectedType == type;
            return GestureDetector(
              onTap: () => setState(() => _selectedType = type),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? auraProvider.currentAuraColor.withOpacity(0.2)
                      : Colors.grey[900],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected 
                        ? auraProvider.currentAuraColor 
                        : Colors.grey[700]!,
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: isSelected ? [
                    BoxShadow(
                      color: auraProvider.currentAuraColor.withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ] : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getTypeIcon(type),
                      color: isSelected 
                          ? auraProvider.currentAuraColor 
                          : Colors.grey[400],
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _getTypeDisplayName(type),
                      style: TextStyle(
                        color: isSelected 
                            ? auraProvider.currentAuraColor 
                            : Colors.grey[400],
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
      ],
    );
  }

  Widget _buildAmountSection(AuraProvider auraProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cantidad (SEK)',
          style: GlowStyles.boldNeonText.copyWith(fontSize: 18),
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
          style: TextStyle(color: Colors.grey[400], fontSize: 14),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _quickAmounts.map((amount) {
            return GestureDetector(
              onTap: () => setState(() {
                _amountController.text = amount.toInt().toString();
              }),
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
                  _currencyFormat.format(amount),
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

  Widget _buildPaymentMethodSelector(DigitalPaymentProvider provider, AuraProvider auraProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Método de Pago',
          style: GlowStyles.boldNeonText.copyWith(fontSize: 18),
        ),
        const SizedBox(height: 16),
        ...provider.paymentMethods.map((method) {
          final isSelected = _selectedProvider == method.provider;
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: isSelected 
                  ? method.brandColor.withOpacity(0.1) 
                  : Colors.grey[900],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? method.brandColor : Colors.grey[700]!,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: RadioListTile<PaymentProvider>(
              value: method.provider,
              groupValue: _selectedProvider,
              onChanged: (value) => setState(() => _selectedProvider = value),
              title: Row(
                children: [
                  Icon(method.icon, color: method.brandColor, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          method.displayName,
                          style: TextStyle(
                            color: isSelected ? method.brandColor : Colors.white,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        if (method.maskedAccount != null)
                          Text(
                            method.maskedAccount!,
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (method.isDefault)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: auraProvider.currentAuraColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Predeterminado',
                        style: TextStyle(
                          color: auraProvider.currentAuraColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              activeColor: method.brandColor,
              fillColor: WidgetStateProperty.all(method.brandColor),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildRecurringOption(AuraProvider auraProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Switch(
              value: _isRecurring,
              onChanged: (value) => setState(() => _isRecurring = value),
              activeColor: auraProvider.currentAuraColor,
            ),
            const SizedBox(width: 12),
            Text(
              'Pago Recurrente',
              style: GlowStyles.boldNeonText.copyWith(fontSize: 16),
            ),
          ],
        ),
        if (_isRecurring) ...[
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _recurringInterval,
            onChanged: (value) => setState(() => _recurringInterval = value!),
            decoration: InputDecoration(
              labelText: 'Frecuencia',
              labelStyle: TextStyle(color: auraProvider.currentAuraColor),
              fillColor: Colors.grey[900],
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            dropdownColor: Colors.grey[800],
            style: const TextStyle(color: Colors.white),
            items: const [
              DropdownMenuItem(value: 'weekly', child: Text('Semanal')),
              DropdownMenuItem(value: 'monthly', child: Text('Mensual')),
              DropdownMenuItem(value: 'quarterly', child: Text('Trimestral')),
              DropdownMenuItem(value: 'yearly', child: Text('Anual')),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildDescriptionSection(AuraProvider auraProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Descripción (Opcional)',
          style: GlowStyles.boldNeonText.copyWith(fontSize: 16),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _descriptionController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Agregar una nota...',
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
          style: GlowStyles.boldNeonText.copyWith(fontSize: 16),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _dedicatedToController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Dedicado a...',
            hintStyle: TextStyle(color: Colors.grey[600]),
            prefixIcon: Icon(Icons.favorite, color: auraProvider.currentAuraColor),
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

  Widget _buildSubmitButton(DigitalPaymentProvider provider, AuraProvider auraProvider) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: auraProvider.currentAuraColor
                    .withOpacity(_glowAnimation.value * 0.5),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: provider.isProcessingPayment ? null : _processPayment,
            style: ElevatedButton.styleFrom(
              backgroundColor: auraProvider.currentAuraColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: provider.isProcessingPayment
                ? const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Procesando...',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  )
                : Text(
                    _isRecurring 
                        ? 'Configurar Pago Recurrente'
                        : 'Procesar Ofrenda',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildHistoryTab(DigitalPaymentProvider provider, AuraProvider auraProvider) {
    if (provider.transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 64,
              color: Colors.grey[600],
            ),
            const SizedBox(height: 16),
            Text(
              'No hay transacciones aún',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 18,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: provider.transactions.length,
      itemBuilder: (context, index) {
        final transaction = provider.transactions[index];
        return _buildTransactionCard(transaction, auraProvider);
      },
    );
  }

  Widget _buildTransactionCard(DigitalTransaction transaction, AuraProvider auraProvider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a2e),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _currencyFormat.format(transaction.amount),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: transaction.status.statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      transaction.status.statusIcon,
                      size: 12,
                      color: transaction.status.statusColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      transaction.status.displayName,
                      style: TextStyle(
                        color: transaction.status.statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.payment,
                size: 16,
                color: transaction.paymentProvider.brandColor,
              ),
              const SizedBox(width: 8),
              Text(
                transaction.paymentProvider.displayName,
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                ),
              ),
            ],
          ),
          if (transaction.description != null) ...[
            const SizedBox(height: 8),
            Text(
              transaction.description!,
              style: TextStyle(
                color: Colors.grey[300],
                fontSize: 14,
              ),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            'Fecha: ${DateFormat('dd/MM/yyyy HH:mm').format(transaction.createdAt)}',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsTab(DigitalPaymentProvider provider, AuraProvider auraProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAnalyticsCard(
            'Total Donado Este Mes',
            _currencyFormat.format(provider.totalDonatedThisMonth),
            Icons.trending_up,
            auraProvider.currentAuraColor,
          ),
          const SizedBox(height: 16),
          _buildAnalyticsCard(
            'Total Comisiones',
            _currencyFormat.format(provider.totalFeesThisMonth),
            Icons.receipt,
            Colors.orange[400]!,
          ),
          const SizedBox(height: 16),
          _buildAnalyticsCard(
            'Transacciones Completadas',
            provider.completedTransactions.length.toString(),
            Icons.check_circle,
            Colors.green[400]!,
          ),
          const SizedBox(height: 24),
          Text(
            'Por Método de Pago',
            style: GlowStyles.boldNeonText.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 16),
          ...provider.donationsByProvider.entries.map((entry) {
            return _buildProviderAnalytics(entry.key, entry.value);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildAnalyticsCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a2e),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24, width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProviderAnalytics(PaymentProvider provider, double amount) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: provider.brandColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: provider.brandColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.payment,
            color: provider.brandColor,
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              provider.displayName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            _currencyFormat.format(amount),
            style: TextStyle(
              color: provider.brandColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _processPayment() async {
    if (_selectedProvider == null) {
      _showErrorSnackBar('Por favor selecciona un método de pago');
      return;
    }

    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      _showErrorSnackBar('Por favor ingresa una cantidad válida');
      return;
    }

    final provider = context.read<DigitalPaymentProvider>();

    bool success;
    if (_isRecurring) {
      success = await provider.setupRecurringPayment(
        amount: amount,
        provider: _selectedProvider!,
        type: _selectedType,
        interval: _recurringInterval,
        description: _descriptionController.text.isEmpty 
            ? null 
            : _descriptionController.text,
      );
    } else {
      success = await provider.processPayment(
        amount: amount,
        provider: _selectedProvider!,
        type: _selectedType,
        description: _descriptionController.text.isEmpty 
            ? null 
            : _descriptionController.text,
        dedicatedTo: _dedicatedToController.text.isEmpty 
            ? null 
            : _dedicatedToController.text,
        message: _messageController.text.isEmpty 
            ? null 
            : _messageController.text,
      );
    }

    if (success) {
      _showSuccessSnackBar(
        _isRecurring 
            ? 'Pago recurrente configurado exitosamente'
            : 'Ofrenda procesada exitosamente'
      );
      _clearForm();
      _tabController.animateTo(1); // Switch to history tab
    } else {
      _showErrorSnackBar(provider.error ?? 'Error al procesar el pago');
    }
  }

  void _clearForm() {
    _amountController.clear();
    _descriptionController.clear();
    _dedicatedToController.clear();
    _messageController.clear();
    setState(() {
      _selectedType = TransactionType.offering;
      _selectedProvider = null;
      _isRecurring = false;
      _recurringInterval = 'monthly';
    });
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green[600],
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[600],
        duration: const Duration(seconds: 3),
      ),
    );
  }

  IconData _getTypeIcon(TransactionType type) {
    switch (type) {
      case TransactionType.offering:
        return Icons.volunteer_activism;
      case TransactionType.tithe:
        return Icons.account_balance;
      case TransactionType.donation:
        return Icons.favorite;
      case TransactionType.merchandise:
        return Icons.shopping_bag;
      case TransactionType.event_ticket:
        return Icons.event_seat;
      case TransactionType.subscription:
        return Icons.subscriptions;
      case TransactionType.gift:
        return Icons.card_giftcard;
    }
  }

  String _getTypeDisplayName(TransactionType type) {
    switch (type) {
      case TransactionType.offering:
        return 'Ofrenda';
      case TransactionType.tithe:
        return 'Diezmo';
      case TransactionType.donation:
        return 'Donación';
      case TransactionType.merchandise:
        return 'Mercancía';
      case TransactionType.event_ticket:
        return 'Entrada Evento';
      case TransactionType.subscription:
        return 'Suscripción';
      case TransactionType.gift:
        return 'Regalo';
    }
  }
}
