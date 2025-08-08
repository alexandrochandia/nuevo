import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'vmf_product_model.dart';

class VMFCartItem {
  final String id;
  final VMFProduct product;
  final VMFProductVariation? variation;
  int quantity;
  final Map<String, dynamic> metadata;
  final DateTime addedAt;

  VMFCartItem({
    required this.id,
    required this.product,
    this.variation,
    this.quantity = 1,
    this.metadata = const {},
    DateTime? addedAt,
  }) : addedAt = addedAt ?? DateTime.now();

  double get unitPrice => variation?.price ?? product.finalPrice;
  double get totalPrice => unitPrice * quantity;
  String get displayName => variation != null 
    ? '${product.name} - ${variation!.name}'
    : product.name;

  factory VMFCartItem.fromJson(Map<String, dynamic> json) {
    return VMFCartItem(
      id: json['id'] ?? '',
      product: VMFProduct.fromJson(json['product']),
      variation: json['variation'] != null 
        ? VMFProductVariation.fromJson(json['variation'])
        : null,
      quantity: json['quantity'] ?? 1,
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      addedAt: json['added_at'] != null 
        ? DateTime.parse(json['added_at'])
        : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product': product.toJson(),
      'variation': variation?.toJson(),
      'quantity': quantity,
      'metadata': metadata,
      'added_at': addedAt.toIso8601String(),
    };
  }
}

class VMFCoupon {
  final String code;
  final String description;
  final double discountValue;
  final bool isPercentage;
  final double? minimumAmount;
  final DateTime? expiryDate;
  final List<ProductCategory>? applicableCategories;

  VMFCoupon({
    required this.code,
    required this.description,
    required this.discountValue,
    this.isPercentage = false,
    this.minimumAmount,
    this.expiryDate,
    this.applicableCategories,
  });

  bool get isValid {
    if (expiryDate != null && DateTime.now().isAfter(expiryDate!)) {
      return false;
    }
    return true;
  }

  double calculateDiscount(double subtotal, List<VMFCartItem> items) {
    if (!isValid) return 0.0;
    
    if (minimumAmount != null && subtotal < minimumAmount!) {
      return 0.0;
    }

    double applicableAmount = subtotal;
    
    if (applicableCategories != null && applicableCategories!.isNotEmpty) {
      applicableAmount = items
        .where((item) => applicableCategories!.contains(item.product.category))
        .fold(0.0, (sum, item) => sum + item.totalPrice);
    }

    if (isPercentage) {
      return applicableAmount * (discountValue / 100);
    } else {
      return discountValue.clamp(0.0, applicableAmount);
    }
  }
}

class VMFCartModel extends ChangeNotifier {
  List<VMFCartItem> _items = [];
  VMFCoupon? _appliedCoupon;
  bool _isLoading = false;
  String? _error;

  // Configuración de envío
  double _shippingCost = 0.0;
  String _shippingMethod = 'standard';
  Map<String, dynamic> _shippingAddress = {};

  // Getters
  List<VMFCartItem> get items => List.unmodifiable(_items);
  VMFCoupon? get appliedCoupon => _appliedCoupon;
  bool get isLoading => _isLoading;
  String? get error => _error;
  double get shippingCost => _shippingCost;
  String get shippingMethod => _shippingMethod;
  Map<String, dynamic> get shippingAddress => _shippingAddress;

  // Cálculos del carrito
  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);
  
  double get subtotal => _items.fold(0.0, (sum, item) => sum + item.totalPrice);
  
  double get discountAmount => _appliedCoupon?.calculateDiscount(subtotal, _items) ?? 0.0;
  
  double get total => (subtotal - discountAmount + _shippingCost).clamp(0.0, double.infinity);
  
  bool get isEmpty => _items.isEmpty;
  bool get isNotEmpty => _items.isNotEmpty;

  // Formateo de precios
  String get formattedSubtotal => '${subtotal.toStringAsFixed(0)} SEK';
  String get formattedDiscount => '${discountAmount.toStringAsFixed(0)} SEK';
  String get formattedShipping => '${_shippingCost.toStringAsFixed(0)} SEK';
  String get formattedTotal => '${total.toStringAsFixed(0)} SEK';

  VMFCartModel() {
    _loadCartFromStorage();
  }

  // Añadir producto al carrito
  Future<void> addToCart(VMFProduct product, {
    VMFProductVariation? variation,
    int quantity = 1,
    Map<String, dynamic>? metadata,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final itemId = '${product.id}_${variation?.id ?? 'default'}';
      final existingIndex = _items.indexWhere((item) => item.id == itemId);

      if (existingIndex >= 0) {
        _items[existingIndex].quantity += quantity;
      } else {
        final cartItem = VMFCartItem(
          id: itemId,
          product: product,
          variation: variation,
          quantity: quantity,
          metadata: metadata ?? {},
        );
        _items.add(cartItem);
      }

      await _saveCartToStorage();
      notifyListeners();
    } catch (e) {
      _setError('Error al añadir producto al carrito: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Actualizar cantidad de un producto
  Future<void> updateQuantity(String itemId, int newQuantity) async {
    _setLoading(true);
    _clearError();

    try {
      if (newQuantity <= 0) {
        await removeFromCart(itemId);
        return;
      }

      final index = _items.indexWhere((item) => item.id == itemId);
      if (index >= 0) {
        _items[index].quantity = newQuantity;
        await _saveCartToStorage();
        notifyListeners();
      }
    } catch (e) {
      _setError('Error al actualizar cantidad: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Eliminar producto del carrito
  Future<void> removeFromCart(String itemId) async {
    _setLoading(true);
    _clearError();

    try {
      _items.removeWhere((item) => item.id == itemId);
      await _saveCartToStorage();
      notifyListeners();
    } catch (e) {
      _setError('Error al eliminar producto: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Limpiar carrito
  Future<void> clearCart() async {
    _setLoading(true);
    _clearError();

    try {
      _items.clear();
      _appliedCoupon = null;
      await _saveCartToStorage();
      notifyListeners();
    } catch (e) {
      _setError('Error al limpiar carrito: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Aplicar cupón
  Future<bool> applyCoupon(VMFCoupon coupon) async {
    _setLoading(true);
    _clearError();

    try {
      if (!coupon.isValid) {
        _setError('El cupón ha expirado');
        return false;
      }

      if (coupon.minimumAmount != null && subtotal < coupon.minimumAmount!) {
        _setError('Pedido mínimo de ${coupon.minimumAmount!.toStringAsFixed(0)} SEK requerido');
        return false;
      }

      _appliedCoupon = coupon;
      await _saveCartToStorage();
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Error al aplicar cupón: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Eliminar cupón
  Future<void> removeCoupon() async {
    _appliedCoupon = null;
    await _saveCartToStorage();
    notifyListeners();
  }

  // Configurar envío
  Future<void> setShipping({
    required double cost,
    required String method,
    Map<String, dynamic>? address,
  }) async {
    _shippingCost = cost;
    _shippingMethod = method;
    if (address != null) {
      _shippingAddress = address;
    }
    await _saveCartToStorage();
    notifyListeners();
  }

  // Verificar si un producto está en el carrito
  bool isInCart(String productId, {String? variationId}) {
    final itemId = '${productId}_${variationId ?? 'default'}';
    return _items.any((item) => item.id == itemId);
  }

  // Obtener cantidad de un producto en el carrito
  int getProductQuantity(String productId, {String? variationId}) {
    final itemId = '${productId}_${variationId ?? 'default'}';
    final item = _items.firstWhere(
      (item) => item.id == itemId,
      orElse: () => VMFCartItem(
        id: '',
        product: VMFProduct(
          id: '',
          name: '',
          description: '',
          shortDescription: '',
          price: 0,
          type: ProductType.book,
          category: ProductCategory.devocionales,
        ),
        quantity: 0,
      ),
    );
    return item.quantity;
  }

  // Métodos privados
  void _setLoading(bool loading) {
    _isLoading = loading;
    if (loading) notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  // Persistencia local
  Future<void> _saveCartToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartData = {
        'items': _items.map((item) => item.toJson()).toList(),
        'applied_coupon': _appliedCoupon != null ? {
          'code': _appliedCoupon!.code,
          'description': _appliedCoupon!.description,
          'discount_value': _appliedCoupon!.discountValue,
          'is_percentage': _appliedCoupon!.isPercentage,
          'minimum_amount': _appliedCoupon!.minimumAmount,
          'expiry_date': _appliedCoupon!.expiryDate?.toIso8601String(),
        } : null,
        'shipping_cost': _shippingCost,
        'shipping_method': _shippingMethod,
        'shipping_address': _shippingAddress,
      };
      await prefs.setString('vmf_cart', json.encode(cartData));
    } catch (e) {
      debugPrint('Error saving cart to storage: $e');
    }
  }

  Future<void> _loadCartFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = prefs.getString('vmf_cart');
      
      if (cartJson != null) {
        final cartData = json.decode(cartJson);
        
        _items = (cartData['items'] as List?)
          ?.map((item) => VMFCartItem.fromJson(item))
          .toList() ?? [];
          
        if (cartData['applied_coupon'] != null) {
          final couponData = cartData['applied_coupon'];
          _appliedCoupon = VMFCoupon(
            code: couponData['code'],
            description: couponData['description'],
            discountValue: couponData['discount_value'].toDouble(),
            isPercentage: couponData['is_percentage'] ?? false,
            minimumAmount: couponData['minimum_amount']?.toDouble(),
            expiryDate: couponData['expiry_date'] != null 
              ? DateTime.parse(couponData['expiry_date'])
              : null,
          );
        }
        
        _shippingCost = cartData['shipping_cost']?.toDouble() ?? 0.0;
        _shippingMethod = cartData['shipping_method'] ?? 'standard';
        _shippingAddress = Map<String, dynamic>.from(cartData['shipping_address'] ?? {});
        
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading cart from storage: $e');
    }
  }
}