"""
Módulo de Controle de Esteiras
Simula o controle das esteiras superior e inferior do sistema
"""

import time
from enum import Enum
from typing import Optional, List
from dataclasses import dataclass


class StatusEsteira(Enum):
    """Status da esteira"""
    PARADA = "parada"
    MOVENDO = "movendo"
    PAUSADA = "pausada"
    ERRO = "erro"


@dataclass
class Produto:
    """Representa um campo cirúrgico (produto) no sistema"""
    id: str
    lado_atual: str  # "superior" ou "inferior"
    lado_inspecionado_1: Optional[dict] = None
    lado_inspecionado_2: Optional[dict] = None
    classificacao: Optional[str] = None
    timestamp_entrada: Optional[float] = None


class Esteira:
    """Classe para controle de esteira transportadora"""
    
    def __init__(self, nome: str, velocidade: float = 1.0, comprimento: float = 10.0):
        """
        Inicializa uma esteira
        
        Args:
            nome: Nome da esteira (ex: "superior", "inferior")
            velocidade: Velocidade da esteira em m/s
            comprimento: Comprimento da esteira em metros
        """
        self.nome = nome
        self.velocidade = velocidade
        self.comprimento = comprimento
        self.status = StatusEsteira.PARADA
        self.produtos: List[Produto] = []
        self.posicao_produtos: dict = {}  # {id_produto: posicao_na_esteira}
        self.pressao_uniforme = True  # Controle de pressão uniforme
        
    def iniciar(self):
        """Inicia a esteira"""
        self.status = StatusEsteira.MOVENDO
        print(f"Esteira {self.nome}: INICIADA")
        
    def parar(self):
        """Para a esteira"""
        self.status = StatusEsteira.PARADA
        print(f"Esteira {self.nome}: PARADA")
        
    def pausar(self):
        """Pausa a esteira"""
        self.status = StatusEsteira.PAUSADA
        print(f"Esteira {self.nome}: PAUSADA")
        
    def adicionar_produto(self, produto: Produto, posicao: float = 0.0):
        """
        Adiciona um produto à esteira
        
        Args:
            produto: Objeto Produto a ser adicionado
            posicao: Posição inicial na esteira (0 = início)
        """
        produto.timestamp_entrada = time.time()
        self.produtos.append(produto)
        self.posicao_produtos[produto.id] = posicao
        produto.lado_atual = self.nome
        print(f"Esteira {self.nome}: Produto {produto.id} adicionado na posição {posicao:.2f}m")
        
    def remover_produto(self, produto_id: str) -> Optional[Produto]:
        """
        Remove um produto da esteira
        
        Args:
            produto_id: ID do produto a ser removido
            
        Returns:
            Produto removido ou None se não encontrado
        """
        produto = next((p for p in self.produtos if p.id == produto_id), None)
        if produto:
            self.produtos.remove(produto)
            del self.posicao_produtos[produto_id]
            print(f"Esteira {self.nome}: Produto {produto_id} removido")
        return produto
        
    def atualizar_posicoes(self, delta_tempo: float):
        """
        Atualiza as posições dos produtos na esteira
        
        Args:
            delta_tempo: Tempo decorrido em segundos
        """
        if self.status != StatusEsteira.MOVENDO:
            return
            
        for produto_id, posicao in self.posicao_produtos.items():
            nova_posicao = posicao + (self.velocidade * delta_tempo)
            self.posicao_produtos[produto_id] = nova_posicao
            
    def obter_produto_na_posicao(self, posicao: float, tolerancia: float = 0.1) -> Optional[Produto]:
        """
        Obtém o produto em uma determinada posição
        
        Args:
            posicao: Posição na esteira
            tolerancia: Tolerância para encontrar o produto
            
        Returns:
            Produto encontrado ou None
        """
        for produto in self.produtos:
            pos_produto = self.posicao_produtos.get(produto.id, -1)
            if abs(pos_produto - posicao) <= tolerancia:
                return produto
        return None
        
    def verificar_sincronizacao(self, outra_esteira: 'Esteira') -> bool:
        """
        Verifica se a sincronização com outra esteira está adequada
        (importante para evitar rugas na curva)
        
        Args:
            outra_esteira: Outra esteira para comparar
            
        Returns:
            True se sincronizada, False caso contrário
        """
        if self.status != outra_esteira.status:
            return False
        if abs(self.velocidade - outra_esteira.velocidade) > 0.01:
            return False
        if not self.pressao_uniforme or not outra_esteira.pressao_uniforme:
            return False
        return True
        
    def obter_produtos_no_fim(self, distancia_fim: float = 0.5) -> List[Produto]:
        """
        Obtém produtos próximos ao fim da esteira
        
        Args:
            distancia_fim: Distância do fim para considerar (em metros)
            
        Returns:
            Lista de produtos próximos ao fim
        """
        produtos_fim = []
        for produto in self.produtos:
            posicao = self.posicao_produtos.get(produto.id, 0)
            if posicao >= (self.comprimento - distancia_fim):
                produtos_fim.append(produto)
        return produtos_fim
        
    def __str__(self):
        return f"Esteira {self.nome}: {self.status.value} | {len(self.produtos)} produtos | Vel: {self.velocidade}m/s"

