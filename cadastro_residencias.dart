import 'dart:io';

class House {
  int id;
  String name;
  double price;

  House(this.id, this.name, this.price);

  @override
  String toString() {
    return "ID: $id | Nome: $name | Preço: R\$ ${price.toStringAsFixed(2)}";
  }
}

void main() {
  List<House> houses = [];

  print("=== CADASTRO DE RESIDÊNCIAS - PORTAL DE VENDAS ===\n");

  // Cadastrar 3 casas
  for (int i = 1; i <= 3; i++) {
    print("== Cadastro da Casa $i ==");

    stdout.write("Digite o ID da casa: ");
    int id = int.parse(stdin.readLineSync()!);

    stdout.write("Digite o nome da casa: ");
    String name = stdin.readLineSync()!;

    stdout.write("Digite o preço da casa (R\$): ");
    double price = double.parse(stdin.readLineSync()!);

    houses.add(House(id, name, price));
    print("");
  }
// Exibir as casas cadastradas
  print("=== Casas Cadastradas ===\n");
  for (House house in houses) {
    house..name = "${house.name} (Cadastrada)";
  }
  
  for (House house in houses) {
    print(house);
  }
}
