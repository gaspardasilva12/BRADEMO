// Configuração da API
const API_BASE_URL = window.location.origin;
let updateInterval = null;
let charts = {};
let pendingDeleteId = null;

// Inicialização
document.addEventListener('DOMContentLoaded', function() {
    initializeNavigation();
    initializeModals();
    loadData();
    startAutoUpdate();
});

// Navegação
function initializeNavigation() {
    const navLinks = document.querySelectorAll('.nav-link');
    navLinks.forEach(link => {
        link.addEventListener('click', function(e) {
            e.preventDefault();
            const page = this.getAttribute('data-page');
            showPage(page);
            
            // Atualiza navegação ativa
            navLinks.forEach(l => l.classList.remove('active'));
            this.classList.add('active');
        });
    });
}

function showPage(pageName) {
    // Esconde todas as páginas
    document.querySelectorAll('.page').forEach(page => {
        page.classList.remove('active');
    });
    
    // Mostra a página selecionada
    const targetPage = document.getElementById(`page-${pageName}`);
    if (targetPage) {
        targetPage.classList.add('active');
        
        // Carrega dados específicos da página
        if (pageName === 'produtos') {
            loadProdutos();
        } else if (pageName === 'inspecoes') {
            loadInspecoes();
        } else if (pageName === 'classificacoes') {
            loadClassificacoes();
        }
    }
}

// Modals
function initializeModals() {
    const form = document.getElementById('form-create-product');
    if (form) {
        form.addEventListener('submit', function(e) {
            e.preventDefault();
            createProduct();
        });
    }

    // Wire confirm-delete button (centered modal) if present
    const confirmBtn = document.getElementById('confirm-delete-btn');
    if (confirmBtn) {
        confirmBtn.addEventListener('click', async function() {
            if (!pendingDeleteId) return;
            // perform deletion and close the confirm modal
            await performDelete(pendingDeleteId);
            closeConfirmModal();
        });
    }
}

function showCreateProductModal() {
    const modal = document.getElementById('modal-create-product');
    if (modal) {
        modal.classList.add('active');
    }
}

function closeModal(modalId) {
    const modal = document.getElementById(modalId);
    if (modal) {
        modal.classList.remove('active');
    }
}

// Carregamento de dados
async function loadData() {
    try {
        // Verifica se a API está online
        const healthCheck = await fetch(`${API_BASE_URL}/health`);
        if (!healthCheck.ok) {
            throw new Error('API não está respondendo');
        }
        
        await Promise.all([
            loadEstatisticas(),
            loadHistorico(),
            loadClassificacoesRecentes(),
            loadCameraStats()
        ]);
        updateLastUpdateTime();
        
        // Atualiza status do sistema
        const statusEl = document.getElementById('system-status');
        if (statusEl) {
            statusEl.textContent = 'Online';
            statusEl.className = 'stat-value status-online';
        }
    } catch (error) {
        console.error('Erro ao carregar dados:', error);
        const statusEl = document.getElementById('system-status');
        if (statusEl) {
            statusEl.textContent = 'Offline';
            statusEl.className = 'stat-value';
            statusEl.style.color = '#ef4444';
        }
    
        if (document.getElementById('recent-tbody').innerHTML.includes('Carregando')) {
            document.getElementById('recent-tbody').innerHTML = 
                '<tr><td colspan="4" class="loading">Erro ao conectar à API. Verifique se o servidor está rodando.</td></tr>';
        }
    }
}


async function loadEstatisticas() {
    try {
        const response = await fetch(`${API_BASE_URL}/estatisticas/`);
        if (!response.ok) throw new Error('Erro ao buscar estatísticas');
        
        const data = await response.json();
        
        // Atualizar os cards das estatísticas
        document.getElementById('stat-total').textContent = data.total_classificados || 0;
        document.getElementById('stat-aprovados').textContent = data.aprovados || 0;
        document.getElementById('stat-reprocessar').textContent = data.reprocessar || 0;
        document.getElementById('stat-segregados').textContent = data.segregados || 0;
        
        // Atualiza percentuais
        if (data.percentuais) {
            document.getElementById('stat-aprovados-pct').textContent = 
                `${data.percentuais.aprovados?.toFixed(1) || 0}%`;
            document.getElementById('stat-reprocessar-pct').textContent = 
                `${data.percentuais.reprocessar?.toFixed(1) || 0}%`;
            document.getElementById('stat-segregados-pct').textContent = 
                `${data.percentuais.segregados?.toFixed(1) || 0}%`;
        }
        
        // Atualizar o gráfico de distribuição
        updateDistributionChart(data);
        
    } catch (error) {
        console.error('Erro ao carregar estatísticas:', error);
    }
}

// Carregar o histórico
async function loadHistorico() {
    try {
        const response = await fetch(`${API_BASE_URL}/estatisticas/historico?dias=7`);
        if (!response.ok) throw new Error('Erro ao buscar histórico');
        
        const data = await response.json();
        updateHistoryChart(data);
        
    } catch (error) {
        console.error('Erro ao carregar histórico:', error);
    }
}

// Classificações recentes
async function loadClassificacoesRecentes() {
    try {
        const response = await fetch(`${API_BASE_URL}/estatisticas/recentes?limit=10`);
        if (!response.ok) throw new Error('Erro ao buscar classificações recentes');
        
        const data = await response.json();
        updateRecentTable(data);
        
    } catch (error) {
        console.error('Erro ao carregar classificações recentes:', error);
    }
}

// Carregar os produtos
async function loadProdutos() {
    try {
        const response = await fetch(`${API_BASE_URL}/produtos/?limit=100`);
        if (!response.ok) throw new Error('Erro ao buscar produtos');
        
        const data = await response.json();
        updateProdutosTable(data);
        
    } catch (error) {
        console.error('Erro ao carregar produtos:', error);
        document.getElementById('produtos-tbody').innerHTML = 
            '<tr><td colspan="6" class="loading">Erro ao carregar produtos</td></tr>';
    }
}

// Carregar as inspeções
async function loadInspecoes() {
    try {
        const response = await fetch(`${API_BASE_URL}/inspecoes/?limit=100`);
        if (!response.ok) {
            const errorText = await response.text();
            console.error('Erro na resposta:', errorText);
            throw new Error(`Erro ao buscar inspeções: ${response.status}`);
        }
        
        const data = await response.json();
        if (!Array.isArray(data)) {
            console.error('Resposta não é um array:', data);
            throw new Error('Resposta inválida da API');
        }
        
        updateInspecoesTable(data);
        
    } catch (error) {
        console.error('Erro ao carregar inspeções:', error);
        const tbody = document.getElementById('inspecoes-tbody');
        if (tbody) {
            tbody.innerHTML = `
                <tr>
                    <td colspan="7" class="loading">
                        <div>Não foi possível carregar as inspeções. Verifique se o servidor está rodando e veja o console para detalhes.</div>
                        <div style="margin-top:8px;"><button class="btn-secondary" onclick="loadInspecoes()" style="padding:6px 10px; font-size:13px;">Tentar novamente</button></div>
                    </td>
                </tr>`;
        }
    }
}

// Classificações
async function loadClassificacoes() {
    try {
        const response = await fetch(`${API_BASE_URL}/classificacoes/?limit=100`);
        if (!response.ok) {
            const errorText = await response.text();
            console.error('Erro na resposta:', errorText);
            throw new Error(`Erro ao buscar classificações: ${response.status}`);
        }
        
        const data = await response.json();
        if (!Array.isArray(data)) {
            console.error('Resposta não é um array:', data);
            throw new Error('Resposta inválida da API');
        }
        
        updateClassificacoesTable(data);
        
    } catch (error) {
        console.error('Erro ao carregar classificações:', error);
        const tbody = document.getElementById('classificacoes-tbody');
        if (tbody) {
            tbody.innerHTML = `
                <tr>
                    <td colspan="6" class="loading">
                        <div>Não foi possível carregar as classificações. Verifique se o servidor está rodando e veja o console para detalhes.</div>
                        <div style="margin-top:8px;"><button class="btn-secondary" onclick="loadClassificacoes()" style="padding:6px 10px; font-size:13px;">Tentar novamente</button></div>
                    </td>
                </tr>`;
        }
    }
}

// Criar um novo produto
async function createProduct() {
    const form = document.getElementById('form-create-product');
    const formData = new FormData(form);
    
    // Obtém o ID, mas remove se estiver vazio para evitar erros
    const produtoId = formData.get('id')?.trim();
    
    const productData = {
        lado_atual: formData.get('lado_atual'),
        status: formData.get('status')
    };
    
    // Só adiciona o ID se foi fornecido
    if (produtoId && produtoId !== '') {
        productData.id = produtoId;
    }
    
    try {
        const response = await fetch(`${API_BASE_URL}/produtos/`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify(productData)
        });
        
        if (!response.ok) {
            const error = await response.json();
            throw new Error(error.detail || 'Erro ao criar produto');
        }
        
        const produtoCriado = await response.json();
        const idGerado = produtoCriado.id || produtoId || 'automático';
        
        closeModal('modal-create-product');
        form.reset();
        
        // Recarregar os produtos se estiver na página
        if (document.getElementById('page-produtos').classList.contains('active')) {
            loadProdutos();
        }
        
        // Recarrega estatísticas
        loadData();
        
        showSuccess(`Produto criado com sucesso! ID: ${idGerado}`);
        
    } catch (error) {
        console.error('Erro ao criar produto:', error);
        showError(error.message || 'Erro ao criar produto');
    }
}

// Atualizar a tabela de classificações recentes
function updateRecentTable(data) {
    const tbody = document.getElementById('recent-tbody');
    
    if (!data || data.length === 0) {
        tbody.innerHTML = '<tr><td colspan="4" class="loading">Nenhuma classificação encontrada</td></tr>';
        return;
    }
    
    tbody.innerHTML = data.map(item => {
        const timestamp = item.timestamp ? new Date(item.timestamp).toLocaleString('pt-BR') : '-';
        const confianca = (item.confianca * 100).toFixed(1);
        const badgeClass = getBadgeClass(item.classificacao);
        const classificacao = capitalizeFirst(item.classificacao);
        
        return `
            <tr>
                <td><strong>${item.produto_id}</strong></td>
                <td><span class="badge ${badgeClass}">${classificacao}</span></td>
                <td>${confianca}%</td>
                <td>${timestamp}</td>
            </tr>
        `;
    }).join('');
}

function updateProdutosTable(data) {
    const tbody = document.getElementById('produtos-tbody');
    
    if (!data || data.length === 0) {
        tbody.innerHTML = '<tr><td colspan="7" class="loading">Nenhum produto encontrado</td></tr>';
        return;
    }
    
    tbody.innerHTML = data.map(item => {
        const entrada = item.timestamp_entrada ? new Date(item.timestamp_entrada).toLocaleString('pt-BR') : '-';
        const statusBadge = getStatusBadge(item.status);
        const classificacaoBadge = item.classificacao_final ? 
            `<span class="badge ${getBadgeClass(item.classificacao_final)}">${capitalizeFirst(item.classificacao_final)}</span>` : 
            '-';
        
        return `
            <tr>
                <td style="text-align:center"><input type="checkbox" class="produto-select" data-id="${item.id}"></td>
                <td><strong>${item.id}</strong></td>
                <td>${statusBadge}</td>
                <td>${capitalizeFirst(item.lado_atual)}</td>
                <td>${classificacaoBadge}</td>
                <td>${entrada}</td>
                        <td>
                            <button class="btn-secondary" onclick="viewProduct('${item.id}')" style="padding: 5px 10px; font-size: 12px; margin-right:8px;">Ver</button>
                            <button class="btn-danger" onclick="deleteProduct('${item.id}')" style="padding: 5px 10px; font-size: 12px;">Deletar</button>
                        </td>
            </tr>
        `;
    }).join('');

    // Wire up selection checkboxes (select all + per-row)
    wireProdutoSelection();
}

// Gerencia comportamento do checkbox de seleção (todos / individual)
function wireProdutoSelection() {
    const selectAll = document.getElementById('select-all-produtos');
    const checkboxes = Array.from(document.querySelectorAll('.produto-select'));

    // Atualiza estado de seleção visual na tabela
    function updateRowSelection(checkbox) {
        const tr = checkbox.closest('tr');
        if (!tr) return;
        if (checkbox.checked) tr.classList.add('selected');
        else tr.classList.remove('selected');
    }

    // Evento para cada checkbox de produto
    checkboxes.forEach(cb => {
        // limpando listeners duplicados: cloneNode trick
        const newCb = cb.cloneNode(true);
        cb.parentNode.replaceChild(newCb, cb);
        newCb.addEventListener('change', function() {
            updateRowSelection(newCb);
            // atualiza estado do select-all
            const all = document.querySelectorAll('.produto-select');
            const checked = document.querySelectorAll('.produto-select:checked');
            if (selectAll) selectAll.checked = (all.length === checked.length && all.length > 0);
        });
        // inicializa estado visual
        updateRowSelection(newCb);
    });

    // Evento para select-all
    if (selectAll) {
        // remove handlers duplicados
        const newAll = selectAll.cloneNode(true);
        selectAll.parentNode.replaceChild(newAll, selectAll);
        newAll.addEventListener('change', function() {
            const checked = newAll.checked;
            document.querySelectorAll('.produto-select').forEach(cb => {
                cb.checked = checked;
                const tr = cb.closest('tr');
                if (tr) {
                    if (checked) tr.classList.add('selected');
                    else tr.classList.remove('selected');
                }
            });
        });
    }
}

// Retorna array de IDs selecionados
function getSelectedProductIds() {
    return Array.from(document.querySelectorAll('.produto-select:checked')).map(cb => cb.getAttribute('data-id'));
}

function updateInspecoesTable(data) {
    const tbody = document.getElementById('inspecoes-tbody');
    if (!tbody) return;
    
    if (!data || data.length === 0) {
        tbody.innerHTML = '<tr><td colspan="7" class="loading">Nenhuma inspeção encontrada</td></tr>';
        return;
    }
    
    try {
        tbody.innerHTML = data.map(item => {
            try {
                // Garantir que temos valores válidos
                const id = item.id || '-';
                const produtoId = item.produto_id || '-';
                const lado = item.lado || 'superior';
                const qualidade = item.qualidade != null ? parseFloat(item.qualidade) : 0.0;
                const qualidadePercent = (qualidade * 100).toFixed(1);
                const defeitos = item.defeitos_detectados || [];
                const defeitosCount = Array.isArray(defeitos) ? defeitos.length : 0;
                const qualidadeClass = getQualityClass(qualidade);
                const cameraId = item.camera_id || '-';
                
                let timestamp = '-';
                if (item.timestamp) {
                    try {
                        timestamp = new Date(item.timestamp).toLocaleString('pt-BR');
                    } catch (e) {
                        timestamp = item.timestamp;
                    }
                }
                
                return `
                    <tr>
                        <td>${id}</td>
                        <td><strong>${produtoId}</strong></td>
                        <td>${capitalizeFirst(String(lado))}</td>
                        <td>
                            <div class="quality-indicator">
                                <span>${qualidadePercent}%</span>
                                <div class="quality-bar">
                                    <div class="quality-fill ${qualidadeClass}" style="width: ${qualidadePercent}%"></div>
                                </div>
                            </div>
                        </td>
                        <td>${cameraId}</td>
                        <td>${defeitosCount} defeito(s)</td>
                        <td>${timestamp}</td>
                    </tr>
                `;
            } catch (e) {
                console.error('Erro ao processar item de inspeção:', e, item);
                return `<tr><td colspan="7">Erro ao processar inspeção</td></tr>`;
            }
        }).join('');
    } catch (error) {
        console.error('Erro ao atualizar tabela de inspeções:', error);
        tbody.innerHTML = '<tr><td colspan="7" class="loading">Erro ao processar dados</td></tr>';
    }
}

function updateClassificacoesTable(data) {
    const tbody = document.getElementById('classificacoes-tbody');
    if (!tbody) return;
    
    if (!data || data.length === 0) {
        tbody.innerHTML = '<tr><td colspan="6" class="loading">Nenhuma classificação encontrada</td></tr>';
        return;
    }
    
    try {
        tbody.innerHTML = data.map(item => {
            try {
                // Garantir que temos valores válidos
                const id = item.id || '-';
                const produtoId = item.produto_id || '-';
                const classificacao = item.classificacao || 'pendente';
                const confianca = item.confianca != null ? parseFloat(item.confianca) : 0.0;
                const confiancaPercent = (confianca * 100).toFixed(1);
                const badgeClass = getBadgeClass(classificacao);
                const classificacaoLabel = capitalizeFirst(String(classificacao));
                const motivo = item.motivo || '-';
                
                let timestamp = '-';
                if (item.timestamp) {
                    try {
                        timestamp = new Date(item.timestamp).toLocaleString('pt-BR');
                    } catch (e) {
                        timestamp = item.timestamp;
                    }
                }
                
                return `
                    <tr>
                        <td>${id}</td>
                        <td><strong>${produtoId}</strong></td>
                        <td><span class="badge ${badgeClass}">${classificacaoLabel}</span></td>
                        <td>${confiancaPercent}%</td>
                        <td>${motivo}</td>
                        <td>${timestamp}</td>
                    </tr>
                `;
            } catch (e) {
                console.error('Erro ao processar item de classificação:', e, item);
                return `<tr><td colspan="6">Erro ao processar classificação</td></tr>`;
            }
        }).join('');
    } catch (error) {
        console.error('Erro ao atualizar tabela de classificações:', error);
        tbody.innerHTML = '<tr><td colspan="6" class="loading">Erro ao processar dados</td></tr>';
    }
}

// Atualizar o gráfico de distribuição
function updateDistributionChart(data) {
    const ctx = document.getElementById('chart-distribution');
    if (!ctx) return;
    
    // Destrói gráfico anterior se existir
    if (charts.distribution) {
        charts.distribution.destroy();
    }
    
    charts.distribution = new Chart(ctx, {
        type: 'doughnut',
        data: {
            labels: ['Aprovados', 'Reprocessar', 'Segregados'],
            datasets: [{
                data: [
                    data.aprovados || 0,
                    data.reprocessar || 0,
                    data.segregados || 0
                ],
                backgroundColor: [
                    '#10b981',
                    '#f59e0b',
                    '#ef4444'
                ],
                borderWidth: 0
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: true,
            plugins: {
                legend: {
                    position: 'bottom',
                },
                tooltip: {
                    callbacks: {
                        label: function(context) {
                            const label = context.label || '';
                            const value = context.parsed || 0;
                            const total = data.total_classificados || 1;
                            const percentage = ((value / total) * 100).toFixed(1);
                            return `${label}: ${value} (${percentage}%)`;
                        }
                    }
                }
            }
        }
    });
}

function updateHistoryChart(data) {
    const ctx = document.getElementById('chart-history');
    if (!ctx) return;
    
    // Destrói gráfico anterior se existir
    if (charts.history) {
        charts.history.destroy();
    }
    
    const labels = data.map(item => {
        const date = new Date(item.data);
        return date.toLocaleDateString('pt-BR', { day: '2-digit', month: '2-digit' });
    });
    
    charts.history = new Chart(ctx, {
        type: 'line',
        data: {
            labels: labels,
            datasets: [
                {
                    label: 'Aprovados',
                    data: data.map(item => item.aprovados || 0),
                    borderColor: '#10b981',
                    backgroundColor: 'rgba(16, 185, 129, 0.1)',
                    tension: 0.4,
                    fill: true
                },
                {
                    label: 'Reprocessar',
                    data: data.map(item => item.reprocessar || 0),
                    borderColor: '#f59e0b',
                    backgroundColor: 'rgba(245, 158, 11, 0.1)',
                    tension: 0.4,
                    fill: true
                },
                {
                    label: 'Segregados',
                    data: data.map(item => item.segregados || 0),
                    borderColor: '#ef4444',
                    backgroundColor: 'rgba(239, 68, 68, 0.1)',
                    tension: 0.4,
                    fill: true
                }
            ]
        },
        options: {
            responsive: true,
            maintainAspectRatio: true,
            plugins: {
                legend: {
                    position: 'top',
                }
            },
            scales: {
                y: {
                    beginAtZero: true,
                    ticks: {
                        stepSize: 1
                    }
                }
            }
        }
    });
}

// Carrega estatísticas por câmera (tenta a rota /estatisticas/cameras, senão usa mock)
async function loadCameraStats() {
    // Primeiro tenta obter lista de câmeras e suas posições
    let cameraMap = {}; // camera_id -> { posicao, camera_id }
    try {
        const camResp = await fetch(`${API_BASE_URL}/cameras/`);
        if (camResp.ok) {
            const camData = await camResp.json();
            camData.forEach(c => {
                cameraMap[c.camera_id] = c;
            });
            // Atualiza tabela de status de câmeras
            try { updateCameraList(camData); } catch (e) { console.warn('Erro ao atualizar lista de câmeras:', e); }
        }
    } catch (e) {
        console.warn('Não foi possível obter /cameras:', e);
    }

    // Depois busca contagens por câmera
    try {
        const resp = await fetch(`${API_BASE_URL}/estatisticas/cameras`);
        if (resp.ok) {
            const data = await resp.json();

            // Calcula totais por posição
            const totalsByPos = {};
            data.forEach(item => {
                const camId = item.camera;
                const pos = (cameraMap[camId] && cameraMap[camId].posicao) ? cameraMap[camId].posicao : 'desconhecido';
                totalsByPos[pos] = (totalsByPos[pos] || 0) + (Number(item.total) || 0);
            });

            // Atualiza resumo abaixo do gráfico
            const summaryEl = document.getElementById('camera-summary');
            if (summaryEl) {
                const parts = [];
                for (const [pos, val] of Object.entries(totalsByPos)) {
                    parts.push(`${capitalizeFirst(pos)}: <strong>${val}</strong>`);
                }
                summaryEl.innerHTML = parts.join(' &nbsp; • &nbsp; ');
            }

            // Mapeia rótulos mais descritivos (posicao (id) se disponível)
            const mapped = data.map(item => {
                const cam = cameraMap[item.camera];
                const label = cam ? `${capitalizeFirst(cam.posicao)} (${item.camera})` : item.camera;
                return { camera: label, total: item.total };
            });

            updateCameraChart(mapped);
            return;
        }
    } catch (e) {
        console.warn('Rota /estatisticas/cameras não disponível, usando dados mock para chart-camera');
    }

    // Fallback mock
    const mock = [
        { camera: 'Superior (CAM001)', total: 42 },
        { camera: 'Inferior (CAM002)', total: 28 },
        { camera: 'Câmera 3', total: 15 }
    ];
    const summaryEl = document.getElementById('camera-summary');
    if (summaryEl) summaryEl.innerHTML = 'Superior: <strong>42</strong> &nbsp; • &nbsp; Inferior: <strong>28</strong>';
    // Preenche também a tabela com mocks
    try { updateCameraList([{
        camera_id: 'CAM001', posicao: 'superior', status: 'disponivel', total_capturas: 42
    },{
        camera_id: 'CAM002', posicao: 'inferior', status: 'disponivel', total_capturas: 28
    }]); } catch (e) { /* ignore */ }
    updateCameraChart(mock);
}

// Atualiza a tabela de status das câmeras
function updateCameraList(cameras) {
    const tbody = document.getElementById('camera-status-tbody');
    if (!tbody) return;

    if (!cameras || cameras.length === 0) {
        tbody.innerHTML = '<tr><td colspan="4" class="loading">Nenhuma câmera registrada</td></tr>';
        return;
    }

    // Normalize e calcula número de capturas para ordenar
    const normalized = cameras.map(c => {
        const camId = c.camera_id || c.camera || '-';
        const pos = c.posicao || c.position || '-';
        const status = c.status || '-';
        const captures = Number(c.total_capturas != null ? c.total_capturas : (c.total || 0)) || 0;
        return { camId, pos, status, captures };
    });

    // Ordena decrescente por captures
    normalized.sort((a, b) => b.captures - a.captures);

    // Gera linhas, destacando a primeira (maior número de capturas)
    tbody.innerHTML = normalized.map((c, idx) => {
        const topClass = (idx === 0) ? 'top-camera' : '';
        return `
            <tr class="${topClass}">
                <td><strong>${c.camId}</strong></td>
                <td>${capitalizeFirst(String(c.pos))}</td>
                <td>${capitalizeFirst(String(c.status))}</td>
                <td>${c.captures}</td>
            </tr>
        `;
    }).join('');
}

function updateCameraChart(data) {
    const ctx = document.getElementById('chart-camera');
    if (!ctx) return;

    // destrói gráfico anterior se existir
    if (charts.camera) {
        try { charts.camera.destroy(); } catch (e) { /* ignore */ }
    }

    // Aceita formatos: array de {camera, total} ou objeto {labels:[], values:[]}
    let labels = [];
    let values = [];
    if (Array.isArray(data)) {
        labels = data.map(d => d.camera || d.label || '-');
        values = data.map(d => Number(d.total || d.value || 0));
    } else if (data && data.labels && data.values) {
        labels = data.labels;
        values = data.values;
    } else {
        labels = ['Câmera 1', 'Câmera 2'];
        values = [1, 1];
    }

    charts.camera = new Chart(ctx, {
        type: 'bar',
        data: {
            labels: labels,
            datasets: [{
                label: 'Total de Classificações',
                data: values,
                backgroundColor: ['#2563eb','#10b981','#f59e0b','#ef4444'],
                borderWidth: 0
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: true,
            plugins: {
                legend: { display: false },
                tooltip: { mode: 'index', intersect: false }
            },
            scales: {
                y: { beginAtZero: true, ticks: { stepSize: 1 } }
            }
        }
    });
}

// Utilitários
function getBadgeClass(classificacao) {
    const map = {
        'aprovado': 'badge-approved',
        'reprocessar': 'badge-reprocess',
        'segregar': 'badge-segregated',
        'pendente': 'badge-pendente'
    };
    return map[classificacao.toLowerCase()] || 'badge-pendente';
}

function getStatusBadge(status) {
    const map = {
        'pendente': 'badge-pendente',
        'em_inspecao': 'badge-em-inspecao',
        'inspecionado': 'badge-approved',
        'classificado': 'badge-approved'
    };
    return `<span class="badge ${map[status] || 'badge-pendente'}">${capitalizeFirst(status)}</span>`;
}

function getQualityClass(qualidade) {
    if (qualidade >= 0.8) return 'high';
    if (qualidade >= 0.5) return 'medium';
    return 'low';
}

function capitalizeFirst(str) {
    if (!str) return '';
    return str.charAt(0).toUpperCase() + str.slice(1).toLowerCase();
}

function updateLastUpdateTime() {
    const now = new Date();
    const timeString = now.toLocaleTimeString('pt-BR');
    const lastUpdateEl = document.getElementById('last-update');
    if (lastUpdateEl) {
        lastUpdateEl.textContent = timeString;
    }
}

// Auto-update
function startAutoUpdate() {
    // Atualiza a cada 5 segundos
    // Agora atualiza todas as seções principais para garantir que elas
    // fiquem sempre em atualização: estatísticas, histórico, recentes,
    // produtos, inspeções e classificações.
    if (updateInterval) return; // não criar múltiplos intervalos
    const intervalMs = 5000;

    async function doUpdate() {
        try {
            await Promise.all([
                loadData(),
                loadProdutos(),
                loadInspecoes(),
                loadClassificacoes()
            ]);
            updateLastUpdateTime();
        } catch (e) {
            
            console.warn('Erro no auto-update:', e);
        }
    }
    doUpdate();
    updateInterval = setInterval(doUpdate, intervalMs);
}

function stopAutoUpdate() {
    if (updateInterval) {
        clearInterval(updateInterval);
        updateInterval = null;
    }
}

// Notificações
function showSuccess(message) {
    // Cria um elemento de notificação
    const notification = document.createElement('div');
    notification.className = 'notification notification-success';
    notification.textContent = message;
    document.body.appendChild(notification);
    
    // Mostra a notificação
    setTimeout(() => {
        notification.classList.add('show');
    }, 10);
    
    // Remove após 3 segundos
    setTimeout(() => {
        notification.classList.remove('show');
        setTimeout(() => {
            document.body.removeChild(notification);
        }, 300);
    }, 3000);
}

function showError(message) {
    // Cria um elemento de notificação
    const notification = document.createElement('div');
    notification.className = 'notification notification-error';
    notification.textContent = message;
    document.body.appendChild(notification);
    
    // Mostra a notificação
    setTimeout(() => {
        notification.classList.add('show');
    }, 10);
    
    // Remove após 5 segundos
    setTimeout(() => {
        notification.classList.remove('show');
        setTimeout(() => {
            document.body.removeChild(notification);
        }, 300);
    }, 5000);
}

// Ver produto
function viewProduct(productId) {
    // Busca detalhes do produto e abre modal
    (async () => {
        try {
            const resp = await fetch(`${API_BASE_URL}/produtos/${productId}`);
            if (!resp.ok) {
                const txt = await resp.text();
                throw new Error(txt || 'Erro ao buscar produto');
            }
            const produto = await resp.json();

            // Preenche o modal com os dados
            document.getElementById('detail-id').textContent = produto.id || '-';
            document.getElementById('detail-status').textContent = produto.status || '-';
            document.getElementById('detail-lado').textContent = produto.lado_atual || '-';
            document.getElementById('detail-classificacao').textContent = produto.classificacao_final || '-';
            document.getElementById('detail-entrada').textContent = produto.timestamp_entrada ? new Date(produto.timestamp_entrada).toLocaleString('pt-BR') : '-';
            document.getElementById('detail-timestamp-classificacao').textContent = produto.timestamp_classificacao ? new Date(produto.timestamp_classificacao).toLocaleString('pt-BR') : '-';
            document.getElementById('detail-created').textContent = produto.created_at ? new Date(produto.created_at).toLocaleString('pt-BR') : '-';
            document.getElementById('detail-updated').textContent = produto.updated_at ? new Date(produto.updated_at).toLocaleString('pt-BR') : '-';

            // Configura o botão de delete
            const btnDelete = document.getElementById('btn-delete-product');
            if (btnDelete) {
                // remove listeners anteriores
                btnDelete.onclick = null;
                btnDelete.onclick = function() { deleteProduct(productId); };
            }

            // Abre modal
            const modal = document.getElementById('modal-view-product');
            if (modal) modal.classList.add('active');

        } catch (err) {
            console.error('Erro ao carregar produto:', err);
            showError('Não foi possível carregar os detalhes do produto. Veja o console para mais informações.');
        }
    })();
}

// Deleta produto (abre modal de confirmação centralizada)
function deleteProduct(productId) {
    // mostra modal de confirmação centrado
    showConfirmDelete(productId);
}

function showConfirmDelete(productId) {
    pendingDeleteId = productId;
    const msgEl = document.getElementById('confirm-delete-message');
    if (msgEl) msgEl.textContent = `Confirma exclusão do produto ${productId}? Esta ação não pode ser desfeita.`;
    const modal = document.getElementById('modal-confirm-delete');
    if (modal) modal.classList.add('active');
}

function closeConfirmModal() {
    pendingDeleteId = null;
    const modal = document.getElementById('modal-confirm-delete');
    if (modal) modal.classList.remove('active');
}

// performDelete: executa a requisição DELETE ao backend
async function performDelete(productId) {
    if (!productId) return;
    try {
        const resp = await fetch(`${API_BASE_URL}/produtos/${productId}`, { method: 'DELETE' });
        if (!resp.ok) {
            const body = await resp.json().catch(() => null);
            const detail = body?.detail || await resp.text();
            throw new Error(detail || `Erro ao deletar produto (status ${resp.status})`);
        }

        // Lê resposta detalhada (DeleteResult) e monta mensagem informativa
        let respBody = null;
        try {
            respBody = await resp.json();
        } catch (e) {
            // se não for JSON, apenas mostra mensagem genérica
            showSuccess(`Produto ${productId} deletado com sucesso`);
            respBody = null;
        }

        if (respBody) {
            const ins = respBody.inspecoes_deleted ?? 0;
            const cls = respBody.classificacoes_deleted ?? 0;
            const cams = Array.isArray(respBody.camera_updates) ? respBody.camera_updates.length : 0;
            let msg = `Produto ${productId} deletado com sucesso.`;
            msg += ` Inspeções removidas: ${ins}. Classificações removidas: ${cls}.`;
            if (cams > 0) msg += ` Câmeras atualizadas: ${cams}.`;
            showSuccess(msg);
            if (respBody.camera_updates) console.info('Camera updates:', respBody.camera_updates);
        }

        // Limpa seleção de produtos na UI após exclusão
        try {
            if (typeof clearSelectedProducts === 'function') clearSelectedProducts();
        } catch (e) {
            console.warn('clearSelectedProducts não disponível:', e);
        }

        // Fecha modal de detalhes se aberto
        closeModal('modal-view-product');

        // Atualiza tabela de produtos e estatísticas
        if (document.getElementById('page-produtos').classList.contains('active')) {
            loadProdutos();
        }
        loadData();

    } catch (err) {
        console.error('Erro ao deletar produto:', err);
        showError(err.message || 'Erro ao deletar produto');
    }
}

// Limpa todas as seleções de produtos (útil para ação em lote)
function clearSelectedProducts() {
    const all = document.querySelectorAll('.produto-select');
    all.forEach(cb => {
        cb.checked = false;
        const tr = cb.closest('tr');
        if (tr) tr.classList.remove('selected');
    });
    const selectAll = document.getElementById('select-all-produtos');
    if (selectAll) selectAll.checked = false;
    showSuccess('Seleção limpa');
}

// Preenche inspeções no modal
function populateModalInspecoes(inspecoes) {
    const tbody = document.getElementById('modal-inspecoes-tbody');
    if (!tbody) return;

    if (!inspecoes || inspecoes.length === 0) {
        tbody.innerHTML = '<tr><td colspan="6" class="loading">Nenhuma inspeção encontrada</td></tr>';
        return;
    }

    try {
        tbody.innerHTML = inspecoes.map(item => {
            const id = item.id || '-';
            const lado = item.lado || '-';
            const qualidade = item.qualidade != null ? (parseFloat(item.qualidade) * 100).toFixed(1) + '%' : '-';
            const camera = item.camera_id || '-';
            const defeitos = Array.isArray(item.defeitos_detectados) ? item.defeitos_detectados.length : (item.defeitos_detectados ? 1 : 0);
            const timestamp = item.timestamp ? new Date(item.timestamp).toLocaleString('pt-BR') : '-';

            return `
                <tr>
                    <td>${id}</td>
                    <td>${capitalizeFirst(String(lado))}</td>
                    <td>${qualidade}</td>
                    <td>${camera}</td>
                    <td>${defeitos} defeito(s)</td>
                    <td>${timestamp}</td>
                </tr>
            `;
        }).join('');
    } catch (e) {
        console.error('Erro ao preencher inspeções do modal:', e);
        tbody.innerHTML = '<tr><td colspan="6" class="loading">Erro ao processar inspeções</td></tr>';
    }
}

// Preenche classificação no modal (última)
function populateModalClassificacao(classificacao) {
    const tbody = document.getElementById('modal-classificacoes-tbody');
    if (!tbody) return;

    if (!classificacao) {
        tbody.innerHTML = '<tr><td colspan="5" class="loading">Nenhuma classificação encontrada</td></tr>';
        return;
    }

    try {
        const id = classificacao.id || '-';
        const classificacaoLabel = classificacao.classificacao || '-';
        const confianca = classificacao.confianca != null ? (parseFloat(classificacao.confianca) * 100).toFixed(1) + '%' : '-';
        const motivo = classificacao.motivo || '-';
        const timestamp = classificacao.timestamp ? new Date(classificacao.timestamp).toLocaleString('pt-BR') : '-';

        tbody.innerHTML = `
            <tr>
                <td>${id}</td>
                <td><span class="badge ${getBadgeClass(classificacaoLabel)}">${capitalizeFirst(classificacaoLabel)}</span></td>
                <td>${confianca}</td>
                <td>${motivo}</td>
                <td>${timestamp}</td>
            </tr>
        `;
    } catch (e) {
        console.error('Erro ao preencher classificação do modal:', e);
        tbody.innerHTML = '<tr><td colspan="5" class="loading">Erro ao processar classificação</td></tr>';
    }
}

// Estende viewProduct para buscar também inspeções e classificação
(function() {
    const originalView = viewProduct;
    viewProduct = function(productId) {
        // chama a implementação anterior para preencher dados básicos e abrir modal
        originalView(productId);

        // Busca inspeções e classificação em paralelo (tratando 404 para classificação)
        (async () => {
            // Preenche placeholders imediatos
            const inspecoesTbody = document.getElementById('modal-inspecoes-tbody');
            if (inspecoesTbody) inspecoesTbody.innerHTML = '<tr><td colspan="6" class="loading">Carregando inspeções...</td></tr>';
            const classTbody = document.getElementById('modal-classificacoes-tbody');
            if (classTbody) classTbody.innerHTML = '<tr><td colspan="5" class="loading">Carregando classificação...</td></tr>';

            try {
                const [insResp, classResp] = await Promise.all([
                    fetch(`${API_BASE_URL}/inspecoes/produto/${productId}`),
                    fetch(`${API_BASE_URL}/classificacoes/produto/${productId}`)
                ]);

                // Inspeções
                if (insResp.ok) {
                    const insData = await insResp.json();
                    populateModalInspecoes(insData);
                } else {
                    const txt = await insResp.text().catch(() => '');
                    console.warn('Erro ao buscar inspeções:', insResp.status, txt);
                    populateModalInspecoes([]);
                }

                // Classificação (pode retornar 404)
                if (classResp.ok) {
                    const classData = await classResp.json();
                    populateModalClassificacao(classData);
                } else if (classResp.status === 404) {
                    populateModalClassificacao(null);
                } else {
                    const txt = await classResp.text().catch(() => '');
                    console.warn('Erro ao buscar classificação:', classResp.status, txt);
                    populateModalClassificacao(null);
                }

            } catch (e) {
                console.error('Erro ao buscar dados relacionados:', e);
                populateModalInspecoes([]);
                populateModalClassificacao(null);
            }
        })();
    };
})();

// Fecha modal ao clicar fora
window.addEventListener('click', function(event) {
    const modals = document.querySelectorAll('.modal');
    modals.forEach(modal => {
        if (event.target === modal) {
            modal.classList.remove('active');
        }
    });
});

