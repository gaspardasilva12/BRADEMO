import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../models/equipment.dart';
import 'details_screen.dart';

class RequestsScreen extends StatefulWidget {
  const RequestsScreen({super.key});

  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

enum SortOption { dateNewest, dateOldest, priorityHigh, priorityLow, nameAZ, nameZA }

class _RequestsScreenState extends State<RequestsScreen> {
  List<Equipment> _allRequests = [];
  List<Equipment> _filteredRequests = [];
  bool _loading = true;

  // Filtros
  String _selectedPriority = 'Todas';
  String _selectedCampus = 'Todos';
  String _selectedStatus = 'Todos';
  SortOption _sortOption = SortOption.dateNewest;

  final List<String> _priorityOptions = ['Todas', 'Baixa', 'Média', 'Alta', 'Crítica'];
  final List<String> _campusOptions = ['Todos', 'Bragança', 'São Paulo', 'Guarulhos'];
  final List<String> _statusOptions = ['Todos', 'Aberto', 'Em Progresso', 'Concluído', 'Cancelado'];

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    final eqs = await DatabaseService.loadEquipments();
    if (!mounted) return;
    setState(() {
      _allRequests = eqs;
      _applyFiltersAndSort();
      _loading = false;
    });
  }

  void _applyFiltersAndSort() {
    // Aplicar filtros
    _filteredRequests = _allRequests.where((eq) {
      final matchesPriority = _selectedPriority == 'Todas' || eq.priority == _selectedPriority;
      final matchesCampus = _selectedCampus == 'Todos' || eq.campus == _selectedCampus;
      return matchesPriority && matchesCampus;
    }).toList();

    // Aplicar ordenação
    _applySort();
  }

  void _applySort() {
    switch (_sortOption) {
      case SortOption.dateNewest:
        _filteredRequests.sort((a, b) => b.reportDate.compareTo(a.reportDate));
        break;
      case SortOption.dateOldest:
        _filteredRequests.sort((a, b) => a.reportDate.compareTo(b.reportDate));
        break;
      case SortOption.priorityHigh:
        final priorityMap = {'Crítica': 0, 'Alta': 1, 'Média': 2, 'Baixa': 3};
        _filteredRequests.sort((a, b) =>
            (priorityMap[a.priority] ?? 4).compareTo(priorityMap[b.priority] ?? 4));
        break;
      case SortOption.priorityLow:
        final priorityMap = {'Baixa': 0, 'Média': 1, 'Alta': 2, 'Crítica': 3};
        _filteredRequests.sort((a, b) =>
            (priorityMap[a.priority] ?? 4).compareTo(priorityMap[b.priority] ?? 4));
        break;
      case SortOption.nameAZ:
        _filteredRequests.sort((a, b) => a.name.compareTo(b.name));
        break;
      case SortOption.nameZA:
        _filteredRequests.sort((a, b) => b.name.compareTo(a.name));
        break;
    }
  }

  void _updateFilters({
    String? priority,
    String? campus,
    String? status,
    SortOption? sort,
  }) {
    setState(() {
      if (priority != null) _selectedPriority = priority;
      if (campus != null) _selectedCampus = campus;
      if (status != null) _selectedStatus = status;
      if (sort != null) _sortOption = sort;
      _applyFiltersAndSort();
    });
  }

  void _resetFilters() {
    setState(() {
      _selectedPriority = 'Todas';
      _selectedCampus = 'Todos';
      _selectedStatus = 'Todos';
      _sortOption = SortOption.dateNewest;
      _applyFiltersAndSort();
    });
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'crítica':
        return Colors.red;
      case 'alta':
        return Colors.orange;
      case 'média':
        return Colors.blue;
      case 'baixa':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Todas as Solicitações'),
        centerTitle: true,
        elevation: 0,
        actions: [
          // Botão de reset de filtros
          if (_selectedPriority != 'Todas' ||
              _selectedCampus != 'Todos' ||
              _selectedStatus != 'Todos')
            Tooltip(
              message: 'Limpar filtros',
              child: IconButton(
                icon: const Icon(Icons.clear_all),
                onPressed: _resetFilters,
              ),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Seção de Filtros e Ordenação
                _buildFilterSection(theme),

                // Contador de Solicitações e Estatísticas
                _buildStatsBar(theme),

                // Lista de Solicitações
                Expanded(
                  child: _filteredRequests.isEmpty
                      ? _buildEmptyState(theme)
                      : _buildRequestsList(theme),
                ),
              ],
            ),
    );
  }

  Widget _buildFilterSection(ThemeData theme) {
    return Container(
      color: theme.colorScheme.surface,
      padding: const EdgeInsets.all(12),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1: Filtros Horizontais
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  // Filtro de Prioridade
                  _buildFilterDropdown(
                    label: 'Prioridade',
                    value: _selectedPriority,
                    items: _priorityOptions,
                    onChanged: (value) =>
                        _updateFilters(priority: value),
                    icon: Icons.flag,
                  ),
                  const SizedBox(width: 8),

                  // Filtro de Campus
                  _buildFilterDropdown(
                    label: 'Campus',
                    value: _selectedCampus,
                    items: _campusOptions,
                    onChanged: (value) => _updateFilters(campus: value),
                    icon: Icons.location_on,
                  ),
                  const SizedBox(width: 8),

                  // Filtro de Status
                  _buildFilterDropdown(
                    label: 'Status',
                    value: _selectedStatus,
                    items: _statusOptions,
                    onChanged: (value) => _updateFilters(status: value),
                    icon: Icons.assignment_turned_in,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Row 2: Ordenação
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Icon(Icons.sort, size: 18, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  DropdownButton<SortOption>(
                    value: _sortOption,
                    items: [
                      DropdownMenuItem(
                        value: SortOption.dateNewest,
                        child: const Text('Data (Recentes)'),
                      ),
                      DropdownMenuItem(
                        value: SortOption.dateOldest,
                        child: const Text('Data (Antigas)'),
                      ),
                      DropdownMenuItem(
                        value: SortOption.priorityHigh,
                        child: const Text('Prioridade (Alta)'),
                      ),
                      DropdownMenuItem(
                        value: SortOption.priorityLow,
                        child: const Text('Prioridade (Baixa)'),
                      ),
                      DropdownMenuItem(
                        value: SortOption.nameAZ,
                        child: const Text('Nome (A-Z)'),
                      ),
                      DropdownMenuItem(
                        value: SortOption.nameZA,
                        child: const Text('Nome (Z-A)'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        _updateFilters(sort: value);
                      }
                    },
                    underline: Container(
                      height: 2,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterDropdown({
    required String label,
    required String value,
    required List<String> items,
    required Function(String) onChanged,
    required IconData icon,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          DropdownButton<String>(
            value: value,
            items: items.map((item) {
              return DropdownMenuItem(
                value: item,
                child: Text(item, style: const TextStyle(fontSize: 13)),
              );
            }).toList(),
            onChanged: (newValue) {
              if (newValue != null) onChanged(newValue);
            },
            underline: Container(),
            isDense: true,
          ),
        ],
      ),
    );
  }

  Widget _buildStatsBar(ThemeData theme) {
    final totalRequests = _allRequests.length;
    final criticalCount =
        _filteredRequests.where((r) => r.priority == 'Crítica').length;
    final highCount = _filteredRequests.where((r) => r.priority == 'Alta').length;

    return Container(
      color: theme.colorScheme.primary.withValues(alpha: 0.05),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total de Solicitações',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              Text(
                '${_filteredRequests.length} / $totalRequests',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          if (criticalCount > 0 || highCount > 0)
            Row(
              children: [
                if (criticalCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red, width: 0.5),
                    ),
                    child: Text(
                      'Crítica: $criticalCount',
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                if (highCount > 0) const SizedBox(width: 8),
                if (highCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange, width: 0.5),
                    ),
                    child: Text(
                      'Alta: $highCount',
                      style: const TextStyle(
                        color: Colors.orange,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhuma solicitação encontrada',
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tente ajustar seus filtros',
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _resetFilters,
            icon: const Icon(Icons.refresh),
            label: const Text('Limpar Filtros'),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestsList(ThemeData theme) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: _filteredRequests.length,
      itemBuilder: (context, index) {
        final request = _filteredRequests[index];
        return _buildRequestCard(context, request, theme);
      },
    );
  }

  Widget _buildRequestCard(
      BuildContext context, Equipment request, ThemeData theme) {
    final priorityColor = _getPriorityColor(request.priority);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ItemDetailScreen(equipment: request),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Imagem, Título e Prioridade
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Imagem
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      request.imageUrl,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Informações principais
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                request.name,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          request.location,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Campus: ${request.campus}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.grey[500],
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Badge de Prioridade
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: priorityColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: priorityColor, width: 0.5),
                          ),
                          child: Text(
                            request.priority,
                            style: TextStyle(
                              color: priorityColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Ícone de ação
                  Icon(
                    Icons.chevron_right,
                    color: Colors.grey[400],
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Detalhes adicionais
              Row(
                children: [
                  Expanded(
                    child: _buildDetailBadge(
                      icon: Icons.report,
                      label: 'Relatórios',
                      value: '${request.reports}',
                      theme: theme,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildDetailBadge(
                      icon: Icons.calendar_today,
                      label: 'Data',
                      value: request.formattedReportDate,
                      theme: theme,
                    ),
                  ),
                ],
              ),

              if (request.details.isNotEmpty) ...[
                const SizedBox(height: 8),
                // Descrição
                Text(
                  request.details,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey[700],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailBadge({
    required IconData icon,
    required String label,
    required String value,
    required ThemeData theme,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: theme.colorScheme.primary),
          const SizedBox(width: 4),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  value,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
