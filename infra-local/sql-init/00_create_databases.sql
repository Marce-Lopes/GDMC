-- =============================================================================
-- GDMC-EU — Criação de todos os databases para execução local
-- =============================================================================
-- Este script é executado automaticamente pelo MySQL Docker na primeira inicialização
-- =============================================================================

-- Databases dos Core Services
CREATE DATABASE IF NOT EXISTS master_data       CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE IF NOT EXISTS org_user          CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE IF NOT EXISTS channel_data_center CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE IF NOT EXISTS sales_order       CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE IF NOT EXISTS purchase_order    CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE IF NOT EXISTS inventory         CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE IF NOT EXISTS transport_order   CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE IF NOT EXISTS payment           CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE IF NOT EXISTS leads             CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE IF NOT EXISTS campaign          CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE IF NOT EXISTS consent           CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE IF NOT EXISTS retail            CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE IF NOT EXISTS warranty          CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE IF NOT EXISTS technical         CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE IF NOT EXISTS report            CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE IF NOT EXISTS after_sale_problem CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Databases das Integrações
CREATE DATABASE IF NOT EXISTS sap_integration   CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE IF NOT EXISTS wms_integration   CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE IF NOT EXISTS mdm_integration   CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE IF NOT EXISTS gbom_integration  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE IF NOT EXISTS idms_integration  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE IF NOT EXISTS call_center_integration CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE IF NOT EXISTS imp_exp           CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Databases de Workflow
CREATE DATABASE IF NOT EXISTS workflow          CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE IF NOT EXISTS workflow_engine   CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Database do XXL-Job
CREATE DATABASE IF NOT EXISTS xxl_job          CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Database do DB-Flyway
CREATE DATABASE IF NOT EXISTS db_flyway         CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Database do App Server
CREATE DATABASE IF NOT EXISTS app_server        CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Permissões
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%';
FLUSH PRIVILEGES;