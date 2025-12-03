import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:country_picker/country_picker.dart';
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
  final _phoneController = TextEditingController();
  final _antennaSerialController = TextEditingController();
  
  String _userPlan = 'Ilimitado';
  String _selectedCountry = 'Venezuela';
  Country? _countryObject;
  
  int _paymentStartDay = 1;
  int _paymentEndDay = 5;

  @override
  void initState() {
    super.initState();
    _countryObject = Country.parse('VE'); // Default to Venezuela
  }

  @override
  void dispose() {
    _newEmailController.dispose();
    _userNameController.dispose();
    _phoneController.dispose();
    _antennaSerialController.dispose();
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
        country: _selectedCountry,
        phoneNumber: _phoneController.text,
        antennaSerial: _antennaSerialController.text,
        paymentStartDay: _paymentStartDay,
        paymentEndDay: _paymentEndDay,
        isNewEmail: _isNewEmailMode,
      );

      // Reset form
      _userNameController.clear();
      _phoneController.clear();
      _antennaSerialController.clear();
      setState(() {
        _paymentStartDay = 1;
        _paymentEndDay = 5;
      });
      
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

                    // 1. Name
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
                        prefixIcon: Icon(LucideIcons.user),
                      ),
                      validator: (value) => value!.isEmpty ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 16),

                    // 2. Phone
                    const Text(
                      'Teléfono',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF475569)),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        hintText: '+58...',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(LucideIcons.phone),
                      ),
                      validator: (value) => value!.isEmpty ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 16),

                    // 3. Antenna Serial
                    const Text(
                      'Serial de la Antena',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF475569)),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _antennaSerialController,
                      decoration: const InputDecoration(
                        hintText: 'Ej: KIT123456789',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(LucideIcons.router),
                      ),
                      validator: (value) => value!.isEmpty ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 16),

                    // 4. Country
                    const Text(
                      'País',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF475569)),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () {
                        showCountryPicker(
                          context: context,
                          showPhoneCode: false,
                          onSelect: (Country country) {
                            setState(() {
                              _selectedCountry = country.name;
                              _countryObject = country;
                            });
                          },
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            if (_countryObject != null) ...[
                              Text(_countryObject!.flagEmoji, style: const TextStyle(fontSize: 20)),
                              const SizedBox(width: 8),
                            ],
                            Expanded(
                              child: Text(
                                _selectedCountry,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const Icon(Icons.arrow_drop_down),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 5. Plan
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
                    const SizedBox(height: 16),

                    // 6. Payment Day
                    const Text(
                      'Días de Pago (Inicio - Fin)',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF475569)),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            value: _paymentStartDay,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 8),
                            ),
                            items: List.generate(31, (index) => index + 1).map((day) {
                              return DropdownMenuItem(value: day, child: Text(day.toString()));
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _paymentStartDay = value!;
                                if (_paymentEndDay < _paymentStartDay) {
                                  _paymentEndDay = _paymentStartDay;
                                }
                              });
                            },
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Text('al'),
                        ),
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            value: _paymentEndDay,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 8),
                            ),
                            items: List.generate(31, (index) => index + 1).map((day) {
                              return DropdownMenuItem(value: day, child: Text(day.toString()));
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                if (value! >= _paymentStartDay) {
                                  _paymentEndDay = value;
                                }
                              });
                            },
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
