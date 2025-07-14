import 'package:child_care/models/models.dart';
import 'package:flutter/material.dart';
import 'profile_screen.dart';
import 'login_screen.dart';

class SettingsScreen extends StatelessWidget {
  final String username;

  const SettingsScreen({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
        ),
        backgroundColor: const Color(0xFF4CAF50),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Sección de Cuenta
          _buildSectionHeader('Cuenta'),
          _buildSettingsTile(
            icon: Icons.person,
            title: 'Perfil de usuario',
            subtitle: 'Administra tu información personal',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileScreen(username: username),
                ),
              );
            },
          ),

          // Sección de Preferencias
          _buildSectionHeader('Preferencias'),
          _buildSettingsTile(
            icon: Icons.notifications,
            title: 'Notificaciones',
            subtitle: 'Personaliza alertas y recordatorios',
          ),
          _buildSettingsTile(
            icon: Icons.medical_services,
            title: 'Unidades médicas',
            subtitle: 'Sistema métrico/imperial',
          ),
          _buildSettingsTile(
            icon: Icons.language,
            title: 'Idioma',
            subtitle: 'Español',
          ),

          // Sección de Seguridad
          _buildSectionHeader('Seguridad'),
          _buildSettingsTile(
            icon: Icons.lock,
            title: 'Privacidad',
            subtitle: 'Controla tus datos',
          ),
          _buildSettingsTile(
            icon: Icons.fingerprint,
            title: 'Autenticación biométrica',
            subtitle: 'Habilitar huella digital',
          ),

          // Sección de Soporte
          _buildSectionHeader('Soporte'),
          _buildSettingsTile(
            icon: Icons.help,
            title: 'Ayuda y soporte',
          ),
          _buildSettingsTile(
            icon: Icons.description,
            title: 'Términos y condiciones',
          ),

          // Cerrar sesión
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 30),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.logout),
              label: const Text('Cerrar sesión'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: () {
                _showLogoutConfirmation(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.teal,
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.teal),
      ),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Estás seguro de que quieres salir de la aplicación?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              // Lógica para cerrar sesión
              appState.logout();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (route) => false,
              );
            },
            child: const Text('Salir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}