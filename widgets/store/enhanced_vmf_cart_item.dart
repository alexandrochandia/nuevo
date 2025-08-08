import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/store/vmf_product_model.dart';
import '../../providers/aura_provider.dart';

class EnhancedVMFCartItem extends StatefulWidget {
  final VMFProduct product;
  final int quantity;
  final VoidCallback? onRemove;
  final Function(int)? onQuantityChanged;
  final VoidCallback? onTap;

  const EnhancedVMFCartItem({
    Key? key,
    required this.product,
    required this.quantity,
    this.onRemove,
    this.onQuantityChanged,
    this.onTap,
  }) : super(key: key);

  @override
  State<EnhancedVMFCartItem> createState() => _EnhancedVMFCartItemState();
}

class _EnhancedVMFCartItemState extends State<EnhancedVMFCartItem>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  bool _isRemoving = false;

  @override
  void initState() {
    super.initState();
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(-1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeIn,
    ));

    // Start entrance animation
    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _handleRemove() async {
    if (_isRemoving) return;
    
    setState(() => _isRemoving = true);
    
    HapticFeedback.mediumImpact();
    
    // Animate out
    await _slideController.reverse();
    
    if (widget.onRemove != null) {
      widget.onRemove!();
    }
  }

  void _handleQuantityChange(int delta) {
    final newQuantity = widget.quantity + delta;
    if (newQuantity > 0 && widget.onQuantityChanged != null) {
      HapticFeedback.lightImpact();
      widget.onQuantityChanged!(newQuantity);
    } else if (newQuantity <= 0) {
      _handleRemove();
    }
  }

  double get _itemTotal => widget.product.price * widget.quantity;

  @override
  Widget build(BuildContext context) {
    final auraProvider = Provider.of<AuraProvider>(context);
    final auraColor = auraProvider.currentAuraColor;

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[900]?.withOpacity(0.8),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: auraColor.withOpacity(0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: auraColor.withOpacity(0.1),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.onTap,
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        // Product Image
                        _buildProductImage(auraColor),
                        const SizedBox(width: 16),
                        
                        // Product Details
                        Expanded(
                          child: _buildProductDetails(auraColor),
                        ),
                        
                        // Quantity Controls
                        _buildQuantityControls(auraColor),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductImage(Color auraColor) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: auraColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: (widget.product.featuredImage?.isNotEmpty ?? false)
            ? Image.network(
                widget.product.featuredImage!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildImagePlaceholder(auraColor);
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return _buildImagePlaceholder(auraColor);
                },
              )
            : _buildImagePlaceholder(auraColor),
      ),
    );
  }

  Widget _buildImagePlaceholder(Color auraColor) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            auraColor.withOpacity(0.1),
            auraColor.withOpacity(0.05),
          ],
        ),
      ),
      child: Icon(
        Icons.image,
        color: auraColor.withOpacity(0.5),
        size: 32,
      ),
    );
  }

  Widget _buildProductDetails(Color auraColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Product Name
        Text(
          widget.product.name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        
        const SizedBox(height: 4),
        
        // Product Category
        if (widget.product.category.name.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: auraColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              widget.product.category.name,
              style: TextStyle(
                color: auraColor,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        
        const SizedBox(height: 8),
        
        // Price per unit
        Text(
          '\$${widget.product.price.toStringAsFixed(2)}',
          style: TextStyle(
            color: auraColor,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        
        const SizedBox(height: 4),
        
        // Total price
        Text(
          'Total: \$${_itemTotal.toStringAsFixed(2)}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildQuantityControls(Color auraColor) {
    return Column(
      children: [
        // Remove button
        GestureDetector(
          onTap: _handleRemove,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.delete_outline,
              color: Colors.red,
              size: 20,
            ),
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Quantity controls
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: auraColor.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Decrease button
              GestureDetector(
                onTap: () => _handleQuantityChange(-1),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    Icons.remove,
                    color: auraColor,
                    size: 16,
                  ),
                ),
              ),
              
              // Quantity display
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Text(
                  '${widget.quantity}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              
              // Increase button
              GestureDetector(
                onTap: () => _handleQuantityChange(1),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    Icons.add,
                    color: auraColor,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
