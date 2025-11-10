"""
Endpoints para gerenciamento de classificações
"""

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List, Optional
from datetime import datetime
import json

from ..database import get_db
from ..models import (
    Classificacao as ClassificacaoModel,
    Produto as ProdutoModel,
    Inspecao as InspecaoModel,
    TipoClassificacao
)
from ..schemas import Classificacao, ClassificacaoCreate, Message

router = APIRouter(prefix="/classificacoes", tags=["classificacoes"])


def _convert_classificacao_to_dict(db_classificacao):
    """
    Converte um modelo de classificação do banco de dados para um dicionário,
    tratando erros de conversão de forma segura.
    """
    try:
        # Converte classificacao para enum, com fallback para string
        try:
            tipo_enum = TipoClassificacao(db_classificacao.classificacao)
            classificacao_value = tipo_enum.value
        except (ValueError, AttributeError, TypeError):
            # Se não conseguir converter, usa o valor diretamente como string
            classificacao_value = str(db_classificacao.classificacao) if db_classificacao.classificacao else "pendente"
        
        # Parse JSON fields com tratamento de erro
        criterios = None
        if db_classificacao.criterios_avaliados:
            try:
                criterios = json.loads(db_classificacao.criterios_avaliados)
            except (json.JSONDecodeError, TypeError, AttributeError):
                criterios = {}
        
        recomendacoes = None
        if db_classificacao.recomendacoes:
            try:
                recomendacoes = json.loads(db_classificacao.recomendacoes)
            except (json.JSONDecodeError, TypeError, AttributeError):
                recomendacoes = []
        
        return {
            "id": db_classificacao.id,
            "produto_id": db_classificacao.produto_id,
            "classificacao": classificacao_value,
            "confianca": float(db_classificacao.confianca) if db_classificacao.confianca is not None else 0.0,
            "motivo": db_classificacao.motivo,
            "criterios_avaliados": criterios,
            "recomendacoes": recomendacoes,
            "timestamp": db_classificacao.timestamp,
            "created_at": db_classificacao.created_at
        }
    except Exception as e:
        # Log erro mas retorna dados básicos
        print(f"Erro ao converter classificação {db_classificacao.id}: {e}")
        return {
            "id": db_classificacao.id,
            "produto_id": db_classificacao.produto_id or "",
            "classificacao": str(db_classificacao.classificacao) if db_classificacao.classificacao else "pendente",
            "confianca": 0.0,
            "motivo": None,
            "criterios_avaliados": {},
            "recomendacoes": [],
            "timestamp": db_classificacao.timestamp,
            "created_at": db_classificacao.created_at
        }


@router.post("/", response_model=Classificacao, status_code=status.HTTP_201_CREATED)
def criar_classificacao(classificacao: ClassificacaoCreate, db: Session = Depends(get_db)):
    """
    Cria uma nova classificação
    """
    # Verifica se o produto existe
    produto = db.query(ProdutoModel).filter(ProdutoModel.id == classificacao.produto_id).first()
    if not produto:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Produto com ID {classificacao.produto_id} não encontrado"
        )
    
    db_classificacao = ClassificacaoModel(
        produto_id=classificacao.produto_id,
        classificacao=classificacao.classificacao.value,
        confianca=classificacao.confianca,
        motivo=classificacao.motivo,
        criterios_avaliados=json.dumps(classificacao.criterios_avaliados) if classificacao.criterios_avaliados else None,
        recomendacoes=json.dumps(classificacao.recomendacoes) if classificacao.recomendacoes else None
    )
    
    db.add(db_classificacao)
    
    # Atualiza o produto com a classificação
    produto.classificacao_final = classificacao.classificacao.value if hasattr(classificacao.classificacao, 'value') else str(classificacao.classificacao)
    produto.timestamp_classificacao = datetime.utcnow()
    produto.status = "classificado"
    
    db.commit()
    db.refresh(db_classificacao)
    
    # Converte para schema de resposta
    response_data = _convert_classificacao_to_dict(db_classificacao)
    return Classificacao(**response_data)


@router.get("/", response_model=List[Classificacao])
def listar_classificacoes(
    skip: int = 0,
    limit: int = 100,
    produto_id: Optional[str] = None,
    classificacao_filter: Optional[str] = None,
    db: Session = Depends(get_db)
):
    """
    Lista todas as classificações com filtros opcionais
    """
    query = db.query(ClassificacaoModel)
    
    if produto_id:
        query = query.filter(ClassificacaoModel.produto_id == produto_id)
    if classificacao_filter:
        try:
            tipo = TipoClassificacao(classificacao_filter)
            query = query.filter(ClassificacaoModel.classificacao == tipo.value)
        except ValueError:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Classificação inválida: {classificacao_filter}"
            )
    
    # aplicar order_by antes de offset/limit para evitar InvalidRequestError do SQLAlchemy
    db_classificacoes = query.order_by(ClassificacaoModel.timestamp.desc()).offset(skip).limit(limit).all()
    
    # Converte para schemas de resposta
    classificacoes = []
    for db_classificacao in db_classificacoes:
        try:
            response_data = _convert_classificacao_to_dict(db_classificacao)
            classificacoes.append(Classificacao(**response_data))
        except Exception as e:
            print(f"Erro ao processar classificação {db_classificacao.id}: {e}")
            continue
    
    return classificacoes


@router.get("/{classificacao_id}", response_model=Classificacao)
def obter_classificacao(classificacao_id: int, db: Session = Depends(get_db)):
    """
    Obtém uma classificação específica por ID
    """
    db_classificacao = db.query(ClassificacaoModel).filter(
        ClassificacaoModel.id == classificacao_id
    ).first()
    if not db_classificacao:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Classificação com ID {classificacao_id} não encontrada"
        )
    
    # Converte para schema de resposta
    response_data = _convert_classificacao_to_dict(db_classificacao)
    return Classificacao(**response_data)


@router.get("/produto/{produto_id}", response_model=Classificacao)
def obter_classificacao_produto(produto_id: str, db: Session = Depends(get_db)):
    """
    Obtém a classificação de um produto específico
    """
    produto = db.query(ProdutoModel).filter(ProdutoModel.id == produto_id).first()
    if not produto:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Produto com ID {produto_id} não encontrado"
        )
    
    db_classificacao = db.query(ClassificacaoModel).filter(
        ClassificacaoModel.produto_id == produto_id
    ).order_by(ClassificacaoModel.timestamp.desc()).first()
    
    if not db_classificacao:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Classificação para o produto {produto_id} não encontrada"
        )
    
    # Converte para schema de resposta
    response_data = _convert_classificacao_to_dict(db_classificacao)
    return Classificacao(**response_data)
