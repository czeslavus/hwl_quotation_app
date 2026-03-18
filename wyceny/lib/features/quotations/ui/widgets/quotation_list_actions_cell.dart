import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wyceny/app/di/locator.dart';
import 'package:wyceny/features/quotations/ui/viewmodels/quotations_list_viewmodel.dart';
import 'package:wyceny/features/quotations/ui/widgets/quotation_reject_dialog.dart';
import 'package:wyceny/l10n/app_localizations.dart';
import 'package:wyceny/ui/widgets/common/danger_action_button.dart';
import 'package:wyceny/ui/widgets/common/neutral_action_button.dart';
import 'package:wyceny/ui/widgets/common/positive_action_button.dart';
import 'package:wyceny/ui/widgets/common/secondary_action_button.dart';

class QuotationListActionsCell extends StatelessWidget {
  final int quotationId;
  final int? statusId;
  final String? orderNrSl;
  final QuotationsListViewModel vm;

  const QuotationListActionsCell({
    super.key,
    required this.quotationId,
    required this.vm,
    required this.statusId,
    required this.orderNrSl,
  });

  bool get _isValidId => quotationId > 0;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final isRejected = vm.isRejectedStatus(statusId);
    final isApproved = vm.isApprovedStatus(statusId, orderNrSl: orderNrSl);

    Widget slot({required bool visible, required Widget child}) {
      return Visibility(
        visible: visible,
        maintainSize: true,
        maintainAnimation: true,
        maintainState: true,
        child: child,
      );
    }

    return SizedBox(
      width: 300,
      child: Align(
        alignment: Alignment.centerRight,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerRight,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // APPROVE (ukryte po Rejected; możesz też ukryć po Approved, jeśli nie ma sensu)
              slot(
                visible: !isRejected && !isApproved,
                child: PositiveActionButton(
                  label: t.action_submit,
                  icon: Icons.check_circle_outline,
                  showCaption: false,
                  onPressed: _isValidId
                      ? () async {
                          final order = await vm.approveAndBuildOrder(
                            quotationId,
                          );
                          if (order == null) return;
                          getIt<GoRouter>().go('/order/new', extra: order);
                        }
                      : null,
                ),
              ),
              _gap,
              // EDIT
              slot(
                visible: !isRejected && !isApproved,
                child: NeutralActionButton(
                  label: t.action_edit,
                  icon: Icons.edit_outlined,
                  showCaption: false,
                  onPressed: _isValidId && !isRejected
                      ? () async {
                          final changed = await context.push(
                            '/quote/$quotationId',
                          );
                          if (changed == true) {
                            await vm.init();
                          }
                        }
                      : null,
                ),
              ),
              _gap,
              // COPY (zawsze)
              SecondaryActionButton(
                label: t.action_copy,
                icon: Icons.copy_outlined,
                showCaption: false,
                onPressed: _isValidId
                    ? () async {
                        final missingIdMessage = _copyMissingIdMessage(context);
                        final messenger = ScaffoldMessenger.maybeOf(context);
                        final confirmed = await _confirmCopy(context);
                        if (confirmed != true || !context.mounted) return;

                        final copied = await vm.copy(quotationId);
                        if (copied == null) return;

                        final copiedId = copied.quotationId;
                        if (copiedId == null || copiedId <= 0) {
                          messenger?.showSnackBar(
                            SnackBar(content: Text(missingIdMessage)),
                          );
                          return;
                        }

                        getIt<GoRouter>().go('/quote/$copiedId');
                      }
                    : null,
              ),
              _gap,
              slot(
                visible: isRejected,
                child: DangerActionButton(
                  label: _deleteActionLabel(context),
                  tooltip: _deleteActionLabel(context),
                  icon: Icons.delete_outline,
                  showCaption: false,
                  onPressed: _isValidId
                      ? () async {
                          final confirmed = await _confirmDelete(context);
                          if (confirmed != true || !context.mounted) return;
                          await vm.delete(quotationId);
                        }
                      : null,
                ),
              ),
              _gap,
              // REJECT
              slot(
                visible: !isRejected && !isApproved,
                child: DangerActionButton(
                  label: t.action_reject,
                  icon: Icons.cancel_outlined,
                  showCaption: false,
                  onPressed: _isValidId
                      ? () async {
                          final res = await showRejectDialog(
                            context: context,
                            quotationId: quotationId,
                          );
                          if (res == null) return;

                          await vm.reject(
                            quotationId,
                            rejectCauseId: res.rejectCauseId,
                            rejectCause: res.rejectCauseNote,
                          );
                        }
                      : null,
                ),
              ),
              _gap,
              // ✅ OPEN ORDER (tylko Approved)
              slot(
                visible: isApproved,
                child: NeutralActionButton(
                  label: t.action_open_order,
                  icon: Icons.local_shipping_outlined,
                  showCaption: false,
                  onPressed: _isValidId
                      ? () async {
                          final order = await vm.buildOrderDraft(quotationId);
                          if (order == null) return;
                          getIt<GoRouter>().go('/order/new', extra: order);
                        }
                      : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool?> _confirmCopy(BuildContext context) {
    final t = AppLocalizations.of(context);
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(_copyDialogTitle(context)),
        content: Text(_copyDialogMessage(context)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(t.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(t.action_copy),
          ),
        ],
      ),
    );
  }

  Future<bool?> _confirmDelete(BuildContext context) {
    final t = AppLocalizations.of(context);
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(_deleteDialogTitle(context)),
        content: Text(_deleteDialogMessage(context)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(t.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(_deleteActionLabel(context)),
          ),
        ],
      ),
    );
  }

  String _copyDialogTitle(BuildContext context) {
    final isPl = Localizations.localeOf(context).languageCode == 'pl';
    return isPl ? 'Skopiować wycenę?' : 'Copy quotation?';
  }

  String _copyDialogMessage(BuildContext context) {
    final isPl = Localizations.localeOf(context).languageCode == 'pl';
    return isPl
        ? 'System utworzy kopię tej wyceny i otworzy ją w ekranie edycji.'
        : 'The system will create a copy of this quotation and open it in the edit screen.';
  }

  String _copyMissingIdMessage(BuildContext context) {
    final isPl = Localizations.localeOf(context).languageCode == 'pl';
    return isPl
        ? 'Kopia została utworzona, ale API nie zwróciło identyfikatora nowej wyceny.'
        : 'The copy was created, but the API did not return the new quotation ID.';
  }

  String _deleteActionLabel(BuildContext context) {
    final isPl = Localizations.localeOf(context).languageCode == 'pl';
    return isPl ? 'Usuń' : 'Delete';
  }

  String _deleteDialogTitle(BuildContext context) {
    final isPl = Localizations.localeOf(context).languageCode == 'pl';
    return isPl ? 'Usunąć wycenę?' : 'Delete quotation?';
  }

  String _deleteDialogMessage(BuildContext context) {
    final isPl = Localizations.localeOf(context).languageCode == 'pl';
    return isPl
        ? 'Ta operacja trwale usunie wycenę z listy.'
        : 'This operation will permanently remove the quotation from the list.';
  }
}

const _gap = SizedBox(width: 6);
