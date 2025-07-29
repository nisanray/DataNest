import 'package:datanest/firebase_options.dart';
import 'package:datanest/views/onboarding_screen.dart';
import 'package:datanest/views/splash_screen.dart';
import 'views/auth_gate.dart';
import 'views/hive_data_viewer_page.dart';
import 'views/home_view.dart';
import 'views/task_list_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'services/sync_service.dart';
import 'package:flutter/foundation.dart';

class SyncStatusController extends GetxController {
  final String userId;
  var isSyncing = false.obs;
  var hasUnsynced = false.obs;
  late final SyncService syncService;
  // Removed unused _connectivity field

  SyncStatusController(this.userId) {
    syncService = SyncService(userId: userId);
    Connectivity().onConnectivityChanged.listen((result) async {
      if (result != ConnectivityResult.none) {
        await refreshAllData();
      }
    });
  }

  // Centralized refresh function - syncs from Firebase to Hive
  Future<void> refreshAllData() async {
    isSyncing.value = true;
    try {
      await syncService.onConnectivityRestored();
      // After sync, all UI will automatically update via ValueListenableBuilder
        labelStyle: const TextStyle(color: Color(0xFF6C63FF)),
          splashFactory: InkRipple.splashFactory,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF6C63FF),
          side: const BorderSide(color: Color(0xFF6C63FF)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        fillColor: MaterialStateProperty.all(const Color(0xFF6C63FF)),
        checkColor: MaterialStateProperty.all(Colors.white),
        side: const BorderSide(color: Color(0xFF6C63FF), width: 1.5),
