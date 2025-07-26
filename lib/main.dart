import 'package:datanest/firebase_options.dart';
import 'views/hive_data_viewer_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
  await Firebase.initializeApp();

  runApp(const DataNestApp());
}

class DataNestApp extends StatelessWidget {
  const DataNestApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DataNest',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      initialRoute: '/',
      getPages: [
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

class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late Animation<double> _logoAnimation;
  late AnimationController _textController;
  late Animation<double> _textAnimation;

  @override
  void initState() {
    super.initState();
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _logoAnimation = CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeOutBack,
    );
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _textAnimation = CurvedAnimation(
      parent: _textController,
      curve: Curves.easeIn,
    );

    _logoController.forward();
    Future.delayed(const Duration(milliseconds: 700), () {
      _textController.forward();
    });
    Future.delayed(const Duration(seconds: 2), () {
      // Navigate to AuthGate after splash
      Get.offAllNamed('/auth');
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _logoAnimation,
              child: Image.asset(
                'assets/logo/logo.png',
                height: 120,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 24),
            FadeTransition(
              opacity: _textAnimation,
              child: Column(
                children: [
                  Text(
                    AppStrings.appName,
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppConstants.primaryColor,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppStrings.slogan,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppConstants.textSecondary,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AuthGate extends StatefulWidget {
  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _isSyncing = false;
  bool _syncDone = false;
  String? _userId;
  Stream<User?>? _authStream;

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
        await SyncService(userId: user.uid).onUserLogin();
        setState(() {
          _isSyncing = false;
          _syncDone = true;
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
        if (snapshot.hasData && snapshot.data != null && _syncDone) {
          debugPrint(
              '[NAV] Navigating to HomeView for user: ${snapshot.data!.uid}');
          // Use Get.offAllNamed to ensure navigation to /home after login
          Future.microtask(() => Get.offAllNamed('/home'));
          // Show loading indicator while navigating
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }
        return SignInView();
      },
    );
  }
}

class SignInView extends StatefulWidget {
  @override
  State<SignInView> createState() => _SignInViewState();
}

class _SignInViewState extends State<SignInView> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLogin = true;
  String error = '';

  Future<void> _submit() async {
    setState(() => error = '');
    try {
      if (isLogin) {
        debugPrint(
            '[AUTH] Attempting sign in for: ${emailController.text.trim()}');
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );
        debugPrint(
            '[AUTH] Sign in successful for: ${emailController.text.trim()}');
      } else {
        debugPrint(
            '[AUTH] Attempting registration for: ${emailController.text.trim()}');
        final userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );
        debugPrint(
            '[AUTH] Registration successful for: ${emailController.text.trim()}');
        // Optionally update displayName
        if (nameController.text.trim().isNotEmpty) {
          await userCredential.user
              ?.updateDisplayName(nameController.text.trim());
        }
      }
    } catch (e) {
      debugPrint('[AUTH] Auth error: ${e.toString()}');
      setState(() => error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/logo/logo.png',
                height: 120,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 16),
              Text(
                AppStrings.appName,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppConstants.primaryColor,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                AppStrings.slogan,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppConstants.textSecondary,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Text(
                isLogin ? AppStrings.signIn : AppStrings.register,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 24),
              if (!isLogin) ...[
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                const SizedBox(height: 12),
              ],
              TextField(
                controller: emailController,
                decoration: InputDecoration(labelText: AppStrings.email),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(labelText: AppStrings.password),
                obscureText: true,
              ),
              const SizedBox(height: 24),
              if (error.isNotEmpty)
                Text(error, style: TextStyle(color: AppConstants.error)),
              SizedBox(
                width: double.infinity,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppConstants.primaryColor,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: AppConstants.primaryColor.withOpacity(0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(30),
                      onTap: _submit,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: Center(
                          child: Text(
                            isLogin ? AppStrings.signIn : AppStrings.register,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isLogin
                        ? "Don't have an account? "
                        : "Already have an account? ",
                  ),
                  GestureDetector(
                    onTap: () => setState(() => isLogin = !isLogin),
                    child: Text(
                      isLogin ? "Register here" : "Sign In",
                      style: TextStyle(
                        color: AppConstants.primaryLight,
                        fontWeight: FontWeight.bold,
                        // Removed underline decoration
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
