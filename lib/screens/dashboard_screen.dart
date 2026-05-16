import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../models/bp_reading.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class DashboardScreen extends StatefulWidget {
  final String? token;
  final String? userId;
  const DashboardScreen({super.key, this.token, this.userId});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final RefreshController _refreshController = RefreshController();
  
  Map<String, dynamic>? _latestReading;
  bool _isLoading = true;
  String? _error;

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
      final reading = await ApiService.getLatestReading(token: widget.token);
      setState(() {
        _latestReading = reading as Map<String, dynamic>?;
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
    return SmartRefresher(
        controller: _refreshController,
        onRefresh: _loadData,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 120,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: const Text('BP Monitor'),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.secondary,
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  if (_isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (_error != null)
                    _buildErrorCard()
                  else if (_latestReading == null)
                    _buildNoDataCard()
                  else
                    _buildContent(),
                ]),
              ),
            ),
          ],
        ),
      );
  }

  Widget _buildContent() {
    if (_latestReading == null) return const SizedBox();
    
    return Column(
      children: [
        _buildBPCard(),
        const SizedBox(height: 16),
        _buildVitalsRow(),
        const SizedBox(height: 16),
        _buildInfoCard(),
      ],
    );
  }

Widget _buildBPCard() {
  final systolic = double.tryParse(_latestReading!['systolic']?.toString() ?? '0') ?? 0;
  final diastolic = double.tryParse(_latestReading!['diastolic']?.toString() ?? '0') ?? 0;
  final category = _latestReading!['category']?.toString() ?? 'Unknown';
  final recordedAt = _latestReading!['recorded_at']?.toString() ?? '';

  return Card(
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    child: Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
      ),
      child: Column(
        children: [
          Text('Current Blood Pressure',
              style: TextStyle(fontSize: 16, color: Colors.grey[600], fontWeight: FontWeight.w500)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text('${systolic.toInt()}',
                  style: const TextStyle(fontSize: 64, fontWeight: FontWeight.bold, color: Colors.teal)),
              Text('/', style: TextStyle(fontSize: 48, color: Colors.grey[400])),
              Text('${diastolic.toInt()}',
                  style: const TextStyle(fontSize: 64, fontWeight: FontWeight.bold, color: Colors.teal)),
            ],
          ),
          Text('mmHg', style: TextStyle(fontSize: 18, color: Colors.grey[600])),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(color: Colors.teal, borderRadius: BorderRadius.circular(20)),
            child: Text(category,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          const SizedBox(height: 12),
          Text(recordedAt, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    ),
  );
}

Widget _buildVitalsRow() {
  final heartRate = _latestReading!['heart_rate'];
  final spo2 = _latestReading!['spo2'];

  if (heartRate == null && spo2 == null) return const SizedBox();

  return Row(
    children: [
      if (heartRate != null)
        Expanded(child: _buildVitalCard('Heart Rate', '$heartRate', 'bpm', Icons.favorite, Colors.red)),
      if (heartRate != null && spo2 != null) const SizedBox(width: 12),
      if (spo2 != null)
        Expanded(child: _buildVitalCard('SpO2', '$spo2', '%', Icons.water_drop, Colors.blue)),
    ],
  );
}

Widget _buildInfoCard() {
  final hrv = _latestReading!['hrv_rmssd'];
  final temp = _latestReading!['temperature'];
  final isMoving = _latestReading!['is_moving'] == true || _latestReading!['is_moving'] == 1;
  final recordedAt = _latestReading!['recorded_at']?.toString() ?? '';

  return Card(
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Additional Information',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          if (hrv != null) _buildInfoRow('HRV', '$hrv ms'),
          if (temp != null) _buildInfoRow('Temperature', '$temp °C'),
          _buildInfoRow('Movement', isMoving ? 'Moving' : 'Still'),
          _buildInfoRow('Time', recordedAt),
        ],
      ),
    ),
  );
}
  Widget _buildVitalCard(String label, String value, String unit, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  unit,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoDataCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.info_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No Data Available',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Waiting for readings...',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard() {
    return Card(
      color: Colors.red[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            const Text(
              'Error Loading Data',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? 'Unknown error',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[700]),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadData,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return 'Unknown';
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else {
      return DateFormat('MMM d, h:mm a').format(dateTime);
    }
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return 'Unknown';
    return DateFormat('MMM d, yyyy h:mm a').format(dateTime);
  }
}