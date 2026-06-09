import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:baladiyati/common/widgets/app_search_field.dart';
import 'package:baladiyati/common/widgets/app_toast.dart';
import 'package:baladiyati/common/widgets/shimmer_loading.dart';
import 'package:baladiyati/features/citizen/services/domain/entities/service_entity.dart';
import 'package:baladiyati/features/citizen/services/presentation/bloc/services_bloc.dart';
import 'package:baladiyati/features/citizen/services/presentation/bloc/services_event.dart';
import 'package:baladiyati/features/citizen/services/presentation/bloc/services_state.dart';
import 'package:baladiyati/l10n/app_localizations.dart';
import 'service_details_screen.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  String? _lastShownError;

  @override
  void initState() {
    super.initState();
    final bloc = context.read<CitizenServicesBloc>();
    if (!bloc.state.isLoading && bloc.state.services.isEmpty) {
      bloc.add(CitizenServicesLoadRequested());
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<ServiceEntity> _filtered(List<ServiceEntity> all, String langCode) =>
      all.where((s) {
        final q = _query.trim().toLowerCase();
        if (q.isEmpty) return true;
        return s.localizedName(langCode).toLowerCase().contains(q) ||
            s.localizedDescription(langCode).toLowerCase().contains(q);
      }).toList();

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final langCode = Localizations.localeOf(context).languageCode;

    return BlocConsumer<CitizenServicesBloc, CitizenServicesState>(
      listener: (context, state) {
        if (state.errorMessage != null &&
            state.errorMessage != _lastShownError) {
          _lastShownError = state.errorMessage;
          AppToast.show(context,
              message: state.errorMessage!, type: AppToastType.error);
        }
      },
      builder: (context, state) {
        final items = _filtered(state.services, langCode);

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: SafeArea(
            child: Column(
              children: [
                Container(
                  color: colors.surface,
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loc.services,
                        style: theme.textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 12),
                      AppSearchField(
                        controller: _searchCtrl,
                        hint: loc.search,
                        onChanged: (v) => setState(() => _query = v),
                        onClear: _query.isEmpty
                            ? null
                            : () {
                                _searchCtrl.clear();
                                setState(() => _query = '');
                              },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: state.isLoading
                      ? const _ServicesSkeleton()
                      : items.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.list_alt_outlined,
                                      size: 64, color: colors.outline),
                                  const SizedBox(height: 12),
                                  Text(
                                    state.errorMessage != null
                                        ? loc.loadFailed
                                        : loc.noData,
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                        color: colors.outline),
                                  ),
                                  if (state.errorMessage != null) ...[
                                    const SizedBox(height: 12),
                                    TextButton(
                                      onPressed: () => context
                                          .read<CitizenServicesBloc>()
                                          .add(CitizenServicesRefreshRequested()),
                                      child: Text(loc.retry),
                                    ),
                                  ],
                                ],
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: () async => context
                                  .read<CitizenServicesBloc>()
                                  .add(CitizenServicesRefreshRequested()),
                              child: ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: items.length,
                                itemBuilder: (_, i) => _ServiceCard(
                                  service: items[i],
                                  langCode: langCode,
                                  theme: theme,
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ServiceDetailsScreen(
                                          service: items[i]),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Skeleton ──────────────────────────────────────────────────────────────────

class _ServicesSkeleton extends StatelessWidget {
  const _ServicesSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 7,
      itemBuilder: (_, __) => const _ServiceCardSkeleton(),
    );
  }
}

class _ServiceCardSkeleton extends StatelessWidget {
  const _ServiceCardSkeleton();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outline.withOpacity(0.12)),
      ),
      child: Row(
        children: [
          const ShimmerBox(width: 48, height: 48, radius: 12),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  const Expanded(flex: 7, child: ShimmerBox(height: 14)),
                  const Spacer(flex: 3),
                ]),
                const SizedBox(height: 7),
                const ShimmerBox(height: 12),
                const SizedBox(height: 4),
                Row(children: [
                  const Expanded(flex: 6, child: ShimmerBox(height: 12)),
                  const Spacer(flex: 4),
                ]),
              ],
            ),
          ),
          const SizedBox(width: 10),
          const ShimmerBox(width: 18, height: 18, radius: 4),
        ],
      ),
    );
  }
}

// ── Real card ──────────────────────────────────────────────────────────────────

class _ServiceCard extends StatelessWidget {
  final ServiceEntity service;
  final String langCode;
  final ThemeData theme;
  final VoidCallback onTap;

  const _ServiceCard({
    required this.service,
    required this.langCode,
    required this.theme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = theme.colorScheme;
    final loc = AppLocalizations.of(context)!;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.outline.withOpacity(0.12)),
          boxShadow: [
            BoxShadow(
                color: colors.shadow.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: colors.primary.withOpacity(0.10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.description_outlined,
                  color: colors.primary, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.localizedName(langCode),
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    service.localizedDescription(langCode),
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: colors.outline),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (service.hasFees && service.feeAmount != null) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.attach_money,
                            size: 14, color: colors.secondary),
                        const SizedBox(width: 2),
                        Text(
                          '${loc.feeLabel} ${service.feeAmount!.toStringAsFixed(0)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                              color: colors.secondary,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            Icon(Icons.chevron_right, size: 20, color: colors.outline),
          ],
        ),
      ),
    );
  }
}
