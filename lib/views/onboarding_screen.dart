import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app_constants.dart';




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

