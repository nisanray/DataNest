import 'package:datanest/firebase_options.dart';
import 'package:datanest/views/onboarding_screen.dart';
import 'package:datanest/views/splash_screen.dart';
import 'views/auth_gate.dart';
import 'views/hive_data_viewer_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'models/section_model.dart';
import 'models/record_model.dart';
import 'models/field_model.dart';
import 'models/task_model.dart';
import 'views/home_view.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'services/sync_service.dart';
import 'package:flutter/foundation.dart';
import 'views/task_list_view.dart';
import 'app_constants.dart';

class SyncStatusController extends GetxController {
  final String userId;
  var isSyncing = false.obs;
  var hasUnsynced = false.obs;
  late final SyncService syncService;
  late final Connectivity _connectivity;

  SyncStatusController(this.userId) {
    syncService = SyncService(userId: userId);
    _connectivity = Connectivity();
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
      // No need to manually refresh controllers or UI
    } catch (e) {
      print('Error refreshing data: $e');
    } finally {
      isSyncing.value = false;
    }
  }

  Future<void> syncNow() async {
    await refreshAllData();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Hive.initFlutter();
  Hive.registerAdapter(SectionAdapter());
  Hive.registerAdapter(RecordAdapter());
  Hive.registerAdapter(FieldAdapter()); // Register FieldAdapter
  Hive.registerAdapter(TaskAdapter());
  Hive.registerAdapter(SubTaskAdapter());
  await Hive.openBox<Section>('sections');
  await Hive.openBox<Record>('records');
  await Hive.openBox<Field>('fields'); // Open fields box
  await Hive.openBox<Task>('tasks');

  // If user is already logged in, you can manually trigger sync if needed
  // final currentUser = FirebaseAuth.instance.currentUser;
  // if (currentUser != null) {
  //   await SyncService(userId: currentUser.uid).onAppLaunchLoggedIn();
  // }

  final prefs = await SharedPreferences.getInstance();
  final onboardingSeen = prefs.getBool('onboardingSeen') ?? false;
  runApp(DataNestApp(onboardingSeen: onboardingSeen));
}

class DataNestApp extends StatelessWidget {
  final bool onboardingSeen;
  const DataNestApp({Key? key, required this.onboardingSeen}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DataNest',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      initialRoute: onboardingSeen ? '/' : '/onboarding',
      getPages: [
        GetPage(name: '/onboarding', page: () => OnboardingScreen()),
        GetPage(name: '/', page: () => SplashScreen()),
        GetPage(name: '/auth', page: () => AuthGate()),
        GetPage(name: '/hive-data-viewer', page: () => HiveDataViewerPage()),
        GetPage(
            name: '/home',
            page: () =>
                HomeView(userId: FirebaseAuth.instance.currentUser?.uid ?? '')),
        GetPage(
            name: '/tasks',
            page: () => TaskListView(
                userId: FirebaseAuth.instance.currentUser?.uid ?? '')),
      ],
    );
  }
}
