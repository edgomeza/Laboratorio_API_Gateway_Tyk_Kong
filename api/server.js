const express = require('express');
const cors = require('cors');
const axios = require('axios');

const app = express();
const PORT = process.env.PORT || 3000;

// URLs de microservicios (desde variables de entorno o localhost)
const CALC_SUMA_URL = process.env.CALC_SUMA_URL || 'http://localhost:8081';
const CALC_RESTA_URL = process.env.CALC_RESTA_URL || 'http://localhost:8082';
const CALC_MULTIPLICA_URL = process.env.CALC_MULTIPLICA_URL || 'http://localhost:8083';
const CALC_DIVIDE_URL = process.env.CALC_DIVIDE_URL || 'http://localhost:8084';
const CALC_ORQUESTADOR_URL = process.env.CALC_ORQUESTADOR_URL || 'http://localhost:8085';
// V2 - Calculadora Científica
const CALC_RAIZ_URL = process.env.CALC_RAIZ_URL || 'http://localhost:8086';
const CALC_POTENCIA_URL = process.env.CALC_POTENCIA_URL || 'http://localhost:8087';
const CALC_MODULO_URL = process.env.CALC_MODULO_URL || 'http://localhost:8088';
const CALC_LOGARITMO_URL = process.env.CALC_LOGARITMO_URL || 'http://localhost:8089';
const CALC_SENO_URL = process.env.CALC_SENO_URL || 'http://localhost:8090';
const CALC_COSENO_URL = process.env.CALC_COSENO_URL || 'http://localhost:8091';
const CALC_TANGENTE_URL = process.env.CALC_TANGENTE_URL || 'http://localhost:8092';

// Middleware
app.use(cors());
app.use(express.json());

// Servir archivos estáticos desde el directorio web
app.use(express.static('web'));

// ============================================
// SISTEMA DE MÉTRICAS
// ============================================
const metrics = {
  totalRequests: 0,
  successRequests: 0,
  failedRequests: 0,
  totalResponseTime: 0,
  requestsByPath: {},
  requestsByOperation: {
    suma: 0,
    resta: 0,
    multiplica: 0,
    divide: 0
  },
  requestsByGateway: {
    direct: 0,
    tyk: 0,
    kong: 0
  },
  startTime: Date.now()
};

// Middleware de métricas
app.use((req, res, next) => {
  const startTime = Date.now();
  const path = req.path;

  // No contar peticiones internas del dashboard (health y metrics)
  const isInternalCheck = path === '/health' || path === '/metrics';

  // Detectar si viene de un gateway
  const fromTyk = req.headers['x-tyk-api-id'] || req.headers['x-tyk-jwt-sub'];
  const fromKong = req.headers['x-kong-request-id'] || req.headers['x-kong-proxy-latency'];

  // Solo contar si no es una petición interna
  if (!isInternalCheck) {
    // Incrementar contador
    metrics.totalRequests++;

    // Contar por gateway
    if (fromTyk) {
      metrics.requestsByGateway.tyk++;
    } else if (fromKong) {
      metrics.requestsByGateway.kong++;
    } else {
      metrics.requestsByGateway.direct++;
    }

    // Contar por path
    if (!metrics.requestsByPath[path]) {
      metrics.requestsByPath[path] = 0;
    }
    metrics.requestsByPath[path]++;

    // Contar por operación
    if (path.includes('/suma')) metrics.requestsByOperation.suma++;
    if (path.includes('/resta')) metrics.requestsByOperation.resta++;
    if (path.includes('/multiplica')) metrics.requestsByOperation.multiplica++;
    if (path.includes('/divide')) metrics.requestsByOperation.divide++;
  }

  // Log de la petición
  console.log(`[${new Date().toISOString()}] ${req.method} ${req.path} ${fromTyk ? '(via Tyk)' : fromKong ? '(via Kong)' : '(direct)'}`);

  // Interceptar respuesta para calcular tiempo
  const originalJson = res.json;
  const originalSend = res.send;

  const finishRequest = function() {
    if (!isInternalCheck) {
      const duration = Date.now() - startTime;
      metrics.totalResponseTime += duration;

      // Contar éxitos y fallos
      if (res.statusCode >= 200 && res.statusCode < 400) {
        metrics.successRequests++;
      } else {
        metrics.failedRequests++;
      }
    }
  };

  res.json = function(data) {
    finishRequest();
    return originalJson.call(this, data);
  };

  res.send = function(data) {
    finishRequest();
    return originalSend.call(this, data);
  };

  next();
});

// ============================================
// HEALTH CHECK Y MÉTRICAS
// ============================================
app.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    service: 'calculator-gateway',
    microservices: {
      suma: CALC_SUMA_URL,
      resta: CALC_RESTA_URL,
      multiplica: CALC_MULTIPLICA_URL,
      divide: CALC_DIVIDE_URL,
      orquestador: CALC_ORQUESTADOR_URL
    }
  });
});

app.get('/metrics', (req, res) => {
  const uptime = (Date.now() - metrics.startTime) / 1000; // segundos
  const avgResponseTime = metrics.totalRequests > 0
    ? Math.round(metrics.totalResponseTime / metrics.totalRequests)
    : 0;

  res.json({
    timestamp: new Date().toISOString(),
    uptime: `${Math.floor(uptime)}s`,
    totalRequests: metrics.totalRequests,
    successRequests: metrics.successRequests,
    failedRequests: metrics.failedRequests,
    avgResponseTime: avgResponseTime,
    requestsByGateway: metrics.requestsByGateway,
    requestsByOperation: metrics.requestsByOperation,
    topPaths: Object.entries(metrics.requestsByPath)
      .sort((a, b) => b[1] - a[1])
      .slice(0, 10)
      .map(([path, count]) => ({ path, count }))
  });
});

app.get('/', (req, res) => {
  res.json({
    message: 'Calculator CORS Proxy',
    version: '2.0.0',
    description: 'CORS proxy for calculator microservices (web interface only)',
    purpose: 'Solves CORS issues when accessing microservices from browser',
    note: 'For API Gateway features, use Tyk (8080) or Kong (8000)',
    endpoints: {
      direct: {
        description: 'Direct access to microservices (no gateway)',
        suma: '/direct/suma?a=10&b=5',
        resta: '/direct/resta?a=20&b=8',
        multiplica: '/direct/multiplica?a=7&b=6',
        divide: '/direct/divide?a=100&b=5'
      },
      orchestrator: {
        description: 'Access through orchestrator microservice',
        suma: '/orchestrator/suma?a=10&b=5',
        resta: '/orchestrator/resta?a=20&b=8',
        multiplica: '/orchestrator/multiplica?a=7&b=6',
        divide: '/orchestrator/divide?a=100&b=5'
      },
      system: {
        health: '/health',
        metrics: '/metrics'
      }
    }
  });
});

// ============================================
// CALCULATOR ENDPOINTS (PROXY DIRECTO)
// ============================================

// Endpoint helper para hacer proxy
async function proxyToService(serviceUrl, path, query, res) {
  try {
    const startTime = Date.now();
    const url = `${serviceUrl}${path}?${new URLSearchParams(query).toString()}`;
    console.log(`  → Proxying to: ${url}`);

    const response = await axios.get(url, {
      timeout: 10000,
      headers: {
        'Accept': 'application/json'
      }
    });

    const duration = Date.now() - startTime;

    res.json({
      ...response.data,
      _meta: {
        responseTime: `${duration}ms`,
        service: serviceUrl,
        timestamp: new Date().toISOString()
      }
    });
  } catch (error) {
    console.error(`  ✗ Error proxying to ${serviceUrl}${path}:`, error.message);

    res.status(error.response?.status || 500).json({
      estado: 'ERROR',
      mensaje: `Error al conectar con el microservicio: ${error.message}`,
      resultado: -1,
      _meta: {
        service: serviceUrl,
        error: error.message,
        timestamp: new Date().toISOString()
      }
    });
  }
}

// ============================================
// DIRECT ACCESS ENDPOINTS (CORS Proxy only)
// ============================================
// These endpoints are ONLY for the web interface to avoid CORS issues
// They provide "direct" access to microservices without going through Tyk/Kong

// SUMA
app.get('/direct/suma', async (req, res) => {
  await proxyToService(CALC_SUMA_URL, '/suma/calculadora/suma', req.query, res);
});

// RESTA
app.get('/direct/resta', async (req, res) => {
  await proxyToService(CALC_RESTA_URL, '/resta/calculadora/resta', req.query, res);
});

// MULTIPLICA
app.get('/direct/multiplica', async (req, res) => {
  await proxyToService(CALC_MULTIPLICA_URL, '/multiplica/calculadora/multiplica', req.query, res);
});

// DIVIDE
app.get('/direct/divide', async (req, res) => {
  await proxyToService(CALC_DIVIDE_URL, '/divide/calculadora/divide', req.query, res);
});

// ============================================
// V2 ENDPOINTS - CALCULADORA CIENTÍFICA
// ============================================

// RAIZ CUADRADA
app.get('/direct/raiz', async (req, res) => {
  await proxyToService(CALC_RAIZ_URL, '/raiz/calculadora/raiz', req.query, res);
});

// POTENCIA
app.get('/direct/potencia', async (req, res) => {
  await proxyToService(CALC_POTENCIA_URL, '/potencia/calculadora/potencia', req.query, res);
});

// MODULO
app.get('/direct/modulo', async (req, res) => {
  await proxyToService(CALC_MODULO_URL, '/modulo/calculadora/modulo', req.query, res);
});

// LOGARITMO
app.get('/direct/logaritmo', async (req, res) => {
  await proxyToService(CALC_LOGARITMO_URL, '/logaritmo/calculadora/logaritmo', req.query, res);
});

// SENO
app.get('/direct/seno', async (req, res) => {
  await proxyToService(CALC_SENO_URL, '/seno/calculadora/seno', req.query, res);
});

// COSENO
app.get('/direct/coseno', async (req, res) => {
  await proxyToService(CALC_COSENO_URL, '/coseno/calculadora/coseno', req.query, res);
});

// TANGENTE
app.get('/direct/tangente', async (req, res) => {
  await proxyToService(CALC_TANGENTE_URL, '/tangente/calculadora/tangente', req.query, res);
});

// ============================================
// KONG VERSIONING - V1 ENDPOINTS (BASIC)
// ============================================

// V1 - Operaciones Básicas
app.get('/v1/direct/suma', async (req, res) => {
  await proxyToService(CALC_SUMA_URL, '/suma/calculadora/suma', req.query, res);
});

app.get('/v1/direct/resta', async (req, res) => {
  await proxyToService(CALC_RESTA_URL, '/resta/calculadora/resta', req.query, res);
});

app.get('/v1/direct/multiplica', async (req, res) => {
  await proxyToService(CALC_MULTIPLICA_URL, '/multiplica/calculadora/multiplica', req.query, res);
});

app.get('/v1/direct/divide', async (req, res) => {
  await proxyToService(CALC_DIVIDE_URL, '/divide/calculadora/divide', req.query, res);
});

// ============================================
// KONG VERSIONING - V2 ENDPOINTS (SCIENTIFIC)
// ============================================

// V2 - Operaciones Científicas
app.get('/v2/direct/raiz', async (req, res) => {
  await proxyToService(CALC_RAIZ_URL, '/raiz/calculadora/raiz', req.query, res);
});

app.get('/v2/direct/potencia', async (req, res) => {
  await proxyToService(CALC_POTENCIA_URL, '/potencia/calculadora/potencia', req.query, res);
});

app.get('/v2/direct/modulo', async (req, res) => {
  await proxyToService(CALC_MODULO_URL, '/modulo/calculadora/modulo', req.query, res);
});

app.get('/v2/direct/logaritmo', async (req, res) => {
  await proxyToService(CALC_LOGARITMO_URL, '/logaritmo/calculadora/logaritmo', req.query, res);
});

app.get('/v2/direct/seno', async (req, res) => {
  await proxyToService(CALC_SENO_URL, '/seno/calculadora/seno', req.query, res);
});

app.get('/v2/direct/coseno', async (req, res) => {
  await proxyToService(CALC_COSENO_URL, '/coseno/calculadora/coseno', req.query, res);
});

app.get('/v2/direct/tangente', async (req, res) => {
  await proxyToService(CALC_TANGENTE_URL, '/tangente/calculadora/tangente', req.query, res);
});

// ============================================
// ORCHESTRATOR ENDPOINTS
// ============================================

app.get('/orchestrator/suma', async (req, res) => {
  await proxyToService(CALC_ORQUESTADOR_URL, '/calculadora/calc/suma', req.query, res);
});

app.get('/orchestrator/resta', async (req, res) => {
  await proxyToService(CALC_ORQUESTADOR_URL, '/calculadora/calc/resta', req.query, res);
});

app.get('/orchestrator/multiplica', async (req, res) => {
  await proxyToService(CALC_ORQUESTADOR_URL, '/calculadora/calc/multiplica', req.query, res);
});

app.get('/orchestrator/divide', async (req, res) => {
  await proxyToService(CALC_ORQUESTADOR_URL, '/calculadora/calc/divide', req.query, res);
});

// ============================================
// ENDPOINTS ESPECIALES PARA TESTING
// ============================================

// Endpoint para probar caching (con y sin delay)
app.get('/calc/suma/cached', async (req, res) => {
  // Simular operación más lenta para ver diferencia de cache
  await new Promise(resolve => setTimeout(resolve, 500));
  await proxyToService(CALC_SUMA_URL, '/suma/calculadora/suma', req.query, res);
});

app.get('/calc/suma/nocache', async (req, res) => {
  // Agregar timestamp para evitar cache
  const query = { ...req.query, _t: Date.now() };
  await new Promise(resolve => setTimeout(resolve, 500));
  await proxyToService(CALC_SUMA_URL, '/suma/calculadora/suma', query, res);
});

// Operación costosa (para testing de rate limiting)
app.get('/calc/expensive', async (req, res) => {
  const start = Date.now();
  const { a, b, operation } = req.query;

  // Simular operación muy pesada
  let result = 0;
  for (let i = 0; i < 50000000; i++) {
    result += Math.sqrt(i);
  }

  // Luego hacer la operación real
  let serviceUrl, path;
  switch(operation) {
    case 'multiplica':
      serviceUrl = CALC_MULTIPLICA_URL;
      path = '/multiplica/calculadora/multiplica';
      break;
    case 'divide':
      serviceUrl = CALC_DIVIDE_URL;
      path = '/divide/calculadora/divide';
      break;
    default:
      serviceUrl = CALC_SUMA_URL;
      path = '/suma/calculadora/suma';
  }

  try {
    const response = await axios.get(
      `${serviceUrl}${path}?a=${a}&b=${b}`,
      { timeout: 10000 }
    );

    const duration = Date.now() - start;

    res.json({
      ...response.data,
      _meta: {
        computationTime: `${duration}ms`,
        message: 'Expensive operation completed',
        timestamp: new Date().toISOString()
      }
    });
  } catch (error) {
    res.status(500).json({
      estado: 'ERROR',
      mensaje: error.message,
      resultado: -1
    });
  }
});

// Endpoint con delay configurable (para testing de timeouts)
app.get('/calc/slow', async (req, res) => {
  const delay = parseInt(req.query.delay) || 3000;
  const { a, b, operation } = req.query;

  await new Promise(resolve => setTimeout(resolve, delay));

  let serviceUrl, path;
  switch(operation) {
    case 'resta':
      serviceUrl = CALC_RESTA_URL;
      path = '/resta/calculadora/resta';
      break;
    case 'multiplica':
      serviceUrl = CALC_MULTIPLICA_URL;
      path = '/multiplica/calculadora/multiplica';
      break;
    case 'divide':
      serviceUrl = CALC_DIVIDE_URL;
      path = '/divide/calculadora/divide';
      break;
    default:
      serviceUrl = CALC_SUMA_URL;
      path = '/suma/calculadora/suma';
  }

  await proxyToService(serviceUrl, path, { a, b }, res);
});

// Endpoint que falla aleatoriamente (para testing de circuit breaker)
let failureCounter = 0;
app.get('/calc/flaky', async (req, res) => {
  failureCounter++;
  const { a, b, operation } = req.query;

  // Falla 50% de las veces
  if (failureCounter % 2 === 0) {
    return res.status(503).json({
      estado: 'ERROR',
      mensaje: 'Servicio temporalmente no disponible',
      resultado: -1,
      _meta: {
        attempt: failureCounter,
        timestamp: new Date().toISOString()
      }
    });
  }

  let serviceUrl, path;
  switch(operation) {
    case 'resta':
      serviceUrl = CALC_RESTA_URL;
      path = '/resta/calculadora/resta';
      break;
    case 'multiplica':
      serviceUrl = CALC_MULTIPLICA_URL;
      path = '/multiplica/calculadora/multiplica';
      break;
    case 'divide':
      serviceUrl = CALC_DIVIDE_URL;
      path = '/divide/calculadora/divide';
      break;
    default:
      serviceUrl = CALC_SUMA_URL;
      path = '/suma/calculadora/suma';
  }

  await proxyToService(serviceUrl, path, { a, b }, res);
});

// ============================================
// MANEJO DE ERRORES GLOBAL
// ============================================
app.use((err, req, res, next) => {
  console.error('Error:', err);
  res.status(500).json({
    estado: 'ERROR',
    mensaje: 'Error interno del servidor',
    resultado: -1,
    error: err.message
  });
});

// 404 Handler
app.use((req, res) => {
  res.status(404).json({
    estado: 'ERROR',
    mensaje: 'Endpoint no encontrado',
    resultado: -1,
    path: req.path,
    method: req.method
  });
});

// ============================================
// SERVIDOR
// ============================================
app.listen(PORT, () => {
  console.log(`====================================`);
  console.log(`Calculator CORS Proxy is running`);
  console.log(`Port: ${PORT}`);
  console.log(`Purpose: Solve CORS issues for web UI`);
  console.log(`Environment: ${process.env.NODE_ENV || 'development'}`);
  console.log(`Time: ${new Date().toISOString()}`);
  console.log(`====================================`);
  console.log(`Microservices URLs:`);
  console.log(`  SUMA:        ${CALC_SUMA_URL}`);
  console.log(`  RESTA:       ${CALC_RESTA_URL}`);
  console.log(`  MULTIPLICA:  ${CALC_MULTIPLICA_URL}`);
  console.log(`  DIVIDE:      ${CALC_DIVIDE_URL}`);
  console.log(`  ORQUESTADOR: ${CALC_ORQUESTADOR_URL}`);
  console.log(`====================================`);
  console.log(`Main endpoints (for web UI):`);
  console.log(`  GET  /direct/suma?a=10&b=5`);
  console.log(`  GET  /direct/resta?a=20&b=8`);
  console.log(`  GET  /direct/multiplica?a=7&b=6`);
  console.log(`  GET  /direct/divide?a=100&b=5`);
  console.log(`  GET  /orchestrator/suma?a=10&b=5`);
  console.log(``);
  console.log(`System endpoints:`);
  console.log(`  GET  /health`);
  console.log(`  GET  /metrics`);
  console.log(`====================================`);
  console.log(`Note: For API Gateway features, use:`);
  console.log(`  - Tyk Gateway: http://localhost:8080`);
  console.log(`  - Kong Gateway: http://localhost:8000`);
  console.log(`====================================`);
});
