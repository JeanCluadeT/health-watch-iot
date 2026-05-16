class BPStats {
  final int totalReadings;
  final SystolicStats systolic;
  final DiastolicStats diastolic;
  final double? heartRate;
  final double? spo2;
  
  BPStats({
    required this.totalReadings,
    required this.systolic,
    required this.diastolic,
    this.heartRate,
    this.spo2,
  });
  
  factory BPStats.fromJson(Map<String, dynamic> json) {
    return BPStats(
      totalReadings: json['total_readings'] ?? 0,
      systolic: SystolicStats.fromJson(json['systolic'] ?? {}),
      diastolic: DiastolicStats.fromJson(json['diastolic'] ?? {}),
      heartRate: double.tryParse(json['heart_rate']?.toString() ?? '0'),
      spo2: double.tryParse(json['spo2']?.toString() ?? '0'),
    );
  }
}

class SystolicStats {
  final double avg;
  final double min;
  final double max;
  
  SystolicStats({
    required this.avg,
    required this.min,
    required this.max,
  });
  
  factory SystolicStats.fromJson(Map<String, dynamic> json) {
    return SystolicStats(
      avg: double.tryParse(json['avg']?.toString() ?? '0') ?? 0.0,
      min: double.tryParse(json['min']?.toString() ?? '0') ?? 0.0,
      max: double.tryParse(json['max']?.toString() ?? '0') ?? 0.0,
    );
  }
}

class DiastolicStats {
  final double avg;
  final double min;
  final double max;
  
  DiastolicStats({
    required this.avg,
    required this.min,
    required this.max,
  });
  
  factory DiastolicStats.fromJson(Map<String, dynamic> json) {
    return DiastolicStats(
      avg: double.tryParse(json['avg']?.toString() ?? '0') ?? 0.0,
      min: double.tryParse(json['min']?.toString() ?? '0') ?? 0.0,
      max: double.tryParse(json['max']?.toString() ?? '0') ?? 0.0,
    );
  }
}