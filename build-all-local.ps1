"# =============================================================================
# GDMC-EU — Build de todos os serviços para Docker local (Windows/PowerShell)
# =============================================================================
# Pre-req: Java 11, Gradle, Docker
# Uso: .\build-all-local.ps1
# =============================================================================

$ErrorActionPreference = "Continue"

function Build-Service {
    param(
        [string]$Dir,
        [string]$JarSubdir,
        [string]$JarName,
        [string]$ImageName,
        [string]$Port
    )

    Write-Host "[INFO] === Building $Dir (port $Port) ===" -ForegroundColor Green

    Push-Location $Dir

    # Gradle build
    if (Test-Path "gradlew") {
        & .\gradlew clean build -x test -x integrationTest 2>$null
    } elseif (Test-Path "gradlew.bat") {
        & .\gradlew.bat clean build -x test -x integrationTest 2>$null
    } else {
        Write-Host "[WARN] $Dir : no gradlew found, trying gradle" -ForegroundColor Yellow
        & gradle clean build -x test -x integrationTest
    }

    if ($LASTEXITCODE -ne 0) {
        Write-Host "[WARN] $Dir : gradle build failed" -ForegroundColor Yellow
    }

    # Docker image
    if (Test-Path "Dockerfile-local") {
        & docker build -f Dockerfile-local -t "gdmc/${ImageName}:local" .
    } else {
        $jarPath = "$JarSubdir/build/libs/$JarName"
        if (Test-Path $jarPath) {
            $dfContent = @"
FROM openjdk:11-jdk-slim-buster
COPY $jarPath /app/service.jar
ENTRYPOINT ["java", "-jar", "-Xms512m", "-Xmx512m", "/app/service.jar"]
"@
            $dfContent | Out-File -FilePath "Dockerfile.generated" -Encoding ascii
            & docker build -f Dockerfile.generated -t "gdmc/${ImageName}:local" .
            Remove-Item "Dockerfile.generated" -ErrorAction SilentlyContinue
        } else {
            Write-Host "[WARN] $Dir : jar not found at $jarPath" -ForegroundColor Yellow
        }
    }

    Pop-Location
    Write-Host "[INFO] $Dir done" -ForegroundColor Green
}

# 0. Publicar common-lib
Write-Host "[INFO] Publishing common-lib to mavenLocal..." -ForegroundColor Cyan
Push-Location "common-lib"
& .\gradlew clean publishToMavenLocal -x test 2>$null
Pop-Location

# 1. Publicar clients
$clientServices = @(
    "app-server", "org-user", "master-data", "channel-data-center", "leads",
    "sales-order", "purchase-order", "inventory", "transport-order", "payment",
    "campaign", "consent", "retail", "warranty", "technical", "report",
    "sap-integration", "wms-integration", "mdm-integration", "gbom-integration",
    "idms-integration", "call-center-integration", "imp-exp", "workflow", "notification"
)

foreach ($svc in $clientServices) {
    if (Test-Path $svc) {
        Write-Host "[INFO] Publishing $svc-client" -ForegroundColor Cyan
        Push-Location $svc
        if (Test-Path "gradlew") {
            & .\gradlew clean publishToMavenLocal -x test -x integrationTest 2>$null
        }
        Pop-Location
    }
}

# 2. Build services em ordem de dependencia
Build-Service -Dir "app-server" -JarSubdir "app-server-service" -JarName "app-server-service-1.0.0.jar" -ImageName "app-server" -Port "8033"

# Core
Build-Service -Dir "org-user" -JarSubdir "org-user-service" -JarName "org-user-service-1.0.0.jar" -ImageName "org-user" -Port "8079"
Build-Service -Dir "master-data" -JarSubdir "master-data-service" -JarName "master-data-service-1.0.0.jar" -ImageName "master-data" -Port "8075"
Build-Service -Dir "channel-data-center" -JarSubdir "channel-data-center-service" -JarName "channel-data-center-service-1.0.0.jar" -ImageName "channel-data-center" -Port "8078"
Build-Service -Dir "leads" -JarSubdir "leads-service" -JarName "leads-service-1.0.0.jar" -ImageName "leads" -Port "8077"

# Business
Build-Service -Dir "sales-order" -JarSubdir "sales-order-service" -JarName "sales-order-service-1.0.0.jar" -ImageName "sales-order" -Port "8091"
Build-Service -Dir "purchase-order" -JarSubdir "purchase-order-service" -JarName "purchase-order-service-1.0.0.jar" -ImageName "purchase-order" -Port "8090"
Build-Service -Dir "inventory" -JarSubdir "inventory-service" -JarName "inventory-service-1.0.0.jar" -ImageName "inventory" -Port "8092"
Build-Service -Dir "transport-order" -JarSubdir "transport-order-service" -JarName "transport-order-service-1.0.0.jar" -ImageName "transport-order" -Port "8093"
Build-Service -Dir "payment" -JarSubdir "payment-service" -JarName "payment-service-1.0.0.jar" -ImageName "payment" -Port "8094"
Build-Service -Dir "campaign" -JarSubdir "campaign-service" -JarName "campaign-service-1.0.0.jar" -ImageName "campaign" -Port "8095"
Build-Service -Dir "consent" -JarSubdir "consent-service" -JarName "consent-service-1.0.0.jar" -ImageName "consent" -Port "8096"
Build-Service -Dir "retail" -JarSubdir "retail-service" -JarName "retail-service-1.0.0.jar" -ImageName "retail" -Port "8097"
Build-Service -Dir "warranty" -JarSubdir "warranty-service" -JarName "warranty-service-1.0.0.jar" -ImageName "warranty" -Port "8098"
Build-Service -Dir "technical" -JarSubdir "technical-service" -JarName "technical-service-1.0.0.jar" -ImageName "technical" -Port "8099"
Build-Service -Dir "report" -JarSubdir "report-service" -JarName "report-service-1.0.0.jar" -ImageName "report" -Port "8088"

# Integracoes
Build-Service -Dir "sap-integration" -JarSubdir "sap-integration-service" -JarName "sap-integration-service-1.0.0.jar" -ImageName "sap-integration" -Port "9010"
Build-Service -Dir "wms-integration" -JarSubdir "wms-integration-service" -JarName "wms-integration-service-1.0.0.jar" -ImageName "wms-integration" -Port "9011"
Build-Service -Dir "mdm-integration" -JarSubdir "mdm-integration-service" -JarName "mdm-integration-service-1.0.0.jar" -ImageName "mdm-integration" -Port "9012"
Build-Service -Dir "gbom-integration" -JarSubdir "gbom-integration-service" -JarName "gbom-integration-service-1.0.0.jar" -ImageName "gbom-integration" -Port "9013"
Build-Service -Dir "idms-integration" -JarSubdir "idms-integration-service" -JarName "idms-integration-service-1.0.0.jar" -ImageName "idms-integration" -Port "9014"
Build-Service -Dir "call-center-integration" -JarSubdir "call-center-integration-service" -JarName "call-center-integration-service-1.0.0.jar" -ImageName "call-center-integration" -Port "9015"
Build-Service -Dir "imp-exp" -JarSubdir "imp-exp-service" -JarName "imp-exp-service-1.0.0.jar" -ImageName "imp-exp" -Port "9016"

# Workflow
Build-Service -Dir "workflow" -JarSubdir "workflow-service" -JarName "workflow-service-1.0.0.jar" -ImageName "workflow" -Port "8102"

# BFFs
Build-Service -Dir "web-bff" -JarSubdir "web-bff" -JarName "web-bff-1.0.0.jar" -ImageName "web-bff" -Port "80"
Build-Service -Dir "mobile-bff" -JarSubdir "mobile-bff" -JarName "mobile-bff-0.1.1-SNAPSHOT.jar" -ImageName "mobile-bff" -Port "80"

# Gateway
Build-Service -Dir "api-gateway" -JarSubdir "api-gateway" -JarName "api-gateway-2.0.0-SNAPSHOT.jar" -ImageName "api-gateway" -Port "8080"

# DB Flyway
Build-Service -Dir "db-flyway" -JarSubdir "db-flyway-service" -JarName "db-flyway-service-2.0.0-SNAPSHOT.jar" -ImageName "db-flyway" -Port "8033"

# Workflow Engine (Maven)
Write-Host "[INFO] === Building workflow-engine (Maven) ===" -ForegroundColor Green
Push-Location "workflow-engine"
if (Test-Path "mvnw") {
    & .\mvnw clean package -DskipTests 2>$null
    if (Test-Path "Dockerfile-local") {
        & docker build -f Dockerfile-local -t "gdmc/workflow-engine:local" .
    }
}
Pop-Location

# Frontend
Write-Host "[INFO] === Building web frontend ===" -ForegroundColor Green
Push-Location "web"
if (Test-Path "package.json") {
    & npm install
    & npm run build:beta 2>$null
    if ($LASTEXITCODE -ne 0) { & npm run build }
    # Docker image
    $nginxDf = @"
FROM nginx:alpine
COPY dist/ /usr/share/nginx/html/
"@
    $nginxDf | Out-File -FilePath "Dockerfile.nginx" -Encoding ascii
    & docker build -f Dockerfile.nginx -t "gdmc/web-frontend:local" .
    Remove-Item "Dockerfile.nginx" -ErrorAction SilentlyContinue
}
Pop-Location

Write-Host ""
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "Build completo! Execute:" -ForegroundColor Cyan
Write-Host "  docker-compose -f docker-compose-local.yml up -d" -ForegroundColor White
Write-Host "=============================================" -ForegroundColor Cyan