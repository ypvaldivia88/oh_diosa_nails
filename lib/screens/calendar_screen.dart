// lib/screens/calendar_screen.dart
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/appointment.dart';
import '../utils/database_helper.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay =
      DateTime.now(); // Selecciona el día actual por defecto
  List<Appointment> _appointments = [];

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    final appointments = await DatabaseHelper().appointments();
    setState(() {
      _appointments = appointments;
    });
  }

  Map<DateTime, List<Appointment>> _getAppointmentsForDays() {
    Map<DateTime, List<Appointment>> appointmentsMap = {};
    for (var appointment in _appointments) {
      final date = DateTime(
          appointment.date.year, appointment.date.month, appointment.date.day);
      if (appointmentsMap[date] == null) {
        appointmentsMap[date] = [];
      }
      appointmentsMap[date]!.add(appointment);
    }
    return appointmentsMap;
  }

  List<Appointment> _getAppointmentsForDay(DateTime day) {
    return _appointments
        .where((appointment) => isSameDay(appointment.date, day))
        .toList();
  }

  void _selectAppointment(Appointment appointment) {
    if (appointment.isAvailable) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Confirmar Turno'),
          content: Text('¿Deseas seleccionar el turno de ${appointment.time}?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                // Aquí puedes añadir la lógica para confirmar el turno
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content:
                          Text('Turno de ${appointment.time} seleccionado')),
                );
              },
              child: const Text('Confirmar'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appointmentsMap = _getAppointmentsForDays();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendario de Turnos'),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events) {
                if (appointmentsMap.isNotEmpty) {
                  final hasAvailable = appointmentsMap.values.any(
                      (appointment) => appointment.any(
                          (a) => a.isAvailable && isSameDay(a.date, date)));
                  final hasUnavailable = appointmentsMap.values.any(
                      (appointment) => appointment.any(
                          (a) => !a.isAvailable && isSameDay(a.date, date)));

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (hasAvailable)
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 1.5),
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.green,
                          ),
                        ),
                      if (hasUnavailable)
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 1.5),
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.red,
                          ),
                        ),
                    ],
                  );
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 8.0),
          Expanded(
            child: ListView.builder(
              itemCount: _selectedDay == null
                  ? 0
                  : _getAppointmentsForDay(_selectedDay!).length,
              itemBuilder: (context, index) {
                final appointment =
                    _getAppointmentsForDay(_selectedDay!)[index];
                return ListTile(
                  title: Text(appointment.time),
                  trailing: appointment.isAvailable
                      ? const Icon(Icons.check, color: Colors.green)
                      : const Icon(Icons.close, color: Colors.red),
                  onTap: () => _selectAppointment(appointment),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
