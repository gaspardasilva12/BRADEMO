class Laptop {
  int id;
  String nome;
  int ram; 
  double clockCpu; 

  // Construtor padrão
  Laptop(this.id, this.nome, this.ram, this.clockCpu);

  Laptop.navegacao(this.id, this.nome)
      : ram = 16,
        clockCpu = 3.8;

  Laptop.escritorio(this.id, this.nome)
      : ram = 32,
        clockCpu = 3.2;

  Laptop.programacao(this.id, this.nome)
      : ram = 8,
        clockCpu = 2.5;

  void exibir() {
    print("ID: $id");
    print("Nome: $nome");
    print("RAM: ${ram}GB");
    print("Clock CPU: ${clockCpu}GHz");
  
  }
}
// Exemplo de uso
void main() {
  print("NAMED CONSTRUCTORS");

  print("\n=== Laptop para Navegação na Internet ===");
  var laptopNav = Laptop.navegacao(1, "Notebook para Web");
  laptopNav.exibir();

  print("\n=== Laptop para Uso em Escritório ===");
  var laptopOfice = Laptop.escritorio(2, "Notebook Office");
  laptopOfice.exibir();

  print("\n=== Laptop para Programação ===");
  var laptopDev = Laptop.programacao(3, "Notebook Developer");
  laptopDev.exibir();

  print("\nConfigurações definidas:");
  print("- Navegação: 16GB RAM, 3.8 GHz");
  print("- Escritório: 32GB RAM, 3.2 GHz");
  print("- Programação: 8GB RAM, 2.5 GHz");
}
