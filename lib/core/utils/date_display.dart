// lib/core/utils/date_display.dart
//
// Shows backend ISO timestamps ("2026-09-29T06:21:55.348Z") as
// "2026-09-29 06:21", which is easier to read in lists.

/// Characters kept from the ISO timestamp: date, space and hours:minutes.
const int _dateTimeDisplayLength = 16;

String formatIsoDateTime(String value) {
  final clean = value.trim();
  if (clean.isEmpty) return clean;
  final readable = clean.replaceFirst('T', ' ');
  return readable.length > _dateTimeDisplayLength
      ? readable.substring(0, _dateTimeDisplayLength)
      : readable;
}
