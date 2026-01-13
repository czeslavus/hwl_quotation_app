import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
    required this.quotationId,
    required this.vm,
    required this.statusId,
    required this.orderNrSl,
  });

  bool get _isValidId => quotationId > 0;

  // wg Twoich ustaleń:
  bool get _isRejected => statusId == 4;
  bool get _isApproved => statusId == 3;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    Widget slot({required bool visible, required Widget child}) {
      return Visibility(
        visible: visible,
        maintainSize: true,
        maintainAnimation: true,
        maintainState: true,
        child: child,
      );
    }

    final canOpenOrder = _isApproved && (orderNrSl != null) && orderNrSl!.trim().isNotEmpty;

    return SizedBox(
      width: 260, // trochę szerzej, bo doszła ikona ciężarówki
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
                visible: !_isRejected && !_isApproved,
                child: PositiveActionButton(
                  label: t.action_submit,
                  icon: Icons.check_circle_outline,
                  showCaption: false,
                  onPressed: _isValidId
                      ? () async {
                    final q = await vm.approve(quotationId);
                    if (q == null) return;
                    if (!context.mounted) return;
                    context.go('/order/new', extra: q);
                  }
                      : null,
                ),
              ),
              _gap,
              // EDIT
              slot(
                visible: !_isRejected && !_isApproved,
                child: NeutralActionButton(
                  label: t.action_edit,
                  icon: Icons.edit_outlined,
                  showCaption: false,
                  onPressed: _isValidId && !_isRejected
                      ? () async {
                        final changed = await context.push('/quote/$quotationId');
                        if (changed == true) {
                          await vm.init();
                        }
                      } : null,
                ),
              ),
              _gap,
              // COPY (zawsze)
              SecondaryActionButton(
                label: t.action_copy,
                icon: Icons.copy_outlined,
                showCaption: false,
                onPressed: _isValidId ? () => vm.copy(quotationId) : null,
              ),
              _gap,
              // REJECT
              slot(
                visible: !_isRejected && !_isApproved,
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
                visible: _isApproved,
                child: NeutralActionButton(
                  label: t.action_open_order,
                  icon: Icons.local_shipping_outlined,
                  showCaption: false,
                  onPressed: canOpenOrder
                      ? () => context.go('/order/${orderNrSl!.trim()}')
                      : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

const _gap = SizedBox(width: 6);
