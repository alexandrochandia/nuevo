import 'package:flutter/material.dart';

class ZoomOverlayImage extends StatefulWidget {
  final String imageUrl;
  final BoxFit fit;
  final Widget? errorWidget;
  final Widget? placeholder;

  const ZoomOverlayImage({
    Key? key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.errorWidget,
    this.placeholder,
  }) : super(key: key);

  @override
  State<ZoomOverlayImage> createState() => _ZoomOverlayImageState();
}

class _ZoomOverlayImageState extends State<ZoomOverlayImage> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showImageOverlay(context),
      child: widget.imageUrl.isNotEmpty
          ? Image.network(
              widget.imageUrl,
              fit: widget.fit,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return widget.placeholder ??
                    Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
              },
              errorBuilder: (context, error, stackTrace) {
                return widget.errorWidget ??
                    Container(
                      color: Colors.grey[300],
                      child: const Icon(
                        Icons.broken_image,
                        color: Colors.grey,
                        size: 50,
                      ),
                    );
              },
            )
          : widget.errorWidget ??
              Container(
                color: Colors.grey[300],
                child: const Icon(
                  Icons.image_not_supported,
                  color: Colors.grey,
                  size: 50,
                ),
              ),
    );
  }

  void _showImageOverlay(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                panEnabled: true,
                boundaryMargin: const EdgeInsets.all(20),
                minScale: 0.5,
                maxScale: 4.0,
                child: Image.network(
                  widget.imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return widget.errorWidget ??
                        Container(
                          width: 200,
                          height: 200,
                          color: Colors.grey[800],
                          child: const Icon(
                            Icons.broken_image,
                            color: Colors.white,
                            size: 50,
                          ),
                        );
                  },
                ),
              ),
            ),
            Positioned(
              top: 20,
              right: 20,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}