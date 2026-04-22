// lib/core/network/connecting(wifiORserver)/connection_status.dart

/// High-level connection status for the app.
enum ConnectionStatus {
  /// Device has internet and backend is reachable.
  online,

  /// Device has NO internet (Wi-Fi/mobile off or no connectivity).
  offline,

  /// Device has internet, but backend is not responding.
  serverDown,
}
