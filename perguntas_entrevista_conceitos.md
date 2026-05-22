# Perguntas de Entrevista (Conceitos + Prática) - Stack GDMC

## Objetivo

Avaliar entendimento de fundamentos e aplicação prática em um contexto com:

- Java + Spring Boot/Spring Cloud
- Feign/API Gateway
- Kafka
- Redis
- MySQL
- Gradle multimódulo
- Kubernetes

## Perguntas Base (Conceitos)

### 1) Monolito vs microserviços

**Pergunta:** Explique a diferença entre arquitetura monolítica e microserviços e quando microserviços não valem a pena.\
**Resposta esperada:**

- Monolito centraliza tudo em uma aplicação; microserviços dividem por domínios.
- Microserviços ajudam escala/autonomia, mas aumentam complexidade operacional.
- Não vale a pena quando produto/time é pequeno, domínio simples ou operação ainda imatura.

### 2) Acoplamento entre serviços

**Pergunta:** O que é acoplamento entre serviços e quais sinais mostram acoplamento alto?\
**Resposta esperada:**

- Acoplamento é dependência forte entre serviços para completar fluxo.
- Sinais: cadeias longas de chamada síncrona, deploy coordenado, mudanças quebrando múltiplos serviços, timeout em cascata.

### 3) Síncrono vs assíncrono

**Pergunta:** Qual diferença entre comunicação síncrona (HTTP/Feign) e assíncrona (Kafka)?\
**Resposta esperada:**

- Síncrona: resposta imediata, simples de entender, mas cria bloqueio e cascata de falha.
- Assíncrona: desacopla produtor/consumidor, melhora resiliência e throughput, porém exige idempotência e observabilidade melhores.

### 4) Idempotência

**Pergunta:** O que significa idempotência e por que é essencial em callback de integração?\
**Resposta esperada:**

- Processar o mesmo evento várias vezes com mesmo resultado final.
- Essencial porque integrações podem reenviar payload por retry, timeout ou duplicidade de transporte.

### 5) Consistência forte vs eventual

**Pergunta:** Qual diferença entre consistência forte e eventual em sistemas distribuídos?\
**Resposta esperada:**

- Forte: leitura após escrita já reflete valor novo (mais rígido, mais custo/latência).
- Eventual: estado converge depois de um tempo (mais escalável, exige desenho de compensação).

### 6) Timeout, retry e circuit breaker

**Pergunta:** O que é timeout, retry e circuit breaker, e quando retry piora problema?\
**Resposta esperada:**

- Timeout limita espera.
- Retry tenta novamente falhas transitórias.
- Circuit breaker abre quando falhas sobem para proteger sistema.
- Retry piora quando erro é persistente (ex.: 4xx ou serviço indisponível), gerando tempestade de requisições.

### 7) Cache e risco de dado stale

**Pergunta:** O que é cache e quais riscos de cache desatualizado?\
**Resposta esperada:**

- Cache guarda leitura frequente para reduzir latência.
- Risco: retornar estado antigo; precisa TTL/invalidação por evento crítico.

### 8) Papel do API Gateway

**Pergunta:** Qual o papel de um API Gateway e o que não deveria estar nele?\
**Resposta esperada:**

- Gateway deve centralizar roteamento, autenticação básica, observabilidade e limites.
- Regra de negócio complexa e orquestração de domínio não devem morar nele.

### 9) Observabilidade

**Pergunta:** O que é observabilidade e diferença entre log, métrica e trace?\
**Resposta esperada:**

- Log: detalhe textual de eventos.
- Métrica: agregação numérica (latência, erro, throughput).
- Trace: caminho da requisição entre serviços com correlação.

### 10) Erro de negócio vs erro técnico

**Pergunta:** Qual diferença entre erro de negócio e erro técnico e como isso muda resposta HTTP?\
**Resposta esperada:**

- Negócio: violação de regra funcional (ex.: status inválido).
- Técnico: falha de infraestrutura/código (DB, timeout, NPE).
- Normalmente 4xx para regra de negócio; 5xx para erro técnico.

## Perguntas Base (Tecnologias)

### 11) Estereótipos Spring

**Pergunta:** No Spring Boot, diferença prática entre `@Component`, `@Service` e `@Repository`?\
**Resposta esperada:**

- Todos registram bean; semântica muda intenção.
- `@Service`: regra de negócio.
- `@Repository`: acesso a dados e tradução de exceção de persistência.

### 12) Transação local vs distribuída

**Pergunta:** Diferença entre transação local e distribuída; como lidar sem 2PC?\
**Resposta esperada:**

- Local: um banco/recurso.
- Distribuída: múltiplos recursos, mais complexa.
- Sem 2PC: usar Outbox, Saga/compensação, idempotência e reprocesso.

### 13) Kafka fundamentos

**Pergunta:** Em Kafka, explique offset, consumer group, partição e DLQ.\
**Resposta esperada:**

- Offset: posição de leitura.
- Consumer group: paralelismo e balanceamento.
- Partição: ordenação por partição e escala horizontal.
- DLQ: mensagens com erro definitivo para análise/reprocesso.

### 14) Redis uso correto

**Pergunta:** No Redis, quando usar cache e quando usar idempotência?\
**Resposta esperada:**

- Cache para leitura quente e baixa criticidade temporal.
- Idempotência para chave de deduplicação (`eventId`) com TTL e lock leve.

### 15) MySQL e índice

**Pergunta:** Qual impacto de índice ruim em fluxo de alto volume?\
**Resposta esperada:**

- Full scan, lock mais longo, aumento de latência, timeouts em cadeia e saturação de recursos.

### 16) Resiliência Feign

**Pergunta:** Em Feign/Spring Cloud, política mínima de resiliência por cliente?\
**Resposta esperada:**

- Timeout de conexão/leitura, retry seletivo, circuit breaker, fallback seguro e métricas por endpoint.

### 17) Gradle multimódulo

**Pergunta:** Em Gradle multimódulo, qual risco de versionamento inconsistente?\
**Resposta esperada:**

- Quebra de build/contrato entre módulos; conflitos transitivos; comportamento diferente entre ambientes.

### 18) Kubernetes probes

**Pergunta:** Em Kubernetes, o que readiness/liveness probe evita?\
**Resposta esperada:**

- Readiness evita receber tráfego sem estar pronto.
- Liveness reinicia pod travado/deadlocked.

## Perguntas Práticas (Raciocínio)

### 19) Latência alta com HTTP 200

**Pergunta:** Endpoint responde 200 em \~120s. Quais 3 hipóteses e validação?\
**Resposta esperada:**

- Hipóteses: query lenta/lock DB; cadeia síncrona longa; timeout/retry oculto de integração.
- Validação: trace ponta a ponta, métricas por dependência, slow query log e timeout config.

### 20) Chamada circular

**Pergunta:** Serviço A chama B, e B chama A antes de responder. Como redesenhar?\
**Resposta esperada:**

- Remover callback síncrono interno; B retorna primeiro; A segue com próxima etapa.
- Ou usar evento assíncrono para atualização posterior.

### 21) Callback duplicado

**Pergunta:** Callback externo chega 3 vezes. Como impedir efeito duplicado?\
**Resposta esperada:**

- Chave idempotente (`eventId`/`invoiceKey`) + storage de processamento + operação de escrita idempotente.

### 22) Falha no meio do fluxo

**Pergunta:** Atualizou banco local e falhou chamada externa. Como evitar inconsistência?\
**Resposta esperada:**

- Persistir intenção no Outbox, publicar assíncrono com retry, compensação quando necessário.

### 23) Reprocessamento seguro

**Pergunta:** Como reprocessar eventos sem duplicar efeito?\
**Resposta esperada:**

- Reprocesso por status, com deduplicação por chave de negócio e trilha de auditoria.

### 24) Responder rápido vs concluir tudo

**Pergunta:** Como decidir entre responder rápido e processar em background vs concluir tudo antes?\
**Resposta esperada:**

- Decidir por criticidade de confirmação imediata, SLA de usuário, custo de inconsistência e capacidade de compensação.

### 25) Métricas mínimas

**Pergunta:** Quais métricas mínimas para monitorar fluxo de faturamento ponta a ponta?\
**Resposta esperada:**

- Latência p50/p95/p99 por etapa, taxa de erro, timeout, retries, backlog Kafka, DLQ, throughput e tempo de reprocesso.

### 26) Rollout seguro

**Pergunta:** Como fazer rollout seguro de mudança crítica?\
**Resposta esperada:**

- Feature flag, canary gradual, métricas de guarda, rollback automático/manual, plano de comunicação.

## Critérios de Avaliação

- **Conceito:** explica fundamentos sem buzzword vazio.
- **Aplicação:** conecta conceito com decisão técnica prática.
- **Trade-off:** enxerga custo/risco e impacto no negócio.
- **Clareza:** comunica de forma estruturada e objetiva.

## Peso por Pergunta

Escala sugerida por pergunta: **0 a 5 pontos**.

### Distribuição de peso (total 100%)

- Perguntas **1 a 10** (Conceitos): **2% cada** (20% no total)
- Perguntas **11 a 18** (Tecnologias): **5% cada** (40% no total)
- Perguntas **19 a 26** (Práticas): **5% cada** (40% no total)

### Peso individual

- Q1: 2%
- Q2: 2%
- Q3: 2%
- Q4: 2%
- Q5: 2%
- Q6: 2%
- Q7: 2%
- Q8: 2%
- Q9: 2%
- Q10: 2%
- Q11: 5%
- Q12: 5%
- Q13: 5%
- Q14: 5%
- Q15: 5%
- Q16: 5%
- Q17: 5%
- Q18: 5%
- Q19: 5%
- Q20: 5%
- Q21: 5%
- Q22: 5%
- Q23: 5%
- Q24: 5%
- Q25: 5%
- Q26: 5%

## Rubrica (como dar a nota 0-5)

- **0:** não respondeu ou resposta incorreta.
- **1:** resposta superficial e confusa.
- **2:** acerta parcialmente, sem profundidade.
- **3:** correta no básico, com exemplos simples.
- **4:** sólida, conecta conceito com decisão prática.
- **5:** excelente, explicita trade-offs, riscos e mitigação.

## Fórmula de Nota Final

- **Nota ponderada por pergunta** = `nota(0-5) * peso(%)`
- **Nota final (0-5)** = `soma das notas ponderadas / 100`
- **Nota final (%)** = `(nota final / 5) * 100`

## Tabela de Avaliação (preenchimento)

| Q         |  Peso % | Nota (0-5) | Pontuação ponderada | Observações |
| --------- | ------: | ---------: | ------------------: | ----------- |
| 1         |       2 |     <br /> |              <br /> | <br />      |
| 2         |       2 |     <br /> |              <br /> | <br />      |
| 3         |       2 |     <br /> |              <br /> | <br />      |
| 4         |       2 |     <br /> |              <br /> | <br />      |
| 5         |       2 |     <br /> |              <br /> | <br />      |
| 6         |       2 |     <br /> |              <br /> | <br />      |
| 7         |       2 |     <br /> |              <br /> | <br />      |
| 8         |       2 |     <br /> |              <br /> | <br />      |
| 9         |       2 |     <br /> |              <br /> | <br />      |
| 10        |       2 |     <br /> |              <br /> | <br />      |
| 11        |       5 |     <br /> |              <br /> | <br />      |
| 12        |       5 |     <br /> |              <br /> | <br />      |
| 13        |       5 |     <br /> |              <br /> | <br />      |
| 14        |       5 |     <br /> |              <br /> | <br />      |
| 15        |       5 |     <br /> |              <br /> | <br />      |
| 16        |       5 |     <br /> |              <br /> | <br />      |
| 17        |       5 |     <br /> |              <br /> | <br />      |
| 18        |       5 |     <br /> |              <br /> | <br />      |
| 19        |       5 |     <br /> |              <br /> | <br />      |
| 20        |       5 |     <br /> |              <br /> | <br />      |
| 21        |       5 |     <br /> |              <br /> | <br />      |
| 22        |       5 |     <br /> |              <br /> | <br />      |
| 23        |       5 |     <br /> |              <br /> | <br />      |
| 24        |       5 |     <br /> |              <br /> | <br />      |
| 25        |       5 |     <br /> |              <br /> | <br />      |
| 26        |       5 |     <br /> |              <br /> | <br />      |
| **Total** | **100** |     <br /> |              <br /> | <br />      |

## Classificação sugerida

- **85% a 100%**: Forte aderência para Tech Lead.
- **70% a 84%**: Bom nível, com gaps pontuais.
- **55% a 69%**: Nível intermediário, precisa mentoria.
- **Abaixo de 55%**: Não aderente para liderança técnica neste contexto.
