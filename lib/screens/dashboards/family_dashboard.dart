import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../screens/dashboard_screen.dart';
import '../../screens/history_screen.dart';
import '../../screens/charts_screen.dart';
import '../../screens/stats_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class FamilyDashboard extends StatefulWidget {
  final String? userId;
  final String? token;
  final String? familyId;

  const FamilyDashboard({
    super.key,
    this.userId,
    this.token,
    this.familyId,
  });

  @override
  State<FamilyDashboard> createState() => _FamilyDashboardState();
}

class _FamilyDashboardState extends State<FamilyDashboard> {
  Map<String, dynamic>? _familyMemberData;
  Map<String, dynamic>? _assignedPatient;
  bool _isLoading = true;
  String? _errorMessage;
  int _selectedTabIndex = 0;

  Map<String, dynamic>? _latestAlert;
  bool _loadingNotification = false;

  List<Map<String, dynamic>> _patientPrescriptions = [];
bool _isPatientPrescriptionsLoading = false;

  late TextEditingController _nameController;
  late TextEditingController _phoneController;

  // ── Monitor ──────────────────────────────────────────────────
  int _monitorSubIndex = 0;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _loadDashboardData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _loadPatientPrescriptions() async {
  if (_assignedPatient == null || widget.token == null) return;
  setState(() => _isPatientPrescriptionsLoading = true);
  try {
    final data = await ApiService.getPrescriptionHistory(token: widget.token!);
    final prescriptions = List<Map<String, dynamic>>.from(
      data['prescriptions'] ?? [],
    );
    if (mounted) {
      setState(() {
        _patientPrescriptions = prescriptions;
        _isPatientPrescriptionsLoading = false;
      });
    }
  } catch (e) {
    if (mounted) setState(() => _isPatientPrescriptionsLoading = false);
  }
}

  void _loadLatestNotification() async {
  if (_assignedPatient == null) return;
  setState(() => _loadingNotification = true);
  try {
    final patientId = _assignedPatient!['patient_id'] ?? _assignedPatient!['id'];
    if (patientId == null) return;

    final data = await ApiService.getPatientAlerts(
      patientId: int.parse(patientId.toString()),
      token: widget.token!,
    );

    final alerts = List<Map<String, dynamic>>.from(data['alerts'] ?? []);
    alerts.sort((a, b) {
      final ta = a['timestamp'] ?? a['sent_at'] ?? '';
      final tb = b['timestamp'] ?? b['sent_at'] ?? '';
      return tb.compareTo(ta);
    });

    if (mounted) {
      setState(() {
        _latestAlert = alerts.isNotEmpty ? alerts.first : null;
        _loadingNotification = false;
      });
    }
  } catch (e) {
    if (mounted) setState(() => _loadingNotification = false);
  }
}

  void _loadDashboardData() async {
    if (widget.userId == null ||
        widget.token == null ||
        widget.familyId == null) {
      setState(() {
        _errorMessage = 'Missing user ID, token, or family ID';
        _isLoading = false;
      });
      return;
    }

    try {
      final profileData = await ApiService.getFamilyMemberProfile(
        token: widget.token!,
      );

      setState(() {
        _familyMemberData = profileData['family_member'];
        _nameController.text = _familyMemberData?['full_name'] ?? '';
        _phoneController.text = _familyMemberData?['phone_number'] ?? '';
      });

      // try {
      //   final patientData = await ApiService.getAssignedPatient(
      //     token: widget.token!,
      //   );
      //   setState(() {
      //     _assignedPatient = patientData['patient'];
      //     _isLoading = false;
      //   });
      // } catch (e) {
      //   setState(() {
      //     _assignedPatient = null;
      //     _isLoading = false;
      //   });
      // }

      try {
  final patientData = await ApiService.getAssignedPatient(
    token: widget.token!,
  );
  setState(() {
    _assignedPatient = patientData['patient'];
    _isLoading = false;
  });
  _loadLatestNotification(); 
  _loadPatientPrescriptions(); 
} catch (e) {
  setState(() {
    _assignedPatient = null;
    _isLoading = false;
  });
}
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
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
              ApiService.logout();
              Navigator.pushReplacementNamed(context, '/login');
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
        title: const Text('Family Dashboard'),
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _logout,
              tooltip: 'Logout',
            ),
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
                          size: 64, color: AppTheme.accentColor),
                      const SizedBox(height: 16),
                      Text('Error: $_errorMessage',
                          textAlign: TextAlign.center,
                          style:
                              const TextStyle(color: AppTheme.accentColor)),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _loadDashboardData,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeroSection(),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildTabBar(),
                            const SizedBox(height: 16),
                            if (_selectedTabIndex == 0)
                              _buildAssignedPatientTab(),
                            if (_selectedTabIndex == 1)
                              _buildNotificationsTab(),
                            if (_selectedTabIndex == 2) _buildAccountTab(),
                            if (_selectedTabIndex == 3) _buildMonitorTab(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildHeroSection() {
    final initials = (_familyMemberData?['full_name'] ?? 'F')
        .split(' ')
        .map((e) => e.isNotEmpty ? e[0] : '')
        .join()
        .toUpperCase();

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryColor, AppTheme.accentColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.white.withOpacity(0.3),
                child: Text(initials,
                    style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello, ${_familyMemberData?['full_name']?.split(' ')[0] ?? 'Family'}! 👋',
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.group,
                              color: Colors.white, size: 14),
                          const SizedBox(width: 6),
                          Text(
                            _familyMemberData?['relationship'] ??
                                'Family Member',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildTabButton(0, 'Assigned Patient', Icons.person),
          _buildTabButton(1, 'Notifications', Icons.notifications),
          _buildTabButton(2, 'Account', Icons.settings),
          // _buildTabButton(3, 'Monitor', Icons.monitor_heart),
        ],
      ),
    );
  }

  Widget _buildTabButton(int index, String label, IconData icon) {
    final isSelected = _selectedTabIndex == index;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        selected: isSelected,
        label: Row(
          children: [
            Icon(icon, size: 16),
            const SizedBox(width: 6),
            Text(label),
          ],
        ),
        onSelected: (_) => setState(() => _selectedTabIndex = index),
        backgroundColor: Colors.white,
        selectedColor: AppTheme.primaryColor,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : AppTheme.textPrimaryColor,
          fontWeight: FontWeight.w600,
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
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.75,
          child: _monitorSubIndex == 0
              ? DashboardScreen(token: widget.token, userId: widget.userId)
              : _monitorSubIndex == 1
                  ? HistoryScreen(token: widget.token, userId: widget.userId)
                  : _monitorSubIndex == 2
                      ? ChartsScreen(
                          token: widget.token, userId: widget.userId)
                      : StatsScreen(
                          token: widget.token, userId: widget.userId),
        ),
      ],
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

  Widget _buildAssignedPatientTab() {
    if (_assignedPatient == null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(Icons.person_outline,
                size: 48, color: AppTheme.textSecondaryColor),
            const SizedBox(height: 8),
            const Text('No patient assigned to you',
                style: TextStyle(color: AppTheme.textSecondaryColor)),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Your Assigned Patient',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimaryColor)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.cyan.withOpacity(0.1),
            border: Border.all(color: Colors.cyan, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                        color: Colors.cyan,
                        borderRadius: BorderRadius.circular(25)),
                    child: const Icon(Icons.person, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _assignedPatient?['full_name'] ?? 'Patient',
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimaryColor),
                        ),
                        Text(
                          'Age: ${_assignedPatient?['age'] ?? 'N/A'} years',
                          style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondaryColor),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildPatientInfoField('Email', _assignedPatient?['email']),
              _buildPatientInfoField(
                  'Phone', _assignedPatient?['phone_number']),
              _buildPatientInfoField(
                  'Medical Condition', _assignedPatient?['medical_condition']),
            ],
          ),
        ),
        // Replace everything from const SizedBox(height: 24) at the bottom to the end of the Column
const SizedBox(height: 24),
const Text(
  'Medical History',
  style: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: AppTheme.textPrimaryColor),
),
const SizedBox(height: 12),
if (_isPatientPrescriptionsLoading)
  const Center(child: CircularProgressIndicator())
else if (_patientPrescriptions.isEmpty)
  Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.orange.withOpacity(0.1),
      border: Border.all(color: Colors.orange),
      borderRadius: BorderRadius.circular(8),
    ),
    child: const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.history, color: Colors.orange, size: 28),
        SizedBox(height: 8),
        Text('No prescription history yet',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimaryColor)),
      ],
    ),
  )
else
  ListView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    itemCount: _patientPrescriptions.length,
    itemBuilder: (context, index) =>
        _buildPatientHistoryCard(_patientPrescriptions[index]),
  ),
      ],
    );
  }
Widget _buildPatientHistoryCard(Map<String, dynamic> prescription) {
  final prescriptionId = prescription['prescription_id'] ?? 'N/A';
  final status = prescription['status'] ?? 'unknown';
  final doctorName = prescription['doctor_name'] ?? 'Unknown Doctor';
  final medicines = prescription['medicines'] ?? [];
  final instructions = prescription['instructions'] ?? '';
  final approvedAt = prescription['approved_at'];
  final deliveredAt = prescription['delivered_at'];
  final deniedReason = prescription['denied_reason'];

  Color statusColor = Colors.grey;
  if (status == 'approved') statusColor = Colors.blue;
  if (status == 'delivered') statusColor = Colors.green;
  if (status == 'denied' || status == 'rejected') statusColor = Colors.red;
  if (status == 'pending') statusColor = Colors.orange;

  String actionDetails = '';
  if (status == 'approved' && approvedAt != null)
    actionDetails = 'Approved: ${_formatDate(approvedAt)}';
  if (status == 'delivered' && deliveredAt != null)
    actionDetails = 'Delivered: ${_formatDate(deliveredAt)}';
  if ((status == 'denied' || status == 'rejected') && deniedReason != null)
    actionDetails = 'Denied: $deniedReason';

  return Card(
    margin: const EdgeInsets.only(bottom: 12),
    elevation: 1,
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Rx #$prescriptionId',
                  style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: AppTheme.textPrimaryColor)),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: statusColor),
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
          const SizedBox(height: 8),
          Text('Dr. $doctorName',
              style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondaryColor,
                  fontStyle: FontStyle.italic)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(6)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('💊 Medicines:',
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: AppTheme.textPrimaryColor)),
                const SizedBox(height: 6),
                ...medicines.map<Widget>((med) {
                  String medicineText;
                  if (med is String) {
                    medicineText = med;
                  } else if (med is Map && med['name'] != null) {
                    medicineText = med['name'].toString();
                  } else {
                    medicineText = med.toString();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 3),
                    child: Text('• $medicineText',
                        style: const TextStyle(
                            fontSize: 12, color: AppTheme.textPrimaryColor)),
                  );
                }).toList(),
              ],
            ),
          ),
          if (instructions.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text('📝 $instructions',
                style: const TextStyle(
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                    color: AppTheme.textSecondaryColor)),
          ],
          if (actionDetails.isNotEmpty) ...[
            const SizedBox(height: 8),
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
  Widget _buildPatientInfoField(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondaryColor,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(value ?? 'N/A',
              style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.textPrimaryColor,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

 Widget _buildNotificationsTab() {
  if (_loadingNotification) {
    return const Center(child: CircularProgressIndicator());
  }

  if (_latestAlert == null) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        border: Border.all(color: Colors.blue),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(Icons.notifications_off,
              size: 48, color: AppTheme.textSecondaryColor.withOpacity(0.5)),
          const SizedBox(height: 12),
          const Text('No alerts yet',
              style: TextStyle(color: AppTheme.textSecondaryColor, fontSize: 14)),
        ],
      ),
    );
  }

  return _buildLatestAlertCard(_latestAlert!);
}

Widget _buildLatestAlertCard(Map<String, dynamic> alert) {
  final alertType = alert['alert_type'] ?? 'alert';
  final message = alert['message'] ?? '';
  final timestamp = _formatDate(alert['timestamp'] ?? alert['sent_at'] ?? '');

  final Color cardColor;
  final Color borderColor;
  final IconData alertIcon;

  if (alertType == 'seizure') {
    cardColor = Colors.red[50]!;
    borderColor = Colors.red[700]!;
    alertIcon = Icons.warning_amber_rounded;
  } else if (alertType == 'cardiac') {
    cardColor = Colors.orange[50]!;
    borderColor = Colors.orange[700]!;
    alertIcon = Icons.favorite_border;
  } else {
    cardColor = Colors.blue[50]!;
    borderColor = Colors.blue[700]!;
    alertIcon = Icons.notifications_active;
  }

  // Extract URL if present
  final urlRegex = RegExp(r'(https?:\/\/[^\s]+)');
  final urlMatch = urlRegex.firstMatch(message);
  final textPart = urlMatch != null
      ? message.substring(0, urlMatch.start).trim()
      : message;
  final url = urlMatch?.group(0);

  return Card(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: BorderSide(color: borderColor, width: 1.5),
    ),
    color: cardColor,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(alertIcon, color: borderColor, size: 22),
              const SizedBox(width: 8),
              Text(
                alertType.toUpperCase(),
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: borderColor),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: borderColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('LATEST',
                    style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: borderColor)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.person, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                _assignedPatient?['full_name'] ?? 'Patient',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: borderColor.withOpacity(0.8)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (textPart.isNotEmpty)
            Text(textPart,
                style: TextStyle(
                    fontSize: 13, color: borderColor.withOpacity(0.85))),
          if (url != null) ...[
            const SizedBox(height: 6),
            GestureDetector(
              onTap: () async {
                final uri = Uri.parse(url.trim());
                try {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Could not open link: $e')),
                    );
                  }
                }
              },
              child: Text(url,
                  style: const TextStyle(
                      fontSize: 12,
                      color: Colors.blue,
                      decoration: TextDecoration.underline)),
            ),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.access_time, size: 12, color: Colors.grey),
              const SizedBox(width: 4),
              Text(timestamp,
                  style: const TextStyle(
                      fontSize: 11, color: AppTheme.textSecondaryColor)),
            ],
          ),
        ],
      ),
    ),
  );
}

String _formatDate(String? dateString) {
  if (dateString == null || dateString.isEmpty) return 'Unknown';
  try {
    final date = DateTime.parse(dateString);
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  } catch (_) {
    return dateString;
  }
}
  Widget _buildAccountTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Account Information',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimaryColor)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: AppTheme.dividerColor(1.0)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildReadOnlyField('Email', _familyMemberData?['email']),
              const SizedBox(height: 16),
              _buildReadOnlyField(
                  'Relationship', _familyMemberData?['relationship']),
              const SizedBox(height: 16),
              _buildTextField('Full Name', _nameController),
              const SizedBox(height: 16),
              _buildTextField('Phone Number', _phoneController),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _updateProfile,
                  style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: AppTheme.primaryColor),
                  child: const Text('Save Changes',
                      style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReadOnlyField(String label, String? value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondaryColor,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.dividerColor(1.0))),
          child: Text(value ?? 'N/A',
              style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.textPrimaryColor,
                  fontWeight: FontWeight.w500)),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondaryColor,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              hintText: 'Enter $label',
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 10)),
        ),
      ],
    );
  }

  void _updateProfile() async {
    try {
      await ApiService.updateFamilyMemberProfile(
        fullName: _nameController.text,
        phoneNumber: _phoneController.text,
        token: widget.token!,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: AppTheme.primaryColor),
      );
      _loadDashboardData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppTheme.accentColor),
      );
    }
  }
}