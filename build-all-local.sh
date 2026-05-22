#!/bin/bash
# =============================================================================
# GDMC-EU — Build de todos os serviços para Docker local
# =============================================================================
# Pré-requisitos: Java 11, Gradle, Docker
# Uso: ./build-all-local.sh
# =============================================================================

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info()  { echo -e "${GREEN}[INFO]${NC}  $1"; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC}  $1"; }
log_err()   { echo -e "${RED}[ERR]${NC}   $1"; }

# ── 1. Publicar common-lib no Maven Local ──────────────────────────────────
log_info "Publicando common-lib no mavenLocal..."
cd common-lib
./gradlew clean publishToMavenLocal -x test -x integrationTest || log_warn "common-lib: publish falhou (pode já existir no cache)"
cd ..

# ── 2. Função de build+docker ─────────────────────────────────────────────
build_service() {
    local dir=$1
    local jar_subdir=$2   # caminho relativo do jar dentro do projeto
    local jar_name=$3     # nome do jar final
    local image_name=$4   # nome da imagem docker
    local port=$5         # porta (apenas informativo)

    log_info "━━━ Building $dir (port $port) ━━━"
    cd "$dir"

    # Gradle build
    ./gradlew clean build -x test -x integrationTest 2>/dev/null || {
        log_warn "$dir: gradle build falhou, tentando sem wrapper..."
        gradle clean build -x test -x integrationTest || {
            log_err "$dir: BUILD FALHOU!"
            cd ..
            return 1
        }
    }

    # Docker image
    if [ -f "Dockerfile-local" ]; then
        docker build -f Dockerfile-local -t "gdmc/${image_name}:local" . || log_warn "$dir: docker build falhou"
    else
        # Fallback: criar imagem genérica
        local jar_path="${jar_subdir}/build/libs/${jar_name}"
        if [ -f "$jar_path" ]; then
            docker build -t "gdmc/${image_name}:local" - <<EOF
FROM openjdk:11-jdk-slim-buster
COPY $jar_path /app/service.jar
ENTRYPOINT ["java", "-jar", "-Xms512m", "-Xmx512m", "/app/service.jar"]
EOF
        else
            log_warn "$dir: jar não encontrado em $jar_path"
        fi
    fi

    cd ..
    log_info "$dir ✓"
}

# ── 3. Build em ordem de dependência ──────────────────────────────────────

# Camada 0: app-server (client usado por vários serviços)
build_service "app-server" "app-server-service" "app-server-service-1.0.0.jar" "app-server" "8033"

# Camada 1: Core services (sem dependência entre si, mas dependem de common-lib)
build_service "org-user" "org-user-service" "org-user-service-1.0.0.jar" "org-user" "8079"
build_service "master-data" "master-data-service" "master-data-service-1.0.0.jar" "master-data" "8075"
build_service "channel-data-center" "channel-data-center-service" "channel-data-center-service-1.0.0.jar" "channel-data-center" "8078"
build_service "leads" "leads-service" "leads-service-1.0.0.jar" "leads" "8077"

# Camada 2: Business services (dependem de core)
build_service "sales-order" "sales-order-service" "sales-order-service-1.0.0.jar" "sales-order" "8091"
build_service "purchase-order" "purchase-order-service" "purchase-order-service-1.0.0.jar" "purchase-order" "8090"
build_service "inventory" "inventory-service" "inventory-service-1.0.0.jar" "inventory" "8092"
build_service "transport-order" "transport-order-service" "transport-order-service-1.0.0.jar" "transport-order" "8093"
build_service "payment" "payment-service" "payment-service-1.0.0.jar" "payment" "8094"
build_service "campaign" "campaign-service" "campaign-service-1.0.0.jar" "campaign" "8095"
build_service "consent" "consent-service" "consent-service-1.0.0.jar" "consent" "8096"
build_service "retail" "retail-service" "retail-service-1.0.0.jar" "retail" "8097"
build_service "warranty" "warranty-service" "warranty-service-1.0.0.jar" "warranty" "8098"
build_service "technical" "technical-service" "technical-service-1.0.0.jar" "technical" "8099"
build_service "report" "report-service" "report-service-1.0.0.jar" "report" "8088"
build_service "after-sale-problem" "problem-api" "problem-api-1.0.0.jar" "after-sale-problem" "8100"

# Camada 3: Integrações (stubs locais)
build_service "sap-integration" "sap-integration-service" "sap-integration-service-1.0.0.jar" "sap-integration" "9010"
build_service "wms-integration" "wms-integration-service" "wms-integration-service-1.0.0.jar" "wms-integration" "9011"
build_service "mdm-integration" "mdm-integration-service" "mdm-integration-service-1.0.0.jar" "mdm-integration" "9012"
build_service "gbom-integration" "gbom-integration-service" "gbom-integration-service-1.0.0.jar" "gbom-integration" "9013"
build_service "idms-integration" "idms-integration-service" "idms-integration-service-1.0.0.jar" "idms-integration" "9014"
build_service "call-center-integration" "call-center-integration-service" "call-center-integration-service-1.0.0.jar" "call-center-integration" "9015"
build_service "imp-exp" "imp-exp-service" "imp-exp-service-1.0.0.jar" "imp-exp" "9016"

# Camada 4: Workflow
build_service "workflow" "workflow-service" "workflow-service-1.0.0.jar" "workflow" "8102"

# Camada 5: BFFs
build_service "web-bff" "web-bff" "web-bff-1.0.0.jar" "web-bff" "80"
build_service "mobile-bff" "mobile-bff" "mobile-bff-0.1.1-SNAPSHOT.jar" "mobile-bff" "80"

# Camada 6: Gateway
build_service "api-gateway" "api-gateway" "api-gateway-2.0.0-SNAPSHOT.jar" "api-gateway" "8080"

# Camada 7: DB Flyway
build_service "db-flyway" "db-flyway-service" "db-flyway-service-2.0.0-SNAPSHOT.jar" "db-flyway" "8033"

# ── 4. Frontend ───────────────────────────────────────────────────────────
log_info "━━━ Building web frontend ━━━"
cd web
if [ -f "package.json" ]; then
    npm install
    npm run build:beta 2>/dev/null || npm run build || log_warn "web: build falhou"
    # Docker image para frontend
    docker build -t gdmc/web-frontend:local - <<'EOF'
FROM nginx:alpine
COPY dist/ /usr/share/nginx/html/
EOF
fi
cd ..

# ── 5. Workflow Engine (Maven) ────────────────────────────────────────────
log_info "━━━ Building workflow-engine (Maven) ━━━"
cd workflow-engine
if [ -f "mvnw" ]; then
    ./mvnw clean package -DskipTests || log_warn "workflow-engine: maven build falhou"
    docker build -f Dockerfile-local -t gdmc/workflow-engine:local . || log_warn "workflow-engine: docker build falhou"
fi
cd ..

log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log_info "Build completo! Execute:"
log_info "  docker-compose -f docker-compose-local.yml up -d"
log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"