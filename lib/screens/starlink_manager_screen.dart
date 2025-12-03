import 'package:flutter/material.dart';
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
