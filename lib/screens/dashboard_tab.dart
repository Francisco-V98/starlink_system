import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/services.dart';
import '../providers/data_provider.dart';
import '../models/client_model.dart';
import 'user_detail_screen.dart';

class DashboardTab extends StatefulWidget {
  const DashboardTab({super.key});

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  final Map<String, bool> _expandedGroups = {};
  bool _allExpanded = false;

  void _toggleAll(List<ClientGroup> data) {
    setState(() {
      _allExpanded = !_allExpanded;
      for (var group in data) {
        _expandedGroups[group.email] = _allExpanded;
      }
    });
  }

  void _toggleGroup(String email) {
    setState(() {
      _expandedGroups[email] = !(_expandedGroups[email] ?? false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DataProvider>(context);
    final data = provider.filteredData;

    // Calculate statistics
    final totalEmails = data.length;
    final totalUsers = data.fold<int>(
      0,
      (sum, group) => sum + group.users.length,
    );
    final totalOverdueUsers = data.fold<int>(0, (sum, group) {
      return sum + group.users.where((u) => u.overdueMonths > 0).length;
    });
    final totalPaymentDueUsers = data.fold<int>(0, (sum, group) {
      return sum + group.users.where((u) => u.isPaymentDue).length;
    });

    // Purple Stat: Total users who haven't paid current month
    final totalPendingMonthUsers = data.fold<int>(0, (sum, group) {
      return sum + group.users.where((u) => u.isPendingMonth).length;
    });

    // Solvente Stat: Total users with no issues
    final totalSolventUsers = data.fold<int>(0, (sum, group) {
      return sum + group.users.where((u) => u.isSolvent).length;
    });

    return Column(
      children: [
        // Search Bar
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Buscar por correo, nombre o ubicación...',
              prefixIcon: const Icon(LucideIcons.search, color: Colors.grey),
              suffixIcon: IconButton(
                onPressed: () => _showFilterDialog(context),
                icon: const Icon(LucideIcons.filter, color: Colors.blue),
                tooltip: 'Filtrar',
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            onChanged: (value) => provider.setSearchTerm(value),
          ),
        ),

        // Controls and Statistics
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: () => _toggleAll(data),
                    icon: Icon(
                      _allExpanded
                          ? LucideIcons.chevronsUp
                          : LucideIcons.chevronsDown,
                      size: 16,
                    ),
                    label: Text(
                      _allExpanded ? 'Colapsar todo' : 'Expandir todo',
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      textStyle: const TextStyle(fontSize: 13),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => _showLegend(context),
                    icon: const Icon(
                      LucideIcons.helpCircle,
                      color: Colors.blueGrey,
                    ),
                    tooltip: 'Ver leyenda de estados',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        LucideIcons.mail,
                        size: 14,
                        color: Colors.blue.shade700,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$totalEmails',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('•', style: TextStyle(color: Colors.blue.shade300)),
                      const SizedBox(width: 8),
                      Icon(
                        LucideIcons.users,
                        size: 14,
                        color: Colors.blue.shade700,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$totalUsers',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                          fontSize: 13,
                        ),
                      ),
                      if (totalPaymentDueUsers > 0) ...[
                        const SizedBox(width: 8),
                        Text(
                          '•',
                          style: TextStyle(color: Colors.blue.shade300),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          LucideIcons.clock,
                          size: 14,
                          color: Colors.orange,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$totalPaymentDueUsers',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                            fontSize: 13,
                          ),
                        ),
                      ],
                      if (totalOverdueUsers > 0) ...[
                        const SizedBox(width: 8),
                        Text(
                          '•',
                          style: TextStyle(color: Colors.blue.shade300),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          LucideIcons.alertCircle,
                          size: 14,
                          color: Colors.red,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$totalOverdueUsers',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                            fontSize: 13,
                          ),
                        ),
                      ],
                      if (totalPendingMonthUsers > 0) ...[
                        const SizedBox(width: 8),
                        Text(
                          '•',
                          style: TextStyle(color: Colors.blue.shade300),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          LucideIcons.calendar,
                          size: 14,
                          color: Colors.purple,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$totalPendingMonthUsers',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.purple,
                            fontSize: 13,
                          ),
                        ),
                      ],
                      if (totalSolventUsers > 0) ...[
                        const SizedBox(width: 8),
                        Text(
                          '•',
                          style: TextStyle(color: Colors.blue.shade300),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          LucideIcons.checkCircle,
                          size: 14,
                          color: Colors.green,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$totalSolventUsers',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // List
        Expanded(
          child: provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: () => provider.refresh(),
                  child: data.isEmpty
                      ? SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: SizedBox(
                            height: MediaQuery.of(context).size.height * 0.7,
                            child: const Center(
                              child: Text('No se encontraron resultados'),
                            ),
                          ),
                        )
                      : ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(16),
                          itemCount: data.length,
                          itemBuilder: (context, index) {
                            final group = data[index];
                            final isExpanded =
                                _expandedGroups[group.email] ?? false;
                            return _ClientGroupCard(
                              group: group,
                              isExpanded: isExpanded,
                              onToggle: () => _toggleGroup(group.email),
                            );
                          },
                        ),
                ),
        ),
      ],
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        final provider = Provider.of<DataProvider>(context);
        return AlertDialog(
          title: const Text('Filtrar Usuarios'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Estado',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                _buildFilterCheckbox(
                  'Solvente',
                  provider.selectedStatusFilters.contains('Solvente'),
                  (val) => provider.toggleStatusFilter('Solvente'),
                ),
                _buildFilterCheckbox(
                  'Mes por pagar',
                  provider.selectedStatusFilters.contains('Mes por pagar'),
                  (val) => provider.toggleStatusFilter('Mes por pagar'),
                ),
                _buildFilterCheckbox(
                  'Pago pendiente',
                  provider.selectedStatusFilters.contains('Pago pendiente'),
                  (val) => provider.toggleStatusFilter('Pago pendiente'),
                ),
                _buildFilterCheckbox(
                  'Moroso',
                  provider.selectedStatusFilters.contains('Moroso'),
                  (val) => provider.toggleStatusFilter('Moroso'),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Plan',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                _buildFilterCheckbox(
                  'Ilimitado',
                  provider.selectedPlanFilters.contains('Ilimitado'),
                  (val) => provider.togglePlanFilter('Ilimitado'),
                ),
                _buildFilterCheckbox(
                  '50GB',
                  provider.selectedPlanFilters.contains('50GB'),
                  (val) => provider.togglePlanFilter('50GB'),
                ),
                // Add more plans if needed
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                provider.clearFilters();
                // Navigator.pop(context); // Optional: close on clear? better to keep open
              },
              child: const Text(
                'Limpiar Filtros',
                style: TextStyle(color: Colors.red),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Aplicar'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFilterCheckbox(
    String title,
    bool value,
    Function(bool?) onChanged,
  ) {
    return CheckboxListTile(
      title: Text(title, style: const TextStyle(fontSize: 14)),
      value: value,
      onChanged: onChanged,
      contentPadding: EdgeInsets.zero,
      dense: true,
      controlAffinity: ListTileControlAffinity.leading,
    );
  }

  void _showLegend(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leyenda de Estados'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLegendItem(
              LucideIcons.checkCircle,
              Colors.green,
              'Solvente',
              'Usuario al día, sin deudas ni pagos pendientes.',
            ),
            const SizedBox(height: 12),
            _buildLegendItem(
              LucideIcons.calendar,
              Colors.purple,
              'Mes por pagar',
              'Mes en curso pendiente. Aún no ha llegado a su fecha de corte.',
            ),
            const SizedBox(height: 12),
            _buildLegendItem(
              LucideIcons.clock,
              Colors.orange,
              'Pago pendiente',
              'Actualmente en su periodo de pago (fecha de corte activa).',
            ),
            const SizedBox(height: 12),
            _buildLegendItem(
              LucideIcons.alertCircle,
              Colors.red,
              'Moroso',
              'Tiene uno o más meses vencidos sin pagar.',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(
    IconData icon,
    Color color,
    String title,
    String description,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: const TextStyle(fontSize: 12, color: Colors.black87),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ClientGroupCard extends StatelessWidget {
  final ClientGroup group;
  final bool isExpanded;
  final VoidCallback onToggle;
  const _ClientGroupCard({
    required this.group,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final overdueCount = group.users.where((u) => u.overdueMonths > 0).length;
    final paymentDueCount = group.users.where((u) => u.isPaymentDue).length;

    final pendingMonthCount = group.users.where((u) => u.isPendingMonth).length;
    final solventCount = group.users.where((u) => u.isSolvent).length;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Group Header
          InkWell(
            onTap: onToggle,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.vertical(
                  top: const Radius.circular(12),
                  bottom: isExpanded ? Radius.zero : const Radius.circular(12),
                ),
                border: isExpanded
                    ? Border(bottom: BorderSide(color: Colors.grey.shade200))
                    : null,
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          group.email,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E3A8A),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(
                        isExpanded
                            ? LucideIcons.chevronUp
                            : LucideIcons.chevronDown,
                        size: 20,
                        color: Colors.grey.shade600,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const SizedBox(height: 10),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade600,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.shade200,
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              LucideIcons.users,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${group.users.length} usuario${group.users.length != 1 ? 's' : ''}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (paymentDueCount > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade600,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.orange.shade200,
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                LucideIcons.clock,
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '$paymentDueCount por pagar',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (overdueCount > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.shade600,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.red.shade200,
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                LucideIcons.alertCircle,
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '$overdueCount moroso${overdueCount != 1 ? 's' : ''}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (pendingMonthCount > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.purple.shade600,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.purple.shade200,
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                LucideIcons.calendar,
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '$pendingMonthCount', // Just the count
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (solventCount > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.shade600,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.green.shade200,
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                LucideIcons.checkCircle,
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '$solventCount',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  if (group.alias.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      group.alias,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Users List (Collapsible)
          if (isExpanded)
            Column(
              children: group.users.map((user) {
                return _UserListTile(email: group.email, user: user);
              }).toList(),
            ),
        ],
      ),
    );
  }
}

class _UserListTile extends StatelessWidget {
  final String email;
  final User user;

  const _UserListTile({required this.email, required this.user});

  static const List<String> months = [
    "Enero",
    "Febrero",
    "Marzo",
    "Abril",
    "Mayo",
    "Junio",
    "Julio",
    "Agosto",
    "Septiembre",
    "Octubre",
    "Noviembre",
    "Diciembre",
  ];

  Future<void> _launchWhatsApp(BuildContext context) async {
    if (user.phoneNumber.isEmpty) {
      _showNoPhoneDialog(context);
      return;
    }

    final overdueMonthsList = <String>[];
    final now = DateTime.now();

    // Calculate overdue months names
    DateTime iterator;
    if (now.day > user.paymentEndDay) {
      iterator = DateTime(now.year, now.month);
    } else {
      iterator = DateTime(now.year, now.month - 1);
    }

    if (user.serviceStartDate != null) {
      final start = DateTime(
        user.serviceStartDate!.year,
        user.serviceStartDate!.month,
      );
      while (iterator.isAfter(start) || iterator.isAtSameMomentAs(start)) {
        final key =
            "${iterator.year}-${iterator.month.toString().padLeft(2, '0')}";
        if (user.payments.containsKey(key)) {
          break;
        }
        overdueMonthsList.add("${months[iterator.month - 1]} ${iterator.year}");
        iterator = DateTime(iterator.year, iterator.month - 1);
      }
    }

    // Add current month if payment due
    if (user.isPaymentDue) {
      // Check if already in list (could happen if logic overlaps, though shouldn't with correct logic)
      final currentMonthStr = "${months[now.month - 1]} ${now.year}";
      if (!overdueMonthsList.contains(currentMonthStr)) {
        overdueMonthsList.insert(0, currentMonthStr);
      }
    }

    if (overdueMonthsList.isEmpty) return;

    final message =
        "Hola *${user.name}* 👋,\n\n"
        "Le recordamos que su fecha de corte es del *${user.paymentStartDay} al ${user.paymentEndDay}* de cada mes.\n\n"
        "Actualmente presenta los siguientes pagos pendientes:\n"
        "${overdueMonthsList.map((m) => "• $m").join("\n")}\n\n"
        "Por favor, realice su pago a la brevedad para mantener su servicio activo.\n\n"
        "Gracias por su preferencia.";

    final url = Uri.parse(
      "https://wa.me/${user.phoneNumber.replaceAll(RegExp(r'[^0-9]'), '')}?text=${Uri.encodeComponent(message)}",
    );

    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No se pudo abrir WhatsApp')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al abrir WhatsApp: $e')));
      }
    }
  }

  void _showNoPhoneDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sin número de teléfono'),
        content: const Text(
          'Este usuario no tiene un número de teléfono registrado.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cerrar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _showEditDialog(context);
            },
            child: const Text(
              'Agregar número',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    final nameController = TextEditingController(text: user.name);
    // Try to parse existing phone number
    String initialPhone = user.phoneNumber;
    Country selectedCountry = Country.parse('VE');

    // Simple heuristic: if starts with +, try to find country
    // For now, we'll just assume if it doesn't match our format, we leave it as is in the controller
    // but default the picker to VE.
    // Ideally we would parse it.

    final phoneController = TextEditingController(text: initialPhone);
    final serialController = TextEditingController(text: user.antennaSerial);
    final countryController = TextEditingController(text: user.country);
    String selectedPlan = user.plan;
    int startDay = user.paymentStartDay;
    int endDay = user.paymentEndDay;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Editar Usuario'),
        content: StatefulBuilder(
          builder: (context, setDialogState) => SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre / Ubicación',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    labelText: 'Teléfono',
                    border: const OutlineInputBorder(),
                    prefixIcon: Container(
                      padding: const EdgeInsets.all(12),
                      child: InkWell(
                        onTap: () {
                          showCountryPicker(
                            context: context,
                            showPhoneCode: true,
                            onSelect: (Country country) {
                              setDialogState(() {
                                selectedCountry = country;
                              });
                            },
                          );
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${selectedCountry.flagEmoji} +${selectedCountry.phoneCode}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            const Icon(Icons.arrow_drop_down, size: 18),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: serialController,
                  decoration: const InputDecoration(
                    labelText: 'Serial de la Antena',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(LucideIcons.router),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: countryController,
                  decoration: const InputDecoration(
                    labelText: 'País',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(LucideIcons.globe),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedPlan,
                  decoration: const InputDecoration(
                    labelText: 'Plan',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'Ilimitado',
                      child: Text('Ilimitado'),
                    ),
                    DropdownMenuItem(value: '50gb', child: Text('50 GB')),
                  ],
                  onChanged: (value) {
                    setDialogState(() {
                      selectedPlan = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: startDay,
                        decoration: const InputDecoration(
                          labelText: 'Día Inicio',
                          border: OutlineInputBorder(),
                        ),
                        items: List.generate(31, (index) => index + 1).map((
                          day,
                        ) {
                          return DropdownMenuItem(
                            value: day,
                            child: Text(day.toString()),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setDialogState(() {
                            startDay = value!;
                            if (endDay < startDay) {
                              endDay = startDay;
                            }
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: endDay,
                        decoration: const InputDecoration(
                          labelText: 'Día Fin',
                          border: OutlineInputBorder(),
                        ),
                        items: List.generate(31, (index) => index + 1).map((
                          day,
                        ) {
                          return DropdownMenuItem(
                            value: day,
                            child: Text(day.toString()),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setDialogState(() {
                            if (value! >= startDay) {
                              endDay = value;
                            }
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              // Construct full phone number
              // If the user didn't change the text and it was already full, we might double prefix if we are not careful.
              // But here we are forcing digits only in the input.
              // So if the original was "+58 412...", the input will show "58412..." (digits only).
              // This is tricky for editing existing data.
              // Ideally we should strip the country code from the initial value if it matches.

              String finalPhone = phoneController.text;
              if (finalPhone.isNotEmpty) {
                finalPhone = '+${selectedCountry.phoneCode} $finalPhone';
              }

              Provider.of<DataProvider>(context, listen: false).updateUser(
                email,
                user.id,
                name: nameController.text,
                plan: selectedPlan,
                phoneNumber: finalPhone,
                antennaSerial: serialController.text,
                country: countryController.text,
                paymentStartDay: startDay,
                paymentEndDay: endDay,
              );
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Usuario actualizado'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text(
              'Guardar',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final overdueMonths = user.overdueMonths;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UserDetailScreen(email: email, user: user),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        user.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      if (overdueMonths > 0) ...[
                        const SizedBox(width: 8),
                        const Icon(
                          LucideIcons.alertCircle,
                          color: Colors.red,
                          size: 16,
                        ),
                      ],
                      if (user.isPaymentDue) ...[
                        const SizedBox(width: 8),
                        const Icon(
                          LucideIcons.clock,
                          color: Colors.orange,
                          size: 16,
                        ),
                      ],
                      if (user.isPendingMonth) ...[
                        const SizedBox(width: 8),
                        const Icon(
                          LucideIcons.calendar,
                          color: Colors.purple,
                          size: 16,
                        ),
                      ],
                      if (overdueMonths == 0 &&
                          !user.isPaymentDue &&
                          !user.isPendingMonth) ...[
                        const SizedBox(width: 8),
                        const Icon(
                          LucideIcons.checkCircle,
                          color: Colors.green,
                          size: 16,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: user.plan == 'Ilimitado'
                              ? Colors.purple.shade50
                              : Colors.teal.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          user.plan,
                          style: TextStyle(
                            color: user.plan == 'Ilimitado'
                                ? Colors.purple
                                : Colors.teal,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            LucideIcons.calendar,
                            size: 12,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            user.range,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      if (overdueMonths > 0)
                        Text(
                          '$overdueMonths mes${overdueMonths != 1 ? 'es' : ''} de retraso',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      if (user.isPaymentDue)
                        const Text(
                          'Pago pendiente',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      if (user.isPendingMonth)
                        const Text(
                          'Mes por pagar',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.purple,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      if (overdueMonths == 0 &&
                          !user.isPaymentDue &&
                          !user.isPendingMonth)
                        const Text(
                          'Solvente',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                  if (user.note != null && user.note!.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 6),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Text(
                        user.note!,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (overdueMonths > 0 || user.isPaymentDue) ...[
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => _launchWhatsApp(context),
                icon: const Icon(
                  LucideIcons.messageCircle,
                  color: Colors.green,
                ),
                tooltip: 'Enviar WhatsApp',
              ),
            ],
            const Icon(LucideIcons.chevronRight, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }
}
