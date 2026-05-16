import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';

class DoctorDashboard extends StatefulWidget {
  final String? token;
  final String? userId;

  const DoctorDashboard({super.key, this.token, this.userId});

  @override
  State<DoctorDashboard> createState() => _DoctorDashboardState();
}

class _DoctorDashboardState extends State<DoctorDashboard> {
  int _selectedTabIndex = 0;
  bool _isLoading = true;
  String? _errorMessage;
  String _doctorName = '';
  Map<String, dynamic> _doctorData = {};
  List<Map<String, dynamic>> _prescriptions = [];
  List<Map<String, dynamic>> _assignedPatients = [];
  Map<String, dynamic>? _selectedPatient;
  Map<String, dynamic>? _patientHistory;
  bool _loadingPatientHistory = false;

  List<Map<String, dynamic>> _pharmacySearchResults = [];
  List<Map<String, dynamic>> _allPharmacies = [];
  Map<String, dynamic>? _selectedPharmacyForPrescription;
  Map<String, dynamic>? _selectedPatientForPrescription;
  bool _isPharmacySearching = false;
  TextEditingController? _pharmacySearchController;
  late TextEditingController _prescriptionInstructionsController;
  late TextEditingController _prescriptionNotesController;

  @override
  void initState() {
    super.initState();
    _pharmacySearchController = TextEditingController();
    _prescriptionInstructionsController = TextEditingController();
    _prescriptionNotesController = TextEditingController();
    _loadDoctorData();
  }

  @override
  void dispose() {
    _pharmacySearchController?.dispose();
    _prescriptionInstructionsController.dispose();
    _prescriptionNotesController.dispose();
    super.dispose();
  }

  void _loadDoctorData() async {
    if (widget.token == null) {
      setState(() {
        _errorMessage = 'Missing authentication token';
        _isLoading = false;
      });
      return;
    }

    try {
      final data = await ApiService.getDoctorProfile(token: widget.token!);
      final doctor = data['doctor'] ?? {};

      setState(() {
        _doctorData = doctor;
        _doctorName = doctor['full_name'] ?? 'Doctor';
        _isLoading = false;
      });

      // Load prescriptions and alerts
      _loadPrescriptions();
      _loadAllPharmacies();
      _loadAssignedPatients();
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _loadAllPharmacies() async {
    try {
      final data = await ApiService.searchPharmacy(
        query: '',
        token: widget.token!,
      );
      final pharmacies = List<Map<String, dynamic>>.from(
        data['pharmacies'] ?? [],
      );

      if (mounted) {
        setState(() {
          _allPharmacies = pharmacies;
          _pharmacySearchResults = pharmacies;
        });
      }
    } catch (e) {
      print('Error loading pharmacies: $e');
    }
  }

  void _loadPrescriptions() async {
    try {
      final data = await ApiService.getDoctorPrescriptions(
        token: widget.token!,
      );
      final prescriptions = List<Map<String, dynamic>>.from(
        data['prescriptions'] ?? [],
      );

      if (mounted) {
        setState(() {
          _prescriptions = prescriptions;
        });
      }
    } catch (e) {
      print('Error loading prescriptions: $e');
    }
  }

  void _loadAssignedPatients() async {
    try {
      final data = await ApiService.getAssignedPatients(token: widget.token!);
      final patients = List<Map<String, dynamic>>.from(data['patients'] ?? []);

      if (mounted) {
        setState(() {
          _assignedPatients = patients;
        });
      }
    } catch (e) {
      print('Error loading assigned patients: $e');
      // Don't show error - silently handle for now as this is optional feature
    }
  }

  void _loadPatientHistory(String patientId) async {
    setState(() => _loadingPatientHistory = true);

    try {
      final data = await ApiService.getPatientAlerts(
        patientId: int.parse(patientId),
        token: widget.token!,
      );

      if (mounted) {
        // Transform the alerts response to match the expected format
        final alerts = List<Map<String, dynamic>>.from(data['alerts'] ?? []);

        // Group alerts by type for display
        final groupedAlerts = {
          'seizure_events':
              alerts.where((a) => a['alert_type'] == 'seizure').toList(),
          'cardiac_events':
              alerts.where((a) => a['alert_type'] == 'cardiac').toList(),
          'alerts':
              alerts
                  .where(
                    (a) =>
                        a['alert_type'] != 'seizure' &&
                        a['alert_type'] != 'cardiac',
                  )
                  .toList(),
        };

        setState(() {
          _patientHistory = groupedAlerts;
          _loadingPatientHistory = false;
        });
      }
    } catch (e) {
      print('Error loading patient history: $e');
      if (mounted) {
        setState(() => _loadingPatientHistory = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    }
  }

  void _logout() {
    showDialog(
      context: context,
      builder:
          (BuildContext context) => AlertDialog(
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
                    context,
                    '/login',
                    (route) => false,
                  );
                },
                child: const Text(
                  'Logout',
                  style: TextStyle(color: AppTheme.accentColor),
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$_doctorName - Doctor'),
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
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(_errorMessage!),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadDoctorData,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
              : Column(
                children: [
                  Container(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildTabButton(0, 'Prescriptions', Icons.description),
                        _buildTabButton(1, 'Patients', Icons.people),
                        _buildTabButton(
                          2,
                          'Notifications',
                          Icons.notifications,
                        ),
                        _buildTabButton(3, 'Account', Icons.person),
                      ],
                    ),
                  ),
                  Expanded(
                    child:
                        _selectedTabIndex == 0
                            ? _buildPrescriptionsTab()
                            : _selectedTabIndex == 1
                            ? _buildPatientsTab()
                            : _selectedTabIndex == 2
                            ? _buildNotificationsTab()
                            : _buildAccountTab(),
                  ),
                ],
              ),
    );
  }

  Widget _buildTabButton(int index, String label, IconData icon) {
    final isSelected = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTabIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color:
                isSelected
                    ? AppTheme.primaryColor
                    : AppTheme.textSecondaryColor,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color:
                  isSelected
                      ? AppTheme.primaryColor
                      : AppTheme.textSecondaryColor,
            ),
          ),
          if (isSelected)
            Container(
              height: 3,
              width: 30,
              margin: const EdgeInsets.only(top: 4),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPrescriptionsTab() {
    // If pharmacy selected, show prescription form
    if (_selectedPharmacyForPrescription != null) {
      return _buildPrescriptionForm();
    }

    // Otherwise show pharmacy search
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Search Pharmacy',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 12),

          // Pharmacy Search Field (Live Search - Local Filter)
          TextField(
            controller: _pharmacySearchController,
            onChanged: (query) {
              setState(() {
                if (query.isEmpty) {
                  // Show all pharmacies if search is empty
                  _pharmacySearchResults = _allPharmacies;
                  _isPharmacySearching = false;
                } else {
                  // Filter pharmacies locally based on name
                  _isPharmacySearching = true;
                  _pharmacySearchResults =
                      _allPharmacies.where((pharmacy) {
                        final name =
                            (pharmacy['pharmacy_name'] ?? '')
                                .toString()
                                .toLowerCase();
                        final district =
                            (pharmacy['district'] ?? '')
                                .toString()
                                .toLowerCase();
                        final province =
                            (pharmacy['province'] ?? '')
                                .toString()
                                .toLowerCase();
                        final searchLower = query.toLowerCase();

                        return name.contains(searchLower) ||
                            district.contains(searchLower) ||
                            province.contains(searchLower);
                      }).toList();
                  _isPharmacySearching = false;
                }
              });
            },
            decoration: InputDecoration(
              labelText: 'Search pharmacy name',
              hintText: 'Type pharmacy name...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              prefixIcon: const Icon(Icons.location_on),
              suffixIcon:
                  _isPharmacySearching
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                      : null,
            ),
          ),
          const SizedBox(height: 16),

          // Search Results - Pharmacy Cards
          if (_pharmacySearchResults.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Found ${_pharmacySearchResults.length} pharmacies',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
                const SizedBox(height: 12),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _pharmacySearchResults.length,
                  itemBuilder: (context, index) {
                    final pharmacy = _pharmacySearchResults[index];
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedPharmacyForPrescription = pharmacy;
                        });
                      },
                      child: Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.local_pharmacy,
                                    color: AppTheme.primaryColor,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          pharmacy['pharmacy_name'] ??
                                              'Unknown',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                            color: AppTheme.textPrimaryColor,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${pharmacy['district'] ?? 'N/A'}, ${pharmacy['province'] ?? 'N/A'}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppTheme.textSecondaryColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(
                                    Icons.arrow_forward,
                                    color: AppTheme.primaryColor,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            )
          else if (_pharmacySearchController!.text.isNotEmpty &&
              !_isPharmacySearching)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(
                      Icons.search_off,
                      size: 48,
                      color: AppTheme.textSecondaryColor.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No pharmacies found',
                      style: TextStyle(
                        color: AppTheme.textSecondaryColor,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 24),

          // Recent Prescriptions Section
          const Text(
            'Recent Prescriptions',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 12),

          if (_prescriptions.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  'No prescriptions sent yet',
                  style: TextStyle(
                    color: AppTheme.textSecondaryColor,
                    fontSize: 14,
                  ),
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _prescriptions.length,
              itemBuilder: (context, index) {
                final prescription = _prescriptions[index];
                return _buildPrescriptionCard(prescription);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildPrescriptionForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with back button
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    _selectedPharmacyForPrescription = null;
                    _selectedPatientForPrescription = null;
                    _prescriptionInstructionsController.clear();
                    _pharmacySearchResults = [];
                    _pharmacySearchController?.clear();
                  });
                },
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Digital Prescription',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _selectedPharmacyForPrescription!['pharmacy_name'] ??
                          'Pharmacy',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Selected Pharmacy Card
          Card(
            color: AppTheme.primaryColor.withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  const Icon(
                    Icons.local_pharmacy,
                    color: AppTheme.primaryColor,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedPharmacyForPrescription!['pharmacy_name'] ??
                              'Unknown',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        Text(
                          '${_selectedPharmacyForPrescription!['district'] ?? 'N/A'}, ${_selectedPharmacyForPrescription!['province'] ?? 'N/A'}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Patient Selection Dropdown
          const Text(
            'Assigned Patients',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
  value: _selectedPatientForPrescription != null
      ? (_selectedPatientForPrescription!['patient_id'] 
          ?? _selectedPatientForPrescription!['id'])?.toString()
      : null,
  items: _assignedPatients.map((patient) {
    final id = (patient['patient_id'] ?? patient['id'])?.toString() ?? '';
    return DropdownMenuItem<String>(
      value: id,
      child: Text(
        patient['full_name'] ?? 'Unknown Patient',
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }).toList(),
  onChanged: (String? newValue) {
    if (newValue != null) {
      final match = _assignedPatients.firstWhere(
        (p) => (p['patient_id'] ?? p['id'])?.toString() == newValue,
        orElse: () => {},
      );
      if (match.isNotEmpty) {
        setState(() => _selectedPatientForPrescription = match);
      }
    }
  },
  // ... rest unchanged
),
          const SizedBox(height: 12),

          // Selected Patient Info Card - PROMINENT DISPLAY
          if (_selectedPatientForPrescription != null &&
              _selectedPatientForPrescription!.isNotEmpty)
            Card(
              elevation: 2,
              color: AppTheme.primaryColor,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '✓ ${_selectedPatientForPrescription!['full_name'] ?? 'Patient'}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Age: ${_selectedPatientForPrescription!['age'] ?? 'N/A'}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Phone: ${_selectedPatientForPrescription!['phone_number'] ?? 'N/A'}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                border: Border.all(color: Colors.orange[200]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '⚠ Please select a patient first',
                style: TextStyle(
                  color: Colors.orange[700],
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          const SizedBox(height: 20),

          // Prescription Details Field
          const Text(
            'Medicines & Details',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _prescriptionInstructionsController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Medicine name, Quantity, Coordinates/Ambulance',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              prefixIcon: const Icon(
                Icons.medication,
                color: AppTheme.primaryColor,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Instructions/Notes Field
          const Text(
            'Additional Instructions',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _prescriptionNotesController,
            maxLines: 2,
            decoration: InputDecoration(
              hintText: 'Optional instructions',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              prefixIcon: const Icon(Icons.notes, color: AppTheme.primaryColor),
            ),
          ),
          const SizedBox(height: 28),

          // Send Button - Enabled when patient selected
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
  onPressed: (_selectedPatientForPrescription == null ||
          _selectedPatientForPrescription!.isEmpty)
      ? null
      : () async {
          try {
            final rawPatientId = _selectedPatientForPrescription!['patient_id']
                ?? _selectedPatientForPrescription!['id'];
            final rawPharmacyId = _selectedPharmacyForPrescription!['pharmacy_id']
                ?? _selectedPharmacyForPrescription!['id'];

            if (rawPatientId == null || rawPharmacyId == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Error: Could not resolve patient or pharmacy ID'),
                  backgroundColor: Colors.red,
                ),
              );
              return;
            }

            final medicineLines = _prescriptionInstructionsController.text
                .split('\n')
                .where((line) => line.trim().isNotEmpty)
                .toList();

            if (medicineLines.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please enter at least one medicine'),
                  backgroundColor: Colors.orange,
                ),
              );
              return;
            }

            final notes = _prescriptionNotesController.text.trim().isNotEmpty
                ? _prescriptionNotesController.text
                : 'Digital prescription';

            print('Patient ID: $rawPatientId');
            print('Pharmacy ID: $rawPharmacyId');

            await ApiService.sendPrescription(
              patientId: rawPatientId.toString(),
              pharmacyId: rawPharmacyId.toString(),
              medicines: medicineLines,
              instructions: notes,
              token: widget.token!,
            );

            setState(() {
              _selectedPharmacyForPrescription = null;
              _selectedPatientForPrescription = null;
              _prescriptionInstructionsController.clear();
              _prescriptionNotesController.clear();
              _pharmacySearchResults = _allPharmacies;
              _pharmacySearchController?.clear();
            });

            _loadPrescriptions();

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Prescription sent successfully!'),
                  backgroundColor: AppTheme.primaryColor,
                ),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: $e'),
                  backgroundColor: AppTheme.accentColor,
                ),
              );
            }
          }
        },
  style: ElevatedButton.styleFrom(
    backgroundColor: AppTheme.primaryColor,
    disabledBackgroundColor: Colors.grey,
    padding: const EdgeInsets.symmetric(
      vertical: 11,
      horizontal: 32,
    ),
  ),
  child: const Text(
    'Send',
    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
  ),
),],
          ),
          const SizedBox(height: 12),

          // Back Button
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton(
                onPressed: () {
                  setState(() {
                    _selectedPharmacyForPrescription = null;
                    _selectedPatientForPrescription = null;
                    _prescriptionInstructionsController.clear();
                    _prescriptionNotesController.clear();
                    _pharmacySearchResults = [];
                    _pharmacySearchController?.clear();
                  });
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: 11,
                    horizontal: 32,
                  ),
                ),
                child: const Text('Back', style: TextStyle(fontSize: 14)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPrescriptionCard(Map<String, dynamic> prescription) {
    final status = prescription['status'] ?? 'pending';
    final statusColor =
        status == 'delivered'
            ? AppTheme.primaryColor
            : status == 'approved'
            ? Colors.green
            : status == 'denied'
            ? AppTheme.accentColor
            : Colors.orange;

    final medicines = prescription['medicines'] ?? [];
    final instructions = prescription['instructions'] ?? '';

    final medicinesDisplay =
        medicines is List
            ? medicines
                .map((m) {
                  if (m is String) return m;
                  if (m is Map && m['name'] != null)
                    return m['name'].toString();
                  return m.toString();
                })
                .join('\n')
            : medicines.toString();

    // Extract coordinates from medicines
    final coordinatesList = <String>[];
    if (medicines is List) {
      for (var m in medicines) {
        String medicineStr = '';
        if (m is String) {
          medicineStr = m;
        } else if (m is Map && m['name'] != null)
          medicineStr = m['name'].toString();

        if (medicineStr.isNotEmpty) {
          final parts = medicineStr.split(',');
          if (parts.length >= 3) {
            final lastPart = parts.last.trim();
            // Check if last part contains coordinates or special keyword
            if (lastPart.contains(RegExp(r'-?\d+\.\d+')) ||
                lastPart.toLowerCase() == 'ambulance') {
              coordinatesList.add(lastPart);
            }
          }
        }
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Patient name and Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '👤 ${prescription['patient_name'] ?? 'Unknown'}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: AppTheme.textPrimaryColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusColor, width: 1),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Pharmacy info
            Text(
              '${prescription['pharmacy_name'] ?? 'Unknown Pharmacy'}',
              style: const TextStyle(
                fontSize: 11,
                color: AppTheme.textSecondaryColor,
                fontStyle: FontStyle.italic,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),

            // Medicines/Prescription
            if (medicinesDisplay.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '💊 Prescription:',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                        color: AppTheme.textPrimaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      medicinesDisplay,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.textPrimaryColor,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            if (coordinatesList.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '📍 Coordinates:',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 4),
                    ...coordinatesList.map(
                      (coord) => Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Text(
                          '• $coord',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (instructions.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '📝 Instructions:',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      instructions,
                      style: const TextStyle(fontSize: 11, color: Colors.green),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 8),

            // Sent date
            Text(
              '📤 ${_formatDate(prescription['created_at'])}',
              style: const TextStyle(
                fontSize: 10,
                color: AppTheme.textSecondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientsTab() {
    // If patient selected, show their history
    if (_selectedPatient != null) {
      return _buildPatientHistoryView();
    }

    // Otherwise show patients list
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Assigned Patients',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 12),

          if (_assignedPatients.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.people,
                        size: 48,
                        color: AppTheme.textSecondaryColor.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No assigned patients',
                        style: TextStyle(
                          color: AppTheme.textSecondaryColor,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _assignedPatients.length,
              itemBuilder: (context, index) {
                final patient = _assignedPatients[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.primaryColor,
                      child: Text(
                        (patient['full_name'] ?? 'P')[0].toUpperCase(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(
                      patient['full_name'] ?? 'Unknown',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimaryColor,
                      ),
                    ),
                    subtitle: Text(
                      patient['email'] ?? 'No email',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward,
                      color: AppTheme.primaryColor,
                    ),
                    onTap: () {
                      setState(() {
                        _selectedPatient = patient;
                      });
                      final patientId = patient['patient_id'] ?? patient['id'];
                      if (patientId != null) {
                        _loadPatientHistory(patientId.toString());
                      }
                    },
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildPatientHistoryView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back button and patient name
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    _selectedPatient = null;
                    _patientHistory = null;
                  });
                },
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedPatient!['full_name'] ?? 'Patient',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimaryColor,
                      ),
                    ),
                    Text(
                      _selectedPatient!['email'] ?? '',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Loading state
          if (_loadingPatientHistory)
            const Center(child: CircularProgressIndicator())
          else if (_patientHistory == null)
            Center(
              child: Text(
                'No history data available',
                style: TextStyle(
                  color: AppTheme.textSecondaryColor,
                  fontSize: 14,
                ),
              ),
            )
          else
            Column(
              children: [
                // Seizure Events
                if ((_patientHistory!['seizure_events'] as List?)?.isNotEmpty ??
                    false)
                  _buildEventSection(
                    'Seizure Events',
                    Colors.red[100]!,
                    Colors.red[700]!,
                    _patientHistory!['seizure_events'] as List,
                  ),

                // Cardiac Events
                if ((_patientHistory!['cardiac_events'] as List?)?.isNotEmpty ??
                    false)
                  _buildEventSection(
                    'Cardiac Events',
                    Colors.orange[100]!,
                    Colors.orange[700]!,
                    _patientHistory!['cardiac_events'] as List,
                  ),

                // General Alerts
                if ((_patientHistory!['alerts'] as List?)?.isNotEmpty ?? false)
                  _buildEventSection(
                    'Alerts',
                    Colors.blue[100]!,
                    Colors.blue[700]!,
                    _patientHistory!['alerts'] as List,
                  ),

                // No events
                if (((_patientHistory!['seizure_events'] as List?)?.isEmpty ??
                        true) &&
                    ((_patientHistory!['cardiac_events'] as List?)?.isEmpty ??
                        true) &&
                    ((_patientHistory!['alerts'] as List?)?.isEmpty ?? true))
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Center(
                        child: Text(
                          'No alert history',
                          style: TextStyle(
                            color: AppTheme.textSecondaryColor,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildEventSection(
    String title,
    Color backgroundColor,
    Color borderColor,
    List<dynamic> events,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: borderColor,
          ),
        ),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: events.length,
          itemBuilder: (context, index) {
            final event = events[index] as Map<String, dynamic>;
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              color: backgroundColor,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatEventTitle(title, event),
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: borderColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Time: ${_formatDate(event['timestamp'] ?? event['sent_at'] ?? '')}',
                      style: TextStyle(
                        fontSize: 12,
                        color: borderColor.withOpacity(0.7),
                      ),
                    ),
                    _buildEventDetails(event),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildEventDetails(Map<String, dynamic> event) {
    final details = <String, String>{};

    // Extract relevant details based on event type
    if (event.containsKey('heart_rate')) {
      details['Heart Rate'] = '${event['heart_rate']} bpm';
    }
    if (event.containsKey('oxygen_level')) {
      details['O2 Level'] = '${event['oxygen_level']}%';
    }
    if (event.containsKey('temperature')) {
      details['Temperature'] = '${event['temperature']}°C';
    }
    if (event.containsKey('heart_rate_variability')) {
      details['HRV'] = event['heart_rate_variability'];
    }
    if (event.containsKey('alert_type')) {
      details['Type'] = event['alert_type'];
    }

    if (details.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        ...details.entries.map((e) {
          return Text(
            '${e.key}: ${e.value}',
            style: const TextStyle(fontSize: 11),
          );
        }),
      ],
    );
  }

  String _formatEventTitle(String type, Map<String, dynamic> event) {
    if (type == 'Alerts') {
      return event['alert_type'] ?? 'Alert';
    } else if (type == 'Seizure Events') {
      return 'Seizure Event';
    } else if (type == 'Cardiac Events') {
      return 'Cardiac Event';
    }
    return type;
  }

  String _formatDate(String? dateString) {
  if (dateString == null || dateString.isEmpty) return 'Unknown';
  try {
    final date = DateTime.parse(dateString);
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  } catch (e) {
    return dateString;
  }
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
                    'Doctor Information',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow('Full Name', _doctorData['full_name'] ?? ''),
                  _buildInfoRow('Email', _doctorData['email'] ?? ''),
                  _buildInfoRow('Phone', _doctorData['phone_number'] ?? ''),
                  _buildInfoRow(
                    'Specialization',
                    _doctorData['specialization'] ?? '',
                  ),
                  _buildInfoRow(
                    'License Number',
                    _doctorData['license_number'] ?? '',
                  ),
                  _buildInfoRow(
                    'Hospital/Clinic',
                    _doctorData['hospital_clinic'] ?? '',
                  ),
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
                color:
                    value.isEmpty
                        ? AppTheme.textSecondaryColor
                        : AppTheme.textPrimaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Notifications',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.notifications,
                      size: 48,
                      color: AppTheme.textSecondaryColor.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'IoT Device Configuration',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Real-time notifications from wearable devices and sensors will appear here once devices are configured.',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondaryColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'To enable notifications:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '1. Pair IoT device with patient account\n2. Sync health metrics\n3. Grant permission for alerts',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondaryColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditDialog() {
    final fullNameController = TextEditingController(
      text: _doctorData['full_name'] ?? '',
    );
    final phoneController = TextEditingController(
      text: _doctorData['phone_number'] ?? '',
    );
    final specializationController = TextEditingController(
      text: _doctorData['specialization'] ?? '',
    );
    final licenseController = TextEditingController(
      text: _doctorData['license_number'] ?? '',
    );
    final hospitalController = TextEditingController(
      text: _doctorData['hospital_clinic'] ?? '',
    );

    final parentContext = context;

    showDialog(
      context: context,
      builder:
          (BuildContext dialogContext) => AlertDialog(
            title: const Text('Edit Doctor Information'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: fullNameController,
                    decoration: InputDecoration(
                      labelText: 'Full Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: phoneController,
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: specializationController,
                    decoration: InputDecoration(
                      labelText: 'Specialization',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: licenseController,
                    decoration: InputDecoration(
                      labelText: 'License Number',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: hospitalController,
                    decoration: InputDecoration(
                      labelText: 'Hospital/Clinic',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  fullNameController.dispose();
                  phoneController.dispose();
                  specializationController.dispose();
                  licenseController.dispose();
                  hospitalController.dispose();
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  try {
                    await ApiService.updateDoctorProfile(
                      fullName: fullNameController.text,
                      phoneNumber: phoneController.text,
                      specialization: specializationController.text,
                      licenseNumber: licenseController.text,
                      hospitalClinic: hospitalController.text,
                      token: widget.token!,
                    );

                    if (mounted) {
                      Navigator.pop(dialogContext);
                    }

                    _loadDoctorData();
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
                  phoneController.dispose();
                  specializationController.dispose();
                  licenseController.dispose();
                  hospitalController.dispose();
                },
                child: const Text('Save'),
              ),
            ],
          ),
    );
  }
}
