"""
Script para executar a API do Sistema de Inspeção Automatizada
"""

import uvicorn
import sys
from pathlib import Path

# Adicionar o diretório src ao caminho
sys.path.insert(0, str(Path(__file__).parent / "src"))

if __name__ == "__main__":
    uvicorn.run(
        "projeto_cremer_inspecao.api.main:app",
        host="0.0.0.0",
        port=8000,
        reload=True,  # Ativar reload automático durante desenvolvimento
        log_level="info"
    )

