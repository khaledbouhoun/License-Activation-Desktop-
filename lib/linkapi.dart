class AppLink {
  static const String server = "http://127.0.0.1:8000/api";

  // Auth
  static const String login = "$server/login";
  static const String logout = "$server/logout";
  static const String profile = "$server/profile";

  // Dashboard
  // static const String dashboardStats = "$server/dashboard/stats";

  // Subscriptions
  static const String subscriptions = "$server/subscriptions";
  static const String subscriptionGenerateLicense =
      "$server/subscriptions/generate-license";
  static const String subscriptionRevokeLicense =
      "$server/subscriptions/revoke-license";

  // Clients
  static const String clients = "$server/clients";

  // Applications
  static const String applications = "$server/applications";

  // Licenses
  static const String licenses = "$server/licenses";

  // Desktop App Key
  static const String desktopAppKey =
      "SqD/Lxalu9SeUO5hcQX/rx3RfIU+mtYtZiQUJXSFZJU="; // Replace with real key
}
