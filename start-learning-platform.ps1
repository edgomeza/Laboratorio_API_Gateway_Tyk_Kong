# ==========================================
# API Gateway Learning Platform - Windows
# PowerShell Startup Script
# ==========================================

# Colors for output
$ESC = [char]27
$GREEN = "$ESC[32m"
$BLUE = "$ESC[34m"
$YELLOW = "$ESC[33m"
$NC = "$ESC[0m"

Write-Host "======================================" -ForegroundColor Cyan
Write-Host "  API Gateway Learning Platform" -ForegroundColor Cyan
Write-Host "  Tyk & Kong Interactive Tutorial" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""

# Check if Docker is running
try {
    docker info | Out-Null
} catch {
    Write-Host "Docker is not running. Please start Docker Desktop first." -ForegroundColor Red
    exit 1
}

Write-Host "Starting services..." -ForegroundColor Green
Write-Host ""

# Create necessary directories
New-Item -ItemType Directory -Force -Path "gateway-configs/tyk/apps-active" | Out-Null

# Start Docker Compose services
if (Get-Command docker-compose -ErrorAction SilentlyContinue) {
    docker-compose up -d
} else {
    docker compose up -d
}

Write-Host ""
Write-Host "Waiting for services to be healthy..." -ForegroundColor Yellow
Start-Sleep -Seconds 10

# Function to check service health
function Test-Service {
    param (
        [string]$Name,
        [string]$Url
    )

    try {
        $response = Invoke-WebRequest -Uri $Url -UseBasicParsing -TimeoutSec 5 -ErrorAction SilentlyContinue
        Write-Host "$Name is running" -ForegroundColor Green
        return $true
    } catch {
        Write-Host "$Name is starting..." -ForegroundColor Yellow
        return $false
    }
}

Write-Host ""
Write-Host "Health Checks:" -ForegroundColor Cyan
Test-Service "Backend API      " "http://localhost:3000/health" | Out-Null
Test-Service "Web Frontend     " "http://localhost:80" | Out-Null
Test-Service "Tyk Gateway      " "http://localhost:8080/hello" | Out-Null
Test-Service "Kong Gateway     " "http://localhost:8001" | Out-Null

Write-Host ""
Write-Host "Configuring CORS for Kong Gateway..." -ForegroundColor Cyan
if (Test-Path ".\scripts\configure-kong-cors.ps1") {
    & ".\scripts\configure-kong-cors.ps1"
} else {
    Write-Host "CORS configuration script not found. You may need to configure CORS manually." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "======================================" -ForegroundColor Cyan
Write-Host "Platform is ready!" -ForegroundColor Green
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Access the Learning Platform:" -ForegroundColor Yellow
Write-Host "   http://localhost" -ForegroundColor Blue
Write-Host ""
Write-Host "API Gateways:" -ForegroundColor Yellow
Write-Host "   Tyk:  http://localhost:8080"
Write-Host "   Kong: http://localhost:8000"
Write-Host ""
Write-Host "Backend API:" -ForegroundColor Yellow
Write-Host "   http://localhost:3000"
Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Yellow
Write-Host "   1. Open http://localhost in your browser"
Write-Host "   2. Follow the interactive tutorials"
Write-Host "   3. Complete exercises by uncommenting config files"
Write-Host ""
Write-Host "To start the exercise watcher (in a new PowerShell window):" -ForegroundColor Yellow
Write-Host "   .\scripts\watch-exercises.ps1"
Write-Host ""
Write-Host "View logs:" -ForegroundColor Yellow
Write-Host "   docker-compose logs -f"
Write-Host ""
Write-Host "Stop the platform:" -ForegroundColor Yellow
Write-Host "   docker-compose down"
Write-Host ""
