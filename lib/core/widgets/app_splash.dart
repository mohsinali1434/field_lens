import 'package:field_lens/app/theme/app_colors.dart';
import 'package:field_lens/app/theme/app_spacing.dart';
import 'package:field_lens/core/constants/app_constants.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:material_ui/material_ui.dart';

/// Shared launch gate so native + Flutter splash dismiss together.
abstract final class AppSplashGate {
  static final ValueNotifier<bool> isReady = ValueNotifier<bool>(false);

  static void markReady() {
    if (!isReady.value) {
      isReady.value = true;
    }
  }
}

/// Branded splash matching the native launch screen.
class AppSplashView extends StatelessWidget {
  const AppSplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: AppColors.primary,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Image(
              image: AssetImage('assets/branding/splash_logo.png'),
              width: 148,
              height: 148,
              filterQuality: FilterQuality.high,
            ),
            SizedBox(height: AppSpacing.lg),
            Text(
              AppConstants.appName,
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Covers the app with [AppSplashView] until the first real screen is ready.
class AppSplashHandoff extends StatefulWidget {
  const AppSplashHandoff({required this.child, super.key});

  final Widget child;

  @override
  State<AppSplashHandoff> createState() => _AppSplashHandoffState();
}

class _AppSplashHandoffState extends State<AppSplashHandoff> {
  bool _nativeRemoved = false;

  @override
  void initState() {
    super.initState();
    AppSplashGate.isReady.addListener(_onReadyChanged);
    _onReadyChanged();
  }

  @override
  void dispose() {
    AppSplashGate.isReady.removeListener(_onReadyChanged);
    super.dispose();
  }

  void _onReadyChanged() {
    if (!AppSplashGate.isReady.value || _nativeRemoved) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _nativeRemoved) return;
      FlutterNativeSplash.remove();
      _nativeRemoved = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: AppSplashGate.isReady,
      builder: (BuildContext context, bool ready, Widget? child) {
        return Stack(
          fit: StackFit.expand,
          children: <Widget>[
            child!,
            if (!ready) const AppSplashView(),
          ],
        );
      },
      child: widget.child,
    );
  }
}

/// Marks splash ready after this page paints its first frame.
mixin AppSplashReadyMixin<T extends StatefulWidget> on State<T> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppSplashGate.markReady();
    });
  }
}
