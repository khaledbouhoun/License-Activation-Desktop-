class AppLink {
  static const String server = "https://licenseactivation.softel.dz/api";

  // Auth
  static const String login = "$server/login";
  static const String logout = "$server/logout";
  static const String profile = "$server/profile";

  // Dashboard
  // static const String dashboardStats = "$server/dashboard/stats";

  // Subscriptions
  static const String subscriptions = "$server/subscriptions";
  // Clients
  static const String clients = "$server/clients";

  // Applications
  static const String applications = "$server/applications";

  // Licenses
  static const String licenses = "$server/licenses";

  // Desktop App Key

  static const String desktopAppKey = String.fromEnvironment('DESKTOP_APP_KEY');
}
