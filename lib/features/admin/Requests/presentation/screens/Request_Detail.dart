import 'package:baladiyati/common/widgets/app_toast.dart';
import 'package:baladiyati/common/widgets/primary_button.dart';
import 'package:baladiyati/features/admin/Requests/data/model/RequestModel.dart';
import 'package:baladiyati/features/admin/Requests/presentation/bloc/Req_Bloc.dart';
import 'package:baladiyati/features/admin/Requests/presentation/bloc/Req_Event.dart';
import 'package:baladiyati/features/admin/Requests/presentation/bloc/Req_State.dart';
import 'package:baladiyati/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RequestDetailPage extends StatefulWidget {
  final RequestModel request;

  const RequestDetailPage({
    super.key,
    required this.request,
  });

  @override
  State<RequestDetailPage> createState() => _RequestDetailPageState();
}

class _RequestDetailPageState extends State<RequestDetailPage> {
  bool _awaitingUpdate = false;

  String _safe(String? value) {
    final clean = value?.trim() ?? '';
    return clean.isEmpty || clean == 'null' ? '---' : clean;
  }

  String _formatDate(String? value) {
    final clean = value?.trim() ?? '';
    if (clean.isEmpty || clean == 'null') return '---';
    return clean.replaceFirst('T', ' ').split('.').first;
  }

  String _formatStatus(String? status) {
    final clean = _safe(status);
    if (clean == '---') return clean;
    return clean.replaceAll('_', ' ');
  }

  void _changeStatus(BuildContext context, String status) {
    final id = widget.request.id;
    if (id == null) return;
    setState(() => _awaitingUpdate = true);
    context.read<RequestBloc>().add(
          UpdateRequestStatusRequested(id: id, status: status),
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;

    return BlocConsumer<RequestBloc, RequestState>(
      listener: (context, state) {
        if (!_awaitingUpdate) return;
        if (state.updating) return;

        if (state.success.isNotEmpty) {
          setState(() => _awaitingUpdate = false);
          if (mounted) Navigator.pop(context);
          return;
        }

        if (state.error.isNotEmpty) {
          setState(() => _awaitingUpdate = false);
          AppToast.show(
            context,
            message: state.error,
            type: AppToastType.error,
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: _ResponsiveText(
              text: l10n.requestDetails,
              maxFontSize: 20,
              minFontSize: 12,
              fontWeight: FontWeight.w900,
              color: colors.onSurface,
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _SectionCard(
                  child: Column(
                    children: [
                      _DetailRow(
                        label: 'Title',
                        value: _safe(widget.request.title),
                      ),
                      _DetailRow(
                        label: 'Tracking',
                        value: _safe(widget.request.trackingNumber),
                      ),
                      _DetailRow(
                        label: l10n.status,
                        value: _formatStatus(widget.request.status),
                      ),
                      _DetailRow(
                        label: 'Service',
                        value: _safe(widget.request.serviceName),
                      ),
                      _DetailRow(
                        label: 'Citizen',
                        value: _safe(widget.request.citizenName),
                      ),
                      _DetailRow(
                        label: l10n.address,
                        value: _safe(widget.request.addressText),
                      ),
                      _DetailRow(
                        label: 'Created',
                        value: _formatDate(widget.request.createdAt),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                _SectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _ResponsiveText(
                        text: 'Description',
                        maxFontSize: 15,
                        minFontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: colors.onSurface,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _safe(widget.request.description),
                        style: TextStyle(
                          color: colors.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: PrimaryButton(
                        label: state.updating ? '...' : l10n.reject,
                        backgroundColor: colors.error,
                        textColor: colors.onPrimary,
                        isLoading: state.updating,
                        onPressed: () {
                          if (state.updating) return;
                          _changeStatus(context, 'REJECTED');
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: PrimaryButton(
                        label: state.updating ? '...' : l10n.approve,
                        backgroundColor: colors.primary,
                        textColor: colors.onPrimary,
                        isLoading: state.updating,
                        onPressed: () {
                          if (state.updating) return;
                          _changeStatus(context, 'APPROVED');
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                PrimaryButton(
                  label: 'Mark in progress',
                  backgroundColor: colors.tertiary,
                  textColor: colors.onPrimary,
                  isLoading: state.updating,
                  onPressed: () {
                    if (state.updating) return;
                    _changeStatus(context, 'IN_PROGRESS');
                  },
                ),
                const SizedBox(height: 10),
                PrimaryButton(
                  label: 'Complete',
                  backgroundColor: colors.primary,
                  textColor: colors.onPrimary,
                  isLoading: state.updating,
                  onPressed: () {
                    if (state.updating) return;
                    _changeStatus(context, 'COMPLETED');
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SectionCard extends StatelessWidget {
  final Widget child;

  const _SectionCard({
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colors.outlineVariant.withOpacity(0.55),
        ),
      ),
      child: child,
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 96,
            child: _ResponsiveText(
              text: label,
              maxFontSize: 13,
              minFontSize: 8,
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _ResponsiveText(
              text: value,
              maxFontSize: 14,
              minFontSize: 8,
              color: colors.onSurface,
              fontWeight: FontWeight.w800,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

class _ResponsiveText extends StatelessWidget {
  final String text;
  final TextAlign textAlign;
  final double minFontSize;
  final double maxFontSize;
  final FontWeight fontWeight;
  final Color color;

  const _ResponsiveText({
    required this.text,
    this.textAlign = TextAlign.start,
    this.minFontSize = 9,
    this.maxFontSize = 14,
    this.fontWeight = FontWeight.normal,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final cleanText = text.trim().isEmpty ? '---' : text.trim();

    double fontSize = maxFontSize;
    final length = cleanText.runes.length;

    if (length > 45) {
      fontSize = maxFontSize - 6;
    } else if (length > 38) {
      fontSize = maxFontSize - 5;
    } else if (length > 31) {
      fontSize = maxFontSize - 4;
    } else if (length > 24) {
      fontSize = maxFontSize - 3;
    } else if (length > 17) {
      fontSize = maxFontSize - 2;
    } else if (length > 11) {
      fontSize = maxFontSize - 1;
    }

    if (fontSize < minFontSize) {
      fontSize = minFontSize;
    }

    Alignment alignment;

    if (textAlign == TextAlign.end || textAlign == TextAlign.right) {
      alignment = Alignment.centerRight;
    } else if (textAlign == TextAlign.center) {
      alignment = Alignment.center;
    } else {
      alignment = Alignment.centerLeft;
    }

    return SizedBox(
      width: double.infinity,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: alignment,
        child: Text(
          cleanText,
          maxLines: 1,
          softWrap: false,
          textAlign: textAlign,
          style: TextStyle(
            color: color,
            fontSize: fontSize,
            fontWeight: fontWeight,
            height: 1.15,
          ),
        ),
      ),
    );
  }
}
