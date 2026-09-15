enum SensorSeverity {
  normal,
  warning,
  critical,
}

extension SensorSeverityExtension on SensorSeverity {
  String get label {
    switch (this) {
      case SensorSeverity.normal:
        return 'Normal';
      case SensorSeverity.warning:
        return 'Peringatan';
      case SensorSeverity.critical:
        return 'Kritis';
    }
  }
}

class SensorMetric {
  final String name;
  final double currentValue;
  final String unit;
  final double maxValue;
  final SensorSeverity severity;
  final List<double> history7Points;

  SensorMetric({
    required this.name,
    required this.currentValue,
    required this.unit,
    required this.maxValue,
    required this.severity,
    required this.history7Points,
  });
}

class PredictiveAlert {
  final String id;
  final String title;
  final String message;
  final SensorSeverity severity;
  final DateTime timestamp;
  bool isDismissed;

  PredictiveAlert({
    required this.id,
    required this.title,
    required this.message,
    required this.severity,
    required this.timestamp,
    this.isDismissed = false,
  });
}
