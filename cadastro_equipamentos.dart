void cadastrarEquipamentos() {
  var nomeEquipamento = "Impressora 3D";
  String local = "Lab de Protótipos";
  dynamic patrimonio = 12345;

  print("=== CADASTRO DE EQUIPAMENTOS - IFSP ===\n");

  print("Nome do Equipamento: $nomeEquipamento");
  print("Local: $local");
  print("Número de Patrimônio (inicial): $patrimonio");

  print("\n--- Tipos Iniciais ---");
  // Verificando os tipos das variáveis
  print("nomeEquipamento é String? ${nomeEquipamento is String}");
  print("nomeEquipamento é int? ${nomeEquipamento is int}");
  // Verificando os tipos de 'local' e 'patrimonio'
  print("local é String? ${local is String}");
  print("patrimonio é int? ${patrimonio is int}");
  print("patrimonio é String? ${patrimonio is String}");

  patrimonio = "12345-A";

  print("\n--- Após Alterar o Patrimônio ---");
  print("Número de Patrimônio (novo): $patrimonio");

  print("\n--- Tipos Após a Mudança ---");
  print("patrimonio é int? ${patrimonio is int}");
  print("patrimonio é String? ${patrimonio is String}");

  print("\n--- EXPLICAÇÃO ---");

  print("\nPor que Dart permite mudar o tipo de 'patrimonio', mas não de 'local'?");
  print("\nO Patrimonio foi declarado como 'dynamic', que é um tipo especial em Dart",
  );
  print(
    "que permite aceitar qualquer tipo de valor. O tipo pode ser mudado em",
  );
  print("tempo de execução sem problemas.");

  print("\nO local foi declarado como 'String', um tipo específico. Uma vez");
  print("declarado como String, só pode armazenar valores do tipo String.");
  print("Tentar atribuir outro tipo resultaria em erro de compilação.");

  print("\nPor que 'var' aparenta flexibilidade mas não a tem?");
  print("\nVar é declarado na primeira atribuição. Como 'nomeEquipamento' foi");
  print("atribuído a 'Impressora 3D' (String), seu tipo é fixado como String");
  print("e não pode ser mudado, similar a uma declaração 'String'.");
}
