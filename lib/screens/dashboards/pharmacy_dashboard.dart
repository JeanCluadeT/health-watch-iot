import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../screens/dashboard_screen.dart';
import '../../screens/history_screen.dart';
import '../../screens/charts_screen.dart';
import '../../screens/stats_screen.dart';

class PharmacyDashboard extends StatefulWidget {
  final String? token;
  final String? userId;

  const PharmacyDashboard({
    super.key,
    this.token,
    this.userId,
  });

  @override
  State<PharmacyDashboard> createState() => _PharmacyDashboardState();
}

class _PharmacyDashboardState extends State<PharmacyDashboard> {
  int _selectedTabIndex = 0;
  bool _isLoading = true;
  String? _errorMessage;
  String _pharmacyName = '';
  Map<String, dynamic> _pharmacyData = {};
  List<Map<String, dynamic>> _pendingPrescriptions = [];
  List<Map<String, dynamic>> _historyPrescriptions = [];
  bool _isPrescriptionsLoading = false;
  bool _isHistoryLoading = false;

  // ── Monitor ──────────────────────────────────────────────────
  int _monitorSubIndex = 0;
  // Tracks whether the current monitor sub-screen returned no/error data
  bool _monitorNoData = false;

  @override
  void initState() {
    super.initState();
    _loadPharmacyData();
  }

  Future<void> _loadPharmacyData() async {
    if (widget.token == null) {
      setState(() {
        _errorMessage = 'Missing authentication token';
        _isLoading = false;
      });
      return;
    }

    try {
      print('=== Loading pharmacy profile with token: ${widget.token}');
      final data = await ApiService.getPharmacyProfile(token: widget.token!);
      print('=== Pharmacy Profile Response: $data');

      final pharmacy = data['pharmacy'] ?? {};
      print(
          '=== Pharmacy ID: ${pharmacy['pharmacy_id']}, Name: ${pharmacy['full_name']}');

      setState(() {
        _pharmacyData = pharmacy;
        // API returns 'pharmacy_name' not 'full_name'; fall back gracefully
        _pharmacyName = pharmacy['pharmacy_name'] ??
            pharmacy['full_name'] ??
            'Pharmacy';
        _isLoading = false;
      });

      _loadPendingPrescriptions();
    } catch (e) {
      print('=== Error loading pharmacy profile: $e');
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadPendingPrescriptions() async {
    if (widget.token == null) return;
    setState(() => _isPrescriptionsLoading = true);

    try {
      final data =
          await ApiService.getPendingPrescriptions(token: widget.token!);
      final prescriptions = data['prescriptions'] ?? [];

      setState(() {
        _pendingPrescriptions =
            List<Map<String, dynamic>>.from(prescriptions);
        _isPrescriptionsLoading = false;
      });

      _loadHistoryPrescriptions();
    } catch (e) {
      print('Error loading prescriptions: $e');
      setState(() => _isPrescriptionsLoading = false);
    }
  }

  Future<void> _loadHistoryPrescriptions() async {
    if (widget.token == null) return;
    setState(() => _isHistoryLoading = true);

    try {
      final data =
          await ApiService.getPrescriptionHistory(token: widget.token!);
      final prescriptions = data['prescriptions'] ?? [];

      setState(() {
        _historyPrescriptions =
            List<Map<String, dynamic>>.from(prescriptions);
        _isHistoryLoading = false;
      });
    } catch (e) {
      print('Error loading history: $e');
      setState(() => _isHistoryLoading = false);
    }
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Logout?'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamedAndRemoveUntil(
                  context, '/login', (route) => false);
            },
            child: const Text('Logout',
                style: TextStyle(color: AppTheme.accentColor)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$_pharmacyName MPHARMACY'),
        centerTitle: true,
        backgroundColor: AppTheme.primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 48, color: AppTheme.accentColor),
                      const SizedBox(height: 16),
                      Text('Error: $_errorMessage'),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Tab Bar
                    Container(
                      color: Colors.grey[100],
                      child: Row(
                        children: [
                          _buildTabItem(0, 'Pending'),
                          _buildTabItem(1, 'History'),
                          _buildTabItem(2, 'Account'),
                          // _buildTabItem(3, 'Monitor',
                          //     icon: Icons.monitor_heart),
                        ],
                      ),
                    ),
                    // Tab Content
                    Expanded(
                      child: _selectedTabIndex == 0
                          ? _buildPrescriptionsTab()
                          : _selectedTabIndex == 1
                              ? _buildHistoryTab()
                              : _buildAccountTab(),
                    ),
                  ],
                ),
    );
  }

  Widget _buildTabItem(int index, String label, {IconData? icon}) {
    final isSelected = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTabIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color:
                    isSelected ? AppTheme.primaryColor : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: icon != null
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon,
                        size: 18,
                        color: isSelected
                            ? AppTheme.primaryColor
                            : AppTheme.textSecondaryColor),
                    const SizedBox(height: 2),
                    Text(
                      label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: isSelected
                            ? AppTheme.primaryColor
                            : AppTheme.textSecondaryColor,
                      ),
                    ),
                  ],
                )
              : Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected
                        ? AppTheme.primaryColor
                        : AppTheme.textSecondaryColor,
                  ),
                ),
        ),
      ),
    );
  }

  // ── Monitor Tab ──────────────────────────────────────────────
  Widget _buildMonitorTab() {
    return Column(
      children: [
        Container(
          color: Colors.grey[100],
          child: Row(
            children: [
              _buildMonitorNavItem(0, 'Dashboard', Icons.dashboard),
              _buildMonitorNavItem(1, 'History', Icons.history),
              _buildMonitorNavItem(2, 'Charts', Icons.show_chart),
              _buildMonitorNavItem(3, 'Stats', Icons.analytics),
            ],
          ),
        ),
        Expanded(child: _buildMonitorSubScreen()),
      ],
    );
  }

  Widget _buildMonitorSubScreen() {
    // DashboardScreen / HistoryScreen etc. display their own error/empty states
    // internally. We keep this clean and let each screen manage its own 404.
    switch (_monitorSubIndex) {
      case 0:
        return DashboardScreen(token: widget.token, userId: widget.userId);
      case 1:
        return HistoryScreen(token: widget.token, userId: widget.userId);
      case 2:
        return ChartsScreen(token: widget.token, userId: widget.userId);
      case 3:
        return StatsScreen(token: widget.token, userId: widget.userId);
      default:
        return DashboardScreen(token: widget.token, userId: widget.userId);
    }
  }

  /// Shown when monitor sub-screens have no data (e.g. 404 for pharmacy role).
  Widget _buildMonitorEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.monitor_heart,
                size: 64,
                color: AppTheme.textSecondaryColor.withOpacity(0.4)),
            const SizedBox(height: 16),
            const Text(
              'No Monitor Data',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimaryColor),
            ),
            const SizedBox(height: 8),
            Text(
              'Blood pressure readings are not linked to this account.',
              style:
                  TextStyle(fontSize: 13, color: AppTheme.textSecondaryColor),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonitorNavItem(int index, String label, IconData icon) {
    final isSelected = _monitorSubIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _monitorSubIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color:
                    isSelected ? AppTheme.primaryColor : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon,
                  size: 20,
                  color: isSelected
                      ? AppTheme.primaryColor
                      : AppTheme.textSecondaryColor),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected
                      ? AppTheme.primaryColor
                      : AppTheme.textSecondaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrescriptionsTab() {
    if (_isPrescriptionsLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_pendingPrescriptions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text('No pending prescriptions',
                style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _loadPendingPrescriptions,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _pendingPrescriptions.length,
        itemBuilder: (context, index) {
          return _buildPrescriptionCard(_pendingPrescriptions[index]);
        },
      ),
    );
  }

  Widget _buildPrescriptionCard(Map<String, dynamic> prescription) {
    final status = prescription['status'] ?? 'pending';
    final statusColor = status == 'pending'
        ? Colors.orange
        : status == 'approved'
            ? Colors.green
            : Colors.red;

    final coordinatesList = <String>[];
    if (prescription['medicines'] is List) {
      for (var med in prescription['medicines'] as List) {
        String medicineStr = '';
        if (med is String) {
          medicineStr = med;
        } else if (med is Map && med['name'] != null) {
          medicineStr = med['name'].toString();
        }
        if (medicineStr.isNotEmpty) {
          final parts = medicineStr.split(',');
          if (parts.length >= 3) {
            final lastPart = parts.last.trim();
            if (lastPart.contains(RegExp(r'-?\\d+\\.\\d+')) ||
                lastPart.toLowerCase() == 'ambulance') {
              coordinatesList.add(lastPart);
            }
          }
        }
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Rx #${prescription['prescription_id']}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: AppTheme.textPrimaryColor),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: statusColor, width: 1),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 11),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Dr. ${prescription['doctor_name'] ?? 'Unknown'}',
              style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondaryColor,
                  fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 10),
            Text(
              '👤 ${prescription['patient_name'] ?? 'Unknown'} (${prescription['patient_age'] ?? 'N/A'} years)',
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textPrimaryColor),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(6)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('💊 Prescription:',
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          color: AppTheme.textPrimaryColor)),
                  const SizedBox(height: 6),
                  ...(prescription['medicines'] as List<dynamic>?)
                          ?.map((med) {
                            String medicineText;
                            if (med is String) {
                              medicineText = med;
                            } else if (med is Map && med['name'] != null) {
                              medicineText = med['name'].toString();
                            } else {
                              medicineText = med.toString();
                            }
                            return Padding(
                              padding: const EdgeInsets.only(left: 4, top: 3),
                              child: Text('• $medicineText',
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.textPrimaryColor)),
                            );
                          })
                          .toList() ??
                      [],
                ],
              ),
            ),
            if (coordinatesList.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(6)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('📍 Coordinates:',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                            color: Colors.blue)),
                    const SizedBox(height: 6),
                    ...coordinatesList.map((coord) => Padding(
                          padding: const EdgeInsets.only(left: 4, top: 2),
                          child: Text('• $coord',
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.blue)),
                        )),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 10),
            if (prescription['instructions'] != null &&
                prescription['instructions'].isNotEmpty)
              Text(
                '📝 ${prescription['instructions']}',
                style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textSecondaryColor,
                    fontStyle: FontStyle.italic),
              ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (status == 'pending') ...[
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _approvePrescription(
                          prescription['prescription_id']),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding:
                              const EdgeInsets.symmetric(vertical: 9)),
                      child: const Text('✓ Approve',
                          style: TextStyle(fontSize: 12)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () =>
                          _denyPrescription(prescription['prescription_id']),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding:
                              const EdgeInsets.symmetric(vertical: 9)),
                      child: const Text('✗ Deny',
                          style: TextStyle(fontSize: 12)),
                    ),
                  ),
                ] else if (status == 'approved') ...[
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _deliverPrescription(
                          prescription['prescription_id']),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          padding:
                              const EdgeInsets.symmetric(vertical: 9)),
                      child: const Text('📦 Delivered',
                          style: TextStyle(fontSize: 12)),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _approvePrescription(int prescriptionId) async {
    try {
      await ApiService.approvePrescription(
          prescriptionId: prescriptionId, token: widget.token!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Prescription approved!'),
            backgroundColor: Colors.green));
      }
      _loadPendingPrescriptions();
      _loadHistoryPrescriptions();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    }
  }

  Future<void> _denyPrescription(int prescriptionId) async {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deny Prescription'),
        content: TextField(
          controller: reasonController,
          maxLines: 3,
          decoration: const InputDecoration(
              hintText: 'Enter reason for denial',
              border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ApiService.denyPrescription(
                    prescriptionId: prescriptionId,
                    reason: reasonController.text,
                    token: widget.token!);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Prescription denied!'),
                      backgroundColor: Colors.orange));
                }
                _loadPendingPrescriptions();
                _loadHistoryPrescriptions();
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: Colors.red));
                }
              }
            },
            child: const Text('Deny'),
          ),
        ],
      ),
    );
  }

  Future<void> _deliverPrescription(int prescriptionId) async {
    try {
      await ApiService.deliverPrescription(
          prescriptionId: prescriptionId, token: widget.token!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Prescription delivered!'),
            backgroundColor: AppTheme.primaryColor));
      }
      _loadPendingPrescriptions();
      _loadHistoryPrescriptions();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    }
  }

  Widget _buildHistoryTab() {
    if (_isHistoryLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_historyPrescriptions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text('No prescription history',
                style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _loadHistoryPrescriptions,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _historyPrescriptions.length,
        itemBuilder: (context, index) {
          return _buildHistoryCard(_historyPrescriptions[index]);
        },
      ),
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> prescription) {
    final prescriptionId = prescription['prescription_id'] ?? 'N/A';
    final status = prescription['status'] ?? 'unknown';
    final doctorName = prescription['doctor_name'] ?? 'Unknown Doctor';
    final patientName = prescription['patient_name'] ?? 'Unknown Patient';
    final patientAge = prescription['patient_age'] ?? 'N/A';
    final medicines = prescription['medicines'] ?? [];
    final instructions = prescription['instructions'] ?? '';
    final approvedAt = prescription['approved_at'];
    final deliveredAt = prescription['delivered_at'];
    final deniedReason = prescription['denied_reason'];

    final coordinatesList = <String>[];
    if (medicines is List) {
      for (var med in medicines) {
        String medicineStr = '';
        if (med is String) {
          medicineStr = med;
        } else if (med is Map && med['name'] != null) {
          medicineStr = med['name'].toString();
        }
        if (medicineStr.isNotEmpty) {
          final parts = medicineStr.split(',');
          if (parts.length >= 3) {
            final lastPart = parts.last.trim();
            if (lastPart.contains(RegExp(r'-?\\d+\\.\\d+')) ||
                lastPart.toLowerCase() == 'ambulance') {
              coordinatesList.add(lastPart);
            }
          }
        }
      }
    }

    Color statusColor = Colors.grey;
    if (status == 'approved') statusColor = Colors.blue;
    if (status == 'delivered') statusColor = Colors.green;
    if (status == 'rejected') statusColor = Colors.red;

    String actionDetails = '';
    if (status == 'approved' && approvedAt != null)
      actionDetails = 'Approved: $approvedAt';
    if (status == 'delivered' && deliveredAt != null)
      actionDetails = 'Delivered: $deliveredAt';
    if (status == 'rejected' && deniedReason != null)
      actionDetails = 'Rejected: $deniedReason';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Rx #$prescriptionId',
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14)),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusColor),
                  ),
                  child: Text(status.toUpperCase(),
                      style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('Doctor: $doctorName',
                style: const TextStyle(
                    fontSize: 13, color: AppTheme.textSecondaryColor)),
            const SizedBox(height: 4),
            Text('Patient: $patientName (Age: $patientAge)',
                style: const TextStyle(
                    fontSize: 13, color: AppTheme.textSecondaryColor)),
            const SizedBox(height: 12),
            const Text('Medicines:',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 6),
            ...medicines.map<Widget>((medicine) {
              String medicineText;
              if (medicine is String) {
                medicineText = medicine;
              } else if (medicine is Map && medicine['name'] != null) {
                medicineText = medicine['name'].toString();
              } else {
                medicineText = medicine.toString();
              }
              return Padding(
                padding: const EdgeInsets.only(left: 8, bottom: 4),
                child: Text('• $medicineText',
                    style: const TextStyle(
                        fontSize: 12, color: AppTheme.textSecondaryColor)),
              );
            }).toList(),
            if (coordinatesList.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text('Coordinates:',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: Colors.blue)),
              const SizedBox(height: 6),
              ...coordinatesList.map<Widget>((coord) => Padding(
                    padding: const EdgeInsets.only(left: 8, bottom: 4),
                    child: Text('• $coord',
                        style: const TextStyle(
                            fontSize: 12, color: Colors.blue)),
                  )),
            ],
            if (instructions.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text('Instructions: $instructions',
                  style: const TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: AppTheme.textSecondaryColor)),
            ],
            if (actionDetails.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(actionDetails,
                  style: TextStyle(
                      fontSize: 11,
                      color: statusColor,
                      fontWeight: FontWeight.w600)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAccountTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Pharmacy Information',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimaryColor)),
                  const SizedBox(height: 16),
                  // API returns 'pharmacy_name'; 'full_name' may be absent
                  _buildInfoRow(
                      'Pharmacy Name',
                      _pharmacyData['pharmacy_name'] ??
                          _pharmacyData['full_name'] ??
                          ''),
                  _buildInfoRow('Contact Name',
                      _pharmacyData['full_name'] ?? ''),
                  _buildInfoRow('Email', _pharmacyData['email'] ?? ''),
                  _buildInfoRow(
                      'Phone', _pharmacyData['phone_number'] ?? ''),
                  _buildInfoRow(
                      'Province', _pharmacyData['province'] ?? ''),
                  _buildInfoRow(
                      'District', _pharmacyData['district'] ?? ''),
                  _buildInfoRow(
                      'City Sector', _pharmacyData['city_sector'] ?? ''),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _showEditDialog(),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8))),
                      child: const Text('Edit Information'),
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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label,
                style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textSecondaryColor)),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? 'Not provided' : value,
              style: TextStyle(
                  color: value.isEmpty
                      ? AppTheme.textSecondaryColor
                      : AppTheme.textPrimaryColor,
                  fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditDialog() {
    final fullNameController =
        TextEditingController(text: _pharmacyData['full_name'] ?? '');
    final pharmacyNameController =
        TextEditingController(text: _pharmacyData['pharmacy_name'] ?? '');
    final phoneController =
        TextEditingController(text: _pharmacyData['phone_number'] ?? '');
    final provinceController =
        TextEditingController(text: _pharmacyData['province'] ?? '');
    final districtController =
        TextEditingController(text: _pharmacyData['district'] ?? '');
    final citySectorController =
        TextEditingController(text: _pharmacyData['city_sector'] ?? '');
    final parentContext = context;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Edit Pharmacy Information'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: fullNameController,
                  decoration: InputDecoration(
                      labelText: 'Contact Name',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)))),
              const SizedBox(height: 12),
              TextField(
                  controller: pharmacyNameController,
                  decoration: InputDecoration(
                      labelText: 'Pharmacy Name',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)))),
              const SizedBox(height: 12),
              TextField(
                  controller: phoneController,
                  decoration: InputDecoration(
                      labelText: 'Phone Number',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)))),
              const SizedBox(height: 12),
              TextField(
                  controller: provinceController,
                  decoration: InputDecoration(
                      labelText: 'Province',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)))),
              const SizedBox(height: 12),
              TextField(
                  controller: districtController,
                  decoration: InputDecoration(
                      labelText: 'District',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)))),
              const SizedBox(height: 12),
              TextField(
                  controller: citySectorController,
                  decoration: InputDecoration(
                      labelText: 'City Sector',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)))),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              fullNameController.dispose();
              pharmacyNameController.dispose();
              phoneController.dispose();
              provinceController.dispose();
              districtController.dispose();
              citySectorController.dispose();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await ApiService.updatePharmacyProfile(
                  fullName: fullNameController.text,
                  pharmacyName: pharmacyNameController.text,
                  phoneNumber: phoneController.text,
                  province: provinceController.text,
                  district: districtController.text,
                  citySector: citySectorController.text,
                  token: widget.token!,
                );
                if (mounted) Navigator.pop(context);
                _loadPharmacyData();
                if (mounted) {
                  ScaffoldMessenger.of(parentContext).showSnackBar(
                    const SnackBar(
                        content: Text('Information updated successfully!'),
                        backgroundColor: AppTheme.primaryColor),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(parentContext).showSnackBar(SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: AppTheme.accentColor));
                }
              }
              fullNameController.dispose();
              pharmacyNameController.dispose();
              phoneController.dispose();
              provinceController.dispose();
              districtController.dispose();
              citySectorController.dispose();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}