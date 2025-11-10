# Projeto Cremer - Sistema de Inspeção Automatizada de Campos Cirúrgicos

Sistema automatizado de inspeção que utiliza visão computacional para inspecionar ambos os lados de campos cirúrgicos, classificando-os como:
- **Aprovado**: Produto atende a todos os critérios de qualidade
- **Reprocessar**: Produto precisa ser reprocessado para atender aos critérios
- **Segregar**: Produto apresenta defeitos graves e deve ser segregado

## 📋 Descrição

O sistema é composto por:
- **Esteiras**: Esteiras superior e inferior para transporte dos campos cirúrgicos
- **Câmeras de Inspeção**: Câmeras para captura e análise de imagens dos produtos
- **Inversor**: Mecanismo para inverter os produtos entre as esteiras
- **Classificador**: Sistema de classificação baseado em critérios de qualidade

## 🏗️ Estrutura do Projeto

```
projeto_cremer_inspecao/
├── src/
│   └── projeto_cremer_inspecao/
│       ├── __init__.py
│       ├── api/                     # API REST (FastAPI)
│       │   ├── endpoints/           # Endpoints da API
│       │   ├── models.py            # Modelos de dados
│       │   └── schemas.py           # Schemas Pydantic
│       └── modules/
│           ├── __init__.py
│           ├── esteira.py          # Controle de esteiras
│           ├── camera_inspecao.py  # Câmeras de inspeção
│           ├── inversor.py         # Mecanismo de inversão
│           └── classificador.py    # Sistema de classificação
├── static/                          # Frontend (Dashboard Web)
│   ├── css/                         # Estilos
│   ├── js/                          # JavaScript
│   └── index.html                   # Página principal
├── data/                            # Dados e imagens
├── examples/                        # Exemplos de uso
├── tests/                           # Testes unitários
├── requirements.txt                 # Dependências
└── README.md                        # Este arquivo
```

## 🚀 Instalação

1. Clone o repositório:
```bash
git clone <url-do-repositorio>
cd projeto_cremer_inspecao
```

2. Crie um ambiente virtual:
```bash
python -m venv venv
source venv/bin/activate  # Linux/Mac
# ou
venv\Scripts\activate  # Windows
```

3. Instale as dependências:
```bash
pip install -r requirements.txt
```

4. Instale o projeto em modo desenvolvimento:
```bash
pip install -e .
```

## 📦 Módulos

### Esteira
Controla as esteiras superior e inferior do sistema. Gerencia o transporte de produtos, suas posições e sincronização.

```python
from projeto_cremer_inspecao.modules import Esteira, Produto

esteira_superior = Esteira("superior", velocidade=1.0, comprimento=10.0)
esteira_superior.iniciar()

produto = Produto(id="PROD001", lado_atual="superior")
esteira_superior.adicionar_produto(produto)
```

### CameraInspecao
Responsável por capturar e processar imagens dos campos cirúrgicos.

```python
from projeto_cremer_inspecao.modules import CameraInspecao

camera = CameraInspecao("CAM001", posicao="superior", resolucao=(1920, 1080))
camera.conectar()
camera.calibrar()
resultado = camera.capturar_imagem("PROD001")
```

### Inversor
Controla o mecanismo de inversão dos produtos entre as esteiras.

```python
from projeto_cremer_inspecao.modules import Inversor, DirecaoInversao

inversor = Inversor("INV001", tempo_inversao=2.0)
inversor.conectar()
inversor.calibrar()
resultado = inversor.inverter_produto("PROD001", DirecaoInversao.SUPERIOR_PARA_INFERIOR)
```

### Classificador
Classifica os produtos com base nas inspeções realizadas.

```python
from projeto_cremer_inspecao.modules import Classificador

classificador = Classificador("CLASS001")
resultado = classificador.classificar_produto(
    produto_id="PROD001",
    inspecao_lado_1=resultado_lado_1,
    inspecao_lado_2=resultado_lado_2
)
```

## 🔄 Fluxo de Inspeção

1. **Entrada do Produto**: Produto é adicionado à esteira superior
2. **Inspeção Lado 1**: Câmera captura imagem do primeiro lado
3. **Inversão**: Produto é invertido para a esteira inferior
4. **Inspeção Lado 2**: Câmera captura imagem do segundo lado
5. **Classificação**: Sistema classifica o produto com base nas inspeções
6. **Saída**: Produto é direcionado conforme a classificação

## 🧪 Testes

Execute os testes com:

```bash
pytest tests/
```

Para executar com cobertura:

```bash
pytest tests/ --cov=src/projeto_cremer_inspecao
```

## 🚀 Executando o Projeto

> 📖 **Guia Completo**: Veja `GUIA_EXECUCAO.md` para instruções detalhadas passo a passo.

### Instalação Rápida (Primeira Vez)

```bash
# 1. Instalar dependências
pip install -r requirements.txt

# 2. Instalar projeto
pip install -e .

# 3. Inicializar banco de dados (para API)
python init_db.py
```

### Formas de Executar

#### 1. Script Principal (Simulação Completa)
```bash
python main.py
```

#### 2. Exemplo Completo
```bash
python examples/exemplo_uso.py
```

#### 3. API Backend (Servidor REST)
```bash
# Inicializar banco de dados (primeira vez)
python init_db.py

# Executar API
python run_api.py
```

**A API estará disponível em:**
- **Dashboard Web**: http://localhost:8000 (Interface visual completa)
- **API**: http://localhost:8000/api (ou use os endpoints diretamente)
- **Documentação Interativa (Swagger)**: http://localhost:8000/docs
- **Documentação Alternativa (ReDoc)**: http://localhost:8000/redoc

### 🎨 Dashboard Web

O projeto inclui um **dashboard web moderno e interativo** para visualização de dados em tempo real:

**Recursos do Dashboard:**
- 📊 **Estatísticas em tempo real**: Cards com métricas principais (Total, Aprovados, Reprocessar, Segregados)
- 📈 **Gráficos interativos**: 
  - Gráfico de pizza com distribuição de classificações
  - Gráfico de linha com histórico dos últimos 7 dias
- 📋 **Tabelas interativas**: Visualização de produtos, inspeções e classificações
- 🔄 **Atualização automática**: Dados são atualizados a cada 5 segundos
- 🎯 **Navegação intuitiva**: Páginas separadas para cada módulo
- 🎨 **Design moderno**: Interface responsiva e profissional

**Para acessar o dashboard:**
1. Inicie a API: `python run_api.py`
2. Abra seu navegador em: `http://localhost:8000`
3. O dashboard será carregado automaticamente

**Funcionalidades:**
- Visualizar estatísticas gerais do sistema
- Criar novos produtos diretamente pela interface
- Visualizar histórico de inspeções
- Analisar classificações e qualidade dos produtos
- Acompanhar métricas em tempo real

#### 4. Executar Testes
```bash
python -m pytest tests/ -v
```

### Endpoints da API:

- `GET /` - Informações da API
- `GET /health` - Health check
- `GET /produtos` - Lista produtos
- `POST /produtos` - Cria produto
- `GET /produtos/{id}` - Obtém produto específico
- `PUT /produtos/{id}` - Atualiza produto
- `DELETE /produtos/{id}` - Deleta produto
- `GET /inspecoes` - Lista inspeções
- `POST /inspecoes` - Cria inspeção
- `GET /inspecoes/{id}` - Obtém inspeção específica
- `GET /inspecoes/produto/{produto_id}` - Obtém inspeções de um produto
- `GET /classificacoes` - Lista classificações
- `POST /classificacoes` - Cria classificação
- `GET /classificacoes/{id}` - Obtém classificação específica
- `GET /classificacoes/produto/{produto_id}` - Obtém classificação de um produto
- `GET /estatisticas` - Obtém estatísticas do sistema

## 📝 Exemplos

Veja exemplos de uso na pasta `examples/`.

## 🔧 Configuração

O sistema permite configurar:
- Velocidade das esteiras
- Critérios de classificação
- Parâmetros das câmeras
- Tempo de inversão

## 📊 Estatísticas

O sistema mantém estatísticas de:
- Produtos processados
- Classificações realizadas
- Taxa de aprovação/reprocessamento/segregação
- Histórico temporal de classificações
- Métricas de qualidade por produto

Todas as estatísticas são exibidas no **Dashboard Web** em tempo real.

## 🎯 Apresentação para Startups

Este projeto está **pronto para apresentação** em eventos, demos e reuniões com investidores. Siga estes passos:

### Preparação Rápida

1. **Instale as dependências:**
   ```bash
   pip install -r requirements.txt
   pip install -e .
   ```

2. **Inicialize o banco de dados:**
   ```bash
   python init_db.py
   ```

3. **Execute a API com Dashboard:**
   ```bash
   python run_api.py
   ```

4. **Acesse o Dashboard:**
   - Abra: `http://localhost:8000`
   - O dashboard será carregado automaticamente

### Dicas para Apresentação

**✨ Demonstração Visual:**
- O dashboard possui design moderno e profissional
- Gráficos interativos mostram dados em tempo real
- Interface responsiva funciona em qualquer dispositivo

**📊 Funcionalidades para Destacar:**
- Sistema de inspeção automatizada completa
- Classificação inteligente de produtos
- Monitoramento em tempo real
- Histórico e análises estatísticas
- API REST documentada

**🎬 Fluxo de Demonstração Sugerido:**
1. Mostre o dashboard principal com estatísticas
2. Crie um novo produto pela interface
3. Execute uma inspeção (use `main.py` ou `examples/exemplo_uso.py`)
4. Mostre como os dados aparecem em tempo real no dashboard
5. Demonstre os gráficos e análises

**💡 Dados de Exemplo:**
Para popular o sistema com dados de exemplo para demonstração, execute:
```bash
# Em um terminal, inicie a API primeiro
python run_api.py

# Em outro terminal, popule os dados
python populate_demo_data.py
```

Isso criará 12 produtos com diferentes classificações (aprovados, reprocessar, segregados) que aparecerão no dashboard com gráficos e estatísticas.

### Recursos Visuais

- ✅ **Dashboard Moderno**: Interface limpa e profissional
- 📈 **Gráficos Interativos**: Chart.js para visualizações
- 🎨 **Design Responsivo**: Funciona em desktop, tablet e mobile
- 🔄 **Tempo Real**: Atualização automática a cada 5 segundos
- 📱 **Mobile-Friendly**: Interface adaptável para qualquer tela

## 🤝 Contribuindo

1. Faça um fork do projeto
2. Crie uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

## 📄 Licença

Este projeto é propriedade da Cremer.

## 👥 Autores

Equipe UFSC

## 📞 Contato

Para mais informações, entre em contato com a equipe do projeto.

## 🔄 Versão

Versão atual: 1.0.0

