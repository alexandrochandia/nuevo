import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/store/vmf_cart_model.dart';
import '../../providers/aura_provider.dart';
import '../../widgets/gradient_text.dart';

enum CheckoutStep { shipping, payment, review, success }
enum PaymentMethod { card, swish, klarna, paypal }

class EnhancedVMFCheckoutScreen extends StatefulWidget {
  const EnhancedVMFCheckoutScreen({Key? key}) : super(key: key);

  @override
  State<EnhancedVMFCheckoutScreen> createState() => _EnhancedVMFCheckoutScreenState();
}

class _EnhancedVMFCheckoutScreenState extends State<EnhancedVMFCheckoutScreen>
    with TickerProviderStateMixin {
  CheckoutStep currentStep = CheckoutStep.shipping;
  PaymentMethod selectedPayment = PaymentMethod.card;
  
  late AnimationController _stepController;
  late AnimationController _successController;
  late Animation<double> _stepAnimation;
  late Animation<double> _successAnimation;

  // Form controllers
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _postalCodeController = TextEditingController();

  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    
    _stepController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _successController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _stepAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _stepController, curve: Curves.easeOutCubic));

    _successAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _successController, curve: Curves.elasticOut));

    _stepController.forward();
  }

  @override
  void dispose() {
    _stepController.dispose();
    _successController.dispose();
    _emailController.dispose();
    _nameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (currentStep == CheckoutStep.success) return;
    
    setState(() {
      switch (currentStep) {
        case CheckoutStep.shipping:
          currentStep = CheckoutStep.payment;
          break;
        case CheckoutStep.payment:
          currentStep = CheckoutStep.review;
          break;
        case CheckoutStep.review:
          _processPayment();
          break;
        case CheckoutStep.success:
          break;
      }
    });
    
    _stepController.reset();
    _stepController.forward();
  }

  void _previousStep() {
    if (currentStep == CheckoutStep.shipping) {
      Navigator.pop(context);
      return;
    }
    
    setState(() {
      switch (currentStep) {
        case CheckoutStep.payment:
          currentStep = CheckoutStep.shipping;
          break;
        case CheckoutStep.review:
          currentStep = CheckoutStep.payment;
          break;
        case CheckoutStep.success:
          currentStep = CheckoutStep.review;
          break;
        case CheckoutStep.shipping:
          break;
      }
    });
    
    _stepController.reset();
    _stepController.forward();
  }

  Future<void> _processPayment() async {
    setState(() => _isProcessing = true);
    
    // Simulate payment processing
    await Future.delayed(const Duration(seconds: 3));
    
    setState(() {
      _isProcessing = false;
      currentStep = CheckoutStep.success;
    });
    
    _successController.forward();
    
    // Clear cart after successful payment
    final cartModel = Provider.of<VMFCartModel>(context, listen: false);
    cartModel.clearCart();
  }

  @override
  Widget build(BuildContext context) {
    final auraProvider = Provider.of<AuraProvider>(context);
    final auraColor = auraProvider.currentAuraColor;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black, Colors.grey[900]!],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(auraColor),
              _buildProgressIndicator(auraColor),
              Expanded(child: _buildStepContent(auraColor)),
              if (currentStep != CheckoutStep.success)
                _buildBottomNavigation(auraColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Color auraColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              _previousStep();
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[900]?.withOpacity(0.8),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: auraColor.withOpacity(0.3), width: 1),
              ),
              child: Icon(Icons.arrow_back_ios, color: auraColor, size: 20),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: GradientText(
              text: _getStepTitle(),
              colors: [auraColor, auraColor.withOpacity(0.7)],
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  String _getStepTitle() {
    switch (currentStep) {
      case CheckoutStep.shipping: return 'Información de Envío';
      case CheckoutStep.payment: return 'Método de Pago';
      case CheckoutStep.review: return 'Revisar Pedido';
      case CheckoutStep.success: return '¡Pedido Completado!';
    }
  }

  Widget _buildProgressIndicator(Color auraColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          _buildProgressStep(0, 'Envío', CheckoutStep.shipping, auraColor),
          _buildProgressLine(0, auraColor),
          _buildProgressStep(1, 'Pago', CheckoutStep.payment, auraColor),
          _buildProgressLine(1, auraColor),
          _buildProgressStep(2, 'Revisar', CheckoutStep.review, auraColor),
          _buildProgressLine(2, auraColor),
          _buildProgressStep(3, 'Listo', CheckoutStep.success, auraColor),
        ],
      ),
    );
  }

  Widget _buildProgressStep(int index, String title, CheckoutStep step, Color auraColor) {
    final isActive = currentStep.index >= index;
    final isCurrent = currentStep == step;
    
    return Column(
      children: [
        Container(
          width: 32, height: 32,
          decoration: BoxDecoration(
            color: isActive ? auraColor : Colors.grey[700],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isCurrent ? auraColor : Colors.transparent, width: 2),
            boxShadow: isActive ? [BoxShadow(color: auraColor.withOpacity(0.3), blurRadius: 8, spreadRadius: 1)] : null,
          ),
          child: Icon(isActive ? Icons.check : Icons.circle, color: isActive ? Colors.black : Colors.white, size: 16),
        ),
        const SizedBox(height: 4),
        Text(title, style: TextStyle(color: isActive ? auraColor : Colors.grey[600], fontSize: 10, fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
      ],
    );
  }

  Widget _buildProgressLine(int index, Color auraColor) {
    final isActive = currentStep.index > index;
    return Expanded(
      child: Container(
        height: 2, margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(color: isActive ? auraColor : Colors.grey[700], borderRadius: BorderRadius.circular(1)),
      ),
    );
  }

  Widget _buildStepContent(Color auraColor) {
    return FadeTransition(
      opacity: _stepAnimation,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: _getCurrentStepWidget(auraColor),
      ),
    );
  }

  Widget _getCurrentStepWidget(Color auraColor) {
    switch (currentStep) {
      case CheckoutStep.shipping: return _buildShippingForm(auraColor);
      case CheckoutStep.payment: return _buildPaymentForm(auraColor);
      case CheckoutStep.review: return _buildReviewStep(auraColor);
      case CheckoutStep.success: return _buildSuccessStep(auraColor);
    }
  }

  Widget _buildShippingForm(Color auraColor) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Información de Contacto', auraColor),
          const SizedBox(height: 16),
          _buildTextField('Email', _emailController, auraColor, keyboardType: TextInputType.emailAddress),
          const SizedBox(height: 16),
          _buildTextField('Nombre Completo', _nameController, auraColor),
          const SizedBox(height: 32),
          _buildSectionTitle('Dirección de Envío', auraColor),
          const SizedBox(height: 16),
          _buildTextField('Dirección', _addressController, auraColor),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(flex: 2, child: _buildTextField('Ciudad', _cityController, auraColor)),
              const SizedBox(width: 16),
              Expanded(child: _buildTextField('Código Postal', _postalCodeController, auraColor, keyboardType: TextInputType.number)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentForm(Color auraColor) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Selecciona Método de Pago', auraColor),
          const SizedBox(height: 16),
          _buildPaymentMethodOption(PaymentMethod.card, 'Tarjeta de Crédito/Débito', Icons.credit_card, auraColor),
          _buildPaymentMethodOption(PaymentMethod.swish, 'Swish', Icons.phone_android, auraColor),
          _buildPaymentMethodOption(PaymentMethod.klarna, 'Klarna', Icons.payment, auraColor),
          _buildPaymentMethodOption(PaymentMethod.paypal, 'PayPal', Icons.account_balance_wallet, auraColor),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodOption(PaymentMethod method, String title, IconData icon, Color auraColor) {
    final isSelected = selectedPayment == method;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() => selectedPayment = method);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? auraColor.withOpacity(0.1) : Colors.grey[900]?.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? auraColor : Colors.grey[700]!, width: isSelected ? 2 : 1),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? auraColor : Colors.white, size: 24),
            const SizedBox(width: 16),
            Expanded(child: Text(title, style: TextStyle(color: isSelected ? auraColor : Colors.white, fontSize: 16, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal))),
            if (isSelected) Icon(Icons.check_circle, color: auraColor, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewStep(Color auraColor) {
    return Consumer<VMFCartModel>(
      builder: (context, cartModel, child) {
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Resumen del Pedido', auraColor),
              const SizedBox(height: 16),
              ...cartModel.items.map((item) => _buildOrderItem(item, auraColor)),
              const SizedBox(height: 24),
              _buildOrderSummary(cartModel, auraColor),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSuccessStep(Color auraColor) {
    return ScaleTransition(
      scale: _successAnimation,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120, height: 120,
              decoration: BoxDecoration(color: auraColor.withOpacity(0.2), borderRadius: BorderRadius.circular(60)),
              child: Icon(Icons.check_circle, size: 80, color: auraColor),
            ),
            const SizedBox(height: 32),
            Text('¡Pedido Completado!', style: TextStyle(color: auraColor, fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Text('Gracias por tu compra en VMF Sweden.\nRecibirás un email de confirmación pronto.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 16)),
            const SizedBox(height: 32),
            GestureDetector(
              onTap: () {
                HapticFeedback.mediumImpact();
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [auraColor, auraColor.withOpacity(0.8)]),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [BoxShadow(color: auraColor.withOpacity(0.3), blurRadius: 12, spreadRadius: 2)],
                ),
                child: const Text('Volver al Inicio', style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, Color auraColor) {
    return Text(title, style: TextStyle(color: auraColor, fontSize: 18, fontWeight: FontWeight.bold));
  }

  Widget _buildTextField(String label, TextEditingController controller, Color auraColor, {TextInputType keyboardType = TextInputType.text}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900]?.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: auraColor.withOpacity(0.3), width: 1),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: auraColor.withOpacity(0.7)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildOrderItem(VMFCartItem item, Color auraColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900]?.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: auraColor.withOpacity(0.2), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 60, height: 60,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: auraColor.withOpacity(0.3), width: 1)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: (item.product.featuredImage?.isNotEmpty ?? false)
                  ? Image.network(item.product.featuredImage!, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => Icon(Icons.image, color: auraColor.withOpacity(0.5)))
                  : Icon(Icons.image, color: auraColor.withOpacity(0.5)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.product.name, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text('Cantidad: ${item.quantity}', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14)),
              ],
            ),
          ),
          Text('\$${(item.product.price * item.quantity).toStringAsFixed(2)}', style: TextStyle(color: auraColor, fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildOrderSummary(VMFCartModel cartModel, Color auraColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900]?.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: auraColor.withOpacity(0.3), width: 1),
      ),
      child: Column(
        children: [
          _buildSummaryRow('Subtotal', '\$${cartModel.subtotal.toStringAsFixed(2)}'),
          const SizedBox(height: 8),
          _buildSummaryRow('Envío', 'Gratis'),
          const SizedBox(height: 8),
          _buildSummaryRow('Impuestos', '\$${(cartModel.subtotal * 0.1).toStringAsFixed(2)}'),
          const SizedBox(height: 16),
          const Divider(color: Colors.grey),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              Text('\$${cartModel.total.toStringAsFixed(2)}', style: TextStyle(color: auraColor, fontSize: 24, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 16)),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildBottomNavigation(Color auraColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[900]?.withOpacity(0.9),
        border: Border(top: BorderSide(color: auraColor.withOpacity(0.2), width: 1)),
      ),
      child: Row(
        children: [
          if (currentStep != CheckoutStep.shipping)
            Expanded(
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  _previousStep();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(color: Colors.grey[800], borderRadius: BorderRadius.circular(12), border: Border.all(color: auraColor.withOpacity(0.3), width: 1)),
                  child: const Text('Anterior', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
            ),
          if (currentStep != CheckoutStep.shipping) const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: _isProcessing ? null : () {
                HapticFeedback.mediumImpact();
                _nextStep();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  gradient: _isProcessing ? null : LinearGradient(colors: [auraColor, auraColor.withOpacity(0.8)]),
                  color: _isProcessing ? Colors.grey[700] : null,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: _isProcessing ? null : [BoxShadow(color: auraColor.withOpacity(0.3), blurRadius: 12, spreadRadius: 2)],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_isProcessing) const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white))),
                    if (_isProcessing) const SizedBox(width: 8),
                    Text(_isProcessing ? 'Procesando...' : _getButtonText(), style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getButtonText() {
    switch (currentStep) {
      case CheckoutStep.shipping: return 'Continuar';
      case CheckoutStep.payment: return 'Continuar';
      case CheckoutStep.review: return 'Completar Pedido';
      case CheckoutStep.success: return 'Finalizar';
    }
  }
}
