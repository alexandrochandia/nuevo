import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'testimonio_dashboard.dart';
import 'testimonios_list.dart';
import 'testimonio_form.dart';
import '../../config/supabase_config.dart';
import '../../utils/glow_styles.dart';

class TestimoniosScreen extends StatefulWidget {
  const TestimoniosScreen({super.key});

  @override
  State<TestimoniosScreen> createState() => _TestimoniosScreenState();
}

class _TestimoniosScreenState extends State<TestimoniosScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const TestimonioDashboard(),
    const TestimoniosListScreen(),
    const TestimonioFormScreen(),
  ];

  final List<Map<String, dynamic>> _navItems = [
    {
      'icon': FontAwesomeIcons.chartLine,
      'label': 'Dashboard',
      'color': Colors.blue,
    },
    {
      'icon': FontAwesomeIcons.comments,
      'label': 'Testimonios',
      'color': Colors.green,
    },
    {
      'icon': FontAwesomeIcons.plus,
      'label': 'Agregar',
      'color': Colors.orange,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const FaIcon(
                FontAwesomeIcons.heart,
                color: Colors.amber,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Testimonios VMF',
              style: GlowStyles.boldNeonText.copyWith(
                fontSize: 20,
                color: GlowStyles.neonBlue,
              ),
            ),
          ],
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const FaIcon(FontAwesomeIcons.arrowLeft, color: Colors.amber),
        ),
        elevation: 0,
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.grey[900],
          border: Border(
            top: BorderSide(color: Colors.amber.withOpacity(0.3), width: 0.5),
          ),
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.amber,
          unselectedItemColor: Colors.grey[400],
          items: _navItems.map((item) {
            return BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _selectedIndex == _navItems.indexOf(item)
                      ? item['color'].withOpacity(0.2)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: FaIcon(
                  item['icon'],
                  size: 20,
                  color: _selectedIndex == _navItems.indexOf(item)
                      ? item['color']
                      : Colors.grey[400],
                ),
              ),
              label: item['label'],
            );
          }).toList(),
        ),
      ),
    );
  }
}