// screens/camera_screen.dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/api_service.dart';
import '../services/tts_service.dart';
import '../services/translation_service.dart';
import '../services/storage_service.dart';
import '../models/pest_report.dart';
import '../widgets/loading_spinner.dart';
import '../main.dart';

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  File? _imageFile;
  bool _isUploading = false;
  PestReport? _pestReport;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      TTSService.speak(TranslationService.tr('take_photo'));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(TranslationService.tr('pest_photo')),
        actions: [
          IconButton(
            onPressed: () => TTSService.speak(TranslationService.tr('take_photo')),
            icon: Icon(Icons.volume_up),
          ),
        ],
      ),
      body: _pestReport != null ? _buildPestResult() : _buildCameraInterface(),
    );
  }

  Widget _buildCameraInterface() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          _buildInstructionCard(),
          SizedBox(height: 24),
          _buildImagePreview(),
          Spacer(),
          _buildCameraButtons(),
          SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildInstructionCard() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.camera_alt, color: AppConstants.primaryGreen, size: 32),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'ਪੱਤੇ ਜਾਂ ਪੌਧੇ ਦਾ ਫੋਟੋ ਲਓ',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            IconButton(
              onPressed: () => TTSService.speak('ਪੱਤੇ ਜਾਂ ਪੌਧੇ ਦਾ ਫੋਟੋ ਲਓ'),
              icon: Icon(Icons.volume_up),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    return Container(
      width: double.infinity,
      height: 300,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300, width: 2),
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey.shade100,
      ),
      child: _imageFile != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.file(
                _imageFile!,
                fit: BoxFit.cover,
              ),
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_a_photo,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                SizedBox(height: 16),
                Text(
                  'ਫੋਟੋ ਲਓ',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildCameraButtons() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _takePicture(ImageSource.camera),
                icon: Icon(Icons.camera_alt),
                label: Text(TranslationService.tr('take_photo')),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _takePicture(ImageSource.gallery),
                icon: Icon(Icons.photo_library),
                label: Text('ਗੈਲਰੀ'),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
        if (_imageFile != null) ...[
          SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isUploading ? null : _uploadImage,
              icon: _isUploading ? LoadingSpinner() : Icon(Icons.cloud_upload),
              label: Text(TranslationService.tr('upload')),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryGreen,
                padding: EdgeInsets.symmetric(vertical: 18),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPestResult() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildResultHeader(),
          SizedBox(height: 16),
          _buildImageResult(),
          SizedBox(height: 16),
          _buildPestInfo(),
          SizedBox(height: 16),
          _buildRemedySteps(),
          SizedBox(height: 24),
          _buildResultActions(),
        ],
      ),
    );
  }

  Widget _buildResultHeader() {
    return Card(
      color: AppConstants.primaryGreen,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 32),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'ਫੋਟੋ ਦਾ ਵਿਸ਼ਲੇਸ਼ਣ ਪੂਰਾ',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            IconButton(
              onPressed: () => TTSService.speak('ਫੋਟੋ ਦਾ ਵਿਸ਼ਲੇਸ਼ਣ ਪੂਰਾ'),
              icon: Icon(Icons.volume_up, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageResult() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(
          _imageFile!,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildPestInfo() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.bug_report, color: AppConstants.dangerRed, size: 24),
                SizedBox(width: 8),
                Text(
                  'ਪਾਇਆ ਗਿਆ:',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              _pestReport!.pestDetected,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _pestReport!.remedy,
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                IconButton(
                  onPressed: () => TTSService.speak(_pestReport!.remedy),
                  icon: Icon(Icons.volume_up),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRemedySteps() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'ਇਲਾਜ ਦੇ ਕਦਮ:',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
                IconButton(
                  onPressed: () => TTSService.speak(_pestReport!.remedySteps.join('. ')),
                  icon: Icon(Icons.volume_up),
                ),
              ],
            ),
            SizedBox(height: 12),
            ..._pestReport!.remedySteps.asMap().entries.map((entry) {
              int index = entry.key;
              String step = entry.value;
              
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppConstants.primaryGreen,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        step,
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildResultActions() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _savePestReport,
            icon: Icon(Icons.save),
            label: Text(TranslationService.tr('save')),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryGreen,
            ),
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _resetCamera,
            icon: Icon(Icons.refresh),
            label: Text('ਨਵਾਂ ਫੋਟੋ'),
          ),
        ),
      ],
    );
  }

  Future<void> _takePicture(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 70,
      );
      
      if (image != null) {
        setState(() {
          _imageFile = File(image.path);
        });
        
        await TTSService.speak('ਫੋਟੋ ਲਿਆ ਗਿਆ');
      }
    } catch (e) {
      AppUtils.showSnackBar(context, TranslationService.tr('error_generic'), isError: true);
    }
  }

  Future<void> _uploadImage() async {
    if (_imageFile == null) return;

    setState(() => _isUploading = true);

    try {
      final pestReport = await ApiService.uploadPestImage(_imageFile!.path);
      
      setState(() {
        _pestReport = pestReport;
        _isUploading = false;
      });
      
      await TTSService.speak(TranslationService.tr('confirm_upload'));
      await Future.delayed(Duration(milliseconds: 500));
      await TTSService.speak(pestReport.remedy);
      
    } catch (e) {
      setState(() => _isUploading = false);
      AppUtils.showSnackBar(context, TranslationService.tr('error_generic'), isError: true);
    }
  }

  Future<void> _savePestReport() async {
    if (_pestReport != null) {
      await StorageService.savePestReport(_pestReport!);
      AppUtils.showSnackBar(context, 'ਰਿਪੋਰਟ ਸੇਵ ਹੋ ਗਈ');
      await TTSService.speak('ਰਿਪੋਰਟ ਸੇਵ ਹੋ ਗਈ');
    }
  }

  void _resetCamera() {
    setState(() {
      _imageFile = null;
      _pestReport = null;
      _isUploading = false;
    });
  }
}
