import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/models.dart';

class CalendarScreen extends StatefulWidget {
  final Child? initialChild;

  const CalendarScreen({super.key, this.initialChild});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late Child? _selectedChild;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<ImportantDate>> _events = {};

  @override
  void initState() {
    super.initState();
    _selectedChild = widget.initialChild ??
        (appState.currentUser!.children.isNotEmpty ? appState.currentUser!.children[0] : null);
    _loadEvents();
  }

  void _loadEvents() {
    final eventsMap = <DateTime, List<ImportantDate>>{};

    if (_selectedChild == null) {
      for (final event in importantDates) {
        final day = DateTime(event.date.year, event.date.month, event.date.day);
        eventsMap.putIfAbsent(day, () => []).add(event);
      }
    } else {
      final childEvents = importantDates
          .where((event) => event.childId == _selectedChild!.id)
          .toList();

      for (final event in childEvents) {
        final day = _normalizeDate(event.date);
        eventsMap.putIfAbsent(day, () => []).add(event);
      }
    }

    setState(() {
      _events = eventsMap;
    });
  }

  void _onChildChanged(Child? newChild) {
    if (newChild != null && newChild != _selectedChild) {
      setState(() {
        _selectedChild = newChild;
      });
      _loadEvents();
    }
  }

  List<ImportantDate> _getEventsForDay(DateTime day) {
    return _events[_normalizeDate(day)] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendario de Eventos'),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
        backgroundColor: const Color(0xFF4CAF50),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Sección de selección de niño
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título solo cuando hay más de un niño
                if (appState.currentUser!.children.length > 1) ...[
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
                // Selector de niños
                if (appState.currentUser!.children.length > 1) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: _selectedChild?.id,
                            icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF4CAF50)),
                            underline: Container(),
                            items: appState.currentUser!.children.map((Child child) {
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
                              if (newValue != null) {
                                final selectedChild = appState.currentUser!.children.firstWhere(
                                      (child) => child.id == newValue,
                                );
                                _onChildChanged(selectedChild);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else if (appState.currentUser!.children.isNotEmpty) ...[
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
                          '${_selectedChild?.name} (${_selectedChild?.age} años)',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  // Mensaje cuando no hay niños
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Center(
                      child: Text(
                        'No hay niños registrados',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Divider(height: 1),
          // Calendario y lista de eventos
          Expanded(
            child: Column(
              children: [
                TableCalendar<ImportantDate>(
                  locale: 'es_ES',
                  firstDay: DateTime.now().subtract(const Duration(days: 365)),
                  lastDay: DateTime.now().add(const Duration(days: 365)),
                  focusedDay: _focusedDay,
                  calendarFormat: _calendarFormat,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  headerStyle: HeaderStyle(
                    titleCentered: true,
                    formatButtonVisible: true,
                    formatButtonShowsNext: false,
                    // Traducción de los formatos del calendario
                    formatButtonTextStyle: const TextStyle(color: Colors.green),
                  ),
                  calendarStyle: CalendarStyle(
                    markerDecoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      shape: BoxShape.circle,
                    ),
                    todayDecoration: BoxDecoration(
                      color: Theme.of(context).primaryColorLight,
                      shape: BoxShape.circle,
                    ),
                  ),
                  onDaySelected: (selectedDay, focusedDay) {
                    if (!isSameDay(_selectedDay, selectedDay)) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                    }
                  },
                  onFormatChanged: (format) {
                    if (_calendarFormat != format) {
                      setState(() {
                        _calendarFormat = format;
                      });
                    }
                  },
                  onPageChanged: (focusedDay) {
                    _focusedDay = focusedDay;
                  },
                  eventLoader: _getEventsForDay,
                ),
                const SizedBox(height: 8.0),
                Expanded(
                  child: _buildEventList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventList() {
    final events = _selectedDay != null ? _getEventsForDay(_selectedDay!) : [];

    if (events.isEmpty) {
      return Center(
        child: Text(
          _selectedDay == null
              ? 'Seleccione un día para ver eventos'
              : 'No hay eventos para ${_selectedChild?.name ?? "ningún niño"} el ${_selectedDay!.day}/${_selectedDay!.month}',
          style: const TextStyle(fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        final child = appState.currentUser!.children.firstWhere(
              (c) => c.id == event.childId,
          orElse: () => Child(id: '', name: 'Desconocido', birthDate: DateTime.now(), gender: '', bloodType: '', weight: 0, height: 0, diseases: [], allergies: [], vaccines: []),
        );

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    event.date.day.toString(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _getMonthAbbreviation(event.date.month),
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
            title: Text(
              event.description,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('Niño: ${child.name}'),
                Text('Fecha: ${_formatDate(event.date)}'),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _getMonthAbbreviation(int month) {
    const months = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
    ];
    return months[month - 1];
  }

  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}