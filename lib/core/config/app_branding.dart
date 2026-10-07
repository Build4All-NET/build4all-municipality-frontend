// The name and logo this particular app was built with (APP_NAME / APP_LOGO_URL from the build config).
// The localized "baladiyati" title is only the fallback for builds that carry no branding.

import 'package:flutter/material.dart';

import 'package:baladiyati/core/config/env.dart';
import 'package:baladiyati/core/network/globals.dart' as globals;
import 'package:baladiyati/l10n/app_localizations.dart';

const _placeholderNames = {'', 'build4all app', 'my app', 'app', 'baladiyati'};

/// The municipality / app name to show to users.
String brandName(BuildContext context) {
  final name = Env.appName.trim();
  if (_placeholderNames.contains(name.toLowerCase())) {
    return AppLocalizations.of(context)!.appTitle;
  }
  return name;
}

/// Absolute URL of the app logo, or '' when the build has none.
String brandLogoUrl() {
  final url = Env.appLogoUrl.trim();
  return url.isEmpty ? '' : globals.resolveUrl(url);
}

/// The app logo in a rounded square, or [fallback] when there is no logo (or it cannot be loaded).
class BrandLogo extends StatelessWidget {
  final double size;
  final double radius;
  final Widget fallback;

  const BrandLogo({super.key, required this.size, required this.radius, required this.fallback});

  @override
  Widget build(BuildContext context) {
    final url = brandLogoUrl();
    if (url.isEmpty) return fallback;
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox(
        width: size,
        height: size,
        child: Image.network(
          url,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => fallback,
        ),
      ),
    );
  }
}
