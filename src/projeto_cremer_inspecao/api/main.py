"""
API Principal do Sistema de Inspeção Automatizada
"""

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from fastapi.responses import FileResponse
from pathlib import Path

from .database import init_db, engine
from .endpoints import produtos, inspecoes, classificacoes, estatisticas
from .endpoints import cameras

# Inicializa o banco de dados
init_db()

# Cria a aplicação FastAPI
app = FastAPI(
    title="Sistema de Inspeção Automatizada - Projeto Cremer",
    description="API para gerenciamento do sistema de inspeção automatizada de campos cirúrgicos",
    version="1.0.0"
)

# Configura CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Em produção, especificar origins permitidas
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Inclui os routers
app.include_router(produtos.router)
app.include_router(inspecoes.router)
app.include_router(classificacoes.router)
app.include_router(estatisticas.router)
app.include_router(cameras.router)

# Configura arquivos estáticos
# O caminho estático é relativo ao diretório raiz do projeto
project_root = Path(__file__).parent.parent.parent.parent
static_path = project_root / "static"

if static_path.exists():
    app.mount("/static", StaticFiles(directory=str(static_path)), name="static")


@app.get("/")
async def root():
    """
    Endpoint raiz da API - Redireciona para o dashboard
    """
    dashboard_path = static_path / "index.html"
    if dashboard_path.exists() and dashboard_path.is_file():
        return FileResponse(str(dashboard_path))
    return {
        "message": "Sistema de Inspeção Automatizada - API",
        "version": "1.0.0",
        "docs": "/docs",
        "redoc": "/redoc",
        "dashboard": "/static/index.html"
    }


@app.get("/health")
def health_check():
    """
    Endpoint de health check
    """
    return {"status": "healthy", "database": "connected"}

