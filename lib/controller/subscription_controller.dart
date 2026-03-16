import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:softel_control/controller/application_controller.dart';
import 'package:softel_control/controller/client_controller.dart';
import 'package:softel_control/core/functions/auth_post.dart';
import 'package:softel_control/data/model/application_model.dart';
import 'package:softel_control/data/model/client_model.dart';
import 'package:softel_control/data/model/subscription_model.dart';
import 'package:softel_control/linkapi.dart';
import 'package:softel_control/view/license/license_view.dart';
import 'package:url_launcher/url_launcher.dart';

class SubscriptionController extends GetxController {
  // Subscriptions list

  ClientController clientController = Get.find<ClientController>();
  ApplicationController applicationController =
      Get.find<ApplicationController>();
  final RxList<SubscriptionModel> subscriptions = <SubscriptionModel>[].obs;
  final RxList<SubscriptionModel> filteredSubscriptions =
      <SubscriptionModel>[].obs;

  // Selection
  final RxList<int> selectedIds = <int>[].obs;

  // Client
  Rx<ClientModel?> clientSelcted = Rx<ClientModel?>(null);
  Rx<ApplicationModel?> applicationSelcted = Rx<ApplicationModel?>(null);

  // Pagination
  final RxInt currentPage = 1.obs;
  final RxInt totalPages = 1.obs;
  final int itemsPerPage = 10;

  // Loading states
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool isLoadingSend = false.obs;

  // Filter and sort
  final RxString filterStatus = 'All'.obs;
  final RxString sortBy = 'date'.obs;

  @override
  void onInit() {
    super.onInit();
    loadSubscriptions();

    // Add workers to apply filters when selection changes
    ever(clientSelcted, (_) => applyFilters());
    ever(applicationSelcted, (_) => applyFilters());
    ever(filterStatus, (_) => applyFilters());
    ever(sortBy, (_) => applyFilters());
  }

  // Selection Methods
  void toggleSelection(int id) {
    if (selectedIds.contains(id)) {
      selectedIds.remove(id);
    } else {
      selectedIds.add(id);
    }
  }

  void selectAll(bool select) {
    if (select) {
      selectedIds.assignAll(getPaginatedSubscriptions().map((sub) => sub.id));
    } else {
      selectedIds.clear();
    }
  }

  bool isSelected(int id) => selectedIds.contains(id);

  // Load subscriptions
  Future<void> loadSubscriptions() async {
    try {
      isLoading.value = true;
      selectedIds.clear();

      // Real API call
      var response = await authGet(AppLink.subscriptions);

      if (response.statusCode == 200) {
        dynamic responseBody = jsonDecode(response.body);
        // Assuming Laravel returns { "success": true, "data": [...] } or just [...]
        // Adjust based on typical Laravel resource response.

        List<dynamic> data = [];
        if (responseBody is Map && responseBody['data'] != null) {
          data = responseBody['data'];
        } else if (responseBody is List) {
          data = responseBody;
        }

        subscriptions.value = data
            .map((json) => SubscriptionModel.fromJson(json))
            .toList();
        applyFilters();
      } else {
        Get.snackbar(
          'Error',
          'Failed to load subscriptions: ${response.statusCode}',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      print("Error loading subscriptions: $e");
      Get.snackbar(
        'Error',
        'Exception loading subscriptions: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Apply filters
  void applyFilters() {
    var filtered = subscriptions.toList();

    // Filter by status
    if (filterStatus.value != 'All') {
      filtered = filtered
          .where((sub) => sub.status.name == filterStatus.value)
          .toList();
    }

    // Filter by client
    if (clientSelcted.value != null) {
      filtered = filtered
          .where((sub) => sub.clientId == clientSelcted.value!.id)
          .toList();
    }

    // Filter by application
    if (applicationSelcted.value != null) {
      filtered = filtered
          .where((sub) => sub.applicationId == applicationSelcted.value!.id)
          .toList();
    }

    // Sort
    if (sortBy.value == 'date') {
      filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } else if (sortBy.value == 'expiry') {
      filtered
          .where((sub) => sub.expiryDate != null)
          .toList()
          .sort((a, b) => a.expiryDate!.compareTo(b.expiryDate!));
    } else if (sortBy.value == 'name') {
      filtered.sort((a, b) => a.clientName.compareTo(b.clientName));
    }

    filteredSubscriptions.value = filtered;
    totalPages.value = (filtered.length / itemsPerPage).ceil();

    // Clear selection if current items are not in filtered list
    // (Optional: depending on desired UX)
  }

  // Change filter status
  void changeFilterStatus(String status) {
    filterStatus.value = status;
    applyFilters();
  }

  // Change sort
  void changeSortBy(String sort) {
    sortBy.value = sort;
    applyFilters();
  }

  // Get paginated subscriptions
  List<SubscriptionModel> getPaginatedSubscriptions() {
    final startIndex = (currentPage.value - 1) * itemsPerPage;
    final endIndex = (startIndex + itemsPerPage).clamp(
      0,
      filteredSubscriptions.length,
    );

    if (startIndex >= filteredSubscriptions.length) {
      return [];
    }

    return filteredSubscriptions.sublist(startIndex, endIndex);
  }

  // Change page
  void changePage(int page) {
    if (page >= 1 && page <= totalPages.value) {
      currentPage.value = page;
      // selectedIds.clear(); // Optional: clear selection on page change
    }
  }

  // Communication Methods
  Future<void> sendWhatsAppReminder(SubscriptionModel sub) async {
    if (sub.clientPhone.isEmpty) {
      Get.snackbar('Error', 'Client has no phone number');
      return;
    }

    String message =
        "Bonjour ${sub.clientName}, 👋\n\n"
        "Ceci est un rappel concernant votre abonnement à *${sub.applicationName}*.\n\n"
        "Statut : ${sub.status == SubscriptionStatus.expired ? '❌ Expiré' : '⚠️ Expire bientôt'}\n"
        "Date d'expiration : ${sub.formattedExpiryDate}\n"
        "Jours restants : ${sub.daysUntilExpiry}\n\n"
        "Veuillez nous contacter pour renouveler votre abonnement.\n\n"
        "Merci beaucoup ! 😊";

    final Uri whatsappUri = Uri.parse(
      "whatsapp://send?phone=${sub.clientPhone}&text=${Uri.encodeComponent(message)}",
    );

    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
    } else {
      final Uri webUri = Uri.parse(
        "https://wa.me/${sub.clientPhone}?text=${Uri.encodeComponent(message)}",
      );

      if (await canLaunchUrl(webUri)) {
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      } else {
        Get.snackbar('Error', 'Could not launch WhatsApp');
      }
    }
  }

  Future<void> sendBulkWhatsApp() async {
    List<SubscriptionModel> targets = [];

    if (selectedIds.isNotEmpty) {
      targets = subscriptions.where((s) => selectedIds.contains(s.id)).toList();
    } else {
      // If none selected, target all in 'warning' or 'expired' status from filtered list
      targets = filteredSubscriptions
          .where(
            (s) =>
                s.status == SubscriptionStatus.warning ||
                s.status == SubscriptionStatus.expired,
          )
          .toList();
    }

    if (targets.isEmpty) {
      Get.snackbar('Info', 'No subscriptions identified for reminder');
      return;
    }

    // Since launching many URLs at once is problematic, we'll suggest processing one by one or confirm
    Get.defaultDialog(
      title: "Send WhatsApp Reminders",
      middleText: "Send reminders to ${targets.length} clients?",
      textConfirm: "Yes",
      textCancel: "Cancel",
      onConfirm: () async {
        Get.back();
        for (var sub in targets) {
          await sendWhatsAppReminder(sub);
          // Small delay to allow browser/app to breathe
          await Future.delayed(Duration(milliseconds: 1500));
        }
      },
    );
  }

  Future<void> sendBulkEmail() async {
    List<SubscriptionModel> targets = [];

    if (selectedIds.isNotEmpty) {
      targets = subscriptions.where((s) => selectedIds.contains(s.id)).toList();
    } else {
      targets = filteredSubscriptions
          .where(
            (s) =>
                s.status == SubscriptionStatus.warning ||
                s.status == SubscriptionStatus.expired,
          )
          .toList();
    }

    if (targets.isEmpty) {
      Get.snackbar('Info', 'No subscriptions identified for reminder');
      return;
    }

    Get.defaultDialog(
      title: "Send Email Reminders",
      middleText: "Send reminders to ${targets.length} clients?",
      textConfirm: "Yes",
      textCancel: "Cancel",
      onConfirm: () async {
        isLoadingSend.value = true;
        Get.back();
        int successCount = 0;
        int failCount = 0;

        for (var sub in targets) {
          try {
            await sendEmailReminder(sub);
            successCount++;
          } catch (_) {
            failCount++;
          } finally {
            isLoadingSend.value = false;
          }
        }

        Get.snackbar(
          'Summary',
          'Emails sent: $successCount, Failed: $failCount',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.blueGrey.shade800,
          colorText: Colors.white,
          duration: Duration(seconds: 4),
        );
      },
    );
  }

  Future<void> sendEmailReminder(SubscriptionModel sub) async {
    if (sub.clientEmail.isEmpty) {
      Get.snackbar('Error', 'Client ${sub.clientName} has no email');
      return;
    }

    final username = 'SavSoftel@gmail.com';
    final password = 'nxex olun rata simu';
    final smtpServer = gmail(username, password);

    final String subject = "ABONNEMENT EXPIRÉ - ${sub.applicationName}";

    // Dynamic variables — used via Dart interpolation inside the HTML string
    final bool isExpired = sub.status == SubscriptionStatus.expired;
    final String accentColor = isExpired ? '#dc2626' : '#ea580c';
    final String statusLabel = isExpired
        ? 'ABONNEMENT EXPIRÉ'
        : 'Expire Bientôt';
    final String statusMessage = isExpired
        ? 'Votre abonnement a expiré'
        : 'Votre abonnement expire dans ${sub.daysUntilExpiry} jours';
    final int currentYear = DateTime.now().year;

    // NOTE: Every ${ } below is a real Dart interpolation.
    // Variables used: accentColor, statusLabel, statusMessage, currentYear
    // and sub.clientName, sub.applicationName, sub.deviceNumber,
    // sub.formattedExpiryDate, sub.daysUntilExpiry
    final String body =
        """<!DOCTYPE html>
<html lang="fr" xmlns="http://www.w3.org/1999/xhtml" xmlns:v="urn:schemas-microsoft-com:vml" xmlns:o="urn:schemas-microsoft-com:office:office">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta http-equiv="X-UA-Compatible" content="IE=edge">
  <meta name="x-apple-disable-message-reformatting">
  <title>Rappel d'Abonnement</title>
  <!--[if mso]>
  <noscript><xml><o:OfficeDocumentSettings><o:PixelsPerInch>96</o:PixelsPerInch></o:OfficeDocumentSettings></xml></noscript>
  <![endif]-->
  <style>
    body, table, td, a { -webkit-text-size-adjust: 100%; -ms-text-size-adjust: 100%; }
    table, td { mso-table-lspace: 0pt; mso-table-rspace: 0pt; }
    img { -ms-interpolation-mode: bicubic; border: 0; height: auto; line-height: 100%; outline: none; text-decoration: none; }
    body { margin: 0 !important; padding: 0 !important; width: 100% !important; background-color: #f0f2f5; }
    a[x-apple-data-detectors] { color: inherit !important; text-decoration: none !important; font-size: inherit !important; font-family: inherit !important; font-weight: inherit !important; line-height: inherit !important; }
    @media screen and (max-width: 600px) {
      .email-container { width: 100% !important; margin: auto !important; }
      .stack-column, .stack-column-center { display: block !important; width: 100% !important; max-width: 100% !important; direction: ltr !important; }
      .stack-column-center { text-align: center !important; }
    }
  </style>
</head>
<body width="100%" style="margin: 0; padding: 0 !important; background-color: #f0f2f5; font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif;">
  <center style="width: 100%; background-color: #f0f2f5; padding: 32px 0;">
  <!--[if mso | IE]><table role="presentation" border="0" cellpadding="0" cellspacing="0" width="100%" style="background-color:#f0f2f5;"><tr><td><![endif]-->

    <table role="presentation" cellspacing="0" cellpadding="0" border="0" align="center" width="600" class="email-container" style="margin: auto; max-width: 600px;">

      <!-- BARRE D'ACCENT SUPÉRIEURE -->
      <tr>
        <td style="background-color: $accentColor; height: 5px; border-radius: 8px 8px 0 0; font-size: 0; line-height: 0;">&nbsp;</td>
      </tr>

      <!-- LOGO -->
      <tr>
        <td style="background-color: #ffffff; padding: 36px 40px 24px 40px; text-align: center; border-left: 1px solid #e8eaed; border-right: 1px solid #e8eaed;">
          <img src="https://softel.dz/softel_logo.PNG" alt="Logo Softel" width="160" style="max-width: 160px; height: auto; display: block; margin: 0 auto;">
        </td>
      </tr>

      <!-- BANDEAU DE STATUT -->
      <tr>
        <td style="background-color: #ffffff; padding: 0 40px; border-left: 1px solid #e8eaed; border-right: 1px solid #e8eaed;">
          <table role="presentation" cellspacing="0" cellpadding="0" border="0" width="100%">
            <tr>
              <td style="background-color: $accentColor; border-radius: 8px; padding: 18px 24px; text-align: center;">
                <p style="margin: 0; font-size: 11px; font-weight: 700; letter-spacing: 2px; text-transform: uppercase; color: #ffffff;">$statusLabel</p>
                <p style="margin: 8px 0 0 0; font-size: 20px; font-weight: 700; color: #ffffff; line-height: 1.3;">$statusMessage</p>
              </td>
            </tr>
          </table>
        </td>
      </tr>

      <!-- SALUTATION -->
      <tr>
        <td style="background-color: #ffffff; padding: 28px 40px 8px 40px; border-left: 1px solid #e8eaed; border-right: 1px solid #e8eaed;">
          <p style="margin: 0; font-size: 15px; color: #4b5563; line-height: 1.7;">
            Cher(e) <strong style="color: #111827;">${sub.clientName}</strong>,
          </p>
          <p style="margin: 12px 0 0 0; font-size: 15px; color: #4b5563; line-height: 1.7;">
            Ceci est un rappel concernant le statut de votre abonnement pour <strong style="color: #111827;">${sub.applicationName}</strong>. Veuillez consulter les informations ci-dessous et contacter notre équipe de support dans les meilleurs délais.
          </p>
        </td>
      </tr>

      <!-- TABLEAU DES DÉTAILS D'ABONNEMENT -->
      <tr>
        <td style="background-color: #ffffff; padding: 24px 40px; border-left: 1px solid #e8eaed; border-right: 1px solid #e8eaed;">
          <p style="margin: 0 0 14px 0; font-size: 11px; font-weight: 700; letter-spacing: 1.5px; text-transform: uppercase; color: #9ca3af;">Détails de l'Abonnement</p>

          <table role="presentation" cellspacing="0" cellpadding="0" border="0" width="100%" style="border: 1px solid #e8eaed; border-radius: 8px; overflow: hidden; border-collapse: separate;">
            <tr>
              <td style="padding: 14px 20px; background-color: #f9fafb; border-bottom: 1px solid #e8eaed; width: 42%;">
                <p style="margin: 0; font-size: 12px; font-weight: 600; text-transform: uppercase; letter-spacing: 0.5px; color: #6b7280;">Application</p>
              </td>
              <td style="padding: 14px 20px; background-color: #ffffff; border-bottom: 1px solid #e8eaed;">
                <p style="margin: 0; font-size: 14px; font-weight: 600; color: #111827;">${sub.applicationName}</p>
              </td>
            </tr>
            <tr>
              <td style="padding: 14px 20px; background-color: #f9fafb; border-bottom: 1px solid #e8eaed;">
                <p style="margin: 0; font-size: 12px; font-weight: 600; text-transform: uppercase; letter-spacing: 0.5px; color: #6b7280;">Numéro d'Appareil</p>
              </td>
              <td style="padding: 14px 20px; background-color: #ffffff; border-bottom: 1px solid #e8eaed;">
                <p style="margin: 0; font-size: 14px; font-weight: 600; color: #111827; font-family: 'Courier New', Courier, monospace; letter-spacing: 0.5px;">${sub.licensesCount} / ${sub.maxDevices}</p>
              </td>
            </tr>
            <tr>
              <td style="padding: 14px 20px; background-color: #f9fafb; border-bottom: 1px solid #e8eaed;">
                <p style="margin: 0; font-size: 12px; font-weight: 600; text-transform: uppercase; letter-spacing: 0.5px; color: #6b7280;">Date d'Expiration</p>
              </td>
              <td style="padding: 14px 20px; background-color: #ffffff; border-bottom: 1px solid #e8eaed;">
                <p style="margin: 0; font-size: 14px; font-weight: 600; color: #111827;">${sub.formattedExpiryDate}</p>
              </td>
            </tr>
            <tr>
              <td style="padding: 14px 20px; background-color: #f9fafb;">
                <p style="margin: 0; font-size: 12px; font-weight: 600; text-transform: uppercase; letter-spacing: 0.5px; color: #6b7280;">Jours Restants</p>
              </td>
              <td style="padding: 14px 20px; background-color: #ffffff;">
                <p style="margin: 0; font-size: 14px; font-weight: 700; color: $accentColor;">${sub.daysUntilExpiry} jours</p>
              </td>
            </tr>
          </table>
        </td>
      </tr>

      <!-- SÉPARATEUR -->
      <tr>
        <td style="background-color: #ffffff; padding: 0 40px; border-left: 1px solid #e8eaed; border-right: 1px solid #e8eaed;">
          <table role="presentation" cellspacing="0" cellpadding="0" border="0" width="100%">
            <tr><td style="border-top: 1px solid #e8eaed; font-size: 0; line-height: 0; height: 1px;">&nbsp;</td></tr>
          </table>
        </td>
      </tr>

      <!-- SECTION CONTACT SUPPORT -->
      <tr>
        <td style="background-color: #ffffff; padding: 28px 40px; border-left: 1px solid #e8eaed; border-right: 1px solid #e8eaed;">
          <p style="margin: 0 0 6px 0; font-size: 11px; font-weight: 700; letter-spacing: 1.5px; text-transform: uppercase; color: #9ca3af;">Besoin d'Aide ?</p>
          <p style="margin: 0 0 20px 0; font-size: 17px; font-weight: 700; color: #111827;">Contacter le Support</p>
          <p style="margin: 0 0 20px 0; font-size: 14px; color: #6b7280; line-height: 1.6;">Notre équipe est prête à vous assister. Contactez-nous via l'un des canaux suivants :</p>

          <table role="presentation" cellspacing="0" cellpadding="0" border="0" width="100%">
            <tr>
              <!-- WhatsApp -->
              <td style="padding: 0 6px 0 0;">
                <a href="https://wa.me/+213558925355" target="_blank" style="display: block; background-color: #25D366; border-radius: 8px; padding: 14px 16px; text-decoration: none; text-align: center;">
                  <table role="presentation" cellspacing="0" cellpadding="0" border="0" align="center">
                    <tr>
                      <td style="vertical-align: middle; padding-right: 8px;">
                        <img src="https://upload.wikimedia.org/wikipedia/commons/6/6b/WhatsApp.svg" alt="WhatsApp" width="18" height="18" style="display: block; width: 18px; height: 18px;">
                      </td>
                      <td style="vertical-align: middle;">
                        <span style="font-size: 13px; font-weight: 700; color: #ffffff; white-space: nowrap;">WhatsApp</span>
                      </td>
                    </tr>
                  </table>
                </a>
              </td>
              <!-- Téléphone -->
              <td style="padding: 0 6px;">
                <a href="tel:+213558925355" style="display: block; background-color: #f3f4f6; border: 1px solid #e5e7eb; border-radius: 8px; padding: 14px 16px; text-decoration: none; text-align: center;">
                  <table role="presentation" cellspacing="0" cellpadding="0" border="0" align="center">
                    <tr>
                      <td style="vertical-align: middle; padding-right: 8px; font-size: 16px;"><span>&#128222;</span></td>
                      <td style="vertical-align: middle;">
                        <span style="font-size: 13px; font-weight: 700; color: #374151; white-space: nowrap;">Nous Appeler</span>
                      </td>
                    </tr>
                  </table>
                </a>
              </td>
              <!-- E-mail -->
              <td style="padding: 0 0 0 6px;">
                <a href="mailto:sav.softel@gmail.com" style="display: block; background-color: #f3f4f6; border: 1px solid #e5e7eb; border-radius: 8px; padding: 14px 16px; text-decoration: none; text-align: center;">
                  <table role="presentation" cellspacing="0" cellpadding="0" border="0" align="center">
                    <tr>
                      <td style="vertical-align: middle; padding-right: 8px; font-size: 16px;"><span>&#9993;</span></td>
                      <td style="vertical-align: middle;">
                        <span style="font-size: 13px; font-weight: 700; color: #374151; white-space: nowrap;">Nous Écrire</span>
                      </td>
                    </tr>
                  </table>
                </a>
              </td>
            </tr>
          </table>

          <!-- Coordonnées -->
          <table role="presentation" cellspacing="0" cellpadding="0" border="0" width="100%" style="margin-top: 16px;">
            <tr>
              <td style="padding: 14px 16px; background-color: #f9fafb; border-radius: 6px; border-left: 3px solid $accentColor;">
                <p style="margin: 0; font-size: 12px; color: #6b7280; line-height: 1.8;">
                  <strong style="color: #374151;">WhatsApp / Tél. 1 :</strong> <a href="tel:+213558925355" style="color: #374151; text-decoration: none;">+213 558 925 355</a><br>
                  <strong style="color: #374151;">Tél. 2 :</strong> <a href="tel:+213798757380" style="color: #374151; text-decoration: none;">+213 798 757 380</a><br>
                  <strong style="color: #374151;">E-mail :</strong> <a href="mailto:sav.softel@gmail.com" style="color: $accentColor; text-decoration: none;">sav.softel@gmail.com</a><br>
                  <strong style="color: #374151;">Horaires :</strong> Dimanche – Jeudi, 8h00 – 17h00 (GMT+1)
                </p>
              </td>
            </tr>
          </table>
        </td>
      </tr>

      <!-- PIED DE PAGE -->
      <tr>
        <td style="background-color: #1f2937; padding: 28px 40px; border-radius: 0 0 8px 8px; text-align: center;">
          <img src="https://softel.dz/softel_logo.PNG" alt="Softel" width="100" style="max-width: 100px; height: auto; display: block; margin: 0 auto 16px auto; opacity: 0.7;">
          <p style="margin: 0 0 8px 0; font-size: 12px; color: #9ca3af; line-height: 1.6;">
            <a href="https://softel.dz" style="color: #d1d5db; text-decoration: none;">softel.dz</a>
            &nbsp;&bull;&nbsp;
            <a href="mailto:sav.softel@gmail.com" style="color: #d1d5db; text-decoration: none;">sav.softel@gmail.com</a>
          </p>
          <p style="margin: 0 0 8px 0; font-size: 11px; color: #6b7280; line-height: 1.6;">
            Ceci est une notification automatique. Merci de ne pas répondre directement à cet e-mail.
          </p>
          <p style="margin: 0; font-size: 11px; color: #4b5563;">
            &copy; $currentYear Softel. Tous droits réservés.
          </p>
        </td>
      </tr>

    </table>

  <!--[if mso | IE]></td></tr></table><![endif]-->
  </center>
</body>
</html>""";

    final message = Message()
      ..from = Address(username, 'Softel')
      ..recipients.add(sub.clientEmail)
      ..subject = subject
      ..html = body;

    try {
      await send(message, smtpServer);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to send email to ${sub.clientName}: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    }
  }

  Future<void> sendEmailCreationSubscribe(SubscriptionModel sub) async {
    if (sub.clientEmail.isEmpty) {
      Get.snackbar('Error', 'Client ${sub.clientName} has no email');
      return;
    }

    final username = 'SavSoftel@gmail.com';
    final password = 'nxex olun rata simu';
    final smtpServer = gmail(username, password);

    final String subject = "Abonnement Activé – ${sub.applicationName}";
    final int currentYear = DateTime.now().year;

    final String body =
        """<!DOCTYPE html>
<html lang="fr" xmlns="http://www.w3.org/1999/xhtml" xmlns:v="urn:schemas-microsoft-com:vml" xmlns:o="urn:schemas-microsoft-com:office:office">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta http-equiv="X-UA-Compatible" content="IE=edge">
  <meta name="x-apple-disable-message-reformatting">
  <title>Abonnement Activé – Softel</title>
  <!--[if mso]>
  <noscript><xml><o:OfficeDocumentSettings><o:PixelsPerInch>96</o:PixelsPerInch></o:OfficeDocumentSettings></xml></noscript>
  <![endif]-->
  <style>
    body, table, td, a { -webkit-text-size-adjust: 100%; -ms-text-size-adjust: 100%; }
    table, td { mso-table-lspace: 0pt; mso-table-rspace: 0pt; }
    img { -ms-interpolation-mode: bicubic; border: 0; height: auto; line-height: 100%; outline: none; text-decoration: none; }
    body { margin: 0 !important; padding: 0 !important; width: 100% !important; background-color: #f0f2f5; }
    a[x-apple-data-detectors] { color: inherit !important; text-decoration: none !important; }
    @media screen and (max-width: 600px) {
      .email-container { width: 100% !important; }
      .stack-column { display: block !important; width: 100% !important; max-width: 100% !important; }
      .stat-cell { display: block !important; width: 100% !important; padding: 16px 20px !important; border-right: none !important; border-bottom: 1px solid #e8eaed !important; }
    }
  </style>
</head>

<body width="100%" style="margin: 0; padding: 0 !important; background-color: #f0f2f5; font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif;">
  <center style="width: 100%; background-color: #f0f2f5; padding: 32px 0;">
  <!--[if mso | IE]><table role="presentation" border="0" cellpadding="0" cellspacing="0" width="100%" style="background-color:#f0f2f5;"><tr><td><![endif]-->

    <table role="presentation" cellspacing="0" cellpadding="0" border="0" align="center" width="600" class="email-container" style="margin: auto; max-width: 600px;">

      <!-- TOP ACCENT BAR — green for success -->
      <tr>
        <td style="background: linear-gradient(90deg, #059669 0%, #10b981 50%, #34d399 100%); height: 5px; border-radius: 8px 8px 0 0; font-size: 0; line-height: 0;">&nbsp;</td>
      </tr>

      <!-- LOGO -->
      <tr>
        <td style="background-color: #ffffff; padding: 36px 40px 24px 40px; text-align: center; border-left: 1px solid #e8eaed; border-right: 1px solid #e8eaed;">
          <img src="https://softel.dz/softel_logo.PNG" alt="Logo Softel" width="150" style="max-width: 150px; height: auto; display: block; margin: 0 auto;">
        </td>
      </tr>

      <!-- SUCCESS HERO BANNER -->
      <tr>
        <td style="background-color: #ffffff; padding: 0 40px 0 40px; border-left: 1px solid #e8eaed; border-right: 1px solid #e8eaed;">
          <table role="presentation" cellspacing="0" cellpadding="0" border="0" width="100%">
            <tr>
              <td style="background: linear-gradient(135deg, #064e3b 0%, #065f46 40%, #047857 100%); border-radius: 12px; padding: 32px 28px; text-align: center;">

                <!-- Checkmark circle -->
                <table role="presentation" cellspacing="0" cellpadding="0" border="0" align="center" style="margin-bottom: 16px;">
                  <tr>
                    <td style="width: 56px; height: 56px; background-color: rgba(52,211,153,0.2); border-radius: 50%; text-align: center; vertical-align: middle; border: 2px solid rgba(52,211,153,0.4);">
                      <span style="font-size: 28px; line-height: 52px; display: block;">✓</span>
                    </td>
                  </tr>
                </table>

                <p style="margin: 0 0 6px 0; font-size: 11px; font-weight: 700; letter-spacing: 2.5px; text-transform: uppercase; color: #6ee7b7;">Abonnement Créé</p>
                <p style="margin: 0 0 10px 0; font-size: 24px; font-weight: 800; color: #ffffff; line-height: 1.25; letter-spacing: -0.3px;">Votre accès est prêt !</p>
                <p style="margin: 0; font-size: 14px; color: #a7f3d0; line-height: 1.6;">
                  Votre abonnement a été créé avec succès.<br>Le décompte démarre dès la première connexion sur chaque appareil.
                </p>
              </td>
            </tr>
          </table>
        </td>
      </tr>

      <!-- GREETING -->
      <tr>
        <td style="background-color: #ffffff; padding: 28px 40px 8px 40px; border-left: 1px solid #e8eaed; border-right: 1px solid #e8eaed;">
          <p style="margin: 0; font-size: 15px; color: #4b5563; line-height: 1.7;">
            Cher(e) <strong style="color: #111827;">${sub.clientName}</strong>,
          </p>
          <p style="margin: 12px 0 0 0; font-size: 15px; color: #4b5563; line-height: 1.7;">
            Nous avons le plaisir de vous confirmer la création de votre abonnement pour <strong style="color: #111827;">${sub.applicationName}</strong>. Retrouvez ci-dessous le récapitulatif complet de votre licence.
          </p>
        </td>
      </tr>

      <!-- LICENCE KEY — HERO CARD -->
      <tr>
        <td style="background-color: #ffffff; padding: 8px 40px 28px 40px; border-left: 1px solid #e8eaed; border-right: 1px solid #e8eaed;">
          <table role="presentation" cellspacing="0" cellpadding="0" border="0" width="100%">
            <tr>
              <td style="background: linear-gradient(135deg, #0f172a 0%, #1e293b 60%, #0f2744 100%); border-radius: 14px; padding: 28px 28px 24px 28px; text-align: center; position: relative;">

                <!-- Label -->
                <p style="margin: 0 0 4px 0; font-size: 10px; font-weight: 700; letter-spacing: 2.5px; text-transform: uppercase; color: #64748b;">🔑 Clé de Licence</p>
                <p style="margin: 0 0 18px 0; font-size: 12px; color: #94a3b8; line-height: 1.5;">
                  Utilisez cette clé pour activer l'application sur chacun de vos appareils.
                </p>

                <!-- The key itself -->
                <table role="presentation" cellspacing="0" cellpadding="0" border="0" align="center" style="margin: 0 auto 18px auto;">
                  <tr>
                    <td style="background-color: #0f172a; border: 1.5px solid #334155; border-radius: 10px; padding: 16px 28px;">
                      <p style="margin: 0; font-size: 22px; font-weight: 800; color: #f0fdf4; font-family: 'Courier New', Courier, monospace; letter-spacing: 3px; word-break: break-all;">${sub.licenseKey}</p>
                    </td>
                  </tr>
                </table>

                <!-- Decorative dots row -->
                <table role="presentation" cellspacing="0" cellpadding="0" border="0" align="center">
                  <tr>
                    <td style="width: 8px; height: 8px; background-color: #10b981; border-radius: 50; margin: 0 4px;">&nbsp;</td>
                    <td style="width: 6px;">&nbsp;</td>
                    <td style="width: 8px; height: 8px; background-color: #059669; border-radius: 50%; opacity: 0.6;">&nbsp;</td>
                    <td style="width: 6px;">&nbsp;</td>
                    <td style="width: 8px; height: 8px; background-color: #047857; border-radius: 50%; opacity: 0.35;">&nbsp;</td>
                  </tr>
                </table>

                <!-- Warning note -->
                <p style="margin: 16px 0 0 0; font-size: 11px; color: #475569; line-height: 1.6;">
                  ⚠️ &nbsp;Ne partagez jamais cette clé. Elle est strictement personnelle et liée à votre compte.
                </p>
              </td>
            </tr>
          </table>
        </td>
      </tr>

      <!-- SUBSCRIPTION DETAILS TABLE -->
      <tr>
        <td style="background-color: #ffffff; padding: 0 40px 24px 40px; border-left: 1px solid #e8eaed; border-right: 1px solid #e8eaed;">
          <p style="margin: 0 0 14px 0; font-size: 11px; font-weight: 700; letter-spacing: 1.5px; text-transform: uppercase; color: #9ca3af;">Détails de l'Abonnement</p>

          <table role="presentation" cellspacing="0" cellpadding="0" border="0" width="100%" style="border: 1px solid #e8eaed; border-radius: 10px; overflow: hidden; border-collapse: separate;">

            <!-- Application -->
            <tr>
              <td style="padding: 14px 20px; background-color: #f9fafb; border-bottom: 1px solid #e8eaed; width: 44%;">
                <p style="margin: 0; font-size: 12px; font-weight: 600; text-transform: uppercase; letter-spacing: 0.5px; color: #6b7280;">Application</p>
              </td>
              <td style="padding: 14px 20px; background-color: #ffffff; border-bottom: 1px solid #e8eaed;">
                <p style="margin: 0; font-size: 14px; font-weight: 700; color: #111827;">${sub.applicationName}</p>
              </td>
            </tr>

            <!-- Client -->
            <tr>
              <td style="padding: 14px 20px; background-color: #f9fafb; border-bottom: 1px solid #e8eaed;">
                <p style="margin: 0; font-size: 12px; font-weight: 600; text-transform: uppercase; letter-spacing: 0.5px; color: #6b7280;">Client</p>
              </td>
              <td style="padding: 14px 20px; background-color: #ffffff; border-bottom: 1px solid #e8eaed;">
                <p style="margin: 0; font-size: 14px; font-weight: 600; color: #111827;">${sub.clientName}</p>
              </td>
            </tr>

            <!-- Number of devices -->
            <tr>
              <td style="padding: 14px 20px; background-color: #f9fafb; border-bottom: 1px solid #e8eaed;">
                <p style="margin: 0; font-size: 12px; font-weight: 600; text-transform: uppercase; letter-spacing: 0.5px; color: #6b7280;">Nombre d'Appareils</p>
              </td>
              <td style="padding: 14px 20px; background-color: #ffffff; border-bottom: 1px solid #e8eaed;">
                <table role="presentation" cellspacing="0" cellpadding="0" border="0">
                  <tr>
                    <td style="background-color: #ecfdf5; border: 1px solid #a7f3d0; border-radius: 6px; padding: 4px 10px;">
                      <span style="font-size: 14px; font-weight: 700; color: #065f46;">📱 ${sub.maxDevices} appareils</span>
                    </td>
                  </tr>
                </table>
              </td>
            </tr>

            <!-- Duration -->
            <tr>
              <td style="padding: 14px 20px; background-color: #f9fafb; border-bottom: 1px solid #e8eaed;">
                <p style="margin: 0; font-size: 12px; font-weight: 600; text-transform: uppercase; letter-spacing: 0.5px; color: #6b7280;">Durée de Validité</p>
              </td>
              <td style="padding: 14px 20px; background-color: #ffffff; border-bottom: 1px solid #e8eaed;">
                <table role="presentation" cellspacing="0" cellpadding="0" border="0">
                  <tr>
                    <td style="background-color: #eff6ff; border: 1px solid #bfdbfe; border-radius: 6px; padding: 4px 10px;">
                      <span style="font-size: 14px; font-weight: 700; color: #1e40af;">⏱ ${sub.durationMonths} mois</span>
                    </td>
                  </tr>
                </table>
              </td>
            </tr>

            <!-- Creation date -->
            <tr>
              <td style="padding: 14px 20px; background-color: #f9fafb;">
                <p style="margin: 0; font-size: 12px; font-weight: 600; text-transform: uppercase; letter-spacing: 0.5px; color: #6b7280;">Date de Création</p>
              </td>
              <td style="padding: 14px 20px; background-color: #ffffff;">
                <p style="margin: 0; font-size: 14px; font-weight: 600; color: #111827;">${sub.formattedCreationDate}</p>
              </td>
            </tr>

          </table>
        </td>
      </tr>

      <!-- HOW IT WORKS — the deferred countdown explanation -->
      <tr>
        <td style="background-color: #ffffff; padding: 0 40px 28px 40px; border-left: 1px solid #e8eaed; border-right: 1px solid #e8eaed;">
          <p style="margin: 0 0 14px 0; font-size: 11px; font-weight: 700; letter-spacing: 1.5px; text-transform: uppercase; color: #9ca3af;">Comment ça fonctionne ?</p>

          <table role="presentation" cellspacing="0" cellpadding="0" border="0" width="100%" style="border: 1px solid #dbeafe; border-radius: 10px; overflow: hidden; background-color: #f8faff; border-collapse: separate;">
            <tr>
              <td style="padding: 24px 24px 8px 24px;">
                <p style="margin: 0; font-size: 15px; font-weight: 700; color: #1e3a5f;">⚡ Décompte Intelligent par Appareil</p>
              </td>
            </tr>
            <tr>
              <td style="padding: 8px 24px 24px 24px;">
                <p style="margin: 0; font-size: 13px; color: #374151; line-height: 1.75;">
                  Votre abonnement couvre <strong style="color: #1d4ed8;">${sub.maxDevices} appareils</strong> pour une durée de <strong style="color: #1d4ed8;">${sub.durationMonths} mois</strong> chacun.<br><br>
                  Le décompte de chaque appareil <strong>ne démarre pas immédiatement</strong> — il se déclenche uniquement lors de la <strong>première connexion</strong> de cet appareil avec votre clé de licence.<br><br>
                  Cela signifie que vous pouvez activer vos appareils à votre rythme, sans perdre de temps d'abonnement.
                </p>
              </td>
            </tr>

            <!-- 3-step visual -->
            <tr>
              <td style="padding: 0 24px 24px 24px;">
                <table role="presentation" cellspacing="0" cellpadding="0" border="0" width="100%">
                  <tr>

                    <!-- Step 1 -->
                    <td class="stat-cell" style="width: 33%; text-align: center; padding: 16px 8px; border-right: 1px solid #dbeafe; vertical-align: top;">
                      <div style="width: 36px; height: 36px; background: linear-gradient(135deg, #3b82f6, #1d4ed8); border-radius: 50%; margin: 0 auto 10px auto; text-align: center; line-height: 36px; font-size: 16px; color: #fff;">1</div>
                      <p style="margin: 0 0 4px 0; font-size: 12px; font-weight: 700; color: #1e3a5f;">Abonnement Créé</p>
                      <p style="margin: 0; font-size: 11px; color: #6b7280; line-height: 1.5;">Votre licence est active et en attente d'activation.</p>
                    </td>

                    <!-- Step 2 -->
                    <td class="stat-cell" style="width: 33%; text-align: center; padding: 16px 8px; border-right: 1px solid #dbeafe; vertical-align: top;">
                      <div style="width: 36px; height: 36px; background: linear-gradient(135deg, #8b5cf6, #6d28d9); border-radius: 50%; margin: 0 auto 10px auto; text-align: center; line-height: 36px; font-size: 16px; color: #fff;">2</div>
                      <p style="margin: 0 0 4px 0; font-size: 12px; font-weight: 700; color: #1e3a5f;">Première Connexion</p>
                      <p style="margin: 0; font-size: 11px; color: #6b7280; line-height: 1.5;">L'appareil se connecte pour la 1ère fois — le compteur démarre.</p>
                    </td>

                    <!-- Step 3 -->
                    <td class="stat-cell" style="width: 33%; text-align: center; padding: 16px 8px; vertical-align: top;">
                      <div style="width: 36px; height: 36px; background: linear-gradient(135deg, #059669, #047857); border-radius: 50%; margin: 0 auto 10px auto; text-align: center; line-height: 36px; font-size: 16px; color: #fff;">3</div>
                      <p style="margin: 0 0 4px 0; font-size: 12px; font-weight: 700; color: #1e3a5f;">Expiration</p>
                      <p style="margin: 0; font-size: 11px; color: #6b7280; line-height: 1.5;">Après ${sub.durationMonths} mois d'utilisation par appareil.</p>
                    </td>

                  </tr>
                </table>
              </td>
            </tr>

          </table>
        </td>
      </tr>

      <!-- DIVIDER -->
      <tr>
        <td style="background-color: #ffffff; padding: 0 40px; border-left: 1px solid #e8eaed; border-right: 1px solid #e8eaed;">
          <table role="presentation" cellspacing="0" cellpadding="0" border="0" width="100%">
            <tr><td style="border-top: 1px solid #e8eaed; font-size: 0; line-height: 0; height: 1px;">&nbsp;</td></tr>
          </table>
        </td>
      </tr>

      <!-- SECURITY TIP -->
      <tr>
        <td style="background-color: #fffbeb; padding: 22px 40px; border-left: 1px solid #e8eaed; border-right: 1px solid #e8eaed; border-top: 1px solid #fde68a;">
          <table role="presentation" cellspacing="0" cellpadding="0" border="0" width="100%">
            <tr>
              <td style="vertical-align: top; width: 36px; padding-right: 14px;">
                <div style="width: 34px; height: 34px; background-color: #f59e0b; border-radius: 50%; text-align: center; line-height: 34px; font-size: 16px;">🔒</div>
              </td>
              <td style="vertical-align: top;">
                <p style="margin: 0 0 4px 0; font-size: 13px; font-weight: 700; color: #92400e;">Conseil Sécurité — Protégez votre Clé de Licence</p>
                <p style="margin: 0; font-size: 13px; color: #78350f; line-height: 1.6;">
                  Votre clé de licence est strictement personnelle. Ne la partagez jamais publiquement ni avec des tiers non autorisés. En cas de compromission, contactez notre support immédiatement.
                </p>
              </td>
            </tr>
          </table>
        </td>
      </tr>

      <!-- CONTACT SUPPORT SECTION -->
      <tr>
        <td style="background-color: #ffffff; padding: 28px 40px; border-left: 1px solid #e8eaed; border-right: 1px solid #e8eaed;">
          <p style="margin: 0 0 6px 0; font-size: 11px; font-weight: 700; letter-spacing: 1.5px; text-transform: uppercase; color: #9ca3af;">Besoin d'Aide ?</p>
          <p style="margin: 0 0 20px 0; font-size: 17px; font-weight: 700; color: #111827;">Contacter le Support</p>

          <table role="presentation" cellspacing="0" cellpadding="0" border="0" width="100%">
            <tr>
              <!-- WhatsApp -->
              <td style="padding: 0 6px 0 0;">
                <a href="https://wa.me/+213558925355" target="_blank" style="display: block; background-color: #25D366; border-radius: 8px; padding: 13px 14px; text-decoration: none; text-align: center;">
                  <table role="presentation" cellspacing="0" cellpadding="0" border="0" align="center">
                    <tr>
                      <td style="vertical-align: middle; padding-right: 7px;">
                        <img src="https://upload.wikimedia.org/wikipedia/commons/6/6b/WhatsApp.svg" alt="WhatsApp" width="17" height="17" style="display: block;">
                      </td>
                      <td style="vertical-align: middle;">
                        <span style="font-size: 13px; font-weight: 700; color: #ffffff; white-space: nowrap;">WhatsApp</span>
                      </td>
                    </tr>
                  </table>
                </a>
              </td>
              <!-- Téléphone -->
              <td style="padding: 0 6px;">
                <a href="tel:+213558925355" style="display: block; background-color: #f3f4f6; border: 1px solid #e5e7eb; border-radius: 8px; padding: 13px 14px; text-decoration: none; text-align: center;">
                  <table role="presentation" cellspacing="0" cellpadding="0" border="0" align="center">
                    <tr>
                      <td style="vertical-align: middle; padding-right: 7px; font-size: 15px;"><span>📞</span></td>
                      <td style="vertical-align: middle;">
                        <span style="font-size: 13px; font-weight: 700; color: #374151; white-space: nowrap;">Nous Appeler</span>
                      </td>
                    </tr>
                  </table>
                </a>
              </td>
              <!-- E-mail -->
              <td style="padding: 0 0 0 6px;">
                <a href="mailto:sav.softel@gmail.com" style="display: block; background-color: #f3f4f6; border: 1px solid #e5e7eb; border-radius: 8px; padding: 13px 14px; text-decoration: none; text-align: center;">
                  <table role="presentation" cellspacing="0" cellpadding="0" border="0" align="center">
                    <tr>
                      <td style="vertical-align: middle; padding-right: 7px; font-size: 15px;"><span>✉️</span></td>
                      <td style="vertical-align: middle;">
                        <span style="font-size: 13px; font-weight: 700; color: #374151; white-space: nowrap;">Nous Écrire</span>
                      </td>
                    </tr>
                  </table>
                </a>
              </td>
            </tr>
          </table>

          <!-- Contact details card -->
          <table role="presentation" cellspacing="0" cellpadding="0" border="0" width="100%" style="margin-top: 16px;">
            <tr>
              <td style="padding: 14px 16px; background-color: #f9fafb; border-radius: 6px; border-left: 3px solid #059669;">
                <p style="margin: 0; font-size: 12px; color: #6b7280; line-height: 1.9;">
                  <strong style="color: #374151;">WhatsApp / Tél. 1 :</strong> <a href="tel:+213558925355" style="color: #374151; text-decoration: none;">+213 558 925 355</a><br>
                  <strong style="color: #374151;">Tél. 2 :</strong> <a href="tel:+213798757380" style="color: #374151; text-decoration: none;">+213 798 757 380</a><br>
                  <strong style="color: #374151;">E-mail :</strong> <a href="mailto:sav.softel@gmail.com" style="color: #059669; text-decoration: none;">sav.softel@gmail.com</a><br>
                  <strong style="color: #374151;">Horaires :</strong> Dimanche – Jeudi, 8h00 – 17h00 (GMT+1)
                </p>
              </td>
            </tr>
          </table>
        </td>
      </tr>

      <!-- FOOTER -->
      <tr>
        <td style="background-color: #1f2937; padding: 28px 40px; border-radius: 0 0 8px 8px; text-align: center;">
          <img src="https://softel.dz/softel_logo.PNG" alt="Softel" width="100" style="max-width: 100px; height: auto; display: block; margin: 0 auto 16px auto; opacity: 0.7;">
          <p style="margin: 0 0 8px 0; font-size: 12px; color: #9ca3af; line-height: 1.6;">
            <a href="https://softel.dz" style="color: #d1d5db; text-decoration: none;">softel.dz</a>
            &nbsp;&bull;&nbsp;
            <a href="mailto:sav.softel@gmail.com" style="color: #d1d5db; text-decoration: none;">sav.softel@gmail.com</a>
          </p>
          <p style="margin: 0 0 8px 0; font-size: 11px; color: #6b7280; line-height: 1.6;">
            Ceci est une notification automatique. Merci de ne pas répondre directement à cet e-mail.
          </p>
          <p style="margin: 0; font-size: 11px; color: #4b5563;">
            &copy; $currentYear Softel. Tous droits réservés.
          </p>
        </td>
      </tr>

    </table>

  <!--[if mso | IE]></td></tr></table><![endif]-->
  </center>
</body>
</html>""";

    final message = Message()
      ..from = Address(username, 'Softel')
      ..recipients.add(sub.clientEmail)
      ..subject = subject
      ..html = body;

    try {
      await send(message, smtpServer);
      Get.snackbar(
        'Success',
        'Creation email sent to ${sub.clientName}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to send email to ${sub.clientName}: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    }
  }

  // Copy license key

  void copyLicenseKey(String licenseKey) {
    Clipboard.setData(ClipboardData(text: licenseKey));
    Get.snackbar(
      'Success',
      'License key copied to clipboard',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void openLicenses(SubscriptionModel subscription) async {
    int licenceCount = await Get.to(
      () => LicensesView(),
      arguments: {"subscription": subscription},
      transition: Transition.rightToLeftWithFade,

      duration: Duration(milliseconds: 300),
    );

    subscription.licensesCount.value = licenceCount;
  }

  // Add Subscription

  Future<void> addSubscription(SubscriptionModel subscription) async {
    try {
      var response = await authPost(
        AppLink.subscriptions,
        subscription.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar(
          "Success",
          "Subscription added",
          snackPosition: SnackPosition.BOTTOM,
        );
        await loadSubscriptions();
      } else {
        Get.snackbar(
          "Error",
          "Failed to add: ${response.body}",
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Exception: $e",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Edit Subscription

  Future<void> editSubscription(
    SubscriptionModel subscription, {
    bool loadSubscription = true,
  }) async {
    try {
      var response = await authPut(
        "${AppLink.subscriptions}/${subscription.id}",
        subscription.toJson(),
      );

      if (response.statusCode == 200) {
        Get.snackbar(
          "Success",
          "Subscription updated",
          snackPosition: SnackPosition.BOTTOM,
        );
        if (loadSubscription) await loadSubscriptions();
      } else {
        Get.snackbar(
          "Error",
          "Failed to update: ${response.body}",
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Exception: $e",
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {}
  }

  // Delete subscription

  Future<void> deleteSubscription(SubscriptionModel subscription) async {
    try {
      // API Call
      var response = await authDelete(
        "${AppLink.subscriptions}/${subscription.id}",
        {},
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        subscriptions.removeWhere((sub) => sub.id == subscription.id);
        applyFilters();

        Get.snackbar(
          'Success',
          'Subscription deleted successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar(
          'Error',
          'Failed to delete: ${response.statusCode}',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Exception deleting subscription: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
