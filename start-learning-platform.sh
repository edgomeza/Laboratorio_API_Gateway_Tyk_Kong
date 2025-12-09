#!/bin/bash
#########################################
# API Gateway Learning Platform - Startup Script
# Starts all services and the exercise watcher
#########################################

set -e

echo "======================================"
echo "  API Gateway Learning Platform"
echo "  Tyk & Kong Interactive Tutorial"
echo "======================================"
echo ""

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker first."
    exit 1
fi

echo "🚀 Starting services..."
echo ""

# Create necessary directories
mkdir -p gateway-configs/tyk/apps-active

# Start Docker Compose services
if command -v docker compose &> /dev/null; then
    docker compose up -d
else
    docker compose up -d
fi

echo ""
echo "⏳ Waiting for services to be healthy..."
sleep 10

# Check service health
check_service() {
    local name=$1
    local url=$2

    if curl -s "$url" > /dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} $name is running"
        return 0
    else
        echo -e "${YELLOW}⏳${NC} $name is starting..."
        return 1
    fi
}

echo ""
echo "🏥 Health Checks:"
check_service "Backend API      " "http://localhost:3000/health" || true
check_service "Web Frontend     " "http://localhost:80" || true
check_service "Tyk Gateway      " "http://localhost:8080/hello" || true
check_service "Kong Gateway     " "http://localhost:8001" || true

echo ""
echo "🌐 Configuring CORS for Kong Gateway..."
if [ -f "./scripts/configure-kong-cors.sh" ]; then
    chmod +x ./scripts/configure-kong-cors.sh
    ./scripts/configure-kong-cors.sh
else
    echo -e "${YELLOW}⚠️  CORS configuration script not found. You may need to configure CORS manually.${NC}"
fi

echo ""
echo "======================================"
echo -e "${GREEN}✨ Platform is ready!${NC}"
echo "======================================"
echo ""
echo "📚 Access the Learning Platform:"
echo -e "   ${BLUE}http://localhost${NC}"
echo ""
echo "🔧 API Gateways:"
echo "   Tyk:  http://localhost:8080"
echo "   Kong: http://localhost:8000"
echo ""
echo "💻 Backend API:"
echo "   http://localhost:3000"
echo ""
echo "📝 Next Steps:"
echo "   1. Open http://localhost in your browser"
echo "   2. Follow the interactive tutorials"
echo "   3. Complete exercises by uncommenting config files"
echo ""
echo "🔍 To start the exercise watcher (in a new terminal):"
echo "   ./scripts/watch-exercises.sh"
echo ""
echo "📊 View logs:"
echo "   docker compose logs -f"
echo ""
echo "🛑 Stop the platform:"
echo "   docker compose down"
echo ""
