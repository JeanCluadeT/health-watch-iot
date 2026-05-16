import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';

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
      print('=== Pharmacy ID: ${pharmacy['pharmacy_id']}, Name: ${pharmacy['full_name']}');
      
      setState(() {
        _pharmacyData = pharmacy;
        _pharmacyName = pharmacy['full_name'] ?? 'Pharmacy';
        _isLoading = false;
      });
      
      // Load pending prescriptions after getting pharmacy data
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

    setState(() {
      _isPrescriptionsLoading = true;
    });

    try {
      print('=== Loading pending prescriptions with token: ${widget.token}');
      final data = await ApiService.getPendingPrescriptions(token: widget.token!);
      print('=== API Response: $data');
      
      final prescriptions = data['prescriptions'] ?? [];
      print('=== Prescriptions count: ${prescriptions.length}');
      print('=== Total: ${data['total']}, Pending: ${data['pending_count']}');
      
      setState(() {
        _pendingPrescriptions = List<Map<String, dynamic>>.from(prescriptions);
        _isPrescriptionsLoading = false;
      });
      
      // Load history after loading pending
      _loadHistoryPrescriptions();
    } catch (e) {
      print('Error loading prescriptions: $e');
      setState(() {
        _isPrescriptionsLoading = false;
      });
    }
  }

  Future<void> _loadHistoryPrescriptions() async {
    if (widget.token == null) return;

    setState(() {
      _isHistoryLoading = true;
    });

    try {
      print('=== Loading history prescriptions with token: ${widget.token}');
      final data = await ApiService.getPrescriptionHistory(token: widget.token!);
      print('=== History API Response: $data');
      
      final prescriptions = data['prescriptions'] ?? [];
      print('=== History Prescriptions count: ${prescriptions.length}');
      
      setState(() {
        _historyPrescriptions = List<Map<String, dynamic>>.from(prescriptions);
        _isHistoryLoading = false;
      });
    } catch (e) {
      print('Error loading history: $e');
      setState(() {
        _isHistoryLoading = false;
      });
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
              Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
            },
            child: const Text('Logout', style: TextStyle(color: AppTheme.accentColor)),
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
                      const Icon(Icons.error_outline, size: 48, color: AppTheme.accentColor),
                      const SizedBox(height: 16),
                      Text('Error: $_errorMessage'),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Tab Buttons
                    Container(
                      color: Colors.grey[100],
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _selectedTabIndex = 0),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: _selectedTabIndex == 0
                                          ? AppTheme.primaryColor
                                          : Colors.transparent,
                                      width: 3,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  'Pending',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: _selectedTabIndex == 0
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                    color: _selectedTabIndex == 0
                                        ? AppTheme.primaryColor
                                        : AppTheme.textSecondaryColor,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _selectedTabIndex = 1),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: _selectedTabIndex == 1
                                          ? AppTheme.primaryColor
                                          : Colors.transparent,
                                      width: 3,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  'History',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: _selectedTabIndex == 1
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                    color: _selectedTabIndex == 1
                                        ? AppTheme.primaryColor
                                        : AppTheme.textSecondaryColor,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _selectedTabIndex = 2),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: _selectedTabIndex == 2
                                          ? AppTheme.primaryColor
                                          : Colors.transparent,
                                      width: 3,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  'Account',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: _selectedTabIndex == 2
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                    color: _selectedTabIndex == 2
                                        ? AppTheme.primaryColor
                                        : AppTheme.textSecondaryColor,
                                  ),
                                ),
                              ),
                            ),
                          ),
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
            Text(
              'No pending prescriptions',
              style: TextStyle(color: Colors.grey[600]),
            ),
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
          final prescription = _pendingPrescriptions[index];
          return _buildPrescriptionCard(prescription);
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

    // Extract coordinates from medicines
    final coordinatesList = <String>[];
    if (prescription['medicines'] is List) {
      for (var med in prescription['medicines'] as List) {
        String medicineStr = '';
        if (med is String) {
          medicineStr = med;
        } else if (med is Map && med['name'] != null) medicineStr = med['name'].toString();
        
        if (medicineStr.isNotEmpty) {
          final parts = medicineStr.split(',');
          if (parts.length >= 3) {
            final lastPart = parts.last.trim();
            // Check if last part contains coordinates or special keyword
            if (lastPart.contains(RegExp(r'-?\\d+\\.\\d+')) || lastPart.toLowerCase() == 'ambulance') {
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
            // Header: Rx ID and Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Rx #${prescription['prescription_id']}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: AppTheme.textPrimaryColor,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Doctor info
            // REPLACE WITH
Text(
  'Dr. ${prescription['doctor_name'] ?? 'Unknown'}',
  style: const TextStyle(
    fontSize: 12,
    color: AppTheme.textSecondaryColor,
    fontStyle: FontStyle.italic,
  ),
),
const SizedBox(height: 10),
Text(
  '👤 ${prescription['patient_name'] ?? 'Unknown'} (${prescription['patient_age'] ?? 'N/A'} years)',
  style: const TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppTheme.textPrimaryColor,
  ),
),const SizedBox(height: 10),

            // Medicines/Prescription Details
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(6),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '💊 Prescription:',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: AppTheme.textPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  ...(prescription['medicines'] as List<dynamic>?)?.map(
                    (med) {
                      // Show medicine as simple text - just the name field or string itself
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
                        child: Text(
                          '• $medicineText',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textPrimaryColor,
                          ),
                        ),
                      );
                    },
                  ).toList() ?? [],
                ],
              ),
            ),
            if (coordinatesList.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '📍 Coordinates:',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 6),
                    ...coordinatesList.map((coord) => Padding(
                      padding: const EdgeInsets.only(left: 4, top: 2),
                      child: Text(
                        '• $coord',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.blue,
                        ),
                      ),
                    )),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 10),

            // Instructions/Notes
            if (prescription['instructions'] != null && prescription['instructions'].isNotEmpty)
              Text(
                '📝 ${prescription['instructions']}',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppTheme.textSecondaryColor,
                  fontStyle: FontStyle.italic,
                ),
              ),
            const SizedBox(height: 12),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (status == 'pending') ...[
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _approvePrescription(prescription['prescription_id']),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 9),
                      ),
                      child: const Text('✓ Approve', style: TextStyle(fontSize: 12)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _denyPrescription(prescription['prescription_id']),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 9),
                      ),
                      child: const Text('✗ Deny', style: TextStyle(fontSize: 12)),
                    ),
                  ),
                ] else if (status == 'approved') ...[
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _deliverPrescription(prescription['prescription_id']),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 9),
                      ),
                      child: const Text('📦 Delivered', style: TextStyle(fontSize: 12)),
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
        prescriptionId: prescriptionId,
        token: widget.token!,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Prescription approved!'),
            backgroundColor: Colors.green,
          ),
        );
      }
      
      _loadPendingPrescriptions();
      _loadHistoryPrescriptions();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
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
            border: OutlineInputBorder(),
          ),
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
                  token: widget.token!,
                );
                
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Prescription denied!'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
                
                _loadPendingPrescriptions();
                _loadHistoryPrescriptions();
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
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
        prescriptionId: prescriptionId,
        token: widget.token!,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Prescription delivered!'),
            backgroundColor: AppTheme.primaryColor,
          ),
        );
      }
      
      _loadPendingPrescriptions();
      _loadHistoryPrescriptions();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
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
            Text(
              'No prescription history',
              style: TextStyle(color: Colors.grey[600]),
            ),
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
          final prescription = _historyPrescriptions[index];
          return _buildHistoryCard(prescription);
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

    // Extract coordinates from medicines
    final coordinatesList = <String>[];
    if (medicines is List) {
      for (var med in medicines) {
        String medicineStr = '';
        if (med is String) {
          medicineStr = med;
        } else if (med is Map && med['name'] != null) medicineStr = med['name'].toString();
        
        if (medicineStr.isNotEmpty) {
          final parts = medicineStr.split(',');
          if (parts.length >= 3) {
            final lastPart = parts.last.trim();
            // Check if last part contains coordinates or special keyword
            if (lastPart.contains(RegExp(r'-?\\d+\\.\\d+')) || lastPart.toLowerCase() == 'ambulance') {
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

    String statusLabel = status.toUpperCase();
    String actionDetails = '';
    if (status == 'approved' && approvedAt != null) actionDetails = 'Approved: $approvedAt';
    if (status == 'delivered' && deliveredAt != null) actionDetails = 'Delivered: $deliveredAt';
    if (status == 'rejected' && deniedReason != null) actionDetails = 'Rejected: $deniedReason';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with ID and Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Rx #$prescriptionId',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusColor),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Doctor and Patient Info
            Text(
              'Doctor: $doctorName',
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Patient: $patientName (Age: $patientAge)',
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 12),
            // Medicines
            Text(
              'Medicines:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 6),
            ...medicines.map<Widget>((medicine) {
              // Show medicine as simple text - just the name field or string itself
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
                child: Text(
                  '• $medicineText',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
              );
            }).toList(),
            if (coordinatesList.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text(
                'Coordinates:',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 6),
              ...coordinatesList.map<Widget>((coord) => Padding(
                padding: const EdgeInsets.only(left: 8, bottom: 4),
                child: Text(
                  '• $coord',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.blue,
                  ),
                ),
              )),
            ],
            const SizedBox(height: 12),
            // Instructions
            if (instructions.isNotEmpty)
              Text(
                'Instructions: $instructions',
                style: const TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: AppTheme.textSecondaryColor,
                ),
              ),
            const SizedBox(height: 12),
            // Action Date
            if (actionDetails.isNotEmpty)
              Text(
                actionDetails,
                style: TextStyle(
                  fontSize: 11,
                  color: statusColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
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
                  const Text(
                    'Pharmacy Information',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow('Contact Name', _pharmacyData['full_name'] ?? ''),
                  _buildInfoRow('Pharmacy Name', _pharmacyData['pharmacy_name'] ?? ''),
                  _buildInfoRow('Email', _pharmacyData['email'] ?? ''),
                  _buildInfoRow('Phone', _pharmacyData['phone_number'] ?? ''),
                  _buildInfoRow('Province', _pharmacyData['province'] ?? ''),
                  _buildInfoRow('District', _pharmacyData['district'] ?? ''),
                  _buildInfoRow('City Sector', _pharmacyData['city_sector'] ?? ''),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _showEditDialog(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
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
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: AppTheme.textSecondaryColor,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? 'Not provided' : value,
              style: TextStyle(
                color: value.isEmpty ? AppTheme.textSecondaryColor : AppTheme.textPrimaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditDialog() {
    final fullNameController = TextEditingController(text: _pharmacyData['full_name'] ?? '');
    final pharmacyNameController = TextEditingController(text: _pharmacyData['pharmacy_name'] ?? '');
    final phoneController = TextEditingController(text: _pharmacyData['phone_number'] ?? '');
    final provinceController = TextEditingController(text: _pharmacyData['province'] ?? '');
    final districtController = TextEditingController(text: _pharmacyData['district'] ?? '');
    final citySectorController = TextEditingController(text: _pharmacyData['city_sector'] ?? '');
    
    // Capture parent context before opening dialog
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
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: pharmacyNameController,
                decoration: InputDecoration(
                  labelText: 'Pharmacy Name',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: provinceController,
                decoration: InputDecoration(
                  labelText: 'Province',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: districtController,
                decoration: InputDecoration(
                  labelText: 'District',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: citySectorController,
                decoration: InputDecoration(
                  labelText: 'City Sector',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
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
                
                // First pop the dialog
                if (mounted) {
                  Navigator.pop(context);
                }
                
                // Then reload data and show snackbar using parent context
                _loadPharmacyData();
                if (mounted) {
                  ScaffoldMessenger.of(parentContext).showSnackBar(
                    const SnackBar(
                      content: Text('Information updated successfully!'),
                      backgroundColor: AppTheme.primaryColor,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(parentContext).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: AppTheme.accentColor,
                    ),
                  );
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
