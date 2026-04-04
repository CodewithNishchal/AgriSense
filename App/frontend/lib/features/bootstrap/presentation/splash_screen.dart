import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/editorial_gradients.dart';

/// AgriSense splash — routes to login.
/// Shows first, then navigates to [LoginScreen] after [autoNavigateDelay].
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  /// Time splash is visible before auto-routing to `/login`.
  static const Duration autoNavigateDelay = Duration(milliseconds: 2800);

  static const String _bgImageUrl =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuDjHqVEmE3-v6u1SGjnpwQWXnfIQFJksi-O9t4AEl3L-S9jjGuZ7a5D9iZJ-pOL4U51E8vFukj_4DEZp2hZKkXOkW4y7r2i-pFr-LBxeH1FCFxKZSzKTPoGZrMQRPVrHT2GX0ikAyKS09zsDe_iapQFAmR5lvYc-_NRfjW_ymvGPRdoBDOQLDxqpxZhXI6_QFluqzWh_KekKvfMaXosdINyPXZqqbD4UurZgCPKNxydQfsW_Z7hLNbQFhljcGfdBVFG7tOunxTp446E';

  static const String _avatar1 =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuC7oSjxpamDW72Wg0ar7hseAyAZpw-Vq0ZP7KvAR2nGqQCU7W3VtOf-LhCnl3_hWFb0-2KgV50_TUN3GW7qBfho8_Ypl5cO7cr77Syg7bVEeH-x2iTFIXOcXG-3nVSPAr20IvBSErTs6UsoZI3XJxI0T2Qj5UPHm57AXuppViRR1ftQAIPkv1SHMhlv1fEn4Y18VC47cTLauRgRXLc678itO6Udd73sTijWy2IXi1prDa3G6ZHxUu5miG8wYqONWsgEF5CvqqaGUFe3';

  static const String _avatar2 =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuAMrkTPYvv1235AYE4Qkx4JKkzIRzKGfVUkGvAiov4LBRFel7xK3ajo757u6l74TBUZJ8XrL_IU2twkj8B1j5HKSzzv_ty6r3IBMCDH9HqXHYXCwUto0G3aSc4q38MjIkPJtquT69wUlilpRA1lNn_3E_wLPrSm8BuT59p4wEEwJM_RwN3hMBRNzpq3t1OjBybnOmE2kwt-_TrDIj44GEMEk_ZUgTDCnJYebtkh5j3yfkS9x4ChgqZuaTnGnAaQFJ6M6oz7HSoTpai4';

  static const String _avatar3 =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuBjhqtVrlkXCerL95m6ypbxiHwt1tXY8k6TmAmdrb3Tx-pRimPMdkrS2SCZyyURfW-ET9shRJqYLWkXoASbE4Bde8hVpcPQvrLhF4yPJy6ONQA1GMAbi1UIm9H8QF64pANvyqUjC21BLp2Lt4_32PEQcVDw1PBujP_8yNpjBYrYZfwbfTmt3ZIiGGJiot-oLakKk6PquMdWlyfqekLPP9QMDDOIn-bC0_XB3zwy-hD7c3jybOCchVEe7PUsz9Yn8SvdESemmnK9M9-1';

  /// Peach accent from HTML (`secondary`)
  static const Color _secondary = Color(0xFFF0BD8B);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _navTimer;

  void _goLogin() {
    _navTimer?.cancel();
    _navTimer = null;
    if (!mounted) return;
    context.go('/login');
  }

  @override
  void initState() {
    super.initState();
    _navTimer = Timer(SplashScreen.autoNavigateDelay, _goLogin);
  }

  @override
  void dispose() {
    _navTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final w = size.width;
    final md = w >= 768;
    final lg = w >= 1024;

    final hPad = md ? 48.0 : 24.0;
    final vPad = md ? 80.0 : 48.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // --- Full-bleed background + gradient ---
          Positioned.fill(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Transform.scale(
                  scale: 1.05,
                  child: Opacity(
                    opacity: 0.8,
                    child: Image.network(
                      SplashScreen._bgImageUrl,
                      fit: BoxFit.cover,
                      width: size.width,
                      height: size.height,
                      alignment: Alignment.center,
                      errorBuilder: (_, __, ___) => ColoredBox(
                        color: AppColors.surfaceContainerLow,
                        child: Icon(
                          Icons.landscape_rounded,
                          size: 96,
                          color: AppColors.primary.withValues(alpha: 0.4),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.background.withValues(alpha: 0.4),
                          Colors.transparent,
                          AppColors.background,
                        ],
                        stops: const [0.0, 0.45, 1.0],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // --- Main column (z-10) ---
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _LogoBlock(),
                  const Spacer(),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 672),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text.rich(
                          TextSpan(
                            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                  fontSize: md ? 72 : 48,
                                  fontWeight: FontWeight.w800,
                                  height: 1.1,
                                  letterSpacing: -0.5,
                                  color: Colors.white,
                                ),
                            children: [
                              const TextSpan(text: 'Precision in\n'),
                              TextSpan(
                                text: 'every acre.',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: md ? 72 : 48,
                                  fontWeight: FontWeight.w800,
                                  height: 1.1,
                                  letterSpacing: -0.5,
                                  fontFamily: Theme.of(context)
                                      .textTheme
                                      .displaySmall
                                      ?.fontFamily,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Connect with the pulse of your land. Real-time insights and biological precision for the modern grower.',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: AppColors.onSurface.withValues(alpha: 0.8),
                                fontSize: md ? 20 : 18,
                                height: 1.6,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),
                  _CtaRow(
                    md: md,
                    avatar1: SplashScreen._avatar1,
                    avatar2: SplashScreen._avatar2,
                    avatar3: SplashScreen._avatar3,
                    onGetStarted: _goLogin,
                  ),
                ],
              ),
            ),
          ),

          // --- Field Analysis card (lg+) ---
          if (lg)
            Positioned(
              top: size.height * 0.25,
              right: 48,
              child: _FieldAnalysisCard(),
            ),

          // --- Moisture card (md+) ---
          if (md)
            Positioned(
              left: md ? 96 : 24,
              bottom: size.height * 0.33,
              child: _MoistureCard(secondary: SplashScreen._secondary),
            ),
        ],
      ),
    );
  }
}

class _LogoBlock extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.2),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.eco_rounded,
            color: AppColors.onPrimary,
            size: 28,
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'AgriSense',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 3.2,
                    color: AppColors.primary,
                    fontSize: 22,
                  ),
            ),
            const SizedBox(height: 2),
            Text(
              'SMART CROP CARE',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 2.4,
                    color: AppColors.onSurface.withValues(alpha: 0.6),
                  ),
            ),
          ],
        ),
      ],
    );
  }
}

class _CtaRow extends StatelessWidget {
  const _CtaRow({
    required this.md,
    required this.avatar1,
    required this.avatar2,
    required this.avatar3,
    required this.onGetStarted,
  });

  final bool md;
  final String avatar1;
  final String avatar2;
  final String avatar3;
  final VoidCallback onGetStarted;

  @override
  Widget build(BuildContext context) {
    final buttonInner = DecoratedBox(
      decoration: BoxDecoration(
        gradient: EditorialGradients.primaryCta,
        borderRadius: BorderRadius.circular(9999),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 32,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onGetStarted,
          borderRadius: BorderRadius.circular(9999),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
            child: Center(
              child: Text(
                'GET STARTED',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppColors.onPrimary,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2.4,
                      fontSize: 13,
                    ),
              ),
            ),
          ),
        ),
      ),
    );

    final Widget button =
        md ? buttonInner : SizedBox(width: double.infinity, child: buttonInner);

    final avatarStrip = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _OverlapAvatar(url: avatar1),
        Transform.translate(
          offset: const Offset(-12, 0),
          child: _OverlapAvatar(url: avatar2),
        ),
        Transform.translate(
          offset: const Offset(-24, 0),
          child: _OverlapAvatar(url: avatar3),
        ),
      ],
    );

    final growersLabel = Text(
      'JOINED BY 10K+ GROWERS',
      textAlign: TextAlign.center,
      maxLines: 2,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: AppColors.onSurface.withValues(alpha: 0.6),
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
            fontSize: 11,
          ),
    );

    if (md) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          button,
          const SizedBox(width: 16),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              avatarStrip,
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: growersLabel,
              ),
            ],
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        button,
        const SizedBox(height: 16),
        Center(child: avatarStrip),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: growersLabel,
        ),
      ],
    );
  }
}

class _OverlapAvatar extends StatelessWidget {
  const _OverlapAvatar({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.background, width: 2),
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => ColoredBox(
          color: AppColors.surfaceContainerHigh,
          child: Icon(Icons.person, color: AppColors.onSurfaceMuted),
        ),
      ),
    );
  }
}

class _FieldAnalysisCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: 0.035,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            width: 300,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: const Color(0x99121410),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.05),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 32,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'FIELD ANALYSIS',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.onSurface.withValues(alpha: 0.5),
                            letterSpacing: 2,
                            fontSize: 10,
                          ),
                    ),
                    Icon(
                      Icons.query_stats_rounded,
                      color: AppColors.primary,
                      size: 22,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  '98.4%',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        fontSize: 40,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'SOIL VITALITY INDEX',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        fontSize: 11,
                      ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 64,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _MiniBar(h: 0.5),
                      _MiniBar(h: 0.75),
                      _MiniBar(h: 1.0, filled: true),
                      _MiniBar(h: 0.66),
                      _MiniBar(h: 0.5),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MiniBar extends StatelessWidget {
  const _MiniBar({required this.h, this.filled = false});

  final double h;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: FractionallySizedBox(
            heightFactor: h,
            widthFactor: 1,
            alignment: Alignment.bottomCenter,
            child: Container(
              decoration: BoxDecoration(
                color: filled
                    ? AppColors.primary
                    : AppColors.primary.withValues(alpha: 0.2),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
                boxShadow: filled
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.4),
                          blurRadius: 8,
                        ),
                      ]
                    : null,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MoistureCard extends StatelessWidget {
  const _MoistureCard({required this.secondary});

  final Color secondary;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -0.017,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0x99121410),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.05),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 32,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: secondary.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.water_drop_rounded,
                    color: secondary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MOISTURE',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.onSurface.withValues(alpha: 0.6),
                            letterSpacing: 2,
                            fontSize: 11,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '42.8%',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    fontSize: 22,
                                  ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Optimal',
                          style:
                              Theme.of(context).textTheme.labelMedium?.copyWith(
                                    color: secondary,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 12,
                                  ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
