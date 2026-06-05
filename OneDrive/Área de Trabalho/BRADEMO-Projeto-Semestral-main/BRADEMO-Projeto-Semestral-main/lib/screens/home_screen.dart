import 'package:flutter/material.dart';
import '../models/equipment.dart';
import '../widgets/equipment_card.dart';
import '../services/database_service.dart';
import 'details_screen.dart';
import 'requests_screen.dart';
import 'profile_screen.dart';

/// Tela inicial: cadastro de equipamentos defeituosos nas salas do IF.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 2; // Home é o índice padrão

  List<Equipment> _equipments = [];

  @override
  void initState() {
    super.initState();
    _loadEquipments();
  }

  Future<void> _loadEquipments() async {
    final equipments = await DatabaseService.loadEquipments();
    setState(() {
      _equipments = equipments;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    if (_equipments.isEmpty) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final featuredEquipment = _equipments[0];
    final otherEquipments = _equipments.sublist(1);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: null,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: () {},
                icon: const Icon(Icons.search, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding = constraints.maxWidth > 900 ? 40.0 : 20.0;
            final featuredHeight = constraints.maxWidth > 900 ? 280.0 : 220.0;
            final otherHeight = constraints.maxWidth > 900 ? 220.0 : 160.0;
            final cardSpacing = constraints.maxWidth > 900 ? 16.0 : 12.0;

            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 12, 0, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bem-vindo!',
                            style: textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Cadastre aqui os equipamentos com defeitos',
                            style: textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Projetor Quebrado - Card grande
                    Padding(
                      padding: EdgeInsets.zero,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            featuredEquipment.name,
                            style: textTheme.labelMedium?.copyWith(
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          EquipmentCard(
                            imageUrl: featuredEquipment.imageUrl,
                            title: featuredEquipment.name,
                            height: featuredHeight,
                            fontSize: 18,
                            textPadding: EdgeInsets.only(bottom: 16, left: 16),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ItemDetailScreen(
                                    equipment: featuredEquipment,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Dois cards lado a lado ou empilhados
                    Padding(
                      padding: EdgeInsets.zero,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Outros Equipamentos',
                            style: textTheme.labelMedium?.copyWith(
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: EquipmentCard(
                                  imageUrl: otherEquipments[0].imageUrl,
                                  title: otherEquipments[0].name,
                                  height: otherHeight,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ItemDetailScreen(
                                          equipment: otherEquipments[0],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              SizedBox(width: cardSpacing),
                              Expanded(
                                child: EquipmentCard(
                                  imageUrl: otherEquipments[1].imageUrl,
                                  title: otherEquipments[1].name,
                                  height: otherHeight,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ItemDetailScreen(
                                          equipment: otherEquipments[1],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          // navigate for Perfil (4) and Solicitações (3)
          if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const RequestsScreen()),
            );
            return;
          }
          if (index == 4) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            );
            return;
          }
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: theme.colorScheme.primary,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.error_outline),
            label: 'Reportar Defeito',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: 'Cadastrar',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Solicitações',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Ação para adicionar equipamento
        },
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}
