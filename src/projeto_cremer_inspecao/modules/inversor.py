"""
Módulo de Inversor de Produtos
Responsável por controlar o mecanismo de inversão dos campos cirúrgicos
"""

import time
from enum import Enum
from typing import Optional
from dataclasses import dataclass


class StatusInversor(Enum):
    """Status do inversor"""
    DISPONIVEL = "disponivel"
    INVERTENDO = "invertendo"
    ERRO = "erro"
    MANUTENCAO = "manutencao"
    OFFLINE = "offline"


class DirecaoInversao(Enum):
    """Direção de inversão"""
    SUPERIOR_PARA_INFERIOR = "superior_para_inferior"
    INFERIOR_PARA_SUPERIOR = "inferior_para_superior"


@dataclass
class ResultadoInversao:
    """Resultado de uma operação de inversão"""
    sucesso: bool
    produto_id: str
    tempo_inversao: float
    timestamp: float
    mensagem: Optional[str] = None
    erro: Optional[str] = None


class Inversor:
    """Classe para controle do mecanismo de inversão"""
    
    def __init__(self, id_inversor: str, tempo_inversao: float = 2.0):
        """
        Inicializa o inversor
        
        Args:
            id_inversor: Identificador único do inversor
            tempo_inversao: Tempo necessário para completar a inversão (segundos)
        """
        self.id_inversor = id_inversor
        self.tempo_inversao = tempo_inversao
        self.status = StatusInversor.OFFLINE
        self.ultima_inversao: Optional[ResultadoInversao] = None
        self.contador_inversoes = 0
        self.calibrado = False
        
    def conectar(self) -> bool:
        """
        Conecta ao inversor
        
        Returns:
            True se conectado com sucesso, False caso contrário
        """
        try:
            # Simulação de conexão
            self.status = StatusInversor.DISPONIVEL
            print(f"Inversor {self.id_inversor}: CONECTADO")
            return True
        except Exception as e:
            self.status = StatusInversor.ERRO
            print(f"Erro ao conectar inversor {self.id_inversor}: {e}")
            return False
    
    def desconectar(self):
        """Desconecta o inversor"""
        self.status = StatusInversor.OFFLINE
        print(f"Inversor {self.id_inversor}: DESCONECTADO")
    
    def calibrar(self) -> bool:
        """
        Calibra o inversor
        
        Returns:
            True se calibração bem-sucedida
        """
        try:
            # Simulação de calibração
            self.calibrado = True
            print(f"Inversor {self.id_inversor}: CALIBRADO")
            return True
        except Exception as e:
            print(f"Erro na calibração do inversor {self.id_inversor}: {e}")
            return False
    
    def inverter_produto(
        self, 
        produto_id: str, 
        direcao: DirecaoInversao = DirecaoInversao.SUPERIOR_PARA_INFERIOR,
        timeout: float = 10.0
    ) -> ResultadoInversao:
        """
        Inverte um produto da esteira superior para inferior ou vice-versa
        
        Args:
            produto_id: ID do produto a ser invertido
            direcao: Direção da inversão
            timeout: Timeout máximo para a operação (segundos)
            
        Returns:
            ResultadoInversao com informações da operação
        """
        if self.status != StatusInversor.DISPONIVEL:
            erro_msg = f"Inversor {self.id_inversor} não está disponível. Status: {self.status.value}"
            print(erro_msg)
            return ResultadoInversao(
                sucesso=False,
                produto_id=produto_id,
                tempo_inversao=0.0,
                timestamp=time.time(),
                erro=erro_msg
            )
        
        if not self.calibrado:
            erro_msg = f"Inversor {self.id_inversor} não está calibrado"
            print(erro_msg)
            return ResultadoInversao(
                sucesso=False,
                produto_id=produto_id,
                tempo_inversao=0.0,
                timestamp=time.time(),
                erro=erro_msg
            )
        
        try:
            inicio = time.time()
            self.status = StatusInversor.INVERTENDO
            
            direcao_str = "superior -> inferior" if direcao == DirecaoInversao.SUPERIOR_PARA_INFERIOR else "inferior -> superior"
            print(f"Inversor {self.id_inversor}: Invertendo produto {produto_id} ({direcao_str})")
            
            # Simulação do processo de inversão
            # Em uma implementação real, aqui seria controlado o mecanismo físico
            time.sleep(self.tempo_inversao)
            
            tempo_decorrido = time.time() - inicio
            
            if tempo_decorrido > timeout:
                self.status = StatusInversor.ERRO
                erro_msg = f"Timeout na inversão do produto {produto_id}"
                print(erro_msg)
                return ResultadoInversao(
                    sucesso=False,
                    produto_id=produto_id,
                    tempo_inversao=tempo_decorrido,
                    timestamp=time.time(),
                    erro=erro_msg
                )
            
            self.status = StatusInversor.DISPONIVEL
            self.contador_inversoes += 1
            
            resultado = ResultadoInversao(
                sucesso=True,
                produto_id=produto_id,
                tempo_inversao=tempo_decorrido,
                timestamp=time.time(),
                mensagem=f"Produto {produto_id} invertido com sucesso"
            )
            
            self.ultima_inversao = resultado
            print(f"Inversor {self.id_inversor}: Inversão concluída em {tempo_decorrido:.2f}s")
            
            return resultado
            
        except Exception as e:
            self.status = StatusInversor.ERRO
            erro_msg = f"Erro ao inverter produto {produto_id}: {e}"
            print(erro_msg)
            return ResultadoInversao(
                sucesso=False,
                produto_id=produto_id,
                tempo_inversao=0.0,
                timestamp=time.time(),
                erro=erro_msg
            )
    
    def verificar_disponibilidade(self) -> bool:
        """
        Verifica se o inversor está disponível para operação
        
        Returns:
            True se disponível, False caso contrário
        """
        return (
            self.status == StatusInversor.DISPONIVEL and
            self.calibrado
        )
    
    def obter_estatisticas(self) -> dict:
        """
        Obtém estatísticas do inversor
        
        Returns:
            Dicionário com estatísticas
        """
        return {
            "id_inversor": self.id_inversor,
            "status": self.status.value,
            "calibrado": self.calibrado,
            "total_inversoes": self.contador_inversoes,
            "tempo_medio_inversao": self.tempo_inversao,
            "ultima_inversao": self.ultima_inversao.timestamp if self.ultima_inversao else None
        }
    
    def entrar_manutencao(self):
        """Coloca o inversor em modo manutenção"""
        self.status = StatusInversor.MANUTENCAO
        print(f"Inversor {self.id_inversor}: Em manutenção")
    
    def sair_manutencao(self):
        """Remove o inversor do modo manutenção"""
        self.status = StatusInversor.DISPONIVEL
        print(f"Inversor {self.id_inversor}: Fora de manutenção")
    
    def resetar_erro(self):
        """Reseta o estado de erro do inversor"""
        if self.status == StatusInversor.ERRO:
            self.status = StatusInversor.DISPONIVEL
            print(f"Inversor {self.id_inversor}: Estado de erro resetado")
            return True
        return False
    
    def __str__(self):
        status_str = f"{self.status.value}"
        calibrado_str = "calibrado" if self.calibrado else "não calibrado"
        return f"Inversor {self.id_inversor}: {status_str} | {calibrado_str} | {self.contador_inversoes} inversões"

