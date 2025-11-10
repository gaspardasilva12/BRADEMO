# 🚀 Guia de Execução - Projeto Cremer Inspeção

Este guia mostra como executar o projeto de diferentes formas.

## 📋 Pré-requisitos

- Python 3.7 ou superior
- pip (gerenciador de pacotes Python)

## 🔧 Instalação Inicial (Primeira Vez)

### 1. Navegar até a pasta do projeto

```bash
cd projeto_cremer_inspecao
```

### 2. Criar ambiente virtual (Recomendado)

**Windows:**
```bash
python -m venv venv
venv\Scripts\activate
```

**Linux/Mac:**
```bash
python -m venv venv
source venv/bin/activate
```

### 3. Instalar dependências

```bash
pip install -r requirements.txt
```

### 4. Instalar o projeto em modo desenvolvimento

```bash
pip install -e .
```

### 5. Inicializar o banco de dados (Para usar a API)

```bash
python init_db.py
```

---

## 🎯 Formas de Executar o Projeto

### Opção 1: Script Principal (Simulação Completa)

Executa uma simulação completa do sistema de inspeção:

```bash
python main.py
```

**O que faz:**
- Cria e configura todos os componentes (esteiras, câmeras, inversor, classificador)
- Simula a inspeção de um produto completo
- Mostra todo o fluxo de inspeção

---

### Opção 2: Exemplo Completo

Executa exemplos mais detalhados:

```bash
python examples/exemplo_uso.py
```

**O que faz:**
- Executa exemplo de inspeção completa
- Executa exemplo de múltiplos produtos
- Mostra estatísticas finais

---

### Opção 3: API Backend (Servidor REST)

#### 3.1. Inicializar o banco de dados (primeira vez apenas)

```bash
python init_db.py
```

#### 3.2. Executar a API

```bash
python run_api.py
```

**A API estará disponível em:**
- **URL Base**: http://localhost:8000
- **Documentação Interativa (Swagger)**: http://localhost:8000/docs
- **Documentação Alternativa (ReDoc)**: http://localhost:8000/redoc

**Para parar a API:** Pressione `Ctrl + C` no terminal

#### 3.3. Testar a API

**Usando o Swagger UI:**
1. Abra o navegador em http://localhost:8000/docs
2. Teste os endpoints diretamente na interface

**Usando curl (linha de comando):**
```bash
# Health check
curl http://localhost:8000/health

# Listar produtos
curl http://localhost:8000/produtos

# Criar produto
curl -X POST http://localhost:8000/produtos \
  -H "Content-Type: application/json" \
  -d '{"id": "PROD001", "lado_atual": "superior", "status": "pendente"}'
```

**Usando Python:**
```python
import requests

# Criar produto
response = requests.post(
    "http://localhost:8000/produtos",
    json={"id": "PROD001", "lado_atual": "superior", "status": "pendente"}
)
print(response.json())
```

---


## 📝 Resumo dos Comandos

| Ação | Comando |
|------|---------|
| **Instalar dependências** | `pip install -r requirements.txt` |
| **Instalar projeto** | `pip install -e .` |
| **Inicializar banco de dados** | `python init_db.py` |
| **Executar script principal** | `python main.py` |
| **Executar exemplo** | `python examples/exemplo_uso.py` |
| **Executar API** | `python run_api.py` |
|

---



```python
uvicorn.run(
    "projeto_cremer_inspecao.api.main:app",
    host="0.0.0.0",
    port=8001,  # Mude para outra porta
    reload=True,
    log_level="info"
)
```

---

## 📚 Próximos Passos

1. **Explorar a API**: Acesse http://localhost:8000/docs para ver todos os endpoints
2. **Ler a documentação**: Veja `API_DOCS.md` para detalhes da API
3. **Ver exemplos**: Explore a pasta `examples/` para mais exemplos
4. **Integrar com seu código**: Use os módulos diretamente no seu código Python

---

## 💡 Dicas

- Use o ambiente virtual para isolar as dependências
- A API tem reload automático ativado (mudanças no código são recarregadas automaticamente)
- Use o Swagger UI para testar a API facilmente
- Os dados são salvos no arquivo `data/inspecao.db` (SQLite)

---

## 📞 Suporte

Para mais informações, consulte:
- `README.md` - Documentação geral do projeto
- `API_DOCS.md` - Documentação detalhada da API
- `examples/exemplo_uso.py` - Exemplos de uso

