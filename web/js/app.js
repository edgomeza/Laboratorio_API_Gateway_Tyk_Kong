// ========================================
// CALCULADORA MICROSERVICIOS - APP.JS
// ========================================

// Global state
let metrics = {
    totalRequests: 0,
    successRequests: 0,
    totalTime: 0,
    operations: {
        // Básica
        suma: 0,
        resta: 0,
        multiplica: 0,
        divide: 0,
        // Científica
        raiz: 0,
        potencia: 0,
        modulo: 0,
        logaritmo: 0,
        seno: 0,
        coseno: 0,
        tangente: 0
    }
};

let currentTab = 'tyk';

// ========================================
// INITIALIZATION
// ========================================

document.addEventListener('DOMContentLoaded', () => {
    console.log('🧮 Calculadora Microservicios cargada');
    initializeApp();
});

function initializeApp() {
    updateMetricsDisplay();
    checkMicroservicesStatus();

    // Check status every 30 seconds
    setInterval(checkMicroservicesStatus, 30000);
}

// ========================================
// CALCULATOR MODE SWITCHING
// ========================================

function switchCalcMode(mode) {
    // Update tabs
    document.getElementById('tab-basica').classList.toggle('active', mode === 'basica');
    document.getElementById('tab-cientifica').classList.toggle('active', mode === 'cientifica');

    // Update button visibility
    document.getElementById('buttons-basica').style.display = mode === 'basica' ? 'grid' : 'none';
    document.getElementById('buttons-cientifica').style.display = mode === 'cientifica' ? 'grid' : 'none';

    // Reset inputs to 2 inputs by default
    updateInputsForOperation(2);
}

// Update inputs based on number of parameters needed
function updateInputsForOperation(numParams, currentVal1, currentVal2) {
    const inputsContainer = document.getElementById('calculator-inputs');

    // Use current values if available, otherwise use defaults
    const val1 = currentVal1 !== undefined && currentVal1 !== '' ? currentVal1 : '15';
    const val2 = currentVal2 !== undefined && currentVal2 !== '' ? currentVal2 : '25';

    if (numParams === 1) {
        // Single input - preserve first value
        inputsContainer.innerHTML = `
            <input type="number" id="num1" placeholder="Número" value="${val1}" class="calc-input" style="grid-column: 1 / -1;">
        `;
    } else {
        // Two inputs - preserve both values
        inputsContainer.innerHTML = `
            <input type="number" id="num1" placeholder="Número 1" value="${val1}" class="calc-input">
            <input type="number" id="num2" placeholder="Número 2" value="${val2}" class="calc-input">
        `;
    }
}

// ========================================
// CALCULATOR FUNCTIONS
// ========================================

async function calculate(operation, symbol, numParams = 2) {
    // Read current values from inputs BEFORE updating them
    const currentNum1 = document.getElementById('num1')?.value;
    const currentNum2 = document.getElementById('num2')?.value;

    // Update inputs if needed (preserve current values if they exist)
    updateInputsForOperation(numParams, currentNum1, currentNum2);

    // Small delay to ensure inputs are rendered
    await new Promise(resolve => setTimeout(resolve, 10));

    const num1 = parseFloat(document.getElementById('num1').value);
    const num2 = numParams === 2 ? parseFloat(document.getElementById('num2')?.value) : null;

    // Validation
    if (isNaN(num1) || (numParams === 2 && isNaN(num2))) {
        alert('Por favor ingresa números válidos');
        return;
    }

    const gatewayMode = document.getElementById('gateway-mode').value;

    // Check if API key is needed but not provided
    if (needsApiKey(operation, gatewayMode)) {
        const apiKey = document.getElementById('api-key-input').value;
        if (!apiKey || apiKey.trim() === '') {
            alert('⚠️ Esta operación requiere un API Key. Por favor ingresa uno.');
            showApiKeyField();
            return;
        }
    }

    // Update display
    if (numParams === 1) {
        document.getElementById('operation-display').textContent = `${symbol}(${num1}) =`;
    } else {
        document.getElementById('operation-display').textContent = `${num1} ${symbol} ${num2} =`;
    }
    document.getElementById('result-display').textContent = 'Calculando...';
    document.getElementById('status').textContent = 'Procesando';
    document.getElementById('status').className = 'metric-value';

    const startTime = Date.now();

    try {
        const result = await performCalculation(operation, num1, num2, gatewayMode);
        const duration = Date.now() - startTime;

        // Update display with result
        document.getElementById('result-display').textContent = result.resultado;
        document.getElementById('status').textContent = result.estado || 'OK';
        document.getElementById('status').className = 'metric-value metric-success';
        document.getElementById('response-time').textContent = `${duration}ms`;
        document.getElementById('last-operation').textContent = operation;

        // Update metrics
        metrics.totalRequests++;
        metrics.successRequests++;
        metrics.totalTime += duration;
        metrics.operations[operation]++;

        updateMetricsDisplay();
        updateOperationsChart();

    } catch (error) {
        const duration = Date.now() - startTime;

        document.getElementById('result-display').textContent = 'Error';
        document.getElementById('status').textContent = 'Error';
        document.getElementById('status').className = 'metric-value metric-error';
        document.getElementById('response-time').textContent = `${duration}ms`;

        // Update metrics (failed request)
        metrics.totalRequests++;
        metrics.totalTime += duration;

        updateMetricsDisplay();

        console.error('Error en cálculo:', error);
        alert(`Error: ${error.message}`);
    }
}

async function performCalculation(operation, a, b, gatewayMode) {
    let url = '';
    let baseUrl = '';
    let queryString = '';

    // Determine base URL based on gateway mode
    switch (gatewayMode) {
        case 'tyk':
            baseUrl = `http://localhost:8080/calc/${operation}`;
            document.getElementById('current-gateway').textContent = 'Tyk';
            break;

        case 'kong':
            baseUrl = `http://localhost:8000/calc/${operation}`;
            document.getElementById('current-gateway').textContent = 'Kong';
            break;

        case 'direct':
            baseUrl = `http://localhost:3000/direct/${operation}`;
            document.getElementById('current-gateway').textContent = 'Sin Gateway';
            break;

        default:
            baseUrl = `http://localhost:3000/direct/${operation}`;
            document.getElementById('current-gateway').textContent = 'Sin Gateway';
    }

    // Build query string based on operation type
    switch (operation) {
        // 1-parameter operations
        case 'raiz':
            queryString = `?n=${a}`;
            break;
        case 'logaritmo':
            queryString = `?n=${a}`;
            break;
        case 'seno':
        case 'coseno':
        case 'tangente':
            queryString = `?angulo=${a}`;
            break;

        // 2-parameter operations with special param names
        case 'potencia':
            queryString = `?base=${a}&exponente=${b}`;
            break;

        // Standard 2-parameter operations
        case 'suma':
        case 'resta':
        case 'multiplica':
        case 'divide':
        case 'modulo':
        default:
            queryString = `?a=${a}&b=${b}`;
            break;
    }

    url = baseUrl + queryString;

    // Prepare headers
    const headers = {};

    // Add API key if needed
    if (needsApiKey(operation, gatewayMode)) {
        const apiKey = document.getElementById('api-key-input').value;
        if (apiKey) {
            if (gatewayMode === 'tyk') {
                headers['Authorization'] = apiKey;
            } else if (gatewayMode === 'kong') {
                headers['apikey'] = apiKey;
            }
        }
    }

    const response = await fetch(url, { headers });

    if (!response.ok) {
        throw new Error(`HTTP ${response.status}: ${response.statusText}`);
    }

    return await response.json();
}

// Helper function: check if operation needs API key
function needsApiKey(operation, gatewayMode) {
    // Division requires API key when using Tyk or Kong gateway
    return operation === 'divide' && (gatewayMode === 'tyk' || gatewayMode === 'kong');
}

// Show API key field with animation
function showApiKeyField() {
    const container = document.getElementById('api-key-container');
    if (container) {
        container.style.display = 'block';
    }
}

// Hide API key field
function hideApiKeyField() {
    const container = document.getElementById('api-key-container');
    if (container) {
        container.style.display = 'none';
    }
}

// ========================================
// METRICS DISPLAY
// ========================================

function updateMetricsDisplay() {
    document.getElementById('total-requests').textContent = metrics.totalRequests;

    const avgTime = metrics.totalRequests > 0
        ? Math.round(metrics.totalTime / metrics.totalRequests)
        : 0;
    document.getElementById('avg-response').textContent = `${avgTime}ms`;

    const successRate = metrics.totalRequests > 0
        ? Math.round((metrics.successRequests / metrics.totalRequests) * 100)
        : 100;
    document.getElementById('success-rate').textContent = `${successRate}%`;
}

function updateOperationsChart() {
    const maxCount = Math.max(...Object.values(metrics.operations), 1);

    const operations = ['suma', 'resta', 'multiplica', 'divide'];
    const bars = document.querySelectorAll('.chart-bars .bar');

    operations.forEach((op, index) => {
        const count = metrics.operations[op];
        const percentage = (count / maxCount) * 100;

        if (bars[index]) {
            bars[index].style.height = `${percentage}%`;
            bars[index].setAttribute('data-count', count);
        }
    });
}

// ========================================
// EXERCISE TABS
// ========================================

function switchTab(gateway) {
    currentTab = gateway;

    // Update tab buttons
    document.getElementById('tab-tyk').classList.remove('active');
    document.getElementById('tab-kong').classList.remove('active');

    if (gateway === 'tyk') {
        document.getElementById('tab-tyk').classList.add('active');
        document.getElementById('tyk-exercises').style.display = 'grid';
        document.getElementById('kong-exercises').style.display = 'none';
    } else if (gateway === 'kong') {
        document.getElementById('tab-kong').classList.add('active');
        document.getElementById('tyk-exercises').style.display = 'none';
        document.getElementById('kong-exercises').style.display = 'grid';
    }

    console.log(`Switched to ${gateway} exercises`);
}

// ========================================
// PERFORMANCE TESTING
// ========================================

async function testPerformance(mode) {
    const resultsDiv = document.getElementById(`results-${mode}`);
    const numRequests = 50;

    // Disable button during test
    const button = event.target;
    button.disabled = true;
    button.textContent = 'Probando...';

    // Clear previous results
    const resultItems = resultsDiv.querySelectorAll('.result-value');
    resultItems.forEach(item => item.textContent = '⏳');

    const startTime = Date.now();
    let successCount = 0;
    const times = [];

    try {
        // Determine URL based on mode
        let url = '';
        if (mode === 'nocache') {
            // Direct to microservice (no cache)
            url = 'http://localhost:8081/suma/calculadora/suma?a=15&b=25';
        } else {
            // Through gateway with cache (Tyk with cache enabled)
            url = 'http://localhost:8080/calc/suma/cached?a=15&b=25';
        }

        // Perform requests
        for (let i = 0; i < numRequests; i++) {
            const reqStart = Date.now();

            try {
                const response = await fetch(url);
                if (response.ok) {
                    successCount++;
                }
                times.push(Date.now() - reqStart);
            } catch (error) {
                times.push(Date.now() - reqStart);
            }
        }

        const totalTime = Date.now() - startTime;
        const avgTime = times.reduce((a, b) => a + b, 0) / times.length;
        const reqPerSec = (numRequests / (totalTime / 1000)).toFixed(2);

        // Update results
        resultItems[0].textContent = `${totalTime}ms`;
        resultItems[1].textContent = `${Math.round(avgTime)}ms`;
        resultItems[2].textContent = reqPerSec;

        // Update comparison if both tests are done
        updateComparison();

    } catch (error) {
        console.error('Error en test de performance:', error);
        resultItems[0].textContent = 'Error';
        resultItems[1].textContent = 'Error';
        resultItems[2].textContent = 'Error';
    } finally {
        button.disabled = false;
        button.textContent = 'Probar 50 requests';
    }
}

function updateComparison() {
    const nocacheResults = document.querySelectorAll('#results-nocache .result-value');
    const cacheResults = document.querySelectorAll('#results-cache .result-value');

    // Check if both tests have been run
    if (nocacheResults[0].textContent !== '-' &&
        cacheResults[0].textContent !== '-' &&
        !nocacheResults[0].textContent.includes('⏳') &&
        !cacheResults[0].textContent.includes('⏳')) {

        const nocacheTime = parseInt(nocacheResults[0].textContent);
        const cacheTime = parseInt(cacheResults[0].textContent);

        if (!isNaN(nocacheTime) && !isNaN(cacheTime) && cacheTime > 0) {
            const improvement = (nocacheTime / cacheTime).toFixed(1);

            document.getElementById('improvement-factor').textContent = improvement;
            document.getElementById('comparison-result').style.display = 'block';
        }
    }
}

// ========================================
// MICROSERVICES STATUS CHECK
// ========================================

async function checkMicroservicesStatus() {
    const services = {
        suma: { endpoint: '/direct/suma?a=1&b=1' },
        resta: { endpoint: '/direct/resta?a=2&b=1' },
        multiplica: { endpoint: '/direct/multiplica?a=2&b=3' },
        divide: { endpoint: '/direct/divide?a=10&b=2' },
        orquestador: { endpoint: '/orchestrator/suma?a=5&b=5' }
    };

    for (const [name, config] of Object.entries(services)) {
        const statusElement = document.getElementById(`status-${name}`);
        if (!statusElement) continue;

        try {
            const controller = new AbortController();
            const timeoutId = setTimeout(() => controller.abort(), 5000);

            const response = await fetch(`http://localhost:3000${config.endpoint}`, {
                signal: controller.signal
            });

            clearTimeout(timeoutId);

            if (response.ok) {
                statusElement.textContent = '●';
                statusElement.style.color = '#10b981'; // green
            } else {
                statusElement.textContent = '●';
                statusElement.style.color = '#ef4444'; // red
            }
        } catch (error) {
            statusElement.textContent = '●';
            statusElement.style.color = '#6b7280'; // gray
        }
    }
}

// ========================================
// UTILITY FUNCTIONS
// ========================================

// Allow Enter key in number inputs and setup gateway mode listener
document.addEventListener('DOMContentLoaded', () => {
    const inputs = document.querySelectorAll('.calc-input');
    inputs.forEach(input => {
        input.addEventListener('keypress', (e) => {
            if (e.key === 'Enter') {
                calculate('suma', '+');
            }
        });
    });

    // Listen to gateway mode changes to show/hide API key field
    const gatewaySelect = document.getElementById('gateway-mode');
    if (gatewaySelect) {
        gatewaySelect.addEventListener('change', updateApiKeyVisibility);
    }
});

// Update API key field visibility based on gateway selection
function updateApiKeyVisibility() {
    const gatewayMode = document.getElementById('gateway-mode').value;

    // Show API key notice if using Tyk or Kong (they have protected endpoints)
    if (gatewayMode === 'tyk' || gatewayMode === 'kong') {
        showApiKeyField();
    } else {
        hideApiKeyField();
    }
}

// ========================================
// DEMO SYSTEM
// ========================================

// Open demo page
function openDemo(gateway, exerciseNum) {
    // Demo page mapping
    const demoPages = {
        tyk: {
            1: 'demos/tyk-1-proxy-basico.html',
            2: 'demos/tyk-2-autenticacion.html',
            3: 'demos/tyk-3-rate-limiting.html',
            4: 'demos/tyk-4-caching.html',
            5: 'demos/tyk-5-transformaciones.html',
            6: 'demos/tyk-6-versioning.html',
            7: 'demos/tyk-7-logging.html'
        },
        kong: {
            1: 'demos/kong-1-proxy-basico.html',
            2: 'demos/kong-2-autenticacion.html',
            3: 'demos/kong-3-rate-limiting.html',
            4: 'demos/kong-4-caching.html',
            5: 'demos/kong-5-transformaciones.html',
            6: 'demos/kong-6-versioning.html',
            7: 'demos/kong-7-logging.html'
        }
    };

    const demoUrl = demoPages[gateway]?.[exerciseNum];
    if (demoUrl) {
        window.open(demoUrl, '_blank');
    }
}

// Export functions to window
window.calculate = calculate;
window.switchCalcMode = switchCalcMode;
window.switchTab = switchTab;
window.testPerformance = testPerformance;
window.checkMicroservicesStatus = checkMicroservicesStatus;
window.updateApiKeyVisibility = updateApiKeyVisibility;
window.openDemo = openDemo;
