import 'package:baladiyati/common/widgets/app_toast.dart';
import 'package:baladiyati/features/admin/Departement/presentation/bloc/Departement_State.dart';
import 'package:baladiyati/features/admin/Departement/presentation/cubit/Departement_cubit.dart';
import 'package:baladiyati/features/admin/Requests/data/model/RequestModel.dart';
import 'package:baladiyati/features/admin/Requests/presentation/bloc/Req_Bloc.dart';
import 'package:baladiyati/features/admin/Requests/presentation/bloc/Req_Event.dart';
import 'package:baladiyati/features/admin/Requests/presentation/bloc/Req_State.dart';
import 'package:baladiyati/features/admin/Requests/presentation/screens/Request_Detail.dart';
import 'package:baladiyati/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RequestsScreen extends StatefulWidget {
  const RequestsScreen({super.key});

  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> {
  static const List<String> _statuses = [
    'SUBMITTED',
    'UNDER_REVIEW',
    'DOCUMENTS_MISSING',
    'IN_PROGRESS',
    'APPROVED',
    'REJECTED',
    'COMPLETED',
    'CANCELLED',
  ];

  @override
  void initState() {
    super.initState();

    context.read<RequestBloc>().add(LoadRequests());
    context.read<DepartmentCubit>().fetchDepartments();
  }

  String _safe(String? value) {
    final clean = value?.trim() ?? '';
    return clean.isEmpty || clean == 'null' ? '---' : clean;
  }

  String _formatStatus(String? status) {
    final clean = _safe(status);
    if (clean == '---') return clean;

    return clean.replaceAll('_', ' ');
  }

  String _formatDate(String? value) {
    final clean = value?.trim() ?? '';
    if (clean.isEmpty || clean == 'null') return '---';

    return clean.replaceFirst('T', ' ').split('.').first;
  }

  Color _statusColor(BuildContext context, String status) {
    final colors = Theme.of(context).colorScheme;

    switch (status) {
      case 'APPROVED':
      case 'COMPLETED':
        return colors.primary;
      case 'REJECTED':
      case 'CANCELLED':
        return colors.error;
      case 'IN_PROGRESS':
      case 'UNDER_REVIEW':
        return colors.tertiary;
      default:
        return colors.secondary;
    }
  }

  Future<void> _openDetails(RequestModel request) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<RequestBloc>(),
          child: RequestDetailPage(request: request),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: _ResponsiveText(
          text: l10n.requests,
          maxFontSize: 20,
          minFontSize: 12,
          fontWeight: FontWeight.w900,
          color: colors.onSurface,
        ),
        centerTitle: true,
      ),
      body: BlocConsumer<RequestBloc, RequestState>(
        listener: (context, state) {
          final error = state.error.trim();
          if (error.isNotEmpty) {
            AppToast.show(
              context,
              message: error,
              type: AppToastType.error,
            );
          }

          final success = state.success.trim();
          if (success.isNotEmpty) {
            AppToast.show(
              context,
              message: success,
              type: AppToastType.success,
            );
          }
        },
        builder: (context, state) {
          return RefreshIndicator(
            onRefresh: () async {
              context.read<RequestBloc>().add(
                    LoadRequests(
                      departmentId: state.selectedDepartmentId,
                      status: state.selectedStatus,
                    ),
                  );
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
              children: [
                TextField(
                  onChanged: (value) {
                    context.read<RequestBloc>().add(SearchRequests(value));
                  },
                  decoration: InputDecoration(
                    hintText: l10n.search,
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: BlocBuilder<DepartmentCubit, DepartmentState>(
                        builder: (context, depState) {
                          return DropdownButtonFormField<int?>(
                            value: state.selectedDepartmentId,
                            isExpanded: true,
                            decoration: InputDecoration(
                              labelText: l10n.department,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            items: [
                              DropdownMenuItem<int?>(
                                value: null,
                                child: _ResponsiveText(
                                  text: l10n.all,
                                  maxFontSize: 13,
                                  minFontSize: 8,
                                  color: colors.onSurface,
                                ),
                              ),
                              ...depState.departments.map(
                                (department) {
                                  return DropdownMenuItem<int?>(
                                    value: department.id,
                                    child: _ResponsiveText(
                                      text: department.name,
                                      maxFontSize: 13,
                                      minFontSize: 8,
                                      color: colors.onSurface,
                                    ),
                                  );
                                },
                              ),
                            ],
                            onChanged: (value) {
                              context.read<RequestBloc>().add(
                                    FilterRequests(
                                      departmentId: value,
                                      status: state.selectedStatus,
                                    ),
                                  );
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField<String?>(
                        value: state.selectedStatus,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: l10n.status,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        items: [
                          DropdownMenuItem<String?>(
                            value: null,
                            child: _ResponsiveText(
                              text: l10n.all,
                              maxFontSize: 13,
                              minFontSize: 8,
                              color: colors.onSurface,
                            ),
                          ),
                          ..._statuses.map(
                            (status) {
                              return DropdownMenuItem<String?>(
                                value: status,
                                child: _ResponsiveText(
                                  text: _formatStatus(status),
                                  maxFontSize: 13,
                                  minFontSize: 8,
                                  color: colors.onSurface,
                                ),
                              );
                            },
                          ),
                        ],
                        onChanged: (value) {
                          context.read<RequestBloc>().add(
                                FilterRequests(
                                  departmentId: state.selectedDepartmentId,
                                  status: value,
                                ),
                              );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (state.loading && state.visibleRequests.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 120),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (state.visibleRequests.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 120),
                    child: Center(
                      child: _ResponsiveText(
                        text: l10n.noData,
                        maxFontSize: 15,
                        minFontSize: 10,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  )
                else
                  ...state.visibleRequests.map(
                    (request) {
                      return _RequestCard(
                        request: request,
                        statusText: _formatStatus(request.status),
                        statusColor: _statusColor(context, request.status),
                        createdAt: _formatDate(request.createdAt),
                        onTap: () => _openDetails(request),
                      );
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final RequestModel request;
  final String statusText;
  final Color statusColor;
  final String createdAt;
  final VoidCallback onTap;

  const _RequestCard({
    required this.request,
    required this.statusText,
    required this.statusColor,
    required this.createdAt,
    required this.onTap,
  });

  String _safe(String? value) {
    final clean = value?.trim() ?? '';
    return clean.isEmpty || clean == 'null' ? '---' : clean;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: colors.outlineVariant.withOpacity(0.55),
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: statusColor.withOpacity(0.13),
              child: Icon(
                Icons.mark_email_unread_outlined,
                color: statusColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                children: [
                  _ResponsiveText(
                    text: _safe(request.title),
                    maxFontSize: 15,
                    minFontSize: 8,
                    fontWeight: FontWeight.w900,
                    color: colors.onSurface,
                  ),
                  const SizedBox(height: 5),
                  _ResponsiveText(
                    text: _safe(request.trackingNumber),
                    maxFontSize: 12,
                    minFontSize: 8,
                    color: colors.onSurfaceVariant,
                  ),
                  const SizedBox(height: 5),
                  _ResponsiveText(
                    text: createdAt,
                    maxFontSize: 11,
                    minFontSize: 8,
                    color: colors.onSurfaceVariant,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            _StatusBadge(
              label: statusText,
              color: statusColor,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusBadge({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 112),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: _ResponsiveText(
        text: label,
        maxFontSize: 11,
        minFontSize: 7,
        fontWeight: FontWeight.w800,
        color: color,
        textAlign: TextAlign.center,
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