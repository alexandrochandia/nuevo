import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ModernOnboardingScreen extends StatefulWidget {
  const ModernOnboardingScreen({super.key});

  @override
  State<ModernOnboardingScreen> createState() => _ModernOnboardingScreenState();
}

class _ModernOnboardingScreenState extends State<ModernOnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _slides = [
    {
      'image': 'assets/images/onboarding/slide1.png',
      'title': 'Explora nuestros productos',
      'desc': 'Encuentra lo mejor de nuestra tienda con solo deslizar.'
    },
    {
      'image': 'assets/images/onboarding/slide2.png',
      'title': 'Recibe beneficios exclusivos',
      'desc': 'Descuentos, promociones y contenido solo para ti.'
    },
    {
      'image': 'assets/images/onboarding/slide3.png',
      'title': 'Apoya nuestra misión',
      'desc': 'Cada compra apoya a nuestra comunidad.'
    },
    {
      'image': 'assets/images/onboarding/slide4.png',
      'title': 'Compra fácil y rápido',
      'desc': 'Una experiencia rápida y segura en tu bolsillo.'
    },
  ];

  void _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/store');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemCount: _slides.length,
                itemBuilder: (_, index) {
                  final slide = _slides[index];
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(slide['image']!, height: 280),
                      const SizedBox(height: 30),
                      Text(
                        slide['title']!,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          slide['desc']!,
                          style: const TextStyle(fontSize: 16, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _slides.length,
                    (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index ? Colors.blue : Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: ElevatedButton(
                onPressed: _completeOnboarding,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(_currentPage == _slides.length - 1 ? 'Comenzar' : 'Siguiente'),
              ),
            ),
            TextButton(
              onPressed: _completeOnboarding,
              child: const Text('Saltar'),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
