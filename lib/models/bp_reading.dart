import 'package:flutter/material.dart';

class BPReading {
  final int? id;
  final double systolic;
  final double diastolic;
  final int? heartRate;
  final int? spo2;
  final double? hrvRmssd;
  final double? temperature;
  final bool isMoving;
  final String category;
  final String alertLevel;
  final DateTime? createdAt;
  
  BPReading({
    this.id,
    required this.systolic,
    required this.diastolic,
    this.heartRate,
    this.spo2,
    this.hrvRmssd,
    this.temperature,
    this.isMoving = false,
    required this.category,
    required this.alertLevel,
    this.createdAt,
  });
  
  factory BPReading.fromJson(Map<String, dynamic> json) {
    return BPReading(
      id: int.tryParse(json['id']?.toString() ?? '0'),
      systolic: double.tryParse(json['systolic']?.toString() ?? '0') ?? 0.0,
      diastolic: double.tryParse(json['diastolic']?.toString() ?? '0') ?? 0.0,
      heartRate: int.tryParse(json['heart_rate']?.toString() ?? '0'),
      spo2: int.tryParse(json['spo2']?.toString() ?? '0'),
      hrvRmssd: double.tryParse(json['hrv_rmssd']?.toString() ?? '0'),
      temperature: double.tryParse(json['temperature']?.toString() ?? '0'),
      isMoving: json['is_moving'] == 1 || json['is_moving'] == true,
      category: json['category'] ?? 'Unknown',
      alertLevel: json['alert_level'] ?? 'info',
      createdAt: json['created_at'] != null 
          ? DateTime.tryParse(json['created_at']) 
          : json['timestamp'] != null
              ? DateTime.tryParse(json['timestamp'])
              : DateTime.now(),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'systolic': systolic,
      'diastolic': diastolic,
      'heart_rate': heartRate,
      'spo2': spo2,
      'hrv_rmssd': hrvRmssd,
      'temperature': temperature,
      'is_moving': isMoving ? 1 : 0,
      'category': category,
      'alert_level': alertLevel,
      'created_at': createdAt?.toIso8601String(),
    };
  }
  
  // Get color based on category
  Color get categoryColor {
    switch (alertLevel.toLowerCase()) {
      case 'success':
        return Colors.green;
      case 'warning':
        return Colors.orange;
      case 'danger':
        return Colors.red;
      case 'info':
      default:
        return Colors.blue;
    }
  }
  
  // Get icon based on category
  IconData get categoryIcon {
    switch (alertLevel.toLowerCase()) {
      case 'success':
        return Icons.check_circle;
      case 'warning':
        return Icons.warning;
      case 'danger':
        return Icons.error;
      case 'info':
      default:
        return Icons.info;
    }
  }
  
  // Format BP as string
  String get bpString => '${systolic.toInt()}/${diastolic.toInt()}';
  
  // Is BP normal?
  bool get isNormal => alertLevel == 'success';
  
  // Is BP concerning?
  bool get isConcerning => alertLevel == 'danger';
}