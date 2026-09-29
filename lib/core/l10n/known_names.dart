// lib/core/l10n/known_names.dart
//
// Translations for the default departments and services the backend creates
// with English names. Unknown names are returned unchanged.

import 'package:baladiyati/l10n/app_localizations.dart';

String localizedDepartmentName(AppLocalizations l10n, String name) {
  switch (name.trim()) {
    case 'Engineering':
      return l10n.deptEngineering;
    case 'Finance':
      return l10n.deptFinance;
    case 'Police':
      return l10n.deptPolice;
    case 'Civil Status':
      return l10n.deptCivilStatus;
    case 'Public Works':
      return l10n.deptPublicWorks;
    default:
      return name;
  }
}

/// [englishName] is the service's English name from the backend.
String localizedServiceName(AppLocalizations l10n, String englishName) {
  switch (englishName.trim()) {
    case 'Building Permit':
      return l10n.serviceBuildingPermit;
    case 'Larger Building Permit':
      return l10n.serviceLargerBuildingPermit;
    case 'Housing Permit':
      return l10n.serviceHousingPermit;
    case 'External Works':
      return l10n.serviceExternalWorks;
    case 'Illegal Construction':
      return l10n.serviceIllegalConstruction;
    case 'Valuation Certificate':
      return l10n.serviceValuationCertificate;
    case 'Clearance Certificate':
      return l10n.serviceClearanceCertificate;
    case 'Tent Permit':
      return l10n.serviceTentPermit;
    case 'Property Access':
      return l10n.servicePropertyAccess;
    case 'Residence Certificate':
      return l10n.serviceResidenceCertificate;
    case 'Contents Certificate':
      return l10n.serviceContentsCertificate;
    case 'Work Certificate':
      return l10n.serviceWorkCertificate;
    case 'Lease Registration':
      return l10n.serviceLeaseRegistration;
    default:
      return englishName;
  }
}

/// Request / workflow status from the backend (e.g. "UNDER_REVIEW") as a label.
/// Unknown statuses are shown readable ("SOME_STATUS" -> "SOME STATUS").
String localizedRequestStatus(AppLocalizations l10n, String? status) {
  final clean = (status ?? '').trim().toUpperCase();
  switch (clean) {
    case 'DRAFT':
      return l10n.statusDraft;
    case 'SUBMITTED':
      return l10n.statusSubmitted;
    case 'PENDING':
      return l10n.statusPending;
    case 'UNDER_REVIEW':
      return l10n.statusUnderReview;
    case 'DOCUMENTS_MISSING':
      return l10n.statusDocumentsMissing;
    case 'IN_PROGRESS':
      return l10n.statusInProgress;
    case 'APPROVED':
      return l10n.statusApproved;
    case 'REJECTED':
      return l10n.statusRejected;
    case 'COMPLETED':
      return l10n.statusCompleted;
    case 'CANCELLED':
      return l10n.statusCancelled;
    case 'TAX_PAID':
      return l10n.statusTaxPaid;
    case 'TAX_REJECTED':
      return l10n.statusTaxRejected;
    case '':
      return '—';
    default:
      return clean.replaceAll('_', ' ');
  }
}
