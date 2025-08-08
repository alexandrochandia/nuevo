import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/aura_provider.dart';

class GlowAvatarWidget extends StatelessWidget {
  final String? imageUrl;
  final double size;
  final String name;
  final VoidCallback? onTap;

  const GlowAvatarWidget({
    super.key,
    this.imageUrl,
    this.size = 70,
    this.name = 'Usuario VMF',
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AuraProvider>(
      builder: (context, auraProvider, child) {
        return GestureDetector(
          onTap: onTap,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: auraProvider.getMultipleAuraGlows(),
            ),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: auraProvider.isAuraEnabled 
                    ? auraProvider.selectedAuraColor.withOpacity(0.8)
                    : Colors.white.withOpacity(0.3),
                  width: 3,
                ),
              ),
              child: ClipOval(
                child: imageUrl != null && imageUrl!.isNotEmpty
                  ? Image.network(
                      imageUrl!,
                      fit: BoxFit.cover,
                      width: size,
                      height: size,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildDefaultAvatar();
                      },
                    )
                  : _buildDefaultAvatar(),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : 'V',
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.4,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}