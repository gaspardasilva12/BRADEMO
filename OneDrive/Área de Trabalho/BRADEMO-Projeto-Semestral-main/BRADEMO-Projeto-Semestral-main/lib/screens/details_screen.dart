import 'package:flutter/material.dart';
import '../models/equipment.dart';

class ItemDetailScreen extends StatefulWidget {
  final Equipment equipment;

  const ItemDetailScreen({super.key, required this.equipment});

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  bool isUrgent = false;
  int _activeTabIndex =
      0; // 0: Aba Detalhes, 1: Aba Localização, 2: Aba Histórico

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 900;
          final imageHeight = isWide ? 420.0 : 350.0;
          final horizontalPadding = isWide ? 40.0 : 25.0;
          final contentPadding = EdgeInsets.symmetric(
            horizontal: horizontalPadding,
          );

          if (!isWide) {
            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              height: imageHeight,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(45),
                                  bottomRight: Radius.circular(45),
                                ),
                                image: DecorationImage(
                                  image: AssetImage(widget.equipment.imageUrl),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 30,
                              right: 20,
                              child: CircleAvatar(
                                backgroundColor: Colors.white,
                                child: IconButton(
                                  icon: Icon(
                                    isUrgent
                                        ? Icons.warning
                                        : Icons.warning_amber_rounded,
                                    color: isUrgent ? Colors.red : Colors.grey,
                                  ),
                                  onPressed: () =>
                                      setState(() => isUrgent = !isUrgent),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 30,
                              left: 20,
                              child: CircleAvatar(
                                backgroundColor: Colors.white,
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.arrow_back,
                                    color: Colors.black,
                                  ),
                                  onPressed: () => Navigator.pop(context),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: -70,
                              left: 20,
                              right: 20,
                              child: _buildInfoCard(context),
                            ),
                          ],
                        ),

                        SizedBox(height: 90),
                        Padding(
                          padding: contentPadding,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildTabItem(context, "Detalhes", 0),
                              _buildTabItem(context, "Localização", 1),
                              _buildTabItem(context, "Histórico", 2),
                            ],
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.all(25.0),
                          child: _buildActiveTabContent(context),
                        ),
                      ],
                    ),
                  ),
                ),

                _buildActionButton(context),
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 5,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            height: imageHeight,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(45),
                                bottomRight: Radius.circular(45),
                              ),
                              image: DecorationImage(
                                image: AssetImage(widget.equipment.imageUrl),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 30,
                            right: 20,
                            child: CircleAvatar(
                              backgroundColor: Colors.white,
                              child: IconButton(
                                icon: Icon(
                                  isUrgent
                                      ? Icons.warning
                                      : Icons.warning_amber_rounded,
                                  color: isUrgent ? Colors.red : Colors.grey,
                                ),
                                onPressed: () =>
                                    setState(() => isUrgent = !isUrgent),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 30,
                            left: 20,
                            child: CircleAvatar(
                              backgroundColor: Colors.white,
                              child: IconButton(
                                icon: const Icon(
                                  Icons.arrow_back,
                                  color: Colors.black,
                                ),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: -70,
                            left: 20,
                            right: 20,
                            child: _buildInfoCard(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 5,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: 30,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildTabItem(context, "Detalhes", 0),
                          _buildTabItem(context, "Localização", 1),
                          _buildTabItem(context, "Histórico", 2),
                        ],
                      ),
                      const SizedBox(height: 25),
                      Expanded(child: _buildActiveTabContent(context)),
                      _buildActionButton(context),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildActiveTabContent(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    switch (_activeTabIndex) {
      case 1:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Localização',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.red),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.equipment.location,
                    style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Reportado em ${widget.equipment.formattedReportDate}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Prioridade ${widget.equipment.priority}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: widget.equipment.priority.toLowerCase() == 'alta'
                    ? Colors.red
                    : widget.equipment.priority.toLowerCase() == 'média'
                    ? Colors.orange
                    : Colors.green,
              ),
            ),
          ],
        );
      case 2:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Histórico',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            _buildHistoryItem(
              context,
              '${widget.equipment.formattedReportDate} - Reporte criado.',
              true,
            ),
            _buildHistoryItem(
              context,
              '${widget.equipment.reports} reportes registrados.',
              false,
            ),
            _buildHistoryItem(
              context,
              'Aguardando análise da equipe de TI.',
              false,
            ),
          ],
        );
      default:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                style: TextStyle(
                  color: Colors.grey[800],
                  fontSize: 16,
                  height: 1.6,
                ),
                children: [TextSpan(text: widget.equipment.details)],
              ),
            ),
            const SizedBox(height: 20),
            _buildStatusInfoBox(context),
          ],
        );
    }
  }

  Widget _buildHistoryItem(BuildContext context, String text, bool isFirst) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            color: isFirst ? primaryColor : Colors.grey,
            size: 20,
          ),
          SizedBox(width: 10),
          Text(text, style: TextStyle(color: Colors.grey[700])),
        ],
      ),
    );
  }

  Widget _buildStatusInfoBox(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: theme.colorScheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'O reparo já está agendado pela equipe de TI.',
              style: TextStyle(color: theme.colorScheme.primary, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 8,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.equipment.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              widget.equipment.location,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 12),
            Text(
              'Reportado em ${widget.equipment.formattedReportDate}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.report_problem,
                  color: widget.equipment.priority.toLowerCase() == 'alta'
                      ? Colors.red
                      : widget.equipment.priority.toLowerCase() == 'média'
                      ? Colors.orange
                      : theme.colorScheme.secondary,
                  size: 20,
                ),
                const SizedBox(width: 6),
                Text(
                  'Prioridade ${widget.equipment.priority.toLowerCase()}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: widget.equipment.priority.toLowerCase() == 'alta'
                        ? Colors.red
                        : widget.equipment.priority.toLowerCase() == 'média'
                        ? Colors.orange
                        : theme.colorScheme.secondary,
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.people_alt_outlined,
                  color: Colors.grey,
                  size: 18,
                ),
                const SizedBox(width: 4),
                Text(
                  '${widget.equipment.reports} reportes',
                  style: TextStyle(color: Colors.grey[700], fontSize: 13),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem(BuildContext context, String title, int index) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    bool active = _activeTabIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _activeTabIndex = index),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: active ? FontWeight.bold : FontWeight.w500,
              color: active ? primaryColor : Colors.grey[400],
            ),
          ),
          if (active)
            Container(
              margin: EdgeInsets.only(top: 8),
              height: 3,
              width: 30,
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(25, 0, 25, 30),
      child: SizedBox(
        width: double.infinity,
        height: 60,
        child: ElevatedButton(
          onPressed: () => _showSoonDialog(context),
          child: const Text(
            'Acompanhar Chamado',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  void _showSoonDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Notificação"),
        content: Text("Você receberá atualizações sobre este chamado."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Entendido"),
          ),
        ],
      ),
    );
  }
}
