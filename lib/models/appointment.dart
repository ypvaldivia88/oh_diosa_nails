// lib/models/appointment.dart
class Appointment {
  final DateTime date;
  final String time;
  final bool isAvailable;

  Appointment({
    required this.date,
    required this.time,
    required this.isAvailable,
  });

  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String(),
      'time': time,
      'isAvailable': isAvailable ? 1 : 0,
    };
  }
}
