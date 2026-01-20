import 'package:crammy_app/helpers/crammy_db_helper.dart';
import 'package:crammy_app/models/file_data.dart';
import 'package:crammy_app/onboarding_screen.dart';
import 'package:crammy_app/screens/container_home+learn/show_modal_choose_card.dart';
import 'package:crammy_app/screens/learn_screen_overall/learn_screen.dart';
import 'package:crammy_app/file_processor_service.dart';
import 'package:flutter/material.dart';
import '../home_screen_overall/home_screen.dart';
import 'camera_screen.dart';
import '../learn_screen_overall/flashcard/modal_create_flashcard.dart';
import '../learn_screen_overall/mnemonics/modal_create_mnemonics.dart';
import '../learn_screen_overall/quiz/modal_create_quiz.dart';

class MyAppContainer extends StatefulWidget {
  const MyAppContainer({super.key});

  @override
  State<MyAppContainer> createState() => _MyAppContainerState();
}

class _MyAppContainerState extends State<MyAppContainer> {
  List<FileInfo> files = [];
  int bottomNavIndex = 0;
  int learnTabIndex = 0;

  List<FileInfo> flashCardData = [];
  List<FileInfo> mnemonicsData = [];
  List<FileInfo> quizData = [];

  bool isProcessing = false;
  bool isLoading = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _loadDataFromDatabase();
  }

  Future<void> _loadDataFromDatabase() async {
    setState(() {
      isLoading = true;
    });

    try {
      final allFiles = await CrammyDbHelper.fetchAllFiles();
      final allFlashcards = await CrammyDbHelper.fetchAllFlashcardSets();
      final allMnemonics = await CrammyDbHelper.fetchAllMnemonicsSets();
      final allQuizzes = await CrammyDbHelper.fetchAllQuizSets();

      setState(() {
        files = allFiles;
        flashCardData = allFlashcards;
        mnemonicsData = allMnemonics;
        quizData = allQuizzes;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showError('Failed to load data: $e');
    }
  }

  Future<void> addFileFromCam(FileInfo file) async {
    try {
      final fileId = await CrammyDbHelper.insertFile(file);
      file.id = fileId;
      setState(() {
        files.add(file);
      });
    } catch (e) {
      _showError('Failed to save file: $e');
    }
  }

  Future<void> onCreateFlashCard(FileInfo file) async {
    try {
      await CrammyDbHelper.insertFlashcardSet(
        file.id!,
        file.flashcardsFromContent!,
      );
      setState(() {
        flashCardData.add(file);
      });
      _showSuccess('Flashcards created successfully!');
    } catch (e) {
      _showError('Failed to save flashcards: $e');
    }
  }

  Future<void> onCreateMnemonics(FileInfo file) async {
    try {
      await CrammyDbHelper.insertMnemonicsSet(
        file.id!,
        file.mnemonicsFromContent!,
      );
      setState(() {
        mnemonicsData.add(file);
      });
      _showSuccess('Mnemonics created successfully!');
    } catch (e) {
      _showError('Failed to save mnemonics: $e');
    }
  }

  Future<void> onCreateQuiz(FileInfo file) async {
    try {
      await CrammyDbHelper.insertQuizSet(
        file.id!,
        file.quizzesFromContent!,
      );
      final updatedQuizzes = await CrammyDbHelper.fetchAllQuizSets();
      setState(() {
        quizData = updatedQuizzes;
      });
      _showSuccess('Quiz created successfully!');
    } catch (e) {
      _showError('Failed to save quiz: $e');
    }
  }

  Future<void> onDeleteItem(FileInfo item, List<FileInfo> list) async {
    try {
      if (list == flashCardData && item.id != null) {
        await CrammyDbHelper.deleteFlashcardSet(item.id!);
      } else if (list == mnemonicsData && item.id != null) {
        await CrammyDbHelper.deleteMnemonicsSet(item.id!);
      } else if (list == quizData && item.quizSetId != null) {
        await CrammyDbHelper.deleteQuizSet(item.quizSetId!);
      }
      setState(() {
        list.remove(item);
      });
    } catch (e) {
      _showError('Failed to delete item: $e');
    }
  }

  Future<void> onDeleteFile(FileInfo file) async {
    try {
      if (file.id != null) {
        await CrammyDbHelper.deleteFile(file.id!);
      }
      setState(() {
        files.remove(file);
      });
    } catch (e) {
      _showError('Failed to delete file: $e');
    }
  }

  void onTabChange(int tabIndex) {
    setState(() {
      learnTabIndex = tabIndex;
    });
  }

  List<Widget> get screens => [
        HomeScreen(files: files, onDelete: onDeleteFile),
        LearnScreen(
          onTabChanged: onTabChange,
          flashCardData: flashCardData,
          mnemonicsData: mnemonicsData,
          quizData: quizData,
          onDelete: onDeleteItem,
        ),
      ];

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF3FC1C9),
          ),
        ),
      );
    }

    return Scaffold(
      key: _scaffoldKey,
      drawer: _buildDrawer(),
      floatingActionButton: SizedBox(
        height: 75,
        width: 75,
        child: FloatingActionButton(
          onPressed: isProcessing ? null : _handleFabPress,
          backgroundColor: isProcessing ? Colors.grey : const Color(0xFF364F6B),
          child: isProcessing
              ? const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                )
              : const Icon(
                  Icons.add_rounded,
                  size: 50,
                  color: Color(0xFF7F9EF3),
                ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(15),
            topRight: Radius.circular(15),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: bottomNavIndex,
          onTap: (selectedIndex) {
            setState(() {
              bottomNavIndex = selectedIndex;
            });
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color(0xFF364F6B),
          unselectedItemColor: const Color(0xFF364F6B).withOpacity(0.60),
          selectedFontSize: 12,
          items: [
            BottomNavigationBarItem(
              activeIcon: Column(
                children: [
                  Container(
                    height: 3,
                    width: 30,
                    decoration: BoxDecoration(
                      color: const Color(0xFF3FC1C9),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Icon(Icons.home_rounded, size: 32),
                ],
              ),
              icon: const Icon(Icons.home_rounded, size: 32),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              activeIcon: Column(
                children: [
                  Container(
                    height: 3,
                    width: 30,
                    decoration: BoxDecoration(
                      color: const Color(0xFF3FC1C9),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Icon(Icons.book_rounded, size: 32),
                ],
              ),
              icon: const Icon(Icons.book, size: 32),
              label: 'Learn',
            ),
          ],
        ),
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF7F9EF3), Color(0xFF9DCBF5)],
          ),
        ),
        child: screens[bottomNavIndex],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF364F6B), Color(0xFF3FC1C9)],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Image.asset(
                      'assets/images/crammy_logo.png',
                      height: 60,
                      width: 60,
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      "Crammy",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  "Your Smart Study Companion",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home, color: Color(0xFF364F6B)),
            title: const Text('Home'),
            onTap: () {
              setState(() {
                bottomNavIndex = 0;
              });
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.book, color: Color(0xFF364F6B)),
            title: const Text('Learn'),
            onTap: () {
              setState(() {
                bottomNavIndex = 1;
              });
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.help_outline, color: Color(0xFF3FC1C9)),
            title: const Text('Tutorial'),
            subtitle: const Text(
              'Learn how to use Crammy',
              style: TextStyle(fontSize: 11),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const OnboardingScreen(isFromMenu: true),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.analytics, color: Color(0xFF3FC1C9)),
            title: const Text('Statistics'),
            subtitle: Text(
              '${files.length} files • ${flashCardData.length} flashcards • ${mnemonicsData.length} mnemonics • ${quizData.length} quizzes',
              style: const TextStyle(fontSize: 11),
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline, color: Color(0xFF364F6B)),
            title: const Text('About'),
            onTap: () {
              Navigator.pop(context);
              showAboutDialog(
                context: context,
                applicationName: 'Crammy',
                applicationVersion: '1.0.0',
                applicationIcon: Image.asset(
                  'assets/images/crammy_logo.png',
                  height: 50,
                  width: 50,
                ),
                children: [
                  const Text(
                    'Crammy is your smart study companion that helps you learn faster with AI-powered flashcards, mnemonics, and quizzes.',
                  ),
                ],
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_sweep, color: Colors.red),
            title: const Text('Clear All Data'),
            onTap: () {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Clear All Data'),
                  content: const Text(
                    'Are you sure you want to delete all files, flashcards, mnemonics, and quizzes? This action cannot be undone.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      onPressed: () async {
                        await CrammyDbHelper.deleteAllFiles();
                        setState(() {
                          files.clear();
                          flashCardData.clear();
                          mnemonicsData.clear();
                          quizData.clear();
                        });
                        Navigator.pop(context);
                        _showSuccess('All data cleared successfully');
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text('Clear All'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _handleFabPress() {
    if (bottomNavIndex == 0) {
      _showHomeActions();
    } else {
      if (files.isEmpty) {
        _showError(
          'No files available. Please upload a file first from the Home tab.',
        );
        return;
      }
      _showLearnActions();
    }
  }

  void _showHomeActions() {
    showModalBottomSheet(
      context: context,
      builder: (_) => ShowModalChooseCard(
        chooseFile: _chooseFile,
        takePhoto: _takePhoto,
      ),
    );
  }

//-------------------------------------------------------------------------FAB FOR ;LEARMN SECCCCCCCCCCCCCCCCCCC
  void _showLearnActions() {
    Widget modalContent;

    if (learnTabIndex == 0) {
      modalContent = ShowModalCreateFlashCard(
        files: files,
        onCreate: onCreateFlashCard,
      );
    } else if (learnTabIndex == 1) {
      modalContent = ShowModalCreateMnemonics(
        files: files,
        onCreate: onCreateMnemonics,
      );
    } else {
      modalContent = ShowModalCreateQuiz(
        files: files,
        onCreate: onCreateQuiz, 
      );
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: modalContent,
      ),
    );
  }

  void _takePhoto() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CameraScreen(addFile: addFileFromCam),
      ),
    );
  }

  Future<void> _chooseFile() async {
    setState(() {
      isProcessing = true;
    });

    Navigator.pop(context);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const PopScope(
        canPop: false,
        child: AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(color: Color(0xFF3FC1C9)),
              SizedBox(width: 20),
              Expanded(
                child: Text('Processing file...\nThis may take a moment'),
              ),
            ],
          ),
        ),
      ),
    );

    try {
      final fileInfo = await FileProcessorService.pickAndProcessFile();

      if (fileInfo == null) {
        if (mounted) {
          Navigator.of(context, rootNavigator: true).pop();
        }
        setState(() {
          isProcessing = false;
        });
        return;
      }

      final fileId = await CrammyDbHelper.insertFile(fileInfo);
      fileInfo.id = fileId;

      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      setState(() {
        files.add(fileInfo);
      });

      if (mounted) {
        _showSuccess('File processed successfully!');
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
      _showError('Failed to process file: $e');
    } finally {
      if (mounted) {
        setState(() {
          isProcessing = false;
        });
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSuccess(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
