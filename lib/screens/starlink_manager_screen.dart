import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'dashboard_tab.dart';
import 'registration_tab.dart';

class StarlinkManagerScreen extends StatefulWidget {
  const StarlinkManagerScreen({super.key});

  @override
  State<StarlinkManagerScreen> createState() => _StarlinkManagerScreenState();
}

class _StarlinkManagerScreenState extends State<StarlinkManagerScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E3A8A), // blue-900
        title: Row(
          children: [
            const Icon(LucideIcons.dollarSign, color: Color(0xFFFACC15), size: 32), // yellow-400
            const SizedBox(width: 8),
            const Text(
              'Starlink Admin',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) async {
              if (value == 'logout') {
                await FirebaseAuth.instance.signOut();
              }
            },
            itemBuilder: (BuildContext context) {
              final userEmail = FirebaseAuth.instance.currentUser?.email ?? 'Usuario';
              return [
                PopupMenuItem<String>(
                  enabled: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sesión iniciada como:',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        userEmail,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem<String>(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout, color: Colors.black54),
                      SizedBox(width: 8),
                      Text('Cerrar Sesión'),
                    ],
                  ),
                ),
              ];
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.blue.shade200,
          tabs: const [
            Tab(
              icon: Icon(LucideIcons.checkCircle),
              text: 'Control de Pagos',
            ),
            Tab(
              icon: Icon(LucideIcons.plus),
              text: 'Registro',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          DashboardTab(),
          RegistrationTab(),
        ],
      ),
    );
  }
}
