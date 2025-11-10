"""Módulos do sistema de inspeção"""

from .esteira import Esteira, Produto, StatusEsteira
from .camera_inspecao import CameraInspecao, ResultadoInspecao, StatusCamera
from .inversor import Inversor, DirecaoInversao, ResultadoInversao, StatusInversor
from .classificador import Classificador, Classificacao, ResultadoClassificacao

__all__ = [
    'Esteira', 
    'Produto', 
    'StatusEsteira',
    'CameraInspecao', 
    'ResultadoInspecao',
    'StatusCamera',
    'Inversor', 
    'DirecaoInversao',
    'ResultadoInversao',
    'StatusInversor',
    'Classificador',
    'Classificacao',
    'ResultadoClassificacao'
]

