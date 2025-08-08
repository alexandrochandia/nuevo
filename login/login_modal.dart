
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../services/auth_service.dart';

/// 🌐 Login Modal con estilo iOS y botones sociales modernos
class LoginModal extends StatefulWidget {
  final VoidCallback? onLoginSuccess;

  const LoginModal({super.key, this.onLoginSuccess});

  /// 📲 Método estático para mostrar el modal desde cualquier contexto
  static Future<void> show(BuildContext context, {VoidCallback? onLoginSuccess}) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      builder: (_) => LoginModal(onLoginSuccess: onLoginSuccess),
    );
  }

  @override
  State<LoginModal> createState() => _LoginModalState();
}

class _LoginModalState extends State<LoginModal> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF1a1a2e),
            Color(0xFF16213e),
            Color(0xFF0f3460),
          ],
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle del modal
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Título
              const Text(
                '👋 ¡Bienvenido de vuelta!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Inicia sesión para continuar con VMF Suecia',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),

              const SizedBox(height: 40),

              // Campo de email
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                  prefixIcon: Icon(
                    Icons.email_outlined,
                    color: Colors.white.withOpacity(0.7),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.white.withOpacity(0.3),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF667eea),
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                ),
              ),

              const SizedBox(height: 20),

              // Campo de contraseña
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                  prefixIcon: Icon(
                    Icons.lock_outlined,
                    color: Colors.white.withOpacity(0.7),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility : Icons.visibility_off,
                      color: Colors.white.withOpacity(0.7),
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.white.withOpacity(0.3),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF667eea),
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                ),
              ),

              const SizedBox(height: 30),

              // Botón de login
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ).copyWith(
                    backgroundColor: MaterialStateProperty.all(Colors.transparent),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF667eea).withOpacity(0.3),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Center(
                      child: _isLoading
                          ? const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            )
                          : const Text(
                              'Iniciar Sesión',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Enlace de registro
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pushNamed('/register_gender');
                  },
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.7),
                      ),
                      children: const [
                        TextSpan(text: '¿No tienes cuenta? '),
                        TextSpan(
                          text: 'Regístrate',
                          style: TextStyle(
                            color: Color(0xFF667eea),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Divisor
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 1,
                      color: Colors.white.withOpacity(0.3),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'O continúa con',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 1,
                      color: Colors.white.withOpacity(0.3),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // Botones sociales
              _buildButton(
                icon: FontAwesomeIcons.apple,
                text: 'Sign in with Apple',
                onPressed: () => _handleAppleSignIn(),
                isLoading: _isLoading,
              ),
              _buildButton(
                icon: FontAwesomeIcons.facebookF,
                text: 'Sign in with Facebook',
                onPressed: () => _handleFacebookSignIn(),
                isLoading: _isLoading,
              ),
              _buildButton(
                icon: FontAwesomeIcons.google,
                text: 'Sign in with Google',
                onPressed: () => _handleGoogleSignIn(),
                isLoading: _isLoading,
              ),

              const SizedBox(height: 20),

              // Botón cancelar
              Center(
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(
                      color: Color(0xFF667eea),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor completa todos los campos'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await AuthService.signIn(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (mounted) {
        Navigator.of(context).pop();
        widget.onLoginSuccess?.call();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Métodos de autenticación social
  Future<void> _handleAppleSignIn() async {
    setState(() => _isLoading = true);
    try {
      // TODO: Implementar Apple Sign In
      await Future.delayed(const Duration(seconds: 1));
      _showSnackBar('Apple Sign In no disponible aún', isError: true);
    } catch (e) {
      _showSnackBar('Error con Apple Sign In: ${e.toString()}', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleFacebookSignIn() async {
    setState(() => _isLoading = true);
    try {
      // TODO: Implementar Facebook Sign In
      await Future.delayed(const Duration(seconds: 1));
      _showSnackBar('Facebook Sign In no disponible aún', isError: true);
    } catch (e) {
      _showSnackBar('Error con Facebook Sign In: ${e.toString()}', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    try {
      // TODO: Implementar Google Sign In
      await Future.delayed(const Duration(seconds: 1));
      _showSnackBar('Google Sign In no disponible aún', isError: true);
    } catch (e) {
      _showSnackBar('Error con Google Sign In: ${e.toString()}', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // 🔧 Widget reutilizable para construir botones sociales
  Widget _buildButton({
    required IconData icon,
    required String text,
    required VoidCallback onPressed,
    bool isLoading = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.black,
          backgroundColor: Colors.grey[100],
          elevation: 0,
          minimumSize: const Size.fromHeight(50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        icon: _isLoading ? 
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ) : 
          FaIcon(icon, size: 20),
        label: Text(
          _isLoading ? 'Conectando...' : text,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        onPressed: _isLoading ? null : onPressed,
      ),
    );
  }
}
