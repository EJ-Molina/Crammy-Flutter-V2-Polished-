import 'package:crammy_app/screens/container_home+learn/main_container.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, this.isFromMenu = false});

  final bool isFromMenu;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'Welcome to Crammy!',
      description:
          'Cramming made easier.\n\nTransform your study materials into concise summaries and interactive learning tools with AI assistance.',
      icon: Icons.school_rounded,
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF7F9EF3), Color(0xFF9DCBF5)],
      ),
    ),
    OnboardingPage(
      title: 'Upload Your Materials',
      description:
          'Upload study materials in multiple formats:\n\n📄 PDF Documents\n📝 Word Files (DOCX)\n📸 Images (JPG, PNG)\n📷 Take photos with camera\n\nOur AI extracts and organizes all the text!',
      icon: Icons.upload_file_rounded,
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF364F6B), Color(0xFF3FC1C9)],
      ),
    ),
    OnboardingPage(
      title: 'AI-Powered Summaries',
      description:
          'Get instant, well-structured summaries of your materials.\n\n• Clear bullet points\n• Key concepts highlighted\n• Organized sections\n• Easy to understand\n\nNo more reading through pages!',
      icon: Icons.auto_awesome_rounded,
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF3FC1C9), Color(0xFF7F9EF3)],
      ),
    ),
    OnboardingPage(
      title: 'Create Flashcards',
      description:
          'Automatically generate comprehensive flashcards from your materials.\n\n✓ Question-answer format\n✓ Covers all key concepts\n✓ Perfect for quick review\n✓ Flip to reveal answers',
      icon: Icons.style_rounded,
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF9DCBF5), Color(0xFF364F6B)],
      ),
    ),
    OnboardingPage(
      title: 'Memory Mnemonics',
      description:
          'Get clever memory aids to remember complex concepts.\n\n🧠 Easy-to-remember phrases\n🔤 Helpful acronyms\n💡 Creative associations\n📝 Clear explanations',
      icon: Icons.psychology_rounded,
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF7F9EF3), Color(0xFF3FC1C9)],
      ),
    ),
    OnboardingPage(
      title: 'Test Your Knowledge',
      description:
          'Take AI-generated quizzes to test yourself!\n\n📝 Multiple Choice\n✓ True or False\n🔍 Identification\n📊 Track your progress\n🎯 See detailed statistics',
      icon: Icons.quiz_rounded,
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF364F6B), Color(0xFF9DCBF5)],
      ),
    ),
    OnboardingPage(
      title: 'Ready to Study Smarter?',
      description:
          'You\'re all set to transform your study sessions!\n\n• Upload your first file\n• Get instant summaries\n• Create study materials\n• Track your progress\n\nLet\'s make cramming easier! 🚀',
      icon: Icons.rocket_launch_rounded,
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF3FC1C9), Color(0xFF7F9EF3)],
      ),
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  Future<void> _completeOnboarding() async {
    if (!widget.isFromMenu) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('hasSeenOnboarding', true);

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => const MyAppContainer(),
          ),
        );
      }
    } else {
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _skipOnboarding() {
    _completeOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: _pages.length,
            itemBuilder: (context, index) {
              return _buildPage(_pages[index]);
            },
          ),
          if (_currentPage < _pages.length - 1)
            Positioned(
              top: 50,
              right: 20,
              child: SafeArea(
                child: TextButton(
                  onPressed: _skipOnboarding,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(
                    'Skip',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => _buildIndicator(index == _currentPage),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _nextPage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF364F6B),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                          elevation: 8,
                        ),
                        child: Text(
                          _currentPage == _pages.length - 1
                              ? 'Get Started'
                              : 'Next',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(OnboardingPage page) {
    return Container(
      decoration: BoxDecoration(gradient: page.gradient),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  page.icon,
                  size: 100,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 50),
              Text(
                page.title,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Text(
                page.description,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIndicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: isActive ? 24 : 8,
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.white.withOpacity(0.4),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class OnboardingPage {
  final String title;
  final String description;
  final IconData icon;
  final Gradient gradient;

  OnboardingPage({
    required this.title,
    required this.description,
    required this.icon,
    required this.gradient,
  });
}
