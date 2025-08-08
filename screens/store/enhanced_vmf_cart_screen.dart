import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/store/vmf_cart_model.dart';
import '../../models/store/vmf_product_model.dart';
import '../../providers/aura_provider.dart';
import '../../widgets/store/enhanced_vmf_cart_item.dart';
import '../../widgets/gradient_text.dart';
import 'enhanced_vmf_checkout_screen.dart';

class EnhancedVMFCartScreen extends StatefulWidget {
  const EnhancedVMFCartScreen({Key? key}) : super(key: key);

  @override
  State<EnhancedVMFCartScreen> createState() => _EnhancedVMFCartScreenState();
}

class _EnhancedVMFCartScreenState extends State<EnhancedVMFCartScreen>
    with TickerProviderStateMixin {
  late AnimationController _headerController;
  late AnimationController _summaryController;
  late Animation<double> _headerAnimation;
  late Animation<double> _summaryAnimation;
  late Animation<Offset> _summarySlideAnimation;

  @override
  void initState() {
    super.initState();
    
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _summaryController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _headerAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeOutCubic,
    ));

    _summaryAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _summaryController,
      curve: Curves.elasticOut,
    ));

    _summarySlideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _summaryController,
      curve: Curves.easeOutCubic,
    ));

    // Start animations
    _headerController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _summaryController.forward();
    });
  }

  @override
  void dispose() {
    _headerController.dispose();
    _summaryController.dispose();
    super.dispose();
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
            colors: [
              Colors.black,
              Colors.grey[900]!,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(auraColor),
              Expanded(
                child: Consumer<VMFCartModel>(
                  builder: (context, cartModel, child) {
                    if (cartModel.isEmpty) {
                      return _buildEmptyCart(auraColor);
                    }
                    return _buildCartContent(cartModel, auraColor);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Color auraColor) {
    return FadeTransition(
      opacity: _headerAnimation,
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                Navigator.pop(context);
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[900]?.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: auraColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.arrow_back_ios,
                  color: auraColor,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: GradientText(
                text: 'Mi Carrito VMF',
                colors: [auraColor, auraColor.withOpacity(0.7)],
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Consumer<VMFCartModel>(
              builder: (context, cartModel, child) {
                if (cartModel.isEmpty) return const SizedBox.shrink();
                
                return GestureDetector(
                  onTap: () => _showClearCartDialog(cartModel),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.red.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.delete_sweep,
                      color: Colors.red,
                      size: 20,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCart(Color auraColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: auraColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(60),
            ),
            child: Icon(
              Icons.shopping_cart_outlined,
              size: 60,
              color: auraColor.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Tu carrito está vacío',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Explora nuestra tienda y encuentra\nproductos espirituales únicos',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 32),
          GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              Navigator.pop(context);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [auraColor, auraColor.withOpacity(0.8)],
                ),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: auraColor.withOpacity(0.3),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Text(
                'Continuar Comprando',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartContent(VMFCartModel cartModel, Color auraColor) {
    return Column(
      children: [
        // Cart Items List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: cartModel.items.length,
            itemBuilder: (context, index) {
              final item = cartModel.items[index];
              return EnhancedVMFCartItem(
                product: item.product,
                quantity: item.quantity,
                onRemove: () {
                  HapticFeedback.mediumImpact();
                  cartModel.removeFromCart(item.product.id);
                  _showSnackBar('${item.product.name} eliminado del carrito', Colors.red);
                },
                onQuantityChanged: (newQuantity) {
                  cartModel.updateQuantity(item.product.id, newQuantity);
                },
                onTap: () {
                  // Navigate to product detail
                  _navigateToProductDetail(item.product);
                },
              );
            },
          ),
        ),
        
        // Cart Summary
        _buildCartSummary(cartModel, auraColor),
      ],
    );
  }

  Widget _buildCartSummary(VMFCartModel cartModel, Color auraColor) {
    return SlideTransition(
      position: _summarySlideAnimation,
      child: ScaleTransition(
        scale: _summaryAnimation,
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.grey[900]?.withOpacity(0.9),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: auraColor.withOpacity(0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: auraColor.withOpacity(0.2),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            children: [
              // Summary Header
              Row(
                children: [
                  Icon(
                    Icons.receipt_long,
                    color: auraColor,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Resumen del Pedido',
                    style: TextStyle(
                      color: auraColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              const Divider(color: Colors.grey, height: 1),
              const SizedBox(height: 16),
              
              // Summary Details
              _buildSummaryRow('Productos (${cartModel.itemCount})', 
                  '\$${cartModel.subtotal.toStringAsFixed(2)}'),
              const SizedBox(height: 8),
              _buildSummaryRow('Envío', 'Gratis'),
              const SizedBox(height: 8),
              _buildSummaryRow('Impuestos', '\$${(cartModel.subtotal * 0.1).toStringAsFixed(2)}'),
              
              const SizedBox(height: 16),
              const Divider(color: Colors.grey, height: 1),
              const SizedBox(height: 16),
              
              // Total
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '\$${cartModel.total.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: auraColor,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Checkout Button
              GestureDetector(
                onTap: () => _proceedToCheckout(cartModel),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [auraColor, auraColor.withOpacity(0.8)],
                    ),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: auraColor.withOpacity(0.4),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.payment,
                        color: Colors.black,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Proceder al Pago',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 16,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  void _showClearCartDialog(VMFCartModel cartModel) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text(
            'Vaciar Carrito',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            '¿Estás seguro de que quieres eliminar todos los productos del carrito?',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                cartModel.clearCart();
                _showSnackBar('Carrito vaciado', Colors.red);
              },
              child: const Text(
                'Vaciar',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void _proceedToCheckout(VMFCartModel cartModel) {
    HapticFeedback.mediumImpact();
    
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const EnhancedVMFCheckoutScreen(),
      ),
    );
  }

  void _navigateToProductDetail(VMFProduct product) {
    // TODO: Navigate to product detail screen
    _showSnackBar('Navegando a ${product.name}', Colors.blue);
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
