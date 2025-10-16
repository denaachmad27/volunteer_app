import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/main_screen.dart';
import 'screens/profil_personal_screen.dart';
import 'screens/data_keluarga_screen.dart';
import 'screens/data_ekonomi_screen.dart';
import 'screens/data_sosial_screen.dart';
import 'screens/legislative_member_detail_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from .env file
  // Gunakan .env.production untuk production build
  // Gunakan .env.development untuk development
  try {
    // Try to load production env first
    await dotenv.load(fileName: ".env.production");
    debugPrint('✅ Loaded .env.production');
    debugPrint('API_BASE_URL: ${dotenv.env['API_BASE_URL']}');
    debugPrint('STORAGE_BASE_URL: ${dotenv.env['STORAGE_BASE_URL']}');
  } catch (e) {
    // Fallback to development env
    try {
      await dotenv.load(fileName: ".env.development");
      debugPrint('✅ Loaded .env.development');
      debugPrint('API_BASE_URL: ${dotenv.env['API_BASE_URL']}');
    } catch (e) {
      debugPrint('⚠️ No .env file found, using default values');
    }
  }

  runApp(VolunteerApp());
}

class VolunteerApp extends StatelessWidget {
  VolunteerApp({super.key});

  final GoRouter _router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const MainScreen(),
      ),
      GoRoute(
        path: '/profil-personal',
        builder: (context, state) => const ProfilPersonalScreen(),
      ),
      GoRoute(
        path: '/data-keluarga',
        builder: (context, state) => const DataKeluargaScreen(),
      ),
      GoRoute(
        path: '/data-ekonomi',
        builder: (context, state) => const DataEkonomiScreen(),
      ),
      GoRoute(
        path: '/data-sosial',
        builder: (context, state) => const DataSosialScreen(),
      ),
      GoRoute(
        path: '/legislative-member/:id',
        builder: (context, state) {
          final memberId = int.tryParse(state.pathParameters['id'] ?? '0') ?? 0;
          return LegislativeMemberDetailScreen(memberId: memberId);
        },
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'VolunteerHub',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFff5001),
          brightness: Brightness.light,
        ),
        fontFamily: 'System',
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
      routerConfig: _router,
    );
  }
}
