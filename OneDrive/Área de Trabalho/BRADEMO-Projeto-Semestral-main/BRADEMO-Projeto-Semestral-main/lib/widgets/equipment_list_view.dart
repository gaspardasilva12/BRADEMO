import 'package:flutter/material.dart';
import '../models/equipment.dart';
import '../screens/details_screen.dart';

class EquipmentListView extends StatelessWidget {
  final List<Equipment> equipments;

  const EquipmentListView({super.key, required this.equipments});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: equipments.length,
      itemBuilder: (context, index) {
        final equipment = equipments[index];
        return ListTile(
          leading: Image.asset(
            equipment.imageUrl,
            width: 50,
            height: 50,
            fit: BoxFit.cover,
          ),
          title: Text(equipment.name),
          subtitle: Text('${equipment.location} - ${equipment.priority}'),
          trailing: Text('${equipment.reports} reports'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ItemDetailScreen(equipment: equipment),
              ),
            );
          },
        );
      },
    );
  }
}
