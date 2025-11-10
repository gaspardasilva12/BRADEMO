"""
Endpoints para estatísticas do sistema
"""

from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from sqlalchemy import func
from typing import List, Dict, Any
from datetime import datetime, timedelta

from ..database import get_db
from ..models import Classificacao as ClassificacaoModel, TipoClassificacao, Produto as ProdutoModel, Inspecao as InspecaoModel
from ..schemas import Estatisticas

router = APIRouter(prefix="/estatisticas", tags=["estatisticas"])


@router.get("/", response_model=Estatisticas)
def obter_estatisticas(db: Session = Depends(get_db)):
    """
    Obtém estatísticas gerais do sistema
    """
    # Conta total de classificações
    total_classificados = db.query(ClassificacaoModel).count()
    
    # Conta por tipo de classificação
    aprovados = db.query(ClassificacaoModel).filter(
        ClassificacaoModel.classificacao == TipoClassificacao.APROVADO.value
    ).count()
    
    reprocessar = db.query(ClassificacaoModel).filter(
        ClassificacaoModel.classificacao == TipoClassificacao.REPROCESSAR.value
    ).count()
    
    segregados = db.query(ClassificacaoModel).filter(
        ClassificacaoModel.classificacao == TipoClassificacao.SEGREGAR.value
    ).count()
    
    # Calcula percentuais
    if total_classificados > 0:
        percentuais = {
            "aprovados": (aprovados / total_classificados) * 100,
            "reprocessar": (reprocessar / total_classificados) * 100,
            "segregados": (segregados / total_classificados) * 100
        }
    else:
        percentuais = {
            "aprovados": 0.0,
            "reprocessar": 0.0,
            "segregados": 0.0
        }
    
    return Estatisticas(
        total_classificados=total_classificados,
        aprovados=aprovados,
        reprocessar=reprocessar,
        segregados=segregados,
        percentuais=percentuais
    )


@router.get("/historico")
def obter_historico(dias: int = 7, db: Session = Depends(get_db)):
    """
    Obtém histórico de classificações por dia para gráficos
    """
    # Calcula data inicial
    data_inicial = datetime.utcnow() - timedelta(days=dias)
    
    # Busca classificações dos últimos N dias
    classificacoes = db.query(ClassificacaoModel).filter(
        ClassificacaoModel.timestamp >= data_inicial
    ).order_by(ClassificacaoModel.timestamp.asc()).all()
    
    # Agrupa por dia
    historico: Dict[str, Dict[str, int]] = {}
    
    for classificacao in classificacoes:
        data_str = classificacao.timestamp.strftime("%Y-%m-%d") if classificacao.timestamp else datetime.utcnow().strftime("%Y-%m-%d")
        
        if data_str not in historico:
            historico[data_str] = {
                "aprovados": 0,
                "reprocessar": 0,
                "segregados": 0,
                "total": 0
            }
        
        historico[data_str]["total"] += 1
        if classificacao.classificacao == TipoClassificacao.APROVADO.value:
            historico[data_str]["aprovados"] += 1
        elif classificacao.classificacao == TipoClassificacao.REPROCESSAR.value:
            historico[data_str]["reprocessar"] += 1
        elif classificacao.classificacao == TipoClassificacao.SEGREGAR.value:
            historico[data_str]["segregados"] += 1
    
    # Converte para lista ordenada
    resultado = []
    for data in sorted(historico.keys()):
        resultado.append({
            "data": data,
            **historico[data]
        })
    
    return resultado


@router.get("/recentes")
def obter_classificacoes_recentes(limit: int = 10, db: Session = Depends(get_db)):
    """
    Obtém as classificações mais recentes
    """
    classificacoes = db.query(ClassificacaoModel).order_by(
        ClassificacaoModel.timestamp.desc()
    ).limit(limit).all()
    
    resultado = []
    for classif in classificacoes:
        resultado.append({
            "id": classif.id,
            "produto_id": classif.produto_id,
            "classificacao": classif.classificacao,
            "confianca": classif.confianca,
            "timestamp": classif.timestamp.isoformat() if classif.timestamp else None
        })
    
    return resultado


@router.get("/cameras")
def obter_estatisticas_cameras(db: Session = Depends(get_db)):
    """
    Retorna contagem de inspeções por câmera para uso em gráficos (array de {camera, total})
    """
    # Agrupa inspeções por camera_id
    rows = db.query(InspecaoModel.camera_id, func.count(InspecaoModel.id)).group_by(InspecaoModel.camera_id).all()

    resultado = []
    for camera_id, total in rows:
        resultado.append({
            "camera": camera_id,
            "total": int(total)
        })

    return resultado

