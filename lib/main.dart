import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'models/models.dart';

void main() {
  _initializeSampleData();
  initializeDateFormatting('es', null).then((_) {
    runApp(const MyApp());
  });
}

void _initializeSampleData() {
  // Crear usuario de prueba
  final testUser = User(
    fullName: "Andrés García",
    email: "andres@example.com",
    password: "123456",
    birthDate: DateTime(1985, 5, 15),
    phone: "+593 98 765 4321",
    address: "Calle Principal 123, Cuenca, Ecuador",
    children: [
      Child(
        id: '1',
        name: 'Juan Pérez',
        birthDate: DateTime.now().subtract(const Duration(days: 3 * 365)),
        gender: 'Masculino',
        bloodType: 'O+',
        weight: 15.2,
        height: 95.5,
        diseases: ['Asma'],
        allergies: ['Polvo', 'Polen'],
        vaccines: ['BCG', 'Hepatitis B', 'DTPa', 'Polio', 'MMR'],
      ),
      Child(
        id: '2',
        name: 'Ana Gómez',
        birthDate: DateTime.now().subtract(const Duration(days: 4 * 365)),
        gender: 'Femenino',
        bloodType: 'A+',
        weight: 14.0,
        height: 92.0,
        diseases: ['Alergia estacional'],
        allergies: ['Ácaros', 'Polen'],
        vaccines: ['BCG', 'Hepatitis B', 'DTPa', 'Polio', 'MMR'],
      ),
      Child(
        id: '3',
        name: 'Luis Fernández',
        birthDate: DateTime.now().subtract(const Duration(days: 2 * 365)),
        gender: 'Masculino',
        bloodType: 'B+',
        weight: 12.5,
        height: 88.0,
        diseases: [],
        allergies: [],
        vaccines: ['BCG', 'Hepatitis B', 'DTPa', 'Polio', 'MMR'],
      ),
      Child(
        id: '4',
        name: 'María López',
        birthDate: DateTime.now().subtract(const Duration(days: 5 * 365)),
        gender: 'Femenino',
        bloodType: 'AB+',
        weight: 16.0,
        height: 100.0,
        diseases: ['Eczema'],
        allergies: ['Lactosa'],
        vaccines: ['BCG', 'Hepatitis B', 'DTPa', 'Polio', 'MMR'],
      ),
    ],
  );

  appState.registerUser(testUser);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Child Care',
      theme: ThemeData(primarySwatch: Colors.blue),
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
    );
  }
}
