import 'package:flutter/material.dart';

class LanguageSelectorModal extends StatefulWidget {
  final Function(String) onLanguageSelected;

  const LanguageSelectorModal({super.key, required this.onLanguageSelected});

  @override
  State<LanguageSelectorModal> createState() => _LanguageSelectorModalState();
}

class _LanguageSelectorModalState extends State<LanguageSelectorModal> {
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

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.black.withOpacity(0.8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Selecciona tu idioma',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.amber),
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
                      color: selected ? Colors.blueAccent : Colors.grey,
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
              onPressed: _selectedLanguage != null
                  ? () {
                widget.onLanguageSelected(_selectedLanguage!);
              }
                  : null,
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                child: Text('Continuar', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
