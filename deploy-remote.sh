"#!/bin/bash
# =============================================================================
# GDMC-EU — Deploy remoto em Linux
# =============================================================================
# Uso:
#   1. Copiar este repo inteiro para o Linux (rsync/scp)
#   2. ./deploy-remote.sh build    # faz build de tudo
#   3. ./deploy-remote.sh infra    # sobe MySQL, Redis, Kafka
#   4. ./deploy-remote.sh core     # sobe serviços core
#   5. ./deploy-remote.sh business # sobe serviços de negócio
#   6. ./deploy-remote.sh all      # sobe tudo
#   7. ./deploy-remote.sh status   # health check
#   8. ./deploy-remote.sh down     # desce tudo
# =============================================================================

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

DC_FILE="docker-compose-linux.yml"
COMPOSE="docker-compose -f $DC_FILE"

log_info()  { echo -e "${GREEN}[INFO]${NC}  $1"; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC}  $1"; }
log_err()   { echo -e "${RED}[ERR]${NC}   $1"; }

# ── BUILD ──────────────────────────────────────────────────────────────────
do_build() {
    log_info "Publicando common-lib no mavenLocal..."
    cd common-lib
    ./gradlew clean publishToMavenLocal -x test -x integrationTest 2>/dev/null || log_warn "common-lib: falhou"
    cd ..

    log_info "Publicando clients no mavenLocal..."
    for svc in app-server org-user master-data channel-data-center leads \
               sales-order purchase-order inventory transport-order payment \
               campaign consent retail warranty technical report \
               sap-integration wms-integration mdm-integration gbom-integration \
               idms-integration call-center-integration imp-exp workflow notification; do
        if [ -d "$svc" ]; then
            echo "  → $svc-client"
            cd "$svc"
            ./gradlew clean publishToMavenLocal -x test -x integrationTest 2>/dev/null || true
            cd ..
        fi
    done

    log_info "Building serviços..."
    build_svc() {
        local dir=$1 jar_sub=$2 jar_name=$3 img=$4
        log_info "Building $dir..."
        cd "$dir"
        ./gradlew clean build -x test -x integrationTest 2>/dev/null || log_warn "$dir: build falhou"
        if [ -f "Dockerfile-local" ]; then
            docker build -f Dockerfile-local -t "gdmc/${img}:local" . 2>/dev/null || log_warn "$dir: docker falhou"
        else
            local jar_path="${jar_sub}/build/libs/${jar_name}"
            if [ -f "$jar_path" ]; then
                docker build -t "gdmc/${img}:local" - <<<"FROM openjdk:11-jdk-slim-buster
COPY ${jar_path} /app/service.jar
ENTRYPOINT [\"java\", \"-jar\", \"-Xms256m\", \"-Xmx256m\", \"/app/service.jar\"]"
            fi
        fi
        cd ..
    }

    # Ordem de dependência
    build_svc "app-server" "app-server-service" "app-server-service-1.0.0.jar" "app-server"
    build_svc "org-user" "org-user-service" "org-user-service-1.0.0.jar" "org-user"
    build_svc "master-data" "master-data-service" "master-data-service-1.0.0.jar" "master-data"
    build_svc "channel-data-center" "channel-data-center-service" "channel-data-center-service-1.0.0.jar" "channel-data-center"
    build_svc "leads" "leads-service" "leads-service-1.0.0.jar" "leads"
    build_svc "sales-order" "sales-order-service" "sales-order-service-1.0.0.jar" "sales-order"
    build_svc "purchase-order" "purchase-order-service" "purchase-order-service-1.0.0.jar" "purchase-order"
    build_svc "inventory" "inventory-service" "inventory-service-1.0.0.jar" "inventory"
    build_svc "transport-order" "transport-order-service" "transport-order-service-1.0.0.jar" "transport-order"
    build_svc "payment" "payment-service" "payment-service-1.0.0.jar" "payment"
    build_svc "campaign" "campaign-service" "campaign-service-1.0.0.jar" "campaign"
    build_svc "consent" "consent-service" "consent-service-1.0.0.jar" "consent"
    build_svc "retail" "retail-service" "retail-service-1.0.0.jar" "retail"
    build_svc "warranty" "warranty-service" "warranty-service-1.0.0.jar" "warranty"
    build_svc "technical" "technical-service" "technical-service-1.0.0.jar" "technical"
    build_svc "report" "report-service" "report-service-1.0.0.jar" "report"
    build_svc "sap-integration" "sap-integration-service" "sap-integration-service-1.0.0.jar" "sap-integration"
    build_svc "wms-integration" "wms-integration-service" "wms-integration-service-1.0.0.jar" "wms-integration"
    build_svc "mdm-integration" "mdm-integration-service" "mdm-integration-service-1.0.0.jar" "mdm-integration"
    build_svc "gbom-integration" "gbom-integration-service" "gbom-integration-service-1.0.0.jar" "gbom-integration"
    build_svc "idms-integration" "idms-integration-service" "idms-integration-service-1.0.0.jar" "idms-integration"
    build_svc "call-center-integration" "call-center-integration-service" "call-center-integration-service-1.0.0.jar" "call-center-integration"
    build_svc "imp-exp" "imp-exp-service" "imp-exp-service-1.0.0.jar" "imp-exp"
    build_svc "workflow" "workflow-service" "workflow-service-1.0.0.jar" "workflow"
    build_svc "web-bff" "web-bff" "web-bff-1.0.0.jar" "web-bff"
    build_svc "mobile-bff" "mobile-bff" "mobile-bff-0.1.1-SNAPSHOT.jar" "mobile-bff"
    build_svc "api-gateway" "api-gateway" "api-gateway-2.0.0-SNAPSHOT.jar" "api-gateway"
    build_svc "db-flyway" "db-flyway-service" "db-flyway-service-2.0.0-SNAPSHOT.jar" "db-flyway"

    # Workflow Engine (Maven)
    log_info "Building workflow-engine (Maven)..."
    cd workflow-engine
    ./mvnw clean package -DskipTests 2>/dev/null || log_warn "workflow-engine: falhou"
    [ -f "Dockerfile-local" ] && docker build -f Dockerfile-local -t "gdmc/workflow-engine:local" . 2>/dev/null
    cd ..

    # Frontend
    log_info "Building web frontend..."
    cd web
    if [ -f "package.json" ]; then
        npm install 2>/dev/null
        npm run build:beta 2>/dev/null || npm run build 2>/dev/null || log_warn "web: build falhou"
        docker build -t "gdmc/web-frontend:local" - <<<"FROM nginx:alpine
COPY dist/ /usr/share/nginx/html/"
    fi
    cd ..

    log_info "Build completo!"
}

# ── WAIT ───────────────────────────────────────────────────────────────────
wait_healthy() {
    local svc=$1 timeout=${2:-60}
    log_info "Aguardando $svc ficar healthy..."
    for i in $(seq 1 $timeout); do
        if $COMPOSE ps $svc 2>/dev/null | grep -q "healthy"; then
            log_info "$svc ✓"
            return
        fi
        sleep 2
    done
    log_warn "$svc: timeout após ${timeout}s"
}

# ── INFRA ──────────────────────────────────────────────────────────────────
do_infra() {
    log_info "Subindo infraestrutura..."
    $COMPOSE up -d mysql redis zookeeper kafka
    wait_healthy "mysql" 90
    log_info "Subindo XXL-Job..."
    $COMPOSE up -d xxl-job-admin
    sleep 10
    log_info "Infra pronta!"
}

# ── CORE ───────────────────────────────────────────────────────────────────
do_core() {
    log_info "Subindo Core Services..."
    $COMPOSE up -d master-data org-user channel-data-center leads
    sleep 15
    log_info "Core pronto!"
}

# ── BUSINESS ───────────────────────────────────────────────────────────────
do_business() {
    log_info "Subindo Business Services..."
    $COMPOSE up -d sales-order purchase-order inventory transport-order \
        payment campaign consent retail warranty technical report
    sleep 15
    log_info "Business pronto!"
}

# ── INTEGRATIONS ───────────────────────────────────────────────────────────
do_integrations() {
    log_info "Subindo Integrações (stub)..."
    $COMPOSE up -d sap-integration wms-integration mdm-integration \
        gbom-integration idms-integration call-center-integration imp-exp
    sleep 10
    log_info "Integrações prontas!"
}

# ── FRONT ──────────────────────────────────────────────────────────────────
do_front() {
    log_info "Subindo Workflow + BFFs + Gateway + Frontend..."
    $COMPOSE up -d workflow workflow-engine web-bff mobile-bff api-gateway web-frontend
    sleep 10
    log_info "Front pronto!"
}

# ── ALL ────────────────────────────────────────────────────────────────────
do_all() {
    do_infra
    do_core
    do_business
    do_integrations
    do_front
    echo ""
    echo -e "${CYAN}=============================================${NC}"
    echo -e "${GREEN}  Plataforma GDMC-EU rodando!${NC}"
    echo -e "${CYAN}=============================================${NC}"
    echo ""
    echo "  Frontend:     http://localhost:3000"
    echo "  API Gateway:  http://localhost:8000"
    echo "  Web BFF:      http://localhost:8001"
    echo "  XXL-Job:      http://localhost:8494"
    echo ""
}

# ── STATUS ─────────────────────────────────────────────────────────────────
do_status() {
    echo ""
    echo -e "${CYAN}GDMC-EU Status${NC}"
    echo -e "${CYAN}===============${NC}"
    $COMPOSE ps
    echo ""
    echo "Health checks:"
    for pair in "master-data:8075" "org-user:8079" "channel-data-center:8078" \
                "leads:8077" "sales-order:8091" "purchase-order:8090" \
                "inventory:8092" "transport-order:8093" "payment:8094" \
                "campaign:8095" "consent:8096" "retail:8097" \
                "warranty:8098" "technical:8099" "report:8088" \
                "sap-integration:9010" "wms-integration:9011" \
                "api-gateway:8000" "web-bff:8001"; do
        name=${pair%%:*}
        port=${pair##*:}
        status=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:$port/actuator/health 2>/dev/null || echo "000")
        if [ "$status" = "200" ]; then
            echo -e "  ${GREEN}$name:$port => UP${NC}"
        else
            echo -e "  ${RED}$name:$port => DOWN ($status)${NC}"
        fi
    done
}

# ── DOWN ───────────────────────────────────────────────────────────────────
do_down() {
    log_info "Parando tudo..."
    $COMPOSE down
    log_info "Parado!"
}

# ── DOWN + VOLUMES ─────────────────────────────────────────────────────────
do_nuke() {
    log_warn "REMOVENDO tudo inclusive volumes (dados do MySQL serão perdidos)!"
    read -p "Tem certeza? [y/N] " confirm
    if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
        $COMPOSE down -v
        log_info "Nuke completo!"
    else
        log_info "Cancelado."
    fi
}

# ── MAIN ───────────────────────────────────────────────────────────────────
case "${1:-}" in
    build)         do_build ;;
    infra)         do_infra ;;
    core)          do_core ;;
    business)      do_business ;;
    integrations)  do_integrations ;;
    front)         do_front ;;
    all)           do_all ;;
    status)        do_status ;;
    down)          do_down ;;
    nuke)          do_nuke ;;
    *)
        echo "Uso: $0 {build|infra|core|business|integrations|front|all|status|down|nuke}"
        echo ""
        echo "  build         - Builda todos os JARs + imagens Docker"
        echo "  infra         - Sobe MySQL, Redis, Kafka, XXL-Job"
        echo "  core          - Sobe master-data, org-user, channel-data-center, leads"
        echo "  business      - Sobe sales-order, purchase-order, inventory, etc."
        echo "  integrations  - Sobe sap, wms, mdm, gbom, idms, call-center, imp-exp (stub)"
        echo "  front         - Sobe workflow, BFFs, gateway, frontend"
        echo "  all           - Sobe tudo em ordem"
        echo "  status        - Health check de todos os serviços"
        echo "  down          - Para todos os containers"
        echo "  nuke          - Remove tudo + volumes (apaga dados!)"
        ;;
esac