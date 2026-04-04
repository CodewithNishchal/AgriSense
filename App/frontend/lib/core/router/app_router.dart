import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/disease_detection/presentation/disease_result_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/pest_detection/presentation/pest_result_screen.dart';
import '../../features/scan/presentation/scan_screen.dart';
import '../../features/tools/presentation/tools_screen.dart';
import '../../features/community/presentation/community_feed_screen.dart';
import '../../features/community/presentation/community_post_screen.dart';
import '../../features/community/presentation/community_thread_screen.dart';
import '../../features/crop/presentation/crop_screen.dart';
import '../../features/disease_risk/presentation/disease_risk_screen.dart';
import '../../features/iot/presentation/iot_screen.dart';
import '../../features/market/presentation/market_detail_screen.dart';
import '../../features/market/presentation/market_list_screen.dart';
import '../../features/ml_lab/presentation/ml_lab_screen.dart';
import '../../features/more/presentation/more_screen.dart';
import '../../features/satellite/presentation/satellite_screen.dart';
import '../../features/schemes/presentation/schemes_eligibility_screen.dart';
import '../../features/schemes/presentation/schemes_list_screen.dart';
import '../../features/soil/presentation/soil_screen.dart';
import '../../features/voice/presentation/voice_screen.dart';
import '../../features/weather/presentation/weather_screen.dart';
import '../../features/yield/presentation/yield_screen.dart';
import '../../features/bootstrap/presentation/splash_screen.dart';
import '../../features/agri_shell/presentation/agri_shell.dart';
import '../../features/agri_shell/presentation/disease_map_screen.dart';
import '../../features/agri_shell/presentation/fleet_dashboard_screen.dart';
import '../../features/agri_shell/presentation/equipment_marketplace_screen.dart';
import '../../features/auth/login.dart';
import '../../features/auth/signup.dart';
import '../session/user_prefs.dart';
import '../session/user_role.dart';
import '../widgets/app_info_page.dart';
import 'app_shell.dart';

IconData _infoPageIcon(String? key) {
  switch (key) {
    case 'settings':
      return Icons.settings_rounded;
    case 'help':
      return Icons.help_outline_rounded;
    case 'info':
      return Icons.info_outline_rounded;
    default:
      return Icons.auto_awesome_rounded;
  }
}

final GlobalKey<NavigatorState> _rootNavKey = GlobalKey<NavigatorState>(debugLabel: 'root');

/// Lenders use the 4-tab Agri shell only; farmers use [AppShell] (5 tabs).
String? roleAwareRedirect(BuildContext context, GoRouterState state) {
  final role = UserPrefs.instance.role;
  final path = state.uri.path;

  if (role == UserRole.lender) {
    switch (path) {
      case '/':
        return '/agri/map';
      case '/scan':
        return '/agri/scan';
      case '/tools':
      case '/community':
      case '/more':
        return '/agri/map';
    }
  }

  if (path.startsWith('/agri/') && role == UserRole.farmer) {
    if (path == '/agri/map') return '/farmer/map';
    if (path == '/agri/marketplace') return '/farmer/marketplace';
    if (path == '/agri/scan') return '/scan';
    if (path == '/agri/fleet') return '/';
  }
  if (path.startsWith('/farmer/') && role == UserRole.lender) {
    if (path == '/farmer/map') return '/agri/map';
    if (path == '/farmer/marketplace') return '/agri/marketplace';
  }
  return null;
}

enum AppRoute {
  home('/'),
  scan('/scan'),
  tools('/tools'),
  community('/community'),
  more('/more');

  const AppRoute(this.path);
  final String path;
}

GoRouter createAppRouter() {
  return GoRouter(
    navigatorKey: _rootNavKey,
    initialLocation: '/splash',
    redirect: roleAwareRedirect,
    routes: [
      GoRoute(
        path: '/splash',
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (_, __) => const SignupScreen(),
      ),
      GoRoute(
        path: '/farmer/map',
        builder: (_, __) => const DiseaseMapScreen(),
      ),
      GoRoute(
        path: '/farmer/marketplace',
        builder: (_, __) => const EquipmentMarketplaceScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AgriShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/agri/map',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: DiseaseMapScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/agri/scan',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: ScanScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/agri/fleet',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: FleetDashboardScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/agri/marketplace',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: EquipmentMarketplaceScreen(),
                ),
              ),
            ],
          ),
        ],
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoute.home.path,
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: HomeScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoute.scan.path,
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: ScanScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoute.tools.path,
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: ToolsScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoute.community.path,
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: CommunityFeedScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoute.more.path,
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: MoreScreen(),
                ),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/disease-result',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          List<String>? steps;
          final rawSteps = extra?['remediationSteps'];
          if (rawSteps is List) {
            steps = rawSteps.map((e) => e.toString()).toList();
          }
          Map<String, dynamic>? fullReport;
          final fr = extra?['fullReport'];
          if (fr is Map) {
            fullReport = Map<String, dynamic>.from(fr);
          }
          return DiseaseResultScreen(
            diseaseName: extra?['diseaseName'] as String? ?? 'Unknown',
            confidence: (extra?['confidence'] as num?)?.toDouble() ?? 0,
            treatment: extra?['treatment'] as String? ?? '',
            imagePath: extra?['imagePath'] as String?,
            remediationSteps: steps,
            locationLabel: extra?['locationLabel'] as String?,
            fullReport: fullReport,
            geminiQuestionPrefill: extra?['geminiQuestionPrefill'] as String?,
          );
        },
      ),
      GoRoute(
        path: '/pest-result',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return PestResultScreen(
            pestName: extra?['pestName'] as String? ?? 'Unknown',
            controlMethod: extra?['controlMethod'] as String? ?? '',
            affectedCrops: extra?['affectedCrops'] as String? ?? '',
            imagePath: extra?['imagePath'] as String?,
          );
        },
      ),
      GoRoute(path: '/soil', builder: (_, __) => const SoilScreen()),
      GoRoute(path: '/crop', builder: (_, __) => const CropScreen()),
      GoRoute(path: '/weather', builder: (_, __) => const WeatherScreen()),
      GoRoute(path: '/disease-risk', builder: (_, __) => const DiseaseRiskScreen()),
      GoRoute(path: '/market', builder: (_, __) => const MarketListScreen()),
      GoRoute(
        path: '/market/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return MarketDetailScreen(commodityName: id);
        },
      ),
      GoRoute(path: '/yield', builder: (_, __) => const YieldScreen()),
      GoRoute(path: '/voice', builder: (_, __) => const VoiceScreen()),
      GoRoute(
        path: '/info',
        builder: (context, state) {
          final raw = state.extra;
          if (raw is! Map) {
            return const AppInfoPage(
              title: 'Information',
              icon: Icons.info_outline_rounded,
            );
          }
          final m = Map<String, dynamic>.from(raw);
          return AppInfoPage(
            title: m['title'] as String? ?? 'Information',
            icon: _infoPageIcon(m['icon'] as String?),
            message: m['message'] as String?,
            primaryRoute: m['primaryRoute'] as String?,
            primaryLabel: m['primaryLabel'] as String?,
          );
        },
      ),
      GoRoute(path: '/ml-lab', builder: (_, __) => const MlLabScreen()),
      GoRoute(path: '/schemes', builder: (_, __) => const SchemesEligibilityScreen()),
      GoRoute(path: '/schemes/list', builder: (_, __) => const SchemesListScreen()),
      GoRoute(
        path: '/community/thread/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '0';
          return CommunityThreadScreen(threadId: id);
        },
      ),
      GoRoute(path: '/community/post', builder: (_, __) => const CommunityPostScreen()),
      GoRoute(path: '/iot', builder: (_, __) => const IoTScreen()),
      GoRoute(path: '/satellite', builder: (_, __) => const SatelliteScreen()),
    ],
  );
}
