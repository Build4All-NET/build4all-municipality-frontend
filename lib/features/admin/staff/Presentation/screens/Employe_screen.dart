import 'package:baladiyati/common/widgets/app_search_field.dart';
import 'package:baladiyati/common/widgets/app_toast.dart';
import 'package:baladiyati/common/widgets/primary_button.dart';
import 'package:baladiyati/features/admin/Departement/domain/Entities/Departement.dart';
import 'package:baladiyati/features/admin/Departement/presentation/bloc/Departement_State.dart';
import 'package:baladiyati/features/admin/Departement/presentation/cubit/Departement_cubit.dart';
import 'package:baladiyati/features/admin/staff/Presentation/bloc/AdminStaffBloc.dart';
import 'package:baladiyati/features/admin/staff/Presentation/bloc/AdminStaffEvent.dart';
import 'package:baladiyati/features/admin/staff/Presentation/bloc/AdminStaffState.dart';
import 'package:baladiyati/features/admin/staff/data/Model/AdminUserModel.dart';
import 'package:baladiyati/features/admin/staff/data/Model/UserAssignmentSearchResult.dart';
import 'package:baladiyati/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EmployeesScreen extends StatefulWidget {
  const EmployeesScreen({super.key});

  @override
  State<EmployeesScreen> createState() => _EmployeesScreenState();
}

class _EmployeesScreenState extends State<EmployeesScreen> {
  final TextEditingController _searchController = TextEditingController();
  static const String _staffRoleName = 'STAFF';

  @override
  void initState() {
    super.initState();
    final bloc = context.read<AdminStaffBloc>();
    bloc.add(LoadStaffRoles());
    bloc.add(LoadStaffUsers(roleName: _staffRoleName));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    context.read<AdminStaffBloc>().add(LoadStaffUsers(roleName: _staffRoleName));
  }

  void _clearSearch() {
    _searchController.clear();
    context.read<AdminStaffBloc>().add(SearchStaffUsersLocally(''));
    setState(() {});
  }

  void _openAssignStaffDialog() {
    context.read<AdminStaffBloc>().add(ClearStaffSearchResult());
    context.read<DepartmentCubit>().fetchDepartments();

    showDialog(
      context: context,
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: context.read<AdminStaffBloc>()),
          BlocProvider.value(value: context.read<DepartmentCubit>()),
        ],
        child: const _AssignStaffDialog(roleName: _staffRoleName),
      ),
    );
  }

  Future<void> _confirmRemoveRole(AdminUserModel user) async {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          title: Text(l10n.removeStaffRole),
          content: Text(l10n.confirmRemoveStaffRole(user.displayName)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(l10n.cancel),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.error,
                foregroundColor: colors.onError,
              ),
              icon: const Icon(Icons.person_remove_outlined),
              label: Text(l10n.delete),
              onPressed: () => Navigator.pop(dialogContext, true),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      context.read<AdminStaffBloc>().add(
            RemoveStaffRole(userId: user.id, roleName: _staffRoleName),
          );
    }
  }

  String _successMessage(AppLocalizations l10n, String code) {
    switch (code) {
      case 'STAFF_ASSIGNED':
        return l10n.staffAssignedSuccessfully;
      case 'STAFF_ROLE_REMOVED':
        return l10n.staffRoleRemovedSuccessfully;
      case 'STAFF_INVITE_SENT':
        return l10n.staffInviteSentSuccessfully;
      case 'FULL_NAME_REQUIRED':
        return l10n.fullNameRequired;
      default:
        return code;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return BlocConsumer<AdminStaffBloc, AdminStaffState>(
      listener: (context, state) {
        final error = state.error?.trim() ?? '';
        final success = state.success?.trim() ?? '';

        if (error.isNotEmpty) {
          AppToast.show(context, message: error, type: AppToastType.error);
          context.read<AdminStaffBloc>().add(ClearStaffMessages());
        }

        if (success.isNotEmpty) {
          AppToast.show(context, message: _successMessage(l10n, success), type: AppToastType.success);
          context.read<AdminStaffBloc>().add(ClearStaffMessages());
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            title: Text(
              l10n.staff,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
            actions: [
              IconButton(
                tooltip: l10n.update,
                icon: const Icon(Icons.refresh),
                onPressed: state.loading || state.actionLoading
                    ? null
                    : () => context.read<AdminStaffBloc>().add(LoadStaffUsers(roleName: _staffRoleName)),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: state.loading || state.actionLoading ? null : _openAssignStaffDialog,
            icon: const Icon(Icons.person_add_alt_1_outlined),
            label: Text(l10n.assignStaff),
          ),
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
                children: [
                  _HeaderCard(
                    title: l10n.staff,
                    subtitle: l10n.manageStaff,
                    count: state.allStaffUsers.length,
                  ),
                  const SizedBox(height: 16),
                  AppSearchField(
                    controller: _searchController,
                    hint: l10n.search,
                    onChanged: (value) {
                      context.read<AdminStaffBloc>().add(SearchStaffUsersLocally(value));
                      setState(() {});
                    },
                    onClear: _searchController.text.trim().isEmpty ? null : _clearSearch,
                  ),
                  const SizedBox(height: 16),
                  if (state.actionLoading)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: LinearProgressIndicator(),
                    ),
                  if (state.loading && state.allStaffUsers.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 120),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (state.visibleStaffUsers.isEmpty)
                    _EmptyState(title: l10n.noData, subtitle: l10n.noStaffHint)
                  else
                    ...state.visibleStaffUsers.map(
                      (user) => _StaffCard(user: user, onRemove: () => _confirmRemoveRole(user)),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _AssignStaffDialog extends StatefulWidget {
  final String roleName;
  const _AssignStaffDialog({required this.roleName});

  @override
  State<_AssignStaffDialog> createState() => _AssignStaffDialogState();
}

class _AssignStaffDialogState extends State<_AssignStaffDialog> {
  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final Set<int> _selectedDepartmentIds = {};

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  String? _emailValidator(String? value) {
    final l10n = AppLocalizations.of(context)!;
    final text = value?.trim() ?? '';
    if (text.isEmpty) return l10n.fieldRequired;
    final valid = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(text);
    if (!valid) return l10n.invalidEmail;
    return null;
  }

  void _search() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _selectedDepartmentIds.clear());
    context.read<AdminStaffBloc>().add(
          SearchUserForStaffAssignment(
            email: _emailController.text.trim(),
            roleName: widget.roleName,
          ),
        );
  }

  void _assign(UserAssignmentSearchResult result) {
    final userId = result.userId;
    if (userId == null || userId <= 0) return;

    if (_selectedDepartmentIds.isEmpty) {
      final l10n = AppLocalizations.of(context)!;
      AppToast.show(context, message: l10n.selectDepartment, type: AppToastType.warning);
      return;
    }

    context.read<AdminStaffBloc>().add(
          AssignUserAsStaff(
            userId: userId,
            roleName: widget.roleName,
            departmentIds: _selectedDepartmentIds.toList(),
          ),
        );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return BlocConsumer<AdminStaffBloc, AdminStaffState>(
      listenWhen: (previous, current) => previous.success != current.success,
      listener: (context, state) {
        if (state.success == 'STAFF_INVITE_SENT') {
          if (Navigator.canPop(context)) Navigator.pop(context);
        }
      },
      builder: (context, state) {
        final result = state.assignmentSearchResult;

        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          titlePadding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
          contentPadding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
          actionsPadding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          title: Text(
            l10n.assignStaff,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.searchUserByEmail,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _emailController,
                      validator: _emailValidator,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.search,
                      onFieldSubmitted: (_) => _search(),
                      decoration: InputDecoration(
                        labelText: l10n.enterUserEmail,
                        prefixIcon: const Icon(Icons.email_outlined),
                        filled: true,
                        fillColor: colors.surface,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                    const SizedBox(height: 14),
                    PrimaryButton(
                      label: state.searchLoading ? l10n.loading : l10n.searchUser,
                      isLoading: state.searchLoading,
                      onPressed: _search,
                    ),
                    if (result != null) ...[
                      const SizedBox(height: 16),
                      if (result.exists)
                        _FoundUserCard(
                          result: result,
                          selectedDepartmentIds: _selectedDepartmentIds,
                          onToggleDepartment: (id) => setState(() {
                            if (_selectedDepartmentIds.contains(id)) {
                              _selectedDepartmentIds.remove(id);
                            } else {
                              _selectedDepartmentIds.add(id);
                            }
                          }),
                          onAssign: result.alreadyAssigned || state.actionLoading
                              ? null
                              : () => _assign(result),
                        )
                      else
                        _NotFoundCard(email: result.email),
                    ],
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: state.searchLoading || state.actionLoading ? null : () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
          ],
        );
      },
    );
  }
}

class _FoundUserCard extends StatelessWidget {
  final UserAssignmentSearchResult result;
  final Set<int> selectedDepartmentIds;
  final void Function(int) onToggleDepartment;
  final VoidCallback? onAssign;

  const _FoundUserCard({
    required this.result,
    required this.selectedDepartmentIds,
    required this.onToggleDepartment,
    required this.onAssign,
  });

  String _safe(String value) {
    final clean = value.trim();
    return clean.isEmpty ? '-' : clean;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.primary.withOpacity(0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle_outline, color: colors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.userFound,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: colors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _InfoLine(icon: Icons.person_outline, value: result.displayName),
          _InfoLine(icon: Icons.email_outlined, value: result.email),
          _InfoLine(icon: Icons.phone_outlined, value: _safe(result.phone)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _SmallBadge(
                label: '\${l10n.currentRole}: \${_safe(result.currentRoleName)}',
                icon: Icons.verified_user_outlined,
                color: colors.secondary,
              ),
              _SmallBadge(
                label: result.isVerified ? l10n.verified : l10n.notVerified,
                icon: result.isVerified ? Icons.verified_outlined : Icons.info_outline,
                color: result.isVerified ? colors.primary : colors.error,
              ),
            ],
          ),
          if (!result.alreadyAssigned) ...[
            const SizedBox(height: 14),
            Text(
              l10n.selectDepartment,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            BlocBuilder<DepartmentCubit, DepartmentState>(
              builder: (context, deptState) {
                if (deptState.loading && deptState.departments.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (deptState.departments.isEmpty) {
                  return Text(
                    l10n.noDepartmentsHint,
                    style: theme.textTheme.bodySmall?.copyWith(color: colors.error),
                  );
                }
                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: deptState.departments.map((dept) {
                    final selected = selectedDepartmentIds.contains(dept.id);
                    return FilterChip(
                      label: Text(dept.name),
                      selected: selected,
                      onSelected: (_) => onToggleDepartment(dept.id),
                      selectedColor: colors.primary.withOpacity(0.18),
                      checkmarkColor: colors.primary,
                      labelStyle: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: selected ? colors.primary : colors.onSurfaceVariant,
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
          const SizedBox(height: 12),
          if (result.alreadyAssigned)
            _InfoBox(
              icon: Icons.done_all_outlined,
              text: l10n.alreadyAssigned,
              color: colors.primary,
            )
          else
            PrimaryButton(
              label: l10n.assignAsStaff,
              onPressed: onAssign ?? () {},
            ),
        ],
      ),
    );
  }
}

class _NotFoundCard extends StatefulWidget {
  final String email;
  const _NotFoundCard({required this.email});

  @override
  State<_NotFoundCard> createState() => _NotFoundCardState();
}

class _NotFoundCardState extends State<_NotFoundCard> {
  final TextEditingController _nameController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  String? _nameValidator(String? value) {
    final l10n = AppLocalizations.of(context)!;
    final clean = value?.trim() ?? '';
    if (clean.isEmpty) return l10n.fullNameRequired;
    if (clean.length < 3) return l10n.fullNameRequired;
    return null;
  }

  void _sendInvite() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AdminStaffBloc>().add(
          SendStaffRegistrationInvite(email: widget.email, fullName: _nameController.text.trim()),
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return BlocBuilder<AdminStaffBloc, AdminStaffState>(
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: colors.error.withOpacity(0.07),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: colors.error.withOpacity(0.18)),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.person_off_outlined, color: colors.error),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.userNotFound,
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: colors.error,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.email,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            l10n.inviteStaffDescription,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colors.onSurfaceVariant,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _nameController,
                  validator: _nameValidator,
                  enabled: !state.actionLoading,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    labelText: l10n.enterFullName,
                    prefixIcon: const Icon(Icons.person_outline),
                    filled: true,
                    fillColor: colors.surface,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
                const SizedBox(height: 12),
                PrimaryButton(
                  label: state.actionLoading ? l10n.loading : l10n.sendRegistrationInvite,
                  isLoading: state.actionLoading,
                  onPressed: _sendInvite,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _HeaderCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final int count;

  const _HeaderCard({required this.title, required this.subtitle, required this.count});

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
            child: Icon(Icons.badge_outlined, color: colors.onPrimary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: colors.onPrimary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onPrimary.withOpacity(0.78),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
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

class _StaffCard extends StatelessWidget {
  final AdminUserModel user;
  final VoidCallback onRemove;

  const _StaffCard({required this.user, required this.onRemove});

  String _safe(String value) {
    final clean = value.trim();
    return clean.isEmpty ? '-' : clean;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.outline.withOpacity(0.14)),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withOpacity(0.045),
            blurRadius: 12,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: colors.primary.withOpacity(0.12),
            child: Icon(Icons.person_outline, color: colors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                _InfoLine(icon: Icons.email_outlined, value: _safe(user.email)),
                _InfoLine(icon: Icons.phone_outlined, value: _safe(user.phone)),
                if (user.assignedDepartments.isNotEmpty)
                  _InfoLine(
                    icon: Icons.account_tree_outlined,
                    value: user.departmentNames,
                  ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _SmallBadge(
                      label: _safe(user.roleName),
                      icon: Icons.verified_user_outlined,
                      color: colors.secondary,
                    ),
                    _SmallBadge(
                      label: user.isVerified ? l10n.verified : l10n.notVerified,
                      icon: user.isVerified ? Icons.verified_outlined : Icons.info_outline,
                      color: user.isVerified ? colors.primary : colors.error,
                    ),
                  ],
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'remove') onRemove();
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'remove',
                child: Row(
                  children: [
                    Icon(Icons.person_remove_outlined, size: 18, color: colors.error),
                    const SizedBox(width: 8),
                    Text(l10n.removeStaffRole, style: TextStyle(color: colors.error)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  final IconData icon;
  final String value;

  const _InfoLine({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 3),
      child: Row(
        children: [
          Icon(icon, size: 14, color: colors.onSurfaceVariant),
          const SizedBox(width: 5),
          Expanded(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SmallBadge extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _SmallBadge({required this.label, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 180),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: color.withOpacity(0.10),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: color.withOpacity(0.22)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _InfoBox({required this.icon, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: color.withOpacity(0.09),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.18)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w800,
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
      padding: const EdgeInsets.only(top: 120),
      child: Column(
        children: [
          Icon(Icons.badge_outlined, size: 58, color: colors.onSurface.withOpacity(0.35)),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 5),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(color: colors.onSurface.withOpacity(0.6)),
          ),
        ],
      ),
    );
  }
}
