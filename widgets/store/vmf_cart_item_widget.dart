import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/store/vmf_cart_model.dart';
import '../../providers/aura_provider.dart';
import '../gradient_text.dart';

class VMFCartItemWidget extends StatefulWidget {
  final VMFCartItem item;
  final VoidCallback? onRemove;
  final Function(int)? onQuantityChanged;
  final bool enableQuantityControls;

  const VMFCartItemWidget({
    Key? key,
    required this.item,
    this.onRemove,
    this.onQuantityChanged,
    this.enableQuantityControls = true,
  }) : super(key: key);

  @override
  State<VMFCartItemWidget> createState() => _VMFCartItemWidgetState();
}

class _VMFCartItemWidgetState extends State<VMFCartItemWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _removeItem() async {
    await _animationController.reverse();
    widget.onRemove?.call();
  }

  @override
  Widget build(BuildContext context) {
    final auraProvider = Provider.of<AuraProvider>(context);
    final auraColor = auraProvider.currentAuraColor;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset((1 - _slideAnimation.value) * 100, 0),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
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
                boxShadow: [
                  BoxShadow(
                    color: auraColor.withOpacity(0.2),
                    blurRadius: 15,
                    spreadRadius: 1,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Imagen del producto
                    _buildProductImage(),
                    
                    const SizedBox(width: 16),
                    
                    // Información del producto
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildProductName(),
                          const SizedBox(height: 4),
                          _buildProductDetails(),
                          const SizedBox(height: 8),
                          _buildPriceRow(auraColor),
                        ],
                      ),
                    ),
                    
                    const SizedBox(width: 16),
                    
                    // Controles de cantidad y eliminar
                    Column(
                      children: [
                        _buildRemoveButton(),
                        const SizedBox(height: 16),
                        if (widget.enableQuantityControls)
                          _buildQuantityControls(auraColor),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProductImage() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: widget.item.product.featuredImage != null
            ? DecorationImage(
                image: NetworkImage(widget.item.product.featuredImage!),
                fit: BoxFit.cover,
              )
            : null,
        gradient: widget.item.product.featuredImage == null
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  widget.item.product.categoryColor.withOpacity(0.3),
                  widget.item.product.categoryColor.withOpacity(0.1),
                ],
              )
            : null,
      ),
      child: widget.item.product.featuredImage == null
          ? Center(
              child: Icon(
                widget.item.product.categoryIcon,
                size: 32,
                color: widget.item.product.categoryColor,
              ),
            )
          : null,
    );
  }

  Widget _buildProductName() {
    return GradientText(
      text: widget.item.displayName,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        height: 1.2,
      ),
      colors: [
        Colors.white,
        Colors.white.withOpacity(0.8),
      ],
    );
  }

  Widget _buildProductDetails() {
    final details = <String>[];
    
    if (widget.item.product.author != null) {
      details.add('por ${widget.item.product.author}');
    } else if (widget.item.product.artist != null) {
      details.add('por ${widget.item.product.artist}');
    }
    
    if (widget.item.variation != null) {
      widget.item.variation!.attributes.forEach((key, value) {
        details.add('$key: $value');
      });
    }
    
    if (widget.item.product.isDigital) {
      details.add('Descarga digital');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: details.map((detail) => Padding(
        padding: const EdgeInsets.only(bottom: 2),
        child: Text(
          detail,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 12,
          ),
        ),
      )).toList(),
    );
  }

  Widget _buildPriceRow(Color auraColor) {
    return Row(
      children: [
        if (widget.item.quantity > 1)
          Text(
            '${widget.item.unitPrice.toStringAsFixed(0)} SEK × ${widget.item.quantity}',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
        const SizedBox(width: 8),
        GradientText(
          text: '${widget.item.totalPrice.toStringAsFixed(0)} SEK',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          colors: [
            auraColor,
            auraColor.withOpacity(0.7),
          ],
        ),
      ],
    );
  }

  Widget _buildRemoveButton() {
    return GestureDetector(
      onTap: _removeItem,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.red.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: const Icon(
          Icons.delete_outline,
          color: Colors.red,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildQuantityControls(Color auraColor) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: auraColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildQuantityButton(
            icon: Icons.remove,
            onTap: () {
              if (widget.item.quantity > 1) {
                widget.onQuantityChanged?.call(widget.item.quantity - 1);
              }
            },
            enabled: widget.item.quantity > 1,
          ),
          Container(
            width: 40,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              '${widget.item.quantity}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          _buildQuantityButton(
            icon: Icons.add,
            onTap: () {
              widget.onQuantityChanged?.call(widget.item.quantity + 1);
            },
            enabled: widget.item.product.isAvailable,
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool enabled,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Icon(
          icon,
          color: enabled ? Colors.white : Colors.white.withOpacity(0.3),
          size: 16,
        ),
      ),
    );
  }
}