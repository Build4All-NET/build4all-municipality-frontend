import 'package:baladiyati/common/widgets/app_search_field.dart';
import 'package:baladiyati/common/widgets/app_toast.dart';
import 'package:baladiyati/core/network/dio_client.dart';
import 'package:baladiyati/core/utils/error_message.dart';
import 'package:baladiyati/features/admin/manage_service/Data/model/service_Model.dart';
import 'package:baladiyati/features/staff/services/data/staff_service_api.dart';
import 'package:baladiyati/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class StaffServicesScreen extends StatefulWidget {
  const StaffServicesScreen({super.key});

  @override
  State<StaffServicesScreen> createState() => _StaffServicesScreenState();
}

class _StaffServicesScreenState extends State<StaffServicesScreen> {
  final TextEditingController _searchController = TextEditingController();
  late final StaffServiceApi _api;

  bool _loading = true;
  String? _error;

  List<ServiceModel> _allServices = [];
  List<ServiceModel> _visibleServices = [];

  @override
  void initState() {
    super.initState();
    _api = StaffServiceApi(DioClient.muni);
    _loadServices();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadServices() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final services = await _api.getServices();

      if (!mounted) return;

      setState(() {
        _allServices = services;
        _visibleServices = _applySearch(services, _searchController.text);
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      final message = errorMessage(e);

      setState(() {
        _loading = false;
        _error = message;
      });

      AppToast.show(
        context,
        message: message,
        type: AppToastType.error,
      );
    }
  }

  Future<void> _refresh() async {
    await _loadServices();
  }

  void _onSearch(String value) {
    setState(() {
      _visibleServices = _applySearch(_allServices, value);
    });
  }

  void _clearSearch() {
    _searchController.clear();

    setState(() {
      _visibleServices = _applySearch(_allServices, '');
    });
  }

  List<ServiceModel> _applySearch(
    List<ServiceModel> services,
    String query,
  ) {
    final q = query.trim().toLowerCase();

    if (q.isEmpty) {
      return services;
    }

    return services.where((service) {
      return service.nameAr.toLowerCase().contains(q) ||
          service.nameEn.toLowerCase().contains(q) ||
          service.descriptionAr.toLowerCase().contains(q) ||
          service.descriptionEn.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(loc.services),
        actions: [
          IconButton(
            tooltip: loc.update,
            icon: const Icon(Icons.refresh),
            onPressed: _loading ? null : _loadServices,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            _HeaderCard(
              title: loc.services,
              subtitle: loc.manageServices,
              count: _allServices.length,
            ),
            const SizedBox(height: 16),
            AppSearchField(
              controller: _searchController,
              hint: loc.search,
              onChanged: _onSearch,
              onClear: _searchController.text.trim().isEmpty
                  ? null
                  : _clearSearch,
            ),
            const SizedBox(height: 16),
            if (_loading && _allServices.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 120),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error != null && _allServices.isEmpty)
              _ErrorState(
                message: _error!,
                onRetry: _loadServices,
              )
            else if (_visibleServices.isEmpty)
              _EmptyState(
                title: loc.noData,
                subtitle: loc.noServicesHint,
              )
            else
              ..._visibleServices.map(
                (service) => _ServiceReadOnlyCard(service: service),
              ),
          ],
        ),
      ),
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
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.primary,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
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
              crossAxisAlignment:
                  isRtl ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: isRtl ? TextAlign.right : TextAlign.left,
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
                  textAlign: isRtl ? TextAlign.right : TextAlign.left,
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

class _ServiceReadOnlyCard extends StatelessWidget {
  final ServiceModel service;

  const _ServiceReadOnlyCard({
    required this.service,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    final langCode = Localizations.localeOf(context).languageCode;
    final title = isRtl
        ? (service.nameAr.trim().isNotEmpty ? service.nameAr : service.nameEn)
        : langCode == 'fr'
            ? switch (service.nameEn.trim()) {
                'Building Permit' => "Permis de construire",
                'Larger Building Permit' => "Permis de construire (grande superficie)",
                'Housing Permit' => "Permis d'habitation",
                'External Works' => 'Travaux extérieurs',
                'Illegal Construction' => 'Régularisation de construction illégale',
                'Valuation Certificate' => "Certificat d'évaluation",
                'Clearance Certificate' => 'Certificat de non-redevance',
                'Tent Permit' => 'Permis de tente',
                'Property Access' => "Autorisation d'accès à la propriété",
                'Residence Certificate' => 'Certificat de résidence',
                'Contents Certificate' => 'Attestation de contenu',
                'Work Certificate' => 'Attestation de travaux',
                'Lease Registration' => 'Enregistrement de bail',
                _ => service.nameEn,
              }
            : (service.nameEn.trim().isNotEmpty ? service.nameEn : service.nameAr);

    final subtitle = isRtl
        ? (service.descriptionAr.trim().isNotEmpty
            ? service.descriptionAr
            : service.descriptionEn)
        : (service.descriptionEn.trim().isNotEmpty
            ? service.descriptionEn
            : service.descriptionAr);

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
          textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
          children: [
            Expanded(
              child: Text(
                title.trim().isNotEmpty ? title : '---',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: isRtl ? TextAlign.right : TextAlign.left,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 8),
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
            textAlign: isRtl ? TextAlign.right : TextAlign.left,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurface.withOpacity(0.68),
            ),
          ),
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

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(top: 80),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            size: 58,
            color: colors.error,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.error,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: Text(loc.update),
          ),
        ],
      ),
    );
  }
}