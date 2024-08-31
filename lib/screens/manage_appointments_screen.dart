// lib/screens/manage_appointments_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/appointment.dart';
import '../utils/database_helper.dart';

class ManageAppointmentsScreen extends StatefulWidget {
  const ManageAppointmentsScreen({super.key});

  @override
  _ManageAppointmentsScreenState createState() =>
      _ManageAppointmentsScreenState();
}

class _ManageAppointmentsScreenState extends State<ManageAppointmentsScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _isAvailable = true;
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

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final newAppointment = Appointment(
        date: _selectedDate,
        time: _selectedTime.format(context),
        isAvailable: _isAvailable,
      );
      await DatabaseHelper().insertAppointment(newAppointment);
      _loadAppointments();
    }
  }

  void _editAppointment(int index) {
    final appointment = _appointments[index];
    setState(() {
      _selectedDate = appointment.date;
      _selectedTime = TimeOfDay(
        hour: int.parse(appointment.time.split(':')[0]),
        minute: int.parse(appointment.time.split(':')[1].split(' ')[0]),
      );
      _isAvailable = appointment.isAvailable;
    });
    _submitForm();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestionar Turnos'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Fecha'),
                    readOnly: true,
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );
                      setState(() {
                        _selectedDate = pickedDate!;
                      });
                    },
                    validator: (value) {
                      return null;
                    },
                    controller: TextEditingController(
                      text: DateFormat('yyyy-MM-dd').format(_selectedDate),
                    ),
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Hora'),
                    readOnly: true,
                    onTap: () async {
                      TimeOfDay? pickedTime = await showTimePicker(
                        context: context,
                        initialTime: _selectedTime,
                      );
                      if (pickedTime != null) {
                        setState(() {
                          _selectedTime = pickedTime;
                        });
                      }
                    },
                    validator: (value) {
                      return null;
                    },
                    controller: TextEditingController(
                      text: _selectedTime.format(context),
                    ),
                  ),
                  SwitchListTile(
                    title: const Text('Disponible'),
                    value: _isAvailable,
                    onChanged: (value) {
                      setState(() {
                        _isAvailable = value;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _submitForm,
                    child: const Text('Añadir Turno'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _appointments.length,
                itemBuilder: (context, index) {
                  final appointment = _appointments[index];
                  return ListTile(
                    title: Text(
                        '${appointment.date.toLocal()} ${appointment.time}'),
                    subtitle: Text(appointment.isAvailable
                        ? 'Disponible'
                        : 'No Disponible'),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _editAppointment(index),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
