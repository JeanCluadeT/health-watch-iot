import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import 'otp_verification_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _phoneNumberController = TextEditingController();

  // Patient specific
  final _ageController = TextEditingController();
  final _medicalConditionController = TextEditingController();

  // Doctor specific
  final _licenseNumberController = TextEditingController();

  // Pharmacy specific
  final _provinceController = TextEditingController();
  final _districtController = TextEditingController();
  final _citySectorController = TextEditingController();

  String _selectedRole = 'patient';
  bool _isLoading = false;
  String? _errorMessage;
  bool _showPassword = false;

  final List<String> _roles = [
    'patient',
    'doctor',
    'family_member',
    'pharmacy',
  ];

  final Map<String, IconData> _roleIcons = {
    'patient': Icons.person,
    'doctor': Icons.medical_services,
    'family_member': Icons.group,
    'pharmacy': Icons.local_pharmacy,
  };

  void _handleSignup() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      switch (_selectedRole) {
        case 'patient':
          await ApiService.registerPatient(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            fullName: _fullNameController.text.trim(),
            phoneNumber: _phoneNumberController.text.trim(),
            age: int.parse(_ageController.text),
            medicalCondition: _medicalConditionController.text.trim(),
          );
          break;
        case 'doctor':
          await ApiService.registerDoctor(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            fullName: _fullNameController.text.trim(),
            phoneNumber: _phoneNumberController.text.trim(),
            licenseNumber: _licenseNumberController.text.trim(),
          );
          break;
        case 'family_member':
          await ApiService.registerFamilyMember(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            fullName: _fullNameController.text.trim(),
            phoneNumber: _phoneNumberController.text.trim(),
          );
          break;
        case 'pharmacy':
          await ApiService.registerPharmacy(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            pharmacyName: _fullNameController.text.trim(),
            phoneNumber: _phoneNumberController.text.trim(),
            province: _provinceController.text.trim(),
            district: _districtController.text.trim(),
            citySector: _citySectorController.text.trim(),
          );
          break;
        default:
          throw Exception('Invalid role selected');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registration successful! Check your email for OTP.'),
            backgroundColor: AppTheme.primaryColor,
          ),
        );
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder:
                (context) => OtpVerificationScreen(
                  email: _emailController.text.trim(),
                  fullName: _fullNameController.text.trim(),
                ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    _phoneNumberController.dispose();
    _ageController.dispose();
    _medicalConditionController.dispose();
    _licenseNumberController.dispose();
    _provinceController.dispose();
    _districtController.dispose();
    _citySectorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: AppTheme.accentColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.app_registration,
                        size: 36,
                        color: AppTheme.accentColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Join HealthGuard',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Create your account to get started',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Common Fields Section
              const Text(
                'Basic Information',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimaryColor,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email Address',
                  prefixIcon: const Icon(Icons.email_outlined, size: 20),
                  hintText: 'Enter your email',
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outlined, size: 20),
                  hintText: 'Enter your password',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _showPassword ? Icons.visibility : Icons.visibility_off,
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() {
                        _showPassword = !_showPassword;
                      });
                    },
                  ),
                ),
                obscureText: !_showPassword,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _fullNameController,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: const Icon(Icons.person_outline, size: 20),
                  hintText: 'Enter your full name',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _phoneNumberController,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: const Icon(Icons.phone_outlined, size: 20),
                  hintText: 'Enter your phone number',
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 18),
              // Role Selection
              const Text(
                'Select Your Role',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimaryColor,
                ),
              ),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children:
                      _roles.map((role) {
                        final isSelected = _selectedRole == role;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedRole = role;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 10),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  isSelected
                                      ? AppTheme.primaryColor
                                      : Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color:
                                    isSelected
                                        ? AppTheme.primaryColor
                                        : AppTheme.dividerColor(1.0),
                                width: 1.5,
                              ),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  _roleIcons[role],
                                  color:
                                      isSelected
                                          ? Colors.white
                                          : AppTheme.primaryColor,
                                  size: 22,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  role.replaceAll('_', ' '),
                                  style: TextStyle(
                                    color:
                                        isSelected
                                            ? Colors.white
                                            : AppTheme.textPrimaryColor,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                ),
              ),
              const SizedBox(height: 18),
              // Role-Specific Fields
              if (_selectedRole == 'patient') ...[
                _buildSectionTitle('Patient Information'),
                const SizedBox(height: 10),
                TextField(
                  controller: _ageController,
                  decoration: InputDecoration(
                    labelText: 'Age',
                    prefixIcon: const Icon(Icons.cake_outlined, size: 20),
                    hintText: 'Enter your age',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _medicalConditionController,
                  decoration: InputDecoration(
                    labelText: 'Medical Condition',
                    prefixIcon: const Icon(Icons.health_and_safety, size: 20),
                    hintText: 'e.g., Epilepsy',
                  ),
                ),
              ] else if (_selectedRole == 'doctor') ...[
                _buildSectionTitle('Doctor Information'),
                const SizedBox(height: 10),
                TextField(
                  controller: _licenseNumberController,
                  decoration: InputDecoration(
                    labelText: 'Medical License Number',
                    prefixIcon: const Icon(Icons.card_membership, size: 20),
                    hintText: 'Enter your license number',
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppTheme.dividerColor(1.0)),
                    borderRadius: BorderRadius.circular(8),
                    color: AppTheme.backgroundColor,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.upload_file,
                        color: AppTheme.primaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'Upload license document later',
                          style: TextStyle(
                            color: AppTheme.textSecondaryColor,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else if (_selectedRole == 'family_member') ...[
                _buildSectionTitle('Family Member Information'),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundColor,
                    border: Border.all(color: AppTheme.dividerColor(1.0)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.info_outlined,
                        color: AppTheme.primaryColor,
                        size: 20,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'You will specify your relationship when a patient assigns you',
                          style: TextStyle(
                            color: AppTheme.textSecondaryColor,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else if (_selectedRole == 'pharmacy') ...[
                _buildSectionTitle('Pharmacy Information'),
                const SizedBox(height: 10),
                TextField(
                  controller: _provinceController,
                  decoration: InputDecoration(
                    labelText: 'Province',
                    prefixIcon: const Icon(
                      Icons.location_on_outlined,
                      size: 20,
                    ),
                    hintText: 'Enter province',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _districtController,
                  decoration: InputDecoration(
                    labelText: 'District',
                    prefixIcon: const Icon(
                      Icons.location_on_outlined,
                      size: 20,
                    ),
                    hintText: 'Enter district',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _citySectorController,
                  decoration: InputDecoration(
                    labelText: 'City/Sector',
                    prefixIcon: const Icon(
                      Icons.location_on_outlined,
                      size: 20,
                    ),
                    hintText: 'Enter city or sector',
                  ),
                ),
              ],
              const SizedBox(height: 16),
              // Error Message
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.accentColor.withOpacity(0.1),
                    border: Border.all(color: AppTheme.accentColor),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: AppTheme.accentColor,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(
                            color: AppTheme.accentColor,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              if (_errorMessage != null) const SizedBox(height: 16),
              // Sign Up Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSignup,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child:
                      _isLoading
                          ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                          : const Text(
                            'Create Account',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                ),
              ),
              const SizedBox(height: 12),
              // Login Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Already have an account? ',
                    style: TextStyle(
                      color: AppTheme.textSecondaryColor,
                      fontSize: 12,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacementNamed('/login');
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                    ),
                    child: const Text(
                      'Sign In',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppTheme.textPrimaryColor,
      ),
    );
  }
}
