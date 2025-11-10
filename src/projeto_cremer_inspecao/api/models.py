"""
Modelos de banco de dados (SQLAlchemy)
"""

from sqlalchemy import Column, Integer, String, Float, DateTime, Text, ForeignKey
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from datetime import datetime
import enum

from .database import Base


class StatusProduto(str, enum.Enum):
    """Status do produto"""
    PENDENTE = "pendente"
    EM_INSPECAO = "em_inspecao"
    INSPECIONADO = "inspecionado"
    CLASSIFICADO = "classificado"


class TipoClassificacao(str, enum.Enum):
    """Tipo de classificação"""
    APROVADO = "aprovado"
    REPROCESSAR = "reprocessar"
    SEGREGAR = "segregar"
    PENDENTE = "pendente"


class LadoInspecao(str, enum.Enum):
    """Lado da inspeção"""
    SUPERIOR = "superior"
    INFERIOR = "inferior"


class Produto(Base):
    """Modelo de Produto (Campo Cirúrgico)"""
    __tablename__ = "produtos"
    
    id = Column(String, primary_key=True, index=True)
    lado_atual = Column(String, nullable=False)  # "superior" ou "inferior"
    status = Column(String, default=StatusProduto.PENDENTE.value)
    classificacao_final = Column(String, nullable=True)
    timestamp_entrada = Column(DateTime, default=func.now())
    timestamp_classificacao = Column(DateTime, nullable=True)
    created_at = Column(DateTime, default=func.now())
    updated_at = Column(DateTime, default=func.now(), onupdate=func.now())
    
    # Relacionamentos
    inspecoes = relationship("Inspecao", back_populates="produto", cascade="all, delete-orphan")
    classificacoes = relationship("Classificacao", back_populates="produto", cascade="all, delete-orphan")
    
    def __repr__(self):
        return f"<Produto(id={self.id}, status={self.status}, classificacao={self.classificacao_final})>"


class Inspecao(Base):
    """Modelo de Inspeção"""
    __tablename__ = "inspecoes"
    
    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    produto_id = Column(String, ForeignKey("produtos.id"), nullable=False, index=True)
    lado = Column(String, nullable=False)  # "superior" ou "inferior"
    camera_id = Column(String, nullable=False)
    qualidade = Column(Float, nullable=False)  # 0.0 a 1.0
    imagem_path = Column(String, nullable=True)
    defeitos_detectados = Column(Text, nullable=True)  # JSON string
    metadados = Column(Text, nullable=True)  # JSON string
    timestamp = Column(DateTime, default=func.now())
    created_at = Column(DateTime, default=func.now())
    
    # Relacionamentos
    produto = relationship("Produto", back_populates="inspecoes")
    
    def __repr__(self):
        return f"<Inspecao(id={self.id}, produto_id={self.produto_id}, lado={self.lado}, qualidade={self.qualidade})>"


class Classificacao(Base):
    """Modelo de Classificação"""
    __tablename__ = "classificacoes"
    
    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    produto_id = Column(String, ForeignKey("produtos.id"), nullable=False, index=True)
    classificacao = Column(String, nullable=False)  # "aprovado", "reprocessar", "segregar", "pendente"
    confianca = Column(Float, nullable=False)  # 0.0 a 1.0
    motivo = Column(Text, nullable=True)
    criterios_avaliados = Column(Text, nullable=True)  # JSON string
    recomendacoes = Column(Text, nullable=True)  # JSON string
    timestamp = Column(DateTime, default=func.now())
    created_at = Column(DateTime, default=func.now())
    
    # Relacionamentos
    produto = relationship("Produto", back_populates="classificacoes")
    
    def __repr__(self):
        return f"<Classificacao(id={self.id}, produto_id={self.produto_id}, classificacao={self.classificacao}, confianca={self.confianca})>"


class EsteiraStatus(Base):
    """Modelo de Status da Esteira"""
    __tablename__ = "esteira_status"
    
    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    nome = Column(String, nullable=False, unique=True, index=True)  # "superior" ou "inferior"
    status = Column(String, nullable=False)  # "parada", "movendo", "pausada", "erro"
    velocidade = Column(Float, nullable=False)
    comprimento = Column(Float, nullable=False)
    quantidade_produtos = Column(Integer, default=0)
    updated_at = Column(DateTime, default=func.now(), onupdate=func.now())
    
    def __repr__(self):
        return f"<EsteiraStatus(nome={self.nome}, status={self.status}, produtos={self.quantidade_produtos})>"


class CameraStatus(Base):
    """Modelo de Status da Câmera"""
    __tablename__ = "camera_status"
    
    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    camera_id = Column(String, nullable=False, unique=True, index=True)
    posicao = Column(String, nullable=False)  # "superior", "inferior", "lateral"
    status = Column(String, nullable=False)  # "disponivel", "capturando", "processando", "erro", "offline"
    calibrada = Column(String, default="false")  # "true" ou "false"
    resolucao_largura = Column(Integer, nullable=True)
    resolucao_altura = Column(Integer, nullable=True)
    total_capturas = Column(Integer, default=0)
    updated_at = Column(DateTime, default=func.now(), onupdate=func.now())
    
    def __repr__(self):
        return f"<CameraStatus(camera_id={self.camera_id}, status={self.status}, capturas={self.total_capturas})>"


class InversorStatus(Base):
    """Modelo de Status do Inversor"""
    __tablename__ = "inversor_status"
    
    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    inversor_id = Column(String, nullable=False, unique=True, index=True)
    status = Column(String, nullable=False)  # "disponivel", "invertendo", "erro", "manutencao", "offline"
    calibrado = Column(String, default="false")  # "true" ou "false"
    tempo_inversao = Column(Float, nullable=False)
    total_inversoes = Column(Integer, default=0)
    updated_at = Column(DateTime, default=func.now(), onupdate=func.now())
    
    def __repr__(self):
        return f"<InversorStatus(inversor_id={self.inversor_id}, status={self.status}, inversoes={self.total_inversoes})>"

