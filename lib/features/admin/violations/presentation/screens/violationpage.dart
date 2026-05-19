import 'package:baladiyati/core/network/dio_client.dart';
import 'package:baladiyati/features/admin/violations/data/Repository/violation_Repository_impl.dart';
import 'package:baladiyati/features/admin/violations/data/services/violation_api_services.dart';
import 'package:baladiyati/features/admin/violations/domain/Usecase/AddViolation.dart';
import 'package:baladiyati/features/admin/violations/domain/Usecase/DeleteViolation.dart';
import 'package:baladiyati/features/admin/violations/domain/Usecase/Getviolation.dart';
import 'package:baladiyati/features/admin/violations/domain/Usecase/UpdateViolation.dart';
import 'package:baladiyati/features/admin/violations/domain/entities/violation.dart';
import 'package:baladiyati/features/admin/violations/presentation/bloc/violation_bloc.dart';
import 'package:baladiyati/features/admin/violations/presentation/bloc/violation_event.dart';
import 'package:baladiyati/features/admin/violations/presentation/bloc/violation_state.dart';
import 'package:baladiyati/features/admin/violations/presentation/screens/AddViolationPage.dart';
import 'package:baladiyati/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ViolationsPage extends StatelessWidget {
  const ViolationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = ViolationRepositoryImpl(
      ViolationApiService(dio: DioClient.muni),
    );

    return BlocProvider(
      create: (_) => ViolationBloc(
        addViolation: AddViolation(repo),
        getViolations: GetViolations(repo),
        updateViolation: UpdateViolation(repo),
        deleteViolation: DeleteViolation(repo),
      )..add(LoadViolationsEvent()),
      child: const ViolationsBody(),
    );
  }
}

class ViolationsBody extends StatefulWidget {
  const ViolationsBody({super.key});

  @override
  State<ViolationsBody> createState() => _ViolationsBodyState();
}

class _ViolationsBodyState extends State<ViolationsBody> {
  final TextEditingController _searchController = TextEditingController();

  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Violation> _filter(List<Violation> list) {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return list;
    return list.where((v) {
      return v.title.toLowerCase().contains(q) ||
          v.description.toLowerCase().contains(q) ||
          v.citizenName.toLowerCase().contains(q) ||
          v.location.toLowerCase().contains(q) ||
          (v.departmentName ?? '').toLowerCase().contains(q) ||
          (v.municipalityName ?? '').toLowerCase().contains(q) ||
          (v.identityNumber ?? '').toLowerCase().contains(q) ||
          (v.carPlate ?? '').toLowerCase().contains(q);
    }).toList();
  }

  void _reload() {
    context.read<ViolationBloc>().add(LoadViolationsEvent());
  }

  Future<void> _openCreateScreen() async {
    final bloc = context.read<ViolationBloc>();
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: bloc,
          child: const CreateViolationScreen(),
        ),
      ),
    );
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(loc.violations),
        actions: [
          IconButton(
            tooltip: loc.update,
            icon: const Icon(Icons.refresh),
            onPressed: _reload,
          ),
          IconButton(
            tooltip: loc.addViolation,
            icon: const Icon(Icons.add),
            onPressed: _openCreateScreen,
          ),
        ],
      ),
      body: BlocConsumer<ViolationBloc, ViolationState>(
        listener: (context, state) {
          if (state is ViolationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: colors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ViolationLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ViolationError) {
            return _ErrorState(message: state.message, onRetry: _reload);
          }
          if (state is ViolationLoaded) {
            final filtered = _filter(state.violations);
            return RefreshIndicator(
              onRefresh: () async => _reload(),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                children: [
                  _SearchField(
                    controller: _searchController,
                    hint: loc.search,
                    onChanged: (value) => setState(() { _query = value; }),
                  ),
                  const SizedBox(height: 14),
                  _SummaryStrip(total: state.violations.length, shown: filtered.length),
                  const SizedBox(height: 14),
                  if (filtered.isEmpty)
                    _EmptyState(title: loc.noData, subtitle: loc.violations)
                  else
                    ...filtered.map(
                      (violation) => _ViolationCard(
                        violation: violation,
                        onUpdated: _reload,
                      ),
                    ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;

  const _SearchField({required this.controller, required this.hint, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return TextField(
      controller: controller,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: colors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: colors.outline.withOpacity(0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: colors.outline.withOpacity(0.2)),
        ),
      ),
      style: theme.textTheme.bodyMedium,
    );
  }
}

class _SummaryStrip extends StatelessWidget {
  final int total;
  final int shown;

  const _SummaryStrip({required this.total, required this.shown});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.primary.withOpacity(0.18)),
      ),
      child: Row(
        children: [
          Icon(Icons.gavel_outlined, color: colors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              loc.violations,
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
          Text(
            '$shown / $total',
            style: theme.textTheme.titleSmall?.copyWith(
              color: colors.primary,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _ViolationCard extends StatelessWidget {
  final Violation violation;
  final VoidCallback onUpdated;

  const _ViolationCard({required this.violation, required this.onUpdated});

  Future<void> _openEditScreen(BuildContext context) async {
    final bloc = context.read<ViolationBloc>();
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: bloc,
          child: CreateViolationScreen(violation: violation),
        ),
      ),
    );
    onUpdated();
  }

  void _confirmDelete(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    if (violation.id == null) return;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(loc.confirmDelete),
        content: Text('${loc.delete} ${violation.title}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(loc.cancel),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.error,
              foregroundColor: colors.onError,
            ),
            icon: const Icon(Icons.delete_outline),
            label: Text(loc.delete),
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<ViolationBloc>().add(DeleteViolationEvent(violation.id!));
            },
          ),
        ],
      ),
    );
  }

  String _departmentText() {
    if ((violation.departmentName ?? '').trim().isNotEmpty) return violation.departmentName!;
    return '${violation.departmentId}';
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.outline.withOpacity(0.14)),
        boxShadow: [
          BoxShadow(color: colors.shadow.withOpacity(0.05), blurRadius: 14, offset: const Offset(0, 7)),
        ],
      ),
      child: Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          leading: CircleAvatar(
            backgroundColor: colors.primary.withOpacity(0.12),
            child: Icon(Icons.gavel_outlined, color: colors.primary),
          ),
          title: Text(
            violation.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '${violation.amount.toStringAsFixed(2)} \$ • ${violation.citizenName}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall,
            ),
          ),
          children: [
            const SizedBox(height: 6),
            _InfoRow(label: loc.description, value: violation.description),
            _InfoRow(label: loc.location, value: violation.location),
            _InfoRow(label: loc.date, value: violation.violationDate),
            _InfoRow(label: loc.department, value: _departmentText()),
            _InfoRow(label: loc.citizenName, value: violation.citizenName),
            _InfoRow(label: loc.amount, value: '${violation.amount.toStringAsFixed(2)} \$'),
            if ((violation.identityNumber ?? '').isNotEmpty)
              _InfoRow(label: 'Identity No.', value: violation.identityNumber!),
            if ((violation.carPlate ?? '').isNotEmpty)
              _InfoRow(label: 'Car Plate', value: violation.carPlate!),
            if ((violation.type ?? '').isNotEmpty)
              _InfoRow(label: 'Type', value: violation.type!),
            if ((violation.municipalityName ?? '').trim().isNotEmpty)
              _InfoRow(label: 'Municipality', value: violation.municipalityName!),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.edit_outlined),
                    label: Text(loc.edit),
                    onPressed: () => _openEditScreen(context),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: Icon(Icons.delete_outline, color: colors.error),
                    label: Text(loc.delete, style: TextStyle(color: colors.error)),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: colors.error.withOpacity(0.35)),
                    ),
                    onPressed: violation.id == null ? null : () => _confirmDelete(context),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 105,
            child: Text(
              '$label:',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: colors.onSurface,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.trim().isEmpty ? '-' : value,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurface.withOpacity(0.78),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String title;
  final String subtitle;

  const _EmptyState({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 90),
      child: Column(
        children: [
          Icon(Icons.inbox_outlined, size: 56, color: colors.onSurface.withOpacity(0.35)),
          const SizedBox(height: 12),
          Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(subtitle, style: theme.textTheme.bodyMedium?.copyWith(color: colors.onSurface.withOpacity(0.6))),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 54, color: colors.error),
            const SizedBox(height: 12),
            Text(
              loc.networkError,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(color: colors.onSurface.withOpacity(0.68)),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(loc.update),
            ),
          ],
        ),
      ),
    );
  }
}
