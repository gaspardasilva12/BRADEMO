"""
Endpoints para gerenciamento de inspeções
"""

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List, Optional
import json

from ..database import get_db
from ..models import Inspecao as InspecaoModel, Produto as ProdutoModel
from ..schemas import Inspecao, InspecaoCreate, Message, LadoInspecao

router = APIRouter(prefix="/inspecoes", tags=["inspecoes"])


def _convert_inspecao_to_dict(db_inspecao):
    """
    Converte um modelo de inspeção do banco de dados para um dicionário,
    tratando erros de conversão de forma segura.
    """
    try:
        # Converte lado para enum, com fallback para string
        try:
            lado_enum = LadoInspecao(db_inspecao.lado)
            lado_value = lado_enum.value
        except (ValueError, AttributeError, TypeError):
            # Se não conseguir converter, usa o valor diretamente como string
            lado_value = str(db_inspecao.lado) if db_inspecao.lado else "superior"
        
        # Parse JSON fields com tratamento de erro
        defeitos = None
        if db_inspecao.defeitos_detectados:
            try:
                defeitos = json.loads(db_inspecao.defeitos_detectados)
            except (json.JSONDecodeError, TypeError, AttributeError):
                defeitos = []
        
        metadados = None
        if db_inspecao.metadados:
            try:
                metadados = json.loads(db_inspecao.metadados)
            except (json.JSONDecodeError, TypeError, AttributeError):
                metadados = {}
        
        return {
            "id": db_inspecao.id,
            "produto_id": db_inspecao.produto_id,
            "lado": lado_value,
            "camera_id": db_inspecao.camera_id or "",
            "qualidade": float(db_inspecao.qualidade) if db_inspecao.qualidade is not None else 0.0,
            "imagem_path": db_inspecao.imagem_path,
            "defeitos_detectados": defeitos,
            "metadados": metadados,
            "timestamp": db_inspecao.timestamp,
            "created_at": db_inspecao.created_at
        }
    except Exception as e:
        # Log erro mas retorna dados básicos
        print(f"Erro ao converter inspeção {db_inspecao.id}: {e}")
        return {
            "id": db_inspecao.id,
            "produto_id": db_inspecao.produto_id or "",
            "lado": str(db_inspecao.lado) if db_inspecao.lado else "superior",
            "camera_id": db_inspecao.camera_id or "",
            "qualidade": 0.0,
            "imagem_path": None,
            "defeitos_detectados": [],
            "metadados": {},
            "timestamp": db_inspecao.timestamp,
            "created_at": db_inspecao.created_at
        }


@router.post("/", response_model=Inspecao, status_code=status.HTTP_201_CREATED)
def criar_inspecao(inspecao: InspecaoCreate, db: Session = Depends(get_db)):
    """
    Cria uma nova inspeção
    """
    # Verifica se o produto existe
    produto = db.query(ProdutoModel).filter(ProdutoModel.id == inspecao.produto_id).first()
    if not produto:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Produto com ID {inspecao.produto_id} não encontrado"
        )
    
    db_inspecao = InspecaoModel(
        produto_id=inspecao.produto_id,
        lado=inspecao.lado.value if hasattr(inspecao.lado, 'value') else str(inspecao.lado),
        camera_id=inspecao.camera_id,
        qualidade=inspecao.qualidade,
        imagem_path=inspecao.imagem_path,
        defeitos_detectados=json.dumps(inspecao.defeitos_detectados) if inspecao.defeitos_detectados else None,
        metadados=json.dumps(inspecao.metadados) if inspecao.metadados else None
    )
    
    db.add(db_inspecao)
    db.commit()
    db.refresh(db_inspecao)
    
    # Converte para schema de resposta
    response_data = _convert_inspecao_to_dict(db_inspecao)
    return Inspecao(**response_data)


@router.get("/", response_model=List[Inspecao])
def listar_inspecoes(
    skip: int = 0,
    limit: int = 100,
    produto_id: Optional[str] = None,
    db: Session = Depends(get_db)
):
    """
    Lista todas as inspeções com filtros opcionais
    """
    query = db.query(InspecaoModel)
    
    if produto_id:
        query = query.filter(InspecaoModel.produto_id == produto_id)
    
    # aplicar order_by antes de offset/limit para evitar InvalidRequestError do SQLAlchemy
    db_inspecoes = query.order_by(InspecaoModel.timestamp.desc()).offset(skip).limit(limit).all()
    
    # Converte para schemas de resposta
    inspecoes = []
    for db_inspecao in db_inspecoes:
        try:
            response_data = _convert_inspecao_to_dict(db_inspecao)
            inspecoes.append(Inspecao(**response_data))
        except Exception as e:
            print(f"Erro ao processar inspeção {db_inspecao.id}: {e}")
            continue
    
    return inspecoes


@router.get("/{inspecao_id}", response_model=Inspecao)
def obter_inspecao(inspecao_id: int, db: Session = Depends(get_db)):
    """
    Obtém uma inspeção específica por ID
    """
    db_inspecao = db.query(InspecaoModel).filter(InspecaoModel.id == inspecao_id).first()
    if not db_inspecao:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Inspeção com ID {inspecao_id} não encontrada"
        )
    
    # Converte para schema de resposta
    response_data = _convert_inspecao_to_dict(db_inspecao)
    return Inspecao(**response_data)


@router.get("/produto/{produto_id}", response_model=List[Inspecao])
def obter_inspecoes_produto(produto_id: str, db: Session = Depends(get_db)):
    """
    Obtém todas as inspeções de um produto específico
    """
    produto = db.query(ProdutoModel).filter(ProdutoModel.id == produto_id).first()
    if not produto:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Produto com ID {produto_id} não encontrado"
        )
    
    db_inspecoes = db.query(InspecaoModel).filter(
        InspecaoModel.produto_id == produto_id
    ).order_by(InspecaoModel.timestamp.asc()).all()
    
    # Converte para schemas de resposta
    inspecoes = []
    for db_inspecao in db_inspecoes:
        try:
            response_data = _convert_inspecao_to_dict(db_inspecao)
            inspecoes.append(Inspecao(**response_data))
        except Exception as e:
            print(f"Erro ao processar inspeção {db_inspecao.id}: {e}")
            continue
    
    return inspecoes
