import 'package:flutter/material.dart';
import 'package:wyceny/l10n/app_localizations.dart';

class TopBarAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String customerName;
  final String contractorName;
  final VoidCallback? onLogout;

  const TopBarAppBar({
    super.key,
    required this.customerName,
    required this.contractorName,
    this.onLogout,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return AppBar(
      title: Row(
        children: [
          Expanded(
            child: Text(
              t.topbar_customer(customerName, contractorName),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          FilledButton.tonalIcon(
            onPressed: onLogout,
            icon: const Icon(Icons.logout),
            label: Text(t.topbar_logout),
          ),
        ],
      ),
    );
  }
}
