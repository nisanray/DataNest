import 'package:datanest/views/sign_in_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../main.dart';
import '../services/sync_service.dart';

class AuthGate extends StatefulWidget {
  @override
  State<AuthGate> createState() => AuthGateState();
}

class AuthGateState extends State<AuthGate> {
  bool _isSyncing = false;
  bool _syncDone = false;
  String? _userId;
  Stream<User?>? _authStream;
  bool isNewUser = false;

  @override
  void initState() {
    super.initState();
    _authStream = FirebaseAuth.instance.authStateChanges();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _authStream?.listen((user) async {
      debugPrint('[AUTH] Auth state changed: ${user?.uid}');
      if (user != null && _userId != user.uid) {
        setState(() {
          _isSyncing = true;
          _syncDone = false;
          _userId = user.uid;
        });
        debugPrint('[AUTH] User signed in: ${user.uid}');
        Get.put(SyncStatusController(user.uid), permanent: true);
        if (isNewUser) {
          // New user: clear all Hive boxes, do NOT sync from Firebase
          await SyncService(userId: user.uid).onUserSignUp();
        } else {
          // Existing user: clear all Hive boxes, download all from Firebase, mark as synced
          await SyncService(userId: user.uid).clearAllHiveBoxes();
          await SyncService(userId: user.uid).syncFromFirebase();
        }
        // Immediately navigate to home for offline-first UX
        Future.microtask(() => Get.offAllNamed('/home'));
        // Start background sync (auto-upload unsynced data when online)
        Future.microtask(() async {
          await SyncService(userId: user.uid).backgroundSync();
        });
      } else if (user == null) {
        debugPrint('[AUTH] User signed out');
        setState(() {
          _userId = null;
          _syncDone = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _authStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting || _isSyncing) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }
        return SignInView();
      },
    );
  }
}
