"""
Exemplo de uso do Sistema de Inspeção Automatizada de Campos Cirúrgicos

Este exemplo demonstra como usar todos os módulos do sistema para
inspecionar um campo cirúrgico completo.
"""

import sys
import time
from pathlib import Path

# Adiciona o diretório src ao path
sys.path.insert(0, str(Path(__file__).parent.parent / "src"))

from projeto_cremer_inspecao.modules import (
    Esteira,
    Produto,
    CameraInspecao,
    Inversor,
    DirecaoInversao,
    Classificador
)


def exemplo_inspecao_completa():
    """Exemplo completo de inspeção de um campo cirúrgico"""
    
    print("=" * 60)
    print("Sistema de Inspeção Automatizada - Exemplo de Uso")
    print("=" * 60)
    print()
    
    # 1. Inicialização dos componentes
    print("1. Inicializando componentes...")
    print("-" * 60)
    
    # Esteiras
    esteira_superior = Esteira("superior", velocidade=1.0, comprimento=10.0)
    esteira_inferior = Esteira("inferior", velocidade=1.0, comprimento=10.0)
    
    # Câmeras
    camera_superior = CameraInspecao("CAM001", posicao="superior", resolucao=(1920, 1080))
    camera_inferior = CameraInspecao("CAM002", posicao="inferior", resolucao=(1920, 1080))
    
    # Inversor
    inversor = Inversor("INV001", tempo_inversao=2.0)
    
    # Classificador
    classificador = Classificador("CLASS001")
    
    print("Componentes criados com sucesso!")
    print()
    
    # 2. Conexão e calibração
    print("2. Conectando e calibrando componentes...")
    print("-" * 60)
    
    esteira_superior.iniciar()
    esteira_inferior.iniciar()
    
    camera_superior.conectar()
    camera_superior.calibrar()
    
    camera_inferior.conectar()
    camera_inferior.calibrar()
    
    inversor.conectar()
    inversor.calibrar()
    
    print("Componentes conectados e calibrados!")
    print()
    
    # 3. Criação de produto
    print("3. Criando produto para inspeção...")
    print("-" * 60)
    
    produto = Produto(
        id="PROD001",
        lado_atual="superior"
    )
    
    esteira_superior.adicionar_produto(produto, posicao=0.0)
    print(f"Produto {produto.id} criado e adicionado à esteira superior")
    print()
    
    # 4. Inspeção do primeiro lado (lado superior)
    print("4. Inspecionando primeiro lado (lado superior)...")
    print("-" * 60)
    
    # Simula movimento do produto até a posição da câmera
    print("Movendo produto até a posição de inspeção...")
    esteira_superior.atualizar_posicoes(2.0)  # Simula 2 segundos de movimento
    
    # Captura imagem
    resultado_inspecao_1 = camera_superior.capturar_imagem(produto.id)
    
    if resultado_inspecao_1:
        print(f"Imagem capturada: {resultado_inspecao_1.imagem_path}")
        print(f"Qualidade: {resultado_inspecao_1.qualidade:.2%}")
        print(f"Defeitos detectados: {len(resultado_inspecao_1.defeitos_detectados)}")
        
        # Detecta defeitos
        resultado_inspecao_1 = camera_superior.detectar_defeitos(resultado_inspecao_1)
        
        # Armazena resultado no produto
        produto.lado_inspecionado_1 = {
            "qualidade": resultado_inspecao_1.qualidade,
            "defeitos_detectados": resultado_inspecao_1.defeitos_detectados,
            "metadados": resultado_inspecao_1.metadados
        }
    else:
        print("Erro ao capturar imagem do primeiro lado")
        return
    
    print()
    
    # 5. Inversão do produto
    print("5. Invertendo produto...")
    print("-" * 60)
    
    # Move produto até o final da esteira superior
    esteira_superior.atualizar_posicoes(5.0)  # Simula movimento até o fim
    
    # Remove da esteira superior
    produto_removido = esteira_superior.remover_produto(produto.id)
    
    # Inverte o produto
    resultado_inversao = inversor.inverter_produto(
        produto.id,
        DirecaoInversao.SUPERIOR_PARA_INFERIOR
    )
    
    if resultado_inversao.sucesso:
        print(f"Inversão concluída em {resultado_inversao.tempo_inversao:.2f}s")
        
        # Adiciona à esteira inferior
        produto.lado_atual = "inferior"
        esteira_inferior.adicionar_produto(produto, posicao=0.0)
    else:
        print(f"Erro na inversão: {resultado_inversao.erro}")
        return
    
    print()
    
    # 6. Inspeção do segundo lado (lado inferior)
    print("6. Inspecionando segundo lado (lado inferior)...")
    print("-" * 60)
    
    # Move produto até a posição da câmera
    print("Movendo produto até a posição de inspeção...")
    esteira_inferior.atualizar_posicoes(2.0)  # Simula 2 segundos de movimento
    
    # Captura imagem
    resultado_inspecao_2 = camera_inferior.capturar_imagem(produto.id)
    
    if resultado_inspecao_2:
        print(f"Imagem capturada: {resultado_inspecao_2.imagem_path}")
        print(f"Qualidade: {resultado_inspecao_2.qualidade:.2%}")
        print(f"Defeitos detectados: {len(resultado_inspecao_2.defeitos_detectados)}")
        
        # Detecta defeitos
        resultado_inspecao_2 = camera_inferior.detectar_defeitos(resultado_inspecao_2)
        
        # Armazena resultado no produto
        produto.lado_inspecionado_2 = {
            "qualidade": resultado_inspecao_2.qualidade,
            "defeitos_detectados": resultado_inspecao_2.defeitos_detectados,
            "metadados": resultado_inspecao_2.metadados
        }
    else:
        print("Erro ao capturar imagem do segundo lado")
        return
    
    print()
    
    # 7. Classificação do produto
    print("7. Classificando produto...")
    print("-" * 60)
    
    resultado_classificacao = classificador.classificar_produto(
        produto_id=produto.id,
        inspecao_lado_1=produto.lado_inspecionado_1,
        inspecao_lado_2=produto.lado_inspecionado_2
    )
    
    produto.classificacao = resultado_classificacao.classificacao.value
    
    print(f"Classificação: {resultado_classificacao.classificacao.value.upper()}")
    print(f"Confiança: {resultado_classificacao.confianca:.2%}")
    print(f"Motivo: {resultado_classificacao.motivo}")
    
    if resultado_classificacao.recomendacoes:
        print("Recomendações:")
        for recomendacao in resultado_classificacao.recomendacoes:
            print(f"  - {recomendacao}")
    
    print()
    print("Critérios avaliados:")
    for criterio, valor in resultado_classificacao.criterios_avaliados.items():
        if isinstance(valor, float):
            print(f"  - {criterio}: {valor:.2%}")
        else:
            print(f"  - {criterio}: {valor}")
    
    print()
    
    # 8. Estatísticas
    print("8. Estatísticas do sistema...")
    print("-" * 60)
    
    stats = classificador.obter_estatisticas()
    print(f"Total de produtos classificados: {stats['total_classificados']}")
    print(f"Aprovados: {stats['aprovados']} ({stats['percentuais'].get('aprovados', 0):.1f}%)")
    print(f"Reprocessar: {stats['reprocessar']} ({stats['percentuais'].get('reprocessar', 0):.1f}%)")
    print(f"Segregados: {stats['segregados']} ({stats['percentuais'].get('segregados', 0):.1f}%)")
    
    print()
    print("=" * 60)
    print("Inspeção concluída com sucesso!")
    print("=" * 60)


def exemplo_multiplos_produtos():
    """Exemplo de processamento de múltiplos produtos"""
    
    print("\n" + "=" * 60)
    print("Exemplo: Processamento de Múltiplos Produtos")
    print("=" * 60)
    print()
    
    # Inicialização (similar ao exemplo anterior)
    esteira_superior = Esteira("superior")
    esteira_inferior = Esteira("inferior")
    camera_superior = CameraInspecao("CAM001", "superior")
    camera_inferior = CameraInspecao("CAM002", "inferior")
    inversor = Inversor("INV001")
    classificador = Classificador("CLASS001")
    
    # Conexão
    esteira_superior.iniciar()
    esteira_inferior.iniciar()
    camera_superior.conectar()
    camera_superior.calibrar()
    camera_inferior.conectar()
    camera_inferior.calibrar()
    inversor.conectar()
    inversor.calibrar()
    
    # Processa múltiplos produtos
    produtos_ids = ["PROD001", "PROD002", "PROD003"]
    
    for produto_id in produtos_ids:
        print(f"\nProcessando {produto_id}...")
        print("-" * 60)
        
        produto = Produto(id=produto_id, lado_atual="superior")
        esteira_superior.adicionar_produto(produto)
        
        # Inspeção lado 1
        resultado_1 = camera_superior.capturar_imagem(produto_id)
        if resultado_1:
            resultado_1 = camera_superior.detectar_defeitos(resultado_1)
            produto.lado_inspecionado_1 = {
                "qualidade": resultado_1.qualidade,
                "defeitos_detectados": resultado_1.defeitos_detectados
            }
        
        # Inversão
        esteira_superior.remover_produto(produto_id)
        inversor.inverter_produto(produto_id, DirecaoInversao.SUPERIOR_PARA_INFERIOR)
        produto.lado_atual = "inferior"
        esteira_inferior.adicionar_produto(produto)
        
        # Inspeção lado 2
        resultado_2 = camera_inferior.capturar_imagem(produto_id)
        if resultado_2:
            resultado_2 = camera_inferior.detectar_defeitos(resultado_2)
            produto.lado_inspecionado_2 = {
                "qualidade": resultado_2.qualidade,
                "defeitos_detectados": resultado_2.defeitos_detectados
            }
        
        # Classificação
        classificacao = classificador.classificar_produto(
            produto_id,
            produto.lado_inspecionado_1,
            produto.lado_inspecionado_2
        )
        
        print(f"  Classificação: {classificacao.classificacao.value}")
        print(f"  Confiança: {classificacao.confianca:.2%}")
        
        # Remove da esteira inferior
        esteira_inferior.remover_produto(produto_id)
    
    # Estatísticas finais
    print("\n" + "=" * 60)
    print("Estatísticas Finais:")
    print("=" * 60)
    stats = classificador.obter_estatisticas()
    for key, value in stats.items():
        if key != "percentuais":
            print(f"{key}: {value}")
        else:
            print("Percentuais:")
            for pkey, pvalue in value.items():
                print(f"  {pkey}: {pvalue:.1f}%")


if __name__ == "__main__":
    # Executa exemplo de inspeção completa
    exemplo_inspecao_completa()
    
    # Executa exemplo de múltiplos produtos
    exemplo_multiplos_produtos()

