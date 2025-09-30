import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:wyceny/app/auth.dart';
import 'package:wyceny/l10n/app_localizations.dart';

class _AppVersionText extends StatefulWidget {
  const _AppVersionText();

  @override
  State<_AppVersionText> createState() => _AppVersionTextState();
}

class _AppVersionTextState extends State<_AppVersionText> {
  String? _version;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final info = await PackageInfo.fromPlatform();
    if (!mounted) return;
    setState(() => _version = '${info.version}+${info.buildNumber}');
  }

  @override
  Widget build(BuildContext context) {
    if (_version == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: Text(
        'v $_version',
        style: Theme.of(context).textTheme.labelSmall,
        textAlign: TextAlign.center,
      ),
    );
  }
}

class AppScaffold extends StatefulWidget {
  final StatefulNavigationShell shell;
  const AppScaffold({super.key, required this.shell});
  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

// ...imports bez zmian
class _AppScaffoldState extends State<AppScaffold> {
  int get index => widget.shell.currentIndex;
  void _onTap(int i) => widget.shell.goBranch(i, initialLocation: i == index);

  String _titleFor(BuildContext context, int i) {
    final t = AppLocalizations.of(context);
    switch (i) {
      case 0: return t.nav_quote;
      case 1: return t.nav_order;
      case 2: return t.nav_settings;
      default: return '…';
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final isWide = MediaQuery.sizeOf(context).width >= 600;

    final mobileDestinations = [
      NavigationDestination(icon: const Icon(Icons.euro_outlined), selectedIcon: const Icon(Icons.euro), label: t.nav_quote),
      NavigationDestination(icon: const Icon(Icons.shopping_basket_outlined), selectedIcon: const Icon(Icons.shopping_basket), label: t.nav_order),
      NavigationDestination(icon: const Icon(Icons.settings_outlined), selectedIcon: const Icon(Icons.settings), label: t.nav_settings),
    ];

    final railDestinations = [
      NavigationRailDestination(icon: const Icon(Icons.euro_outlined), selectedIcon: const Icon(Icons.euro), label: Text(t.nav_quote)),
      NavigationRailDestination(icon: const Icon(Icons.shopping_basket_outlined), selectedIcon: const Icon(Icons.shopping_basket), label: Text(t.nav_order)),
      NavigationRailDestination(icon: const Icon(Icons.settings_outlined), selectedIcon: const Icon(Icons.settings), label: Text(t.nav_settings)),
    ];

    final content = ClipRect(child: widget.shell);

    if (isWide) {
      final t = AppLocalizations.of(context);

      final rail = Theme(
        data: Theme.of(context).copyWith(
          navigationRailTheme: NavigationRailThemeData(
            backgroundColor: Colors.indigo,
            indicatorColor: Colors.white70, // highlight pod wybranym
            selectedIconTheme: const IconThemeData(color: Colors.black),
            unselectedIconTheme: const IconThemeData(color: Colors.white),
            selectedLabelTextStyle: const TextStyle(color: Colors.white),
            unselectedLabelTextStyle: const TextStyle(color: Colors.white),
          ),
        ),
        child: NavigationRail(
          selectedIndex: index,
          onDestinationSelected: _onTap,
          labelType: NavigationRailLabelType.all,
          destinations: railDestinations,
        ),
      );

      return Scaffold(
        body: Row(
          children: [
            Container(
              // teraz tło raila jest indigo
              color: Colors.indigo,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 80),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Image.asset(
                        'assets/hellmann256.png',
                        height: 64,
                        fit: BoxFit.contain,
                        semanticLabel: t.app_companyName,
                      ),
                    ),
                    Expanded(child: rail),
                    SafeArea(
                      top: false,
                      minimum: const EdgeInsets.only(bottom: 8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          _LogoutButton(),
                          SizedBox(height: 6),
                          _AppVersionText(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const VerticalDivider(width: 1),
            Expanded(child: content),
          ],
        ),
      );
    }


    // WIDOK MOBILNY/TABLETOWY: AppBar z logo (jak wcześniej)
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            const SizedBox(width: 8),
            Image.asset('assets/hellmannblue.png', height: 22, fit: BoxFit.contain, semanticLabel: t.app_companyName),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _titleFor(context, index),
                style: const TextStyle(fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            _UserMenu(
              onOpenSettings: () => widget.shell.goBranch(5, initialLocation: false),
              onLogoutDone: () { if (context.mounted) context.go('/login'); },
            ),
          ],
        ),
      ),
      body: content,
      bottomNavigationBar: NavigationBar(
        selectedIndex: index.clamp(0, 4),
        onDestinationSelected: _onTap,
        destinations: mobileDestinations,
      ),
    );
  }
}


enum _UserMenuAction { settings, logout }

class _UserMenu extends StatelessWidget {
  final VoidCallback onOpenSettings;
  final VoidCallback onLogoutDone;
  const _UserMenu({required this.onOpenSettings, required this.onLogoutDone});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final auth = AuthScope.of(context);
    final display = auth.user;
    final initials = (display.isNotEmpty ? display.trim()[0].toUpperCase() : 'U');

    return PopupMenuButton<_UserMenuAction>(
      tooltip: t.menu_account,
      onSelected: (value) async {
        switch (value) {
          case _UserMenuAction.settings:
            onOpenSettings();
            break;
          case _UserMenuAction.logout:
            await auth.logout();
            onLogoutDone();
            break;
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(value: _UserMenuAction.settings, child: Text(t.menu_settings)),
        const PopupMenuDivider(),
        PopupMenuItem(value: _UserMenuAction.logout, child: Text(t.menu_logout)),
      ],
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(radius: 12, child: Text(initials)),
          const SizedBox(width: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 140),
            child: Text(display, overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  const _LogoutButton();

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final auth = AuthScope.of(context);

    return IconButton(
      tooltip: t.menu_logout,
      onPressed: () async {
        await auth.logout();
        if (context.mounted) context.go('/login');
      },
      icon: const Icon(Icons.logout, color: Colors.white),
    );
  }
}