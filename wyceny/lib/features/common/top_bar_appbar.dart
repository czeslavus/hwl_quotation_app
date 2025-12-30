import 'package:flutter/material.dart';
import 'package:wyceny/app/auth.dart';
import 'package:wyceny/l10n/app_localizations.dart';

class TopBarAppBar extends StatelessWidget implements PreferredSizeWidget {
  final AuthState authState;

  const TopBarAppBar({
    super.key,
    required this.authState,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return AppBar(
      title: Row(
        children: [
          Expanded(
            child: Text(
              t.topbar_customer(authState.forename+' '+authState.surname, authState.contractorName, authState.skyLogicNumber),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
