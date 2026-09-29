// lib/core/config/app_breakpoints.dart

/// Screen-width breakpoints (logical pixels), following Material 3 window size classes.
class AppBreakpoints {
  /// Below this width the layout is "compact" (phones).
  static const double medium   = 600;
  /// From this width the layout is "expanded" (desktop / wide web).
  static const double expanded = 1024;
}

/// Layout limits used to keep content readable on wide screens (web / desktop).
class AppLayout {
  // Max content widths per screen type.
  static const double maxWidthAuth   = 480;   // login, register, OTP, reset password
  static const double maxWidthForm   = 760;   // create / edit forms
  static const double maxWidthDetail = 960;   // single-column content: lists, details, chat, profile
  static const double maxWidthPage   = 1200;  // dashboards, grids

  // Grid columns per window size.
  static const int gridColumnsCompact  = 2;
  static const int gridColumnsMedium   = 3;
  static const int gridColumnsExpanded = 4;

  // List cards: columns are added while each card can stay at least this wide.
  static const double cardMinWidth   = 420;
  static const int    cardMaxColumns = 3;
  static const double cardGridSpacing = 12;

  // Dashboard quick-action tiles (width / height): wider on tablet / web.
  static const double actionTileAspectRatioCompact = 1.12;
  static const double actionTileAspectRatioWide    = 1.6;

  // Side navigation shown instead of the bottom bar / dashboard tiles on wide screens.
  static const double sidebarWidth          = 272;  // desktop: icons + labels
  static const double sidebarCollapsedWidth = 84;   // tablet: icons only
  static const double sidebarItemHeight     = 48;
  static const double sidebarLogoSize       = 44;
}
