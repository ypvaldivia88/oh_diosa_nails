// lib/utils/database_helper.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/appointment.dart';
import 'firebase_options.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  DatabaseHelper._internal();

  Future<void> initializeFirebase() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  Future<void> insertAppointment(Appointment appointment) async {
    await _firestore.collection('appointments').add(appointment.toMap());
  }

  Future<List<Appointment>> appointments() async {
    QuerySnapshot querySnapshot =
        await _firestore.collection('appointments').get();
    return querySnapshot.docs.map((doc) {
      return Appointment(
        date: DateTime.parse(doc['date']),
        time: doc['time'],
        isAvailable: doc['isAvailable'] == 1,
      );
    }).toList();
  }
}
