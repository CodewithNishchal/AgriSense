import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'core/router/app_router.dart';
import 'core/session/user_prefs.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/editorial_screen_background.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: 'assets/.env', isOptional: true);
  await UserPrefs.instance.init();
  runApp(const AgriSenseApp());
}

class AgriSenseApp extends StatelessWidget {
  const AgriSenseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'AgriSense',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.editorial,
      builder: (context, child) {
        return Stack(
          fit: StackFit.expand,
          children: [
            const EditorialScreenBackground(),
            child ?? const SizedBox.shrink(),
          ],
        );
      },
      routerConfig: createAppRouter(),
    );
  }
}
