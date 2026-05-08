// lib/features/citizen/requests/presentation/screens/requests_screen.dart

import 'package:baladiyati/common/widgets/app_text_field.dart';
import 'package:baladiyati/common/widgets/app_toast.dart';
import 'package:baladiyati/common/widgets/primary_button.dart';
import 'package:baladiyati/core/config/app_sizes.dart';
import 'package:baladiyati/features/citizen/requests/data/models/request_model.dart';
import 'package:baladiyati/features/citizen/requests/presentation/bloc/requests_bloc.dart';
import 'package:baladiyati/features/citizen/requests/presentation/bloc/requests_event.dart';
import 'package:baladiyati/features/citizen/requests/presentation/bloc/requests_state.dart';
import 'package:baladiyati/features/citizen/requests/presentation/screens/request_details_screen.dart';
import 'package:baladiyati/features/citizen/requests/presentation/widgets/request_status_badge.dart';
import 'package:baladiyati/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RequestsScreen extends StatelessWidget {
  const RequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RequestsBloc()
        ..add(
          const RequestsLoadRequested(),
        ),
      child: const _RequestsScreenView(),
    );
  }
}

class _RequestsScreenView extends StatefulWidget {
  const _RequestsScreenView();

  @override
  State<_RequestsScreenView> createState() => _RequestsScreenViewState();
}

class _RequestsScreenViewState extends State<_RequestsScreenView> {
  final TextEditingController _searchController = TextEditingController();

  String _query = '';
  CitizenRequestStatus? _filterStatus;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<RequestModel> _filteredRequests(List<RequestModel> requests) {
    final query = _query.trim().toLowerCase();

    return requests.where((request) {
      final status = requestStatusFromString(request.status);

      final matchesStatus = _filterStatus == null || status == _filterStatus;

      final matchesSearch = query.isEmpty ||
          request.displayTitle.toLowerCase().contains(query) ||
          request.displayNumber.toLowerCase().contains(query) ||
          request.description.toLowerCase().contains(query);

      return matchesStatus && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: cs.background,
      body: SafeArea(
        child: BlocConsumer<RequestsBloc, RequestsState>(
          listener: (context, state) {
            if (state.status == RequestsStatus.failure &&
                state.errorMessage != null) {
              AppToast.show(
                context,
                message: state.errorMessage!,
                type: AppToastType.error,
              );
            }
          },
          builder: (context, state) {
            final filteredRequests = _filteredRequests(state.requests);

            return Column(
              children: [
                Container(
                  width: double.infinity,
                  color: cs.surface,
                  padding: const EdgeInsets.all(AppSizes.paddingMedium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        l10n.myRequests,
                        textAlign: TextAlign.right,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: cs.onSurface,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: AppSizes.paddingMedium),
                      AppTextField(
                        controller: _searchController,
                        label: l10n.searchRequest,
                        hint: l10n.searchRequest,
                        icon: Icons.search,
                        textAlign: TextAlign.right,
                        onChanged: (value) {
                          setState(() => _query = value);
                        },
                      ),
                      const SizedBox(height: AppSizes.paddingMedium),
                      _StatusFilter(
                        value: _filterStatus,
                        onChanged: (value) {
                          setState(() => _filterStatus = value);
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _buildBody(
                    context,
                    state,
                    filteredRequests,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    RequestsState state,
    List<RequestModel> requests,
  ) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    if (state.status == RequestsStatus.loading) {
      return Center(
        child: CircularProgressIndicator(
          color: cs.primary,
        ),
      );
    }

    if (state.status == RequestsStatus.failure) {
      return Padding(
        padding: const EdgeInsets.all(AppSizes.paddingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: cs.error,
              size: AppSizes.iconLarge * 0.70,
            ),
            const SizedBox(height: AppSizes.paddingMedium),
            Text(
              state.errorMessage ?? l10n.errorGeneric,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: AppSizes.paddingMedium),
            PrimaryButton(
              label: l10n.retry,
              onPressed: () {
                context.read<RequestsBloc>().add(
                      const RequestsLoadRequested(),
                    );
              },
            ),
          ],
        ),
      );
    }

    if (requests.isEmpty) {
      return RefreshIndicator(
        color: cs.primary,
        onRefresh: () async {
          context.read<RequestsBloc>().add(
                const RequestsRefreshRequested(),
              );
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppSizes.paddingLarge),
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.16),
            Icon(
              Icons.description_outlined,
              size: AppSizes.iconLarge,
              color: cs.onSurfaceVariant,
            ),
            const SizedBox(height: AppSizes.paddingMedium),
            Text(
              l10n.noRequests,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: cs.primary,
      onRefresh: () async {
        context.read<RequestsBloc>().add(
              const RequestsRefreshRequested(),
            );
      },
      child: ListView.separated(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        itemCount: requests.length,
        separatorBuilder: (_, __) {
          return const SizedBox(height: AppSizes.paddingSmall);
        },
        itemBuilder: (context, index) {
          final request = requests[index];

          return _RequestCard(
            request: request,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => RequestDetailsScreen(
                    request: request,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _StatusFilter extends StatelessWidget {
  final CitizenRequestStatus? value;
  final ValueChanged<CitizenRequestStatus?> onChanged;

  const _StatusFilter({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingSmall,
      ),
      decoration: BoxDecoration(
        color: cs.surfaceVariant.withOpacity(0.25),
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        border: Border.all(
          color: cs.outline.withOpacity(0.10),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.filter_list,
            color: cs.onSurfaceVariant,
            size: AppSizes.iconSmall,
          ),
          const SizedBox(width: AppSizes.paddingSmall),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<CitizenRequestStatus?>(
                value: value,
                isExpanded: true,
                dropdownColor: cs.surface,
                iconEnabledColor: cs.onSurfaceVariant,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: cs.onSurface,
                ),
                items: [
                  DropdownMenuItem<CitizenRequestStatus?>(
                    value: null,
                    child: Text(l10n.filterAll),
                  ),
                  ...CitizenRequestStatus.values.map(
                    (status) {
                      return DropdownMenuItem<CitizenRequestStatus?>(
                        value: status,
                        child: Text(
                          requestStatusLabel(l10n, status),
                        ),
                      );
                    },
                  ),
                ],
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final RequestModel request;
  final VoidCallback onTap;

  const _RequestCard({
    required this.request,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Card(
      elevation: 0,
      color: cs.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        side: BorderSide(
          color: cs.outline.withOpacity(0.10),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RequestStatusBadge(status: request.status),
                  const SizedBox(width: AppSizes.paddingSmall),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          request.displayNumber,
                          textAlign: TextAlign.right,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: AppSizes.paddingSmall / 2),
                        Text(
                          request.displayTitle,
                          textAlign: TextAlign.right,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: cs.onSurface,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (request.description.trim().isNotEmpty) ...[
                const SizedBox(height: AppSizes.paddingSmall),
                Text(
                  request.description,
                  textAlign: TextAlign.right,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
              const SizedBox(height: AppSizes.paddingSmall),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    request.date.isEmpty ? l10n.notAvailable : request.date,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: AppSizes.paddingSmall / 2),
                  Icon(
                    Icons.calendar_today_outlined,
                    color: cs.onSurfaceVariant,
                    size: AppSizes.iconSmall,
                  ),
                  const SizedBox(width: AppSizes.paddingMedium),
                  Text(
                    l10n.submissionDate,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}