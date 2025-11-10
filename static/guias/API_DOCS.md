# Documentação da API - Sistema de Inspeção Automatizada

## 📋 Visão Geral

API REST desenvolvida com FastAPI para gerenciamento do sistema de inspeção automatizada de campos cirúrgicos.

## 🗄️ Banco de Dados

### Estrutura

O banco de dados utiliza SQLite (padrão) e pode ser facilmente migrado para PostgreSQL ou MySQL.

**Localização**: `data/inspecao.db`

### Tabelas

1. **produtos** - Campos cirúrgicos (produtos)
2. **inspecoes** - Inspeções realizadas
3. **classificacoes** - Classificações dos produtos
4. **esteira_status** - Status das esteiras (futuro)
5. **camera_status** - Status das câmeras (futuro)
6. **inversor_status** - Status do inversor (futuro)

## 🚀 Como Usar

### 1. Inicializar o Banco de Dados

```bash
python init_db.py
```

### 2. Executar a API

```bash
python run_api.py
```

A API estará disponível em: `http://localhost:8000`

### 3. Acessar a Documentação

- **Swagger UI**: http://localhost:8000/docs
- **ReDoc**: http://localhost:8000/redoc

## 📡 Endpoints

### Produtos

#### Criar Produto
```http
POST /produtos
Content-Type: application/json

{
  "id": "PROD001",
  "lado_atual": "superior",
  "status": "pendente"
}
```

#### Listar Produtos
```http
GET /produtos?skip=0&limit=100&status_filter=pendente
```

#### Obter Produto
```http
GET /produtos/{produto_id}
```

#### Atualizar Produto
```http
PUT /produtos/{produto_id}
Content-Type: application/json

{
  "lado_atual": "inferior",
  "status": "em_inspecao",
  "classificacao_final": "aprovado"
}
```

#### Deletar Produto
```http
DELETE /produtos/{produto_id}
```

### Inspeções

#### Criar Inspeção
```http
POST /inspecoes
Content-Type: application/json

{
  "produto_id": "PROD001",
  "lado": "superior",
  "camera_id": "CAM001",
  "qualidade": 0.95,
  "imagem_path": "data/imagens/PROD001_superior.jpg",
  "defeitos_detectados": [],
  "metadados": {
    "resolucao": [1920, 1080],
    "timestamp": "2024-01-01T10:00:00"
  }
}
```

#### Listar Inspeções
```http
GET /inspecoes?skip=0&limit=100&produto_id=PROD001
```

#### Obter Inspeção
```http
GET /inspecoes/{inspecao_id}
```

#### Obter Inspeções de um Produto
```http
GET /inspecoes/produto/{produto_id}
```

### Classificações

#### Criar Classificação
```http
POST /classificacoes
Content-Type: application/json

{
  "produto_id": "PROD001",
  "classificacao": "aprovado",
  "confianca": 0.95,
  "motivo": "Qualidade excelente",
  "criterios_avaliados": {
    "qualidade_media": 0.95,
    "total_defeitos": 0
  },
  "recomendacoes": []
}
```

#### Listar Classificações
```http
GET /classificacoes?skip=0&limit=100&produto_id=PROD001&classificacao_filter=aprovado
```

#### Obter Classificação
```http
GET /classificacoes/{classificacao_id}
```

#### Obter Classificação de um Produto
```http
GET /classificacoes/produto/{produto_id}
```

### Estatísticas

#### Obter Estatísticas
```http
GET /estatisticas
```

Resposta:
```json
{
  "total_classificados": 100,
  "aprovados": 85,
  "reprocessar": 10,
  "segregados": 5,
  "percentuais": {
    "aprovados": 85.0,
    "reprocessar": 10.0,
    "segregados": 5.0
  }
}
```

## 🔧 Configuração

### Variáveis de Ambiente

Você pode configurar a URL do banco de dados usando a variável de ambiente `DATABASE_URL`:

```bash
export DATABASE_URL="sqlite:///./data/inspecao.db"
```

Para PostgreSQL:
```bash
export DATABASE_URL="postgresql://user:password@localhost/inspecao"
```

### CORS

Por padrão, o CORS está configurado para permitir todas as origens (`*`). Em produção, configure as origens permitidas no arquivo `src/projeto_cremer_inspecao/api/main.py`.

## 📊 Modelos de Dados

### Produto
- `id` (String, PK): ID único do produto
- `lado_atual` (String): Lado atual ("superior" ou "inferior")
- `status` (Enum): Status do produto
- `classificacao_final` (Enum, nullable): Classificação final
- `timestamp_entrada` (DateTime): Data/hora de entrada
- `timestamp_classificacao` (DateTime, nullable): Data/hora de classificação

### Inspeção
- `id` (Integer, PK): ID único da inspeção
- `produto_id` (String, FK): ID do produto
- `lado` (Enum): Lado inspecionado
- `camera_id` (String): ID da câmera
- `qualidade` (Float): Qualidade (0.0 a 1.0)
- `imagem_path` (String, nullable): Caminho da imagem
- `defeitos_detectados` (JSON, nullable): Lista de defeitos
- `metadados` (JSON, nullable): Metadados da inspeção

### Classificação
- `id` (Integer, PK): ID único da classificação
- `produto_id` (String, FK): ID do produto
- `classificacao` (Enum): Tipo de classificação
- `confianca` (Float): Confiança (0.0 a 1.0)
- `motivo` (Text, nullable): Motivo da classificação
- `criterios_avaliados` (JSON, nullable): Critérios avaliados
- `recomendacoes` (JSON, nullable): Recomendações

## 🔒 Segurança

Atualmente, a API não possui autenticação. Para produção, recomenda-se:

1. Implementar autenticação JWT
2. Adicionar rate limiting
3. Configurar CORS adequadamente
4. Usar HTTPS
5. Validar e sanitizar todas as entradas

## 🧪 Testes

Para testar a API, você pode usar:

1. **Swagger UI**: http://localhost:8000/docs (interface interativa)
2. **curl**: Linha de comando
3. **Postman**: Cliente HTTP
4. **Python requests**: Biblioteca Python

### Exemplo com Python

```python
import requests

# Criar produto
response = requests.post(
    "http://localhost:8000/produtos",
    json={
        "id": "PROD001",
        "lado_atual": "superior",
        "status": "pendente"
    }
)
print(response.json())

# Listar produtos
response = requests.get("http://localhost:8000/produtos")
print(response.json())
```

## 📝 Notas

- O banco de dados SQLite é criado automaticamente na primeira execução
- As imagens são armazenadas no diretório `data/imagens/`
- Os timestamps são gerados automaticamente pelo banco de dados
- A API suporta paginação através dos parâmetros `skip` e `limit`

