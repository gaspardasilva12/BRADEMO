from fastapi.testclient import TestClient
from projeto_cremer_inspecao.api.main import app
import json

client = TestClient(app)

# Create product
r = client.post('/produtos/', json={'lado_atual':'superior','status':'pendente'})
print('POST /produtos', r.status_code, r.json())
pid = r.json().get('id')

# Create inspections
r1 = client.post('/inspecoes/', json={'produto_id': pid, 'lado':'superior','camera_id':'cam-test-1','qualidade':0.9})
print('POST /inspecoes 1', r1.status_code, r1.json())
r2 = client.post('/inspecoes/', json={'produto_id': pid, 'lado':'superior','camera_id':'cam-test-1','qualidade':0.7})
print('POST /inspecoes 2', r2.status_code, r2.json())

# Create classification
rc = client.post('/classificacoes/', json={'produto_id': pid, 'classificacao':'aprovado', 'confianca':0.95})
print('POST /classificacoes', rc.status_code, rc.json())

# Delete product
rd = client.delete(f'/produtos/{pid}')
print('DELETE /produtos', rd.status_code, rd.json())
