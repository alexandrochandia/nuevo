
import 'package:flutter/material.dart';
import '../dynamic_layout/dynamic_layout.dart';
import 'home_background.dart';

/// Main home layout widget inspired by FluxStore
class HomeLayout extends StatefulWidget {
  final bool isPinAppBar;
  final bool isShowAppbar;
  final bool showNewAppBar;
  final Map<String, dynamic> configs;
  final ScrollController? scrollController;

  const HomeLayout({
    super.key,
    required this.isPinAppBar,
    required this.isShowAppbar,
    required this.showNewAppBar,
    required this.configs,
    this.scrollController,
  });

  @override
  State<HomeLayout> createState() => _HomeLayoutState();
}

class _HomeLayoutState extends State<HomeLayout> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController ?? ScrollController();
  }

  @override
  Widget build(BuildContext context) {
    final horizontalLayouts = widget.configs['HorizonLayout'] as List? ?? [];
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background
          if (widget.configs['background'] != null)
            Positioned.fill(
              child: HomeBackground(config: widget.configs['background']),
            ),
          
          // Main content
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              // App Bar
              if (widget.isShowAppbar || widget.showNewAppBar)
                SliverAppBar(
                  pinned: widget.isPinAppBar,
                  floating: true,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  title: const Text(
                    'VMF SWEDEN',
                    style: TextStyle(
                      color: Color(0xFFD4AF37),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.search, color: Colors.white),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                      onPressed: () {},
                    ),
                  ],
                ),

              // Dynamic layouts
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final layout = horizontalLayouts[index];
                    return DynamicLayout(
                      configLayout: layout,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    );
                  },
                  childCount: horizontalLayouts.length,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    if (widget.scrollController == null) {
      _scrollController.dispose();
    }
    super.dispose();
  }
}
