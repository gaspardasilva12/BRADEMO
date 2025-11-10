"""
Endpoints para gerenciamento de produtos
"""

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from sqlalchemy import func
from typing import List, Optional
import json
import re

from ..database import get_db
from ..models import Produto as ProdutoModel
from ..models import Inspecao as InspecaoModel, Classificacao as ClassificacaoModel, EsteiraStatus as EsteiraStatusModel, CameraStatus as CameraStatusModel
from ..schemas import Produto, ProdutoCreate, ProdutoUpdate, Message, StatusProduto

router = APIRouter(prefix="/produtos", tags=["produtos"])


def gerar_id_produto_unico(db: Session) -> str:
    """
    Gera um ID único para produto no formato PROD001, PROD002, etc.
    Busca o maior número existente e incrementa.
    Se houver produtos com IDs que não seguem o padrão, continua a partir do maior número encontrado.
    """
    # Busca todos os produtos que começam com "PROD" seguido de números
    # Usamos with_entities para garantir que recebemos apenas o campo id
    produtos = db.query(ProdutoModel.id).filter(ProdutoModel.id.ilike('PROD%')).all()

    # Extrai números dos IDs existentes de forma robusta
    numeros = []
    for row in produtos:
        # row pode ser uma tupla (id,) ou um objeto com atributo id dependendo da versão do SQLAlchemy
        id_str = None
        if isinstance(row, tuple) or isinstance(row, list):
            if len(row) > 0:
                id_str = row[0]
        else:
            id_str = getattr(row, 'id', None)

        if not id_str:
            continue

        match = re.search(r'PROD0*(\d+)$', str(id_str), re.IGNORECASE)
        if match:
            try:
                numeros.append(int(match.group(1)))
            except ValueError:
                continue

    # Se não há produtos com padrão PROD###, começa do 1
    if numeros:
        proximo_numero = max(numeros) + 1
    else:
        proximo_numero = 1

    # Gera o novo ID no formato PROD001, PROD002, etc.
    novo_id = f"PROD{proximo_numero:03d}"

    # Verifica se o ID já existe e incrementa até encontrar um disponível
    tentativas = 0
    max_tentativas = 10000
    while db.query(ProdutoModel).filter(ProdutoModel.id == novo_id).first():
        proximo_numero += 1
        novo_id = f"PROD{proximo_numero:03d}"
        tentativas += 1
        if tentativas >= max_tentativas:
            # Fallback: usa timestamp se não conseguir encontrar ID disponível
            from datetime import datetime
            timestamp = datetime.now().strftime("%Y%m%d%H%M%S")
            novo_id = f"PROD{timestamp}"
            break

    return novo_id


@router.post("/", response_model=Produto, status_code=status.HTTP_201_CREATED)
def criar_produto(produto: ProdutoCreate, db: Session = Depends(get_db)):
    """
    Cria um novo produto. Se o ID não for fornecido, será gerado automaticamente.
    """
    # Se o ID não foi fornecido, gera automaticamente
    produto_id = produto.id
    if not produto_id or produto_id.strip() == "":
        produto_id = gerar_id_produto_unico(db)
    else:
        # Verifica se o produto já existe
        db_produto_existente = db.query(ProdutoModel).filter(ProdutoModel.id == produto_id).first()
        if db_produto_existente:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Produto com ID {produto_id} já existe"
            )
    
    db_produto = ProdutoModel(
        id=produto_id,
        lado_atual=produto.lado_atual,
        status=produto.status.value if produto.status else StatusProduto.PENDENTE.value
    )
    db.add(db_produto)
    db.commit()
    db.refresh(db_produto)
    return db_produto


@router.get("/", response_model=List[Produto])
def listar_produtos(
    skip: int = 0,
    limit: int = 100,
    status_filter: Optional[str] = None,
    db: Session = Depends(get_db)
):
    """
    Lista todos os produtos com paginação opcional
    """
    query = db.query(ProdutoModel)
    
    if status_filter:
        try:
            status_enum = StatusProduto(status_filter)
            query = query.filter(ProdutoModel.status == status_enum.value)
        except ValueError:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Status inválido: {status_filter}"
            )
    
    produtos = query.offset(skip).limit(limit).all()
    return produtos


@router.get("/{produto_id}", response_model=Produto)
def obter_produto(produto_id: str, db: Session = Depends(get_db)):
    """
    Obtém um produto específico por ID
    """
    produto = db.query(ProdutoModel).filter(ProdutoModel.id == produto_id).first()
    if not produto:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Produto com ID {produto_id} não encontrado"
        )
    return produto


@router.put("/{produto_id}", response_model=Produto)
def atualizar_produto(
    produto_id: str,
    produto_update: ProdutoUpdate,
    db: Session = Depends(get_db)
):
    """
    Atualiza um produto existente
    """
    db_produto = db.query(ProdutoModel).filter(ProdutoModel.id == produto_id).first()
    if not db_produto:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Produto com ID {produto_id} não encontrado"
        )
    
    if produto_update.lado_atual is not None:
        db_produto.lado_atual = produto_update.lado_atual
    if produto_update.status is not None:
        # Define novo status (pode ser enum ou string)
        novo_status = produto_update.status.value if hasattr(produto_update.status, 'value') else str(produto_update.status)
        db_produto.status = novo_status
        # Se o status NÃO for 'classificado', devemos "zerar" a classificação final e seu timestamp
        try:
            if novo_status != StatusProduto.CLASSIFICADO.value:
                db_produto.classificacao_final = None
                db_produto.timestamp_classificacao = None
        except Exception:
            # Em caso de qualquer incoerência com enums/valores, garante o reset por segurança
            db_produto.classificacao_final = None
            db_produto.timestamp_classificacao = None
    if produto_update.classificacao_final is not None:
        from ..schemas import TipoClassificacao
        db_produto.classificacao_final = produto_update.classificacao_final.value if hasattr(produto_update.classificacao_final, 'value') else str(produto_update.classificacao_final)
        from datetime import datetime
        db_produto.timestamp_classificacao = datetime.utcnow()
    
    db.commit()
    db.refresh(db_produto)
    return db_produto


@router.delete("/{produto_id}")
def deletar_produto(produto_id: str, db: Session = Depends(get_db)):
    """
    Deleta um produto
    """
    db_produto = db.query(ProdutoModel).filter(ProdutoModel.id == produto_id).first()
    if not db_produto:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Produto com ID {produto_id} não encontrado"
        )
    # Busca inspeções relacionadas para coletar informações (ex: câmeras afetadas)
    inspecoes = db.query(InspecaoModel).filter(InspecaoModel.produto_id == produto_id).all()
    ins_deleted = len(inspecoes)

    # Conta por câmera para atualizar CameraStatus.total_capturas
    camera_counts = {}
    for ins in inspecoes:
        cam = ins.camera_id or None
        if cam:
            camera_counts[cam] = camera_counts.get(cam, 0) + 1

    # Remove inspeções (depois de coletar dados)
    try:
        db.query(InspecaoModel).filter(InspecaoModel.produto_id == produto_id).delete(synchronize_session=False)
    except Exception:
        # se falhar, ins_deleted permanece informativo mas não abortamos
        pass

    # Remove classificações relacionadas (conta antes)
    try:
        cls_deleted = db.query(ClassificacaoModel).filter(ClassificacaoModel.produto_id == produto_id).count()
        db.query(ClassificacaoModel).filter(ClassificacaoModel.produto_id == produto_id).delete(synchronize_session=False)
    except Exception:
        cls_deleted = 0

    # Atualiza contagens da câmera conforme deletas as inspeções
    camera_updates = []
    try:
        for cam_id, dec in camera_counts.items():
            cam_stat = db.query(CameraStatusModel).filter(CameraStatusModel.camera_id == cam_id).first()
            if cam_stat and isinstance(cam_stat.total_capturas, int):
                original = cam_stat.total_capturas
                cam_stat.total_capturas = max(0, original - dec)
                camera_updates.append({"camera_id": cam_id, "decrement": dec, "original": original, "new": cam_stat.total_capturas})
    except Exception:
        # ignore camera update errors
        pass

    # Atualiza contagem na esteira (se houver registro para o lado do produto)
    try:
        lado = db_produto.lado_atual
        if lado:
            esteira = db.query(EsteiraStatusModel).filter(EsteiraStatusModel.nome == lado).first()
            if esteira and isinstance(esteira.quantidade_produtos, int) and esteira.quantidade_produtos > 0:
                esteira.quantidade_produtos = max(0, esteira.quantidade_produtos - 1)
    except Exception:
        # Não é crítico; apenas ignora se não for possível atualizar
        pass

    # Finalmente, deleta o produto
    db.delete(db_produto)
    db.commit()

    # Retorna objeto detalhado
    from ..schemas import DeleteResult
    return DeleteResult(
        message=f"Produto {produto_id} deletado com sucesso",
        success=True,
        inspecoes_deleted=ins_deleted,
        classificacoes_deleted=cls_deleted,
        camera_updates=camera_updates if camera_updates else None
    )

