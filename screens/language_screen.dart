import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'intro_screen.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  String? _selectedLanguage;

  final Map<String, String> _languages = {
    'English': '🇬🇧',
    'Español': '🇪🇸',
    'Deutsch': '🇩🇪',
    'Italiano': '🇮🇹',
    'Português': '🇵🇹',
    'Svenska': '🇸🇪',
    'العربية': '🇸🇦',
  };

  Future<void> _saveLanguageAndContinue() async {
    if (_selectedLanguage != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('language', _selectedLanguage!);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const IntroScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'lib/assets/images/fondo.jpg',
            fit: BoxFit.cover,
          ),
          Center(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.black.withOpacity(0.65),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Language Selection',
                    style: TextStyle(fontSize: 22, color: Colors.amber, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  ..._languages.entries.map((entry) {
                    final selected = _selectedLanguage == entry.key;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedLanguage = entry.key;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: selected ? Colors.black : Colors.transparent,
                          border: Border.all(
                            color: selected ? Colors.blueAccent : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(entry.value, style: const TextStyle(fontSize: 20)),
                            const SizedBox(width: 12),
                            Text(
                              entry.key,
                              style: TextStyle(
                                fontSize: 18,
                                color: selected ? Colors.blueAccent : Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedLanguage != null ? Colors.amber : Colors.grey,
                    ),
                    onPressed: _selectedLanguage != null ? _saveLanguageAndContinue : null,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                      child: Text('Continue', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}