import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/equipment.dart';
import '../models/login.dart';

class DatabaseService {
  static User? currentUser;

  static Future<List<User>> loadUsers() async {
    final String response = await rootBundle.loadString('assets/data/database.json');
    final data = json.decode(response);
    return (data['users'] as List).map((user) => User.fromJson(user)).toList();
  }

  static Future<List<Equipment>> loadEquipments() async {
    final String response = await rootBundle.loadString('assets/data/database.json');
    final data = json.decode(response);
    return (data['equipments'] as List).map((eq) => Equipment.fromJson(eq)).toList();
  }

  static Future<User?> validateLogin(String prontuario, String senha) async {
    final users = await loadUsers();
    for (final user in users) {
      if (user.prontuario == prontuario && user.senha == senha) {
        currentUser = user;
        return user;
      }
    }
    return null;
  }
}