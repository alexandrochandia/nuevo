
import 'package:flutter/material.dart';

/// App configuration class inspired by FluxStore
class AppConfig {
  final Map<String, dynamic> jsonData;
  final AppSettings settings;
  final Map<String, dynamic>? background;
  final AppBarConfig? appBar;

  AppConfig({
    required this.jsonData,
    required this.settings,
    this.background,
    this.appBar,
  });

  factory AppConfig.fromJson(Map<String, dynamic> json) {
    return AppConfig(
      jsonData: json,
      settings: AppSettings.fromJson(json['settings'] ?? {}),
      background: json['background'],
      appBar: json['appBar'] != null 
        ? AppBarConfig.fromJson(json['appBar']) 
        : null,
    );
  }
}

class AppSettings {
  final bool stickyHeader;
  final SmartEngagementBannerConfig smartEngagementBannerConfig;

  AppSettings({
    required this.stickyHeader,
    required this.smartEngagementBannerConfig,
  });

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      stickyHeader: json['stickyHeader'] ?? false,
      smartEngagementBannerConfig: SmartEngagementBannerConfig.fromJson(
        json['smartEngagementBannerConfig'] ?? {},
      ),
    );
  }
}

class SmartEngagementBannerConfig {
  final PopupConfig popup;

  SmartEngagementBannerConfig({required this.popup});

  factory SmartEngagementBannerConfig.fromJson(Map<String, dynamic> json) {
    return SmartEngagementBannerConfig(
      popup: PopupConfig.fromJson(json['popup'] ?? {}),
    );
  }
}

class PopupConfig {
  final int updatedTime;
  final bool alwaysShowUponOpen;

  PopupConfig({
    required this.updatedTime,
    required this.alwaysShowUponOpen,
  });

  factory PopupConfig.fromJson(Map<String, dynamic> json) {
    return PopupConfig(
      updatedTime: json['updatedTime'] ?? 0,
      alwaysShowUponOpen: json['alwaysShowUponOpen'] ?? false,
    );
  }
}

class AppBarConfig {
  final List<String> showOnRoutes;

  AppBarConfig({required this.showOnRoutes});

  factory AppBarConfig.fromJson(Map<String, dynamic> json) {
    return AppBarConfig(
      showOnRoutes: List<String>.from(json['showOnRoutes'] ?? []),
    );
  }

  bool shouldShowOn(String route) {
    return showOnRoutes.contains(route);
  }
}

/// Route list constants
class RouteList {
  static const String home = '/';
  static const String search = '/search';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String testimonios = '/testimonios';
  static const String events = '/events';
  static const String livestream = '/livestream';
  static const String gallery = '/gallery';
  static const String store = '/store';
}

/// Default VMF Sweden app configuration
class VMFConfig {
  static AppConfig getDefaultConfig() {
    return AppConfig.fromJson({
      'settings': {
        'stickyHeader': true,
        'smartEngagementBannerConfig': {
          'popup': {
            'updatedTime': DateTime.now().millisecondsSinceEpoch,
            'alwaysShowUponOpen': false,
          },
        },
      },
      'background': {
        'type': 'gradient',
        'colors': ['#000000', '#1a1a1a', '#000000'],
      },
      'appBar': {
        'showOnRoutes': [RouteList.home],
      },
      'HorizonLayout': [
        {
          'layout': 'banner',
          'title': 'Destacados',
          'items': [
            {
              'title': 'EN VIVO AHORA',
              'subtitle': 'Culto dominical - 127 conectados',
              'image': 'https://via.placeholder.com/400x200',
              'colors': ['#667eea', '#764ba2'],
              'isLive': true,
            },
          ],
        },
        {
          'layout': 'category',
          'title': 'Acciones Rápidas',
          'countColumn': 2,
          'items': [
            {
              'name': 'Testimonios',
              'icon': 'chat',
            },
            {
              'name': 'Oración',
              'icon': 'prayer',
            },
            {
              'name': 'Eventos',
              'icon': 'event',
            },
            {
              'name': 'Música',
              'icon': 'music',
            },
          ],
        },
        {
          'layout': 'story',
          'title': 'Miembros Recientes',
          'items': [
            {
              'name': 'María S.',
              'image': 'https://via.placeholder.com/100x100',
            },
            {
              'name': 'Carlos M.',
              'image': 'https://via.placeholder.com/100x100',
            },
            {
              'name': 'Ana L.',
              'image': 'https://via.placeholder.com/100x100',
            },
          ],
        },
      ],
    });
  }
}
