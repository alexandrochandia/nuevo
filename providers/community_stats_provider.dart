import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import '../models/community_stats_model.dart';

class CommunityStatsProvider extends ChangeNotifier {
  CommunityStatsModel _stats = CommunityStatsModel.mock();
  Timer? _updateTimer;
  bool _isLoading = false;

  CommunityStatsModel get stats => _stats;
  bool get isLoading => _isLoading;

  CommunityStatsProvider() {
    _startRealTimeUpdates();
  }

  void _startRealTimeUpdates() {
    // Update stats every 30 seconds to simulate real-time activity
    _updateTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _updateStats();
    });
  }

  void _updateStats() {
    final random = Random();
    
    // Simulate realistic fluctuations
    final newStats = CommunityStatsModel(
      activeMembers: _stats.activeMembers + random.nextInt(3) - 1, // ±1
      dailyVisits: _stats.dailyVisits + random.nextInt(5), // +0 to +4
      weeklyTestimonios: _stats.weeklyTestimonios + (random.nextBool() ? 1 : 0),
      prayersAnswered: _stats.prayersAnswered + (random.nextBool() ? 1 : 0),
      upcomingEvents: _stats.upcomingEvents,
      onlineNow: max(15, _stats.onlineNow + random.nextInt(6) - 3), // ±3, min 15
      engagementRate: (_stats.engagementRate + random.nextDouble() * 2 - 1).clamp(80.0, 95.0),
      recentActivities: _generateRecentActivities(),
      nextEvent: _stats.nextEvent,
      lastUpdated: DateTime.now(),
    );

    _stats = newStats;
    notifyListeners();
  }

  List<String> _generateRecentActivities() {
    final activities = [
      'Ana compartió un testimonio',
      'Carlos se unió a Alabanza',
      'María registró una oración',
      'Pedro visitó Devocionales',
      'Sofia participó en Eventos',
      'Luis comentó en Multimedia',
      'Carmen favoritó una canción',
      'Daniel se conectó desde Stockholm',
      'Isabella visitó Casas Iglesias',
      'Miguel actualizó su perfil',
    ];
    
    activities.shuffle();
    return activities.take(5).toList();
  }

  Future<void> refreshStats() async {
    _isLoading = true;
    notifyListeners();
    
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 800));
    
    _updateStats();
    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }
}