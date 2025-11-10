import urllib.request, urllib.error, json, time

BASE = 'http://127.0.0.1:8000'

def wait_health(timeout=20):
    deadline = time.time() + timeout
    while time.time() < deadline:
        try:
            r = urllib.request.urlopen(f'{BASE}/health', timeout=2)
            data = json.loads(r.read().decode())
            if data.get('status') == 'healthy':
                print('health ok')
                return True
        except Exception as e:
            # print('waiting for server...', e)
            time.sleep(0.5)
    return False


def http_post(path, payload):
    data = json.dumps(payload).encode('utf-8')
    req = urllib.request.Request(f'{BASE}{path}', data=data, headers={'Content-Type':'application/json'})
    with urllib.request.urlopen(req) as r:
        return json.loads(r.read().decode())


def http_get(path):
    with urllib.request.urlopen(f'{BASE}{path}') as r:
        return json.loads(r.read().decode())


def run_test():
    if not wait_health(20):
        print('server did not start')
        return

    # Cria produto
    prod = http_post('/produtos/', {'lado_atual':'superior', 'status':'pendente'})
    pid = prod.get('id')
    print('created product', pid)

    # Cria duas inspecoes para a mesma camera
    ins1 = http_post('/inspecoes/', {'produto_id': pid, 'lado':'superior', 'camera_id':'cam-test-1', 'qualidade': 0.9})
    ins2 = http_post('/inspecoes/', {'produto_id': pid, 'lado':'superior', 'camera_id':'cam-test-1', 'qualidade': 0.7})
    print('created inspecoes', ins1.get('id'), ins2.get('id'))

    # Cria classificacao
    cls = http_post('/classificacoes/', {'produto_id': pid, 'classificacao':'aprovado', 'confianca':0.95})
    print('created classificacao', cls.get('id'))

    # Deleta produto
    req = urllib.request.Request(f'{BASE}/produtos/{pid}', method='DELETE')
    with urllib.request.urlopen(req) as r:
        res = json.loads(r.read().decode())
    print('delete response:', res)

if __name__ == '__main__':
    run_test()
