class User {
  final String fullName;
  final String email;
  final String password;
  final DateTime birthDate;
  final String phone;
  final String address;
  final List<Child> children;

  User({
    required this.fullName,
    required this.email,
    required this.password,
    required this.birthDate,
    required this.phone,
    required this.address,
    this.children = const [],
  });
}

class Child {
  final String id;
  final String name;
  final DateTime birthDate; // Cambiamos de age a birthDate
  final String gender;
  final String bloodType;
  final double weight;
  final double height;
  final List<String> diseases;
  final List<String> allergies;
  final List<String> vaccines;

  const Child({
    required this.id,
    required this.name,
    required this.birthDate,
    required this.gender,
    required this.bloodType,
    required this.weight,
    required this.height,
    this.diseases = const [],
    this.allergies = const [],
    this.vaccines = const [],
  });

  // Calcular la edad a partir de la fecha de nacimiento
  int get age {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }
}

class ImportantDate {
  final String childId;
  final String description;
  final DateTime date;

  ImportantDate({
    required this.childId,
    required this.description,
    required this.date,
  });
}

// Estado global de la aplicación
class AppState {
  User? currentUser;
  List<User> registeredUsers = [];
  List<Child> globalChildren = [];
  List<ImportantDate> importantDates = [];

  // Singleton para acceso global
  static final AppState _instance = AppState._internal();
  factory AppState() => _instance;
  AppState._internal();

  // Métodos para gestionar usuarios
  void registerUser(User newUser) {
    registeredUsers.add(newUser);
    currentUser = newUser;
  }

  bool login(String email, String password) {
    final user = registeredUsers.firstWhere(
          (u) => u.email == email && u.password == password,
      orElse: () => User(
        fullName: '',
        email: '',
        password: '',
        birthDate: DateTime.now(),
        phone: '',
        address: '',
      ),
    );

    if (user.email.isNotEmpty) {
      currentUser = user;
      return true;
    }
    return false;
  }

  void logout() {
    currentUser = null;
  }

  void addChild(Child child) {
    globalChildren.add(child);
    if (currentUser != null) {
      currentUser!.children.add(child);
    }
  }
}

// Instancia global
final appState = AppState();


// Lista de niños (ejemplo)
List<Child> globalChildren = [
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
];

List<ImportantDate> importantDates = [
  // Fechas médicas existentes
  ImportantDate(childId: '1', description: 'Visita al pediatra', date: DateTime.now().add(const Duration(days: 5))),
  ImportantDate(childId: '1', description: 'Vacuna triple viral', date: DateTime.now().add(const Duration(days: 15))),
  ImportantDate(childId: '1', description: 'Cumpleaños', date: DateTime.now().add(const Duration(days: 30))),
  ImportantDate(childId: '2', description: 'Control de desarrollo', date: DateTime.now().add(const Duration(days: 7))),
  ImportantDate(childId: '2', description: 'Vacuna contra influenza', date: DateTime.now().add(const Duration(days: 20))),
  ImportantDate(childId: '3', description: 'Evaluación nutricional', date: DateTime.now().add(const Duration(days: 3))),
  ImportantDate(childId: '3', description: 'Consulta oftalmológica', date: DateTime.now().add(const Duration(days: 25))),
  ImportantDate(childId: '4', description: 'Control de vacunas', date: DateTime.now().add(const Duration(days: 10))),
  ImportantDate(childId: '4', description: 'Terapia del lenguaje', date: DateTime.now().add(const Duration(days: 18))),

  // Cumpleaños de los niños
  ...appState.currentUser!.children.map((child) {
    final nextBirthday = DateTime(
      DateTime.now().year,
      child.birthDate.month,
      child.birthDate.day,
    );
    // Si el cumpleaños de este año ya pasó, calculamos para el próximo año
    final date = nextBirthday.isBefore(DateTime.now())
        ? DateTime(DateTime.now().year + 1, child.birthDate.month, child.birthDate.day)
        : nextBirthday;

    return ImportantDate(
      childId: child.id,
      description: 'Cumpleaños',
      date: date,
    );
  }),
];

// Datos de ejemplo para cada niño
final Map<String, List<ImportantDate>> importantDatesByChild = {
  '1': [
    ImportantDate(childId: '1', description: 'Visita al pediatra', date: DateTime.now().add(const Duration(days: 5))),
    ImportantDate(childId: '1', description: 'Vacuna triple viral', date: DateTime.now().add(const Duration(days: 15))),
  ],
  '2': [
    ImportantDate(childId: '2', description: 'Control de desarrollo', date: DateTime.now().add(const Duration(days: 7))),
    ImportantDate(childId: '2', description: 'Vacuna contra influenza', date: DateTime.now().add(const Duration(days: 20))),
  ],
  '3': [
    ImportantDate(childId: '3', description: 'Evaluación nutricional', date: DateTime.now().add(const Duration(days: 3))),
    ImportantDate(childId: '3', description: 'Consulta oftalmológica', date: DateTime.now().add(const Duration(days: 25))),
  ],
  '4': [
    ImportantDate(childId: '4', description: 'Control de vacunas', date: DateTime.now().add(const Duration(days: 10))),
    ImportantDate(childId: '4', description: 'Terapia del lenguaje', date: DateTime.now().add(const Duration(days: 18))),
  ],
};