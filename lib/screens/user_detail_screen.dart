import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/data_provider.dart';
import '../models/client_model.dart';

class UserDetailScreen extends StatefulWidget {
  final String email;
  final User user;

  const UserDetailScreen({
    super.key,
    required this.email,
    required this.user,
  });

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  int _currentYear = DateTime.now().year;
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
    "Diciembre"
  ];
  static const List<String> monthsShort = [
    "Ene",
    "Feb",
    "Mar",
    "Abr",
    "May",
    "Jun",
    "Jul",
    "Ago",
    "Sep",
    "Oct",
    "Nov",
    "Dic"
  ];

  void _showPaymentConfirmation(String month, String monthKey, String? currentPaymentDate) async {
    final bool isPaid = currentPaymentDate != null;
    
    if (isPaid) {
      // Show unmark confirmation
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Desmarcar pago'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('¿Deseas desmarcar el mes de $month como pagado?'),
              const SizedBox(height: 8),
              Text(
                'Fecha de pago: ${_formatDate(currentPaymentDate)}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Provider.of<DataProvider>(context, listen: false)
                    .setPaymentDate(widget.email, widget.user.id, monthKey, null);
                Navigator.pop(ctx);
              },
              child: const Text(
                'Desmarcar',
                style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );
    } else {
      // Show date picker
      final DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2020),
        lastDate: DateTime(2100),
        locale: const Locale('es', 'ES'),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: Color(0xFF1E3A8A),
                onPrimary: Colors.white,
                onSurface: Colors.black,
              ),
            ),
            child: child!,
          );
        },
      );

      if (pickedDate != null) {
        Provider.of<DataProvider>(context, listen: false)
            .setPaymentDate(widget.email, widget.user.id, monthKey, pickedDate.toIso8601String());
      }
    }
  }

  String _formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return isoDate;
    }
  }

  void _showOptionsMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(LucideIcons.edit, color: Color(0xFF1E3A8A)),
              title: const Text('Editar Usuario'),
              onTap: () {
                Navigator.pop(ctx);
                _showEditDialog();
              },
            ),
            ListTile(
              leading: const Icon(LucideIcons.trash2, color: Colors.red),
              title: const Text('Eliminar Usuario', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(ctx);
                _showDeleteConfirmation();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog() {
    final nameController = TextEditingController(text: widget.user.name);
    final phoneController = TextEditingController(text: widget.user.phoneNumber);
    final serialController = TextEditingController(text: widget.user.antennaSerial);
    final countryController = TextEditingController(text: widget.user.country);
    String selectedPlan = widget.user.plan;
    int startDay = widget.user.paymentStartDay;
    int endDay = widget.user.paymentEndDay;

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
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Teléfono',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(LucideIcons.phone),
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
                    DropdownMenuItem(value: 'Ilimitado', child: Text('Ilimitado')),
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
                        items: List.generate(31, (index) => index + 1).map((day) {
                          return DropdownMenuItem(value: day, child: Text(day.toString()));
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
                        items: List.generate(31, (index) => index + 1).map((day) {
                          return DropdownMenuItem(value: day, child: Text(day.toString()));
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
              Provider.of<DataProvider>(context, listen: false).updateUser(
                widget.email,
                widget.user.id,
                name: nameController.text,
                plan: selectedPlan,
                phoneNumber: phoneController.text,
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
            child: const Text('Guardar', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar usuario'),
        content: const Text('¿Estás seguro de eliminar este usuario? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<DataProvider>(context, listen: false)
                  .deleteUser(widget.email, widget.user.id);
              Navigator.pop(ctx);
              Navigator.pop(context); // Volver a la pantalla anterior
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Usuario eliminado'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DataProvider>(context);
    final currentUser = provider.data
        .firstWhere((g) => g.email == widget.email)
        .users
        .firstWhere((u) => u.id == widget.user.id);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
        title: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    currentUser.name,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    widget.email,
                    style: const TextStyle(fontSize: 11, color: Colors.white70),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.moreVertical),
            onPressed: _showOptionsMenu,
          ),
        ],
      ),
      body: Column(
        children: [
          // User Info Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade200,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Wrap(
                  spacing: 20,
                  runSpacing: 20,
                  alignment: WrapAlignment.center,
                  children: [
                    _InfoChip(
                      icon: LucideIcons.package,
                      label: 'Plan',
                      value: currentUser.plan,
                      color: currentUser.plan == 'Ilimitado' ? Colors.purple : Colors.teal,
                    ),
                    _InfoChip(
                      icon: LucideIcons.calendar,
                      label: 'Días de Pago',
                      value: currentUser.range,
                      color: Colors.blue,
                    ),
                    if (currentUser.phoneNumber.isNotEmpty)
                      _InfoChip(
                        icon: LucideIcons.phone,
                        label: 'Teléfono',
                        value: currentUser.phoneNumber,
                        color: Colors.green,
                      ),
                    if (currentUser.antennaSerial.isNotEmpty)
                      _InfoChip(
                        icon: LucideIcons.router,
                        label: 'Serial',
                        value: currentUser.antennaSerial,
                        color: Colors.orange,
                      ),
                    if (currentUser.country.isNotEmpty)
                      _InfoChip(
                        icon: LucideIcons.globe,
                        label: 'País',
                        value: currentUser.country,
                        color: Colors.indigo,
                      ),
                  ],
                ),
                if (currentUser.note != null && currentUser.note!.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        const Icon(LucideIcons.alertCircle, color: Colors.red, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          currentUser.note!,
                          style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // Year Navigator
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            color: Colors.grey.shade50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(LucideIcons.chevronLeft),
                  onPressed: _currentYear > (currentUser.serviceStartDate?.year ?? 2020)
                      ? () {
                          setState(() {
                            _currentYear--;
                          });
                        }
                      : null,
                  color: _currentYear > (currentUser.serviceStartDate?.year ?? 2020)
                      ? Colors.black
                      : Colors.grey.shade300,
                ),
                const SizedBox(width: 20),
                Text(
                  '$_currentYear',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
                const SizedBox(width: 20),
                IconButton(
                  icon: const Icon(LucideIcons.chevronRight),
                  onPressed: _currentYear < (DateTime.now().year + 2)
                      ? () {
                          setState(() {
                            _currentYear++;
                          });
                        }
                      : null,
                  color: _currentYear < (DateTime.now().year + 2)
                      ? Colors.black
                      : Colors.grey.shade300,
                ),
              ],
            ),
          ),

          // Calendar Grid
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Responsive: 2 columns on small screens, 3 on medium, 4 on large
                int crossAxisCount = 2;
                if (constraints.maxWidth > 600) crossAxisCount = 3;
                if (constraints.maxWidth > 900) crossAxisCount = 4;

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.2,
                  ),
                  itemCount: months.length,
                  itemBuilder: (ctx, index) {
                    final month = months[index];
                    final monthNumber = index + 1;
                    final monthKey = "$_currentYear-${monthNumber.toString().padLeft(2, '0')}";
                    final paymentDate = currentUser.payments[monthKey];

                    bool isDisabled = false;
                    if (currentUser.serviceStartDate != null) {
                      final cardDate = DateTime(_currentYear, monthNumber);
                      // We only care about month/year precision. 
                      // If cardDate is strictly before the start date's month/year, disable it.
                      final startDate = DateTime(currentUser.serviceStartDate!.year, currentUser.serviceStartDate!.month);
                      if (cardDate.isBefore(startDate)) {
                        isDisabled = true;
                      }
                    }

                    return _MonthCard(
                      month: month,
                      paymentDate: paymentDate,
                      isDisabled: isDisabled,
                      onTap: () => _showPaymentConfirmation(month, monthKey, paymentDate),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _MonthCard extends StatelessWidget {
  final String month;
  final String? paymentDate;
  final bool isDisabled;
  final VoidCallback onTap;

  const _MonthCard({
    required this.month,
    required this.paymentDate,
    this.isDisabled = false,
    required this.onTap,
  });

  String _formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return isoDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isPaid = paymentDate != null;
    
    if (isDisabled) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey.shade200,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.ban,
              color: Colors.grey.shade300,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              month,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade400,
              ),
            ),
          ],
        ),
      );
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: isPaid ? Colors.green : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isPaid ? Colors.green.shade700 : Colors.grey.shade300,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: isPaid ? Colors.green.shade100 : Colors.grey.shade100,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isPaid ? LucideIcons.checkCircle2 : LucideIcons.circle,
              color: isPaid ? Colors.white : Colors.grey.shade400,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              month,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isPaid ? Colors.white : Colors.grey.shade700,
              ),
            ),
            if (isPaid)
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _formatDate(paymentDate!),
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
