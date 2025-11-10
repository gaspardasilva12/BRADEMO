"""
Endpoints para gerenciar/listar câmeras
"""

from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from typing import List

from ..database import get_db
from ..schemas import CameraStatusSchema
from ..models import CameraStatus as CameraStatusModel

router = APIRouter(prefix="/cameras", tags=["cameras"])


@router.get("/", response_model=List[CameraStatusSchema])
def listar_cameras(db: Session = Depends(get_db)):
    """Retorna o status de todas as câmeras registradas"""
    rows = db.query(CameraStatusModel).all()
    resultado = []
    for r in rows:
        resultado.append(r)
    return resultado
