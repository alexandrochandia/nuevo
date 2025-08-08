import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/intro_screen.dart';
import '../register/improved/register_welcome_screen.dart';
import '../register/improved/register_name_screen.dart';
import '../register/improved/register_gender_screen.dart';
import '../register/improved/register_birthday_screen.dart';
import '../register/improved/register_notifications_screen.dart';
import '../register/improved/register_photos_screen.dart';
import '../register/improved/register_final_screen.dart';
import '../register/improved/welcome_activated_screen.dart';
import '../screens/simple_home_screen.dart';
import '../screens/main_navigation_screen.dart';
import '../screens/swipe_screen.dart' as swipe;
import '../screens/profile_screen.dart';
import '../screens/feed_screen.dart';
import '../screens/events_screen.dart';
import '../screens/livestream_screen.dart';
import '../screens/prayer_request_screen.dart';
import '../screens/spiritual_music_screen.dart';
import '../modules/testimonios/testimonios_screen.dart';
import '../screens/vmf_stories_screen.dart';
import '../screens/vmf_chat_screen.dart';
import '../screens/dating/vmf_dating_dashboard.dart';
import '../screens/live/vmf_enhanced_live_screen.dart';
import '../screens/dating/vmf_enhanced_dating_screen.dart';
import '../screens/live/vmf_enhanced_live_screen.dart';

// Router configuration
final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: [
    // Intro and improved registration routes
    GoRoute(
      path: '/',
      builder: (context, state) => const MainNavigationScreen(),
    ),
    GoRoute(
      path: '/main-navigation',
      builder: (context, state) => const MainNavigationScreen(),
    ),
    GoRoute(
      path: '/intro',
      builder: (context, state) => const IntroScreen(),
    ),
    GoRoute(
      path: '/register-welcome',
      builder: (context, state) => const RegisterWelcomeScreen(),
    ),
    GoRoute(
      path: '/register-gender',
      builder: (context, state) => const RegisterGenderScreen(),
    ),
    GoRoute(
      path: '/register-name',
      builder: (context, state) => const RegisterNameScreen(),
    ),
    GoRoute(
      path: '/register-birthday',
      builder: (context, state) => const RegisterBirthdayScreen(),
    ),
    GoRoute(
      path: '/register-notifications',
      builder: (context, state) => const RegisterNotificationsScreen(),
    ),
    GoRoute(
      path: '/register-photos',
      builder: (context, state) => const RegisterPhotosScreen(),
    ),
    GoRoute(
      path: '/register-final',
      builder: (context, state) => const RegisterFinalScreen(),
    ),
    GoRoute(
      path: '/welcome-activated',
      builder: (context, state) {
        final userName = state.extra as String? ?? 'Usuario';
        return WelcomeActivatedScreen(userName: userName);
      },
    ),
    // Main app routes
    GoRoute(
      path: '/home',
      builder: (context, state) => const SimpleHomeScreen(),
    ),
    GoRoute(
      path: '/simple-home',
      builder: (context, state) => const SimpleHomeScreen(),
    ),
    GoRoute(
      path: '/swipe',
      builder: (context, state) => const swipe.SwipeScreen(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/feed',
      builder: (context, state) => const FeedScreen(),
    ),
    GoRoute(
      path: '/events',
      builder: (context, state) => const EventsScreen(),
    ),
    GoRoute(
      path: '/livestream',
      builder: (context, state) => const LiveStreamScreen(),
    ),
    GoRoute(
      path: '/prayer-request',
      builder: (context, state) => const PrayerRequestScreen(),
    ),
    GoRoute(
      path: '/spiritual-music',
      builder: (context, state) => const SpiritualMusicScreen(),
    ),
    GoRoute(
      path: '/testimonios',
      builder: (context, state) => const TestimoniosScreen(),
    ),
    GoRoute(
      path: '/vmf-stories',
      builder: (context, state) => const VMFStoriesScreen(),
    ),
    GoRoute(
      path: '/vmf-chat',
      builder: (context, state) => const VMFChatScreen(),
    ),
    GoRoute(
      path: '/dating',
      builder: (context, state) => const VMFEnhancedDatingScreen(),
    ),
    GoRoute(
      path: '/live-streaming',
      builder: (context, state) => const VMFEnhancedLiveScreen(),
    ),
  ],
);