"""
Script para inicializar o banco de dados
"""

import sys
from pathlib import Path

# Adicionar o diretório src ao caminho
sys.path.insert(0, str(Path(__file__).parent / "src"))

from projeto_cremer_inspecao.api.database import init_db
from projeto_cremer_inspecao.api.database import SessionLocal
from projeto_cremer_inspecao.api import models

if __name__ == "__main__":
    print("Inicializando banco de dados...")
    init_db()
    print("Banco de dados inicializado com sucesso!")
    # Insere câmeras padrão se não existirem
    db = SessionLocal()
    try:
        # Verifica se Camera 1 existe (usar id CAM001) - mantemos compatibilidade com demos
        cam1 = db.query(models.CameraStatus).filter(models.CameraStatus.camera_id == 'CAM001').first()
        if not cam1:
            cam1 = models.CameraStatus(
                camera_id='CAM001',
                posicao='superior',
                status='disponivel',
                calibrada='false',
                resolucao_largura=1920,
                resolucao_altura=1080,
                total_capturas=0
            )
            db.add(cam1)
            print('=> Camera CAM001 adicionada')

        # Adiciona Camera 2 para o lado inferior se não existir
        cam2 = db.query(models.CameraStatus).filter(models.CameraStatus.camera_id == 'CAM002').first()
        if not cam2:
            cam2 = models.CameraStatus(
                camera_id='CAM002',
                posicao='inferior',
                status='disponivel',
                calibrada='false',
                resolucao_largura=1920,
                resolucao_altura=1080,
                total_capturas=0
            )
            db.add(cam2)
            print('=> Camera CAM002 (inferior) adicionada')

        db.commit()
    except Exception as e:
        db.rollback()
        print('Erro ao inserir câmeras padrão:', e)
    finally:
        db.close()

