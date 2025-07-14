import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart' as charts;
import 'package:intl/intl.dart';
import '../models/models.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  Child? selectedChild;
  int _selectedReportType = 0; // 0: Vacunas, 1: Crecimiento, 2: Eventos
  final List<String> reportTypes = ['Vacunas', 'Crecimiento', 'Eventos'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reportes'),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
        ),
        backgroundColor: const Color(0xFF4CAF50),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () {
              // Exportar o compartir reportes
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Selector de niño
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF4CAF50)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.child_care, color: Color(0xFF4CAF50)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButton<Child>(
                      isExpanded: true,
                      value: selectedChild,
                      hint: const Text('Seleccione un niño'),
                      icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF4CAF50)),
                      underline: Container(),
                      items: appState.currentUser!.children.map((Child child) {
                        return DropdownMenuItem<Child>(
                          value: child,
                          child: Text(
                            '${child.name} (${child.age} años)',
                            style: const TextStyle(fontSize: 16),
                          ),
                        );
                      }).toList(),
                      onChanged: (Child? newValue) {
                        setState(() {
                          selectedChild = newValue;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Selector de tipo de reporte
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SegmentedButton<int>(
              segments: reportTypes.asMap().entries.map((entry) {
                return ButtonSegment<int>(
                  value: entry.key,
                  label: Text(entry.value),
                );
              }).toList(),
              selected: {_selectedReportType},
              onSelectionChanged: (Set<int> newSelection) {
                setState(() {
                  _selectedReportType = newSelection.first;
                });
              },
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.resolveWith<Color>(
                      (Set<WidgetState> states) {
                    if (states.contains(WidgetState.selected)) {
                      return const Color(0xFF4CAF50);
                    }
                    return Colors.grey[200]!;
                  },
                ),
                foregroundColor: WidgetStateProperty.resolveWith<Color>(
                      (Set<WidgetState> states) {
                    if (states.contains(WidgetState.selected)) {
                      return Colors.white;
                    }
                    return Colors.black;
                  },
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Contenido del reporte seleccionado
          Expanded(
            child: selectedChild == null
                ? const Center(
              child: Text(
                'Seleccione un niño para ver sus reportes',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
                : _buildReportContent(selectedChild!),
          ),
        ],
      ),
    );
  }

  Widget _buildReportContent(Child child) {
    switch (_selectedReportType) {
      case 0:
        return _buildVaccinesReport(child);
      case 1:
        return _buildGrowthReport(child);
      case 2:
        return _buildEventsReport(child);
      default:
        return _buildVaccinesReport(child);
    }
  }

  Widget _buildVaccinesReport(Child child) {
    final allVaccines = [
      'BCG', 'Hepatitis B', 'Pentavalente', 'Polio', 'Rotavirus',
      'Neumococo', 'Influenza', 'Triple viral', 'Varicela', 'Hepatitis A'
    ];

    final appliedVaccines = child.vaccines;
    final pendingVaccines = allVaccines
        .where((v) => !appliedVaccines.contains(v))
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Reporte de Vacunación',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            'Estado actual de vacunas para ${child.name}',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 20),

          // Gráfico de vacunas
          SizedBox(
            height: 200,
            child: charts.PieChart(
              charts.PieChartData(
                sections: [
                  charts.PieChartSectionData(
                    value: appliedVaccines.length.toDouble(),
                    title: 'Aplicadas: ${appliedVaccines.length}',
                    color: const Color(0xFF4CAF50),
                    radius: 80,
                  ),
                  charts.PieChartSectionData(
                    value: pendingVaccines.length.toDouble(),
                    title: 'Pendientes: ${pendingVaccines.length}',
                    color: Colors.orange,
                    radius: 80,
                  ),
                ],
                sectionsSpace: 2,
                centerSpaceRadius: 40,
              ),
            ),
          ),

          const SizedBox(height: 30),

          // Vacunas aplicadas
          const Text(
            'Vacunas Aplicadas',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          if (appliedVaccines.isEmpty)
            const Text('No se han aplicado vacunas aún', style: TextStyle(color: Colors.grey))
          else
            ...appliedVaccines.map((v) => ListTile(
              leading: const Icon(Icons.check_circle, color: Colors.green),
              title: Text(v),
            )),

          const SizedBox(height: 20),

          // Vacunas pendientes
          const Text(
            'Vacunas Pendientes',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          if (pendingVaccines.isEmpty)
            const Text('¡Felicidades! Todas las vacunas están al día', style: TextStyle(color: Colors.green))
          else
            ...pendingVaccines.map((v) => ListTile(
              leading: const Icon(Icons.warning, color: Colors.orange),
              title: Text(v),
              trailing: TextButton(
                child: const Text('Agendar'),
                onPressed: () {
                  // Lógica para agendar vacuna
                },
              ),
            )),
        ],
      ),
    );
  }

  Widget _buildGrowthReport(Child child) {
    // Datos simulados de crecimiento histórico
    final growthData = [
      GrowthData(DateTime.now().subtract(const Duration(days: 365)), 8.2, 70.5),
      GrowthData(DateTime.now().subtract(const Duration(days: 270)), 9.5, 75.0),
      GrowthData(DateTime.now().subtract(const Duration(days: 180)), 10.8, 80.2),
      GrowthData(DateTime.now().subtract(const Duration(days: 90)), 12.5, 85.0),
      GrowthData(DateTime.now(), child.weight, child.height),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Reporte de Crecimiento',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            'Evolución de peso y talla para ${child.name}',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 20),

          // Gráfico de crecimiento - Peso
          const Text(
            'Evolución de Peso (kg)',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 250,
            child: charts.LineChart(
              charts.LineChartData(
                gridData: charts.FlGridData(show: true),
                titlesData: charts.FlTitlesData(
                  bottomTitles: charts.AxisTitles(
                    sideTitles: charts.SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                        return Text(
                          '${date.day}/${date.month}',
                          style: const TextStyle(fontSize: 10),
                        );
                      },
                    ),
                  ),
                ),
                lineBarsData: [
                  charts.LineChartBarData(
                    spots: growthData.map((data) =>
                        charts.FlSpot(
                          data.date.millisecondsSinceEpoch.toDouble(),
                          data.weight,
                        )
                    ).toList(),
                    isCurved: true,
                    color: Colors.blue,
                    dotData: charts.FlDotData(show: true),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 30),

          // Gráfico de crecimiento - Talla
          const Text(
            'Evolución de Talla (cm)',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 250,
            child: charts.LineChart(
              charts.LineChartData(
                gridData: charts.FlGridData(show: true),
                titlesData: charts.FlTitlesData(
                  bottomTitles: charts.AxisTitles(
                    sideTitles: charts.SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                        return Text(
                          '${date.day}/${date.month}',
                          style: const TextStyle(fontSize: 10),
                        );
                      },
                    ),
                  ),
                ),
                lineBarsData: [
                  charts.LineChartBarData(
                    spots: growthData.map((data) =>
                        charts.FlSpot(
                          data.date.millisecondsSinceEpoch.toDouble(),
                          data.height,
                        )
                    ).toList(),
                    isCurved: true,
                    color: Colors.green,
                    dotData: charts.FlDotData(show: true),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Tabla de datos
          const Text(
            'Historial de Medidas',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          DataTable(
            columns: const [
              DataColumn(label: Text('Fecha')),
              DataColumn(label: Text('Peso (kg)')),
              DataColumn(label: Text('Talla (cm)')),
            ],
            rows: growthData.map((data) {
              return DataRow(cells: [
                DataCell(Text(DateFormat('dd/MM/yy').format(data.date))),
                DataCell(Text(data.weight.toStringAsFixed(1))),
                DataCell(Text(data.height.toStringAsFixed(1))),
              ]);
            }).toList(),
          ),

          const SizedBox(height: 20),
          // Percentiles (ejemplo)
          const Text(
            'Percentiles de Crecimiento',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildPercentileCard('Peso', '65%', Colors.blue),
              _buildPercentileCard('Talla', '72%', Colors.green),
              _buildPercentileCard('IMC', '58%', Colors.orange),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPercentileCard(String title, String value, Color color) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            Text(value, style: TextStyle(fontSize: 20, color: color, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildEventsReport(Child child) {
    final events = importantDates
        .where((event) => event.childId == child.id)
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    final upcomingEvents = events.where((e) => e.date.isAfter(DateTime.now())).toList();
    final pastEvents = events.where((e) => e.date.isBefore(DateTime.now())).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Reporte de Eventos',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            'Historial y próximos eventos para ${child.name}',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 20),

          // Próximos eventos
          const Text(
            'Próximos Eventos',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
          ),
          const SizedBox(height: 10),
          if (upcomingEvents.isEmpty)
            const Text('No hay eventos próximos', style: TextStyle(color: Colors.grey))
          else
            ...upcomingEvents.map((event) => _buildEventCard(event, false)),

          const SizedBox(height: 30),

          // Eventos pasados
          const Text(
            'Eventos Pasados',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
          ),
          const SizedBox(height: 10),
          if (pastEvents.isEmpty)
            const Text('No hay eventos registrados', style: TextStyle(color: Colors.grey))
          else
            ...pastEvents.map((event) => _buildEventCard(event, true)),
        ],
      ),
    );
  }

  Widget _buildEventCard(ImportantDate event, bool isPast) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: isPast ? Colors.blue[50] : Colors.green[50],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    event.date.day.toString(),
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isPast ? Colors.blue : Colors.green,
                    ),
                  ),
                  Text(
                    DateFormat.MMM().format(event.date).toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      color: isPast ? Colors.blue : Colors.green,
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
                    event.description,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    DateFormat('EEEE, d MMMM y', 'es').format(event.date),
                    style: const TextStyle(color: Colors.grey),
                  ),
                  if (!isPast) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          'Faltan ${event.date.difference(DateTime.now()).inDays} días',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ]
                ],
              ),
            ),
            if (!isPast)
              IconButton(
                icon: const Icon(Icons.notifications),
                color: Colors.orange,
                onPressed: () {
                  // Programar recordatorio
                },
              ),
          ],
        ),
      ),
    );
  }
}

// Modelos auxiliares para los reportes
class VaccineData {
  final String status;
  final int count;

  VaccineData(this.status, this.count);
}

class GrowthData {
  final DateTime date;
  final double weight;
  final double height;

  GrowthData(this.date, this.weight, this.height);
}