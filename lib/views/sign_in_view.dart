import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../app_constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_gate.dart';

class SignInView extends StatefulWidget {
  @override
  State<SignInView> createState() => _SignInViewState();
}

class _SignInViewState extends State<SignInView> {
  // Ensure user profile is complete (displayName, etc.)
  Future<void> _ensureUserProfileComplete(User? user) async {
    if (user == null) return;
    // If displayName is missing, set it from nameController
    if ((user.displayName == null || user.displayName!.isEmpty) &&
        nameController.text.trim().isNotEmpty) {
      await user.updateDisplayName(nameController.text.trim());
      debugPrint('[AUTH] Set missing displayName for user: ${user.email}');
    }
    // Update Firestore user doc with displayName and email (add more fields as needed)
    try {
      final users = FirebaseFirestore.instance.collection('users');
      final userDoc = users.doc(user.uid);
      final userData = <String, dynamic>{
        'displayName': user.displayName ?? nameController.text.trim(),
        'email': user.email,
        // Add more fields here if needed
      };
      await userDoc.set(userData, SetOptions(merge: true));
      debugPrint('[AUTH] Synced user profile to Firestore: ${user.email}');
    } catch (e) {
      debugPrint('[AUTH] Failed to sync user profile to Firestore: $e');
    }
  }

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
        // Not a new user
        final authGateState = context.findAncestorStateOfType<AuthGateState>();
        if (authGateState != null) authGateState.isNewUser = false;
        // Ensure user profile is complete after login
        await _ensureUserProfileComplete(FirebaseAuth.instance.currentUser);
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
        // Always set displayName on registration
        if (nameController.text.trim().isNotEmpty) {
          await userCredential.user
              ?.updateDisplayName(nameController.text.trim());
        }
        // Ensure user profile is complete after registration
        await _ensureUserProfileComplete(userCredential.user);
        // Mark as new user for sync flow
        final authGateState = context.findAncestorStateOfType<AuthGateState>();
        if (authGateState != null) authGateState.isNewUser = true;
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
