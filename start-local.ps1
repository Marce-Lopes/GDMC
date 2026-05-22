"# =============================================================================
# GDMC-EU — Quick Start Local (PowerShell)
# =============================================================================
# Sobe toda a plataforma local em ordem correta
# Uso: .\start-local.ps1
# =============================================================================

$dc = "docker-compose"
$dcFile = "-f docker-compose-local.yml"

function Wait-Healthy {
    param([string]$Service, [int]$TimeoutSeconds = 60)
    Write-Host "[INFO] Waiting for $Service to be healthy..." -ForegroundColor Cyan
    $elapsed = 0
    while ($elapsed -lt $TimeoutSeconds) {
        $status = (& $dc $dcFile ps $Service 2>$null | Select-String "healthy")
        if ($status) {
            Write-Host "[OK] $Service is healthy" -ForegroundColor Green
            return
        }
        Start-Sleep -Seconds 2
        $elapsed += 2
    }
    Write-Host "[WARN] $Service not healthy after ${TimeoutSeconds}s, continuing..." -ForegroundColor Yellow
}

function Wait-Port {
    param([string]$Host = "localhost", [int]$Port, [int]$TimeoutSeconds = 30)
    $elapsed = 0
    while ($elapsed -lt $TimeoutSeconds) {
        try {
            $tcp = New-Object System.Net.Sockets.TcpClient
            $tcp.Connect($Host, $Port)
            $tcp.Close()
            return $true
        } catch {
            Start-Sleep -Seconds 2
            $elapsed += 2
        }
    }
    return $false
}

Write-Host ""
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "  GDMC-EU — Plataforma Montadora (Local)    " -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""

# 1. Infra
Write-Host "[1/7] Subindo infraestrutura (MySQL, Redis, Kafka)..." -ForegroundColor Yellow
& $dc $dcFile up -d mysql redis zookeeper kafka
Start-Sleep -Seconds 5
Wait-Healthy -Service "mysql" -TimeoutSeconds 60

# 2. XXL-Job
Write-Host "[2/7] Subindo XXL-Job Admin..." -ForegroundColor Yellow
& $dc $dcFile up -d xxl-job-admin
Start-Sleep -Seconds 10

# 3. Core Services
Write-Host "[3/7] Subindo Core Services..." -ForegroundColor Yellow
& $dc $dcFile up -d master-data org-user channel-data-center leads
Start-Sleep -Seconds 15

# 4. Business Services
Write-Host "[4/7] Subindo Business Services..." -ForegroundColor Yellow
& $dc $dcFile up -d sales-order purchase-order inventory transport-order `
    payment campaign consent retail warranty technical report after-sale-problem
Start-Sleep -Seconds 15

# 5. Integracoes (stub)
Write-Host "[5/7] Subindo Integracoes (stub local)..." -ForegroundColor Yellow
& $dc $dcFile up -d sap-integration wms-integration mdm-integration `
    gbom-integration idms-integration call-center-integration imp-exp
Start-Sleep -Seconds 10

# 6. Workflow + BFFs + Gateway
Write-Host "[6/7] Subindo Workflow, BFFs e Gateway..." -ForegroundColor Yellow
& $dc $dcFile up -d workflow workflow-engine web-bff mobile-bff api-gateway
Start-Sleep -Seconds 10

# 7. Frontend
Write-Host "[7/7] Subindo Frontend..." -ForegroundColor Yellow
& $dc $dcFile up -d web-frontend

Write-Host ""
Write-Host "=============================================" -ForegroundColor Green
Write-Host "  Plataforma GDMC-EU rodando!" -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Green
Write-Host ""
Write-Host "  Frontend:     http://localhost:3000" -ForegroundColor White
Write-Host "  API Gateway:  http://localhost:8000" -ForegroundColor White
Write-Host "  Web BFF:      http://localhost:8001" -ForegroundColor White
Write-Host "  Mobile BFF:   http://localhost:8002" -ForegroundColor White
Write-Host "  XXL-Job:      http://localhost:8494" -ForegroundColor White
Write-Host ""
Write-Host "  Status: .\status-local.ps1" -ForegroundColor Gray
Write-Host "  Stop:   docker-compose -f docker-compose-local.yml down" -ForegroundColor Gray
Write-Host ""