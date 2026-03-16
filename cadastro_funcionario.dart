void cadastrarFuncionario({required String nome, String? cargo}) {
  if (cargo != null) {
    print("\nBem-vindo, $nome! Você é um(a) $cargo.");
  } else {
    print("\nBem-vindo, $nome!\n");
  }
}

// Exemplo de uso
void main() {

  cadastrarFuncionario(nome: "Ana", cargo: "Analista");
  
  cadastrarFuncionario(nome: "Carlos");

  cadastrarFuncionario(nome: "Maria", cargo: "Gerente");

  cadastrarFuncionario(nome: "João");
}
