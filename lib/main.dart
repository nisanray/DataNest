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
    final base = ThemeData.light();
    final customTheme = base.copyWith(
      colorScheme: base.colorScheme.copyWith(
        primary: const Color(0xFF6C63FF), // Soft Indigo
        secondary: const Color(0xFF5EEAD4), // Pastel Teal
        background: const Color(0xFFF8FAFC), // Very light background
        surface: Colors.white,
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onBackground: Colors.black,
        onSurface: Colors.black,
        error: const Color(0xFFF87171), // Soft red
      ),
      scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF6C63FF),
        foregroundColor: Colors.white,
        elevation: 1.5,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 22,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      cardTheme: CardTheme(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
        shadowColor: Colors.black12,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFF6C63FF),
        foregroundColor: Colors.white,
        shape: StadiumBorder(),
        elevation: 2,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Color(0xFF6C63FF), width: 2),
        ),
        labelStyle: const TextStyle(color: Color(0xFF6C63FF)),
        fillColor: Color(0xFFF1F5F9),
        filled: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6C63FF),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          elevation: 1.5,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF6C63FF),
          side: const BorderSide(color: Color(0xFF6C63FF)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        fillColor: MaterialStateProperty.all(const Color(0xFF6C63FF)),
        checkColor: MaterialStateProperty.all(Colors.white),
        side: const BorderSide(color: Color(0xFF6C63FF), width: 1.5),
      ),
      dialogTheme: DialogTheme(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        titleTextStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
          color: Color(0xFF1E293B),
        ),
        contentTextStyle: TextStyle(
          fontSize: 15,
          color: Colors.grey[800],
        ),
      ),
      textTheme: base.textTheme.copyWith(
        titleLarge: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 22,
          color: Color(0xFF1E293B),
          letterSpacing: 0.5,
        ),
        titleMedium: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 18,
          color: Color(0xFF1E293B),
        ),
        bodyMedium: const TextStyle(
          fontSize: 15,
          color: Color(0xFF334155),
        ),
        bodySmall: const TextStyle(
          fontSize: 13,
          color: Color(0xFF64748B),
        ),
        labelLarge: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
          color: Color(0xFF6C63FF),
        ),
      ),
      iconTheme: const IconThemeData(color: Color(0xFF6C63FF)),
      dividerTheme: const DividerThemeData(
        color: Color(0xFFE0E7EF),
        thickness: 1,
        space: 1,
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: Color(0xFF6C63FF),
        contentTextStyle:
            TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12))),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Color(0xFFF8FAFC),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
    );
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DataNest',
      theme: customTheme,
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
