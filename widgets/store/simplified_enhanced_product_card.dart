import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/store/vmf_product_model.dart';
import '../../models/store/vmf_cart_model.dart';
import '../../providers/aura_provider.dart';
import '../gradient_text.dart';
import '../custom_blur_button.dart';

class SimplifiedEnhancedProductCard extends StatefulWidget {
  final VMFProduct product;
  final double? width;
  final bool showQuickActions;
  final bool showWishlistButton;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCart;
  final VoidCallback? onAddToWishlist;

  const SimplifiedEnhancedProductCard({
    Key? key,
    required this.product,
    this.width,
    this.showQuickActions = true,
    this.showWishlistButton = true,
    this.onTap,
    this.onAddToCart,
    this.onAddToWishlist,
  }) : super(key: key);

  @override
  State<SimplifiedEnhancedProductCard> createState() => _SimplifiedEnhancedProductCardState();
}

class _SimplifiedEnhancedProductCardState extends State<SimplifiedEnhancedProductCard>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _heartController;
  late AnimationController _cartController;
  
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _heartAnimation;
  late Animation<double> _cartBounceAnimation;
  
  bool _isHovered = false;
  bool _isWishlisted = false;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _heartController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _cartController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _glowAnimation = Tween<double>(
      begin: 0.3,
      end: 0.8,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _heartAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _heartController,
      curve: Curves.elasticOut,
    ));

    _cartBounceAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _cartController,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    _heartController.dispose();
    _cartController.dispose();
    super.dispose();
  }

  void _onHover(bool isHovered) {
    setState(() {
      _isHovered = isHovered;
    });
    if (isHovered) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  void _onWishlistTap() {
    HapticFeedback.mediumImpact();
    setState(() {
      _isWishlisted = !_isWishlisted;
    });
    _heartController.forward().then((_) {
      _heartController.reverse();
    });
    widget.onAddToWishlist?.call();
  }

  void _onAddToCart() {
    HapticFeedback.lightImpact();
    _cartController.forward().then((_) {
      _cartController.reverse();
    });
    widget.onAddToCart?.call();
  }

  // Calcular porcentaje de descuento
  double get _discountPercentage {
    if (!widget.product.onSale || widget.product.regularPrice == null) return 0.0;
    final regular = widget.product.regularPrice!;
    final sale = widget.product.finalPrice;
    return ((regular - sale) / regular) * 100;
  }

  @override
  Widget build(BuildContext context) {
    final auraProvider = Provider.of<AuraProvider>(context);
    final auraColor = auraProvider.currentAuraColor;

    return MouseRegion(
      onEnter: (_) => _onHover(true),
      onExit: (_) => _onHover(false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                width: widget.width ?? 280,
                margin: const EdgeInsets.all(8),
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
                  boxShadow: [
                    BoxShadow(
                      color: auraColor.withOpacity(_glowAnimation.value * 0.3),
                      blurRadius: 20,
                      spreadRadius: 2,
                      offset: const Offset(0, 8),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Imagen del producto con overlays
                          _buildProductImage(auraColor),
                          
                          // Información del producto
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Badges de categoría
                                  _buildBadgesRow(auraColor),
                                  const SizedBox(height: 8),
                                  
                                  // Título del producto
                                  _buildProductTitle(),
                                  const SizedBox(height: 4),
                                  
                                  // Información del autor/artista
                                  _buildAuthorInfo(),
                                  const SizedBox(height: 8),
                                  
                                  // Descripción
                                  _buildDescription(),
                                  const SizedBox(height: 8),
                                  
                                  // Rating y reviews
                                  _buildRatingRow(),
                                  
                                  const Spacer(),
                                  
                                  // Precio y acciones
                                  _buildPriceAndActions(auraColor),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      // Botón de favoritos (corazón)
                      if (widget.showWishlistButton)
                        Positioned(
                          top: 12,
                          right: 12,
                          child: _buildWishlistButton(auraColor),
                        ),
                      
                      // Badge de stock bajo
                      if (widget.product.stockQuantity <= 5 && widget.product.stockQuantity > 0)
                        Positioned(
                          top: 12,
                          left: 12,
                          child: _buildStockBadge(),
                        ),
                      
                      // Badge de oferta
                      if (widget.product.onSale && _discountPercentage > 0)
                        Positioned(
                          top: 12,
                          left: 12,
                          child: _buildSaleBadge(auraColor),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProductImage(Color auraColor) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.grey[800]!,
            Colors.grey[900]!,
          ],
        ),
      ),
      child: Stack(
        children: [
          // Imagen del producto
          if (widget.product.featuredImage != null && widget.product.featuredImage!.isNotEmpty)
            Container(
              width: double.infinity,
              height: double.infinity,
              child: Image.network(
                widget.product.featuredImage!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildPlaceholderImage();
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return _buildLoadingImage();
                },
              ),
            )
          else
            _buildPlaceholderImage(),
          
          // Gradient overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.3),
                ],
              ),
            ),
          ),
          
          // Quick actions overlay (visible on hover)
          if (_isHovered && widget.showQuickActions)
            _buildQuickActionsOverlay(auraColor),
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: Colors.grey[800],
      child: Center(
        child: Icon(
          widget.product.categoryIcon,
          size: 60,
          color: Colors.white.withOpacity(0.5),
        ),
      ),
    );
  }

  Widget _buildLoadingImage() {
    return Container(
      color: Colors.grey[800],
      child: const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white54),
        ),
      ),
    );
  }

  Widget _buildQuickActionsOverlay(Color auraColor) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.3),
            Colors.black.withOpacity(0.6),
          ],
        ),
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildQuickActionButton(
              icon: Icons.visibility,
              onTap: widget.onTap,
              color: auraColor,
            ),
            const SizedBox(width: 16),
            AnimatedBuilder(
              animation: _cartController,
              builder: (context, child) {
                return Transform.scale(
                  scale: _cartBounceAnimation.value,
                  child: _buildQuickActionButton(
                    icon: Icons.add_shopping_cart,
                    onTap: _onAddToCart,
                    color: auraColor,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    VoidCallback? onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: color.withOpacity(0.5),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Icon(
          icon,
          color: color,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildWishlistButton(Color auraColor) {
    return AnimatedBuilder(
      animation: _heartController,
      builder: (context, child) {
        return Transform.scale(
          scale: _heartAnimation.value,
          child: GestureDetector(
            onTap: _onWishlistTap,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _isWishlisted ? Colors.red : Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Icon(
                _isWishlisted ? Icons.favorite : Icons.favorite_border,
                color: _isWishlisted ? Colors.red : Colors.white,
                size: 18,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStockBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.orange,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Text(
        'Solo ${widget.product.stockQuantity}',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSaleBadge(Color auraColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Text(
        '-${_discountPercentage.toStringAsFixed(0)}%',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildBadgesRow(Color auraColor) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: widget.product.categoryColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: widget.product.categoryColor.withOpacity(0.5),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.product.categoryIcon,
                size: 12,
                color: widget.product.categoryColor,
              ),
              const SizedBox(width: 4),
              Text(
                widget.product.category.toString().split('.').last.replaceAll('_', ' '),
                style: TextStyle(
                  color: widget.product.categoryColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProductTitle() {
    return GradientText(
      text: widget.product.name,
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

  Widget _buildAuthorInfo() {
    final author = widget.product.author ?? widget.product.artist;
    if (author == null) return const SizedBox.shrink();

    return Text(
      'por $author',
      style: TextStyle(
        color: Colors.white.withOpacity(0.7),
        fontSize: 12,
        fontStyle: FontStyle.italic,
      ),
    );
  }

  Widget _buildDescription() {
    return Text(
      widget.product.shortDescription,
      style: TextStyle(
        color: Colors.white.withOpacity(0.8),
        fontSize: 12,
        height: 1.3,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildRatingRow() {
    return Row(
      children: [
        Row(
          children: List.generate(5, (index) {
            return Icon(
              index < widget.product.rating.floor()
                  ? Icons.star
                  : index < widget.product.rating
                      ? Icons.star_half
                      : Icons.star_border,
              color: const Color(0xFFFFD700),
              size: 14,
            );
          }),
        ),
        const SizedBox(width: 4),
        Text(
          '${widget.product.rating.toStringAsFixed(1)} (${widget.product.reviewCount})',
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildPriceAndActions(Color auraColor) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.product.onSale && widget.product.regularPrice != null)
                Text(
                  widget.product.formattedRegularPrice,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 12,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              GradientText(
                text: widget.product.formattedPrice,
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
          ),
        ),
        const SizedBox(width: 8),
        _buildAddToCartButton(auraColor),
      ],
    );
  }

  Widget _buildAddToCartButton(Color auraColor) {
    return CustomBlurButton(
      text: 'Añadir',
      icon: Icons.add_shopping_cart,
      onPressed: _onAddToCart,
      backgroundColor: auraColor,
      textColor: Colors.white,
      borderRadius: 20,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }
}
