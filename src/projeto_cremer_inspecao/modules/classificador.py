"""
Módulo de Classificador
Responsável por classificar campos cirúrgicos com base nas inspeções
"""

from enum import Enum
from typing import Optional, List, Dict
from dataclasses import dataclass
import time


class Classificacao(Enum):
    """Classificação do produto"""
    APROVADO = "aprovado"
    REPROCESSAR = "reprocessar"
    SEGREGAR = "segregar"
    PENDENTE = "pendente"


@dataclass
class ResultadoClassificacao:
    """Resultado da classificação de um produto"""
    produto_id: str
    classificacao: Classificacao
    confianca: float  # 0.0 a 1.0
    motivo: str
    timestamp: float
    criterios_avaliados: Dict = None
    recomendacoes: List[str] = None
    
    def __post_init__(self):
        if self.criterios_avaliados is None:
            self.criterios_avaliados = {}
        if self.recomendacoes is None:
            self.recomendacoes = []


class Classificador:
    """Classe para classificação de produtos"""
    
    def __init__(self, id_classificador: str):
        """
        Inicializa o classificador
        
        Args:
            id_classificador: Identificador único do classificador
        """
        self.id_classificador = id_classificador
        self.estatisticas = {
            "total_classificados": 0,
            "aprovados": 0,
            "reprocessar": 0,
            "segregados": 0
        }
        self.criterios_padrao = self._inicializar_criterios()
        
    def _inicializar_criterios(self) -> Dict:
        """
        Inicializa os critérios de classificação padrão
        
        Returns:
            Dicionário com critérios de classificação
        """
        return {
            "qualidade_minima_aprovado": 0.9,
            "qualidade_minima_reprocessar": 0.7,
            "max_defeitos_leves": 2,
            "max_area_defeitos_leves": 0.05,  # 5% da área total
            "max_area_defeitos_graves": 0.01,  # 1% da área total
            "tipos_defeitos_graves": ["rasgo", "furo", "contaminacao"],
            "tipos_defeitos_leves": ["mancha", "dobra", "descoloracao"]
        }
    
    def atualizar_criterios(self, novos_criterios: Dict):
        """
        Atualiza os critérios de classificação
        
        Args:
            novos_criterios: Dicionário com novos critérios
        """
        self.criterios_padrao.update(novos_criterios)
        print(f"Classificador {self.id_classificador}: Critérios atualizados")
    
    def classificar_produto(
        self,
        produto_id: str,
        inspecao_lado_1: Optional[Dict],
        inspecao_lado_2: Optional[Dict],
        criterios: Optional[Dict] = None
    ) -> ResultadoClassificacao:
        """
        Classifica um produto com base nas inspeções realizadas
        
        Args:
            produto_id: ID do produto
            inspecao_lado_1: Resultado da inspeção do primeiro lado
            inspecao_lado_2: Resultado da inspeção do segundo lado
            criterios: Critérios de classificação (usa padrão se None)
            
        Returns:
            ResultadoClassificacao com a classificação do produto
        """
        if criterios is None:
            criterios = self.criterios_padrao
        
        # Verifica se ambas as inspeções foram realizadas
        if inspecao_lado_1 is None or inspecao_lado_2 is None:
            return ResultadoClassificacao(
                produto_id=produto_id,
                classificacao=Classificacao.PENDENTE,
                confianca=0.0,
                motivo="Inspeções incompletas - falta inspecionar um ou ambos os lados",
                timestamp=time.time(),
                criterios_avaliados={},
                recomendacoes=["Completar inspeção de ambos os lados"]
            )
        
        # Extrai informações das inspeções
        qualidade_lado_1 = inspecao_lado_1.get("qualidade", 0.0)
        qualidade_lado_2 = inspecao_lado_2.get("qualidade", 0.0)
        defeitos_lado_1 = inspecao_lado_1.get("defeitos_detectados", [])
        defeitos_lado_2 = inspecao_lado_2.get("defeitos_detectados", [])
        
        # Calcula qualidade média
        qualidade_media = (qualidade_lado_1 + qualidade_lado_2) / 2.0
        
        # Analisa defeitos
        todos_defeitos = defeitos_lado_1 + defeitos_lado_2
        defeitos_graves = [
            d for d in todos_defeitos
            if d.get("tipo", "").lower() in criterios["tipos_defeitos_graves"]
        ]
        defeitos_leves = [
            d for d in todos_defeitos
            if d.get("tipo", "").lower() in criterios["tipos_defeitos_leves"]
        ]
        
        # Calcula área total de defeitos
        area_total_defeitos = sum(d.get("area", 0) for d in todos_defeitos)
        # Assumindo uma área padrão do produto (pode ser configurável)
        area_produto_padrao = 10000  # cm² (exemplo)
        percentual_area_defeitos = area_total_defeitos / area_produto_padrao
        
        # Classifica o produto
        classificacao, confianca, motivo, recomendacoes = self._determinar_classificacao(
            qualidade_media,
            defeitos_graves,
            defeitos_leves,
            percentual_area_defeitos,
            criterios
        )
        
        criterios_avaliados = {
            "qualidade_media": qualidade_media,
            "qualidade_lado_1": qualidade_lado_1,
            "qualidade_lado_2": qualidade_lado_2,
            "total_defeitos": len(todos_defeitos),
            "defeitos_graves": len(defeitos_graves),
            "defeitos_leves": len(defeitos_leves),
            "percentual_area_defeitos": percentual_area_defeitos
        }
        
        resultado = ResultadoClassificacao(
            produto_id=produto_id,
            classificacao=classificacao,
            confianca=confianca,
            motivo=motivo,
            timestamp=time.time(),
            criterios_avaliados=criterios_avaliados,
            recomendacoes=recomendacoes
        )
        
        # Atualizar estatísticas (apenas para classificações finais, não para "pendente")
        if classificacao != Classificacao.PENDENTE:
            self.estatisticas["total_classificados"] += 1
            
            # Mapear valores da enumeração para chaves do dicionário de estatísticas
            mapeamento_estatisticas = {
                Classificacao.APROVADO: "aprovados",
                Classificacao.REPROCESSAR: "reprocessar",
                Classificacao.SEGREGAR: "segregados"
            }
            
            chave_estatistica = mapeamento_estatisticas.get(classificacao)
            if chave_estatistica:
                self.estatisticas[chave_estatistica] += 1
        
        return resultado
    
    def _determinar_classificacao(
        self,
        qualidade_media: float,
        defeitos_graves: List[Dict],
        defeitos_leves: List[Dict],
        percentual_area_defeitos: float,
        criterios: Dict
    ) -> tuple:
        """
        Determina a classificação com base nos critérios
        
        Returns:
            Tupla (classificacao, confianca, motivo, recomendacoes)
        """
        motivo = []
        recomendacoes = []
        confianca = 1.0
        
        # Verificar defeitos graves - sempre segregar
        if len(defeitos_graves) > 0: # Se houver defeitos graves, sempre segregar
            motivo.append(f"Defeitos graves detectados: {len(defeitos_graves)}")
            recomendacoes.append("Produto deve ser segregado devido a defeitos graves")
            return (Classificacao.SEGREGAR, 0.95, "; ".join(motivo), recomendacoes)
        
        # Verificar área de defeitos graves
        if percentual_area_defeitos > criterios["max_area_defeitos_graves"]:
            motivo.append(f"Área de defeitos excede limite: {percentual_area_defeitos:.2%}")
            recomendacoes.append("Produto deve ser segregado devido à extensão dos defeitos")
            confianca = 0.9
            return (Classificacao.SEGREGAR, confianca, "; ".join(motivo), recomendacoes)
        
        # Verificar qualidade mínima para aprovação
        if qualidade_media >= criterios["qualidade_minima_aprovado"]:
            # Verificar se não há muitos defeitos leves
            if len(defeitos_leves) <= criterios["max_defeitos_leves"]:
                if percentual_area_defeitos <= criterios["max_area_defeitos_leves"]:
                    motivo.append(f"Qualidade excelente ({qualidade_media:.2%}) e defeitos dentro dos limites")
                    return (Classificacao.APROVADO, 0.95, "; ".join(motivo), recomendacoes)
        
        # Verificar se pode reprocessar
        if qualidade_media >= criterios["qualidade_minima_reprocessar"]:
            if len(defeitos_leves) > criterios["max_defeitos_leves"]:
                motivo.append(f"Qualidade adequada ({qualidade_media:.2%}) mas muitos defeitos leves: {len(defeitos_leves)}")
                recomendacoes.append("Produto pode ser reprocessado para remover defeitos leves")
                confianca = 0.85
                return (Classificacao.REPROCESSAR, confianca, "; ".join(motivo), recomendacoes)
            
            if percentual_area_defeitos > criterios["max_area_defeitos_leves"]:
                motivo.append(f"Qualidade adequada mas área de defeitos elevada: {percentual_area_defeitos:.2%}")
                recomendacoes.append("Produto pode ser reprocessado para melhorar qualidade")
                confianca = 0.80
                return (Classificacao.REPROCESSAR, confianca, "; ".join(motivo), recomendacoes)
        
        # Se não se encaixa em nenhuma categoria acima, mas qualidade é razoável, reprocessar
        if qualidade_media >= 0.6:
            motivo.append(f"Qualidade abaixo do ideal ({qualidade_media:.2%})")
            recomendacoes.append("Produto requer reprocessamento")
            confianca = 0.75
            return (Classificacao.REPROCESSAR, confianca, "; ".join(motivo), recomendacoes)
        
        # Qualidade muito baixa ou muitos defeitos - sempre segregar
        motivo.append(f"Qualidade muito baixa ({qualidade_media:.2%}) ou muitos defeitos")
        recomendacoes.append("Produto deve ser segregado")
        confianca = 0.90
        return (Classificacao.SEGREGAR, confianca, "; ".join(motivo), recomendacoes)
    
    def obter_estatisticas(self) -> Dict:
        """
        Obter estatísticas de classificação
        
        Returns:
            Dicionário com estatísticas
        """
        total = self.estatisticas["total_classificados"]
        if total == 0:
            percentuais = {}
        else:
            percentuais = {
                "aprovados": (self.estatisticas["aprovados"] / total) * 100,
                "reprocessar": (self.estatisticas["reprocessar"] / total) * 100,
                "segregados": (self.estatisticas["segregados"] / total) * 100
            }
        
        return {
            **self.estatisticas,
            "percentuais": percentuais
        }
    
    def resetar_estatisticas(self):
        """Reseta as estatísticas do classificador"""
        self.estatisticas = {
            "total_classificados": 0,
            "aprovados": 0,
            "reprocessar": 0,
            "segregados": 0
        }
        print(f"Classificador {self.id_classificador}: Estatísticas resetadas")
    
    def __str__(self):
        stats = self.obter_estatisticas()
        return f"Classificador {self.id_classificador}: {stats['total_classificados']} produtos classificados | " \
               f"Aprovados: {stats['aprovados']} | Reprocessar: {stats['reprocessar']} | Segregados: {stats['segregados']}"

