// screens/history_screen.dart
import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../services/tts_service.dart';
import '../services/translation_service.dart';
import '../models/advice.dart';
import '../models/pest_report.dart';
import '../main.dart';

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  List<Advice> _savedAdvice = [];
  List<PestReport> _pestReports = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final advice = await StorageService.getCachedAdvice();
    final reports = await StorageService.getPestReports();
    
    setState(() {
      _savedAdvice = advice;
      _pestReports = reports;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(TranslationService.tr('history')),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'ਸਲਾਹ'),
            Tab(text: 'ਪੇਸਟ ਰਿਪੋਰਟ'),
          ],
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildAdviceHistory(),
                _buildPestHistory(),
              ],
            ),
    );
  }

  Widget _buildAdviceHistory() {
    if (_savedAdvice.isEmpty) {
      return _buildEmptyState('ਕੋਈ ਸੇਵ ਕੀਤੀ ਸਲਾਹ ਨਹੀਂ');
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _savedAdvice.length,
      itemBuilder: (context, index) {
        final advice = _savedAdvice[index];
        return _buildAdviceCard(advice);
      },
    );
  }

  Widget _buildPestHistory() {
    if (_pestReports.isEmpty) {
      return _buildEmptyState('ਕੋਈ ਪੇਸਟ ਰਿਪੋਰਟ ਨਹੀਂ');
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _pestReports.length,
      itemBuilder: (context, index) {
        final report = _pestReports[index];
        return _buildPestCard(report);
      },
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildAdviceCard(Advice advice) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb, color: AppConstants.primaryGreen),
                SizedBox(width: 8),
                Text(
                  '${advice.cropType} - ${advice.soilType}',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                Spacer(),
                Text(
                  '${advice.timestamp.day}/${advice.timestamp.month}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(advice.recommendation),
            SizedBox(height: 12),
            Row(
              children: [
                IconButton(
                  onPressed: () => TTSService.speak(advice.recommendation),
                  icon: Icon(Icons.volume_up),
                ),
                IconButton(
                  onPressed: () => _shareAdvice(advice),
                  icon: Icon(Icons.share),
                ),
                IconButton(
                  onPressed: () => _deleteAdvice(advice),
                  icon: Icon(Icons.delete, color: AppConstants.dangerRed),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPestCard(PestReport report) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.bug_report, color: AppConstants.dangerRed),
                SizedBox(width: 8),
                Text(
                  report.pestDetected,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                Spacer(),
                Text(
                  '${report.timestamp.day}/${report.timestamp.month}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(report.remedy),
            SizedBox(height: 12),
            Row(
              children: [
                IconButton(
                  onPressed: () => TTSService.speak(report.remedy),
                  icon: Icon(Icons.volume_up),
                ),
                IconButton(
                  onPressed: () => _deletePestReport(report),
                  icon: Icon(Icons.delete, color: AppConstants.dangerRed),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _shareAdvice(Advice advice) {
    // In a real app, you would use share_plus package
    AppUtils.showSnackBar(context, 'ਸ਼ੇਅਰ ਫੀਚਰ ਜਲਦੀ ਆਏਗਾ');
  }

  void _deleteAdvice(Advice advice) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('ਡਿਲੀਟ ਕਰੋ'),
        content: Text('ਕੀ ਤੁਸੀਂ ਇਸ ਸਲਾਹ ਨੂੰ ਡਿਲੀਟ ਕਰਨਾ ਚਾਹੁੰਦੇ ਹੋ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('ਨਹੀਂ'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _savedAdvice.remove(advice);
              });
              AppUtils.showSnackBar(context, 'ਸਲਾਹ ਡਿਲੀਟ ਹੋ ਗਈ');
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppConstants.dangerRed),
            child: Text('ਹਾਂ'),
          ),
        ],
      ),
    );
  }

  void _deletePestReport(PestReport report) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('ਡਿਲੀਟ ਕਰੋ'),
        content: Text('ਕੀ ਤੁਸੀਂ ਇਸ ਰਿਪੋਰਟ ਨੂੰ ਡਿਲੀਟ ਕਰਨਾ ਚਾਹੁੰਦੇ ਹੋ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('ਨਹੀਂ'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _pestReports.remove(report);
              });
              AppUtils.showSnackBar(context, 'ਰਿਪੋਰਟ ਡਿਲੀਟ ਹੋ ਗਈ');
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppConstants.dangerRed),
            child: Text('ਹਾਂ'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  }