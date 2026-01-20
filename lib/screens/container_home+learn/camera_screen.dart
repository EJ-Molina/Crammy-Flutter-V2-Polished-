import 'dart:io';
import 'package:camera/camera.dart';
import 'package:crammy_app/models/file_data.dart';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../../helpers/environment_config.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({required this.addFile, super.key});
  final Function addFile;

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver {
  List<CameraDescription> camerasList = [];
  CameraController? cameraController;
  XFile? picture;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (cameraController == null ||
        cameraController?.value.isInitialized == false) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _setupCameraController();
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _setupCameraController();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    cameraController?.dispose();
    super.dispose();
  }

//  SHOW CAMERA ORRRRRRRRRR TAKEN PHOTTOOOOOOOOOOOOOO
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: picture == null ? _buildCameraView() : _buildPreview(),
    );
  }

  Widget _buildPreview() {
    if (picture == null) {
      return const Center(child: Text('No picture taken'));
    }

    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: Image.file(
              File(picture!.path),
              fit: BoxFit.contain,
            ),
          ),
          Container(
            color: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      picture = null;
                    });
                  },
                  icon: const Icon(
                    Icons.close_rounded,
                    size: 60,
                    color: Colors.red,
                  ),
                  tooltip: 'Retake',
                ),
                IconButton(
                  onPressed: _confirmAndExtract,
                  icon: const Icon(
                    Icons.check_rounded,
                    size: 60,
                    color: Colors.green,
                  ),
                  tooltip: 'Extract text',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraView() {
    if (cameraController == null ||
        cameraController?.value.isInitialized == false) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    return SafeArea(
      child: Stack(
        children: [
          SizedBox.expand(
            child: CameraPreview(cameraController!),
          ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: FloatingActionButton.large(
                onPressed: _takePicture,
                backgroundColor: Colors.white,
                child: const Icon(
                  Icons.camera_alt,
                  size: 40,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _takePicture() async {
    try {
      final image = await cameraController?.takePicture();
      if (image != null) {
        setState(() {
          picture = image;
        });
      }
    } catch (e) {
      _showError('Failed to take picture: $e');
    }
  }

  void _confirmAndExtract() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Extract Text'),
        content: const Text(
          'Extract and summarize text from this image?',
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await _extractAndProcess();
            },
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF3FC1C9),
            ),
            child: const Text('Extract'),
          ),
        ],
      ),
    );
  }

  Future<void> _extractAndProcess() async {
    if (picture == null) {
      _showError('No picture to process');
      return;
    }

    _showLoadingDialog('Extracting text...');

    try {
      final bytes = await picture!.readAsBytes();

      final extractModel = GenerativeModel(
        model: EnvironmentConfig.geminiModel,
        apiKey: EnvironmentConfig.geminiApiKey,
      );

      final extractResponse = await extractModel.generateContent([
        Content.multi([
          DataPart('image/jpeg', bytes),
          TextPart(
            'Extract all visible text from this image. '
            'Return ONLY the extracted text with no additional commentary. '
            'Preserve the original structure, formatting, and organization. '
            'If there are equations, formulas, or diagrams, describe them clearly.',
          ),
        ]),
      ]);

      final extractedText = extractResponse.text?.trim();

      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      if (extractedText == null || extractedText.isEmpty) {
        _showError('No text could be extracted from the image');
        return;
      }

      if (mounted) {
        _showLoadingDialog('Generating summary...');
      }

      final summaryModel = GenerativeModel(
        model: 'gemini-2.5-flash',
        apiKey: 'AIzaSyDNOOZRiVsoa59XTkE5SAAsolcnvpCrX1o',
        systemInstruction: Content.system('''
You are an expert at creating clear, concise summaries of educational content.

RULES:
1. Extract the MAIN ideas and key concepts
2. Organize information with clear structure using paragraphs
3. Keep language simple and direct
4. Focus on what students need to learn
5. Length: 3-5 well-structured paragraphs
6. Use bullet points ONLY for lists of items, not for main points
7. Write in a flowing, readable style

FORMAT GUIDELINES:
- Start with a brief overview sentence
- Follow with 2-4 paragraphs covering key concepts
- Each paragraph should focus on one main idea
- Use transitional phrases between paragraphs
- End with a concluding sentence if appropriate

Now create a clear, well-formatted summary of this content:
'''),
      );

      final summaryResponse = await summaryModel.generateContent([
        Content.text(extractedText),
      ]);

      final summary = summaryResponse.text?.trim() ?? extractedText;

      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      final newFile = FileInfo(
        origName: 'Captured Image',
        filepath: picture!.path,
        fileExtension: 'jpg',
        contentGenerated: extractedText,
        summary: summary,
      );

      widget.addFile(newFile);

      if (mounted) {
        Navigator.pop(context);
        _showSuccess('Text extracted and summarized successfully!');
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
      _showError('Failed to process image: $e');
    }
  }

  Future<void> _setupCameraController() async {
    try {
      final availableCamerasList = await availableCameras();

      if (availableCamerasList.isEmpty) {
        if (mounted) {
          _showError('No camera available');
        }
        return;
      }

      setState(() {
        camerasList = availableCamerasList;
        cameraController = CameraController(
          availableCamerasList.first,
          ResolutionPreset.high,
        );
      });

      await cameraController?.initialize();

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        _showError('Failed to initialize camera: $e');
      }
    }
  }

  void _showLoadingDialog(String message) {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 20),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
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
