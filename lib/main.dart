import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'theme/app_theme.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/auth/reset_password_screen.dart';
import 'screens/auth/otp_verification_screen.dart';
import 'screens/dashboards/patient_dashboard.dart';
import 'screens/dashboards/doctor_dashboard.dart';
import 'screens/dashboards/family_dashboard.dart';
import 'screens/dashboards/pharmacy_dashboard.dart';




Future<void> main() async {
  await dotenv.load(fileName: '.env');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HealthGuard',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.getLightTheme(),
      home: const LoginScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
      },
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/otp-verification':
            final args = settings.arguments as Map<String, dynamic>?;
            return MaterialPageRoute(
              builder: (context) => OtpVerificationScreen(
                email: args?['email'] ?? '',
                fullName: args?['fullName'],
                purpose: args?['purpose'] ?? 'registration',
              ),
            );
          case '/reset-password':
            final args = settings.arguments as Map<String, dynamic>?;
            return MaterialPageRoute(
              builder: (context) => ResetPasswordScreen(),
              settings: RouteSettings(arguments: args),
            );
          case '/patient-dashboard':
            final args = settings.arguments as Map<String, dynamic>?;
            return MaterialPageRoute(
              builder: (context) => PatientDashboard(
                userId: args?['userId'],
                token: args?['token'],
              ),
            );
          case '/doctor-dashboard':
            final args = settings.arguments as Map<String, dynamic>?;
            return MaterialPageRoute(
              builder: (context) => DoctorDashboard(
                userId: args?['userId'],
                token: args?['token'],
              ),
            );
          case '/family-dashboard':
            final args = settings.arguments as Map<String, dynamic>?;
            return MaterialPageRoute(
              builder: (context) => FamilyDashboard(
                userId: args?['userId'],
                token: args?['token'],
                familyId: args?['familyId'],
              ),
            );
          case '/pharmacy-dashboard':
            final args = settings.arguments as Map<String, dynamic>?;
            return MaterialPageRoute(
              builder: (context) => PharmacyDashboard(
                userId: args?['userId'],
                token: args?['token'],
              ),
            );
          default:
            return MaterialPageRoute(
              builder: (context) => const LoginScreen(),
            );
        }
      },
    );
  }
}
