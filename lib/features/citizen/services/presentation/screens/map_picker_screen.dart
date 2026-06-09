import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:baladiyati/l10n/app_localizations.dart';

class MapPickerResult {
  final double lat;
  final double lng;
  final String? locationName;

  const MapPickerResult({
    required this.lat,
    required this.lng,
    this.locationName,
  });
}

class MapPickerScreen extends StatefulWidget {
  final double? initialLat;
  final double? initialLng;

  const MapPickerScreen({super.key, this.initialLat, this.initialLng});

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  LatLng? _picked;
  String? _locationName;
  bool _fetchingName = false;
  final _mapController = MapController();

  // Default to Beirut city center if no initial coords
  static const _defaultCenter = LatLng(33.8938, 35.5018);

  @override
  void initState() {
    super.initState();
    if (widget.initialLat != null && widget.initialLng != null) {
      _picked = LatLng(widget.initialLat!, widget.initialLng!);
    }
  }

  Future<void> _onTap(TapPosition _, LatLng point) async {
    setState(() {
      _picked = point;
      _locationName = null;
      _fetchingName = true;
    });

    final name = await _reverseGeocode(point.latitude, point.longitude);
    if (mounted) {
      setState(() {
        _locationName = name;
        _fetchingName = false;
      });
    }
  }

  Future<String?> _reverseGeocode(double lat, double lng) async {
    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lng&accept-language=en',
      );
      final response = await http.get(uri, headers: {
        'User-Agent': 'Baladiyati-Municipality-App/1.0',
      }).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final address = data['address'] as Map<String, dynamic>?;
        if (address != null) {
          final city = address['city']?.toString() ??
              address['town']?.toString() ??
              address['village']?.toString() ??
              address['county']?.toString();
          if (city != null && city.isNotEmpty) return city;
        }
        final displayName = data['display_name']?.toString();
        if (displayName != null && displayName.isNotEmpty) {
          return displayName.split(',').take(3).join(',').trim();
        }
      }
    } catch (_) {}
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final center = _picked ?? _defaultCenter;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.mapPickerTitle),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: center,
              initialZoom: _picked != null ? 14 : 10,
              onTap: _onTap,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'net.build4all.baladiyati',
              ),
              if (_picked != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _picked!,
                      width: 40,
                      height: 40,
                      child: Icon(
                        Icons.location_pin,
                        color: colors.primary,
                        size: 40,
                      ),
                    ),
                  ],
                ),
            ],
          ),

          // Hint banner at top
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              color: colors.surface.withOpacity(0.92),
              child: Row(
                children: [
                  Icon(Icons.touch_app_outlined,
                      color: colors.primary, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      loc.mapPickerHint,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: colors.outline),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom confirm panel
          if (_picked != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 14,
                  bottom: MediaQuery.of(context).padding.bottom + 14,
                ),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.location_on,
                            color: colors.primary, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _fetchingName
                              ? Text(
                                  '...',
                                  style: theme.textTheme.bodyMedium
                                      ?.copyWith(color: colors.outline),
                                )
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (_locationName != null)
                                      Text(
                                        _locationName!,
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                                fontWeight: FontWeight.w600),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    Text(
                                      '${_picked!.latitude.toStringAsFixed(5)}, '
                                      '${_picked!.longitude.toStringAsFixed(5)}',
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(color: colors.outline),
                                    ),
                                  ],
                                ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _fetchingName
                            ? null
                            : () => Navigator.pop(
                                  context,
                                  MapPickerResult(
                                    lat: _picked!.latitude,
                                    lng: _picked!.longitude,
                                    locationName: _locationName,
                                  ),
                                ),
                        child: Text(loc.mapPickerConfirm),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
