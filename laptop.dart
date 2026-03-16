class Laptop {
  int id;
  String nome;
  String ram;
  String clockCpu;

  Laptop({
    required this.id,
    required this.nome,
    required this.ram,
    required this.clockCpu,
  });

  void imprimirDetalhes() {
    print("ID: $id");
    print("Nome: $nome");
    print("RAM: $ram");
    print("Clock CPU: $clockCpu");
    print("---");
  }
}

void main() {

  Laptop laptop1 = Laptop(
    id: 1,
    nome: "Acer Aspire 5",
    ram: "16GB",
    clockCpu: "3.8 GHz",
  );

  Laptop laptop2 = Laptop(
    id: 2,
    nome: "MacBook Pro",
    ram: "32GB",
    clockCpu: "3.2 GHz",
  );

  Laptop laptop3 = Laptop(
    id: 3,
    nome: "Lenovo ThinkPad",
    ram: "8GB",
    clockCpu: "2.5 GHz",
  );

  // Imprimir os detalhes de todos os laptops
  print("=== DETALHES DOS LAPTOPS ===\n");
  
  print("Laptop 1:");
  laptop1.imprimirDetalhes();
  
  print("Laptop 2:");
  laptop2.imprimirDetalhes();
  
  print("Laptop 3:");
  laptop3.imprimirDetalhes();
}
