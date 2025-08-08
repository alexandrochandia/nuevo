import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/store/vmf_cart_model.dart';
import '../../providers/aura_provider.dart';
import '../../widgets/store/vmf_cart_item_widget.dart';
import '../../widgets/gradient_text.dart';
import '../../widgets/custom_blur_button.dart';


class VMFCartScreen extends StatefulWidget {
  const VMFCartScreen({Key? key}) : super(key: key);

  @override
  State<VMFCartScreen> createState() => _VMFCartScreenState();
}

class _VMFCartScreenState extends State<VMFCartScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _couponController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // screenScrollController = _scrollController;
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    _couponController.dispose();
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
          child: Consumer<VMFCartModel>(
            builder: (context, cartModel, child) {
              if (cartModel.isEmpty) {
                return _buildEmptyCart(auraColor);
              }

              return Column(
                children: [
                  _buildHeader(auraColor, cartModel),
                  Expanded(
                    child: _buildCartContent(cartModel, auraColor),
                  ),
                  _buildBottomSummary(cartModel, auraColor),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Color auraColor, VMFCartModel cartModel) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: auraColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: const Icon(Icons.arrow_back, color: Colors.white),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GradientText(
                  text: 'Mi Carrito',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  colors: [
                    auraColor,
                    auraColor.withOpacity(0.7),
                  ],
                ),
                Text(
                  '${cartModel.itemCount} producto${cartModel.itemCount != 1 ? 's' : ''}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          if (cartModel.isNotEmpty)
            CustomBlurButton(
              text: 'Limpiar',
              icon: Icons.delete_outline,
              onPressed: () => _showClearCartDialog(cartModel),
              backgroundColor: Colors.red.withOpacity(0.7),
              textColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
        ],
      ),
    );
  }

  Widget _buildCartContent(VMFCartModel cartModel, Color auraColor) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            // Items del carrito
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: cartModel.items.length,
              itemBuilder: (context, index) {
                final item = cartModel.items[index];
                return VMFCartItemWidget(
                  item: item,
                  onRemove: () => cartModel.removeFromCart(item.id),
                  onQuantityChanged: (newQuantity) => 
                      cartModel.updateQuantity(item.id, newQuantity),
                );
              },
            ),
            
            const SizedBox(height: 20),
            
            // Sección de cupón
            _buildCouponSection(cartModel, auraColor),
            
            const SizedBox(height: 20),
            
            // Resumen de costos
            _buildCostSummary(cartModel, auraColor),
            
            const SizedBox(height: 100), // Espacio para el bottom bar
          ],
        ),
      ),
    );
  }

  Widget _buildCouponSection(VMFCartModel cartModel, Color auraColor) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
        ),
        border: Border.all(
          color: auraColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.local_offer,
                color: auraColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              GradientText(
                text: 'Código de descuento',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                colors: [
                  Colors.white,
                  Colors.white.withOpacity(0.8),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          if (cartModel.appliedCoupon != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.green.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Cupón aplicado: ${cartModel.appliedCoupon!.code}',
                          style: const TextStyle(
                            color: Colors.green,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          cartModel.appliedCoupon!.description,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => cartModel.removeCoupon(),
                    icon: const Icon(Icons.close, color: Colors.red, size: 20),
                  ),
                ],
              ),
            ),
          ] else ...[
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _couponController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Ingresa tu código',
                      hintStyle: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                      ),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.white.withOpacity(0.3),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.white.withOpacity(0.3),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: auraColor,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                CustomBlurButton(
                  text: 'Aplicar',
                  onPressed: () => _applyCoupon(cartModel),
                  backgroundColor: auraColor,
                  textColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCostSummary(VMFCartModel cartModel, Color auraColor) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
        ),
        border: Border.all(
          color: auraColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          _buildSummaryRow('Subtotal', cartModel.formattedSubtotal),
          
          if (cartModel.discountAmount > 0) ...[
            const SizedBox(height: 8),
            _buildSummaryRow(
              'Descuento', 
              '-${cartModel.formattedDiscount}',
              color: Colors.green,
            ),
          ],
          
          if (cartModel.shippingCost > 0) ...[
            const SizedBox(height: 8),
            _buildSummaryRow('Envío', cartModel.formattedShipping),
          ],
          
          const Divider(
            color: Colors.white24,
            height: 24,
          ),
          
          Row(
            children: [
              GradientText(
                text: 'Total',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                colors: [
                  Colors.white,
                  Colors.white.withOpacity(0.8),
                ],
              ),
              const Spacer(),
              GradientText(
                text: cartModel.formattedTotal,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                colors: [
                  auraColor,
                  auraColor.withOpacity(0.7),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {Color? color}) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 14,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            color: color ?? Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomSummary(VMFCartModel cartModel, Color auraColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.9),
        border: Border(
          top: BorderSide(
            color: auraColor.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Total a pagar',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                  GradientText(
                    text: cartModel.formattedTotal,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    colors: [
                      auraColor,
                      auraColor.withOpacity(0.7),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CustomBlurButton(
                text: 'Proceder al pago',
                icon: Icons.payment,
                onPressed: () => _proceedToCheckout(cartModel),
                backgroundColor: auraColor,
                textColor: Colors.white,
                borderRadius: 25,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCart(Color auraColor) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: auraColor.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: auraColor.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.shopping_cart_outlined,
                size: 64,
                color: auraColor,
              ),
            ),
            
            const SizedBox(height: 24),
            
            GradientText(
              text: 'Tu carrito está vacío',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              colors: [
                Colors.white,
                Colors.white.withOpacity(0.8),
              ],
            ),
            
            const SizedBox(height: 8),
            
            Text(
              'Agrega productos de nuestra tienda espiritual',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 32),
            
            CustomBlurButton(
              text: 'Explorar tienda',
              icon: Icons.store,
              onPressed: () => Navigator.pop(context),
              backgroundColor: auraColor,
              textColor: Colors.white,
              borderRadius: 25,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ],
        ),
      ),
    );
  }

  // Métodos de acción
  void _applyCoupon(VMFCartModel cartModel) {
    final code = _couponController.text.trim();
    if (code.isEmpty) return;

    // TODO: Implementar validación real de cupones
    // Por ahora, simulamos algunos cupones válidos
    final mockCoupons = {
      'VMF10': VMFCoupon(
        code: 'VMF10',
        description: '10% de descuento en toda la tienda',
        discountValue: 10,
        isPercentage: true,
      ),
      'WELCOME50': VMFCoupon(
        code: 'WELCOME50',
        description: '50 SEK de descuento',
        discountValue: 50,
        minimumAmount: 200,
      ),
      'FREESHIPING': VMFCoupon(
        code: 'FREESHIPING',
        description: 'Envío gratuito',
        discountValue: cartModel.shippingCost,
      ),
    };

    final coupon = mockCoupons[code.toUpperCase()];
    if (coupon != null) {
      cartModel.applyCoupon(coupon).then((success) {
        if (success) {
          _couponController.clear();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cupón aplicado correctamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Código de cupón inválido'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showClearCartDialog(VMFCartModel cartModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          '¿Limpiar carrito?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Se eliminarán todos los productos del carrito. Esta acción no se puede deshacer.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              cartModel.clearCart();
              Navigator.pop(context);
            },
            child: const Text(
              'Limpiar',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _proceedToCheckout(VMFCartModel cartModel) {
    // TODO: Implementar checkout
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Función de checkout próximamente disponible'),
        backgroundColor: Colors.blue,
      ),
    );
  }
}