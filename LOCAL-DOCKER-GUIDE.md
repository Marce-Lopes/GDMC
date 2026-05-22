"# GDMC-EU — Guia Completo: Subir Tudo Local com Docker

## Visão Geral

Este guia replica toda a plataforma GDMC-EU localmente via Docker Compose,
**sem conexões externas** (SAP, WMS, MDM, GBOM, IDMS, Call Center, Huawei OBS).

---

## Mapa de Portas (dev/local)

| Serviço | Porta | Container |
|---------|-------|-----------|
| **API Gateway** | 8000 | gdmc-api-gateway |
| **Web BFF** | 8001 | gdmc-web-bff |
| **Mobile BFF** | 8002 | gdmc-mobile-bff |
| **Web Frontend** | 3000 | gdmc-web-frontend |
| **Master Data** | 8075 | gdmc-master-data |
| **Channel Data Center** | 8078 | gdmc-channel-data-center |
| **Org User** | 8079 | gdmc-org-user |
| **Leads** | 8077 | gdmc-leads |
| **Sales Order** | 8091 | gdmc-sales-order |
| **Purchase Order** | 8090 | gdmc-purchase-order |
| **Inventory** | 8092 | gdmc-inventory |
| **Transport Order** | 8093 | gdmc-transport-order |
| **Payment** | 8094 | gdmc-payment |
| **Campaign** | 8095 | gdmc-campaign |
| **Consent** | 8096 | gdmc-consent |
| **Retail** | 8097 | gdmc-retail |
| **Warranty** | 8098 | gdmc-warranty |
| **Technical** | 8099 | gdmc-technical |
| **Report** | 8088 | gdmc-report |
| **SAP Integration** | 9010 | gdmc-sap-integration |
| **WMS Integration** | 9011 | gdmc-wms-integration |
| **MDM Integration** | 9012 | gdmc-mdm-integration |
| **GBOM Integration** | 9013 | gdmc-gbom-integration |
| **IDMS Integration** | 9014 | gdmc-idms-integration |
| **Call Center Int.** | 9015 | gdmc-call-center-integration |
| **Imp-Exp** | 9016 | gdmc-imp-exp |
| **Workflow** | 8102 | gdmc-workflow |
| **Workflow Engine** | 8103 | gdmc-workflow-engine |
| **DB Flyway** | 8033 | gdmc-db-flyway |
| **XXL-Job Admin** | 8494 | gdmc-xxl-job-admin |
| **MySQL** | 3306 | gdmc-mysql |
| **Redis** | 6379 | gdmc-redis |
| **Kafka** | 9092 | gdmc-kafka |
| **Zookeeper** | 2181 | gdmc-zookeeper |

---

## Passo a Passo

### 1. Pré-requisitos

- Java 11 (JDK)
- Docker + Docker Compose
- 16GB+ RAM recomendado (~25 containers)
- Node.js 16+ (para build do frontend)

### 2. Publicar common-lib no Maven Local

Os serviços dependem de `com.gdmc.eu.common.lib:*`. Sem isso, nada compila.

```bash
cd common-lib
./gradlew clean publishToMavenLocal -x test
cd ..
```

### 3. Publicar clients no Maven Local

Cada serviço `-client` precisa estar no mavenLocal para os consumidores:

```bash
# Ordem importa! Services que dependem de outros clients primeiro:
for svc in app-server org-user master-data channel-data-center leads \
            sales-order purchase-order inventory transport-order payment \
            campaign consent retail warranty technical report \
            sap-integration wms-integration mdm-integration gbom-integration \
            idms-integration call-center-integration imp-exp workflow notification; do
  echo "=== Publishing $svc-client ==="
  cd "$svc"
  ./gradlew clean publishToMavenLocal -x test -x integrationTest 2>/dev/null || echo "SKIP $svc"
  cd ..
done
```

### 4. Build dos serviços (JARs)

```bash
# Usar o script fornecido:
chmod +x build-all-local.sh
./build-all-local.sh

# OU build manual serviço a serviço:
cd sales-order && ./gradlew clean build -x test -x integrationTest && cd ..
```

### 5. Criar databases MySQL

O script `infra-local/sql-init/00_create_databases.sql` cria todos os
databases automaticamente na primeira inicialização do MySQL container.

### 6. Subir infraestrutura primeiro

```bash
docker-compose -f docker-compose-local.yml up -d mysql redis zookeeper kafka xxl-job-admin

# Aguardar MySQL ficar healthy:
docker-compose -f docker-compose-local.yml logs -f mysql
# Aguardar até: "mysqld: ready for connections"
```

### 7. Rodar Flyway (migração de schema)

Cada serviço tem seus scripts Flyway em `src/main/resources/db/migration/`.
Opções:

**Opção A:** Subir o serviço db-flyway:
```bash
docker-compose -f docker-compose-local.yml up -d db-flyway
```

**Opção B:** Rodar Flyway manualmente por serviço:
```bash
# Exemplo para sales_order:
mysql -h 127.0.0.1 -u root -pgdmc123 sales_order < \
  sales-order/sales-order-service/src/main/resources/db/migration/V1.1__create_distributor_purchase_order_table.sql
# (repetir para cada migration, em ordem)
```

**Opção C:** Deixar o Flyway embutido em cada serviço rodar automaticamente
(cada serviço já tem `flyway-core` nas dependências).

### 8. Subir Core Services

```bash
docker-compose -f docker-compose-local.yml up -d \
  master-data org-user channel-data-center leads
```

### 9. Subir Business Services

```bash
docker-compose -f docker-compose-local.yml up -d \
  sales-order purchase-order inventory transport-order \
  payment campaign consent retail warranty technical report
```

### 10. Subir Integrações (stub)

```bash
docker-compose -f docker-compose-local.yml up -d \
  sap-integration wms-integration mdm-integration \
  gbom-integration idms-integration call-center-integration imp-exp
```

### 11. Subir Workflow + BFFs + Gateway

```bash
docker-compose -f docker-compose-local.yml up -d \
  workflow workflow-engine web-bff mobile-bff api-gateway
```

### 12. Subir Frontend

```bash
cd web && npm install && npm run build:beta && cd ..
docker-compose -f docker-compose-local.yml up -d web-frontend
```

### 13. Acessar

| URL | Serviço |
|-----|---------|
| http://localhost:3000 | Frontend Web (Vue) |
| http://localhost:8000 | API Gateway |
| http://localhost:8001 | Web BFF |
| http://localhost:8002 | Mobile BFF |
| http://localhost:8494 | XXL-Job Admin |
| http://localhost:8075 | Master Data (direto) |
| http://localhost:8091 | Sales Order (direto) |

---

## Problemas Conhecidos e Workarounds

### 1. OBS (Huawei Cloud Object Storage)
**Problema:** Vários serviços dependem de `obs-util` do common-lib.
**Solução:** Criar implementação `NoOpObsUtil` que faz nada, ou mockar
com MinIO (S3-compatible):

```yaml
# Adicionar ao docker-compose-local.yml:
minio:
  image: minio/minio:latest
  ports:
    - "9000:9000"
  environment:
    MINIO_ACCESS_KEY: test
    MINIO_SECRET_KEY: testtest
  command: server /data
```

### 2. Kafka Topics
**Problema:** Alguns serviços esperam topics pré-criados.
**Solução:** `auto.create.topics.enable=true` já está configurado.
Para criar manualmente:

```bash
docker exec -it gdmc-kafka kafka-topics.sh --create \
  --bootstrap-server localhost:9092 \
  --topic gdmc-vehicle-so-to-po --partitions 3 --replication-factor 1
```

### 3. Versionamento Inconsistente
**Problema:** Alguns clients usam `1.0.0`, outros `0.1.1-SNAPSHOT`.
**Solução:** Antes do build, unificar versões ou usar `mavenLocal()` no
repositório Gradle (já configurado na maioria).

### 4. Profile `local` não existe em todos os serviços
**Problema:** Só `dev`, `pre`, `test`, `uat`, `prod` existem.
**Solução:** Criar `application-local.yml` em cada serviço (já criado
para sales-order). Para os demais, usar `dev` com overrides via
env vars no docker-compose.

### 5. Spring Cloud Discovery sem Kubernetes
**Problema:** Alguns serviços usam `spring-cloud-starter-kubernetes-fabric8-all`.
**Solução:** Em Docker Compose, usar `spring-cloud-starter-loadbalancer` +
URLs Feign hardcoded (já é o padrão no profile dev).

### 6. XXL-Job Database
**Problema:** XXL-Job precisa de suas tabelas criadas no MySQL.
**Solução:**

```bash
# Baixar schema do XXL-Job:
curl -o infra-local/sql-init/xxl-job.sql \
  https://raw.githubusercontent.com/xuxueli/xxl-job/master/doc/db/tables_xxl_job.sql
```

---

## Ordem de Start Completa (one-liner)

```bash
# Infra
docker-compose -f docker-compose-local.yml up -d mysql redis zookeeper kafka

# Esperar MySQL
sleep 15

# XXL-Job
docker-compose -f docker-compose-local.yml up -d xxl-job-admin

# Core
docker-compose -f docker-compose-local.yml up -d master-data org-user channel-data-center leads

# Business
docker-compose -f docker-compose-local.yml up -d sales-order purchase-order inventory transport-order payment campaign consent retail warranty technical report after-sale-problem

# Integrações
docker-compose -f docker-compose-local.yml up -d sap-integration wms-integration mdm-integration gbom-integration idms-integration call-center-integration imp-exp

# Workflow
docker-compose -f docker-compose-local.yml up -d workflow workflow-engine

# BFFs + Gateway
docker-compose -f docker-compose-local.yml up -d web-bff mobile-bff api-gateway

# Frontend
docker-compose -f docker-compose-local.yml up -d web-frontend
```

---

## Comandos Úteis

```bash
# Ver logs de um serviço
docker-compose -f docker-compose-local.yml logs -f sales-order

# Restart um serviço
docker-compose -f docker-compose-local.yml restart sales-order

# Parar tudo
docker-compose -f docker-compose-local.yml down

# Parar e limpar volumes (CUIDADO: apaga dados do MySQL)
docker-compose -f docker-compose-local.yml down -v

# Status de todos
docker-compose -f docker-compose-local.yml ps

# Health check de todos os serviços
for port in 8075 8077 8078 8079 8088 8090 8091 8092 8093 8094 8095 8096 8097 8098 8099 9010 9011; do
  status=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:$port/actuator/health 2>/dev/null || echo "OFF")
  echo "$port => $status"
done
```

---

## Arquitetura dos Containers

```
                    ┌──────────────────────┐
                    │   web-frontend :3000 │  (Vue 3 + Nginx)
                    └──────────┬───────────┘
                               │
                    ┌──────────▼───────────┐
                    │  api-gateway  :8000  │  (Spring Cloud Gateway)
                    └──────────┬───────────┘
                               │
              ┌────────────────┼────────────────┐
              ▼                ▼                ▼
     ┌──────────────┐  ┌──────────────┐  ┌──────────────┐
     │ web-bff :8001│  │mobile-bff    │  │              │
     └──────┬───────┘  │  :8002       │  │              │
            │          └──────┬───────┘  │              │
   ─────────┼─────────────────┼──────────┼──────────────
            ▼                 ▼          ▼
   ┌─────────────────────────────────────────────────┐
   │              CORE + BUSINESS SERVICES            │
   │  master-data:8075  sales-order:8091             │
   │  org-user:8079     purchase-order:8090          │
   │  channel-dc:8078   inventory:8092               │
   │  leads:8077        transport-order:8093         │
   │  payment:8094      campaign:8095                │
   │  consent:8096      retail:8097                  │
   │  warranty:8098     technical:8099               │
   │  report:8088       after-sale-problem:8100      │
   └──────────────────────┬──────────────────────────┘
                          │
   ───────────────────────┼──────────────────────────
                          ▼
   ┌─────────────────────────────────────────────────┐
   │           INTEGRAÇÕES (stub local)              │
   │  sap-integration:9010    wms-integration:9011   │
   │  mdm-integration:9012    gbom-integration:9013  │
   │  idms-integration:9014   call-center:9015       │
   │  imp-exp:9016                                   │
   └─────────────────────────────────────────────────┘
                          │
   ───────────────────────┼──────────────────────────
                          ▼
   ┌─────────────────────────────────────────────────┐
   │              INFRAESTRUTURA                     │
   │  MySQL:3306   Redis:6379   Kafka:9092           │
   │  XXL-Job:8494  Zookeeper:2181                   │
   └─────────────────────────────────────────────────┘
```