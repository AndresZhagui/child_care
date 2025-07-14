import 'package:flutter/material.dart';
import '../models/models.dart';

class ChildrenManagementScreen extends StatefulWidget {
  const ChildrenManagementScreen({super.key});

  @override
  ChildrenManagementScreenState createState() => ChildrenManagementScreenState();
}

class ChildrenManagementScreenState extends State<ChildrenManagementScreen> {
  // Lista de niños (usaremos la lista global)
  List<Child> children = [];

  @override
  void initState() {
    super.initState();
    // Inicializar con los niños existentes
    children = List.from(appState.currentUser!.children);
  }

  // Función para agregar un nuevo niño
  void _addChild(Child newChild) {
    setState(() {
      children.add(newChild);
      appState.addChild(newChild);
    });
  }

  // Función para actualizar un niño existente
  void _updateChild(int index, Child updatedChild) {
    setState(() {
      children[index] = updatedChild;
      // Actualizar lista global
      appState.currentUser!.children[index] = updatedChild;
    });
  }

  // Función para eliminar un niño
  void _deleteChild(int index) {
    setState(() {
      children.removeAt(index);
      // Actualizar lista global
      appState.currentUser!.children.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Niños'),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
        backgroundColor: const Color(0xFF4CAF50),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddChildDialog(context),
          ),
        ],
      ),
      body: children.isEmpty
          ? const Center(
        child: Text(
          'No hay niños registrados\nPresiona el botón + para agregar uno',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: children.length,
        itemBuilder: (context, index) {
          return _buildChildCard(children[index], index);
        },
      ),
    );
  }

  Widget _buildChildCard(Child child, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        title: Text(
          child.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        subtitle: Text(
          '${child.age} años | ${child.gender} | ${child.bloodType}',
          style: const TextStyle(fontSize: 14),
        ),
        leading: CircleAvatar(
          child: Text(
            child.name[0],
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () => _showEditChildDialog(context, child, index),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _showDeleteConfirmation(context, index),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Peso:', '${child.weight} kg'),
                _buildInfoRow('Talla:', '${child.height} cm'),
                const SizedBox(height: 16),

                // Sección de Enfermedades
                _buildExpandableSection(
                  title: 'Enfermedades',
                  items: child.diseases,
                  icon: Icons.medical_services,
                  color: Colors.red,
                ),

                // Sección de Alergias
                _buildExpandableSection(
                  title: 'Alergias',
                  items: child.allergies,
                  icon: Icons.warning,
                  color: Colors.orange,
                ),

                // Sección de Vacunas
                _buildExpandableSection(
                  title: 'Vacunas',
                  items: child.vaccines,
                  icon: Icons.medical_information,
                  color: Colors.green,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandableSection({
    required String title,
    required List<String> items,
    required IconData icon,
    required Color color,
  }) {
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      title: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: color,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${items.length}',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      children: [
        if (items.isEmpty)
          const Padding(
            padding: EdgeInsets.only(left: 32, bottom: 8),
            child: Text(
              'No hay información',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          )
        else
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(left: 32, bottom: 8),
            child: Row(
              children: [
                const Icon(Icons.circle, size: 8),
                const SizedBox(width: 8),
                Text(item),
              ],
            ),
          )),
      ],
    );
  }

  // Diálogo para agregar un nuevo niño
  void _showAddChildDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final birthDateController = TextEditingController();
    final bloodTypeController = TextEditingController();
    final weightController = TextEditingController();
    final heightController = TextEditingController();
    String gender = 'Masculino';
    List<String> diseases = [];
    List<String> allergies = [];
    List<String> vaccines = [];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Agregar Niño'),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(labelText: 'Nombre completo'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingrese el nombre';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Selector de género
                      DropdownButtonFormField<String>(
                        value: gender,
                        items: const [
                          DropdownMenuItem(value: 'Masculino', child: Text('Masculino')),
                          DropdownMenuItem(value: 'Femenino', child: Text('Femenino')),
                          DropdownMenuItem(value: 'Otro', child: Text('Otro')),
                        ],
                        onChanged: (value) {
                          setState(() => gender = value!);
                        },
                        decoration: const InputDecoration(labelText: 'Género'),
                      ),
                      const SizedBox(height: 16),

                      // Fecha de nacimiento
                      TextFormField(
                        controller: birthDateController,
                        decoration: const InputDecoration(
                          labelText: 'Fecha de nacimiento',
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        readOnly: true,
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2010),
                            lastDate: DateTime.now(),
                          );
                          if (date != null) {
                            birthDateController.text =
                            '${date.day}/${date.month}/${date.year}';
                          }
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor seleccione la fecha';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: bloodTypeController,
                        decoration: const InputDecoration(labelText: 'Tipo de sangre'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingrese el tipo de sangre';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: weightController,
                              decoration: const InputDecoration(labelText: 'Peso (kg)'),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Ingrese el peso';
                                }
                                if (double.tryParse(value) == null) {
                                  return 'Valor inválido';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: heightController,
                              decoration: const InputDecoration(labelText: 'Talla (cm)'),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Ingrese la talla';
                                }
                                if (double.tryParse(value) == null) {
                                  return 'Valor inválido';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Sección para enfermedades, alergias y vacunas
                      _buildMultiInputSection(
                        title: 'Enfermedades',
                        items: diseases,
                        onAdd: (value) {
                          if (value.isNotEmpty) {
                            setState(() => diseases.add(value));
                          }
                        },
                        onRemove: (index) {
                          setState(() => diseases.removeAt(index));
                        },
                      ),

                      _buildMultiInputSection(
                        title: 'Alergias',
                        items: allergies,
                        onAdd: (value) {
                          if (value.isNotEmpty) {
                            setState(() => allergies.add(value));
                          }
                        },
                        onRemove: (index) {
                          setState(() => allergies.removeAt(index));
                        },
                      ),

                      _buildMultiInputSection(
                        title: 'Vacunas',
                        items: vaccines,
                        onAdd: (value) {
                          if (value.isNotEmpty) {
                            setState(() => vaccines.add(value));
                          }
                        },
                        onRemove: (index) {
                          setState(() => vaccines.removeAt(index));
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      final birthDateParts = birthDateController.text.split('/');
                      final birthDate = DateTime(
                        int.parse(birthDateParts[2]),
                        int.parse(birthDateParts[1]),
                        int.parse(birthDateParts[0]),
                      );

                      final newChild = Child(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        name: nameController.text,
                        birthDate: birthDate,
                        gender: gender,
                        bloodType: bloodTypeController.text,
                        weight: double.parse(weightController.text),
                        height: double.parse(heightController.text),
                        diseases: diseases,
                        allergies: allergies,
                        vaccines: vaccines,
                      );
                      _addChild(newChild);

                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildMultiInputSection({
    required String title,
    required List<String> items,
    required Function(String) onAdd,
    required Function(int) onRemove,
  }) {
    final controller = TextEditingController();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),

        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: 'Agregar $title',
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                onAdd(controller.text);
                controller.clear();
              },
            ),
          ],
        ),

        if (items.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(items.length, (index) {
              return Chip(
                label: Text(items[index]),
                deleteIcon: const Icon(Icons.close, size: 16),
                onDeleted: () => onRemove(index),
              );
            }),
          ),
        ],
        const SizedBox(height: 16),
      ],
    );
  }

  // Diálogo para editar un niño existente
  void _showEditChildDialog(BuildContext context, Child child, int index) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: child.name);
    final birthDateController = TextEditingController(
        text: '${child.birthDate.day}/${child.birthDate.month}/${child.birthDate.year}'
    );
    final bloodTypeController = TextEditingController(text: child.bloodType);
    final weightController = TextEditingController(text: child.weight.toString());
    final heightController = TextEditingController(text: child.height.toString());
    String gender = child.gender;
    List<String> diseases = List.from(child.diseases);
    List<String> allergies = List.from(child.allergies);
    List<String> vaccines = List.from(child.vaccines);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Editar Niño'),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(labelText: 'Nombre completo'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingrese el nombre';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Selector de género
                      DropdownButtonFormField<String>(
                        value: gender,
                        items: const [
                          DropdownMenuItem(value: 'Masculino', child: Text('Masculino')),
                          DropdownMenuItem(value: 'Femenino', child: Text('Femenino')),
                          DropdownMenuItem(value: 'Otro', child: Text('Otro')),
                        ],
                        onChanged: (value) {
                          setState(() => gender = value!);
                        },
                        decoration: const InputDecoration(labelText: 'Género'),
                      ),
                      const SizedBox(height: 16),

                      // Fecha de nacimiento
                      TextFormField(
                        controller: birthDateController,
                        decoration: const InputDecoration(
                          labelText: 'Fecha de nacimiento',
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        readOnly: true,
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: child.birthDate,
                            firstDate: DateTime(2010),
                            lastDate: DateTime.now(),
                          );
                          if (date != null) {
                            birthDateController.text =
                            '${date.day}/${date.month}/${date.year}';
                          }
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor seleccione la fecha';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: bloodTypeController,
                        decoration: const InputDecoration(labelText: 'Tipo de sangre'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingrese el tipo de sangre';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: weightController,
                              decoration: const InputDecoration(labelText: 'Peso (kg)'),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Ingrese el peso';
                                }
                                if (double.tryParse(value) == null) {
                                  return 'Valor inválido';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: heightController,
                              decoration: const InputDecoration(labelText: 'Talla (cm)'),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Ingrese la talla';
                                }
                                if (double.tryParse(value) == null) {
                                  return 'Valor inválido';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Sección para enfermedades, alergias y vacunas
                      _buildMultiInputSection(
                        title: 'Enfermedades',
                        items: diseases,
                        onAdd: (value) {
                          if (value.isNotEmpty) {
                            setState(() => diseases.add(value));
                          }
                        },
                        onRemove: (index) {
                          setState(() => diseases.removeAt(index));
                        },
                      ),

                      _buildMultiInputSection(
                        title: 'Alergias',
                        items: allergies,
                        onAdd: (value) {
                          if (value.isNotEmpty) {
                            setState(() => allergies.add(value));
                          }
                        },
                        onRemove: (index) {
                          setState(() => allergies.removeAt(index));
                        },
                      ),

                      _buildMultiInputSection(
                        title: 'Vacunas',
                        items: vaccines,
                        onAdd: (value) {
                          if (value.isNotEmpty) {
                            setState(() => vaccines.add(value));
                          }
                        },
                        onRemove: (index) {
                          setState(() => vaccines.removeAt(index));
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      final birthDateParts = birthDateController.text.split('/');
                      final birthDate = DateTime(
                        int.parse(birthDateParts[2]),
                        int.parse(birthDateParts[1]),
                        int.parse(birthDateParts[0]),
                      );

                      final updatedChild = Child(
                        id: child.id,
                        name: nameController.text,
                        birthDate: birthDate,
                        gender: gender,
                        bloodType: bloodTypeController.text,
                        weight: double.parse(weightController.text),
                        height: double.parse(heightController.text),
                        diseases: diseases,
                        allergies: allergies,
                        vaccines: vaccines,
                      );

                      _updateChild(index, updatedChild);
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Actualizar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Confirmación para eliminar un niño
  void _showDeleteConfirmation(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmar eliminación'),
          content: Text(
            '¿Estás seguro de que deseas eliminar a ${children[index].name}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                _deleteChild(index);
                Navigator.pop(context);
              },
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }
}