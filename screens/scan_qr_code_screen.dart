import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/qr_code_provider.dart';
import '../providers/aura_provider.dart';
import '../widgets/glow_container.dart';

class ScanQRCodeScreen extends StatefulWidget {
  const ScanQRCodeScreen({super.key});

  @override
  State<ScanQRCodeScreen> createState() => _ScanQRCodeScreenState();
}

class _ScanQRCodeScreenState extends State<ScanQRCodeScreen>
    with TickerProviderStateMixin {
  late AnimationController _scanLineController;
  late AnimationController _glowController;
  late Animation<double> _scanLineAnimation;
  late Animation<double> _glowAnimation;
  
  bool _isScanning = false;
  bool _hasPermission = false;
  String? _scanResult;
  Map<String, dynamic>? _scanData;

  @override
  void initState() {
    super.initState();
    _scanLineController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    
    _glowController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);
    
    _scanLineAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scanLineController, curve: Curves.easeInOut),
    );
    
    _glowAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
    
    _checkPermission();
  }

  @override
  void dispose() {
    _scanLineController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  Future<void> _checkPermission() async {
    // Simular verificación de permisos
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      _hasPermission = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<QRCodeProvider, AuraProvider>(
      builder: (context, qrProvider, auraProvider, child) {
        final auraColor = auraProvider.currentAuraColor;

        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios, color: auraColor),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Escanear QR Code',
              style: TextStyle(
                color: auraColor,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.flash_on, color: auraColor),
                onPressed: _toggleFlash,
              ),
              IconButton(
                icon: Icon(Icons.flip_camera_android, color: auraColor),
                onPressed: _switchCamera,
              ),
            ],
          ),
          body: _hasPermission ? _buildScannerView(auraColor, qrProvider) : _buildPermissionView(auraColor),
        );
      },
    );
  }

  Widget _buildPermissionView(Color auraColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.camera_alt,
            size: 80,
            color: auraColor.withOpacity(0.5),
          ),
          const SizedBox(height: 20),
          Text(
            'Permisos de Cámara',
            style: TextStyle(
              color: auraColor,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Se requiere acceso a la cámara para escanear códigos QR',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: _requestPermission,
            style: ElevatedButton.styleFrom(
              backgroundColor: auraColor,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Permitir Acceso',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScannerView(Color auraColor, QRCodeProvider qrProvider) {
    return Column(
      children: [
        // Área de escaneo
        Expanded(
          flex: 3,
          child: Stack(
            children: [
              // Simulación de vista de cámara
              Container(
                width: double.infinity,
                height: double.infinity,
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
                child: const Center(
                  child: Text(
                    'Vista de Cámara\n(Simulación)',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              
              // Marco de escaneo
              Center(
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: auraColor,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Stack(
                    children: [
                      // Esquinas del marco
                      _buildCornerBorder(auraColor, Alignment.topLeft),
                      _buildCornerBorder(auraColor, Alignment.topRight),
                      _buildCornerBorder(auraColor, Alignment.bottomLeft),
                      _buildCornerBorder(auraColor, Alignment.bottomRight),
                      
                      // Línea de escaneo animada
                      AnimatedBuilder(
                        animation: _scanLineAnimation,
                        builder: (context, child) {
                          return Positioned(
                            left: 0,
                            right: 0,
                            top: _scanLineAnimation.value * 250,
                            child: Container(
                              height: 2,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.transparent,
                                    auraColor,
                                    Colors.transparent,
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: auraColor.withOpacity(0.5),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              
              // Mensaje de instrucciones
              Positioned(
                bottom: 40,
                left: 0,
                right: 0,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _isScanning ? 'Escaneando...' : 'Apunta la cámara hacia el código QR',
                    style: TextStyle(
                      color: auraColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Controles inferiores
        Expanded(
          flex: 1,
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Botón de escaneo
                AnimatedBuilder(
                  animation: _glowAnimation,
                  builder: (context, child) {
                    return GlowContainer(
                      glowColor: auraColor,
                      borderRadius: BorderRadius.circular(35),
                      child: GestureDetector(
                        onTap: () => _simulateScan(qrProvider),
                        child: Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            color: auraColor,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: auraColor.withOpacity(0.3),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Icon(
                            _isScanning ? Icons.stop : Icons.qr_code_scanner,
                            color: Colors.black,
                            size: 32,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 16),
                
                Text(
                  _isScanning ? 'Presiona para parar' : 'Presiona para escanear',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Opciones adicionales
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildActionButton(
                      icon: Icons.image,
                      label: 'Galería',
                      onTap: _scanFromGallery,
                      color: Colors.blue,
                    ),
                    _buildActionButton(
                      icon: Icons.history,
                      label: 'Historial',
                      onTap: _showScanHistory,
                      color: Colors.purple,
                    ),
                    _buildActionButton(
                      icon: Icons.text_fields,
                      label: 'Texto',
                      onTap: _scanFromText,
                      color: Colors.green,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCornerBorder(Color color, Alignment alignment) {
    return Align(
      alignment: alignment,
      child: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          border: Border(
            top: alignment == Alignment.topLeft || alignment == Alignment.topRight
                ? BorderSide(color: color, width: 4)
                : BorderSide.none,
            bottom: alignment == Alignment.bottomLeft || alignment == Alignment.bottomRight
                ? BorderSide(color: color, width: 4)
                : BorderSide.none,
            left: alignment == Alignment.topLeft || alignment == Alignment.bottomLeft
                ? BorderSide(color: color, width: 4)
                : BorderSide.none,
            right: alignment == Alignment.topRight || alignment == Alignment.bottomRight
                ? BorderSide(color: color, width: 4)
                : BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: color.withOpacity(0.5),
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _toggleFlash() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Flash alternado')),
    );
  }

  void _switchCamera() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cámara cambiada')),
    );
  }

  void _requestPermission() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Permisos solicitados')),
    );
  }

  Future<void> _simulateScan(QRCodeProvider qrProvider) async {
    if (_isScanning) {
      setState(() {
        _isScanning = false;
      });
      return;
    }

    setState(() {
      _isScanning = true;
    });

    // Simular escaneo
    await Future.delayed(const Duration(seconds: 2));

    // Simular diferentes tipos de QR
    final qrExamples = [
      'vmf://event?data={"eventId":"event_1","title":"Culto Dominical","church":"VMF Sweden","date":"2024-07-15T10:00:00Z"}',
      'vmf://contact?data={"name":"Pastor Anders","phone":"+46 70 123 4567","email":"anders@vmf.se"}',
      'vmf://checkin?data={"eventId":"event_2","title":"Conferencia VMF","location":"Centro de Conferencias"}',
      'WIFI:T:WPA;S:VMF_Church_Guest;P:Jesus2024!;H:false;;',
      'https://vmfsweden.se/eventos',
      'Bienvenidos a VMF Sweden - Iglesia Cristiana en Suecia',
    ];

    final randomQR = qrExamples[DateTime.now().millisecond % qrExamples.length];
    final result = await qrProvider.simulateScanQR(randomQR);

    setState(() {
      _isScanning = false;
      _scanResult = randomQR;
      _scanData = result;
    });

    if (result['success']) {
      _showScanResult(result);
    }
  }

  void _showScanResult(Map<String, dynamic> result) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1a1a1a),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Consumer<AuraProvider>(
        builder: (context, auraProvider, child) {
          final auraColor = auraProvider.currentAuraColor;
          
          return Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Indicador de éxito
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 40,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                Text(
                  'QR Escaneado',
                  style: TextStyle(
                    color: auraColor,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                Text(
                  result['message'] ?? 'QR procesado exitosamente',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Información del QR
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2a2a2a),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tipo: ${result['type']}',
                        style: TextStyle(
                          color: auraColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Contenido:',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _scanResult ?? 'No disponible',
                        style: TextStyle(
                          color: Colors.grey[300],
                          fontSize: 12,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Acciones
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.grey[400],
                          side: BorderSide(color: Colors.grey[400]!),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Cerrar'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _processScanResult(result);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: auraColor,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Procesar'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _processScanResult(Map<String, dynamic> result) {
    final type = result['type'];
    
    switch (type) {
      case 'event':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Navegando a evento VMF...')),
        );
        break;
      case 'contact':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Agregando contacto...')),
        );
        break;
      case 'checkin':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Realizando check-in...')),
        );
        break;
      case 'wifi':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Conectando a WiFi...')),
        );
        break;
      case 'url':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Abriendo enlace...')),
        );
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Contenido copiado al portapapeles')),
        );
    }
  }

  void _scanFromGallery() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Escaneando desde galería...')),
    );
  }

  void _showScanHistory() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Historial de escaneos próximamente')),
    );
  }

  void _scanFromText() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a1a),
        title: const Text('Escanear desde Texto', style: TextStyle(color: Colors.white)),
        content: TextField(
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Pega el contenido del QR aquí',
            hintStyle: TextStyle(color: Colors.grey),
            border: OutlineInputBorder(),
          ),
          onSubmitted: (value) {
            if (value.isNotEmpty) {
              Navigator.pop(context);
              // Procesar texto como QR
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Procesando: $value')),
              );
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Escanear'),
          ),
        ],
      ),
    );
  }
}