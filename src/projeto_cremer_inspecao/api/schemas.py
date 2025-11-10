"""
Schemas Pydantic para validação de dados da API
"""

from pydantic import BaseModel, Field, field_validator, ConfigDict
from typing import Optional, List, Dict, Any, Union
from datetime import datetime
from enum import Enum


class StatusProduto(str, Enum):
    """Status do produto"""
    PENDENTE = "pendente"
    EM_INSPECAO = "em_inspecao"
    INSPECIONADO = "inspecionado"
    CLASSIFICADO = "classificado"


class TipoClassificacao(str, Enum):
    """Tipo de classificação"""
    APROVADO = "aprovado"
    REPROCESSAR = "reprocessar"
    SEGREGAR = "segregar"
    PENDENTE = "pendente"


class LadoInspecao(str, Enum):
    """Lado da inspeção"""
    SUPERIOR = "superior"
    INFERIOR = "inferior"


# Schemas de Produto
class ProdutoBase(BaseModel):
    """Schema base de Produto"""
    id: str
    lado_atual: str = Field(..., description="Lado atual: 'superior' ou 'inferior'")
    status: Optional[StatusProduto] = StatusProduto.PENDENTE


class ProdutoCreate(BaseModel):
    """Schema para criar produto - ID é opcional, será gerado automaticamente se não fornecido"""
    id: Optional[str] = Field(None, description="ID do produto (opcional, será gerado automaticamente se não fornecido)")
    lado_atual: str = Field(..., description="Lado atual: 'superior' ou 'inferior'")
    status: Optional[StatusProduto] = StatusProduto.PENDENTE


class ProdutoUpdate(BaseModel):
    """Schema para atualizar produto"""
    lado_atual: Optional[str] = None
    status: Optional[StatusProduto] = None
    classificacao_final: Optional[TipoClassificacao] = None


class Produto(ProdutoBase):
    """Schema de Produto completo"""
    classificacao_final: Optional[TipoClassificacao] = None
    timestamp_entrada: Optional[datetime] = None
    timestamp_classificacao: Optional[datetime] = None
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None
    
    class Config:
        from_attributes = True


# Schemas de Inspeção
class InspecaoBase(BaseModel):
    """Schema base de Inspeção"""
    produto_id: str
    lado: LadoInspecao
    camera_id: str
    qualidade: float = Field(..., ge=0.0, le=1.0, description="Qualidade de 0.0 a 1.0")
    imagem_path: Optional[str] = None
    defeitos_detectados: Optional[List[Dict[str, Any]]] = None
    metadados: Optional[Dict[str, Any]] = None


class InspecaoCreate(InspecaoBase):
    """Schema para criar inspeção"""
    pass


class Inspecao(BaseModel):
    """Schema de Inspeção completo"""
    id: int
    produto_id: str
    lado: Union[LadoInspecao, str]  # Aceita Enum ou string
    camera_id: str
    qualidade: float = Field(..., ge=0.0, le=1.0, description="Qualidade de 0.0 a 1.0")
    imagem_path: Optional[str] = None
    defeitos_detectados: Optional[List[Dict[str, Any]]] = None
    metadados: Optional[Dict[str, Any]] = None
    timestamp: Optional[datetime] = None
    created_at: Optional[datetime] = None
    
    model_config = ConfigDict(from_attributes=True)
    
    @field_validator('lado', mode='before')
    @classmethod
    def validate_lado(cls, v):
        if isinstance(v, str):
            return v
        if hasattr(v, 'value'):
            return v.value
        return str(v)


# Schemas de Classificação
class ClassificacaoBase(BaseModel):
    """Schema base de Classificação"""
    produto_id: str
    classificacao: TipoClassificacao
    confianca: float = Field(..., ge=0.0, le=1.0, description="Confiança de 0.0 a 1.0")
    motivo: Optional[str] = None
    criterios_avaliados: Optional[Dict[str, Any]] = None
    recomendacoes: Optional[List[str]] = None


class ClassificacaoCreate(ClassificacaoBase):
    """Schema para criar classificação"""
    pass


class Classificacao(BaseModel):
    """Schema de Classificação completo"""
    id: int
    produto_id: str
    classificacao: Union[TipoClassificacao, str]  # Aceita Enum ou string
    confianca: float = Field(..., ge=0.0, le=1.0, description="Confiança de 0.0 a 1.0")
    motivo: Optional[str] = None
    criterios_avaliados: Optional[Dict[str, Any]] = None
    recomendacoes: Optional[List[str]] = None
    timestamp: Optional[datetime] = None
    created_at: Optional[datetime] = None
    
    model_config = ConfigDict(from_attributes=True)
    
    @field_validator('classificacao', mode='before')
    @classmethod
    def validate_classificacao(cls, v):
        if isinstance(v, str):
            return v
        if hasattr(v, 'value'):
            return v.value
        return str(v)


# Schemas de Estatísticas
class Estatisticas(BaseModel):
    """Schema de Estatísticas"""
    total_classificados: int
    aprovados: int
    reprocessar: int
    segregados: int
    percentuais: Dict[str, float]


# Schemas de Status
class EsteiraStatusSchema(BaseModel):
    """Schema de Status da Esteira"""
    nome: str
    status: str
    velocidade: float
    comprimento: float
    quantidade_produtos: int
    updated_at: Optional[datetime] = None
    
    class Config:
        from_attributes = True


class CameraStatusSchema(BaseModel):
    """Schema de Status da Câmera"""
    camera_id: str
    posicao: str
    status: str
    calibrada: str
    resolucao_largura: Optional[int] = None
    resolucao_altura: Optional[int] = None
    total_capturas: int
    updated_at: Optional[datetime] = None
    
    class Config:
        from_attributes = True


class InversorStatusSchema(BaseModel):
    """Schema de Status do Inversor"""
    inversor_id: str
    status: str
    calibrado: str
    tempo_inversao: float
    total_inversoes: int
    updated_at: Optional[datetime] = None
    
    class Config:
        from_attributes = True


# Schema de Resposta de Mensagem
class Message(BaseModel):
    """Schema de mensagem de resposta"""
    message: str
    success: bool = True


# Schema para resultado de deleção
class DeleteResult(BaseModel):
    """Resultado detalhado da deleção de um recurso"""
    message: str
    success: bool = True
    inspecoes_deleted: int = 0
    classificacoes_deleted: int = 0
    camera_updates: Optional[List[Dict[str, Any]]] = None

