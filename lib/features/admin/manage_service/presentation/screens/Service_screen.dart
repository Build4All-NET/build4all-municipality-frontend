import 'package:baladiyati/common/widgets/app_search_field.dart';
import 'package:baladiyati/common/widgets/app_toast.dart';
import 'package:baladiyati/features/admin/manage_service/Data/model/service_Model.dart';
import 'package:baladiyati/features/admin/manage_service/presentation/bloc/Service_State.dart';
import 'package:baladiyati/features/admin/manage_service/presentation/bloc/Service_bloc.dart';
import 'package:baladiyati/features/admin/manage_service/presentation/bloc/Service_event.dart';
import 'package:baladiyati/features/admin/manage_service/presentation/screens/Add_Service.dart';
import 'package:baladiyati/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  final TextEditingController _searchController = TextEditingController();

  bool _waitingForDeleteResult = false;
  bool _waitingForAddOrEditResult = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openForm({ServiceModel? service}) async {
    _waitingForAddOrEditResult = true;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<ServiceBloc>(),
          child: AddServicePage(service: service),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(ServiceModel service) async {
    final loc = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;

    final serviceName = service.nameEn.trim().isNotEmpty
        ? service.nameEn.trim()
        : service.nameAr.trim();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(loc.confirmDelete),
          content: Text(loc.deleteServiceConfirm(serviceName)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(loc.cancel),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.error,
                foregroundColor: colors.onError,
              ),
              icon: const Icon(Icons.delete_outline),
              label: Text(loc.delete),
              onPressed: () => Navigator.pop(dialogContext, true),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    setState(() {
      _waitingForDeleteResult = true;
    });

    context.read<ServiceBloc>().add(DeleteServiceEvent(service.id));
  }

  Future<void> _refresh() async {
    context.read<ServiceBloc>().add(LoadServices());
  }

  void _clearSearch() {
    _searchController.clear();
    context.read<ServiceBloc>().add(SearchServices(''));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return BlocConsumer<ServiceBloc, ServiceState>(
      listener: (context, state) {
        final error = state.error;

        if (error != null && error.isNotEmpty) {
          _waitingForDeleteResult = false;
          _waitingForAddOrEditResult = false;

          AppToast.show(
            context,
            message: error,
            type: AppToastType.error,
          );

          return;
        }

        if (_waitingForDeleteResult && !state.actionLoading) {
          _waitingForDeleteResult = false;

          AppToast.show(
            context,
            message: loc.serviceDeleted,
            type: AppToastType.success,
          );
        }

        if (_waitingForAddOrEditResult && !state.actionLoading) {
          _waitingForAddOrEditResult = false;
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            title: Text(loc.services),
            actions: [
              IconButton(
                tooltip: loc.update,
                icon: const Icon(Icons.refresh),
                onPressed: state.loading || state.actionLoading
                    ? null
                    : () => context.read<ServiceBloc>().add(LoadServices()),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: state.loading || state.actionLoading
                ? null
                : () => _openForm(),
            icon: const Icon(Icons.add),
            label: Text(loc.add),
          ),
          body: RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
              children: [
                _HeaderCard(
                  title: loc.services,
                  subtitle: loc.manageServices,
                  count: state.allServices.length,
                ),

                const SizedBox(height: 16),

                AppSearchField(
                  controller: _searchController,
                  hint: loc.search,
                  onChanged: (value) {
                    context.read<ServiceBloc>().add(SearchServices(value));
                    setState(() {});
                  },
                  onClear: _searchController.text.trim().isEmpty
                      ? null
                      : _clearSearch,
                ),

                const SizedBox(height: 16),

                if (state.loading && state.allServices.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 120),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (state.visibleServices.isEmpty)
                  _EmptyState(
                    title: loc.noData,
                    subtitle: loc.noServicesHint,
                  )
                else
                  ...state.visibleServices.map(
                    (service) => _ServiceCard(
                      service: service,
                      isBusy: state.actionLoading,
                      onEdit: () => _openForm(service: service),
                      onDelete: () => _confirmDelete(service),
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

class _HeaderCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final int count;

  const _HeaderCard({
    required this.title,
    required this.subtitle,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.primary,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Container(
            height: 52,
            width: 52,
            decoration: BoxDecoration(
              color: colors.onPrimary.withOpacity(0.14),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.description_outlined,
              color: colors.onPrimary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: colors.onPrimary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onPrimary.withOpacity(0.78),
                  ),
                ),
              ],
            ),
          ),
          Text(
            '$count',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: colors.onPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final ServiceModel service;
  final bool isBusy;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ServiceCard({
    required this.service,
    required this.isBusy,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final title =
        service.nameEn.trim().isNotEmpty ? service.nameEn : service.nameAr;

    final subtitle = service.descriptionEn.trim().isNotEmpty
        ? service.descriptionEn
        : service.descriptionAr;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colors.outline.withOpacity(0.14),
        ),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withOpacity(0.045),
            blurRadius: 12,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 8,
        ),
        leading: CircleAvatar(
          backgroundColor: colors.primary.withOpacity(0.12),
          child: Icon(
            Icons.description_outlined,
            color: colors.primary,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            _StatusChip(active: service.isActive),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text(
            subtitle.trim().isNotEmpty
                ? subtitle
                : '${loc.department}: ${service.departmentId} • ${loc.price}: ${service.feeAmount.toStringAsFixed(2)}',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurface.withOpacity(0.68),
            ),
          ),
        ),
        trailing: PopupMenuButton<String>(
          enabled: !isBusy,
          onSelected: (value) {
            if (value == 'edit') {
              onEdit();
            }

            if (value == 'delete') {
              onDelete();
            }
          },
          itemBuilder: (_) => [
            PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  const Icon(Icons.edit_outlined),
                  const SizedBox(width: 8),
                  Text(loc.edit),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete_outline, color: colors.error),
                  const SizedBox(width: 8),
                  Text(
                    loc.delete,
                    style: TextStyle(color: colors.error),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final bool active;

  const _StatusChip({
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = Theme.of(context).colorScheme;

    final color = active ? colors.primary : colors.error;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        active ? loc.active : loc.inactive,
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String title;
  final String subtitle;

  const _EmptyState({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(top: 120),
      child: Column(
        children: [
          Icon(
            Icons.description_outlined,
            size: 58,
            color: colors.onSurface.withOpacity(0.35),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}