import 'package:flutter/material.dart';
import 'pdf_view_screen.dart';
import 'calendar_screen.dart';
import 'child_management_screen.dart';
import 'settings_screen.dart';
import 'reports_screen.dart';
import '../models/models.dart';

class HomeScreen extends StatefulWidget {
  final String username;

  const HomeScreen({super.key, required this.username});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Child? selectedChild;
  int _currentIndex = 0;

  final Map<String, MedicalHistory> medicalHistoryByChild = {
    '1': MedicalHistory(
      lastVisit: DateTime.now().subtract(const Duration(days: 30)),
      nextAppointment: DateTime.now().add(const Duration(days: 60)),
      vaccinations: ['BCG', 'Hepatitis B', 'Pentavalente'],
      allergies: ['Ninguna conocida'],
    ),
    '2': MedicalHistory(
      lastVisit: DateTime.now().subtract(const Duration(days: 45)),
      nextAppointment: DateTime.now().add(const Duration(days: 75)),
      vaccinations: ['BCG', 'Hepatitis B', 'Pentavalente', 'Influenza'],
      allergies: ['Polvo', 'Polen'],
    ),
    '3': MedicalHistory(
      lastVisit: DateTime.now().subtract(const Duration(days: 20)),
      nextAppointment: DateTime.now().add(const Duration(days: 40)),
      vaccinations: ['BCG', 'Hepatitis B', 'Pentavalente', 'Rotavirus'],
      allergies: ['Penicilina'],
    ),
    '4': MedicalHistory(
      lastVisit: DateTime.now().subtract(const Duration(days: 60)),
      nextAppointment: DateTime.now().add(const Duration(days: 90)),
      vaccinations: ['BCG', 'Hepatitis B', 'Pentavalente', 'Neumococo'],
      allergies: ['Huevo'],
    ),
  };

  @override
  void initState() {
    super.initState();
    // Usar los niños del usuario actual
    if (appState.currentUser != null && appState.currentUser!.children.isNotEmpty) {
      selectedChild = appState.currentUser!.children.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/images/logo.png',
              height: 40,
              width: 40,
              errorBuilder: (_, __, ___) => const FlutterLogo(size: 32),
            ),
            const SizedBox(width: 10),
            const Text(
              'ChildCare',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: Colors.white,
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF4CAF50),
        elevation: 4,
        centerTitle: false,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Sección superior fija (bienvenida y selector de niños)
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Bienvenida al usuario
                Text(
                  'Bienvenido, ${widget.username}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 16),
                // Título condicional"
                if (appState.currentUser != null && appState.currentUser!.children.length > 1) ...[
                  const Text(
                    'Seleccione el niño:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF4CAF50),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                // Selector de niños solo si hay más de uno
                if (appState.currentUser != null && appState.currentUser!.children.length > 1) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF4CAF50),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.child_care, color: Color(0xFF4CAF50)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: selectedChild?.id,
                            icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF4CAF50)),
                            underline: Container(),
                            items: appState.currentUser?.children.map((Child child) {
                              return DropdownMenuItem<String>(
                                value: child.id,
                                child: Text(
                                  '${child.name} (${child.age} años)',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                selectedChild = appState.currentUser?.children
                                    .firstWhere((child) => child.id == newValue);
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else if (appState.currentUser != null && appState.currentUser!.children.isNotEmpty) ...[
                  // Mostrar solo el nombre del niño si hay solo uno
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.child_care, color: Color(0xFF4CAF50)),
                        const SizedBox(width: 12),
                        Text(
                          '${selectedChild?.name} (${selectedChild?.age} años)',
                          style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Divisor
          const Divider(height: 1, thickness: 1),

          // Sección desplazable con tarjetas
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Tarjeta de Historial Médico (actualizada según niño seleccionado)
                  if (selectedChild != null)
                    _buildMedicalCard(selectedChild!),

                  const SizedBox(height: 20),

                  // Tarjeta de Calendario (actualizada según niño seleccionado)
                  if (selectedChild != null)
                    _buildCalendarCard(selectedChild!),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),

      // Barra de navegación inferior
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFF4CAF50),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            // Navegar a diferentes pantallas según el índice
            if (index == 1) { // Índice para Gestión de Niños
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChildrenManagementScreen(),
                ),
              );
            } else if (index == 2) { // Índice para Reportes
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ReportsScreen(),
                ),
              );
            } else if (index == 3) { // Índice para Configuración
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsScreen(username: widget.username),
                ),
              );
            }
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.child_care),
            label: 'Niños',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Reportes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Configuración',
          ),
        ],
      ),
    );
  }

  Widget _buildMedicalCard(Child child) {
    final history = medicalHistoryByChild[child.id] ?? MedicalHistory.empty();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.medical_services,
                      size: 28,
                      color: Color(0xFFE57373),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Historial Médico',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Resumen médico
              _buildMedicalInfoRow('Última visita:',
                  '${history.lastVisit.day}/${history.lastVisit.month}/${history.lastVisit.year}'),

              _buildMedicalInfoRow('Próxima cita:',
                  '${history.nextAppointment.day}/${history.nextAppointment.month}/${history.nextAppointment.year}'),

              _buildMedicalInfoRow('Vacunas aplicadas:',
                  '${history.vaccinations.length} dosis'),

              _buildMedicalInfoRow('Alergias conocidas:',
                  history.allergies.join(', ')),

              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    {
                      // Abrir el PDF correspondiente al niño
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PdfViewScreen(
                            pdfAssetPath: 'assets/pdfs/historial_${child.id}.pdf',
                          ),
                        ),
                      );
                    }
                  },
                  child: const Text(
                    'Ver historial completo',
                    style: TextStyle(
                      color: Color(0xFF4CAF50),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMedicalInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarCard(Child child) {
    final importantDates = importantDatesByChild[child.id] ?? [];

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.calendar_today,
                    size: 28,
                    color: Color(0xFF64B5F6),
                  ),
                ),
                const SizedBox(width: 16),
                const Text(
                  'Fechas Importantes',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Próximos eventos:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 16,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 10),

            if (importantDates.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Center(
                  child: Text(
                    'No hay fechas próximas',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.grey,
                    ),
                  ),
                ),
              )
            else
              ...importantDates.map((date) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0xFF64B5F6),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            date.date.day.toString(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Color(0xFF64B5F6),
                            ),
                          ),
                          Text(
                            _getMonthAbbreviation(date.date.month),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF64B5F6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            date.description,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            date.date.toLocal().toString().split(' ')[0],
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )),

            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CalendarScreen(
                        initialChild: selectedChild, // CORRECCIÓN: Pasar selectedChild
                      ),
                    ),
                  );
                },
                child: const Text(
                  'Ver calendario completo',
                  style: TextStyle(
                    color: Color(0xFF4CAF50),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getMonthAbbreviation(int month) {
    const months = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
    ];
    return months[month - 1];
  }
}

// Modelo para historial médico
class MedicalHistory {
  final DateTime lastVisit;
  final DateTime nextAppointment;
  final List<String> vaccinations;
  final List<String> allergies;

  MedicalHistory({
    required this.lastVisit,
    required this.nextAppointment,
    required this.vaccinations,
    required this.allergies,
  });

  factory MedicalHistory.empty() {
    return MedicalHistory(
      lastVisit: DateTime.now().subtract(const Duration(days: 30)),
      nextAppointment: DateTime.now().add(const Duration(days: 60)),
      vaccinations: [],
      allergies: [],
    );
  }
}