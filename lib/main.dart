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
import 'views/home_view.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'services/sync_service.dart';
import 'package:flutter/foundation.dart';

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
  await Hive.openBox<Section>('sections');
  await Hive.openBox<Record>('records');
  await Hive.openBox<Field>('fields'); // Open fields box
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
        GetPage(name: '/', page: () => AuthGate()),
        GetPage(name: '/hive-data-viewer', page: () => HiveDataViewerPage()),
      ],
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
          return HomeView(userId: snapshot.data!.uid);
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
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );
        debugPrint(
            '[AUTH] Registration successful for: ${emailController.text.trim()}');
      }
    } catch (e) {
      debugPrint('[AUTH] Auth error: ${e.toString()}');
      setState(() => error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(isLogin ? 'Sign In' : 'Register',
                  style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 24),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              const SizedBox(height: 24),
              if (error.isNotEmpty)
                Text(error, style: const TextStyle(color: Colors.red)),
              ElevatedButton(
                onPressed: _submit,
                child: Text(isLogin ? 'Sign In' : 'Register'),
              ),
              TextButton(
                onPressed: () => setState(() => isLogin = !isLogin),
                child: Text(isLogin
                    ? 'Create an account'
                    : 'Already have an account? Sign In'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
