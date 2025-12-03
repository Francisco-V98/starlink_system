import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
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
    final totalUsers = data.fold<int>(0, (sum, group) => sum + group.users.length);

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
            border: Border(
              bottom: BorderSide(color: Colors.grey.shade200),
            ),
          ),
          child: Row(
            children: [
              OutlinedButton.icon(
                onPressed: () => _toggleAll(data),
                icon: Icon(
                  _allExpanded ? LucideIcons.chevronsUp : LucideIcons.chevronsDown,
                  size: 16,
                ),
                label: Text(_allExpanded ? 'Colapsar todo' : 'Expandir todo'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  textStyle: const TextStyle(fontSize: 13),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.mail, size: 14, color: Colors.blue.shade700),
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
                    Icon(LucideIcons.users, size: 14, color: Colors.blue.shade700),
                    const SizedBox(width: 4),
                    Text(
                      '$totalUsers',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // List
        Expanded(
          child: provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : data.isEmpty
                  ? const Center(child: Text('No se encontraron resultados'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        final group = data[index];
                        final isExpanded = _expandedGroups[group.email] ?? false;
                        return _ClientGroupCard(
                          group: group,
                          isExpanded: isExpanded,
                          onToggle: () => _toggleGroup(group.email),
                        );
                      },
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
                        isExpanded ? LucideIcons.chevronUp : LucideIcons.chevronDown,
                        size: 20,
                        color: Colors.grey.shade600,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                        const Icon(LucideIcons.users, color: Colors.white, size: 16),
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
                return _UserListTile(
                  email: group.email,
                  user: user,
                );
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

  const _UserListTile({
    required this.email,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UserDetailScreen(
              email: email,
              user: user,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade100),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: user.plan == 'Ilimitado' ? Colors.purple.shade50 : Colors.teal.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          user.plan,
                          style: TextStyle(
                            color: user.plan == 'Ilimitado' ? Colors.purple : Colors.teal,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(LucideIcons.calendar, size: 12, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(
                        user.range,
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                  if (user.note != null && user.note!.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
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
            const Icon(LucideIcons.chevronRight, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }
}
