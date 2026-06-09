import 'dart:io';

import 'package:baladiyati/core/network/dio_client.dart';
import 'package:baladiyati/core/network/globals.dart' as globals;
import 'package:flutter/material.dart';

class PrivateProfileAvatar extends StatefulWidget {
  final String? imageUrl;
  final File? localImage;
  final String fallbackText;
  final double radius;
  final Color backgroundColor;
  final Color textColor;
  final Widget? badge;

  const PrivateProfileAvatar({
    super.key,
    required this.imageUrl,
    required this.fallbackText,
    required this.backgroundColor,
    required this.textColor,
    this.localImage,
    this.radius = 38,
    this.badge,
  });

  @override
  State<PrivateProfileAvatar> createState() => _PrivateProfileAvatarState();
}

class _PrivateProfileAvatarState extends State<PrivateProfileAvatar> {
  bool _failed = false;
  bool _primaryFailed = false;

  @override
  void didUpdateWidget(covariant PrivateProfileAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.imageUrl != widget.imageUrl ||
        oldWidget.localImage?.path != widget.localImage?.path) {
      _failed = false;
      _primaryFailed = false;
    }
  }

  String? _resolveUrl(String? rawUrl) {
    var value = rawUrl?.trim();

    if (value == null || value.isEmpty || value == 'null') {
      return null;
    }

    value = value.replaceAll('\\', '/');

    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }

    // Relative path — resolve against the server root (strip /api suffix from
    // the base URL only; keep the path exactly as returned by the server so we
    // never accidentally drop an /api segment that belongs in the URL).
    final buildBase = DioClient.build.options.baseUrl.trim();
    final serverRoot = buildBase
        .replaceFirst(RegExp(r'/api/?$'), '')
        .replaceAll(RegExp(r'/+$'), '');

    final path = value.startsWith('/') ? value : '/$value';

    // Primary candidate: Build4All server root + path
    final primaryUrl = '$serverRoot$path';

    // Secondary candidate: municipality server root + path (stored for fallback)
    try {
      final muniBase = DioClient.muni.options.baseUrl.trim();
      final muniRoot = muniBase
          .replaceFirst(RegExp(r'/api/?$'), '')
          .replaceAll(RegExp(r'/+$'), '');
      if (muniRoot != serverRoot) {
        _fallbackResolvedUrl = '$muniRoot$path';
      }
    } catch (_) {
      // DioClient.muni may not be ready yet
    }

    return primaryUrl;
  }

  /// Secondary URL tried after the primary fails.
  String? _fallbackResolvedUrl;

  Map<String, String> _headers() {
    final auth = globals.readAuthToken().trim();
    final ownerProjectLinkId = globals.ownerProjectLinkId?.trim();

    final headers = <String, String>{};

    if (auth.isNotEmpty) {
      headers['Authorization'] = auth;
    }

    if (ownerProjectLinkId != null && ownerProjectLinkId.isNotEmpty) {
      headers['Owner-Project-Link-Id'] = ownerProjectLinkId;
      headers['X-Owner-Project-Link-Id'] = ownerProjectLinkId;
    }

    return headers;
  }

  String _initial() {
    final clean = widget.fallbackText.trim();

    if (clean.isEmpty) {
      return '?';
    }

    return clean.substring(0, 1).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    ImageProvider? provider;

    if (widget.localImage != null) {
      provider = FileImage(widget.localImage!);
    } else {
      final resolved = _resolveUrl(widget.imageUrl);
      final fallback = _fallbackResolvedUrl;

      if (!_failed) {
        // If primary URL failed, try the municipality-base fallback URL
        final useUrl = (_primaryFailed && fallback != null) ? fallback : resolved;
        if (useUrl != null) {
          provider = NetworkImage(useUrl, headers: _headers());
        }
      }
    }

    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        CircleAvatar(
          radius: widget.radius,
          backgroundColor: widget.backgroundColor,
          backgroundImage: provider,
          onBackgroundImageError: provider == null
              ? null
              : (_, __) {
                  if (!mounted) return;
                  if (!_primaryFailed && _fallbackResolvedUrl != null) {
                    // First failure: try municipality base URL
                    setState(() => _primaryFailed = true);
                  } else {
                    // Both URLs failed: show initials
                    setState(() => _failed = true);
                  }
                },
          child: provider == null
              ? Text(
                  _initial(),
                  style: TextStyle(
                    color: widget.textColor,
                    fontSize: widget.radius * 0.75,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : null,
        ),
        if (widget.badge != null) widget.badge!,
      ],
    );
  }
}