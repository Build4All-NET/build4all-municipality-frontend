import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:baladiyati/common/widgets/primary_button.dart';
import 'package:baladiyati/features/citizen/services/data/services/ai_service.dart';
import 'package:baladiyati/features/citizen/services/domain/entities/service_entity.dart';
import 'package:baladiyati/features/citizen/services/presentation/cubit/ai_service_cubit.dart';
import 'package:baladiyati/features/citizen/services/presentation/cubit/ai_service_state.dart';
import 'package:baladiyati/l10n/app_localizations.dart';
import 'new_request_screen.dart';

class ServiceDetailsScreen extends StatelessWidget {
  final ServiceEntity service;
  const ServiceDetailsScreen({super.key, required this.service});

  void _showAiHelp(
    BuildContext context,
    ServiceEntity service,
    AppLocalizations loc,
    ColorScheme colors,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => BlocProvider(
        create: (_) => AiServiceCubit(AiService())..explain(service.id),
        child: _AiHelpSheet(loc: loc, colors: colors, serviceId: service.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final langCode = Localizations.localeOf(context).languageCode;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(title: Text(loc.serviceDetails)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon + name card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colors.outline.withOpacity(0.12)),
              ),
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: colors.primary.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(Icons.description_outlined,
                        color: colors.primary, size: 32),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    service.localizedName(langCode),
                    style: theme.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.w800),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    service.localizedDescription(langCode),
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: colors.outline),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Details card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colors.outline.withOpacity(0.12)),
              ),
              child: Column(
                children: [
                  if (service.slaDays != null)
                    _InfoRow(
                      icon: Icons.schedule_outlined,
                      label: loc.slaDays,
                      value: '${service.slaDays} ${loc.days}',
                      theme: theme,
                      colors: colors,
                    ),
                  if (service.hasFees && service.feeAmount != null) ...[
                    if (service.slaDays != null) const Divider(height: 20),
                    _InfoRow(
                      icon: Icons.attach_money,
                      label: loc.feeLabel,
                      value: service.feeAmount!.toStringAsFixed(0),
                      theme: theme,
                      colors: colors,
                    ),
                  ],
                  if (service.requiresInspection) ...[
                    const Divider(height: 20),
                    _InfoRow(
                      icon: Icons.search_outlined,
                      label: loc.requiresInspection,
                      value: loc.active,
                      theme: theme,
                      colors: colors,
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 28),

            PrimaryButton(
              label: loc.startRequest,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => NewRequestScreen(service: service),
                ),
              ),
            ),

            const SizedBox(height: 12),

            OutlinedButton.icon(
              onPressed: () => _showAiHelp(context, service, loc, colors),
              icon: const Icon(Icons.auto_awesome_outlined),
              label: Text(loc.aiHelp),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                foregroundColor: colors.primary,
                side: BorderSide(color: colors.primary.withOpacity(0.5)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _AiHelpSheet extends StatelessWidget {
  final AppLocalizations loc;
  final ColorScheme colors;
  final int serviceId;

  const _AiHelpSheet({
    required this.loc,
    required this.colors,
    required this.serviceId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.55,
      minChildSize: 0.35,
      maxChildSize: 0.9,
      builder: (_, controller) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_awesome_outlined, color: colors.primary),
                const SizedBox(width: 10),
                Text(
                  loc.aiExplanation,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: BlocBuilder<AiServiceCubit, AiServiceState>(
                builder: (context, state) {
                  if (state.status == AiServiceStatus.loading ||
                      state.status == AiServiceStatus.initial) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: colors.primary),
                          const SizedBox(height: 16),
                          Text(
                            loc.aiHelpLoading,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colors.outline,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state.status == AiServiceStatus.error) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, color: colors.error, size: 48),
                          const SizedBox(height: 12),
                          Text(
                            loc.aiHelpError,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colors.error,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          OutlinedButton.icon(
                            onPressed: () =>
                                context.read<AiServiceCubit>().explain(serviceId),
                            icon: const Icon(Icons.refresh),
                            label: Text(loc.retry),
                          ),
                        ],
                      ),
                    );
                  }

                  return SingleChildScrollView(
                    controller: controller,
                    child: Text(
                      state.reply ?? '',
                      style: theme.textTheme.bodyLarge?.copyWith(height: 1.6),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final ThemeData theme;
  final ColorScheme colors;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.theme,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: colors.primary),
        const SizedBox(width: 12),
        Text(label,
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: colors.outline)),
        const Spacer(),
        Text(value,
            style: theme.textTheme.bodyMedium
                ?.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }
}
