import 'package:datanest/firebase_options.dart';
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

class OnboardingScreen extends StatefulWidget {
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingPageData> _pages = [
    _OnboardingPageData(
      title: 'Welcome to DataNest',
      description:
          'A modern, flexible platform to structure, collect, and sync any kind of data. Let’s get you started!',
      lottieUrl: 'https://assets2.lottiefiles.com/packages/lf20_kyu7xb1v.json',
    ),
    _OnboardingPageData(
      title: 'Organize with Sections',
      description:
          'Create custom sections for your projects, clients, or any topic. Sections keep your workspace clean and focused.',
      lottieUrl: 'https://assets2.lottiefiles.com/packages/lf20_2ks3pjua.json',
    ),
    _OnboardingPageData(
      title: 'Customize with Fields',
      description:
          'Add fields to each section: text, numbers, dates, images, files, and more. Tailor your data structure to your needs.',
      lottieUrl: 'https://assets2.lottiefiles.com/packages/lf20_3vbOcw.json',
    ),
    _OnboardingPageData(
      title: 'Add & Manage Records',
      description:
          'Quickly add records to capture your information. Edit, search, and filter with ease. All changes are saved instantly.',
      lottieUrl: 'https://assets2.lottiefiles.com/packages/lf20_1pxqjqps.json',
    ),
    _OnboardingPageData(
      title: 'Stay Synced & Secure',
      description:
          'Your data is always safe. Work offline and sync automatically when you’re back online. Access from any device.',
      lottieUrl: 'https://assets2.lottiefiles.com/packages/lf20_4kx2q32n.json',
    ),
    _OnboardingPageData(
      title: 'Track Tasks & Progress',
      description:
          'Manage your to-dos and tasks inside any section. Set priorities, mark as done, and never lose track of what matters.',
      lottieUrl: 'https://assets2.lottiefiles.com/packages/lf20_2glqweqs.json',
    ),
    _OnboardingPageData(
      title: 'How to Use DataNest',
      description:
          '1. Tap the + button to create a section.\n2. Add fields to define what you want to track.\n3. Add records to store your data.\n4. Use the menu to view, edit, or delete sections and records.\n5. Use the search and filter tools to find anything fast.\n6. Enjoy seamless sync and access anywhere!',
      lottieUrl: 'https://assets2.lottiefiles.com/packages/lf20_1pxqjqps.json',
    ),
    _OnboardingPageData(
      title: 'Ready to Start?',
      description:
          'Sign in or register to unlock the full power of DataNest. Your data, your way—organized and always with you.',
      lottieUrl: 'https://assets2.lottiefiles.com/packages/lf20_kyu7xb1v.json',
    ),
  ];

  void _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboardingSeen', true);
    Get.offAllNamed('/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Lottie.network(page.lottieUrl, height: 220),
                        const SizedBox(height: 32),
                        Text(
                          page.title,
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppConstants.primaryColor,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          page.description,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: AppConstants.textSecondary,
                                  ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pages.length, (index) {
                return Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 16),
                  width: _currentPage == index ? 16 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? AppConstants.primaryColor
                        : AppConstants.primaryLight.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: _currentPage == _pages.length - 1
                      ? _finishOnboarding
                      : () {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOut,
                          );
                        },
                  child: Text(
                    _currentPage == _pages.length - 1 ? 'Get Started' : 'Next',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPageData {
  final String title;
  final String description;
  final String lottieUrl;
  _OnboardingPageData(
      {required this.title,
      required this.description,
      required this.lottieUrl});
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
