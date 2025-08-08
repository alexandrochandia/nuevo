import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/store/vmf_product_model.dart';
import '../../models/store/vmf_cart_model.dart';
import '../../providers/aura_provider.dart';
import '../gradient_text.dart';
import '../custom_blur_button.dart';

class VMFProductCard extends StatefulWidget {
  final VMFProduct product;
  final double? width;
  final bool showQuickActions;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCart;
  final VoidCallback? onAddToWishlist;

  const VMFProductCard({
    Key? key,
    required this.product,
    this.width,
    this.showQuickActions = true,
    this.onTap,
    this.onAddToCart,
    this.onAddToWishlist,
  }) : super(key: key);

  @override
  State<VMFProductCard> createState() => _VMFProductCardState();
}

class _VMFProductCardState extends State<VMFProductCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
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
  }

  @override
  void dispose() {
    _animationController.dispose();
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Imagen del producto
                      _buildProductImage(auraColor),
                      
                      // Información del producto
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Badges y categoría
                              _buildBadgesRow(auraColor),
                              
                              const SizedBox(height: 8),
                              
                              // Título del producto
                              _buildProductTitle(),
                              
                              const SizedBox(height: 4),
                              
                              // Autor/Artista
                              _buildAuthorInfo(),
                              
                              const SizedBox(height: 8),
                              
                              // Descripción corta
                              _buildDescription(),
                              
                              const Spacer(),
                              
                              // Rating y reseñas
                              _buildRatingRow(),
                              
                              const SizedBox(height: 12),
                              
                              // Precio y acciones
                              _buildPriceAndActions(auraColor),
                            ],
                          ),
                        ),
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
    return Stack(
      children: [
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            image: widget.product.featuredImage != null
                ? DecorationImage(
                    image: NetworkImage(widget.product.featuredImage!),
                    fit: BoxFit.cover,
                  )
                : null,
            gradient: widget.product.featuredImage == null
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      widget.product.categoryColor.withOpacity(0.3),
                      widget.product.categoryColor.withOpacity(0.1),
                    ],
                  )
                : null,
          ),
          child: widget.product.featuredImage == null
              ? Center(
                  child: Icon(
                    widget.product.categoryIcon,
                    size: 64,
                    color: widget.product.categoryColor,
                  ),
                )
              : null,
        ),
        
        // Overlay gradient
        Container(
          height: 200,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
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
        
        // Status badges
        Positioned(
          top: 12,
          left: 12,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.product.isFeatured)
                _buildStatusBadge('Destacado', auraColor),
              if (widget.product.onSale)
                _buildStatusBadge('Oferta', Colors.red),
              if (widget.product.isDigital)
                _buildStatusBadge('Digital', Colors.blue),
              if (!widget.product.isAvailable)
                _buildStatusBadge('Agotado', Colors.grey),
            ],
          ),
        ),
        
        // Quick actions
        if (widget.showQuickActions)
          Positioned(
            top: 12,
            right: 12,
            child: Column(
              children: [
                _buildQuickActionButton(
                  icon: Icons.favorite_border,
                  onTap: widget.onAddToWishlist,
                ),
                const SizedBox(height: 8),
                _buildQuickActionButton(
                  icon: Icons.remove_red_eye,
                  onTap: widget.onTap,
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildStatusBadge(String text, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 16,
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
        CustomBlurButton(
          text: 'Añadir',
          icon: Icons.add_shopping_cart,
          onPressed: widget.onAddToCart ?? () {},
          backgroundColor: auraColor,
          textColor: Colors.white,
          borderRadius: 20,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ],
    );
  }
}