import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/api_service.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:intl/intl.dart';

class ChartsScreen extends StatefulWidget {
  final String? token;
  final String? userId;
  const ChartsScreen({super.key, this.token, this.userId});

  @override
  State<ChartsScreen> createState() => _ChartsScreenState();
}

class _ChartsScreenState extends State<ChartsScreen> {
  final RefreshController _refreshController = RefreshController();

  List<Map<String, dynamic>> _chartData = [];

  bool _isLoading = true;
  String? _error;
  int _selectedDays = 7;

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
      final data = await ApiService.getChartData(days: _selectedDays, token: widget.token);
      setState(() {
        _chartData = data;
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
    Align(
      alignment: Alignment.centerRight,
      child: PopupMenuButton<int>(
        initialValue: _selectedDays,
        onSelected: (days) {
          setState(() { _selectedDays = days; });
          _loadData();
        },
        itemBuilder: (context) => [
          const PopupMenuItem(value: 7, child: Text('Last 7 days')),
          const PopupMenuItem(value: 14, child: Text('Last 14 days')),
          const PopupMenuItem(value: 30, child: Text('Last 30 days')),
        ],
        child: const Padding(
          padding: EdgeInsets.all(8),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Text('Filter', style: TextStyle(fontSize: 13)),
            Icon(Icons.arrow_drop_down),
          ]),
        ),
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
                : _chartData.isEmpty
                    ? _buildNoData()
                    : _buildContent(),
      ),
    )]);
  }

  Widget _buildContent() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildPeriodInfo(),
        const SizedBox(height: 16),
        _buildBPChart(),
        const SizedBox(height: 16),
        _buildHeartRateChart(),
      ],
    );
  }

  Widget _buildPeriodInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Period: Last $_selectedDays days',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${_chartData.length} data points',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBPChart() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Blood Pressure Trend',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildLegend('Systolic', Colors.red),
                const SizedBox(width: 16),
                _buildLegend('Diastolic', Colors.blue),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 250,
              child: LineChart(
                _getBPChartData(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeartRateChart() {
    // Check if we have heart rate data
    final hasHRData = _chartData.any((d) =>
    (double.tryParse(d['avg_heart_rate']?.toString() ?? '0') ?? 0) > 0);
    if (!hasHRData) return const SizedBox();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Heart Rate Trend',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _buildLegend('Heart Rate', Colors.pink),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: LineChart(
                _getHRChartData(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 3,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  LineChartData _getBPChartData() {
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: 20,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: Colors.grey[300],
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: (value, meta) {
              if (value.toInt() >= 0 && value.toInt() < _chartData.length) {
                final date = _chartData[value.toInt()]['date']?.toString() ?? '';
                final parsed = DateTime.tryParse(date);
                if (parsed != null) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      DateFormat('M/d').format(parsed),
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                }
              }
              return const Text('');
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 20,
            reservedSize: 40,
            getTitlesWidget: (value, meta) {
              return Text(
                value.toInt().toString(),
                style: const TextStyle(fontSize: 10),
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!),
          left: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      minX: 0,
      maxX: (_chartData.length - 1).toDouble(),
      minY: 60,
      maxY: 180,
      lineBarsData: [
        // Systolic line
        LineChartBarData(
          spots: _chartData.asMap().entries.map((entry) {
  final val = double.tryParse(entry.value['avg_systolic']?.toString() ?? '0') ?? 0;
  return FlSpot(entry.key.toDouble(), val);
}).toList(),
          isCurved: true,
          color: Colors.red,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: true),
          belowBarData: BarAreaData(
            show: true,
            color: Colors.red.withOpacity(0.1),
          ),
        ),
        // Diastolic line
        LineChartBarData(
          spots: _chartData.asMap().entries.map((entry) {
  final val = double.tryParse(entry.value['avg_diastolic']?.toString() ?? '0') ?? 0;
  return FlSpot(entry.key.toDouble(), val);
}).toList(),
          isCurved: true,
          color: Colors.blue,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: true),
          belowBarData: BarAreaData(
            show: true,
            color: Colors.blue.withOpacity(0.1),
          ),
        ),
      ],
    );
  }

  LineChartData _getHRChartData() {
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: 20,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: Colors.grey[300],
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: (value, meta) {
              if (value.toInt() >= 0 && value.toInt() < _chartData.length) {
                final date = _chartData[value.toInt()]['date']?.toString() ?? '';
                final parsed = DateTime.tryParse(date);
                if (parsed != null) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      DateFormat('M/d').format(parsed),
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                }
              }
              return const Text('');
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 20,
            reservedSize: 40,
            getTitlesWidget: (value, meta) {
              return Text(
                value.toInt().toString(),
                style: const TextStyle(fontSize: 10),
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!),
          left: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      minX: 0,
      maxX: (_chartData.length - 1).toDouble(),
      minY: 40,
      maxY: 140,
      lineBarsData: [
        LineChartBarData(
          spots: _chartData.asMap().entries.map((entry) {
  final val = double.tryParse(entry.value['avg_heart_rate']?.toString() ?? '0') ?? 0;
  return FlSpot(entry.key.toDouble(), val);
}).toList(),
          isCurved: true,
          color: Colors.pink,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: true),
          belowBarData: BarAreaData(
            show: true,
            color: Colors.pink.withOpacity(0.1),
          ),
        ),
      ],
    );
  }

  Widget _buildNoData() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.show_chart, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No Chart Data',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Collect more readings to see trends',
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
          const Text('Error Loading Charts'),
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
}