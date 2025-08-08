import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'services/supabase_service.dart';
import 'config/firebase_options.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'router/app_router.dart';
import 'screens/modern_onboarding_screen.dart';
import 'screens/intro_screen.dart';
import 'register/improved/register_welcome_screen.dart';
import 'register/improved/register_gender_screen.dart';
import 'register/improved/register_name_screen.dart';
import 'register/improved/register_birthday_screen.dart';
import 'register/improved/register_notifications_screen.dart';
import 'register/improved/register_photos_screen.dart';
import 'register/improved/register_final_screen.dart';
import 'features/vmf_connect/vmf_connect_screen.dart';
import 'register/improved/registration_controller.dart';
import 'screens/simple_home_screen.dart';
import 'screens/main_navigation_screen.dart';
import 'screens/store/vmf_store_onboarding_screen.dart';
import 'screens/store/vmf_store_screen.dart';
import 'providers/user_provider.dart';
import 'providers/swipe_provider.dart';
import 'providers/aura_provider.dart';
import 'providers/gallery_provider.dart';
import 'providers/testimonio_provider.dart';
import 'providers/events_provider.dart';
import 'providers/media_provider.dart';
import 'providers/church_provider.dart';
import 'providers/alabanza_provider.dart';
import 'providers/casas_iglesias_provider.dart';
import 'providers/pastor_provider.dart';
import 'providers/community_stats_provider.dart';
import 'providers/visit_provider.dart';
import 'providers/vmf_stories_provider.dart';
import 'providers/livestream_provider.dart';
import 'providers/offering_provider.dart';
import 'providers/feed_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/spiritual_profile_provider.dart';
import 'providers/search_provider.dart';
import 'providers/prayer_request_provider.dart';
import 'providers/ministry_provider.dart';
import 'providers/qr_code_provider.dart';
import 'providers/spiritual_music_provider.dart';
import 'providers/devotional_provider.dart';
import 'providers/vmf_store_provider.dart';
import 'providers/profile_modal_provider.dart';
import 'models/store/vmf_cart_model.dart';
import 'config/supabase_config.dart';
import 'config/firebase_config.dart';
import 'utils/error_handler.dart';
import 'utils/framework_fix.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ErrorHandler.initialize();

  try {
    if (SupabaseConfig.url.isNotEmpty && SupabaseConfig.anonKey.isNotEmpty) {
      await Supabase.initialize(
        url: SupabaseConfig.url,
        anonKey: SupabaseConfig.anonKey,
      );
      print('✅ Supabase inicializado correctamente');
    } else {
      print('ℹ️ Supabase no configurado - usando datos de prueba');
    }
  } catch (e) {
    print('❌ Supabase initialization failed: $e');
  }

  try {
    if (!kIsWeb) {
      await FirebaseConfig.initialize();
    }
  } catch (e) {
    print('❌ Firebase initialization failed: $e');
  }

  await initializeDateFormatting('es', null);

  final prefs = await SharedPreferences.getInstance();
  final onboardingCompleted = prefs.getBool('onboarding_completed') ?? false;

  runApp(VMFSwedenApp(onboardingCompleted: onboardingCompleted));
}

class VMFSwedenApp extends StatelessWidget {
  final bool onboardingCompleted;
  const VMFSwedenApp({required this.onboardingCompleted, super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RegistrationController()),
        ChangeNotifierProvider(create: (_) => UserProvider()..loadUsers()),
        ChangeNotifierProvider(create: (_) => SwipeProvider()),
        ChangeNotifierProvider(create: (_) => AuraProvider()..loadAuraSettings()),
        ChangeNotifierProvider(create: (_) => GalleryProvider()),
        ChangeNotifierProvider(create: (_) => TestimonioProvider()),
        ChangeNotifierProvider(create: (_) => EventsProvider()),
        ChangeNotifierProvider(create: (_) => MediaProvider()),
        ChangeNotifierProvider(create: (_) => ChurchProvider()),
        ChangeNotifierProvider(create: (_) => AlabanzaProvider()),
        ChangeNotifierProvider(create: (_) => CasasIglesiasProvider()),
        ChangeNotifierProvider(create: (_) => DevotionalProvider()),
        ChangeNotifierProvider(create: (_) => PastorProvider()),
        ChangeNotifierProvider(create: (_) => CommunityStatsProvider()),
        ChangeNotifierProvider(create: (_) => VisitProvider()),
        ChangeNotifierProvider(create: (_) => VMFStoriesProvider()),
        ChangeNotifierProvider(create: (_) => LiveStreamProvider()),
        ChangeNotifierProvider(create: (_) => OfferingProvider()),
        ChangeNotifierProvider(create: (_) => FeedProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => SpiritualProfileProvider()),
        ChangeNotifierProvider(create: (_) => SearchProvider()),
        ChangeNotifierProvider(create: (_) => PrayerRequestProvider()),
        ChangeNotifierProvider(create: (_) => MinistryProvider()),
        ChangeNotifierProvider(create: (_) => QRCodeProvider()),
        ChangeNotifierProvider(create: (_) => SpiritualMusicProvider()),
        ChangeNotifierProvider(create: (_) => VMFStoreProvider()),
        ChangeNotifierProvider(create: (_) => ProfileModalProvider()),
        ChangeNotifierProvider(create: (_) => VMFCartModel()),
      ],
      child: GetMaterialApp(
        title: 'VMF Sweden Swipe',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          fontFamily: 'Roboto',
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        debugShowCheckedModeBanner: false,
        home: onboardingCompleted
            ? const MainNavigationScreen()
            : const ModernOnboardingScreen(),
        getPages: [
          GetPage(
            name: '/',
            page: () => onboardingCompleted
                ? const MainNavigationScreen()
                : const ModernOnboardingScreen(),
          ),
          GetPage(
            name: '/home',
            page: () => const MainNavigationScreen(),
          ),
          GetPage(
            name: '/simple-home',
            page: () => const SimpleHomeScreen(),
          ),
          GetPage(
            name: '/vmf-connect',
            page: () => const VMFConnectScreen(),
          ),
          GetPage(
            name: '/store-onboarding',
            page: () => const VMFStoreOnboardingScreen(),
          ),
          GetPage(
            name: '/store',
            page: () => const VMFStoreScreen(),
          ),
        ],
      ),
    );
  }
}
