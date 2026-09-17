import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import '../core/utils/snack_bar.dart';
import '../features/details/presentation/article_details_screen.dart';
import '../features/settings/presentation/cubit/settings_cubit.dart';
import 'app_router.dart';

/// Deep links (X3) — `newsfeed://article/{id}` and
/// `https://newsfeed.app/article/{id}`.
///
/// Cold start with onboarding not yet completed: the route is held until
/// onboarding finishes, then pushed on top of the fresh [AppShell]. Warm
/// start, or cold start already onboarded: pushed immediately over
/// whichever tab is showing. A malformed link never blocks the app — it
/// just falls back to the feed with a snackbar.
class DeepLinkController {
  final GlobalKey<NavigatorState> navigatorKey;
  final SettingsCubit settings;
  final AppLinks _appLinks;

  StreamSubscription<Uri>? _linkSubscription;
  StreamSubscription<SettingsState>? _settingsSubscription;
  AppRoute? _pendingRoute;

  DeepLinkController({
    required this.navigatorKey,
    required this.settings,
    AppLinks? appLinks,
  }) : _appLinks = appLinks ?? AppLinks();

  Future<void> start() async {
    _settingsSubscription = settings.stream.listen(_onSettingsChanged);
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) => _handle(uri.toString()));
    final initial = await _appLinks.getInitialLink();
    if (initial != null) _handle(initial.toString());
  }

  void dispose() {
    _linkSubscription?.cancel();
    _settingsSubscription?.cancel();
  }

  void _onSettingsChanged(SettingsState state) {
    if (!state.onboardingCompleted || _pendingRoute == null) return;
    final route = _pendingRoute!;
    _pendingRoute = null;
    _push(route);
  }

  void _handle(String link) {
    final route = AppRouter.parse(link);
    if (route == null) {
      _showMalformedLinkMessage();
      return;
    }
    if (!settings.state.onboardingCompleted) {
      _pendingRoute = route;
      return;
    }
    _push(route);
  }

  void _push(AppRoute route) {
    final navigator = navigatorKey.currentState;
    if (navigator == null) return;
    switch (route) {
      case ArticleRoute(:final articleId):
        navigator.push(MaterialPageRoute(builder: (_) => ArticleDetailsScreen.byId(articleId)));
    }
  }

  void _showMalformedLinkMessage() {
    final context = navigatorKey.currentContext;
    if (context == null) return;
    showSnackBarMessage(context, "That link didn't work");
  }
}
