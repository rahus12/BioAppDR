import 'package:flutter/material.dart';

/// Global navigator key for app-wide navigation
/// Used by BioAssistant to navigate from the global overlay
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// True when the chat page's navigation dropdown is open (hides floating button)
final ValueNotifier<bool> isChatDropdownOpen = ValueNotifier<bool>(false);

/// Tracks current route so BioAssistant can hide when Bio Buddy chat is open
class BioBuddyRouteObserver extends NavigatorObserver {
  BioBuddyRouteObserver._();
  static final BioBuddyRouteObserver instance = BioBuddyRouteObserver._();

  final ValueNotifier<String?> currentRoute = ValueNotifier<String?>(null);

  @override
  void didPush(Route route, Route? previousRoute) {
    currentRoute.value = route.settings.name ?? '/';
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    currentRoute.value = previousRoute?.settings.name ?? '/';
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    currentRoute.value = newRoute?.settings.name ?? '/';
  }
}
