import 'package:flutter/material.dart';
import 'package:healthguard_app/theme/app_theme.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../models/bp_reading.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class HistoryScreen extends StatefulWidget {
  final String? token;
  final String? userId;
  const HistoryScreen({super.key, this.token, this.userId});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final ApiService _apiService = ApiService();
  final RefreshController _refreshController = RefreshController();
  
  List<Map<String, dynamic>> _readings = [];
  bool _isLoading = true;
  String? _error;
  int _total = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    try {
      final result = await ApiService.getReadings(limit: 50, token: widget.token);
      setState(() {
        _readings = List<Map<String, dynamic>>.from(result['readings'] ?? []);
        _total = result['total'];
        _isLoading = false;
      });
      _refreshController.refreshCompleted();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
      _refreshController.refreshFailed();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
  children: [
    if (_total > 0)
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Align(
          alignment: Alignment.centerRight,
          child: Text('$_total readings',
              style: const TextStyle(fontSize: 14,
                  color: AppTheme.textSecondaryColor)),
        ),
      ),
    Expanded(
      child: SmartRefresher(
        controller: _refreshController,
        onRefresh: _loadData,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? _buildError()
                : _readings.isEmpty
                    ? _buildEmptyState()
                    : _buildList(),
      ),
    )
    ]);
  }

  Widget _buildList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _readings.length,
      itemBuilder: (context, index) {
        final reading = _readings[index];
        return _buildReadingCard(reading);
      },
    );
  }

Widget _buildReadingCard(Map<String, dynamic> reading) {
  final systolic = reading['systolic']?.toString() ?? '--';
  final diastolic = reading['diastolic']?.toString() ?? '--';
  final category = reading['category']?.toString() ?? 'Unknown';
  final date = reading['recorded_at']?.toString() ?? '';
  final heartRate = reading['heart_rate'];
  final spo2 = reading['spo2'];

  return Card(
    margin: const EdgeInsets.only(bottom: 12),
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: InkWell(
      onTap: () => _showDetailsDialog(reading),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 80,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.teal.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text('$systolic/$diastolic',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.teal)),
                  const Text('mmHg', style: TextStyle(fontSize: 10)),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(category,
                      style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.teal)),
                  const SizedBox(height: 4),
                  Text(date, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  if (heartRate != null || spo2 != null) ...[
                    const SizedBox(height: 4),
                    Row(children: [
                      if (heartRate != null) ...[
                        Icon(Icons.favorite, size: 12, color: Colors.red[400]),
                        const SizedBox(width: 4),
                        Text('$heartRate bpm', style: const TextStyle(fontSize: 11)),
                      ],
                      if (heartRate != null && spo2 != null) const SizedBox(width: 12),
                      if (spo2 != null) ...[
                        Icon(Icons.water_drop, size: 12, color: Colors.blue[400]),
                        const SizedBox(width: 4),
                        Text('$spo2%', style: const TextStyle(fontSize: 11)),
                      ],
                    ]),
                  ],
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      ),
    ),
  );
}

void _showDetailsDialog(Map<String, dynamic> reading) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Reading Details'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow('Blood Pressure',
              '${reading['systolic'] ?? '--'}/${reading['diastolic'] ?? '--'} mmHg'),
          _buildDetailRow('Category', reading['category']?.toString() ?? 'Unknown'),
          if (reading['heart_rate'] != null)
            _buildDetailRow('Heart Rate', '${reading['heart_rate']} bpm'),
          if (reading['spo2'] != null)
            _buildDetailRow('SpO2', '${reading['spo2']}%'),
          if (reading['hrv_rmssd'] != null)
            _buildDetailRow('HRV', '${reading['hrv_rmssd']} ms'),
          if (reading['temperature'] != null)
            _buildDetailRow('Temperature', '${reading['temperature']} °C'),
          _buildDetailRow('Movement',
              (reading['is_moving'] == true || reading['is_moving'] == 1) ? 'Moving' : 'Still'),
          _buildDetailRow('Time', reading['recorded_at']?.toString() ?? ''),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
      ],
    ),
  );
}

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey[600]),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No History',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Your readings will appear here',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          const Text('Error Loading History'),
          const SizedBox(height: 8),
          Text(_error ?? 'Unknown error'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadData,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return 'Unknown';
    return DateFormat('MMM d, yyyy h:mm a').format(dateTime);
  }
}