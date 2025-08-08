class CommunityStatsModel {
  final int activeMembers;
  final int dailyVisits;
  final int weeklyTestimonios;
  final int prayersAnswered;
  final int upcomingEvents;
  final int onlineNow;
  final double engagementRate;
  final List<String> recentActivities;
  final String nextEvent;
  final DateTime lastUpdated;

  CommunityStatsModel({
    required this.activeMembers,
    required this.dailyVisits,
    required this.weeklyTestimonios,
    required this.prayersAnswered,
    required this.upcomingEvents,
    required this.onlineNow,
    required this.engagementRate,
    required this.recentActivities,
    required this.nextEvent,
    required this.lastUpdated,
  });

  factory CommunityStatsModel.mock() {
    return CommunityStatsModel(
      activeMembers: 247,
      dailyVisits: 89,
      weeklyTestimonios: 12,
      prayersAnswered: 34,
      upcomingEvents: 3,
      onlineNow: 24,
      engagementRate: 87.5,
      recentActivities: [
        'Ana compartió un testimonio',
        'Carlos se unió a Alabanza',
        'María registró una oración',
        'Pedro visitó Devocionales',
        'Sofia participó en Eventos',
      ],
      nextEvent: 'Culto de Jóvenes - 2h 15m',
      lastUpdated: DateTime.now(),
    );
  }

  // Animated counter helpers
  String get activeMembersDisplay => activeMembers.toString();
  String get dailyVisitsDisplay => dailyVisits.toString();
  String get engagementDisplay => '${engagementRate.toStringAsFixed(1)}%';
  String get onlineDisplay => '$onlineNow en línea';
}