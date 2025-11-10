import sys
from pathlib import Path
import requests
import time
from datetime import datetime, timedelta
import random

# Adicionar o diretório src ao caminho
sys.path.insert(0, str(Path(__file__).parent / "src"))

API_BASE_URL = "http://localhost:8000"

def create_product(product_id=None, lado_atual="superior", status="pendente"):
    """Cria um produto. Se product_id não for fornecido, será gerado automaticamente."""
    data = {
        "lado_atual": lado_atual,
        "status": status
    }
    
    # Só adiciona o ID se foi fornecido
    if product_id:
        data["id"] = product_id
    
    response = requests.post(
        f"{API_BASE_URL}/produtos/",
        json=data
    )
    if response.status_code == 201:
        produto_criado = response.json()
        id_real = produto_criado.get("id", product_id or "automático")
        print(f"✅ Produto {id_real} criado")
        return id_real
    elif response.status_code == 400:
        print(f"⚠️ Produto {product_id or 'automático'} já existe ou erro na criação")
        # Se o produto já existe, tenta criar sem ID para obter o próximo disponível
        if product_id:
            print("   → Tentando criar sem ID para obter próximo ID disponível...")
            response2 = requests.post(f"{API_BASE_URL}/produtos/", json={"lado_atual": lado_atual, "status": status})
            if response2.status_code == 201:
                produto_criado = response2.json()
                id_real = produto_criado.get("id", "automático")
                print(f"✅ Produto criado com novo ID {id_real}")
                return id_real
            else:
                print(f"❌ Falha ao criar produto sem ID: {response2.status_code} {response2.text}")
                return None
        return None
    else:
        print(f"❌ Erro ao criar produto {product_id or 'automático'}: {response.text}")
        return None

def create_inspection(produto_id, lado, qualidade, camera_id=None):
    """Cria uma inspeção"""
    if not produto_id:
        print(f"  ❌ Erro: produto_id é necessário para criar inspeção")
        return False
        
    defeitos = []
    if qualidade < 0.7:
        defeitos = [{"tipo": "mancha", "severidade": "media"}]
    if qualidade < 0.5:
        defeitos.append({"tipo": "rasgo", "severidade": "alta"})
    
    # Se camera_id não foi fornecido, escolhe CAM001 para superior e CAM002 para inferior
    if not camera_id:
        camera_id = 'CAM001' if str(lado).lower().startswith('s') or str(lado).lower() == 'superior' else 'CAM002'

    response = requests.post(
        f"{API_BASE_URL}/inspecoes/",
        json={
            "produto_id": produto_id,
            "lado": lado,
            "camera_id": camera_id,
            "qualidade": qualidade,
            "defeitos_detectados": defeitos,
            "metadados": {
                "resolucao": [1920, 1080],
                "timestamp": datetime.utcnow().isoformat()
            }
        }
    )
    if response.status_code == 201:
        print(f"  ✅ Inspeção criada para {produto_id} (lado {lado}, qualidade {qualidade:.2%})")
        return True
    else:
        print(f"  ❌ Erro ao criar inspeção: {response.text}")
        return False

def create_classification(produto_id, classificacao, confianca, motivo):
    """Cria uma classificação"""
    response = requests.post(
        f"{API_BASE_URL}/classificacoes/",
        json={
            "produto_id": produto_id,
            "classificacao": classificacao,
            "confianca": confianca,
            "motivo": motivo,
            "criterios_avaliados": {
                "qualidade_media": random.uniform(0.7, 0.95),
                "total_defeitos": random.randint(0, 3)
            },
            "recomendacoes": []
        }
    )
    if response.status_code == 201:
        print(f"  ✅ Classificação criada: {classificacao} (confiança {confianca:.2%})")
        return True
    else:
        print(f"  ❌ Erro ao criar classificação: {response.text}")
        return False

def main():
    """Função principal"""
    print("=" * 60)
    print("Populando banco de dados com dados de demonstração")
    print("=" * 60)
    print()
    
    # Verificar se a API está rodando
    try:
        response = requests.get(f"{API_BASE_URL}/health")
        if response.status_code != 200:
            print("❌ API não está respondendo. Execute 'python run_api.py' primeiro.")
            return
    except requests.exceptions.ConnectionError:
        print("❌ Não foi possível conectar à API. Execute 'python run_api.py' primeiro.")
        return
    
    print("✅ API está rodando")
    print()
    
    # Cria produtos com diferentes classificações
    produtos_data = [
        # Aprovados
        ("PROD001", "aprovado", 0.95, "Qualidade excelente, sem defeitos"),
        ("PROD002", "aprovado", 0.92, "Qualidade muito boa"),
        ("PROD003", "aprovado", 0.88, "Qualidade boa, aprovado"),
        ("PROD004", "aprovado", 0.90, "Qualidade excelente"),
        ("PROD005", "aprovado", 0.93, "Sem defeitos detectados"),
        
        # Reprocessar (produtos que precisam ser reprocessados)
        ("PROD006", "reprocessar", 0.75, "Qualidade abaixo do esperado"),
        ("PROD007", "reprocessar", 0.70, "Pequenos defeitos detectados"),
        ("PROD008", "reprocessar", 0.68, "Necessita reprocessamento"),
        ("PROD009", "reprocessar", 0.72, "Qualidade marginal"),
        
        # Segregados
        ("PROD010", "segregar", 0.45, "Defeitos graves detectados"),
        ("PROD011", "segregar", 0.40, "Produto com múltiplos defeitos"),
        ("PROD012", "segregar", 0.35, "Não atende aos critérios mínimos"),
    ]
    
    print("Criando produtos e classificações...")
    print("-" * 60)
    
    for produto_id, classificacao, confianca, motivo in produtos_data:
        # Criar produto (pode usar IDs específicos ou deixar gerar automaticamente)
        id_criado = create_product(produto_id, "superior", "classificado")
        
        # Usar o ID criado (pode ser o fornecido ou um gerado automaticamente)
        id_para_uso = id_criado if id_criado else produto_id
        
        if not id_para_uso:
            print(f"  ⚠️ Não foi possível criar produto, pulando...")
            continue
        
        # Cria inspeções (ambos os lados)
        qualidade_lado1 = confianca + random.uniform(-0.1, 0.1)
        qualidade_lado1 = max(0.3, min(1.0, qualidade_lado1))
        create_inspection(id_para_uso, "superior", qualidade_lado1)
        
        qualidade_lado2 = confianca + random.uniform(-0.1, 0.1)
        qualidade_lado2 = max(0.3, min(1.0, qualidade_lado2))
        create_inspection(id_para_uso, "inferior", qualidade_lado2)
        
        # Criar classificação
        create_classification(id_para_uso, classificacao, confianca, motivo)
        
        time.sleep(0.1)  # Pequeno atraso para evitar sobrecarga
    
    print()
    print("=" * 60)
    print("✅ Dados de demonstração criados com sucesso!")
    print("=" * 60)
    print()
    print("Acesse o dashboard em: http://localhost:8000")
    print()

if __name__ == "__main__":
    main()

