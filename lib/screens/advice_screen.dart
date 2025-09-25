// screens/advice_screen.dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/tts_service.dart';
import '../services/translation_service.dart';
import '../services/storage_service.dart';
import '../models/advice.dart';
import '../widgets/loading_spinner.dart';
import '../main.dart';

class AdviceScreen extends StatefulWidget {
  @override
  _AdviceScreenState createState() => _AdviceScreenState();
}

class _AdviceScreenState extends State<AdviceScreen> {
  String? _selectedCrop;
  String? _selectedSoil;
  bool _isLoading = false;
  Advice? _currentAdvice;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      TTSService.speak(TranslationService.tr('advice_prompt'));
    });
    
    // Listen for language changes to rebuild UI
    TranslationService.addLanguageChangeListener(_onLanguageChanged);
  }

  void _onLanguageChanged() {
    if (mounted) {
      setState(() {
        // Trigger rebuild with new language
      });
    }
  }

  // Dynamic crop list based on current language
  List<Map<String, dynamic>> get _crops => [
    {'id': 'wheat', 'name': TranslationService.tr('wheat'), 'icon': Icons.grass},
    {'id': 'rice', 'name': TranslationService.tr('rice'), 'icon': Icons.eco},
    {'id': 'maize', 'name': TranslationService.tr('maize'), 'icon': Icons.local_florist},
  ];

  // Dynamic soil list based on current language
  List<Map<String, dynamic>> get _soils => [
    {'id': 'loamy', 'name': TranslationService.tr('loamy_soil'), 'icon': Icons.terrain},
    {'id': 'sandy', 'name': TranslationService.tr('sandy_soil'), 'icon': Icons.beach_access},
    {'id': 'clay', 'name': TranslationService.tr('clay_soil'), 'icon': Icons.layers},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppConstants.primaryGreen,
              AppConstants.lightBackground,
            ],
            stops: [0.0, 0.3],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: _currentAdvice != null ? _buildAdviceResult() : _buildAdviceForm(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                TranslationService.tr('advice'),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black26,
                      offset: Offset(1, 1),
                      blurRadius: 2,
                    ),
                  ],
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () => TTSService.speak(TranslationService.tr('advice_prompt')),
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.volume_up,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdviceForm() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPromptCard(),
          SizedBox(height: 24),
          _buildCropSelection(),
          SizedBox(height: 24),
          _buildSoilSelection(),
          SizedBox(height: 32),
          _buildGetAdviceButton(),
        ],
      ),
    );
  }

  Widget _buildPromptCard() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: AppUtils.agriculturalCardDecoration,
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: AppConstants.primaryGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.lightbulb,
              color: Colors.white,
              size: 24,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              TranslationService.tr('advice_prompt'),
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
          GestureDetector(
            onTap: () => TTSService.speak(TranslationService.tr('advice_prompt')),
            child: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppConstants.primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.volume_up,
                color: AppConstants.primaryGreen,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCropSelection() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: AppUtils.agriculturalCardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            TranslationService.tr('select_crop'),
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: _crops.length,
            itemBuilder: (context, index) {
              final crop = _crops[index];
              final isSelected = _selectedCrop == crop['id'];
              
              return GestureDetector(
                onTap: () {
                  setState(() => _selectedCrop = crop['id']);
                  TTSService.speak(crop['name']);
                },
                child: Container(
                  decoration: BoxDecoration(
                    gradient: isSelected ? AppConstants.primaryGradient : null,
                    color: isSelected ? null : Colors.white,
                    border: Border.all(
                      color: isSelected ? AppConstants.primaryGreen : Colors.grey.shade300,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        crop['icon'],
                        size: 32,
                        color: isSelected ? Colors.white : AppConstants.primaryGreen,
                      ),
                      SizedBox(height: 8),
                      Text(
                        crop['name'],
                        style: TextStyle(
                          color: isSelected ? Colors.white : AppConstants.primaryText,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSoilSelection() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: AppUtils.agriculturalCardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            TranslationService.tr('soil_type'),
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          SizedBox(height: 16),
          Row(
            children: _soils.map((soil) {
              final isSelected = _selectedSoil == soil['id'];
              
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() => _selectedSoil = soil['id']);
                    TTSService.speak(soil['name']);
                  },
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 4),
                    padding: EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      gradient: isSelected ? AppConstants.earthGradient : null,
                      color: isSelected ? null : Colors.white,
                      border: Border.all(
                        color: isSelected ? AppConstants.earthyBrown : Colors.grey.shade300,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Icon(
                          soil['icon'],
                          color: isSelected ? Colors.white : AppConstants.earthyBrown,
                          size: 24,
                        ),
                        SizedBox(height: 6),
                        Text(
                          soil['name'],
                          style: TextStyle(
                            color: isSelected ? Colors.white : AppConstants.primaryText,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildGetAdviceButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _canGetAdvice() ? _getAdvice : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.primaryGreen,
          padding: EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isLoading
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  LoadingSpinner(color: Colors.white, size: 20),
                  SizedBox(width: 12),
                  Text(
                    TranslationService.getCurrentLanguage() == 'pa' 
                      ? 'ਇੰਤਜ਼ਾਰ ਕਰੋ...'
                      : TranslationService.getCurrentLanguage() == 'hi'
                        ? 'प्रतीक्षा करें...'
                        : 'Please wait...',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              )
            : Text(
                TranslationService.tr('get_advice'),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Widget _buildAdviceResult() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRecommendationCard(),
          SizedBox(height: 16),
          _buildYieldCard(),
          SizedBox(height: 16),
          _buildFertilizerCard(),
          SizedBox(height: 16),
          _buildStepsCard(),
          SizedBox(height: 24),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppConstants.primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppConstants.primaryGreen.withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              _currentAdvice!.recommendation,
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ),
          SizedBox(width: 12),
          GestureDetector(
            onTap: () => TTSService.speak(_currentAdvice!.recommendation),
            child: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.volume_up,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYieldCard() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: AppUtils.agriculturalCardDecoration,
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppConstants.primaryGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.trending_up, color: AppConstants.primaryGreen),
        ),
        title: Text(
          TranslationService.tr('expected_yield'),
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          _currentAdvice!.expectedYield,
          style: TextStyle(fontSize: 16, color: AppConstants.primaryText),
        ),
        trailing: GestureDetector(
          onTap: () => TTSService.speak('${TranslationService.tr('expected_yield')} ${_currentAdvice!.expectedYield}'),
          child: Icon(Icons.volume_up, color: AppConstants.primaryGreen),
        ),
      ),
    );
  }

  Widget _buildFertilizerCard() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: AppUtils.agriculturalCardDecoration,
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppConstants.earthyBrown.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.eco, color: AppConstants.earthyBrown),
        ),
        title: Text(
          TranslationService.tr('fertilizer'),
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          _currentAdvice!.fertilizer,
          style: TextStyle(fontSize: 16, color: AppConstants.primaryText),
        ),
        trailing: GestureDetector(
          onTap: () => TTSService.speak('${TranslationService.tr('fertilizer')} ${_currentAdvice!.fertilizer}'),
          child: Icon(Icons.volume_up, color: AppConstants.primaryGreen),
        ),
      ),
    );
  }

  Widget _buildStepsCard() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: AppUtils.agriculturalCardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  TranslationService.tr('steps'),
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
              GestureDetector(
                onTap: () => TTSService.speak(_currentAdvice!.steps.join('. ')),
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppConstants.primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.volume_up,
                    color: AppConstants.primaryGreen,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          ..._currentAdvice!.steps.asMap().entries.map((entry) {
            int index = entry.key;
            String step = entry.value;
            
            return Container(
              margin: EdgeInsets.symmetric(vertical: 8),
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppConstants.lightBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppConstants.primaryGreen.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      gradient: AppConstants.primaryGradient,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      step,
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.4,
                        color: AppConstants.primaryText,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _saveAdvice,
            icon: Icon(Icons.save),
            label: Text(TranslationService.tr('save')),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryGreen,
              padding: EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _resetForm,
            icon: Icon(Icons.refresh),
            label: Text(TranslationService.tr('new')),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppConstants.primaryGreen,
              side: BorderSide(color: AppConstants.primaryGreen),
              padding: EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  bool _canGetAdvice() {
    return _selectedCrop != null && _selectedSoil != null && !_isLoading;
  }

  Future<void> _getAdvice() async {
    setState(() => _isLoading = true);
    
    try {
      final advice = await ApiService.getAdvice(
        cropType: _selectedCrop!,
        soilType: _selectedSoil!,
      );
      
      setState(() => _currentAdvice = advice);
      
      // Speak the recommendation
      await TTSService.speak(advice.recommendation);
      
    } catch (e) {
      AppUtils.showSnackBar(context, TranslationService.tr('error_generic'), isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveAdvice() async {
    if (_currentAdvice != null) {
      await StorageService.cacheAdvice(_currentAdvice!);
      AppUtils.showSnackBar(context, TranslationService.tr('advice_saved'));
      await TTSService.speak(TranslationService.tr('advice_saved'));
    }
  }

  void _resetForm() {
    setState(() {
      _selectedCrop = null;
      _selectedSoil = null;
      _currentAdvice = null;
    });
  }

  @override
  void dispose() {
    TranslationService.removeLanguageChangeListener(_onLanguageChanged);
    super.dispose();
  }
}