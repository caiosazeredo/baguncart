import 'package:flutter/material.dart';
import 'clientes_screen.dart';
import 'contratos_screen.dart';
import 'servicos_screen.dart';
import 'cadastro_screen.dart';
import 'login_screen.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Row(
          children: [
            Icon(Icons.celebration),
            SizedBox(width: 8),
            Text('BagunçArt'),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                const Icon(Icons.person),
                const SizedBox(width: 4),
                const Text('Administrador'),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () => _logout(context),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: _getCrossAxisCount(context),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.2,
          children: [
            _buildMenuCard(
              context,
              'CLIENTES',
              Icons.people,
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ClientesScreen())),
            ),
            _buildMenuCard(
              context,
              'CONTRATOS',
              Icons.description,
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ContratosScreen())),
            ),
            _buildMenuCard(
              context,
              'SERVIÇOS',
              Icons.build,
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ServicosScreen())),
            ),
            _buildMenuCard(
              context,
              'CADASTRAR\nCLIENTE',
              Icons.person_add,
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CadastroScreen())),
            ),
            _buildMenuCard(
              context,
              'PROMOÇÕES',
              Icons.local_offer,
              () => _showDevelopment(context),
            ),
            _buildMenuCard(
              context,
              'NOTIFICAÇÕES',
              Icons.notifications,
              () => _showDevelopment(context),
            ),
          ],
        ),
      ),
    );
  }

  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) return 1;
    if (width < 900) return 2;
    return 3;
  }

  Widget _buildMenuCard(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: LinearGradient(
              colors: [const Color(0xFFFF8C00), const Color(0xFFFF8C00).withOpacity(0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48,
                color: Colors.white,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Deseja realmente sair?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (_) => false,
              );
            },
            child: const Text('Sair'),
          ),
        ],
      ),
    );
  }

  void _showDevelopment(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Funcionalidade em desenvolvimento')),
    );
  }
}
