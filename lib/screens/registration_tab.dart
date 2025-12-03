import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/data_provider.dart';

class RegistrationTab extends StatefulWidget {
  const RegistrationTab({super.key});

  @override
  State<RegistrationTab> createState() => _RegistrationTabState();
}

class _RegistrationTabState extends State<RegistrationTab> {
  final _formKey = GlobalKey<FormState>();
  bool _isNewEmailMode = false;
  String? _selectedEmail;
  final _newEmailController = TextEditingController();
  final _userNameController = TextEditingController();
  String _userPlan = 'Ilimitado';
  final _userRangeController = TextEditingController();

  @override
  void dispose() {
    _newEmailController.dispose();
    _userNameController.dispose();
    _userRangeController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<DataProvider>(context, listen: false);
      
      final targetEmail = _isNewEmailMode ? _newEmailController.text : _selectedEmail;
      if (targetEmail == null || targetEmail.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor selecciona o ingresa un correo')),
        );
        return;
      }

      provider.addUser(
        email: targetEmail,
        name: _userNameController.text,
        plan: _userPlan,
        range: _userRangeController.text,
        isNewEmail: _isNewEmailMode,
      );

      // Reset form
      _userNameController.clear();
      _userRangeController.clear();
      if (_isNewEmailMode) {
        _newEmailController.clear();
        setState(() {
          _isNewEmailMode = false;
        });
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuario agregado correctamente'), backgroundColor: Colors.green),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DataProvider>(context);
    final existingEmails = provider.data.map((e) => e.email).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(LucideIcons.user, color: Color(0xFF1E3A8A)),
                        SizedBox(width: 8),
                        Text(
                          'Registrar Nuevo Cliente',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF334155),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Email Section
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Cuenta Madre (Email)',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF475569)),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _ModeButton(
                                  text: 'Existente',
                                  isSelected: !_isNewEmailMode,
                                  onTap: () => setState(() => _isNewEmailMode = false),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _ModeButton(
                                  text: 'Nueva Cuenta',
                                  isSelected: _isNewEmailMode,
                                  onTap: () => setState(() => _isNewEmailMode = true),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          if (!_isNewEmailMode)
                            DropdownButtonFormField<String>(
                              value: _selectedEmail,
                              isExpanded: true,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                              ),
                              hint: const Text('Selecciona un correo...'),
                              items: existingEmails.map((email) {
                                final count = provider.data.firstWhere((e) => e.email == email).users.length;
                                return DropdownMenuItem(
                                  value: email,
                                  child: Text(
                                    '$email ($count)',
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) => setState(() => _selectedEmail = value),
                              validator: (value) => value == null ? 'Requerido' : null,
                            )
                          else
                            TextFormField(
                              controller: _newEmailController,
                              decoration: const InputDecoration(
                                hintText: 'ejemplo@correo.com',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) => value!.isEmpty ? 'Requerido' : null,
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // User Details
                    const Text(
                      'Nombre del Usuario / Ubicación',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF475569)),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _userNameController,
                      decoration: const InputDecoration(
                        hintText: 'Ej: Casa Finca, Juan Perez...',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value!.isEmpty ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Plan',
                                style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF475569)),
                              ),
                              const SizedBox(height: 8),
                              DropdownButtonFormField<String>(
                                value: _userPlan,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                ),
                                items: const [
                                  DropdownMenuItem(value: 'Ilimitado', child: Text('Ilimitado')),
                                  DropdownMenuItem(value: '50gb', child: Text('50 GB')),
                                ],
                                onChanged: (value) => setState(() => _userPlan = value!),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Días de Pago',
                                style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF475569)),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _userRangeController,
                                decoration: const InputDecoration(
                                  hintText: 'Ej: 1 al 5',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _handleSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        icon: const Icon(LucideIcons.save),
                        label: const Text('Guardar Cliente', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModeButton({
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade100 : Colors.white,
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.blue.shade800 : Colors.grey.shade700,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
