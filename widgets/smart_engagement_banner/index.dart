
import 'package:flutter/material.dart';
import '../dynamic_layout/dynamic_layout.dart';

/// Smart engagement banner widget inspired by FluxStore
class SmartEngagementBanner extends StatefulWidget {
  final BuildContext context;
  final dynamic config;
  final bool enablePopup;
  final VoidCallback? afterClosePopup;
  final Widget Function(Map<String, dynamic> data)? childWidget;

  const SmartEngagementBanner({
    super.key,
    required this.context,
    required this.config,
    this.enablePopup = false,
    this.afterClosePopup,
    this.childWidget,
  });

  @override
  State<SmartEngagementBanner> createState() => _SmartEngagementBannerState();
}

class _SmartEngagementBannerState extends State<SmartEngagementBanner> {
  bool _showPopup = false;

  @override
  void initState() {
    super.initState();
    if (widget.enablePopup) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showEngagementPopup();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }

  void _showEngagementPopup() {
    if (!mounted) return;

    setState(() {
      _showPopup = true;
    });

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.9,
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFFD4AF37),
                  width: 2,
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: const Text(
                              'Bienvenido a VMF Sweden',
                              style: TextStyle(
                                color: Color(0xFFD4AF37),
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () {
                            Navigator.of(context).pop();
                            widget.afterClosePopup?.call();
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '¡Únete a nuestra comunidad espiritual y encuentra conexiones auténticas con personas que comparten tu fe!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              // Navigate to registration
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFD4AF37),
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            child: const FittedBox(
                              child: Text(
                                'Comenzar',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              widget.afterClosePopup?.call();
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            child: const FittedBox(
                              child: Text('Más tarde'),
                            ),
                          ),
                        ),
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
}
