import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';

class ApiService {

  static String get baseUrl {
  final protocol = dotenv.env['API_PROTOCOL'] ?? 'http';
  final host = dotenv.env['API_HOST'] ?? 'localhost';
  final port = dotenv.env['API_PORT'] ?? '';
  final basePath = dotenv.env['API_BASE_PATH'] ?? 'api';

  // Only include port if one is specified
  final authority = port.isNotEmpty ? '$host:$port' : host;

  return '$protocol://$authority/$basePath';
}

  // Auth Endpoints
  static Future<Map<String, dynamic>> registerPatient({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
    required int age,
    required String medicalCondition,
  }) async {
    try {
      print('Attempting to register patient to: $baseUrl/auth/register/patient');
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register/patient'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'full_name': fullName,
          'phone_number': phoneNumber,
          'age': age,
          'medical_condition': medicalCondition,
        }),
      ).timeout(Duration(seconds: 10));

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception(jsonDecode(response.body)['error'] ?? 'Registration failed');
      }
    } catch (e) {
      print('Error in registerPatient: $e');
      throw Exception('Error: $e');
    }
  }

  static Future<Map<String, dynamic>> registerDoctor({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
    required String licenseNumber,
  }) async {
    try {
      print('Attempting to register doctor to: $baseUrl/auth/register/doctor');
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register/doctor'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'full_name': fullName,
          'phone_number': phoneNumber,
          'license_number': licenseNumber,
        }),
      ).timeout(Duration(seconds: 10));

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception(jsonDecode(response.body)['error'] ?? 'Registration failed');
      }
    } catch (e) {
      print('Error in registerDoctor: $e');
      throw Exception('Error: $e');
    }
  }

  static Future<Map<String, dynamic>> registerFamilyMember({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
  }) async {
    try {
      print('Attempting to register family member to: $baseUrl/auth/register/family');
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register/family'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'full_name': fullName,
          'phone_number': phoneNumber,
        }),
      ).timeout(Duration(seconds: 10));

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception(jsonDecode(response.body)['error'] ?? 'Registration failed');
      }
    } catch (e) {
      print('Error in registerFamilyMember: $e');
      throw Exception('Error: $e');
    }
  }

  static Future<Map<String, dynamic>> registerPharmacy({
    required String email,
    required String password,
    required String pharmacyName,
    required String phoneNumber,
    required String province,
    required String district,
    required String citySector,
  }) async {
    try {
      print('Attempting to register pharmacy to: $baseUrl/auth/register/pharmacy');
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register/pharmacy'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'pharmacy_name': pharmacyName,
          'phone_number': phoneNumber,
          'province': province,
          'district': district,
          'city_sector': citySector,
        }),
      ).timeout(Duration(seconds: 10));

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception(jsonDecode(response.body)['error'] ?? 'Registration failed');
      }
    } catch (e) {
      print('Error in registerPharmacy: $e');
      throw Exception('Error: $e');
    }
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      print('Attempting to login to: $baseUrl/auth/login');
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      ).timeout(Duration(seconds: 10));

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(jsonDecode(response.body)['error'] ?? 'Login failed');
      }
    } catch (e) {
      print('Error in login: $e');
      throw Exception('Error: $e');
    }
  }

  // OTP Verification Endpoints
  static Future<Map<String, dynamic>> verifyOtp({
    required String email,
    required String otp,
  }) async {
    try {
      print('Attempting to verify OTP for: $email');
      final response = await http.post(
        Uri.parse('$baseUrl/auth/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'otp': otp,
        }),
      ).timeout(const Duration(seconds: 10));

      print('OTP Verification Response status: ${response.statusCode}');
      print('OTP Verification Response body: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(jsonDecode(response.body)['error'] ?? 'OTP verification failed');
      }
    } catch (e) {
      print('Error in verifyOtp: $e');
      throw Exception('Error: $e');
    }
  }

  static Future<Map<String, dynamic>> resendOtp({
    required String email,
  }) async {
    try {
      print('Attempting to resend OTP for: $email');
      final response = await http.post(
        Uri.parse('$baseUrl/auth/resend-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
        }),
      ).timeout(const Duration(seconds: 10));

      print('Resend OTP Response status: ${response.statusCode}');
      print('Resend OTP Response body: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(jsonDecode(response.body)['error'] ?? 'Failed to resend OTP');
      }
    } catch (e) {
      print('Error in resendOtp: $e');
      throw Exception('Error: $e');
    }
  }

  // ============ PATIENT ENDPOINTS ============

  // Get patient profile data
  static Future<Map<String, dynamic>> getPatientProfile({
    required String userId,
    required String token,
  }) async {
    try {
      print('Fetching patient profile for user: $userId');
      final response = await http.get(
        Uri.parse('$baseUrl/patient/profile/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      print('Patient Profile Response: ${response.statusCode}');
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(jsonDecode(response.body)['error'] ?? 'Failed to fetch patient profile');
      }
    } catch (e) {
      print('Error in getPatientProfile: $e');
      throw Exception('Error: $e');
    }
  }

  // Get list of doctors for assignment
  static Future<Map<String, dynamic>> getDoctors({
    required String token,
  }) async {
    try {
      print('Fetching doctor list');
      final response = await http.get(
        Uri.parse('$baseUrl/patient/doctors'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      print('Doctors List Response: ${response.statusCode}');
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(jsonDecode(response.body)['error'] ?? 'Failed to fetch doctors');
      }
    } catch (e) {
      print('Error in getDoctors: $e');
      throw Exception('Error: $e');
    }
  }

  // Assign doctor to patient
  static Future<Map<String, dynamic>> assignDoctor({
    required String patientId,
    required String doctorId,
    required String token,
  }) async {
    try {
      print('Assigning doctor $doctorId to patient $patientId');
      final response = await http.post(
        Uri.parse('$baseUrl/patient/assign-doctor'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'patient_id': patientId,
          'doctor_id': doctorId,
        }),
      ).timeout(const Duration(seconds: 10));

      print('Assign Doctor Response: ${response.statusCode}');
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(jsonDecode(response.body)['error'] ?? 'Failed to assign doctor');
      }
    } catch (e) {
      print('Error in assignDoctor: $e');
      throw Exception('Error: $e');
    }
  }

  // Get family members
  static Future<Map<String, dynamic>> getFamilyMembers({
    required String token,
  }) async {
    try {
      print('Fetching assigned family members');
      final response = await http.get(
        Uri.parse('$baseUrl/patient/family-members'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      print('Family Members Response: ${response.statusCode}');
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(jsonDecode(response.body)['error'] ?? 'Failed to fetch family members');
      }
    } catch (e) {
      print('Error in getFamilyMembers: $e');
      throw Exception('Error: $e');
    }
  }

  // Get unassigned family members for adding
  static Future<Map<String, dynamic>> getUnassignedFamilyMembers({
    required String token,
  }) async {
    try {
      print('Fetching unassigned family members');
      final response = await http.get(
        Uri.parse('$baseUrl/patient/unassigned-family-members'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      print('Unassigned Family Members Response: ${response.statusCode}');
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(jsonDecode(response.body)['error'] ?? 'Failed to fetch unassigned family members');
      }
    } catch (e) {
      print('Error in getUnassignedFamilyMembers: $e');
      // Return empty list if endpoint doesn't exist yet (for backwards compatibility)
      return {'family_members': []};
    }
  }

  // Add family member to patient
  static Future<Map<String, dynamic>> addFamilyMember({
    required String familyMemberId,
    required String relationship,
    required String token,
  }) async {
    try {
      print('Adding family member $familyMemberId with relationship: $relationship');
      final response = await http.post(
        Uri.parse('$baseUrl/patient/add-family-member'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'family_member_id': familyMemberId,
          'relationship': relationship,
        }),
      ).timeout(const Duration(seconds: 10));

      print('Add Family Member Response: ${response.statusCode}');
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(jsonDecode(response.body)['error'] ?? 'Failed to add family member');
      }
    } catch (e) {
      print('Error in addFamilyMember: $e');
      throw Exception('Error: $e');
    }
  }

  // Update patient password
  static Future<Map<String, dynamic>> updatePassword({
    required String userId,
    required String oldPassword,
    required String newPassword,
    required String token,
  }) async {
    try {
      print('Updating password for user: $userId');
      final response = await http.put(
        Uri.parse('$baseUrl/patient/update-password'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'user_id': userId,
          'old_password': oldPassword,
          'new_password': newPassword,
        }),
      ).timeout(const Duration(seconds: 10));

      print('Update Password Response: ${response.statusCode}');
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(jsonDecode(response.body)['error'] ?? 'Failed to update password');
      }
    } catch (e) {
      print('Error in updatePassword: $e');
      throw Exception('Error: $e');
    }
  }

  // Update patient profile
  static Future<Map<String, dynamic>> updateProfile({
    required String userId,
    required String fullName,
    required String phoneNumber,
    required String medicalCondition,
    required String token,
  }) async {
    try {
      print('Updating profile for user: $userId');
      final response = await http.put(
        Uri.parse('$baseUrl/patient/update-profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'user_id': userId,
          'full_name': fullName,
          'phone_number': phoneNumber,
          'medical_condition': medicalCondition,
        }),
      ).timeout(const Duration(seconds: 10));

      print('Update Profile Response: ${response.statusCode}');
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(jsonDecode(response.body)['error'] ?? 'Failed to update profile');
      }
    } catch (e) {
      print('Error in updateProfile: $e');
      throw Exception('Error: $e');
    }
  }

  // Remove doctor assignment
  static Future<Map<String, dynamic>> removeDoctor({
    required String token,
  }) async {
    try {
      print('Removing doctor assignment');
      final response = await http.delete(
        Uri.parse('$baseUrl/patient/remove-doctor'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      print('Remove Doctor Response: ${response.statusCode}');
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(jsonDecode(response.body)['error'] ?? 'Failed to remove doctor');
      }
    } catch (e) {
      print('Error in removeDoctor: $e');
      throw Exception('Error: $e');
    }
  }

  // Remove family member
  static Future<Map<String, dynamic>> removeFamilyMember({
    required String familyMemberId,
    required String token,
  }) async {
    try {
      print('Removing family member $familyMemberId');
      final response = await http.delete(
        Uri.parse('$baseUrl/patient/family-member/$familyMemberId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      print('Remove Family Member Response: ${response.statusCode}');
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(jsonDecode(response.body)['error'] ?? 'Failed to remove family member');
      }
    } catch (e) {
      print('Error in removeFamilyMember: $e');
      throw Exception('Error: $e');
    }
  }

  // Logout (simple - just clears local data)
  static Future<void> logout() async {
    try {
      print('User logged out');
      // Just return success - no server call needed for logout
      // In a real app, you might want to invalidate the token on server
      return;
    } catch (e) {
      print('Error in logout: $e');
      throw Exception('Error: $e');
    }
  }

  // Family Member Endpoints

  // Get family member profile
  static Future<Map<String, dynamic>> getFamilyMemberProfile({
    required String token,
  }) async {
    try {
      print('Fetching family member profile');
      final response = await http.get(
        Uri.parse('$baseUrl/family/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      print('Family Member Profile Response: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(jsonDecode(response.body)['error'] ?? 'Failed to fetch profile');
      }
    } catch (e) {
      print('Error in getFamilyMemberProfile: $e');
      throw Exception('Error: $e');
    }
  }

  // Update family member profile
  static Future<Map<String, dynamic>> updateFamilyMemberProfile({
    required String fullName,
    required String phoneNumber,
    required String token,
  }) async {
    try {
      print('Updating family member profile');
      final response = await http.put(
        Uri.parse('$baseUrl/family/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'full_name': fullName,
          'phone_number': phoneNumber,
        }),
      ).timeout(const Duration(seconds: 10));

      print('Update Family Member Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(jsonDecode(response.body)['error'] ?? 'Failed to update profile');
      }
    } catch (e) {
      print('Error in updateFamilyMemberProfile: $e');
      throw Exception('Error: $e');
    }
  }

  // Get assigned patient for family member
  static Future<Map<String, dynamic>> getAssignedPatient({
    required String token,
  }) async {
    try {
      print('Fetching assigned patient for family member');
      final response = await http.get(
        Uri.parse('$baseUrl/family/patient'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      print('Assigned Patient Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(jsonDecode(response.body)['error'] ?? 'Failed to fetch patient');
      }
    } catch (e) {
      print('Error in getAssignedPatient: $e');
      throw Exception('Error: $e');
    }
  }

  // Get patient medical history for family member
  static Future<Map<String, dynamic>> getPatientMedicalHistory({
    required String familyId,
  }) async {
    try {
      print('Fetching patient medical history for family: $familyId');
      final response = await http.get(
        Uri.parse('$baseUrl/family/$familyId/patient/history'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      print('Patient History Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(jsonDecode(response.body)['error'] ?? 'Failed to fetch history');
      }
    } catch (e) {
      print('Error in getPatientMedicalHistory: $e');
      throw Exception('Error: $e');
    }
  }

  // Pharmacy API calls
  static Future<Map<String, dynamic>> getPharmacyProfile({
    required String token,
  }) async {
    try {
      print('Fetching pharmacy profile');
      final response = await http.get(
        Uri.parse('$baseUrl/pharmacy/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      print('Pharmacy Profile Response: ${response.statusCode}');
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(jsonDecode(response.body)['error'] ?? 'Failed to fetch pharmacy profile');
      }
    } catch (e) {
      print('Error in getPharmacyProfile: $e');
      throw Exception('Error: $e');
    }
  }

  static Future<Map<String, dynamic>> getPharmacyPrescriptions({
    required String token,
  }) async {
    try {
      print('Fetching pharmacy prescriptions');
      final response = await http.get(
        Uri.parse('$baseUrl/pharmacy/prescriptions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      print('Pharmacy Prescriptions Response: ${response.statusCode}');
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(jsonDecode(response.body)['error'] ?? 'Failed to fetch prescriptions');
      }
    } catch (e) {
      print('Error in getPharmacyPrescriptions: $e');
      throw Exception('Error: $e');
    }
  }

  static Future<Map<String, dynamic>> approvePrescription({
    required int prescriptionId,
    required String token,
  }) async {
    try {
      print('Approving prescription: $prescriptionId');
      final response = await http.patch(
        Uri.parse('$baseUrl/prescription/prescription/$prescriptionId/approve'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      print('Approve Prescription Response: ${response.statusCode}');
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(jsonDecode(response.body)['error'] ?? 'Failed to approve prescription');
      }
    } catch (e) {
      print('Error in approvePrescription: $e');
      throw Exception('Error: $e');
    }
  }

  static Future<Map<String, dynamic>> denyPrescription({
    required int prescriptionId,
    required String reason,
    required String token,
  }) async {
    try {
      print('Denying prescription: $prescriptionId');
      final response = await http.patch(
        Uri.parse('$baseUrl/prescription/prescription/$prescriptionId/deny'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'reason': reason}),
      ).timeout(const Duration(seconds: 10));

      print('Deny Prescription Response: ${response.statusCode}');
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(jsonDecode(response.body)['error'] ?? 'Failed to deny prescription');
      }
    } catch (e) {
      print('Error in denyPrescription: $e');
      throw Exception('Error: $e');
    }
  }

  static Future<Map<String, dynamic>> deliverPrescription({
    required int prescriptionId,
    required String token,
  }) async {
    try {
      print('Delivering prescription: $prescriptionId');
      final response = await http.patch(
        Uri.parse('$baseUrl/prescription/prescription/$prescriptionId/deliver'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      print('Deliver Prescription Response: ${response.statusCode}');
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(jsonDecode(response.body)['error'] ?? 'Failed to deliver prescription');
      }
    } catch (e) {
      print('Error in deliverPrescription: $e');
      throw Exception('Error: $e');
    }
  }

  static Future<Map<String, dynamic>> getPendingPrescriptions({
    required String token,
  }) async {
    try {
      print('Getting pending prescriptions...');
      final response = await http.get(
        Uri.parse('$baseUrl/prescription/pending'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      print('Get Pending Prescriptions Response: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      // Check if response is HTML (error)
      if (response.body.trim().startsWith('<')) {
        throw Exception('Server returned HTML error. Status: ${response.statusCode}');
      }

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(jsonDecode(response.body)['error'] ?? 'Failed to get pending prescriptions');
      }
    } catch (e) {
      print('Error in getPendingPrescriptions: $e');
      throw Exception('Error: $e');
    }
  }

  static Future<Map<String, dynamic>> getPrescriptionHistory({
    required String token,
  }) async {
    try {
      print('Getting prescription history...');
      final response = await http.get(
        Uri.parse('$baseUrl/prescription/history'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      print('Get Prescription History Response: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      // Check if response is HTML (error)
      if (response.body.trim().startsWith('<')) {
        throw Exception('Server returned HTML error. Status: ${response.statusCode}');
      }

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(jsonDecode(response.body)['error'] ?? 'Failed to get prescription history');
      }
    } catch (e) {
      print('Error in getPrescriptionHistory: $e');
      throw Exception('Error: $e');
    }
  }

  static Future<Map<String, dynamic>> updatePharmacyProfile({
    required String? fullName,
    required String? pharmacyName,
    required String? phoneNumber,
    required String? province,
    required String? district,
    required String? citySector,
    required String token,
  }) async {
    try {
      print('Updating pharmacy profile');
      final response = await http.put(
        Uri.parse('$baseUrl/pharmacy/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          if (fullName != null) 'full_name': fullName,
          if (pharmacyName != null) 'pharmacy_name': pharmacyName,
          if (phoneNumber != null) 'phone_number': phoneNumber,
          if (province != null) 'province': province,
          if (district != null) 'district': district,
          if (citySector != null) 'city_sector': citySector,
        }),
      ).timeout(const Duration(seconds: 10));

      print('Update Pharmacy Profile Response: ${response.statusCode}');
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(jsonDecode(response.body)['error'] ?? 'Failed to update profile');
      }
    } catch (e) {
      print('Error in updatePharmacyProfile: $e');
      throw Exception('Error: $e');
    }
  }

  // Doctor API calls
  static Future<Map<String, dynamic>> getDoctorProfile({
    required String token,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/doctor/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(jsonDecode(response.body)['error'] ?? 'Failed to fetch doctor profile');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  static Future<Map<String, dynamic>> getDoctorPrescriptions({
    required String token,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/doctor/prescriptions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(jsonDecode(response.body)['error'] ?? 'Failed to fetch prescriptions');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  static Future<Map<String, dynamic>> getDoctorPatientAlerts({
    required String token,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/doctor/patient-alerts'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'alerts': []}; // Return empty list if no alerts
      }
    } catch (e) {
      print('Error getting patient alerts: $e');
      return {'alerts': []};
    }
  }

  static Future<Map<String, dynamic>> updateDoctorProfile({
    required String? fullName,
    required String? phoneNumber,
    required String? specialization,
    required String? licenseNumber,
    required String? hospitalClinic,
    required String token,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/doctor/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          if (fullName != null) 'full_name': fullName,
          if (phoneNumber != null) 'phone_number': phoneNumber,
          if (specialization != null) 'specialization': specialization,
          if (licenseNumber != null) 'license_number': licenseNumber,
          if (hospitalClinic != null) 'hospital_clinic': hospitalClinic,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(jsonDecode(response.body)['error'] ?? 'Failed to update profile');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  static Future<Map<String, dynamic>> sendPrescription({
  required String patientId,
  required String pharmacyId,
  required List<String> medicines,
  required String instructions,
  required String token,
}) async {
  try {
    List<Map<String, dynamic>> medicinesList = medicines.map((medicine) {
      final parts = medicine.split(RegExp(r'\s+(?=\d)'));
      return {
        'name': parts[0],
        'dosage': parts.length > 1 ? parts[1] : '',
        'quantity': 10,
        'frequency': 'As needed'
      };
    }).toList();

    final requestBody = {
      'patient_id': int.parse(patientId),
      'pharmacy_id': int.parse(pharmacyId),
      'medicines': medicinesList,
      'instructions': instructions,
    };

    print('=== Sending Prescription ===');
    print('Request Body: $requestBody');

    final response = await http.post(
      Uri.parse('$baseUrl/prescription/doctor/send'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(requestBody),
    ).timeout(const Duration(seconds: 10));

    print('Status Code: ${response.statusCode}');
    print('Response Body: "${response.body}"');

    // Empty body guard
    if (response.body.trim().isEmpty) {
      throw Exception('Server returned empty response (status ${response.statusCode})');
    }

    // HTML error page guard
    if (response.body.trim().startsWith('<')) {
      throw Exception('Server returned HTML error (status ${response.statusCode})');
    }

    final decoded = jsonDecode(response.body);

    if (response.statusCode == 201 || response.statusCode == 200) {
      return decoded;
    } else {
      throw Exception(decoded['error'] ?? 'Failed to send prescription (${response.statusCode})');
    }
  } catch (e) {
    print('=== Error sending prescription: $e');
    throw Exception('Error sending prescription: $e');
  }
}
  static Future<Map<String, dynamic>> searchPharmacy({
    required String query,
    String? district,
    required String token,
  }) async {
    try {
      final params = {
        'q': query,
        if (district != null) 'district': district,
      };
      
      final response = await http.get(
        Uri.parse('$baseUrl/doctor/pharmacy/search').replace(queryParameters: params),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(jsonDecode(response.body)['error'] ?? 'Failed to search pharmacies');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Get assigned patients for doctor
  static Future<Map<String, dynamic>> getAssignedPatients({
    required String token,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/doctor/patients'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(jsonDecode(response.body)['error'] ?? 'Failed to fetch patients');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Get alert history for a specific patient
  static Future<Map<String, dynamic>> getPatientAlerts({
    required int patientId,
    required String token,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/doctor/patient/$patientId/alerts'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(jsonDecode(response.body)['error'] ?? 'Failed to fetch alerts');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // ============ PASSWORD RESET ENDPOINTS ============

  // Forgot Password - Request OTP
  static Future<Map<String, dynamic>> forgotPassword({
    required String email,
  }) async {
    try {
      print('Attempting forgot password for: $email');
      final response = await http.post(
        Uri.parse('$baseUrl/auth/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
        }),
      ).timeout(const Duration(seconds: 30)); // Increased timeout for email sending

      print('Forgot Password Response status: ${response.statusCode}');
      print('Forgot Password Response body: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(jsonDecode(response.body)['error'] ?? 'Failed to process forgot password');
      }
    } catch (e) {
      print('Error in forgotPassword: $e');
      throw Exception('Error: $e');
    }
  }

  // Get all patients assigned to this doctor
  static Future<Map<String, dynamic>> getDoctorAssignedPatients({
    required String token,
  }) async {
    try {
      print('Fetching assigned patients for doctor');
      final response = await http.get(
        Uri.parse('$baseUrl/doctor/patients'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(jsonDecode(response.body)['error'] ?? 'Failed to fetch patients');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Get patient history/alerts for a specific patient
  static Future<Map<String, dynamic>> getDoctorPatientHistory({
    required String patientId,
    required String token,
  }) async {
    try {
      print('Fetching patient history for: $patientId');
      final response = await http.get(
        Uri.parse('$baseUrl/doctor/patient/$patientId/history'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(jsonDecode(response.body)['error'] ?? 'Failed to fetch patient history');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Reset Password - Verify OTP and set new password
  static Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String resetCode,
    required String newPassword,
  }) async {
    try {
      print('Attempting to reset password for: $email');
      final response = await http.post(
        Uri.parse('$baseUrl/auth/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'resetCode': resetCode,
          'newPassword': newPassword,
        }),
      ).timeout(const Duration(seconds: 30)); // Increased timeout for email sending

      print('Reset Password Response status: ${response.statusCode}');
      print('Reset Password Response body: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(jsonDecode(response.body)['error'] ?? 'Failed to reset password');
      }
    } catch (e) {
      print('Error in resetPassword: $e');
      throw Exception('Error: $e');
    }
  }


  // ============================================================
  // WATCH / BP MONITOR ENDPOINTS
  // ============================================================

static const String _watchBaseUrl =
    'http://dht.softechsupply.com/watch/api_mysql.php';

static Future<Map<String, dynamic>> getReadings({
  int limit = 50,
  int offset = 0,
  String? token,
}) async {
  try {
    final params = {
      'limit': '$limit',
      'offset': '$offset',
      if (token != null) 'token': token,
    };
    final response = await http.get(
      Uri.parse('$_watchBaseUrl/api/readings').replace(queryParameters: params),
      headers: token != null ? {'Authorization': 'Bearer $token'} : {},
    );
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Failed to load readings');
  } catch (e) {
    throw Exception('Network error: $e');
  }
}



// Add userId to the URL as backup in case header is stripped
static Future<Map<String, dynamic>?> getLatestReading({String? token}) async {
  try {
    final uri = Uri.parse('$_watchBaseUrl/api/latest')
        .replace(queryParameters: token != null ? {'token': token} : null);
    final response = await http.get(
      uri,
      headers: token != null ? {'Authorization': 'Bearer $token'} : {},
    );
    print('=== latest status: ${response.statusCode} body: ${response.body}');
    if (response.statusCode == 200) return jsonDecode(response.body);
    if (response.statusCode == 404) return null;
    throw Exception('Server error ${response.statusCode}: ${response.body}');
  } catch (e) {
    throw Exception('Network error: $e');
  }
}


  // Get BP statistics
static Future<Map<String, dynamic>> getBPStats({String? token}) async {
  try {
    final uri = Uri.parse('$_watchBaseUrl/api/stats')
        .replace(queryParameters: token != null ? {'token': token} : null);
    final response = await http.get(
      uri,
      headers: token != null ? {'Authorization': 'Bearer $token'} : {},
    );
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Failed to load stats');
  } catch (e) {
    throw Exception('Network error: $e');
  }
}

  // Get chart data
static Future<List<Map<String, dynamic>>> getChartData({
  int days = 7,
  String? token,
}) async {
  try {
    final params = {
      'days': '$days',
      if (token != null) 'token': token,
    };
    final response = await http.get(
      Uri.parse('$_watchBaseUrl/api/chart').replace(queryParameters: params),
      headers: token != null ? {'Authorization': 'Bearer $token'} : {},
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['chart_data'] ?? []);
    }
    throw Exception('Failed to load chart data');
  } catch (e) {
    throw Exception('Network error: $e');
  }
}

  // Send new BP reading
  static Future<Map<String, dynamic>> sendBPReading(
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$_watchBaseUrl/api/predict'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to send reading');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Delete a reading
  static Future<bool> deleteBPReading(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$_watchBaseUrl/api/readings/$id'),
      );
      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Health check
  static Future<bool> checkWatchHealth() async {
    try {
      final response = await http.get(
        Uri.parse('$_watchBaseUrl/health'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['status'] == 'healthy';
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
